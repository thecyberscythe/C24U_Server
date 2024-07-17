package main

import (
	"bytes"
	"context"
	"errors"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
)

type Command struct {
	Endpoint string `json:"endpoint"`
	Command  string `json:"command"`
}

type Response struct {
	Output string `json:"output"`
}

func handler(ctx context.Context, request Command) (Response, error) {
	// Validate the input
	if request.Endpoint == "" || request.Command == "" {
		errMsg := "Invalid input: Endpoint or Command is empty"
		log.Println(errMsg)
		return Response{}, errors.New(errMsg)
	}

	log.Printf("Forwarding command to endpoint: %s\n", request.Endpoint)

	// Create a HTTP client with timeout
	client := &http.Client{
		Timeout: 10 * time.Second,
	}

	// Forward the command to the remote endpoint
	resp, err := client.Post(request.Endpoint, "application/json", bytes.NewBuffer([]byte(request.Command)))
	if err != nil {
		log.Printf("Error forwarding command to endpoint: %v\n", err)
		return Response{}, err
	}
	defer resp.Body.Close()

	// Read the response from the remote endpoint
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Printf("Error reading response from endpoint: %v\n", err)
		return Response{}, err
	}

	// Log the response
	log.Printf("Received response from endpoint: %s\n", string(body))

	// Return the response back to the original sender
	return Response{Output: string(body)}, nil
}

func main() {
	// Setup logging to a file
	f, err := os.OpenFile("/var/log/proxy.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Fatalf("Error opening log file: %v\n", err)
	}
	defer f.Close()
	log.SetOutput(f)
	log.Println("Starting the Lambda function")

	// Start the Lambda handler
	lambda.Start(handler)
}
