<template>
  <div v-images-loaded="partsLoaded" class="warrior-char" v-if="warriorDNA">
    <div class="warrior-parts" v-show="imagesLoaded">
	<!--Loads Base then Clothes-->
		<img :style="skinColor" class="armRight" :src="baseArmRightSrc(currentSkinColorChoice)">
		<img :style="clothesColor" class="armRight" :src="armRightSrc(currentArmChoice)">
		<img :style="skinColor" class="chest" :src="baseChestSrc(currentSkinColorChoice)">
		<img :style="clothesColor" class="chest" :src="chestSrc(currentChestChooice)">
		<img :style="skinColor" class="head" :src="headSrc(currentHeadChoice, currentSkinColorChoice)">
		<img :style="skinColor" class="legs" :src="baseLegSrc(currentSkinColorChoice)">
		<img :style="skinColor" class="feet" :src="baseFeetSrc(currentSkinColorChoice)">
		<img :style="skinColor" class="armLeft" :src="baseArmLeftSrc(currentSkinColorChoice)">
		<img :style="clothesColor" class="armLeft" :src="armLeftSrc(currentArmChoice)">
	<!--Loads face on Base-->
		<img :style="clothesColor" class="eyes" :src="eyesSrc(currentEyeChoice)">
		<img :style="skinColor" class="nose" :src="noseSrc(currentNoseChoice, currentSkinColorChoice)">
		<img :style="skinColor" class="mouth" :src="mouthSrc(currentMouthChoice, currentSkinColorChoice)">
	
		<img :style="clothesColor" class="legs" :src="legSrc(currentLegChooice)">
		<img :style="clothesColor" class="feet" :src="feetSrc(currentFeetChooice)">		
		<img :style="hairColor" class="hair" :src="hairSrc(currentHairChoice, currentSkinColorChoice)">
			

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
		headSrc(baseHead, skinType) {
			console.log(skinType)
			if (skinType > 5) {
				return require("../assets/warriorparts/special-head-" + skinType + ".svg")
			} else {
				return require("../assets/warriorparts/base-head-" + baseHead + "-" + skinType + ".svg")
			}
		},
		eyesSrc(i) {
			return require("../assets/warriorparts/base-eyes-" + i + ".svg")
		},
		noseSrc(i, j) {
			if (j > 5) {
				return require("../assets/warriorparts/special-nose-" + j + ".svg")
			} else {
				return require("../assets/warriorparts/base-nose-" + i + "-" + j + ".svg")
			}
		},
		mouthSrc(i, j) {
			if (j > 5) {
				return require("../assets/warriorparts/special-mouth-" + j + ".svg")
			} else {
				return require("../assets/warriorparts/base-mouth-" + i + "-" + j + ".svg")
			}
		},
		baseChestSrc(i) {
			return require("../assets/warriorparts/base-chest-" + i + ".svg")
		},
		baseArmLeftSrc(i) {
			return require("../assets/warriorparts/base-armLeft-" + i + ".svg")
		},
		baseArmRightSrc(i) {
			return require("../assets/warriorparts/base-armRight-" + i + ".svg")
		},
		baseLegSrc(i) {
			return require("../assets/warriorparts/base-legs-" + i + ".svg")
		},
		baseFeetSrc(i) {
			return require("../assets/warriorparts/base-feet-" + i + ".svg")
		},
		hairSrc(i, skinType) {
			if (skinType > 5) {
				return require("../assets/warriorparts/special-hair-" + skinType + ".svg")
			} else {
				return require("../assets/warriorparts/clothes-hair-" + i + ".svg")
			}
		},
		chestSrc(i) {
			return require("../assets/warriorparts/clothes-chest-" + i + ".svg")
		},
		armLeftSrc(i) {
			return require("../assets/warriorparts/clothes-armLeft-" + i + ".svg")
		},
		armRightSrc(i) {
			return require("../assets/warriorparts/clothes-armRight-" + i + ".svg")
		},
		legSrc(i) {
			return require("../assets/warriorparts/clothes-legs-" + i + ".svg")
		},
		feetSrc(i) {
			return require("../assets/warriorparts/clothes-feet-" + i + ".svg")
		},
    rarityResolve(gene, lootable){  
        gene += 1; //offset from 00-99 to 1-100
        gene /= 100.0; // scale to 0.001 - 1
        let sum = 0;
        let ranges = new Array();
        for(let i=0;i<lootable.length;i++){
          sum += lootable[i];
          ranges[i] = lootable[i] + (i == 0 ? 0 : ranges[i-1]+1);
        }
        gene *= sum; //scale gene to lootable range
        for(let i=0;i<ranges.length;i++){
            if(gene <= ranges[i]){
              return i+1;
            }
        }
        return 1; //should be dead code
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
        return this.rarityResolve(this.currentDna.substring(0, 1), this.parttable.hair);
      },
      currentHeadChoice(){
        return (parseInt(this.currentDna.substring(2, 4)) % 4 + 1);
      },
      currentEyeChoice(){
        return (parseInt(this.currentDna.substring(4, 6)) % 8 + 1);
      },
      currentNoseChoice(){
        return (parseInt(this.currentDna.substring(6, 8)) % 7 + 1);
      },
      currentMouthChoice(){
        return (parseInt(this.currentDna.substring(8, 10)) % 11 + 1);
      },
      currentArmChoice(){
        return (parseInt(this.currentDna.substring(10, 12)) % 9 + 1);
      },
      currentLegChooice(){
        return (parseInt(this.currentDna.substring(14, 15)) % 8 + 1);
      },
      currentChestChooice(){
        return (parseInt(this.currentDna.substring(15, 16)) % 8 + 1);
      },
      currentFeetChooice(){
        return (parseInt(this.currentDna.substring(16, 17)) % 7 + 1);
      },
      currentClothesColorChoice(){
        return (parseInt(this.currentDna.substring(17, 19)) / 100 * 360);
      },
      currentSkinColorChoice(){
        return (parseInt(this.currentDna.substring(18, 19)) % 6 + 1);
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
    data() {
      return {
			imagesLoaded: false,
      parttable: {
        hair: [
          1, 10, 10, 10, 80, 10, 10, 10, 10, 10, 60, 2, 10
        ]
      }
		}
    }
  }
