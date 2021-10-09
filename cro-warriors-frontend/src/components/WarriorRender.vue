<template>
  <div v-images-loaded="partsLoaded" class="warrior-char" v-if="warriorDNA">
    <div class="warrior-parts" v-show="imagesLoaded">
      <img :style="clothesColor" class="left-feet" :src="leftFeetSrc(currentFeetChooice)">  
      <img :style="clothesColor" class="right-feet" :src="rightFeetSrc(currentFeetChooice)">
      
      <img :style="clothesColor" class="left-lower-leg" :src="lowerLeftLegSrc(currentLegChooice)">
      <img :style="clothesColor" class="right-lower-leg" :src="lowerRightLegSrc(currentLegChooice)">
      
      <img :style="clothesColor" class="right-upper-leg" :src="upperRightLegSrc(currentLegChooice)">
      <img :style="clothesColor" class="left-upper-leg" :src="upperLeftLegSrc(currentLegChooice)">

      <img :style="skinColor" class="left-lower-arm" :src="lowerLeftArmSrc(currentArmChoice)">
      <img :style="skinColor" class="left-upper-arm" :src="upperLeftArmSrc(currentArmChoice)">

      <img :style="skinColor" class="right-lower-arm" :src="lowerRightArmSrc(currentArmChoice)">
      <img :style="skinColor" class="right-upper-arm" :src="upperRightArmSrc(currentArmChoice)">

      <img :style="clothesColor" class="chest" :src="chestSrc(currentChestChooice)">
      <img :style="skinColor" class="head" :src="headSrc(currentHeadChoice)" >
      <img :style="skinColor" class="eyes" :src="eyesSrc(currentEyeChoice)" >
      <img :style="skinColor" class="mouth" :src="mouthSrc(currentMouthChoice)" >
      <img :style="skinColor" class="nose" :src="headSrc(currentNoseChoice)" >
      <img :style="hairColor" class="hair" :src="headSrc(currentHairChoice)" >
    </div>
  </div>
</template>

<script>
import imagesLoaded from 'vue-images-loaded'

export default {
    name: 'WarriorRender',
    directives:{
      imagesLoaded
    },
    props: {
      warriorDNA:{
        default: '',
        type: String
      }
    },
    components:{
    },
    methods:{
      partsLoaded(){
        this.imagesLoaded = true;
      },
      getColor (deg) {
        return `filter: hue-rotate(${deg}deg);`
      },
      hairSrc(i) {
        return require("../assets/warriorparts/hair-" + i + ".png")
      },
      headSrc(i) {
        return require("../assets/warriorparts/head-" + i + ".png")
      },
      eyesSrc(i) {
        return require("../assets/warriorparts/eyes-" + i + ".png")
      },
      noseSrc(i) {
        return require("../assets/warriorparts/nose-" + i + ".png")
      },
      mouthSrc(i) {
        return require("../assets/warriorparts/mouth-" + i + ".png")
      },
      upperLeftArmSrc(i) {
        return require("../assets/warriorparts/upper-left-arm-" + i + ".png")
      },
      lowerLeftArmSrc(i) {
        return require("../assets/warriorparts/lower-left-arm-" + i + ".png")
      },
      upperRightArmSrc(i) {
        return require("../assets/warriorparts/upper-right-arm-" + i + ".png")
      },
      lowerRightArmSrc(i) {
        return require("../assets/warriorparts/lower-right-arm-" + i + ".png")
      },
      chestSrc(i) {
        return require("../assets/warriorparts/chest-" + i + ".png")
      },
      upperLeftLegSrc(i) {
        return require("../assets/warriorparts/upper-left-leg-" + i + ".png")
      },
      lowerLeftLegSrc(i) {
        return require("../assets/warriorparts/lower-left-leg-" + i + ".png")
      },
      upperRightLegSrc(i) {
        return require("../assets/warriorparts/upper-right-leg-" + i + ".png")
      },
      lowerRightLegSrc(i) {
        return require("../assets/warriorparts/lower-right-leg-" + i + ".png")
      },
      leftFeetSrc(i) {
        return require("../assets/warriorparts/right-feet-" + i + ".png")
      },
      rightFeetSrc(i) {
        return require("../assets/warriorparts/left-feet-" + i + ".png")
      }
    },
    watch:{
    },
    mounted(){
    },
    computed:{
      currentDna(){
        return this.warriorDNA;
      },
      currentHairChoice(){
        return (parseInt(this.currentDna.substring(0, 2)) % 7 + 1);
      },
      currentHeadChoice(){
        return (parseInt(this.currentDna.substring(2, 4)) % 7 + 1);
      },
      currentEyeChoice(){
        return (parseInt(this.currentDna.substring(4, 6)) % 11 + 1);
      },
      currentNoseChoice(){
        return (parseInt(this.currentDna.substring(6, 8)) % 11 + 1);
      },
      currentMouthChoice(){
        return (parseInt(this.currentDna.substring(8, 10)) % 11 + 1);
      },
      currentArmChoice(){
        return (parseInt(this.currentDna.substring(10, 12)) % 6 + 1);
      },
      currentLegChooice(){
        return (parseInt(this.currentDna.substring(14, 15)) % 1 + 1);
      },
      currentChestChooice(){
        return (parseInt(this.currentDna.substring(15, 16)) % 1 + 1);
      },
      currentFeetChooice(){
        return (parseInt(this.currentDna.substring(16, 17)) % 1 + 1);
      },
      currentClothesColorChoice(){
        return (parseInt(this.currentDna.substring(17, 19)) / 100 * 360);
      },
      currentSkinColorChoice(){
        return (parseInt(this.currentDna.substring(18, 19)) / 100 * 360);
      },
      currentHairColorChoice(){
        return (parseInt(this.currentDna.substring(18, 20)) / 100 * 360);
      },
      clothesColor () {
        return this.getColor(this.currentClothesColorChoice);
      },
      skinColor () {
        return this.getColor(this.currentSkinColorChoice);
      },
      hairColor () {
        return this.getColor(this.currentHairColorChoice);
      }
    },
    data: () => ({
      imagesLoaded: false,
    }),
  }
