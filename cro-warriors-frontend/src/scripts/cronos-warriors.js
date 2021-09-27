import Web3 from 'web3';

//contract imports
const availableContracts = {
    WarriorSkills : {
        address : "0x8A791620dd6260079BF849Dc5567aDC3F2FdC318",
        artifact : () => import("../artifacts/WarriorSkills.json")
    },
    WarriorVisuals : {
        address : "0x0165878A594ca255338adfa4d48449f69242Eb8F",
        artifact : () => import("../artifacts/WarriorVisuals.json")
    },
    CronosWarriors : {
        address: "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707",
        artifact: () => import("../artifacts/CronosWarriors.json")
    },
    WarriorFactory : {
        address: "0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0",
        artifact: () => import("../artifacts/WarriorFactory.json")
    },
    Treasury:{
        address: "0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6",
        artifact: () => import("../artifacts/Treasury.json")
    }
}

const warriors = {
    $Web3 : Web3,
    contracts : availableContracts,
    async loadContract(provider,contract){
        const web3 = new this.$Web3(provider);
        const artifact = await contract.artifact();
        return new web3.eth.Contract(await artifact.abi, contract.address);
    } 
}

export default warriors;