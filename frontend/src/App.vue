<template>
  <div id="app">
    <StockSentiment />
  </div>
</template>
  
<script>
import StockSentiment from './components/StockSentiment.vue';
import './assets/styles/app.css';

export default {
  name: 'App',
  components: {
    StockSentiment
  }
};
</script>