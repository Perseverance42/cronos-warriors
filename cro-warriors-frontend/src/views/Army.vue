<template>
  <v-container>
    <v-row class="text-center" justify="center">
      <v-col cols="8">
        <v-text-field v-model="inWalletAddr" label="Wallet"></v-text-field>
      </v-col>
    </v-row>
    <v-row class="text-center" justify="center">
      <v-col cols="6">
        <v-sheet>
          <ArmyList :armyAddr="currentArmyAddr" @select="selectWarriorDetailed($event)"/>
        </v-sheet>
      </v-col>
      <v-expand-transition>
        <v-col v-if="warriorDetailed!=null">
          <WarriorCard :warriorID="warriorDetailed"/>        
        </v-col>
      </v-expand-transition>
    </v-row>
  </v-container>
</template>

<script>
import ArmyList from '../components/ArmyList.vue';
import WarriorCard from '../components/WarriorCard.vue';

  export default {
    name: 'Army',
    components: {ArmyList,WarriorCard},
    methods:{
      selectWarriorDetailed(event){
        this.warriorDetailed = event;
        this.$emit("select", event);
      },
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
      warriorDetailed: null,
      currentArmyAddr: null,
      inWalletAddr : null
    }),
  }
</script>
