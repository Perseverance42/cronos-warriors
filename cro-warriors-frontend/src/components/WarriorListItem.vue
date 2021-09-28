<template>
    <v-list-item>
        <v-list-item-content  class="pa-0 ma-0"> 
            <v-card class="ma-0" tile :loading="isLoading">
                <div v-if="!isLoading" class="">
                    <v-list-item-title>{{warriorName}} #{{warriorID}}</v-list-item-title>
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
import WarriorSkills from '../scripts/warrior-skills.js';
import WarriorVisuals from '../scripts/warrior-visuals.js';

  export default {
    name: 'WarriorListItem',
    props: ['warriorID'],
    methods:{
        loadWarriorSkills(){
            WarriorSkills.loadWarriorHealth(this.warriorID).then(health=>{
                this.warriorHealth = health;
            }).catch(e=>{
                alert("Failed to load warrior healht " + e);
            });

            WarriorSkills.loadWarriorLevel(this.warriorID).then(level=>{
                this.warriorLevel = level;
            }).catch(e=>{
                alert("Failed to load warrior healht " + e);
            });
        },
        loadWarriorVisuals(){
            WarriorVisuals.warriorName(this.warriorID).then(name=>{
                this.warriorName = name;
            }).catch(e=>{
                alert("Failed to load warrior name " + e);
            });
        }
    },
    watch:{
        "warriorID": function(){
            this.loadWarriorSkills();
            this.loadWarriorVisuals();
        }
    },
    mounted(){
        if(this.warriorID!=null){
            this.loadWarriorSkills();
            this.loadWarriorVisuals();
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

