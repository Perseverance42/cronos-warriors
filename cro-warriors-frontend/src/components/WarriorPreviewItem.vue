<template>
  <div>
    <v-list>
      <v-list-item>
            <v-list-item-avatar>
                <WarriorPreviewRender :warriorDNA="warriorDNA" v-if="warriorDNA"/>
            </v-list-item-avatar>
            <v-list-item-title># {{warriorID}} | {{warriorName || 'Loading...'}}</v-list-item-title>
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
                        ><v-icon>mdi-cog-transfer-outline</v-icon></v-btn>
                    </template>
                    <v-card class="pa-3" tile width="350">
                        <v-card-title class="text-overline">Select a warrior</v-card-title>
                        <v-divider/>
                        <v-card-actions><ArmyList :armyAddr="currentWallet" @select="selectWarrior($event)"></ArmyList></v-card-actions>
                    </v-card>
                </v-menu>
            </v-list-item-icon>
      </v-list-item>
    </v-list>
  </div>
</template>

<script>

import ArmyList from './ArmyList.vue';
import WarriorPreviewRender from './WarriorPreviewRender.vue';

export default {
  name: "WarriorPreviewItem",
  props: ['warriorID'],
  components: { ArmyList, WarriorPreviewRender},
  methods: {
    async bindContracts(){
          if(this.$wallet.$currentWalletAddr==null){
              setTimeout(this.bindContracts, 1000);
              return;
          }
          this.$bindCall('warriorName', { contract: await this.$wallet.loadContract('WarriorVisuals'), method:"warriorName", args:[ this.warriorID ] });
          this.$bindCall('warriorDNA', { contract: await this.$wallet.loadContract('WarriorVisuals'), method:"warriorDNA", args:[ this.warriorID ] });
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
      currentWallet:function(){
          return this.$wallet ? this.$wallet.$currentWalletAddr : null;
      }
  },
  data: () => ({
      warriorName: null,
      warriorDNA: null,
  }),
};
</script>
