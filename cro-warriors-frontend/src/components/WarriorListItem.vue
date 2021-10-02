<template>
    <v-list-item class="py-2">
        <v-list-item-content  class="pa-0 ma-0"> 
            <v-card class="ma-0" tile :loading="isLoading">
                <div v-if="!isLoading">
                    
                    <v-list-item-title>
                        <v-avatar tile class="mb-2"><Identicon class="pa-0" :value="warriorID"/></v-avatar>
                        {{warriorName}} #{{warriorID}}</v-list-item-title>
                    <v-list-item-subtitle> Level: {{warriorLevel}} | Health: {{warriorHealth}}</v-list-item-subtitle>
                </div>
                <div v-else class="my-4">
                    #{{warriorID}} Pending...
                </div>
            </v-card>
        </v-list-item-content>
        <v-list-item-action v-if="hasSlot"><slot></slot></v-list-item-action>
  </v-list-item>
</template>

<script>
import Identicon from './Identicon.vue';
  export default {
    name: 'WarriorListItem',
    components:{Identicon},
    props: ['warriorID'],
    methods:{
        async bindCalls(){
            this.$bindCall('warriorName', {contract: await this.$wallet.loadContract("WarriorVisuals"), method: 'warriorName', args:[this.warriorID]});
            this.$bindCall('warriorLevel', {contract: await this.$wallet.loadContract("WarriorSkills"), method: 'warriorLevel', args:[this.warriorID]});
            this.$bindCall('warriorHealth', {contract: await this.$wallet.loadContract("WarriorSkills"), method: 'warriorHealth', args:[this.warriorID]});
        }
    },
    watch:{
        "warriorID": function(){
            this.bindCalls();
        }
    },
    mounted(){
        if(this.warriorID!=null){
            this.bindCalls();
        }
    },
    computed: {
        isLoading(){
            return this.warriorName == null || this.warriorLevel == null || this.warriorHealth == null;
        },
        hasSlot(){
            return !!this.$slots[ 'default' ] || !!this.$scopedSlots[ 'default' ];
        }
    },
    data: () => ({
        warriorName: null,
        warriorLevel: null,
        warriorHealth: null
    }),
  }
</script>

