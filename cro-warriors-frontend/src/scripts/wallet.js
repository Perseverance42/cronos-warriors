import Web3 from 'web3';
import VueWeb3 from 'vue-web3';
import Vue from 'vue';


const availableContracts = {
    "WarriorSkills" : {
        address : "0x8A791620dd6260079BF849Dc5567aDC3F2FdC318",
        artifact : () => import("../artifacts/WarriorSkills.json")
    },
    "WarriorVisuals" : {
        address : "0x0165878A594ca255338adfa4d48449f69242Eb8F",
        artifact : () => import("../artifacts/WarriorVisuals.json")
    },
    "CronosWarriors" : {
        address: "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707",
        artifact: () => import("../artifacts/CronosWarriors.json")
    },
    "WarriorFactory" : {
        address: "0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0",
        artifact: () => import("../artifacts/WarriorFactory.json")
    },
    "Treasury":{
        address: "0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6",
        artifact: () => import("../artifacts/Treasury.json")
    },
    "BattleBoard":{
        address: "0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e",
        artifact: () => import("../artifacts/BattleBoard.json")
    },
    "WarriorStats":{
        address: "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853",
        artifact: () => import("../artifacts/WarriorStats.json")
    },
    "WarriorProxy":{
        address: "0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0",
        artifact: () => import("../artifacts/WarriorProxy.json")
    },
    "CombatModule":{
        address: "0x610178dA211FEF7D417bC0e6FeD39F05609AD788",
        artifact: () => import("../artifacts/CombatModule.json")
    }
}

const wallet = {
    $Web3 : Web3,
    $web3 : null,               //will be injected by vue-metamask component
    $currentWalletAddr: null,   //will be injected by vue-metamask component
    _cachedContracts: {},
    injectWallet(web3, walletAddr){
        wallet._cachedContracts = {};
        wallet.$web3 = web3;
        wallet.$currentWalletAddr = walletAddr;
        Vue.use(VueWeb3, {web3: new Web3(web3.currentProvider)} );
    },
    isReady(){
        return wallet.$web3 !== null;
    },
    loadContract(contract){
        return new Promise(function (resolve, reject){
            if(wallet._cachedContracts[contract]){
                resolve(wallet._cachedContracts[contract]);
            }else{
                const contractDef = availableContracts[contract];               
                contractDef.artifact().then(artifact=>{
                    const web3 = new Web3(wallet.$web3.currentProvider);
                    const instance = new web3.eth.Contract(artifact.abi, contractDef.address);
                    wallet._cachedContracts[contract] = instance;
                    resolve(instance);
                }).catch(e=>{
                    reject(e);
                });
            }
        });
    }
}

export default wallet;