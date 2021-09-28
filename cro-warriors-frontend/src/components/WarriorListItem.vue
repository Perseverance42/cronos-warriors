<template>
    <v-list-item>
        <v-list-item-content  class="pa-0 ma-0"> 
            <v-card class="ma-0" tile :loading="isLoading">
                <div v-if="!isLoading" class="">
                    <v-list-item-title>{{warriorName}} #{{warriorID}}</v-list-item-title>
                    <v-list-item-subtitle> Level: {{warriorLevel}} | Health: {{warriorHealth}}</v-list-item-subtitle>
                    
                </div>
                <div v-else class="my-4">
                    #{{warriorID}} Pending...
                </div>
            </v-card>
        </v-list-item-content>
        <v-list-item-action v-if="hasSlot"><slot></slot></v-list-item-action>
  </v-list-item>
</template>

<script>
import CronosWarriors from '../scripts/cronos-warriors.js';

  export default {
    name: 'WarriorListItem',
    props: ['warriorID'],
    methods:{
        async loadWarriorSkills(){
            if(this.$wallet == null || this.$wallet.web3 == null) return; 
            const contractInstance = await CronosWarriors.loadContract(this.$wallet.web3.currentProvider, CronosWarriors.contracts.WarriorSkills);

            contractInstance.methods.warriorHealth(this.warriorID).call().then(result=>{
                if(result){
                    console.log("Warrior health", result);
                    this.warriorHealth = result;
                }
            });

            contractInstance.methods.warriorLevel(this.warriorID).call().then(result=>{
                if(result){
                    console.log("Warrior level", result);
                    this.warriorLevel = result;
                }
            });
        },
        async loadWarriorVisuals(){
            if(this.$wallet == null || this.$wallet.web3 == null) return; 
            const contractInstance = await CronosWarriors.loadContract(this.$wallet.web3.currentProvider, CronosWarriors.contracts.WarriorVisuals);

            contractInstance.methods.warriorName(this.warriorID).call().then(result=>{
                if(result){
                    console.log("Warrior result", result);
                    this.warriorName = result;
                }
            }).catch(error=>{
                console.log(error);
            });
        }
    },
    watch:{
        "warriorID": function(){
            this.loadWarriorSkills();
            this.loadWarriorVisuals();
        }
    },
    mounted(){
        if(this.warriorID!=null){
            this.loadWarriorSkills();
            this.loadWarriorVisuals();
        }
    },
    computed: {
        isLoading(){
            return this.warriorName == null || this.warriorLevel == null || this.warriorHealth == null;
        },
        hasSlot(){
            return !!this.$slots[ 'default' ] || !!this.$scopedSlots[ 'default' ];
        }
    },
    data: () => ({
        warriorName: null,
        warriorLevel: null,
        warriorHealth: null
    }),
  }
</script>

