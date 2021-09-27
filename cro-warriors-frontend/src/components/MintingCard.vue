<template>
    <v-card class="d-flex"> 
        <v-container>
            <v-row><v-col><v-card-title>Mint your own Cronos Warrior here</v-card-title></v-col></v-row>
            <v-card-text>
                <v-row><v-col>
                    <p>Minting a new warrior does cost 1CRO + transaction fee</p>
                    <v-text-field v-model="inWarriorName" label="Warrior name:"></v-text-field>
                    <v-btn block tile :disabled="!isWalletConnected" :loading="isWaitingOnWallet" color="green"  @click="mintWarrior()">Mint</v-btn>
                </v-col></v-row>
            </v-card-text>
        </v-container>
    </v-card>
</template>

<script>

import CronosWarriors from '../scripts/cronos-warriors.js';
  export default {
    name: 'MintingCard',
    components:{
    },
    methods:{
        async mintWarrior(){
            this.isWaitingOnWallet = true;
            const contractInstance = await CronosWarriors.loadContract(this.$wallet.web3.currentProvider, CronosWarriors.contracts.WarriorFactory);

            contractInstance.methods.mint(this.inWarriorName).send({from: this.$wallet.metaMaskAddress, value: "1000000000000000000"}).then(result=>{
                console.log("minted warrior: ", result);
                this.$emit("warriorMinted", result.events.WarriorMinted.returnValues.id);
                this.isWaitingOnWallet = false;
            }).catch(e=>{
                alert("Failed to mint warrior!");
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
            return this.$wallet != null;
        }
    },
    data: () => ({
        isWaitingOnWallet : false,
        inWarriorName: ""
    }),
  }
</script>
