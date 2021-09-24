<template>
  <v-app>
    <v-app-bar
      app
      color="primary"
      dark
    >
      <div class="d-flex align-center">
        <v-img
          alt="Vuetify Logo"
          class="shrink mr-2"
          contain
          src="https://cdn.vuetifyjs.com/images/logos/vuetify-logo-dark.png"
          transition="scale-transition"
          width="40"
        />

        <v-img
          alt="Vuetify Name"
          class="shrink mt-1 hidden-sm-and-down"
          contain
          min-width="100"
          src="https://cdn.vuetifyjs.com/images/logos/vuetify-name-dark.png"
          width="100"
        />
      </div>

      <v-spacer></v-spacer>

      <v-btn
        href="https://github.com/vuetifyjs/vuetify/releases/latest"
        target="_blank"
        text
      >
        <span class="mr-2">Latest Release</span>
        <v-icon>mdi-open-in-new</v-icon>
      </v-btn>
    </v-app-bar>

    <v-main>
      <v-card :loading="this.wallet == null" min-height="100">
        <div v-if="this.wallet">
          <h1>Your wallet address: {{this.wallet.metaMaskAddress}}</h1>
        </div>
      </v-card>
      
      <vue-metamask 
            :userMessage="msg" 
            @onComplete="onComplete"
        >
      </vue-metamask>
      <v-container fluid>
        <v-row justify="center">
          <v-col cols="4">
            <v-btn color="error" block :disabled="!isAbleToFight" :loading="isWaitingForWallet" @click="startFight()">Fight</v-btn>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="6">
            <WarriorCard :wallet="this.wallet" v-on:warriorUpdated="updateAttacker"/>
          </v-col>
          <v-col>
            <WarriorCard :wallet="this.wallet" v-on:warriorUpdated="updateDefender"/>
          </v-col>
        </v-row>
        
      </v-container>
    </v-main>
  </v-app>
</template>

<script>
import VueMetamask from 'vue-metamask';
import WarriorCard from './components/WarriorCard.vue';
import WarriorContract from './artifacts/CronosWarriors.json';

export default {
  name: 'App',

  components: {
    VueMetamask,
    WarriorCard
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
      const contractInstance = new web3.eth.Contract(WarriorContract.abi, "0x5FbDB2315678afecb367f032d93F642f64180aa3");
      contractInstance.methods.fight(this.attackerId, this.defenderId).send({from: this.wallet.metaMaskAddress}).then(result=>{
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
    ,onComplete(data){
      this.wallet = data;     
    }
  },watch:{
    'wallet' : function(){
      console.log("Wallet was updated!", this.wallet);
    }
  }
  ,mounted(){
    
  },
  data: () => ({
    msg: "Please enable this website to connect to meta mask.",
    wallet: null,
    attackerId: null,
    defenderId: null,
    isWaitingForWallet : false
  }),
};
</script>
