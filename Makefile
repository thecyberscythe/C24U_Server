# Define the paths for the Rust and Go applications
RUST_SERVER_PATH=rust_server
RUST_PROXIED_SERVER_PATH=rust_server_proxied
GO_SERVER_PATH=go_server
GO_PROXIED_SERVER_PATH=go_server_proxied

# Define the TLS certificate files
CERT_FILE=cert.pem
KEY_FILE=key.pem

# Default port
PORT ?= 8080

# Detect operating system
OS := $(shell uname)

# Default action is to show help
.PHONY: default
default: help

# Help target
.PHONY: help
help:
	@echo "Usage: make <target> [OS=<os>] [PORT=<port>]"
	@echo ""
	@echo "Targets:"
	@echo "  tls                    Run the tls.sh script to generate TLS certificates"
	@echo "  rust_build             Build the standalone Rust server application"
	@echo "  rust_build_proxied     Build the proxied Rust server application"
	@echo "  go_build               Build the standalone Go server application"
	@echo "  go_build_proxied       Build the proxied Go server application"
	@echo "  rust_run               Run the standalone Rust server application"
	@echo "  rust_run_proxied       Run the proxied Rust server application"
	@echo "  go_run                 Run the standalone Go server application"
	@echo "  go_run_proxied         Run the proxied Go server application"
	@echo "  clean                  Clean up build artifacts"
	@echo "  build_windows          Build for Windows"
	@echo "  build_macos            Build for MacOS"
	@echo "  build_linux_deb        Build for Linux (Debian based)"
	@echo "  build_linux_rpm        Build for Linux (RPM based)"

# Run the tls.sh script to generate TLS certificates
.PHONY: tls
tls:
	@echo "Generating TLS certificates..."
	./tls.sh

# Build the standalone Rust server application
.PHONY: rust_build
rust_build: tls
	@echo "Building standalone Rust server application..."
	cd $(RUST_SERVER_PATH) && cargo build --release

# Build the proxied Rust server application
.PHONY: rust_build_proxied
rust_build_proxied: tls
	@echo "Building proxied Rust server application..."
	cd $(RUST_PROXIED_SERVER_PATH) && cargo build --release

# Build the standalone Go server application
.PHONY: go_build
go_build: tls
	@echo "Building standalone Go server application..."
	cd $(GO_SERVER_PATH) && go build -o server main.go

# Build the proxied Go server application
.PHONY: go_build_proxied
go_build_proxied: tls
	@echo "Building proxied Go server application..."
	cd $(GO_PROXIED_SERVER_PATH) && go build -o server main.go

# Run the standalone Rust server application
.PHONY: rust_run
rust_run: rust_build
	@echo "Running standalone Rust server application on port $(PORT)..."
	PORT=$(PORT) ./$(RUST_SERVER_PATH)/target/release/rust_server

# Run the proxied Rust server application
.PHONY: rust_run_proxied
rust_run_proxied: rust_build_proxied
	@echo "Running proxied Rust server application on port $(PORT)..."
	PORT=$(PORT) ./$(RUST_PROXIED_SERVER_PATH)/target/release/rust_server_proxied

# Run the standalone Go server application
.PHONY: go_run
go_run: go_build
	@echo "Running standalone Go server application..."
	./$(GO_SERVER_PATH)/server

# Run the proxied Go server application
.PHONY: go_run_proxied
go_run_proxied: go_build_proxied
	@echo "Running proxied Go server application..."
	./$(GO_PROXIED_SERVER_PATH)/server

# Clean up build artifacts
.PHONY: clean
clean:
	@echo "Cleaning up build artifacts..."
	cd $(RUST_SERVER_PATH) && cargo clean
	cd $(RUST_PROXIED_SERVER_PATH) && cargo clean
	rm -f $(GO_SERVER_PATH)/server
	rm -f $(GO_PROXIED_SERVER_PATH)/server
	rm -f $(CERT_FILE) $(KEY_FILE)

# Build for Windows
.PHONY: build_windows
build_windows:
	@echo "Building for Windows..."
	# Rust standalone
	cd $(RUST_SERVER_PATH) && cargo build --release --target x86_64-pc-windows-gnu
	# Rust proxied
	cd $(RUST_PROXIED_SERVER_PATH) && cargo build --release --target x86_64-pc-windows-gnu
	# Go standalone
	cd $(GO_SERVER_PATH) && GOOS=windows GOARCH=amd64 go build -o server.exe main.go
	# Go proxied
	cd $(GO_PROXIED_SERVER_PATH) && GOOS=windows GOARCH=amd64 go build -o server.exe main.go

# Build for MacOS
.PHONY: build_macos
build_macos:
	@echo "Building for MacOS..."
	# Rust standalone
	cd $(RUST_SERVER_PATH) && cargo build --release --target x86_64-apple-darwin
	# Rust proxied
	cd $(RUST_PROXIED_SERVER_PATH) && cargo build --release --target x86_64-apple-darwin
	# Go standalone
	cd $(GO_SERVER_PATH) && GOOS=darwin GOARCH=amd64 go build -o server main.go
	# Go proxied
	cd $(GO_PROXIED_SERVER_PATH) && GOOS=darwin GOARCH=amd64 go build -o server main.go

# Build for Linux (Debian based)
.PHONY: build_linux_deb
build_linux_deb:
	@echo "Building for Linux (Debian based)..."
	# Rust standalone
	cd $(RUST_SERVER_PATH) && cargo build --release --target x86_64-unknown-linux-gnu
	# Rust proxied
	cd $(RUST_PROXIED_SERVER_PATH) && cargo build --release --target x86_64-unknown-linux-gnu
	# Go standalone
	cd $(GO_SERVER_PATH) && GOOS=linux GOARCH=amd64 go build -o server main.go
	# Go proxied
	cd $(GO_PROXIED_SERVER_PATH) && GOOS=linux GOARCH=amd64 go build -o server main.go

# Build for Linux (RPM based)
.PHONY: build_linux_rpm
build_linux_rpm:
	@echo "Building for Linux (RPM based)..."
	# Rust standalone
	cd $(RUST_SERVER_PATH) && cargo build --release --target x86_64-unknown-linux-gnu
	# Rust proxied
	cd $(RUST_PROXIED_SERVER_PATH) && cargo build --release --target x86_64-unknown-linux-gnu
	# Go standalone
	cd $(GO_SERVER_PATH) && GOOS=linux GOARCH=amd64 go build -o server main.go
	# Go proxied
	cd $(GO_PROXIED_SERVER_PATH) && GOOS=linux GOARCH=amd64 go build -o server main.go
