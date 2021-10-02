<template>
  <v-app>
    <NavigationDrawer/>
    <v-main>
      <div class="d-flex flex-column">
      <RecentBattlesList/>  
      <v-divider></v-divider>
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
import NavigationDrawer from './components/NavigationDrawer.vue';
import RecentBattlesList from './components/RecentBattlesList.vue';

export default {
  name: 'App',

  components: {
    VueMetamask,
    AlertQueue,
    NavigationDrawer,
    RecentBattlesList
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
    isWaitingForWallet : false,
  }),
};
</script>
