<template>
    <v-list>
        <v-list-item-group
        v-model="selectedWarrior"
        color="primary"
        >
            <v-list-item
                v-for="(id,i) in warriorIDs"
                :key="i"
                class="pa-0 ma-0"
                @click="warriorSelected(id)"
            >
                <v-list-item-content  class="pa-0 ma-0"> 
                    <WarriorListItem :warriorID="id"></WarriorListItem>
                </v-list-item-content>
            </v-list-item>
        </v-list-item-group>     
    </v-list>
</template>

<script>
import WarriorListItem from './WarriorListItem.vue';
import CronosWarriors from '../scripts/cronos-warriors.js';
import {AlertBus} from '../scripts/alert-bus.js';

  export default {
    name: 'ArmyList',
    props: ['armyAddr'],
    components:{WarriorListItem},
    methods:{
        loadArmy(){
            if(this.armyAddr==null) return;
            CronosWarriors.loadArmyByAddr(this.armyAddr).then((result)=>{
                console.log(result, this)
                this.warriorIDs = result;
            }).catch(e=>{
                AlertBus.$emit("alert",{ type:"error", message:"Failed to load army!", timeout: 7000, details: e});        
            });
        },
        isWarriorLoading(index){
            return this.warriorIDs == null || index <= this.warriorIDs.length || this.warriorIDs[index] == null;
        },
        warriorSelected(warriorID){
            this.$emit("select", warriorID)
        }
    },
    watch:{
        armyAddr: function(oldVal, newVal){
            if(oldVal!=newVal){
                this.loadArmy();
            }
        }
    },
    mounted(){
        if(this.armyAddr!=null)
            this.loadArmy();
    },
    computed:{
    },
    data: () => ({
        armySize: 0,
        warriorIDs: null,
        isWaitingOnWallet: false,
        selectedWarrior: null,
    }),
  }
  
</script>
