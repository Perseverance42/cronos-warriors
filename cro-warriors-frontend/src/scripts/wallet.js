import Web3 from 'web3';
import VueWeb3 from 'vue-web3';
import Vue from 'vue';

//used to sync changes on wallet to other components
export const EventBus = new Vue();

const availableContracts = {
    "WarriorSkills" : {
        address : "0xA9111058aC3359c640aA8e39Fc94d53fD8c5AC2F",
        artifact : () => import("../artifacts/WarriorSkills.json")
    },
    "WarriorVisuals" : {
        address : "0x28c6002Eae84F858f4402c17cEB4565D382CE206",
        artifact : () => import("../artifacts/WarriorVisuals.json")
    },
    "CronosWarriors" : {
        address: "0x9FD69B9ed7317BF8aBE639B6C5D2B0D646A630C8",
        artifact: () => import("../artifacts/CronosWarriors.json")
    },
    "WarriorFactory" : {
        address: "0xE47De92f71D21B97d196be433EE6939e17d5cEB4",
        artifact: () => import("../artifacts/WarriorFactory.json")
    },
    "Treasury":{
        address: "0x7C21Acac884713690a7f1CB03dD40C19888B5F10",
        artifact: () => import("../artifacts/Treasury.json")
    },
    "BattleBoard":{
        address: "0xD8ecb434b43631c67e5Bda4a59Fa880467828a9C",
        artifact: () => import("../artifacts/BattleBoard.json")
    },
    "WarriorStats":{
        address: "0x994f57295b5EfD35c92b0345495029BE792c85f7",
        artifact: () => import("../artifacts/WarriorStats.json")
    },
    "WarriorProxy":{
        address: "0xE47De92f71D21B97d196be433EE6939e17d5cEB4",
        artifact: () => import("../artifacts/WarriorProxy.json")
    },
    "CombatModule":{
        address: "0x91204b3eD1eb628716636A5654F5420373d21641",
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
        wallet.enforceNetwork();
        window.ethereum.on('accountsChanged', function () {
            window.location.reload();
        });
        window.ethereum.on('networkChanged', function () {
            wallet.enforceNetwork();
            window.location.reload();
        });
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
    }, async enforceNetwork(){
        // Check if MetaMask is installed
        // MetaMask injects the global API into window.ethereum
        if (window.ethereum) {
            try {
            // check if the chain to connect to is installed
            await window.ethereum.request({
                method: 'wallet_switchEthereumChain',
                params: [{ chainId: '0x152' }], // chainId must be in hexadecimal numbers
            });
            } catch (error) {
            // This error code indicates that the chain has not been added to MetaMask
            // if it is not, then install it into the user MetaMask
            if (error.code === 4902) {
                try {
                await window.ethereum.request({
                    method: 'wallet_addEthereumChain',
                    params: [
                    {
                        chainId: '0x152',
                        rpcUrls: ['https://cronos-testnet-3.crypto.org:8545/'],
                        nativeCurrency: {
                            name: 'TCRO',
                            symbol: 'TCRO', // 2-6 characters long
                            decimals: 18
                        }
                    },
                    ],
                });
                } catch (addError) {
                console.error(addError);
                }
            }
            console.error(error);
            }
        } else {
            // if no window.ethereum then MetaMask is not installed
            alert('MetaMask is not installed. Please consider installing it: https://metamask.io/download.html');
        } 
    }
}

export default wallet;