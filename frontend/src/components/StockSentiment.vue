<template>
  <div class="stock-sentiment">
    <h1>Stock Sentiment Analyzer</h1>
    
    <div class="connection-status" :class="connectionStatusClass">
      <span v-if="isConnected">Connected</span>
      <span v-else>
        Disconnected from server 
        <button @click="reconnect" class="reconnect-btn">Reconnect</button>
      </span>
    </div>
    
    <div class="input-section">
      <input 
        v-model="symbol" 
        placeholder="Enter stock symbol (e.g. AAPL)" 
        @keyup.enter="analyzeStock"
        :disabled="!isConnected"
      />
      <button 
        @click="analyzeStock" 
        :disabled="!symbol || isLoading || !isConnected"
      >
        {{ isLoading ? 'Analyzing...' : 'Analyze' }}
      </button>
    </div>
    
    <div v-if="error" class="error-message">
      {{ error }}
    </div>
    
    <div class="history-section">
      <h2>Sentiment History</h2>
      <div class="controls">
        <button @click="loadHistory" :disabled="isHistoryLoading || !isConnected" class="refresh-btn">
          {{ isHistoryLoading ? 'Loading...' : 'Refresh' }}
        </button>
      </div>
      <table v-if="history.length > 0">
        <thead>
          <tr>
            <th>Symbol</th>
            <th>Sentiment</th>
            <th>Analyzed At</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(result, index) in history" :key="index">
            <td>{{ result.symbol }}</td>
            <td>
              <span :class="getSentimentClass(result.sentiment)">
                {{ sentimentToString(result.sentiment) }}
              </span>
            </td>
            <td>{{ formatTimestamp(result.analyzedAt) }}</td>
          </tr>
        </tbody>
      </table>
      <div v-else-if="isHistoryLoading" class="loading-history">
        Loading history...
      </div>
      <p v-else>No sentiment analysis history yet.</p>
    </div>
  </div>
</template>

<script>
import sentimentService from '../services/sentimentService';
import '../assets/styles/stock-sentiment.css';

export default {
  name: 'StockSentiment',
  data() {
    return {
      symbol: '',
      history: [],
      error: null,
      isLoading: false,
      isHistoryLoading: false,
      isConnected: false,
      connectionTimer: null
    };
  },
  computed: {
    connectionStatusClass() {
      return this.isConnected ? 'connected' : 'disconnected';
    }
  },
  mounted() {
    this.checkConnection();
  },
  beforeUnmount() {
    if (this.connectionTimer) {
      clearTimeout(this.connectionTimer);
    }
  },
  methods: {
    checkConnection() {
      this.isHistoryLoading = true;
      
      sentimentService.getHistory()
        .then(history => {
          this.isConnected = true;
          this.error = null;
          this.history = history;
        })
        .catch(err => {
          console.error('Connection error:', err);
          this.isConnected = false;
          this.error = `Cannot connect to the server: ${err.message}`;
          
          // Retry connection after 5 seconds
          this.connectionTimer = setTimeout(() => {
            this.checkConnection();
          }, 5000);
        })
        .finally(() => {
          this.isHistoryLoading = false;
        });
    },
    
    reconnect() {
      this.error = null;
      this.checkConnection();
    },
    
    loadHistory() {
      if (!this.isConnected) return;
      
      this.isHistoryLoading = true;
      
      sentimentService.getHistory()
        .then(history => {
          this.isConnected = true;
          this.history = history;
        })
        .catch(err => {
          this.error = `Error loading history: ${err.message}`;
          this.isConnected = false;
        })
        .finally(() => {
          this.isHistoryLoading = false;
        });
    },
    
    analyzeStock() {
      if (!this.symbol || this.isLoading || !this.isConnected) return;
      
      this.error = null;
      this.isLoading = true;
      
      sentimentService.analyzeStock(this.symbol)
        .then(result => {
          this.isConnected = true;
          this.history.unshift(result);
          this.symbol = '';
        })
        .catch(err => {
          this.error = `Error analyzing stock: ${err.message}`;
          this.isConnected = false;
        })
        .finally(() => {
          this.isLoading = false;
        });
    },
    
    sentimentToString(sentiment) {
      return sentimentService.constructor.sentimentToString(sentiment);
    },
    
    getSentimentClass(sentiment) {
      return sentimentService.constructor.getSentimentClass(sentiment);
    },
    
    formatTimestamp(timestamp) {
      return sentimentService.constructor.formatTimestamp(timestamp);
    }
  }
};
</script>

<style>
/* Styles are imported from external CSS file */
</style>