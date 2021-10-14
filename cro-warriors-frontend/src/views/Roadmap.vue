<template>
    <v-container>
        <v-row class="text-center text-overline"><v-col><h1>Roadmap</h1></v-col></v-row>        
        <v-row justify="center" align="center">
            <v-col cols="11">
                <v-card>
                    <v-sheet color="primary"><v-card-title>Gear NFTs</v-card-title></v-sheet>
                    <v-card-text>
                        <v-row>
                            <v-col>Some text about how we plan to implement items/gear as seperate NFTs which can be equipped to a warrior.</v-col>
                            <v-col>
                                <v-img>

                                </v-img>
                            </v-col>
                        </v-row>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>
        <v-row justify="center" align="center">
            <v-col cols="11">
                <v-card>
                    <v-sheet color="primary"><v-card-title>PVE events</v-card-title></v-sheet>
                    <v-card-text>
                        <v-row>
                            <v-col>
                                <v-img>
                                    
                                </v-img>
                            </v-col>
                            <v-col>Some text about how battle fees will be distrubted to players durring special player versus enviroment events to attract new players.</v-col>
                        </v-row>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>
        <v-row justify="center" align="center">
            <v-col cols="11">
                <v-card>
                    <v-sheet color="primary"><v-card-title>More variety and design</v-card-title></v-sheet>
                    <v-card-text>
                        <v-row>
                            <v-col>This project was specifically build durring the Cronos hackathon and thus many parts had to be implemented very quickly.<br/>If the project continues afterwards the user interface and core gameplay mechanics would be reworked and extended.</v-col>
                        </v-row>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>
    </v-container>
</template>

<script>
export default {
    name: 'Roadmap',
    props: [],
    components:{
    },
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
