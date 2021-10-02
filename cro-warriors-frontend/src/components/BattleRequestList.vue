<template>
    <v-list>
        <v-list-item
                v-for="(id,i) in battleRequests"
                :key="i"
                class="pa-0 ma-0"
            >
                <v-list-item-content  class="pa-0 ma-0"> 
                    <WarriorListItem :warriorID="id">
                        <v-container>
                            <v-row><v-col>
                                <v-btn :loading="isWaitingForWallet" v-if="!offensive" class="mx-1" color="green" fab small @click="confirmBattleRequest(i)"><v-icon fab>mdi-check</v-icon></v-btn>
                                <v-btn :loading="isWaitingForWallet" class="mx-1" color="red" fab small @click="offensive ? abortBattleRequest(i) : denyBattleRequest(i)"><v-icon >mdi-cancel</v-icon></v-btn>
                            </v-col></v-row>
                        </v-container>
                    </WarriorListItem>
                </v-list-item-content>
            </v-list-item>
            <v-list-item v-if="battleRequests.length<1">
                <v-list-item-content>
                    <span>Nothing here yet...</span>
                </v-list-item-content>
            </v-list-item>
    </v-list>
    
</template>

<script>
import BattleBoard from '../scripts/battle-board.js';
import WarriorListItem from '../components/WarriorListItem.vue';
import { AlertBus } from '../scripts/alert-bus.js';

  export default {
    name: 'BattleRequestList',
    components:{WarriorListItem},
    props: ['warriorID', 'offensive'],
    methods:{
        async bindDefensiveCalls(){
            this.$bindCall('battleRequests', { contract: await this.$wallet.loadContract('BattleBoard'), method:"defensiveRequestOf", args:[ this.warriorID, 0, 20 ] });
        },
        async subscribeDefensiveRequests(){
            if(this.battleBoardSubscriber !== null ) return;
            const contract = await this.$wallet.loadContract('BattleBoard');
            contract.events.FightRequested({
                    filter:{
                        defender : this.warriorID
                    }
                }).on("data", (event) => {
                    console.log(event)
                });
        },
        confirmBattleRequest(index){
            this.isWaitingForWallet = true;
            BattleBoard.confirmBattleRequest(this.defenderID, this.battleRequests[index]).then(result=>{
                AlertBus.$emit("alert",{ type:"infor", message:"Battle finished successfully", timeout: 3000 });
                this.$emit("battleConfirmed", result);
                this.isWaitingForWallet = false;
            }).catch(e=>{
                AlertBus.$emit("alert",{ type:"error", message:"Failed to accept battle.", details: e });
                this.isWaitingForWallet = false;
            });
        },
        denyBattleRequest(index){
            this.isWaitingForWallet = true;
            BattleBoard.confirmBattleRequest(this.defenderID, this.battleRequests[index]).then(result=>{
                this.$emit("battleDenied", result);
                AlertBus.$emit("alert",{ type:"infor", message:"The battle was aborted.", timeout: 3000 });        
                this.isWaitingForWallet = false;
            }).catch(e=>{
                AlertBus.$emit("alert",{ type:"error", message:"Failed to deny battle.", details: e});
                this.isWaitingForWallet = false;
            });      
        },
        abortBattleRequest(index){
            this.isWaitingForWallet = true;
            BattleBoard.abortBattleRequest(this.attackerID, this.battleRequests[index]).then(result=>{
                console.log("Warrior battle withdrawn", result);
                AlertBus.$emit("alert",{ type:"infor", message:"Your warrior withdrew from battle.", timeout: 3000 });        
                this.$emit("battleWithdrawn", result);
                this.isWaitingForWallet = false;
            }).catch(e=>{
                AlertBus.$emit("alert",{ type:"error", message:"Failed to withdraw from battle.", details: e });
                console.log("Failed to withdraw battle", e);
                this.isWaitingForWallet = false;
            });   
        },
        opponentId(event){
            if(this.offensive){
                return event.returnValues.defender;
            }else{
                return event.returnValues.attacker;
            }
        },
    },
    watch:{
        "warriorID": function(){
            if(this.offensive){
                this.attackerID = this.warriorID;
              //  this.bindDefensiveCalls();
            }else{
                this.defenderID = this.warriorID;
                this.bindDefensiveCalls();
                this.subscribeDefensiveRequests();
            }
        }
    },
    mounted(){
        if(this.warriorID!=null){
            if(this.offensive){
                this.attackerID = this.warriorID;
                
            }else{
                this.defenderID = this.warriorID;
                this.bindDefensiveCalls();
                this.subscribeDefensiveRequests();
            }
        }
    },
    computed: {
        isLoading(){
            return this.battleRequests == null;
        }
    },
    data: () => ({
        battleBoardSubscriber: null,
        attackerID: null,
        defenderID: null,
        eventBattleRequests: [],
        battleRequests: [],
        selectedBattle: null,
        isWaitingForWallet: false
    }),
  }
</script>

