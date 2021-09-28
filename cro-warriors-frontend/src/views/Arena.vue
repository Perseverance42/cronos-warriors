<template>
  <v-container>
    <v-row class="text-center">
      <v-col cols="12">
        <BattleRequestList warriorID="2"/>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import BattleRequestList from '../components/BattleRequestList.vue';
  export default {
    name: 'Arena',
    components:{BattleRequestList},
    data: () => ({
    }),
  }
</script>