</script>

<style lang="scss" scoped>

.warrior-char {
  position: relative;
  width:100%;
  /*background-color:red; remove after setup*/
}

.share-page .warrior-parts {
  margin-left: 4vh;
}

.warrior-battle-component .warrior-parts {
  margin-left: -1vh;
}

.warrior-parts {
  position: relative;
  width:100%;
  /*top: 50%; left: 50%;
  width:450%;
  transform: translate(-40%,380px);*/
}
  
  .hair {
   width: 55%;
    position: absolute;
	transform: translate(-50%,-50%);
  }

  .head {
    width: 55%;
    position: absolute;
	transform: translate(-50%,-50%);
  }

  .eyes {
    width: 55%;
    position: absolute;
	transform: translate(-50%,-50%);
  }

  .nose {
    width: 55%;
    position: absolute;
	transform: translate(-50%,-50%);
  }
  .mouth {
    width: 55%;
    position: absolute;
	transform: translate(-50%,-50%);
  }

  .chest {
    width: 55%;
    position: absolute;
	transform: translate(-50%,-50%);
  }
  
  .legs {
	width: 55%;
    position: absolute;
	transform: translate(-50%,-50%);
  }
  
  .feet {
	width: 55%;
    position: absolute;
	transform: translate(-50%,-50%);
  }
  
  .armLeft {
	width: 55%;
    position: absolute;
	transform: translate(-50%,-50%);
  }
  
  .armRight {
	width: 55%;
    position: absolute;
	transform: translate(-50%,-50%);
  }



</style>
