<template>
  <v-navigation-drawer app permanent color="primary" >
    <template v-slot:prepend>
      <v-sheet color="accent">
        <WarriorPreviewItem :warriorID="$selectedWarrior" v-if="$selectedWarrior" />
        <v-menu close-on-click v-else>
          <template v-slot:activator="{ on, attrs }">
            <v-btn
              block
              tile
              color="accent"
              x-large 
              v-on="on"
              v-bind="attrs"
              class="text-overline"
            >Plese select a warrior</v-btn>
          </template>
          <v-card class="pa-3" tile>
            <v-card-title class="text-overline">Select a warrior</v-card-title>
            <v-divider/>
            <v-card-actions><ArmyList :armyAddr="currentWallet" @select="selectWarrior($event)"></ArmyList></v-card-actions>
          </v-card>
        </v-menu>
      </v-sheet>
    </template>
    <v-divider></v-divider>
    <v-list nav dense>
      <v-list-item @click="battleRequestMenu=!battleRequestMenu">
        <v-list-item-icon>
          <v-icon>mdi-human-queue</v-icon>
          
        </v-list-item-icon>
        <v-list-item-content>
          <v-list-item-title>
              Battle Requests
            <v-chip outlined class="mx-2" color="white"><v-icon>{{ battleRequestMenu ? 'mdi-arrow-up' : 'mdi-arrow-down'  }}</v-icon></v-chip>  
            </v-list-item-title>
        </v-list-item-content>
      </v-list-item>
      <v-slide-y-transition>
      <div v-if="battleRequestMenu">
        <v-list-item v-for="warriorID in playerWarriors" :key="warriorID">
          <WarriorBattleRequestsItem :warriorID="warriorID"/>
        </v-list-item>
      </div>
      </v-slide-y-transition>

      <v-list-item
        link
        v-for="item in navigation"
        :key="item.route"
        :to="item.route"
      >
        <v-list-item-icon>
          <v-icon>{{ item.icon }}</v-icon>
        </v-list-item-icon>
        <v-list-item-content>
          <v-list-item-title>{{ item.label }}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>
    </v-list>
    <v-spacer></v-spacer>
    <v-footer color="primary" bottom fixed>
        <v-btn
            href="https://github.com/Perseverance42/cronos-warriors"
            target="_blank"
            text
            block
            color="white"
          >
            <span class="mr-2">GitHub</span>
            <v-icon>mdi-open-in-new</v-icon>
          </v-btn>
    </v-footer>
  </v-navigation-drawer>
</template>

<script>
import WarriorPreviewItem from "./WarriorPreviewItem.vue";
import WarriorBattleRequestsItem from "./WarriorBattleRequestsItem.vue";
import ArmyList from './ArmyList.vue';
import { AlertBus } from '../scripts/alert-bus.js';
import CronosWarriors from '../scripts/cronos-warriors.js';

export default {
  name: "NavigationDrawer",
  props: [],
  components: { WarriorPreviewItem,WarriorBattleRequestsItem,ArmyList },
  methods: {
    loadArmy() {
      if(!this.$wallet || !this.$wallet.$currentWalletAddr){
        setTimeout(this.loadArmy, 1000);
        return;
      }

      CronosWarriors.loadArmyByAddr(this.$wallet.$currentWalletAddr)
        .then((result) => {
          this.playerWarriors = result;
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
    selectWarrior(id){
        this.$selectedWarrior = id;
    }
  },
  watch: {
  },
  mounted() {
    this.loadArmy()
  },
  computed: {
    currentWallet:function(){
      return this.$wallet ? this.$wallet.$currentWalletAddr : null;
    }
  },
  data: () => ({
    navigation: [
      { icon: "mdi-home", label: "Your Legacy", route: "/" },
      { icon: "mdi-seal", label: "Leaderboard", route: "/leaderboard" },
      { icon: "mdi-wallet", label: "Minting", route: "/mint" },
      { icon: "mdi-map", label: "Roadmap", route: "/roadmap" }
    ],
    
    battleRequestMenu: false,
    playerWarriors:[],
  }),
};
</script>
