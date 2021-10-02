<template>
  <v-container fluid>
    <v-row class="text-center" justify="center">
      <v-col cols="12">
        <v-text-field v-model="inWalletAddr" label="Wallet"></v-text-field>
      </v-col>
    </v-row>
    <v-row class="text-center" justify="center">
      <ArmyGrid :armyAddr="currentArmyAddr"></ArmyGrid>
    </v-row>
  </v-container>
</template>

<script>
import ArmyGrid from '../components/ArmyGrid.vue';
  export default {
    name: 'Army',
    components: {ArmyGrid},
    methods:{
      selectCurrentWalletArmy(){
        if(this.$wallet.$currentWalletAddr == null){
          setTimeout(this.selectCurrentWalletArmy, 1000);
          return;
        }
        this.inWalletAddr = this.$wallet.$currentWalletAddr;
      }
    },
    mounted(){
      if(this.currentArmyAddr==null){
        this.selectCurrentWalletArmy();
      }
    },
    watch:{
      "inWalletAddr": function(){
        if(this.inWalletAddr != null && this.inWalletAddr.length == 42 && this.inWalletAddr != this.currentArmyAddr){
          this.currentArmyAddr = this.inWalletAddr;
        }
      }
    },
    data: () => ({
      currentArmyAddr: null,
      inWalletAddr : null
    }),
  }
</script>
