<template>
  <v-card>
    <v-list>
        <v-list-item-group
        v-model="selectedWarrior"
        color="primary"
        >
            <v-list-item
                v-for="i in warriorIDs"
                :key="i"
                class="pa-0 ma-0"
                @click="warriorSelected(warriorIDs[i-1])"
            >
                <v-list-item-content  class="pa-0 ma-0"> 
                    <WarriorListItem :warriorID="warriorIDs[i-1]"/>
                </v-list-item-content>
            </v-list-item>
        </v-list-item-group>     
    </v-list>
  </v-card>
</template>

<script>
import WarriorListItem from './WarriorListItem.vue';
import CronosWarriors from '../scripts/cronos-warriors.js';

  export default {
    name: 'ArmyCard',
    props: ['armyAddr'],
    components:{WarriorListItem},
    methods:{
        async loadArmy(){
            if(this.$wallet == null || this.$wallet.web3 == null) return; 
            
            let contractInstance = await CronosWarriors.loadContract(this.$wallet.web3.currentProvider, CronosWarriors.contracts.CronosWarriors);
            contractInstance.methods.balanceOf(this.armyAddr).call().then(result=>{
                console.log("balance of addr: ", result);
                let armySize = parseInt(result);
                this.warriorIDs = new Array();
                
                for(let i=0;i<armySize;i++){
                    this.loadWarriorByOwnerIndex(this.armyAddr, i);
                }
            }).catch(e=>{
                alert("Failed to load army!");
                console.log("balanceOf error", e)
            });
        },
        async loadWarriorByOwnerIndex(address, index){
            if(this.$wallet == null || this.$wallet.web3 == null) return; 

            const contractInstance = await CronosWarriors.loadContract(this.$wallet.web3.currentProvider, CronosWarriors.contracts.CronosWarriors);
            console.log(contractInstance);
            contractInstance.methods.tokenOfOwnerByIndex(address, index).call().then(result=>{
                console.log("warrior loaded: ", result);
                this.warriorIDs.push(result);
            }).catch(e=>{
                alert("Failed to fetch warrior id!");
                console.log("error", e);
            });
        },
        isWarriorLoading(index){
            return this.warriorIDs == null || index <= this.warriorIDs.length || this.warriorIDs[index] == null;
        },
        warriorSelected(warriorId){
            this.$emit('select', warriorId);
        }
    },
    watch:{
        armyAddr: function(oldVal, newVal){
            if(oldVal!=newVal){
                this.loadArmy();
            }
        },
        selectedWarrior: function(){
            
        }
    },
    mounted(){
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
