package main

import (
	"log"
	"net"

	"stock-sentiment/backend/internal/service"
	pb "stock-sentiment/backend/proto/sentiment"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {

	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	grpcServer := grpc.NewServer()

	// Create and register the sentiment service
	sentimentService := service.NewSentimentService()
	pb.RegisterSentimentServiceServer(grpcServer, sentimentService)

	// Register reflection service for gRPC tools
	reflection.Register(grpcServer)

	log.Println("Server listening on :50051")
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