</script>

<style lang="scss" scoped>

.warrior-char {
  position: relative;
}

.share-page .warrior-parts {
  margin-left: 4vh;
}

.warrior-battle-component .warrior-parts {
  margin-left: -1vh;
}

.warrior-parts {
  position: absolute;
  top: 50%; right: 50%;
  transform: translate(50%,-50%);

  .hair {
    width: 15vh;
    position: absolute;
    top: 50%; right: 50%;
    transform: translate(59%,-100%);
  }

  .head {
    width: 15vh;
    position: absolute;
    top: 50%; right: 50%;
    transform: translate(59%,-100%);
  }

  .eyes {
    width: 13vh;
    position: absolute;
    top: 50%; right: 50%;
    transform: translate(50%,-50%);
  }

  .nose {
    width: 13vh;
    position: absolute;
    top: 50%; right: 50%;
    transform: translate(50%,-50%);
  }
  .mouth {
    width: 6vh;
    position: absolute;
    top: 50%; right: 50%;
    transform: translate(50%,-50%);
  }

  .chest {
    width: 13vh;
    position: absolute;
    top: 50%; right: 50%;
    transform: translate(50%,-50%);
  }

  .left-lower-leg {
    width: 6vh;
    position: absolute;
    top: 50%; right: 50%;
    
  }

  .right-lower-leg {
    width: 6vh;
    position: absolute;
    top: 50%; right: 50%;
    transform: translate(50%,-50%);
  }

  .left-upper-leg {
    width: 6vh;
    position: absolute;
    top: 50%; right: 50%;
    
  }

  .right-upper-leg {
    width: 6vh;
    position: absolute;
    top: 50%; right: 50%;
    transform: translate(50%,-50%);
  }

  .left-lower-arm {
    width: 6vh;
    position: absolute;
    top: 50%; right: 50%;
    
  }

  .right-lower-arm {
    width: 6vh;
    position: absolute;
    top: 50%; right: 50%;
    transform: translate(50%,-50%);
  }

  .left-upper-arm {
    width: 6vh;
    position: absolute;
    top: 50%; right: 50%;
    
  }

  .right-upper-arm {
    width: 6vh;
    position: absolute;
    top: 50%; right: 50%;
    transform: translate(50%,-50%);
  }

  .left-feet {
    width: 6vh;
    position: absolute;
    top: 50%; right: 50%;
    
  }

  .right-feet {
    width: 6vh;
    position: absolute;
    top: 50%; right: 50%;
    transform: translate(50%,-50%);
  }
}
</style>
