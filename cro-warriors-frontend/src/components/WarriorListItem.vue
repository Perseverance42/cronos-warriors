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
  </v-list-item>
</template>

<script>
import WarriorSkillsContract from '../artifacts/WarriorSkills.json';
import WarriorVisualsContract from '../artifacts/WarriorVisuals.json';

  export default {
    name: 'WarriorListItem',
    props: ['warriorID'],
    methods:{
        loadWarriorSkills(){
            if(this.$wallet == null || this.$wallet.web3 == null) return; 
            const web3 = new this.$Web3(this.$wallet.web3.currentProvider);
            const contractInstance = new web3.eth.Contract(WarriorSkillsContract.abi, "0x8A791620dd6260079BF849Dc5567aDC3F2FdC318");

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
        loadWarriorVisuals(){
            console.log("loading name");
            if(this.$wallet == null || this.$wallet.web3 == null) return; 
            const web3 = new this.$Web3(this.$wallet.web3.currentProvider);
            const contractInstance = new web3.eth.Contract(WarriorVisualsContract.abi, "0x0165878A594ca255338adfa4d48449f69242Eb8F");

            contractInstance.methods.warriorName(this.warriorID).call().then(result=>{
                if(result!== null){
                    console.log("Warrior result", result);
                    this.warriorName = result;
                }
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
        }
    },
    data: () => ({
        warriorName: null,
        warriorLevel: null,
        warriorHealth: null
    }),
  }
</script>

