import Web3 from 'web3';
import VueWeb3 from 'vue-web3';
import Vue from 'vue';

//used to sync changes on wallet to other components
export const EventBus = new Vue();

const availableContracts = {
    "WarriorSkills" : {
        address : "0xCf622473FEA959f6288b4b4E2b2553C20a139A58",
        artifact : () => import("../artifacts/WarriorSkills.json")
    },
    "WarriorVisuals" : {
        address : "0x6C3D276C5Ca1e6dc1d108Ca47F042B9356B69C5C",
        artifact : () => import("../artifacts/WarriorVisuals.json")
    },
    "CronosWarriors" : {
        address: "0x6777a24aef6374265B4A900c9Db57673cFF426Ab",
        artifact: () => import("../artifacts/CronosWarriors.json")
    },
    "WarriorFactory" : {
        address: "0xDd5cdf8FBE6AE1d743f25EECaC16937F5d718e25",
        artifact: () => import("../artifacts/WarriorFactory.json")
    },
    "Treasury":{
        address: "0xEefAFa8d1790495621520fa92f458B2e1541b039",
        artifact: () => import("../artifacts/Treasury.json")
    },
    "BattleBoard":{
        address: "0x876f14A7841850dDF4eB6E2C10c5583D3d7aC660",
        artifact: () => import("../artifacts/BattleBoard.json")
    },
    "WarriorStats":{
        address: "0xbD0313FA548e58ecAe35ce055aE87704872b20d4",
        artifact: () => import("../artifacts/WarriorStats.json")
    },
    "WarriorProxy":{
        address: "0xDd5cdf8FBE6AE1d743f25EECaC16937F5d718e25",
        artifact: () => import("../artifacts/WarriorProxy.json")
    },
    "CombatModule":{
        address: "0x6c0B85a1D976A7a11c52c6e564Ab0e9b5e390fc7",
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
        Vue.use(VueWeb3, {web3: new Web3(web3.currentProvider)});
        EventBus.$emit("init");
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
    },weiToCroDecimal(experience){
        return Web3.utils.fromWei(experience, 'ether');
    }
}

export default wallet;