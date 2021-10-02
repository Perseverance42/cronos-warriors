<template>
  <div>
    <v-list>
      <v-list-item>
            <v-list-item-avatar dense>
            <v-img src="https://randomuser.me/api/portraits/men/85.jpg"></v-img>
            </v-list-item-avatar>
            
            <v-list-item-title># {{warriorID}} | {{warriorName || 'Loading...'}}</v-list-item-title>
            <v-list-item-icon>
                <v-tooltip bottom>
                    <template v-slot:activator="{ on, attrs }">
                        <v-btn 
                            fab 
                            x-small 
                            elevation="0" 
                            v-bind="attrs" 
                            v-on="on"
                        ><v-icon>mdi-cog-transfer-outline</v-icon></v-btn>
                    </template>
                    <span>Change selected warrior</span>
                </v-tooltip>
            </v-list-item-icon>
      </v-list-item>
    </v-list>
  </div>
</template>

<script>
export default {
  name: "WarriorPreviewItem",
  props: ['warriorID'],
  components: {},
  methods: {
      async bindContracts(){
          if(this.$wallet.$currentWalletAddr==null){
              setTimeout(this.bindContracts, 1000);
              return;
          }
          this.$bindCall('warriorName', { contract: await this.$wallet.loadContract('WarriorVisuals'), method:"warriorName", args:[ this.warriorID ] });
      }
  },
  watch: {},
  mounted() {
      this.bindContracts();
  },
  computed: {},
  data: () => ({
      warriorName: null
  }),
};
</script>
