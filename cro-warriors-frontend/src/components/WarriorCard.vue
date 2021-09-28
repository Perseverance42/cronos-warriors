<template>
    <v-card class="d-flex" :loading="isLoadingWarrior"> 
        <v-container>
            <v-row><v-col><v-card-title>{{currentWarrior.name}}</v-card-title></v-col></v-row>
            <v-card-text>
                <v-row>
                    <!--<v-col><v-text-field type="number" label="Warrior ID" v-model="inWarriorId"></v-text-field><v-btn @click="searchWarrior()">Load</v-btn></v-col>-->
                </v-row>
                <v-row><v-col>Experience: {{currentWarrior.experience}}</v-col></v-row>
                <v-row>
                    <v-col>Level: {{currentWarrior.level}}</v-col>
                    </v-row>
                    <v-row>
                        <v-col>Health: {{currentWarrior.health}}</v-col>
                       
                    </v-row>
                <v-row><v-col>Points available: {{pointsAvailable}}</v-col></v-row> 
                <v-row>
                    <v-col v-if="isCurrentWalletOwner">
                        <v-row>
                            <v-col>
                                <v-btn class="ma-2" :disabled="currentWarrior.skills==null" :loading="isWaitingOnWallet" @click="increaseSkill('attack')">Attack: {{currentWarrior.skills[0]}}</v-btn>
                                <v-btn class="ma-2" :disabled="currentWarrior.skills==null" :loading="isWaitingOnWallet" @click="increaseSkill('defense')">Defense: {{currentWarrior.skills[1]}}</v-btn>
                                <v-btn class="ma-2" :disabled="currentWarrior.skills==null" :loading="isWaitingOnWallet" @click="increaseSkill('stamina')">Stamina: {{currentWarrior.skills[2]}}</v-btn>
                            </v-col>
                        </v-row>
                    </v-col>
                    <v-col v-else>
                        <v-row>
                            <v-col><span>Attack: {{currentWarrior.skills[0]}}</span></v-col>
                            <v-col><span>Defense: {{currentWarrior.skills[1]}}</span></v-col>
                            <v-col><span>Stamina: {{currentWarrior.skills[2]}}</span></v-col>
                        </v-row>
                    </v-col>
                </v-row>           
                <!--TODO add v-if="!isCurrentWalletOwner" -->
                <v-row><v-col>
                    <v-menu
                        close-on-click
                        >
                        <template v-slot:activator="{ on, attrs }">
                            <v-btn
                            color="red"
                            dark
                            v-bind="attrs"
                            v-on="on"
                            :loading="isWaitingOnWallet"
                            >
                            Challange</v-btn>
                        </template>
                        <v-card>
                            <v-card-title class="text-overline">Select Warrior to attack with</v-card-title>
                            <v-card-action><ArmyList :armyAddr="currentWallet" @select="challangeWarrior($event)"></ArmyList></v-card-action>
                        </v-card>
                    </v-menu>
                </v-col></v-row>
            </v-card-text>
        </v-container>
    </v-card>
    
</template>

<script>
import CronosWarriors from '../scripts/cronos-warriors.js';
import WarriorSkills from '../scripts/warrior-skills.js';
import BattleBoard from '../scripts/battle-board.js';
import Wallet from '../scripts/wallet.js';
import ArmyList from '../components/ArmyList.vue';

  export default {
    name: 'WarriorCard',
    props: ["warriorID"],
    components:{ArmyList},
    methods:{
        increaseSkill(skill){
            this.isWaitingOnWallet = true;
            WarriorSkills.increaseSkill(this.warriorID, skill).then(result=>{
                console.log("successfully increased skill!", result);
            }).catch(e=>{
                alert("Failed to increase stat", e);
            });
        },
        loadWarriorFully(){
            this.isLoadingWarrior = true;
            CronosWarriors.loadWarriorComplete( this.warriorID ).then(warrior=>{
                this.currentWarrior = warrior;
                this.$emit("warriorLoaded");
                this.isLoadingWarrior = false;
            }).catch(e=>{
                alert("Failed to load warrior " + this.warriorID + ": " + e);
                this.isLoadingWarrior = false;
            });
        },
        challangeWarrior(attacker){
            BattleBoard.challangeWarrior(attacker, this.warriorID).then(result=>{
                console.log("Warrior was challanged!", result);
                setTimeout(this.loadWarriorFully, 1000);
            }).catch(e =>{
                alert("Failed to challange warrior! " + e);
            });
        }
    },
    mounted(){
        if(this.warriorID!=null){
            this.loadWarriorFully();
        }
    },
    watch:{
        "warriorID": function(){
            this.loadWarriorFully();
        }
    },
    computed:{
        isCurrentWalletOwner(){
            return this.currentWarrior != null && this.currentWarrior.owner !=null && this.currentWarrior.owner.toLowerCase() === Wallet.$currentWalletAddr;
        },
        currentWallet(){
            return Wallet.$currentWalletAddr;
        },
        pointsAvailable(){
            return (this.currentWarrior.level || 0) - (this.currentWarrior.skills!= null && this.currentWarrior.skills[0] || 0)
        }
    },
    data: () => ({
        inWarriorId: null,
        currentWarrior: {
            owner:null,
            name :null,
            level:null,
            health:null,
            skills:null,
            experience:null,
        },
        isLoadingWarrior: false,
        isWaitingOnWallet : false
    }),
  }
</script>
