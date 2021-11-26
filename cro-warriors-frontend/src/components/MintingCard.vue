<template>
    <v-card class="d-flex"> 
        <v-container>
            <v-row><v-col><v-card-title>Mint your own Cronos Warrior here</v-card-title></v-col></v-row>
            <v-card-text>
                <v-row><v-col>
                    <p>Minting a new warrior does cost 50TCRO + transaction fee</p>
                    <v-text-field v-model="inWarriorName" label="Warrior name: (can not be changed)"></v-text-field>
                    <v-btn block tile :disabled="!isWalletConnected" :loading="isWaitingOnWallet" color="green"  @click="mintWarrior()">Mint</v-btn>
                </v-col></v-row>
            </v-card-text>
        </v-container>
    </v-card>
</template>

<script>
import WarriorFactory from '../scripts/warrior-factory.js';
import {AlertBus} from '../scripts/alert-bus.js';

export default {
    name: 'MintingCard',
    components:{
    },
    methods:{
        async mintWarrior(){
            this.isWaitingOnWallet = true;
            WarriorFactory.mintWarrior(this.inWarriorName).then(result=>{
                console.log("minted warrior: ", result);
                AlertBus.$emit("alert",{ type:"info", message:"Your warrior was successfully minted!", timeout: 3000 });
                this.$emit("warriorMinted", result.events.WarriorMinted.returnValues.id);
                this.isWaitingOnWallet = false;
            }).catch(e=>{
                AlertBus.$emit("alert",{ type:"error", message:"Failed to mint Warrior.", details: e});
                console.log("mint error", e);
                this.isWaitingOnWallet = false;
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
        }
    },
    data: () => ({
        isWaitingOnWallet : false,
        inWarriorName: ""
    }),
  }
</script>
