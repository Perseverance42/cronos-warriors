<template>
    <v-list>
        <v-list-item
                v-for="warrior of battleList"
                :key="warrior"
                class="pa-0 ma-0"
            >
                <v-list-item-content  class="pa-0 ma-0"> 
                    <WarriorListItem :warriorID="warrior">
                        <v-container>
                            <v-row><v-col>
                                <v-btn :loading="isWaitingForWallet" v-if="!offensive" class="mx-1" color="green" fab small @click="confirmBattleRequest(warrior)"><v-icon fab>mdi-check</v-icon></v-btn>
                                <v-btn :loading="isWaitingForWallet" class="mx-1" color="red" fab small @click="ofensive ? withdrawBattleRequest(warrior) : denyBattleRequest(warrior)"><v-icon >mdi-cancel</v-icon></v-btn>
                            </v-col></v-row>
                        </v-container>
                    </WarriorListItem>
                </v-list-item-content>
            </v-list-item>
    </v-list>
    
</template>

<script>
import CronosWarriors from '../scripts/cronos-warriors.js';
import WarriorListItem from '../components/WarriorListItem.vue';

  export default {
    name: 'BattleRequestList',
    components:{WarriorListItem},
    props: ['warriorID', 'offensive'],
    methods:{
        async loadDefensiveBattles(){
            if(this.$wallet == null || this.$wallet.web3 == null) return; 
            const contractInstance = await CronosWarriors.loadContract(this.$wallet.web3.currentProvider, CronosWarriors.contracts.BattleBoard);
            this.isWaitingForWallet = true;
            contractInstance.methods.defensiveRequestOf(this.warriorID, 0, 20).call().then(result=>{
                if(result){
                    console.log("Warrior defensive battles", result);
                    this.battleList = result;
                    this.$emit("requestsLoaded", result);
                    
                }
                this.isWaitingForWallet = false;
            }).catch(error=>{
                console.log("Failed to fetch defensive battles", error);
                this.isWaitingForWallet = false;
            });
        },
        async confirmBattleRequest(attacker){

            if(this.$wallet == null || this.$wallet.web3 == null) return; 
            const contractInstance = await CronosWarriors.loadContract(this.$wallet.web3.currentProvider, CronosWarriors.contracts.BattleBoard);
            
            this.isWaitingForWallet = true;
            contractInstance.methods.acceptBattleRequest(this.defenderID, attacker).send({from: this.$wallet.metaMaskAddress}).then(result=>{
                if(result){
                    console.log("Warrior battle accepted", result);
                    this.$emit("battleConfimed", result);
                }
                this.isWaitingForWallet = false;
            }).catch(error=>{
                console.log("Failed to accept battles", error);
                this.isWaitingForWallet = false;
            });            
        },
        async denyBattleRequest(attacker){
            if(this.$wallet == null || this.$wallet.web3 == null) return; 
            const contractInstance = await CronosWarriors.loadContract(this.$wallet.web3.currentProvider, CronosWarriors.contracts.BattleBoard);
            
            this.isWaitingForWallet = true;
            contractInstance.methods.denyBattleRequest(this.defenderID, attacker).send({from: this.$wallet.metaMaskAddress}).then(result=>{
                if(result){
                    console.log("Warrior battle denied", result);
                    this.$emit("battleDenied", result);
                }
                this.isWaitingForWallet = false;
            }).catch(error=>{
                console.log("Failed to deny battle", error);
                this.isWaitingForWallet = false;
            });            
        },
        async abortBattleRequest(defender){
            if(this.$wallet == null || this.$wallet.web3 == null) return; 
            const contractInstance = await CronosWarriors.loadContract(this.$wallet.web3.currentProvider, CronosWarriors.contracts.BattleBoard);
            
            this.isWaitingForWallet = true;
            contractInstance.methods.withdrawBattleRequest(this.attackerID, defender).send({from: this.$wallet.metaMaskAddress}).then(result=>{
                if(result){
                    console.log("Warrior battle withdrawn", result);
                    this.$emit("battleWithdrawn", result);
                }
                this.isWaitingForWallet = false;
            }).catch(error=>{
                console.log("Failed to withdraw battle", error);
                this.isWaitingForWallet = false;
            });   
        }
    },
    watch:{
        "warriorID": function(){
            if(this.offensive){
                this.attackerID = this.warriorID;
                this.loadDefensiveBattles();
            }else{
                this.defenderID = this.warriorID;
                this.loadDefensiveBattles();
            }
        }
    },
    mounted(){
        if(this.warriorID!=null){
            if(this.offensive){
                this.attackerID = this.warriorID;
                this.loadDefensiveBattles();
            }else{
                this.defenderID = this.warriorID;
                this.loadDefensiveBattles();
            }
        }
    },
    computed: {
        isLoading(){
            return this.battleList == null;
        }
    },
    data: () => ({
        attackerID: null,
        defenderID: null,
        battleList: null,
        selectedBattle: null,
        isWaitingForWallet: false
    }),
  }
</script>

