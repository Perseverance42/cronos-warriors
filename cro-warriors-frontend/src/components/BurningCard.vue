<template>
    <v-card class="d-flex" :loading="isLoadingWarriorDetails"> 
        <v-container>
            <v-row><v-col><v-card-title>Burn your warrior here</v-card-title></v-col></v-row>
            <v-card-text>
                <v-row><v-col>
                    <p class="text-left">Burning your warrior does permanently destroy it and releases the collected eperience as CRO.</p>

                    <ArmyList v-if="!selectedWarrior" :armyAddr="this.$wallet.$currentWalletAddr" @select="selectWarrior($event)" height="300"/>
                    <v-fade-transition v-else>
                    <span >
                        <v-row justify="center" class="mb-5">
                            <WarriorCard :warriorID="selectedWarrior"></WarriorCard>
                        </v-row>
                    <v-dialog
                        v-model="burnDialog"
                        width="500"
                    >
                        <template v-slot:activator="{ on, attrs }">
                            <v-btn v-on="on" v-bind="attrs" block tile :disabled="!selectedWarrior" :loading="isWaitingOnWallet" color="error" >Burn</v-btn>
                        </template>
                        <v-card class="pb-2" :loading="isLoadingWarriorDetails">
                            <v-sheet  color="error" class="mb-4" tile>
                                <v-card-title>Are you sure you want to do this?</v-card-title>    
                            </v-sheet>
                            <v-card-text>
                                Burning your warrior will irreversably destroy it. <br/>
                                Burning this warrior will release {{croReleasedOnBurn}} CRO to the owner wallet.
                            </v-card-text>
                            <v-card-actions>
                                <v-spacer></v-spacer>
                                <v-btn tile block :loading="isWaitingOnWallet" color="error" @click="burnWarrior()">BURN IT!</v-btn>
                                <v-spacer></v-spacer>
                            </v-card-actions>
                        </v-card>
                    </v-dialog>
                    <v-spacer></v-spacer>
                    <v-btn class="mt-2" tile block :loading="isWaitingOnWallet" color="primary" @click="selectedWarrior=null">Back to selection</v-btn>
                    <v-spacer></v-spacer>
                    </span>
                    </v-fade-transition>
                </v-col></v-row>
            </v-card-text>
        </v-container>
    </v-card>
</template>

<script>
import WarriorFactory from '../scripts/warrior-factory.js';
import ArmyList from './ArmyList.vue';
import {AlertBus} from '../scripts/alert-bus.js';
import WarriorCard from '../components/WarriorCard.vue'
import WarriorVisuals from '../scripts/warrior-visuals.js';
import Treasury from '../scripts/treasury.js';

export default {
    name: 'BurningCard',
    components:{
        ArmyList,
        WarriorCard
    },
    methods:{
        async burnWarrior(){
            console.log(this.currentWalletAddr);
            this.isWaitingOnWallet = true;
            WarriorFactory.burnWarrior(this.selectedWarrior, this.currentWalletAddr).then(result=>{
                console.log("minted warrior: ", result);
                AlertBus.$emit("alert",{ type:"info", message:"Your warrior was successfully burned!", timeout: 3000 });
                this.isWaitingOnWallet = false;
                if(this.burnDialog)
                    this.burnDialog =false;
            }).catch(e=>{
                AlertBus.$emit("alert",{ type:"error", message:"Failed to burn Warrior.", details: e});
                console.log("mint error", e);
                this.isWaitingOnWallet = false;
            });
        },
        selectWarrior(id){
            this.selectedWarrior = id;
            if(id)
                this.loadSelectedWarriorDetails();
        },
        async loadSelectedWarriorDetails(){
            this.loadingWarriorName = true;
            this.loadingWarriorEp = true;
            this.loadingWarriorDNA = true;

            WarriorVisuals.warriorName(this.selectedWarrior).then(result=>{
                this.selectedWarriorName = result;
                this.loadingWarriorName = false;
            }).catch(e=>{
                AlertBus.$emit("alert",{ type:"error", message:"Failed to load warrior name.", details: e} );
            });

            WarriorVisuals.warriorDNA(this.selectedWarrior).then(result=>{
                this.selectedWarriorDNA = result;
                this.loadingWarriorDNA = false;
            }).catch(e=>{
                AlertBus.$emit("alert",{ type:"error", message:"Failed to load warrior looks.", details: e} );
            })

            Treasury.experience(this.selectedWarrior).then(result=>{
                this.selectedWarriorExperience = result;
                this.loadingWarriorEp = false;
            }).catch(e=>{
                AlertBus.$emit("alert",{ type:"error", message:"Failed to load warrior experience.", details: e} );
            });
        }
    },
    mounted(){
    },
    watch:{
    },
    computed:{
        isWalletConnected(){
            return this.$wallet.$currentWalletAddr != null;
        },
        currentWalletAddr(){
            return this.$wallet.$currentWalletAddr;
        },
        isLoadingWarriorDetails(){
            return this.selectedWarrior && (this.loadingWarriorName || this.loadingWarriorEp);
        },
        croReleasedOnBurn(){
            return this.$wallet.weiToCroDecimal(this.selectedWarriorExperience);
        }
    },
    data: () => ({
        isWaitingOnWallet : false,
        selectedWarrior: null,
        selectedWarriorName: null,
        loadingWarriorName: false,
        selectedWarriorExperience: null,
        loadingWarriorEp: false,
        selectedWarriorDNA: null,
        loadingWarriorDNA: false,
        burnDialog: false,
    }),
  }
</script>
