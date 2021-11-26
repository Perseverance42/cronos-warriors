import BN from 'bn.js';
const difficultyScale = new BN(25);
const healthScale = new BN(10);
const epScale     = new BN("10000000000");
const epS1Root    = new BN("100000");
const mintFee     = new BN("45000000000000000000");
const critScale   = new BN("1000000000000000000");

const ZERO = new BN(0);
const ONE  = new BN(1);
const TWO  = new BN(2);
const TEN  = new BN(10);
const HUNDRED  = new BN(100);
const THOUSAND  = new BN(1000);

function sqrt(x) {
    let z = x.add(ONE).div(TWO);
    let y = x;
    while (z.sub(y).lt(ZERO)) {
        y = z;
        z = x.div(z).add(z).div(TWO);
    }
    return y;
}

const compute = {
    warriorLevel(experience){
        let lvl = new BN(experience);
        if(mintFee.gt(lvl)){
            lvl = ZERO;
            
        }else{
            lvl = lvl.sub(mintFee);
        }        
        lvl = lvl.div(epScale);
        lvl = lvl.mul(difficultyScale);
        lvl = sqrt(lvl);
        lvl = lvl.div(epS1Root);
        lvl = lvl.add(ONE);
        return lvl;
    },
    warriorHealth(experience, stamina){
        let lvl = this.warriorLevel(experience);
        experience = new BN(experience);
        stamina = new BN(stamina);
        return healthScale.mul(lvl.add(stamina));
    },
    epForLevel(lvl){
        let ep = new BN(lvl);
        ep = ep.sub(ONE);
        ep = ep.mul(epS1Root);
        ep = ep.mul(ep);
        ep = ep.div(difficultyScale);
        ep = ep.mul(epScale);
        return ep.add(mintFee);
    },
    epForNextLevel(experience){
        let lvl = this.warriorLevel(experience);
        let epNeeded = this.epForLevel(lvl.add(ONE));
        return epNeeded;
    },
    levelUpProgress(experience){
        let epNeeded = this.epForNextLevel(experience);
        experience = new BN(experience);
        return HUNDRED.mul(experience).add( epNeeded.div(TWO) ).div(epNeeded);
    },
    warriorCritRate(experience, dexterity){
        let lvl = this.warriorLevel(experience);
        dexterity = new BN(dexterity);
        return (dexterity.mul(critScale)).div(lvl.add(TEN).mul(critScale).div(THOUSAND));
    }
}

export default compute;