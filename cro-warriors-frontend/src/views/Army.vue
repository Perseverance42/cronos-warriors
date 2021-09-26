<template>
  <v-container>
    <v-row class="text-center" justify="center">
      <v-col cols="6">
        <ArmyCard :armyAddr="$wallet.metaMaskAddress"/>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import ArmyCard from '../components/ArmyCard.vue';

  export default {
    name: 'Army',
    components: {ArmyCard},
    data: () => ({
    }),
  }
</script>
