<template>
    <v-card class="d-flex"> 
        <v-container>
            <v-row><v-col><v-card-title>{{warriorName}}</v-card-title></v-col></v-row>
            <v-card-text>
                <v-row>
                    <!--<v-col><v-text-field type="number" label="Warrior ID" v-model="inWarriorId"></v-text-field><v-btn @click="searchWarrior()">Load</v-btn></v-col>-->
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
import WarriorSkillsContract from '../artifacts/WarriorSkills.json';
import WarriorVisualsContract from '../artifacts/WarriorVisuals.json';

  export default {
    name: 'WarriorCard',
    props: ["warriorID"],
    methods:{
        increaseSkill(skill){
            this.isWaitingOnWallet = true;
            const web3 = new this.$Web3(this.$wallet.web3.currentProvider);
            const contractInstance = new web3.eth.Contract(WarriorSkillsContract.abi, "0x8A791620dd6260079BF849Dc5567aDC3F2FdC318");
            switch(skill){
                case 'attack':
                    contractInstance.methods.increaseAttack(this.warriorID).send({from: this.$wallet.metaMaskAddress}).then(result=>{
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
                    contractInstance.methods.increaseDefense(this.warriorID).send({from: this.$wallet.metaMaskAddress}).then(result=>{
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
                    contractInstance.methods.increaseStamina(this.warriorID).send({from: this.$wallet.metaMaskAddress}).then(result=>{
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
        async loadWarriorSkills(){
            const web3 = new this.$Web3(this.$wallet.web3.currentProvider);
            const contractInstance = new web3.eth.Contract(WarriorSkillsContract.abi, "0x8A791620dd6260079BF849Dc5567aDC3F2FdC318");

            contractInstance.methods.warriorSkills(this.warriorID).call().then(result=>{
                if(result!== null){
                    console.log("Warrior result", result);
                    this.warriorSkills = result;
                }
            });

            contractInstance.methods.warriorHealth(this.warriorID).call().then(result=>{
                if(result){
                    console.log("Warrior result", result);
                    this.warriorHealth = result;
                }
            });

            contractInstance.methods.warriorLevel(this.warriorID).call().then(result=>{
                if(result){
                    console.log("Warrior result", result);
                    this.warriorLevel = result;
                }
            });
        },
        async loadWarriorVisuals(){
            const web3 = new this.$Web3(this.$wallet.web3.currentProvider);
            const contractInstance = new web3.eth.Contract(WarriorVisualsContract.abi, "0x0165878A594ca255338adfa4d48449f69242Eb8F");

            contractInstance.methods.warriorName(this.warriorID).call().then(result=>{
                if(result!== null){
                    console.log("Warrior result", result);
                    this.warriorName = result;
                }
            });
        },
        async loadWarriorFully(){
            let skills = this.loadWarriorSkills();
            let visuals = this.loadWarriorVisuals();
            await skills;
            await visuals;
            this.$emit("warriorLoaded");
        }
    },
    mounted(){
        if(this.warriorID!=null){
            this.loadWarriorFully();
        }
    },
    watch:{
        "warriorID":() => {
            this.loadWarriorFully();
        }
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
