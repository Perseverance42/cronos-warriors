<template>
    <v-list>
        <v-list-item-group
        v-model="selectedWarrior"
        color="primary"
        >
            <v-list-item
                v-for="(id,i) in warriorIDs"
                :key="i"
                class="pa-0 ma-0"
                @click="warriorSelected(i)"
            >
                <v-list-item-content  class="pa-0 ma-0"> 
                    <WarriorListItem :warriorID="id"></WarriorListItem>
                </v-list-item-content>
            </v-list-item>
        </v-list-item-group>     
    </v-list>
</template>

<script>
import WarriorListItem from './WarriorListItem.vue';

  export default {
    name: 'ChallangeWarriorMenu',
    components:{WarriorListItem},
    methods:{

    },
    watch:{

    },
    mounted(){
    },
    computed:{
    },
    data: () => ({

    }),
  }
</script>
