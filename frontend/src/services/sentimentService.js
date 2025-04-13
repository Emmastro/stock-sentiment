import { SentimentServiceClient } from '../proto/sentiment/sentiment_grpc_web_pb';
import { AnalyzeRequest, GetHistoryRequest } from '../proto/sentiment/sentiment_pb';

const API_URL = process.env.VUE_APP_API_URL || 'http://localhost:8080';

class SentimentService {
  constructor() {
    this.client = new SentimentServiceClient(API_URL);
  }

  /**
   * Get sentiment history
   * @returns {Promise} Promise that resolves with history results
   */
  getHistory() {
    return new Promise((resolve, reject) => {
      const request = new GetHistoryRequest();
      
      this.client.getHistory(request, {}, (err, response) => {
        if (err) {
          reject(err);
          return;
        }
        
        const history = response.getResultsList().map(result => ({
          symbol: result.getSymbol(),
          sentiment: result.getSentiment(),
          analyzedAt: result.getAnalyzedAt()
        }));
        
        resolve(history);
      });
    });
  }

  /**
   * Analyze stock sentiment
   * @param {string} symbol - Stock symbol to analyze
   * @returns {Promise} Promise that resolves with analysis result
   */
  analyzeStock(symbol) {
    return new Promise((resolve, reject) => {
      if (!symbol) {
        reject(new Error('Stock symbol is required'));
        return;
      }
      
      const request = new AnalyzeRequest();
      request.setSymbol(symbol.toUpperCase());
      
      this.client.analyze(request, {}, (err, response) => {
        if (err) {
          reject(err);
          return;
        }
        
        resolve({
          symbol: response.getSymbol(),
          sentiment: response.getSentiment(),
          analyzedAt: response.getAnalyzedAt()
        });
      });
    });
  }

  /**
   * Convert sentiment enum to readable string
   * @param {number} sentiment - Sentiment enum value
   * @returns {string} Human-readable sentiment
   */
  static sentimentToString(sentiment) {
    switch (sentiment) {
      case 1: return 'Positive';
      case 2: return 'Neutral';
      case 3: return 'Negative';
      default: return 'Unknown';
    }
  }

  /**
   * Get CSS class based on sentiment value
   * @param {number} sentiment - Sentiment enum value
   * @returns {string} CSS class name
   */
  static getSentimentClass(sentiment) {
    switch (sentiment) {
      case 1: return 'positive';
      case 2: return 'neutral';
      case 3: return 'negative';
      default: return '';
    }
  }

  /**
   * Format protobuf timestamp to human-readable format
   * @param {Timestamp} timestamp - Protobuf timestamp
   * @returns {string} Formatted date/time string
   */
  static formatTimestamp(timestamp) {
    if (!timestamp) return 'N/A';
    
    const date = new Date(timestamp.getSeconds() * 1000 + timestamp.getNanos() / 1000000);
    return date.toLocaleString();
  }
}

export default new SentimentService();