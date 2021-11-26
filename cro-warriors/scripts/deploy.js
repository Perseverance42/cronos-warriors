// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { expect } = require("chai");
const hre = require("hardhat");



async function addModuleAccess(modular, module, role){
    console.log(typeof(role));
    let grantRole = await modular.grantRole(role, module.address);
    grantRole.wait();
    console.log(modular.address + " can now be accessed by " + module.address);
}

async function mintWarriorAndSend(warriors, factory, sender, receiver, name){
    //Modules are initialized now
    const w1 = await(factory.mint(name,
    {
      value: "50000000000000000000"
    }
    ));
    let receipt = await w1.wait();
    const id = receipt.events[2].args[0];
    const send = await warriors.transferFrom(sender, receiver, id);
    receipt = send.wait();

    console.log("Minted "+ name + " and send to " + receiver);
}
async function main() {
  const signers = await hre.ethers.getSigners()
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  //deploy libs first
  const MathLib = await hre.ethers.getContractFactory("Math");
  const mathlib = await MathLib.deploy();
  await mathlib.deployed();

  const ComputeLib = await hre.ethers.getContractFactory("Compute",{
    libraries: {
      Math: mathlib.address,
    },
    });
  const computelib = await ComputeLib.deploy();
  await computelib.deployed();
  
  const VisualsLib = await hre.ethers.getContractFactory("VisualsLib");
  const visualLib = await VisualsLib.deploy();
  await visualLib.deployed();
  
  const SkillsLib = await hre.ethers.getContractFactory("SkillsLib");
  const skillsLib = await SkillsLib.deploy();
  await skillsLib.deployed();
  
  const StatsLib = await hre.ethers.getContractFactory("StatsLib");
  const statsLib = await StatsLib.deploy();
  await statsLib.deployed();
  
  console.log("Libs deployed!")
  
  //Cronos Warriors Contract gets used as root for most stuff so it needs to be deployed first
  const CronosWarriors = await hre.ethers.getContractFactory("CronosWarriors");
  
  const warriors = await CronosWarriors.deploy();
  await warriors.deployed();
  console.log("Cronos Warriors deployed to:", warriors.address);
  
  const WarriorVisuals = await hre.ethers.getContractFactory("WarriorVisuals", {
    libraries: {
      VisualsLib: visualLib.address
    }
  });
  const warriorVisuals = await WarriorVisuals.deploy(warriors.address);
  await warriorVisuals.deployed();
  console.log("Warrior Visuals deployed "+warriorVisuals.address);
  
  const WarriorStats = await hre.ethers.getContractFactory("WarriorStats", {
    libraries: {
      StatsLib: statsLib.address
    }
  });
  const warriorStats = await WarriorStats.deploy();
  await warriorStats.deployed();
  console.log("Warrior Stats deployed "+warriorStats.address);
  
  const Treasury = await hre.ethers.getContractFactory("Treasury", {
    libraries: {
      Math: mathlib.address,
      Compute: computelib.address
    },
  });
  const treasury = await Treasury.deploy();
  await treasury.deployed();
  console.log("Treasury deployed "+treasury.address);
  
  const WarriorSkills = await hre.ethers.getContractFactory("WarriorSkills", {
    libraries: {
      Math: mathlib.address,
      SkillsLib: skillsLib.address,
      Compute: computelib.address,
      Math: mathlib.address
    },
  });
  const warriorSkills = await WarriorSkills.deploy( warriors.address, treasury.address );
  await warriorSkills.deployed();
  console.log("Warrior Skills deployed "+warriorSkills.address);

  const CombatModule = await hre.ethers.getContractFactory("CombatModule", {
    libraries: {
      Math: mathlib.address,
      Compute: computelib.address  
    },
  });
  const combatModule = await CombatModule.deploy(warriorSkills.address, warriorStats.address, treasury.address);
  await combatModule.deployed();
  console.log("Combat Module deployed to:"+combatModule.address);
  
  const BattleBoard = await hre.ethers.getContractFactory("BattleBoard");
  const battleBoard = await BattleBoard.deploy(warriors.address, combatModule.address);
  await battleBoard.deployed();
  console.log("BattleBoard deployed to: "+battleBoard.address);
  
  const WarriorFactory = await hre.ethers.getContractFactory("WarriorFactory");
  const warriorFactory = await WarriorFactory.deploy(warriors.address, warriorSkills.address, warriorStats.address, warriorVisuals.address, treasury.address);
  await warriorFactory.deployed();
  console.log("Warrior Factory deployed to: ", warriorFactory.address);
  

  const WarriorProxy = await hre.ethers.getContractFactory("WarriorProxy");
  const warriorProxy = await WarriorProxy.deploy(warriors.address, treasury.address, warriorFactory.address, warriorSkills.address, warriorStats.address, warriorVisuals.address);
  await warriorProxy.deployed();
  console.log("Warrior Proxy deployed to: ", warriorFactory.address);
    /**
     * 
     * Deployments done 
     * 
     * */


  console.log("Setting up module access control...");
 
  //Warrior factory controls mint/burn of storage
  await addModuleAccess(warriors, warriorFactory, "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6");
  await addModuleAccess(warriorSkills, warriorFactory, "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6");
  await addModuleAccess(warriorStats, warriorFactory, "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6");
  await addModuleAccess(warriorVisuals, warriorFactory, "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6");
  
  //Factory needs access to Treasury
  await addModuleAccess(treasury, warriorFactory, "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6");
 
  //Battle Board starts fights in combat module
  await addModuleAccess(combatModule, battleBoard, "0x3e080ec955b0872a48616505668afef3d5feb6f6ed7066618b240a262412ea75");
  
  //Combat module changes stats and swaps ep
  await addModuleAccess(treasury, combatModule, "0x28d62fc77014de57a1bbaa8212ff0979fa61ab00d377b4b8d9762048fb419961");
  await addModuleAccess(warriorStats, combatModule, "0x5ef52737852c52d2211e81450fc3850cd8f44f8344ad3b406fdca6ea6d0bac7e");
 
  //enable owner wallet to edit tokenURI
  let grantRole = await warriors.grantRole("0xa62d8e55240185837238af9adc11e51727e005b95707f32446366dbe58f727e2", signers[0].address);
  await grantRole.wait();
  //enable owner wallet to edit Treasury
  
  grantRole = await treasury.grantRole("0xb7b0a8b00357f0e4c4a4839008cf90d61a23fe1c55511ea70753532d8bab02c5", signers[0].address);
  await grantRole.wait();
  
  //testnet genesis warriors
  await mintWarriorAndSend(warriors, warriorFactory, signers[0].address, "0x186643D210995010150B8e84Bb58513D0D5dDA3c", "Crominator");
  await mintWarriorAndSend(warriors, warriorFactory, signers[0].address, "0x4c12170bf8e986e43d04add0184489959faa695f", "Crolosus"); 
  await mintWarriorAndSend(warriors, warriorFactory, signers[0].address, "0x04Fd207BCC982C0041b41817E3db7aac4222608c", "Crocatus");
  await mintWarriorAndSend(warriors, warriorFactory, signers[0].address, "0xd98ca1cc5e97672bd0d420677f3881722cc19b10", "Cronostradamus");
  await mintWarriorAndSend(warriors, warriorFactory, signers[0].address, "0xdAf13551F4B47DBf8964724F941E0163eC19c01D", "Cronotrigger");
  await mintWarriorAndSend(warriors, warriorFactory, signers[0].address, "0x9dBebFE53Ad6954FF5640fF561cAE0aFCa3ee0AA", "Crobro");
  await mintWarriorAndSend(warriors, warriorFactory, signers[0].address, "0xb48d1128e9130E3d2345910E2cC2C5136446C365", "Spartacus");

  console.log("done!");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
