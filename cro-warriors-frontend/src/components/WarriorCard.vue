<template>
    <v-card class="d-flex"> 
        <v-container>
            <v-row><v-col><v-card-title>{{warriorName}}</v-card-title></v-col></v-row>
            <v-card-text>
                <v-row>
                    <v-col><v-text-field label="Warrior ID" v-model="inWarriorId"></v-text-field><v-btn @click="loadWarrior()">Load</v-btn></v-col>
                </v-row>
                <v-row>
                    <v-col>Level: {{warriorLevel}}</v-col>
                    <v-col>Fights won: {{warriorStats[0]}}</v-col>
                    </v-row>
                    <v-row>
                        <v-col>Health: {{warriorHealth}}</v-col>
                        <v-col>Fights lost: {{warriorStats[1]}}</v-col>
                    </v-row>
                <v-row><v-col>Points available: {{warriorLevel-warriorStats[2]}}</v-col></v-row>                
                <v-row><v-col><v-btn :disabled="warriorSkills[0]==null" :loading="isWaitingOnWallet" @click="increaseSkill('attack')"> Attack: {{warriorSkills[0]}}</v-btn></v-col></v-row>
                <v-row><v-col><v-btn :disabled="warriorSkills[1]==null" :loading="isWaitingOnWallet" @click="increaseSkill('defense')">Defense: {{warriorSkills[1]}}</v-btn></v-col></v-row>
                <v-row><v-col><v-btn :disabled="warriorSkills[2]==null" :loading="isWaitingOnWallet" @click="increaseSkill('stamina')">Stamina: {{warriorSkills[2]}}</v-btn></v-col></v-row>
            </v-card-text>
        </v-container>
    </v-card>
</template>

<script>
import WarriorContract from '../artifacts/CronosWarriors.json';
  export default {
    name: 'WarriorCard',
    props:[
        "wallet"
    ],
    methods:{
        increaseSkill(skill){
            this.isWaitingOnWallet = true;
            const web3 = new this.$Web3(this.wallet.web3.currentProvider);
            const contractInstance = new web3.eth.Contract(WarriorContract.abi, "0x5FbDB2315678afecb367f032d93F642f64180aa3");
            switch(skill){
                case 'attack':
                    contractInstance.methods.increaseAttack(this.inWarriorId).send({from: this.wallet.metaMaskAddress}).then(result=>{
                        console.log("attack increase: ", result);
                        setTimeout(this.loadWarrior, 2000);
                        this.isWaitingOnWallet = false;
                    }).catch(e=>{
                        alert("Failed to increase attack!");
                        console.log("attack increase error", e);
                        this.isWaitingOnWallet = false;
                    });
                    break;
                case 'defense':
                    contractInstance.methods.increaseDefense(this.inWarriorId).send({from: this.wallet.metaMaskAddress}).then(result=>{
                        console.log("defense increase: ", result);
                        setTimeout(this.loadWarrior, 2000);
                        this.isWaitingOnWallet = false;
                    }).catch(e=>{
                        alert("Failed to increase defense!");
                        console.log("defense increase error", e);
                        this.isWaitingOnWallet = false;
                    });
                    break;
                case 'stamina':
                    contractInstance.methods.increaseStamina(this.inWarriorId).send({from: this.wallet.metaMaskAddress}).then(result=>{
                        console.log("stamina increase: ", result);
                        setTimeout(this.loadWarrior, 2000);
                        this.isWaitingOnWallet = false;
                    }).catch(e=>{
                        alert("Failed to increase stamina!");
                        console.log("stamina increase error", e);
                        this.isWaitingOnWallet = false;
                    });
                    break;
            }
        },
        async loadWarrior(){
            this.$emit('warriorUpdated', this.inWarriorId);
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

            contractInstance.methods.warriorStats(this.inWarriorId).call().then(result=>{
                if(result!== null){
                    console.log("Warrion result", result);
                    this.warriorStats = result;
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
    computed:{
        
    },
    data: () => ({
        inWarriorId: null,
        warriorName: "Unkown",
        warriorLevel: 0,
        warriorHealth: 0,
        warriorSkills: [null,null,null],
        warriorStats: [null,null,null],
        isWaitingOnWallet : false
    }),
  }
</script>
