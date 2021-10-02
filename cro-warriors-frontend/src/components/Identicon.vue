<template>
    <img v-if="hash!=null" :src="imgSource" aspect-ratio="1/1"/>
</template>

<script>
import Identicon from 'identicon.js';
import shajs from 'sha.js'

export default {
    name: 'Identicon',
    props: ['value', 'icoForeground', 'icoBackground', 'icoMargin' ],
    components:{
    },
    methods:{
        async hashValue(){
            const digest = shajs('sha256').update(this.value).digest('hex');
            this.hash = digest;
        }
    },
    watch:{
        "value":function(){
            this.hashValue();
        }
    },
    mounted(){
        this.hashValue();
    },
    computed:{
        imgSource(){
            const data = new Identicon(this.hash, {
                foreground: this.icoForeground,
                background: this.icoBackground || [255, 255, 255, 255],
                margin: this.icoMargin || 0.2,
                format: 'svg'
            }).toString();
            return 'data:image/svg+xml;base64,' + data;
        }
    },
    data: () => ({
        hash: null,
    }),
  }
</script>

