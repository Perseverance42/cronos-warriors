// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { expect } = require("chai");
const hre = require("hardhat");

async function addModuleAccess(modular, module){
    
    let setModule = await modular.setModule(module.address, true);
    setModule.wait();
    console.log(modular.address + " can now be accessed by " + module.address);
}

async function main() {
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
  const warriorVisuals = await WarriorVisuals.deploy();
  await warriorVisuals.deployed();
  console.log("Warrior Visuals deployed @"+warriorVisuals.address);
  
  const WarriorStats = await hre.ethers.getContractFactory("WarriorStats", {
    libraries: {
      StatsLib: statsLib.address
    }
  });
  const warriorStats = await WarriorStats.deploy();
  await warriorStats.deployed();
  console.log("Warrior Stats deployed @"+warriorStats.address);
  
  const Treasury = await hre.ethers.getContractFactory("Treasury", {
    libraries: {
      Math: mathlib.address,
      Compute: computelib.address
    },
  });
  const treasury = await Treasury.deploy();
  await treasury.deployed();
  console.log("Treasury deployed @"+treasury.address);
  
  const WarriorSkills = await hre.ethers.getContractFactory("WarriorSkills", {
    libraries: {
      Math: mathlib.address,
      SkillsLib: skillsLib.address,
      Compute: computelib.address
    },
  });
  const warriorSkills = await WarriorSkills.deploy( warriors.address, treasury.address );
  await warriorSkills.deployed();
  console.log("Warrior Skills deployed @"+warriorSkills.address);

  const CombatModule = await hre.ethers.getContractFactory("CombatModule", {
    libraries: {
      Math: mathlib.address,
      Compute: computelib.address  
    },
  });
  const combatModule = await CombatModule.deploy(warriorSkills.address, warriorStats.address, treasury.address);
  await combatModule.deployed();
  console.log("Combat Module deployed @"+combatModule.address);
  
  const BattleBoard = await hre.ethers.getContractFactory("BattleBoard");
  const battleBoard = await BattleBoard.deploy(warriors.address, combatModule.address);
  await battleBoard.deployed();
  console.log("BattleBoard deployed @"+battleBoard.address);
  
  const WarriorFactory = await hre.ethers.getContractFactory("WarriorFactory");
  const warriorFactory = await WarriorFactory.deploy(warriors.address, warriorSkills.address, warriorStats.address, warriorVisuals.address, treasury.address);
  await warriorFactory.deployed();
  console.log("Warrior Factory deployed to:", warriorFactory.address);
  
    /**
     * 
     * Deployments done 
     * 
     * */


  console.log("Setting up module access control...");

  //Warrior factory controls mint/burn of storage
  await addModuleAccess(warriors, warriorFactory);
  await addModuleAccess(warriorSkills, warriorFactory);
  await addModuleAccess(warriorStats, warriorFactory);
  await addModuleAccess(warriorVisuals, warriorFactory);
  
  //Factory needs access to Treasury
  await addModuleAccess(treasury, warriorFactory);
 
  //Battle Board starts fights in combat module
  await addModuleAccess(combatModule, battleBoard);
  
  //Combat module changes stats and swaps ep
  await addModuleAccess(treasury, combatModule);
  await addModuleAccess(warriorStats, combatModule);
 
  //Modules are initialized now

  const w1 = await(warriorFactory.mint('Warrior 1',
    {
      value: "1000000000000000000"
    }
  ));
  await w1.wait();
  let exp = await treasury.experience(1);
  expect(exp.toString()).to.equal("1000000000000000000");
  console.log("Minted first Warrior");

  const w2 = await(warriorFactory.mint('Warrior 2',
    {
      value: "1000000000000000000"
    }
  ));
  await w2.wait();
  exp = await treasury.experience(2);
  expect(exp.toString()).to.equal("1000000000000000000");
  console.log("Minted second Warrior");

  const w3 = await(warriorFactory.mint('Warrior 3',
  {
    value: "1000000000000000000"
  }
  ));
  await w3.wait();
  exp = await treasury.experience(3);
  expect(exp.toString()).to.equal("1000000000000000000");
  console.log("Minted third Warrior");

  let battleRequest = await battleBoard.challangeWarrior(1,2);
  await battleRequest.wait();

  let inBattle = await battleBoard.doesBattleRequestExist(1,2);
  expect(inBattle).to.equal(true);

  battleRequest = await battleBoard.challangeWarrior(3,2);
  await battleRequest.wait();

  console.log('Battle was requested');

  const battleAccept = await battleBoard.acceptBattleRequest(2,1);
  await battleAccept.wait();

  let ep = await treasury.experience(1);
  console.log("Ep Warrior 1 " + ep.toString());

  ep = await treasury.experience(2);
  console.log("Ep Warrior 2 " + ep.toString());

  let reserve = await treasury.reserve();
  expect(reserve.toNumber()).to.greaterThan(0);
  console.log("Strategic reserve: " + reserve);

  let noBattleAnymore = await battleBoard.doesBattleRequestExist(1,2);
  expect(noBattleAnymore).to.equal(false);
  console.log("Battle request was cleared");

  battleRequest = await battleBoard.challangeWarrior(1,2);
  await battleRequest.wait();

  battleRequest = await battleBoard.doesBattleRequestExist(1,2);
  expect(battleRequest).to.equal(true);

  console.log("New battle request was submited")

  let battleRequestList = await battleBoard.defensiveRequestOf(2,1,10);
  console.log(battleRequestList);
  expect(battleRequestList[0].toNumber()).to.equal(1);
  expect(battleRequestList[1].toNumber()).to.equal(3);
  
  console.log("Battle Board linked list seems to work");

  let battleDeny = await battleBoard.denyBattleRequest(2,1);
  await battleDeny.wait();

  battleRequest = await battleBoard.doesBattleRequestExist(1,2);
  expect(battleRequest).to.equal(false);

  battleRequestList = await battleBoard.defensiveRequestOf(2,0,10);
  console.log(battleRequestList);
  expect(battleRequestList[0].toNumber()).to.equal(3);

  console.log("Battle request was successfully denied");

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
