<template>
  <v-container fluid>
    <v-row class="text-center mx-2" align="center" justify="center">
      <v-col v-for="id in leaderboard" :key="id" class="ma-2 px-2 shrink">
        <WarriorCard :warriorID="id" />
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import WarriorCard from '../components/WarriorCard.vue';
  export default {
  components: { WarriorCard },
    name: 'Leaderboard',
    methods:{
      async bindContracts(){
        if(!this.$wallet || !this.$wallet.$currentWalletAddr){
          setTimeout(this.bindContracts, 1000);
          return
        }
        this.$bindCall('leaderboard', { contract: await this.$wallet.loadContract('Treasury'), method:"leaderboard", args:[ 0, 10 ] });
      }
    },
    mounted(){
      this.bindContracts();
    },
    data: () => ({
      leaderboard:[]
    }),
  }
</script>
