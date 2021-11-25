<template>
  <div v-images-loaded="partsLoaded" class="warrior-char" v-if="warriorDNA">
    <div class="warrior-parts" v-show="imagesLoaded">
	<!--Loads face on Base-->
      <img :style="skinColor" class="chest" :src="baseChestSrc(currentSkinColorChoice)">
      <img :style="clothesColor" class="chest" :src="chestSrc(currentChestChooice)">
      <img :style="skinColor" class="head" :src="headSrc(currentHeadChoice, currentSkinColorChoice)">
      <img :style="clothesColor" class="eyes" :src="eyesSrc(currentEyeChoice)">
      <img :style="skinColor" class="nose" :src="noseSrc(currentNoseChoice, currentSkinColorChoice)">
      <img :style="skinColor" class="mouth" :src="mouthSrc(currentMouthChoice, currentSkinColorChoice)">
      <img :style="hairColor" class="hair" :src="hairSrc(currentHairChoice, currentSkinColorChoice)">
    </div>
  </div>
</template>

<script>
import imagesLoaded from 'vue-images-loaded'
export default {
    name: 'WarriorPreviewRender',
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
          return (parseInt(this.currentDna.substring(0, 2)) % 13 + 1);
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
        currentChestChooice(){
          return (parseInt(this.currentDna.substring(15, 16)) % 8 + 1);
        },
        currentSkinColorChoice(){
			//return (parseInt(this.currentDna.substring(18, 19)) % 6 + 1);
			return this.rarityResolve(this.currentDna.substring(18, 19), this.parttable.skinTypeTable);
		},
        currentClothesColorChoice(){
          return (parseInt(this.currentDna.substring(17, 19)) / 100 * 360);
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
        ],
		skinTypeTable: [
          19, 19, 19, 19, 19, 5
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
}

.warrior-parts {
  position: relative;
  margin-top: 200%;
  transform: scale(3);

  
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
}
</style>