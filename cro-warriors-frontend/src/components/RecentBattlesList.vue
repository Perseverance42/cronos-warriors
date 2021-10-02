<template>
    <v-container>
        <v-row>
            <v-col cols="1">
                <h4>Block #</h4>
            </v-col>
            <v-col>
                <h4>Winner</h4>
            </v-col>
            <v-col></v-col>
            <v-col>
                <h4>Loser</h4>
            </v-col>
        </v-row>
        <v-list>
            <v-list-item 
                v-for="(event, i) in battles" 
                :key="i"
                >
                <v-row>
                    <v-col cols="1">
                        #{{event.blockNumber}}
                    </v-col>
                    <v-col>
                        <WarriorListItem :warriorID="event.returnValues.winner"/>
                    </v-col>
                    <v-col>
                        <v-icon v-for="a1 in 3" :key="'a1-'+a1" class="px-2">mdi-arrow-left-bold</v-icon>
                        <span class="text-overline">{{event.returnValues.epSwapped/10000000000}}</span>
                        <v-icon v-for="a2 in 3" :key="'a2-'+a2" class="px-2">mdi-arrow-left-bold</v-icon>
                    </v-col>
                    <v-col>
                        <WarriorListItem :warriorID="event.returnValues.loser"/>
                    </v-col>
                </v-row>
            </v-list-item>
        </v-list>
    </v-container>
</template>

<script>

import WarriorListItem from './WarriorListItem.vue';
  export default {
    name: 'RecentBattlesList',
    props: ['historyLength'],
    components:{
        WarriorListItem
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
                    battleBoard.events.FightDone({}, (_,event=>{
                        this.$set(this.battles, this.battles.length, event);
                    }))
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
