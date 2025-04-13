# gRPC Web Project

A web application using gRPC with Go backend and JS frontend.

## Prerequisites

- Go 1.18+
- Node.js 16+
- npm
- Docker and Docker Compose
- protoc (Protocol Buffers compiler)


## Setup

1. Install dependencies:

```bash
make setup
```

This installs:
- Protocol Buffers Go plugins
- gRPC Web tools
- Backend Go dependencies
- Frontend npm packages

## Development Workflow

### Generate Protocol Buffer Code

```bash
make generate-proto
```

### Run Individual Components

Backend:
```bash
make run-backend
```

Frontend:
```bash
make run-frontend
```

Proxy:
```bash
make run-proxy
```

### Run All Components

```bash
make run-all
```

### Stop All Services

```bash
make stop
```

### Check Status

```bash
make status
```

### Clean Build Artifacts

```bash
make clean
```