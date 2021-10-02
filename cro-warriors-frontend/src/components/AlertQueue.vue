<template>
    <div class="alerts">
        <v-alert v-for="alert in alerts" :key="alert.uuid" class="ma-2" :type="alert.type" dismissible>
            <v-container fluid>
                <v-row align="center">
                    <v-col>
                        <div v-if="alert.message">
                            <p>{{alert.message}}</p>
                        </div>
                        <div v-if="alert.component">
                            <component v-bind:is="alert.component"></component>
                        </div>
                        <div v-if="alert.html != null">
                            <span :v-html="alert.html"></span>
                        </div>
                    </v-col>
                    <v-col cols="2" v-if="alert.details">
                        <v-dialog 
                            max-width="600"
                            transition="dialog-top-transition"
                        >
                        <template v-slot:default>
                            <v-card>
                                <v-toolbar 
                                    color="primary"
                                    dark>
                                    {{alert.message}}
                                </v-toolbar>
                                
                                <v-card-text class="py-5">
                                    {{alert.details}}
                                </v-card-text>
                            </v-card>
                        </template>
                        <v-spacer></v-spacer>
                            <template v-slot:activator="{ on, attrs }">
                                <v-btn
                                    color="primary"
                                    v-bind="attrs"
                                    v-on="on"
                                >More Details</v-btn>
                            </template>
                        </v-dialog>
                    </v-col>
                </v-row>
            </v-container>
        </v-alert>
    </div>
</template>

<script>
import { AlertBus } from '../scripts/alert-bus.js';

export default {
    name: 'AlertQueue',
    props: [],
    components:{
    },
    methods:{
        addAlert(alert){
            alert.uuid = this.alertid++;
            this.$set(this.alerts, alert.uuid, alert);
            if(alert.timeout != null){
                setTimeout(this.removeAlert, alert.timeout, alert.uuid );
            }
        },
        removeAlert(uuid){
            this.$delete(this.alerts, uuid);
        }
    },
    watch:{
    },
    mounted(){
        AlertBus.$on('alert', alert =>{
            this.addAlert(alert);
        })
    },
    computed:{
    },
    data: () => ({
        maxAlerts : 100,
        alerts : {},
        alertid : 0
    }),
  }
</script>
<style lang="css" scoped>
.alerts {
    width: 70%;
    position: fixed;
    bottom: 0;
    left:50%;
    transform: translate(-50%);
}
</style>
