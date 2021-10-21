<template>
    <v-container>
        <v-row class="text-center text-overline"><v-col><h1>Roadmap</h1></v-col></v-row>        
        <v-row justify="center" align="center">
            <v-col cols="11">
                <v-card>
                    <v-sheet color="primary"><v-card-title>Gear NFTs</v-card-title></v-sheet>
                    <v-card-text>
                        <v-row>
                            <v-col cols="8">
                                <div class="pa-4">
                                    <p>Warrior gear is going to be implemented as seperate ERC721 NFT which can be traded independently from the warrior NFT.<br/>
                                        Warrior gear can be minted through two distinct methods.<p/>
                                        <ul>
                                            <li>Gearshop in which players pay with their warriors experience to forge new gear.</li>
                                            <li>During events players who complete certin tasks have the chance to drop additional new gear.</li>
                                        </ul><br/>
                                    <p>
                                        Experience payed in the gearshop will be held by the treasury contract and redistributed in player versus enviroment combat.<br/>
                                        Warrior gear can change the visual appearance and combat statistics of warriors as long as it is equipped to a warrior.<br/>
                                        Warrior gear will not be tradeable when equipped.<br/>
                                    </p>
                                </div>
                            </v-col>
                            <v-col cols="3">
                                <v-img src="@/assets/static/Katana.jpg" contain max-height="500">
                                </v-img>
                            </v-col>
                            <v-spacer></v-spacer>
                        </v-row>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>
        <v-row justify="center" align="center">
            <v-col cols="11">
                <v-card>
                    <v-sheet color="primary"><v-card-title>Integrate with partnered marketplace</v-card-title></v-sheet>
                    <v-card-text>
                        <v-row>
                            <v-col>
                                <div class="pa-4">
                                    We plan to integrate at least one external and open NFT marketplace on Cronos to be able to display open bids and trade history for warriors within the main app.<br/>To reach a broader audience we want to avoid building a proprietary marketplace.
                                </div>
                            </v-col>
                        </v-row>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>
        <v-row justify="center" align="center">
            <v-col cols="11">
                <v-card>
                    <v-sheet color="primary"><v-card-title>Player versus enviroment events</v-card-title></v-sheet>
                    <v-card-text>
                        <v-row>
                            <v-col>
                                <v-img>
                                    
                                </v-img>
                            </v-col>
                            <v-col>
                                <div class="pa-4">
                                    <p>
                                        The game will regularly host special events in which players can participate in player versus enviroment combat.<br/>
                                        At the start of these events a fixed amount of CRO stored within the treasury will be allocated to the event and used to pay out experience to players<br/><br/>
                                        Currently the plan is to let players fight against a mirrored version of their own warrior, the resulting winrate should be around 50% giving players a gamble at leveling their warriors.<br/>
                                        The event can be modified in different ways to change how players benefit from the event.<br/>
                                        <br/>
                                        For example durring holiday seasons each fight could give playes a chance at dropping additional holiday themed warrior gear with variying rarity.<br/><br/>
                                        The ep swap function can be changed for the event so people get a slight advantage and thus can level their warrior until the allocated CRO is distributed<br/><br/>
                                        Promotional partnerships with different Cronos projects could distribute some token or NFT to event participants.   
                                    </p>
                                </div>
                            </v-col>
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
                            <v-col cols="8">
                                <div class="pa-4">
                                This project was designed specifically for the Cronos hackathon and thus many parts had to be implemented very rapidly.<br/>
                                We already implemented much of the projects core game mechanics.<br/>Before a potential release the game variety and scope would need to be extended further.<br/>
                                More combat skills which impact the outcome of fights.<br/>
                                Actual randomness provided by a Oracle would need to be enforced on all contracts.<br/>
                                </div>
                            </v-col>
                            <v-col cols="3">
                                <v-img src="@/assets/static/sickles.jpg" contain max-height="500">
                                </v-img>
                            </v-col>
                            <v-spacer></v-spacer>
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
