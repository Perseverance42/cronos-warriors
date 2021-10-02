<template>
  <v-navigation-drawer app permanent color="primary" >
    <template v-slot:prepend>
      <v-sheet color="accent">
        <WarriorPreviewItem warriorID="1" />
      </v-sheet>
    </template>
    <v-divider></v-divider>
    <v-list nav dense>
      <v-list-item>
        <v-list-item-icon>
          <v-icon>mdi-human-queue</v-icon>
          
        </v-list-item-icon>
        <v-list-item-content>
          
          <v-list-item-title>
              Battle Requests
            <v-chip outlined class="mx-2" color="white"><v-avatar>10+</v-avatar></v-chip>  
            </v-list-item-title>
        </v-list-item-content>
      </v-list-item>

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
export default {
  name: "NavigationDrawer",
  props: [],
  components: { WarriorPreviewItem },
  methods: {},
  watch: {},
  mounted() {},
  computed: {},
  data: () => ({
    navigation: [
      { icon: "mdi-home", label: "Your Legacy", route: "/" },
      { icon: "mdi-seal", label: "Leaderboard", route: "/leaderboard" },
      { icon: "mdi-stadium", label: "Arena", route: "/arena" },
      { icon: "mdi-wallet", label: "Minting", route: "/mint" },
    ],
  }),
};
</script>
