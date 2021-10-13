<template>
  <v-container>
    <v-row class="text-center" justify="center">
      <v-col md="10" lg="6">
        <MintingCard v-on:warriorMinted="updateRecentMint"/>
      </v-col>
      <v-expand-transition>
        <v-col v-if="mostRecentMintId!==null">
            <div >
              <WarriorCard :warriorID="mostRecentMintId" />
            </div>
        </v-col>
      </v-expand-transition>
    </v-row>
    <v-row class="text-center" justify="center">
      <v-col md="10" lg="6">
        <BurningCard/>
      </v-col>
    </v-row>
    <v-row></v-row>
  </v-container>
</template>

<script>
import WarriorCard from '../components/WarriorCard.vue';
import MintingCard from '../components/MintingCard.vue';
import BurningCard from '../components/BurningCard.vue';
  export default {
    name: 'Minting',
    components:{
      MintingCard,
      BurningCard,
      WarriorCard
    },
    methods:{
      updateRecentMint(id){
        setTimeout(()=>{
          this.mostRecentMintId = id;
        }, 1000);
        
      }
    },
    data: () => ({
      mostRecentMintId: null
    }),
  }
</script>
