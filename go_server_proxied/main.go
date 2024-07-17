package main

import (
	"bufio"
	"crypto/tls"
	"fmt"
	"net"
	"time"
)

func handleConnection(conn net.Conn) {
	defer conn.Close()
	fmt.Println("Client connected")

	commands := []string{"date", "uptime", "whoami"}

	for _, cmd := range commands {
		fmt.Printf("Sending command to client: %s\n", cmd)
		_, err := conn.Write([]byte(cmd + "\n"))
		if err != nil {
			fmt.Printf("Failed to write to client: %v\n", err)
			return
		}

		// Read response from client
		response, err := bufio.NewReader(conn).ReadString('\n')
		if err != nil {
			fmt.Printf("Failed to read from client: %v\n", err)
			return
		}
		fmt.Printf("Response from client: %s", response)

		time.Sleep(5 * time.Second)
	}
}

func main() {
	cert, err := tls.LoadX509KeyPair("cert.pem", "key.pem")
	if err != nil {
		fmt.Printf("Error loading certificate: %v\n", err)
		return
	}

	config := &tls.Config{Certificates: []tls.Certificate{cert}}
	listener, err := tls.Listen("tcp", "127.0.0.1:443", config)
	if err != nil {
		fmt.Printf("Error starting server: %v\n", err)
		return
	}
	defer listener.Close()
	fmt.Println("Server listening on 127.0.0.1:443")

	for {
		conn, err := listener.Accept()
		if err != nil {
			fmt.Printf("Error accepting connection: %v\n", err)
			continue
		}

		go handleConnection(conn)
	}
}
