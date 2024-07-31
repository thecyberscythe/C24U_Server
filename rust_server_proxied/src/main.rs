use tokio::net::TcpListener;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::time::{sleep, Duration};
use tokio_native_tls::{TlsAcceptor, native_tls};
use base64::encode;
use log::{info, warn, error};
use env_logger;
use reqwest::Client;
use serde::{Deserialize, Serialize};

#[derive(Deserialize, Serialize)]
struct CommandResponse {
    command: String,
    output: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    env_logger::init();

    info!("Starting server...");

    // Load TLS certificates
    let cert = include_bytes!("../../cert.pem");
    let key = include_bytes!("../../key.pem");

    let identity = native_tls::Identity::from_pkcs8(cert, key)?;
    let acceptor = TlsAcceptor::from(native_tls::TlsAcceptor::builder(identity).build()?);

    // Bind the server to the address
    let listener = TcpListener::bind("127.0.0.1:8080").await?;
    info!("Server listening on 127.0.0.1:8080");

    // Initialize HTTP client
    let client = Client::new();

    loop {
        let (socket, _) = listener.accept().await?;
        let acceptor = acceptor.clone();
        let client = client.clone();

        tokio::spawn(async move {
            let mut socket = match acceptor.accept(socket).await {
                Ok(socket) => {
                    info!("Accepted connection");
                    socket
                }
                Err(e) => {
                    error!("Failed to accept connection: {}", e);
                    return;
                }
            };

            let mut buffer = [0; 1024];

            // Fetch commands from the Lambda function
            let lambda_url = "https://<api-id>.execute-api.<region>.amazonaws.com/prod/commands"; // Replace with your API Gateway URL

            match client.get(lambda_url).send().await {
                Ok(response) => {
                    if response.status().is_success() {
                        match response.json::<CommandResponse>().await {
                            Ok(cmd_response) => {
                                info!("Received command from Lambda: {}", cmd_response.command);

                                // Send the command to the client
                                let encoded_command = cmd_response.command;
                                if let Err(e) = socket.write_all(encoded_command.as_bytes()).await {
                                    error!("Failed to write to socket: {}", e);
                                    return;
                                }

                                // Give the client some time to execute the command and send the response
                                sleep(Duration::from_secs(1)).await;

                                let n = match socket.read(&mut buffer).await {
                                    Ok(n) if n == 0 => return, // Connection closed
                                    Ok(n) => n,
                                    Err(e) => {
                                        error!("Failed to read from socket: {}", e);
                                        return;
                                    }
                                };

                                let response = String::from_utf8_lossy(&buffer[..n]);
                                info!("Response from client: {}", response);

                                // Send the response back to the Lambda function
                                let cmd_response = CommandResponse {
                                    command: encoded_command,
                                    output: response.to_string(),
                                };

                                if let Err(e) = client.post(lambda_url)
                                    .json(&cmd_response)
                                    .send()
                                    .await
                                {
                                    error!("Failed to send response to Lambda: {}", e);
                                }
                            }
                            Err(e) => {
                                error!("Failed to parse Lambda response: {}", e);
                            }
                        }
                    } else {
                        error!("Failed to fetch commands from Lambda: {}", response.status());
                    }
                }
                Err(e) => {
                    error!("Failed to send request to Lambda: {}", e);
                }
            }
        });
    }
}
