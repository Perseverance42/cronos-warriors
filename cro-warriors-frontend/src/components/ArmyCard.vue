<template>
  <v-card>
    <v-card-title>Army of: {{armyAddr}}</v-card-title>
    <v-list>
        <v-list-item-group
        v-model="selectedWarrior"
        color="primary"
        >
            <v-list-item
                v-for="i in warriorIDs"
                :key="i"
                class="pa-0 ma-0"
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
import CronosWarriors from '../artifacts/CronosWarriors.json';
import WarriorListItem from './WarriorListItem.vue';
  export default {
    name: 'ArmyCard',
    props: ['armyAddr'],
    components:{WarriorListItem},
    methods:{
        async loadArmy(){
            if(this.$wallet == null || this.$wallet.web3 == null) return; 
            
            const web3 = new this.$Web3(this.$wallet.web3.currentProvider);
            const contractInstance = new web3.eth.Contract(CronosWarriors.abi, "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707");

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
        loadWarriorByOwnerIndex(address, index){
            if(this.$wallet == null || this.$wallet.web3 == null) return; 

            const web3 = new this.$Web3(this.$wallet.web3.currentProvider);
            const contractInstance = new web3.eth.Contract(CronosWarriors.abi, "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707");

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
        }
    },
    watch:{
        armyAddr: function(){
            this.loadArmy();
        }
    },
    mounted(){
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
