BACKEND_DIR := backend
FRONTEND_DIR := frontend
PROXY_DIR := proxy
PROTO_DIR := proto

.PHONY: all help setup generate-proto build-backend run-backend run-frontend run-proxy run-all clean stop status

# TODO: consider moving to gmake syntax with dependencies where possible/required

# TODO: lock versions
setup:
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	cd $(BACKEND_DIR) && go mod tidy
	npm install -g protoc-gen-js protoc-gen-grpc-web
	cd $(FRONTEND_DIR) && npm install


# Generate protobuf code for both Go and JS
generate-proto:
	# Make sure directories exist
	mkdir -p $(PROTO_DIR)
	mkdir -p $(BACKEND_DIR)/proto
	mkdir -p $(FRONTEND_DIR)/src/proto
	
	# Generate Go code from all proto files
	protoc -I$(PROTO_DIR) \
		--go_out=$(BACKEND_DIR)/proto --go_opt=paths=source_relative \
		--go-grpc_out=$(BACKEND_DIR)/proto --go-grpc_opt=paths=source_relative \
		$(PROTO_DIR)/**/*.proto
	
	# Generate JS code from all proto files
	protoc -I$(PROTO_DIR) \
		--js_out=import_style=commonjs:$(FRONTEND_DIR)/src/proto \
		--grpc-web_out=import_style=commonjs,mode=grpcwebtext:$(FRONTEND_DIR)/src/proto \
		$(PROTO_DIR)/**/*.proto

# Build the backend executable
build-backend: $(GO_PROTO_OUT)
	cd $(BACKEND_DIR) && go build -o bin/server cmd/server/main.go

# Run the backend server (depends on generate-proto)
run-backend: $(GO_PROTO_OUT)
	cd $(BACKEND_DIR) && go run cmd/server/main.go

# Run the frontend (depends on generate-proto)
run-frontend: $(JS_PROTO_OUT)
	cd $(FRONTEND_DIR) && npm run serve


run-proxy:
	cd $(PROXY_DIR) && docker-compose up -d

# Run all components
run-all: generate-proto
	@make -j3 run-backend run-proxy run-frontend

# Stop all running components
stop:
	-pkill -f "$(BACKEND_DIR)/server" || true
	-cd $(PROXY_DIR) && docker-compose down || true
	-pkill -f "$(FRONTEND_DIR)" || true

# Check status of components
status:
	@echo "Backend: $(shell pgrep -f "$(BACKEND_DIR)/server" > /dev/null && echo "Running" || echo "Stopped")"
	@echo "Proxy: $(shell docker ps --filter name=stock-sentiment-proxy -q | grep -q . && echo "Running" || echo "Stopped")"
	@echo "Frontend: $(shell pgrep -f "$(FRONTEND_DIR)" > /dev/null && echo "Running" || echo "Stopped")"

# Clean build artifacts
clean:
	cd $(BACKEND_DIR) && rm -rf bin/
	cd $(FRONTEND_DIR) && rm -rf dist/
