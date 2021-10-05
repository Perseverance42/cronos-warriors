<template>
    <div>
        <v-virtual-scroll
        height="200"
        item-height="100"
        :items="battles.slice().reverse()"
        bench="2"
        >
        <template v-slot:default="{ item }">
            <v-list :key="item.id">
                <v-list-item>
                    <v-row align="center">
                        <v-col class="shrink">
                            <b>#{{item.blockNumber}}</b>
                        </v-col>
                        <v-col class="shrink">
                            <v-dialog 
                                transition="dialog-top-transition"
                                max-width="800">
                                <template v-slot:activator="{ on, attrs }">
                                    <v-sheet
                                        v-bind="attrs"
                                        v-on="on"
                                    >
                                    <qrcode-vue 
                                        :value="item.transactionHash" 
                                        size="60"></qrcode-vue>
                                    </v-sheet>
                                </template>
                                <template v-slot:default>
                                    <v-card tile class="pa-6">
                                        <center>
                                            <qrcode-vue 
                                                :value="'https://cronos.crypto.org/explorer/tx/'+item.transactionHash" 
                                                size="180"></qrcode-vue>
                                            Transaction Hash:<br/>
                                            <v-btn text :href="'https://cronos.crypto.org/explorer/tx/'+item.transactionHash" target="_blank">{{item.transactionHash}}</v-btn>
                                        </center>
                                    </v-card>
                                </template>
                            </v-dialog>
                        </v-col>
                        <v-col class="shrink">
                            <WarriorListItem :warriorID="item.returnValues.winner" context="true"/>
                        </v-col>
                        <v-col class="grow">
                            <v-progress-linear stream value="0" buffer-value="0" height="25">
                                <template v-slot:default="">
                                    <strong class="text-truncate">{{item.returnValues.epSwapped}}</strong>
                                </template>
                            </v-progress-linear>
                        </v-col>
                        <v-col class="shrink">
                            <WarriorListItem :warriorID="item.returnValues.loser" context="true"/>
                        </v-col>
                    </v-row>
                </v-list-item>
            </v-list>
        </template>
        </v-virtual-scroll>
    </div>
</template>

<script>

import WarriorListItem from './WarriorListItem.vue';
import QrcodeVue from 'qrcode.vue'

  export default {
    name: 'RecentBattlesList',
    props: ['historyLength'],
    components:{
        WarriorListItem,
        QrcodeVue
    },
    methods:{
        async subscribeToEvents(){
            if(this.$wallet.$currentWalletAddr == null){
                setTimeout(this.subscribeToEvents, 1000)
                return;
            }
            // would be so clean but gets duplicates
           //this.$bindEvents('battles', {contract: await this.$wallet.loadContract('CombatModule'), event: 'FightDone', options:{fromBlock:0}});
           const battleBoard = await this.$wallet.loadContract('CombatModule');

           this.$wallet.$web3.eth.getBlockNumber((_, number)=>{
               battleBoard.getPastEvents('FightDone', {
                    fromBlock: 0,
                    toBlock: number-1
                }, (_, events)=>{
                    this.battles = events;
                    //history fetched listen for new Events now
                    battleBoard.events.FightDone({}, (error, event)=>{
                        console.log("Event ", error, event)
                        this.$set(this.battles, this.battles.length, event);
                    })
                });
           });           
        }
    },
    watch:{
       
    },
    mounted(){
        this.subscribeToEvents();
    },
    computed:{

    },
    data: () => ({
        battles: [],
        historyLoaded: false,
    }),
  }
</script>
