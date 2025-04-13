package service

import (
	"context"
	"math/rand"
	"sync"

	pb "stock-sentiment/backend/proto/sentiment"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type SentimentService struct {
	pb.UnimplementedSentimentServiceServer
	history []*pb.SentimentResult
	mu      sync.Mutex
}

var sentiments = []pb.SentimentType{
	pb.SentimentType_POSITIVE,
	pb.SentimentType_NEUTRAL,
	pb.SentimentType_NEGATIVE,
}

var lenSentiments int = len(sentiments)

func NewSentimentService() *SentimentService {
	return &SentimentService{
		history: make([]*pb.SentimentResult, 0),
	}
}

// Analyze analyzes a stock symbol and returns a sentiment result
func (s *SentimentService) Analyze(ctx context.Context, req *pb.AnalyzeRequest) (*pb.SentimentResult, error) {
	// TODO: add more validation on symbol standards (consider global standards and country standards)

	if req.Symbol == "" {
		return nil, status.Error(codes.InvalidArgument, "stock symbol cannot be empty")
	}

	sentiment := sentiments[rand.Intn(lenSentiments)]

	result := &pb.SentimentResult{
		Symbol:     req.Symbol,
		Sentiment:  sentiment,
		AnalyzedAt: timestamppb.Now(),
	}

	s.mu.Lock()
	s.history = append(s.history, result)
	s.mu.Unlock()

	return result, nil
}

// GetHistory returns all previously analyzed sentiments
func (s *SentimentService) GetHistory(ctx context.Context, req *pb.GetHistoryRequest) (*pb.GetHistoryResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	return &pb.GetHistoryResponse{
		Results: s.history,
	}, nil
}
