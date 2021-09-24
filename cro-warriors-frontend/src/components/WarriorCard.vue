<template>
    <v-card>
        <v-text-field label="Warrior ID" v-model="inWarriorId"></v-text-field><v-btn @click="loadWarrior()">Load</v-btn>
        <v-card-title>{{warriorName}}</v-card-title>
        <v-card-text>
            Level: {{warriorLevel}}<br/>
            Health: {{warriorHealth}}<br/>
            Attack: {{warriorSkills[0]}}<br/>
            Defense: {{warriorSkills[1]}}<br/>
            Stamina: {{warriorSkills[2]}}
        </v-card-text>
    </v-card>
</template>

<script>
import WarriorContract from '../artifacts/CronosWarriors.json';
  export default {
    name: 'WarriorCard',
    props:[
        "wallet","warriorId"
    ],
    methods:{
        async loadWarrior(){
            const web3 = new this.$Web3(this.wallet.web3.currentProvider);
            const contractInstance = new web3.eth.Contract(WarriorContract.abi, "0x5FbDB2315678afecb367f032d93F642f64180aa3");
            contractInstance.methods.warriorName(this.inWarriorId).call().then(result=>{
                if(result !== null){
                    console.log("Warrion result", result);
                    this.warriorName = result;
                }
            });

            contractInstance.methods.warriorSkills(this.inWarriorId).call().then(result=>{
                if(result!== null){
                    console.log("Warrion result", result);
                    this.warriorSkills = result;
                }
            });

            contractInstance.methods.warriorHealth(this.inWarriorId).call().then(result=>{
                if(result){
                    console.log("Warrion result", result);
                    this.warriorHealth = result;
                }
            });

            contractInstance.methods.warriorLevel(this.inWarriorId).call().then(result=>{
                if(result){
                    console.log("Warrion result", result);
                    this.warriorLevel = result;
                }
            });
        }
    },
    mounted(){
        
    },
    data: () => ({
        inWarriorId: null,
        warriorName: "Unkown",
        warriorLevel: 0,
        warriorHealth: 0,
        warriorSkills: []
    }),
  }
</script>
