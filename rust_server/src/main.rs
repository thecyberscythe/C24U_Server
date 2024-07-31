use tokio::net::TcpListener;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::time::{sleep, Duration};
use base64::encode;
use tokio_native_tls::{TlsAcceptor, native_tls};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cert = include_bytes!("../../cert.pem");
    let key = include_bytes!("../../key.pem");

    let identity = native_tls::Identity::from_pkcs8(cert, key)?;
    let acceptor = TlsAcceptor::from(native_tls::TlsAcceptor::builder(identity).build()?);

    let listener = TcpListener::bind("127.0.0.1:443").await?;
    println!("Server listening on 127.0.0.1:443");

    loop {
        let (socket, _) = listener.accept().await?;
        let acceptor = acceptor.clone();

        tokio::spawn(async move {
            let mut socket = match acceptor.accept(socket).await {
                Ok(socket) => socket,
                Err(e) => {
                    eprintln!("Failed to accept connection: {}", e);
                    return;
                }
            };

            let mut buffer = [0; 1024];
            let commands = vec!["date", "uptime", "whoami"];

            for cmd in commands {
                println!("Sending command to client: {}", cmd);
                let encoded_command = encode(cmd);
                if let Err(e) = socket.write_all(encoded_command.as_bytes()).await {
                    eprintln!("Failed to write to socket: {}", e);
                    return;
                }

                // Give the client some time to execute the command and send the response
                sleep(Duration::from_secs(1)).await;

                let n = match socket.read(&mut buffer).await {
                    Ok(n) if n == 0 => return, // Connection closed
                    Ok(n) => n,
                    Err(_) => {
                        eprintln!("Failed to read from socket");
                        return;
                    }
                };

                let response = String::from_utf8_lossy(&buffer[..n]);
                println!("Response from client: {}", response);
            }
        });
    }
}
