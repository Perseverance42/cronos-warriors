<template>
    <v-card class="d-flex" :loading="!isWarriorLoaded"> 
        <v-container>
            <v-row><v-col><v-card-title>{{name}}</v-card-title></v-col></v-row>
            <v-card-text>
                <v-row><v-col>Experience: {{experience}}</v-col></v-row>
                <v-row>
                    <v-col>Level: {{level}}</v-col><v-col>Health: {{health}}</v-col>
                </v-row>
                    <v-row>
                        <v-col>Battles won: {{stats==null?'': stats[0]}}</v-col>
                        <v-col>Battles lost: {{stats==null?'': stats[1]}}</v-col>
                    </v-row>
                <v-row><v-col>Points available: {{pointsAvailable}}</v-col></v-row> 
                <v-row>
                    <v-col v-if="isCurrentWalletOwner">
                        <v-row>
                            <v-col>
                                <v-btn class="ma-2" :disabled="pointsAvailable<1" :loading="isWaitingOnWallet" @click="increaseSkill('attack')">Attack: {{skills==null?'':skills[1]}}</v-btn>
                                <v-btn class="ma-2" :disabled="pointsAvailable<1" :loading="isWaitingOnWallet" @click="increaseSkill('defense')">Defense: {{skills==null?'':skills[2]}}</v-btn>
                                <v-btn class="ma-2" :disabled="pointsAvailable<1" :loading="isWaitingOnWallet" @click="increaseSkill('stamina')">Stamina: {{skills==null?'':skills[3]}}</v-btn>
                            </v-col>
                        </v-row>
                    </v-col>
                    <v-col v-else>
                        <v-row>
                            <v-col><span>Attack: {{skills==null?'': skills[1]}}</span></v-col>
                            <v-col><span>Defense: {{skills==null?'': skills[2]}}</span></v-col>
                            <v-col><span>Stamina: {{skills==null?'':skills[3]}}</span></v-col>
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
import WarriorSkills from '../scripts/warrior-skills.js';
import BattleBoard from '../scripts/battle-board.js';
import ArmyList from '../components/ArmyList.vue';
import { AlertBus } from '../scripts/alert-bus.js';

  export default {
    name: 'WarriorCard',
    props: ["warriorID"],
    components:{ArmyList},
    methods:{
        async bindContracts(){
            //bind get calls
            this.$bindCall('owner', { contract: await this.$wallet.loadContract('CronosWarriors'), method:"ownerOf", args:[ this.warriorID ] });
            this.$bindCall('name', { contract: await this.$wallet.loadContract('WarriorVisuals'), method:"warriorName", args:[ this.warriorID ] });
            this.bindSkills();
            this.$bindCall('health', { contract: await this.$wallet.loadContract('WarriorSkills'), method:"warriorHealth", args:[ this.warriorID ] });
            this.$bindCall('level', { contract: await this.$wallet.loadContract('WarriorSkills'), method:"warriorLevel", args:[ this.warriorID ] });
            this.$bindCall('experience', { contract: await this.$wallet.loadContract('WarriorSkills'), method:"warriorExperience", args:[ this.warriorID ] });
            this.$bindCall('stats', { contract: await this.$wallet.loadContract('WarriorStats'), method:"warriorStats", args:[ this.warriorID ] });
        },
        //can change within this component so its seperately rebindable
        async bindSkills(){
            this.$bindCall('skills', { contract: await this.$wallet.loadContract('WarriorSkills'), method:"warriorSkills", args:[ this.warriorID ] });
        },
        increaseSkill(skill){
            this.isWaitingOnWallet = true;
            WarriorSkills.increaseSkill(this.warriorID, skill).then(result=>{
                console.log("", result);
                AlertBus.$emit("alert",{ type:"info", message:"Successfully increased skill.", timeout:3000 });
                setTimeout(this.bindSkills, 1000);
                this.isWaitingOnWallet = false;
            }).catch(e=>{
                AlertBus.$emit("alert",{ type:"error", message:"Failed to increase skill.", details: e });
                this.isWaitingOnWallet = false;
            });
        },
        challangeWarrior(attacker){
            this.isWaitingOnWallet = true;
            BattleBoard.challangeWarrior(attacker, this.warriorID).then(result=>{
                console.log("Warrior was challanged!", result);
                AlertBus.$emit("alert",{ type:"info", message:"Successfully challanged warrior.", timeout:3000 });
                this.isWaitingOnWallet = false;
            }).catch(e =>{
                AlertBus.$emit("alert",{ type:"error", message:"Failed to challange warrior.", details: e } );
                this.isWaitingOnWallet = false;
            });
        }
    },
    mounted(){
        this.bindContracts();
    },
    watch:{
        "warriorID": function(){
            this.bindContracts();
        }
    },
    computed:{
        isCurrentWalletOwner(){
            return this.owner != null && this.owner.toLowerCase() === this.currentWallet;
        },
        currentWallet(){
            return this.$wallet.$currentWalletAddr;
        },
        pointsAvailable(){
            return this.skills==null ? 0 : this.level - this.skills[0];
        },
        isWarriorLoaded(){
            return true && this.owner && this.name && this.skills && this.stats && this.level && this.health && this.experience;
        }
    },
    data: () => ({
        owner : null,
        name : null,
        skills: null,
        stats: null,
        level: null,
        health:null,
        experience: null,

        isWaitingOnWallet : false
    }),
  }
</script>
