<template>
  <v-container>
    <v-row class="text-center" justify="center">
      <v-col md="10" lg="4">
        <MintingCard v-on:warriorMinted="updateRecentMint"/>
      </v-col>
    </v-row>

    <v-row><v-col>
      <v-expand-transition>
        <div v-if="mostRecentMintId!==null">
          <WarriorCard :warriorID="mostRecentMintId" />
        </div>
      </v-expand-transition>
    </v-col></v-row>
  </v-container>
</template>

<script>
import WarriorCard from '../components/WarriorCard.vue';
import MintingCard from '../components/MintingCard.vue';
  export default {
    name: 'Minting',
    components:{
      MintingCard,
      WarriorCard
    },
    methods:{
      updateRecentMint(id){
        this.mostRecentMintId = id;
      }
    },
    data: () => ({
      mostRecentMintId: null
    }),
  }
</script>
