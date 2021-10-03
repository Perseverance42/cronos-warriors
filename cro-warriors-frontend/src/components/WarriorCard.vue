<template>
    <v-card class="d-flex" :loading="!isWarriorLoaded" outlined flat max-width="500" width="400"> 
        <v-container>
            <v-row><v-col><v-card-title>{{name}}</v-card-title></v-col></v-row>
            <v-card-text>
                <v-row class="pb-1" v-if="experience!=null">
                    <v-tooltip bottom>
                        <template v-slot:activator="{ on, attrs }">
                            <v-progress-linear
                                v-on="on"
                                v-bind="attrs"
                                height="25"
                                color="green lighten-2"
                                :value="levelUpProgress"
                            >
                                <template v-slot:default>
                                    <strong>Level {{ Math.ceil(computedLevel || 0) }}</strong>
                                </template>
                            </v-progress-linear>
                        </template>
                        <span>
                            <table>
                                <tr><th>EP currently:</th><td class="text-right">{{experience}}</td></tr>
                                <tr><th>EP required:</th><td class="text-right">{{epNeededForNextLevel}}</td></tr>
                            </table>
                        </span>
                    </v-tooltip>
                </v-row>
                <v-row v-if="experience && skills">
                    <v-progress-linear
                        height="25"
                        color="red darken-2"
                        value="100"
                    >
                        <template v-slot:default>
                            <strong>HP {{ Math.ceil(computedHealth || 0) }}</strong>
                        </template>
                    </v-progress-linear>
                </v-row>
                <v-row>
                    <v-col>
                        <v-avatar size=250 color="accent" tile>
                            <Identicon :value="dna || 'cro'" class="pa-2"/>
                        </v-avatar>
                    </v-col>
                </v-row>
                <v-row class="text-overline">
                    <v-col justify="center" align="center"> 
                        <table>
                            <tr><th>Attack: </th><td>{{skills==null?'': skills[1]}}</td></tr>
                            <tr><th>Defense: </th><td>{{skills==null?'': skills[2]}}</td></tr>
                            <tr><th>Stamina: </th><td>{{skills==null?'': skills[3]}}</td></tr>
                        </table>
                    </v-col>
                    <v-col justify="center" align="center">
                        <table>
                            <tr><th>Battles won: </th><td>{{stats==null?'': stats[0]}}</td></tr>
                            <tr><th>Battles lost: </th><td>{{stats==null?'': stats[1]}}</td></tr>
                        </table>
                    </v-col>
                </v-row>
                <v-row v-if="isCurrentWalletOwner">
                    <v-col>
                        <v-dialog
                        max-width="600"
                        v-if="pointsAvailable"
                        >
                        <template v-slot:activator="{ on, attrs }">
                            <v-btn 
                                text 
                                v-bind="attrs"
                                v-on="on"
                            >
                            Points available: {{pointsAvailable}}</v-btn>
                        </template>
                        <template v-slot:default>
                            <v-card>
                                <v-toolbar color="primary" dense>
                                    <span class="text-overline">Select which Skill you want to increase.</span>
                                </v-toolbar>
                                <v-container fluid>
                                    <v-row justify="center">
                                        <v-col><v-btn block color="primary" @click="increaseSkill('stamina')" :loading="isWaitingOnWallet">Stamina</v-btn></v-col>
                                        <v-col><v-btn block color="accent"  @click="increaseSkill('attack')" :loading="isWaitingOnWallet">Attack</v-btn></v-col>
                                        <v-col><v-btn block color="primary" @click="increaseSkill('defense')" :loading="isWaitingOnWallet">Defense</v-btn></v-col>
                                    </v-row>
                                </v-container>
                            </v-card>
                        </template>
                        </v-dialog>
                        <span v-else class="text-overline">
                            <v-btn text disabled >Points available: 0</v-btn>
                        </span>
                    </v-col>
                </v-row>
                <v-row>
                    <v-col>
                        <v-btn tile block color="primary">Select</v-btn>
                    </v-col>    
                </v-row>            
                <v-row><v-col>
                    <v-menu
                        close-on-click
                        >
                        <template v-slot:activator="{ on, attrs }">
                            <v-btn
                            tile 
                            block
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
import Identicon from '../components/Identicon.vue';
import { AlertBus } from '../scripts/alert-bus.js';
import Compute from '../scripts/compute'

  export default {
    name: 'WarriorCard',
    props: ["warriorID"],
    components:{ArmyList, Identicon},
    methods:{
        async bindContracts(){
            //bind get calls
            this.$bindCall('owner', { contract: await this.$wallet.loadContract('CronosWarriors'), method:"ownerOf", args:[ this.warriorID ] });
            this.$bindCall('name', { contract: await this.$wallet.loadContract('WarriorVisuals'), method:"warriorName", args:[ this.warriorID ] });
            this.$bindCall('dna', { contract: await this.$wallet.loadContract('WarriorVisuals'), method:"warriorDNA", args:[ this.warriorID ] });
            this.bindSkills();
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
            return this.skills==null ? 0 : this.computedLevel.toNumber() - this.skills[0];
        },
        isWarriorLoaded(){
            return true && this.owner && this.name && this.skills && this.stats && this.experience && this.dna;
        },
        computedLevel(){
            return Compute.warriorLevel(this.experience); //can be huge so better display as string
        },
        computedHealth(){
            return Compute.warriorHealth(this.experience, this.skills[3]).toString();
        },
        epNeededForNextLevel(){
            return Compute.epForNextLevel(this.experience).toString();
        },
        levelUpProgress(){
            return Compute.levelUpProgress(this.experience).toNumber(); //always in between 100-0 so toNumber is fine
        }
    },
    data: () => ({
        owner : null,
        name : null,
        skills: null,
        stats: null,
        experience: null,
        dna : null,

        isWaitingOnWallet : false
    }),
  }
</script>
