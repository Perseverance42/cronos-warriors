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
      <router-view></router-view>

      <vue-metamask 
        :userMessage="mmMsg" 
        @onComplete="onMMComplete"
      >
      </vue-metamask>
    </v-main>
  </v-app>
</template>

<script>
import VueMetamask from 'vue-metamask';
import BattleBoard from './artifacts/BattleBoard.json';

export default {
  name: 'App',

  components: {
    VueMetamask,
  //  WarriorCard
  },
  computed:{
    isAbleToFight(){
      return this.attackerId !== null && this.defenderId !== null;
    }
  },
  methods:{
    async startFight(){
      this.isWaitingForWallet = true;
      const web3 = new this.$Web3(this.wallet.web3.currentProvider);
      const contractInstance = new web3.eth.Contract(BattleBoard.abi, "0x8A791620dd6260079BF849Dc5567aDC3F2FdC318");
      contractInstance.methods.challangeWarrior(this.attackerId, this.defenderId).send({from: this.wallet.metaMaskAddress}).then(result=>{
        console.log("fight: ", result);
        this.isWaitingForWallet = false;
      }).catch(e=>{
        alert("Failed to fight!");
        console.log("fight failed", e);
        this.isWaitingForWallet = false;
      });
    },
    updateAttacker(id){
      this.attackerId = id;
    },
    updateDefender(id){
      this.defenderId = id;
    }
    ,async onMMComplete(data){
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
