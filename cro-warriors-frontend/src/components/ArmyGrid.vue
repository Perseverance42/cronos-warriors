<template>
    <v-row v-if="warriorIDs" class="mx-2">
        <v-col v-for="(id,i) in warriorIDs" :key="i" class="ma-2">
            <WarriorCard :warriorID="id"></WarriorCard>
        </v-col>
    </v-row>
</template>

<script>
import CronosWarriors from "../scripts/cronos-warriors.js";
import WarriorCard from "../components/WarriorCard.vue";
import { AlertBus } from "../scripts/alert-bus.js";
export default {
  name: "ArmyGrid",
  props: ["armyAddr"],
  components: {WarriorCard},
  methods: {
    loadArmy() {
      if (this.armyAddr == null) return;
      CronosWarriors.loadArmyByAddr(this.armyAddr)
        .then((result) => {
          this.warriorIDs = result;
        })
        .catch((e) => {
          AlertBus.$emit("alert", {
            type: "error",
            message: "Failed to load army!",
            timeout: 7000,
            details: e,
          });
        });
    },
  },
  watch: {
    armyAddr: function (oldVal, newVal) {
      if (oldVal != newVal) {
        this.loadArmy();
      }
    },
  },
  mounted() {
    if (this.armyAddr != null) this.loadArmy();
  },
  computed: {},
  data: () => ({
    warriorIDs: null,
  }),
};
</script>
