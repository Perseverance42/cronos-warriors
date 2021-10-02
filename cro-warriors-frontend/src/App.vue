<template>
  <v-app>
    
    <v-app-bar
      app
      color="primary"
      dark
    >      
          <div class="d-flex align-center">
            <v-btn class="mx-4" to="/">Home</v-btn>
            <v-btn class="mx-4" to="/leaderboard">Leaderboard</v-btn>
            <v-btn class="mx-4" to="/mint">Minting</v-btn>
            <v-btn class="mx-4" to="/army">Army</v-btn>
            <v-btn class="mx-4" to="/arena">Arena</v-btn>
          </div>

          <v-spacer></v-spacer>

          <v-btn
            href="https://github.com/Perseverance42/cronos-warriors"
            target="_blank"
            text
          >
            <span class="mr-2">GitHub</span>
            <v-icon>mdi-open-in-new</v-icon>
          </v-btn>          
    </v-app-bar>

    <v-main>
      <div class="d-flex flex-column">
      <router-view></router-view>
      <v-spacer></v-spacer>
      <alert-queue></alert-queue>
        
      <vue-metamask 
        :userMessage="mmMsg" 
        @onComplete="onMMComplete"
      >
      </vue-metamask>
      </div>
    </v-main>
    
  </v-app>
</template>

<script>
import VueMetamask from 'vue-metamask';
import AlertQueue from './components/AlertQueue.vue';

export default {
  name: 'App',

  components: {
    VueMetamask,
    AlertQueue
  },
  computed:{
  },
  methods:{
    async onMMComplete(data){
      this.$wallet.injectWallet(data.web3, data.metaMaskAddress);
    }
  },watch:{
    '$wallet' : function(){
      console.log("Wallet was updated!", this.$wallet);
    }
  }
  ,mounted(){
  },
  data: () => ({
    mmMsg: "Please enable this website to connect to meta mask.",
    isWaitingForWallet : false
  }),
};
</script>
