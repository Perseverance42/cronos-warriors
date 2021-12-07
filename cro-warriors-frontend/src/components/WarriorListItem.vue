<template>
    <v-list-item class="py-2" @click="showMenu">
        <v-list-item-content  class="pa-0 ma-0"> 
            <v-card class="ma-0" tile :loading="isLoading">
                <div v-if="!isLoading">
                    
                    <v-list-item-title>
                        <v-avatar color="accent" class="mb-2"><WarriorPreviewRender class="pa-0" :warriorDNA="warriorDNA || 'cro'"/></v-avatar>
                        {{warriorName}} #{{warriorID}}</v-list-item-title>
                    <v-list-item-subtitle> Level: {{warriorLevel}} | Health: {{warriorHealth}}</v-list-item-subtitle>
                </div>
                <div v-else class="my-4">
                    #{{warriorID}} Pending...
                </div>
            </v-card>
        </v-list-item-content>
        <v-menu
            v-if="context && !isWaitingOnWallet && currentSelectedWarrior != warriorID"
            v-model="isMenuShowing"
            :position-x="menuX"
            :position-y="menuY"
            offset-y
            absolute
        >
        <v-list>
            <v-list-item>
                <v-list-item-title>
                    <v-btn
                            tile 
                            block
                            color="red"
                            dark
                            :disabled="!currentSelectedWarrior"
                            :loading="isWaitingOnWallet"
                            @click="challengeWarrior"
                            >
                            Challenge</v-btn>            
                </v-list-item-title>
            </v-list-item>
            <v-list-item>
                <v-list-item-title>
                    <v-btn
                            tile 
                            block
                            color="primary"
                            dark
                            >
                            Details</v-btn>   
                </v-list-item-title>
            </v-list-item>
        </v-list>
        </v-menu>
        <v-list-item-action v-if="hasSlot"><slot></slot></v-list-item-action>
  </v-list-item>
</template>

<script>
import WarriorPreviewRender from './WarriorPreviewRender.vue';
import BattleBoard from '../scripts/battle-board.js';
import { AlertBus } from '../scripts/alert-bus.js';

  export default {
    name: 'WarriorListItem',
    components:{WarriorPreviewRender},
    props: ['warriorID', 'context'],
    methods:{
        async bindCalls(){
            this.$bindCall('warriorName', {contract: await this.$wallet.loadContract("WarriorVisuals"), method: 'warriorName', args:[this.warriorID]});
            this.$bindCall('warriorDNA', {contract: await this.$wallet.loadContract("WarriorVisuals"), method: 'warriorDNA', args:[this.warriorID]});
            this.$bindCall('warriorLevel', {contract: await this.$wallet.loadContract("WarriorSkills"), method: 'warriorLevel', args:[this.warriorID]});
            this.$bindCall('warriorHealth', {contract: await this.$wallet.loadContract("WarriorSkills"), method: 'warriorHealth', args:[this.warriorID]});
        },
        showMenu(e){
            e.preventDefault();
            this.isMenuShowing = false;
            this.menuX = e.clientX
            this.menuY = e.clientY
            this.$nextTick(() => {
                this.isMenuShowing = true
            })
        },
        challengeWarrior(){
            if(this.currentSelectedWarrior == null){
                AlertBus.$emit("alert",{ type:"error", message:"Please select one of your warriors first!"} );
                return;
            }
            this.isWaitingOnWallet = true;
            BattleBoard.challengeWarrior(this.currentSelectedWarrior, this.warriorID).then(result=>{
                console.log("Warrior was challenged!", result);
                AlertBus.$emit("alert",{ type:"info", message:"Successfully challenged warrior.", timeout:3000 });
                this.isWaitingOnWallet = false;
            }).catch(e =>{
                AlertBus.$emit("alert",{ type:"error", message:"Failed to challenge warrior.", details: e } );
                this.isWaitingOnWallet = false;
            });
        }
    },
    watch:{
        "warriorID": function(){
            this.bindCalls();
        }
    },
    mounted(){
        if(this.warriorID!=null){
            this.bindCalls();
        }
    },
    computed: {
        isLoading(){
            return this.warriorName == null || this.warriorLevel == null || this.warriorHealth == null;
        },
        hasSlot(){
            return !!this.$slots[ 'default' ] || !!this.$scopedSlots[ 'default' ];
        },
        currentSelectedWarrior(){
            return this.$selectedWarrior;
        }
    },
    data: () => ({
        warriorName: null,
        warriorLevel: null,
        warriorHealth: null,
        warriorDNA: null,

        menuX:0,
        menuY:0,
        isMenuShowing: false,
        isWaitingOnWallet: false,
    }),
  }
</script>

