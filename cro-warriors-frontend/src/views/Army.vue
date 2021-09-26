<template>
  <v-container>
    <v-row class="text-center" justify="center">
      <v-col cols="6">
        <WarriorCard warriorID="1"/>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import WarriorCard from '../components/WarriorCard.vue';

  export default {
    name: 'Army',
    components: {WarriorCard},
    data: () => ({
    }),
  }
</script>
