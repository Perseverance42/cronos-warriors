<template>
  <v-container fluid>
      <v-row class="text-center" v-for="(id,i) in warriorIDs" :key="i" cols="10">
        <v-row><v-col>
          <v-card-title>Open battle requests for {{warriorNames[i]==null ? 'Loading...' : warriorNames[i]}}</v-card-title>      
        </v-col></v-row>
        
        <v-col cols="12">
          <BattleRequestList :warriorID="id"/>
        </v-col>
      </v-row>
    </v-container>
</template>

<script>

import BattleRequestList from '../components/BattleRequestList.vue';
import Wallet from '../scripts/wallet.js';
import CronosWarriors from '../scripts/cronos-warriors.js';
import WarriorVisuals from '../scripts/warrior-visuals.js';
import {AlertBus} from '../scripts/alert-bus.js';

  export default {
    name: 'Arena',
    components:{BattleRequestList},
    methods:{
      loadArmyIDs(){
        if(Wallet.$currentWalletAddr == null){
          setTimeout(this.loadArmyIDs,100);
          return;
        }
        CronosWarriors.loadArmyByAddr(Wallet.$currentWalletAddr).then(warriors=>{
          this.warriorIDs = warriors;
          this.warriorNames = new Array(warriors.length);
          for(let i=0;i<warriors.length;i++){
            WarriorVisuals.warriorName(warriors[i]).then(name=>{
              this.$set(this.warriorNames,i,name);
            }).catch(e=>{
              console.error("Failed to fetch name", e);
              this.$set(this.warriorNames,i,'Unkown');
            });
          }
        }).catch(e=>{
          AlertBus.$emit("alert",{ type:"error", message:"Failed to load army! Try refreshing the Page.", timeout: 20000, details: JSON.stringify(e) });        
        });
      }
    },
    mounted(){
      this.loadArmyIDs();
    },
    data: () => ({
      warriorIDs:[],
      warriorNames:[]
    }),
  }
</script>
