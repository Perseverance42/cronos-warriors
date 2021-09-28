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
                                <v-btn :loading="isWaitingForWallet" class="mx-1" color="red" fab small @click="offensive ? abortBattleRequest(warrior) : denyBattleRequest(warrior)"><v-icon >mdi-cancel</v-icon></v-btn>
                            </v-col></v-row>
                        </v-container>
                    </WarriorListItem>
                </v-list-item-content>
            </v-list-item>
            <v-list-item v-if="battleListSize<1">
                <v-list-item-content>
                    <span>Nothing here yet...</span>
                </v-list-item-content>
            </v-list-item>
    </v-list>
    
</template>

<script>
import BattleBoard from '../scripts/battle-board.js';
import WarriorListItem from '../components/WarriorListItem.vue';

  export default {
    name: 'BattleRequestList',
    components:{WarriorListItem},
    props: ['warriorID', 'offensive'],
    methods:{
        loadDefensiveBattles(){
            this.isWaitingForWallet = true;
            BattleBoard.loadDefensiveBattles(this.warriorID,0,20).then(result=>{
                this.battleList = result;
                this.battleListSize = result.length; // Vue doesnt react to updates without this!
                this.$emit("requestsLoaded", result);
                this.isWaitingForWallet = false;
            }).catch(e=>{
                alert("Failed to fetch defensive battles " + e);
                this.isWaitingForWallet = false;
            });
        },
        confirmBattleRequest(attacker){
            this.isWaitingForWallet = true;
            BattleBoard.confirmBattleRequest(this.defenderID, attacker).then(result=>{
                alert("Battle succeeded!");
                this.$emit("battleConfirmed", result);
                this.isWaitingForWallet = false;
                setTimeout(this.loadDefensiveBattles,2000);
            }).catch(e=>{
                alert("Failed to confirm battle " + e);
                this.isWaitingForWallet = false;
            });
        },
        denyBattleRequest(attacker){
            this.isWaitingForWallet = true;
            BattleBoard.confirmBattleRequest(this.defenderID, attacker).then(result=>{
                this.$emit("battleDenied", result);
                this.isWaitingForWallet = false;
                setTimeout(this.loadDefensiveBattles,2000);
            }).catch(e=>{
                alert("Failed to deny battle " + e);
                this.isWaitingForWallet = false;
            });      
        },
        abortBattleRequest(defender){
            this.isWaitingForWallet = true;
            BattleBoard.abortBattleRequest(this.attackerID, defender).then(result=>{
                console.log("Warrior battle withdrawn", result);
                this.$emit("battleWithdrawn", result);
                this.isWaitingForWallet = false;
            }).catch(error=>{
                alert("Failed to withdraw from battle!");
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
        battleListSize : 0,
        selectedBattle: null,
        isWaitingForWallet: false
    }),
  }
</script>

