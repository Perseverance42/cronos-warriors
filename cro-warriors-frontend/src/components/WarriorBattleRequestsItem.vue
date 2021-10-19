<template>
    <v-list-item>
        <v-list-item-avatar dense color="accent">
            <WarriorPreviewRender :warriorDNA="warriorDNA" v-if="warriorDNA"/>
        </v-list-item-avatar>
        <div style="max-width: 45%;">
            <v-list-item-content>
                <v-list-item-title class="text-truncate"># {{warriorID}} | {{warriorName || 'Loading...'}}</v-list-item-title>
            </v-list-item-content>
        </div>
        <v-spacer></v-spacer>
            <v-list-item-icon>
                <v-menu close-on-click>
                    <template v-slot:activator="{ on, attrs }">
                        <v-btn 
                            fab 
                            x-small 
                            :disabled="!currentWallet"
                            elevation="0" 
                            v-bind="attrs" 
                            v-on="on"
                        >{{requestCount}}</v-btn>
                    </template>
                    <v-card class="pa-3" tile>
                        <v-card-title class="text-overline">Open requests</v-card-title>
                        <v-divider/>
                        <v-card-actions><BattleRequestList :warriorID="warriorID"></BattleRequestList></v-card-actions>
                    </v-card>
                </v-menu>
            </v-list-item-icon>
    </v-list-item>
</template>

<script>
import WarriorPreviewRender from './WarriorPreviewRender.vue';
import BattleRequestList from './BattleRequestList.vue';

export default {
  name: "WarriorBattleRequestsItem",
  props: ['warriorID'],
  components: {WarriorPreviewRender, BattleRequestList},
  methods: {
    async bindContracts(){
          if(this.$wallet.$currentWalletAddr==null){
              setTimeout(this.bindContracts, 1000);
              return;
          }
          this.$bindCall('warriorName', { contract: await this.$wallet.loadContract('WarriorVisuals'), method:"warriorName", args:[ this.warriorID ] });
          this.$bindCall('warriorDNA', { contract: await this.$wallet.loadContract('WarriorVisuals'), method:"warriorDNA", args:[ this.warriorID ] });
          this.$bindCall('battleRequests', { contract: await this.$wallet.loadContract('BattleBoard'), method:"defensiveRequestOf", args:[ this.warriorID, 0, 10 ] });
    },
    selectWarrior(id){
        this.$selectedWarrior = id;
    }
  },
  watch: {
      'warriorID':function(){
          if(this.currentWallet && this.warriorID && this.warriorID.length>0){
              this.bindContracts();
          }
      }
  },
  mounted() {
      this.bindContracts();
  },
  computed: {
      currentWallet(){
          return this.$wallet ? this.$wallet.$currentWalletAddr : null;
      },
      requestCount(){
          return this.battleRequests.length >= 10 ? '10+' : this.battleRequests.length;
      }
  },
  data: () => ({
      warriorName: null,
      warriorDNA: null,
      battleRequests: [],
  }),
};
</script>
