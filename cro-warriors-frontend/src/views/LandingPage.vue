<template>
  <v-container fluid>
    <v-row class="text-center" justify="center">
      <v-col cols="12">
        <RecentBattlesList/>
        
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import RecentBattlesList from '../components/RecentBattlesList.vue';

  export default {
    name: 'LandingPage',
    components: {RecentBattlesList},
    data: () => ({
    }),
  }
</script>
