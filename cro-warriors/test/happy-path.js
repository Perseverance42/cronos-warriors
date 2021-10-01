const { expect } = require("chai");
const { ethers } = require("hardhat");
const {BigNumber} = require("ethers");


let mathLib, computeLib, visualsLib, skillsLib, statsLib;
let cronosWariors, treasury, warriorFactory, warriorSkills, warriorStats, warriorVisuals, combatModule, battleBoard;

let warriorsMinted = [];



describe("Lib Deployment", function () {
  it("Should return all required libraries", async function () {
    const MathLib = await hre.ethers.getContractFactory("Math");
    mathLib = await MathLib.deploy();
    await mathLib.deployed();

    expect(await mathLib.secMinus(100,1000)).to.equal(0);

    const ComputeLib = await hre.ethers.getContractFactory("Compute",{
      libraries:{ Math: mathLib.address}
    });
    computeLib = await ComputeLib.deploy();
    await computeLib.deployed();

    expect(await computeLib.warriorLevel(1000)).to.equal(1);

    const VisualsLib = await hre.ethers.getContractFactory("VisualsLib");
    visualsLib = await VisualsLib.deploy();
    await visualsLib.deployed();
    
    const SkillsLib = await hre.ethers.getContractFactory("SkillsLib");
    skillsLib = await SkillsLib.deploy();
    await skillsLib.deployed();
    
    const StatsLib = await hre.ethers.getContractFactory("StatsLib");
    statsLib = await StatsLib.deploy();
    await statsLib.deployed();

    console.log("Libs deployed!")
  });
});

describe("Contract Deployment", function () {
  it("Should return all required Contracts in a non initialized state", async function () {
    const CronosWarriors = await hre.ethers.getContractFactory("CronosWarriors");
  
    cronosWariors = await CronosWarriors.deploy();
    await cronosWariors.deployed();
    console.log("Cronos Warriors deployed to: ", cronosWariors.address);

    

    const WarriorVisuals = await hre.ethers.getContractFactory("WarriorVisuals", {
      libraries: {
        VisualsLib: visualsLib.address
      }
    });
    warriorVisuals = await WarriorVisuals.deploy();
    await warriorVisuals.deployed();
    console.log("Warrior Visuals deployed to: ", warriorVisuals.address);

    const WarriorStats = await hre.ethers.getContractFactory("WarriorStats", {
      libraries: {
        StatsLib: statsLib.address
      }
    });
    warriorStats = await WarriorStats.deploy();
    await warriorStats.deployed();
    console.log("Warrior Stats deployed to: ", warriorStats.address);

    const Treasury = await hre.ethers.getContractFactory("Treasury", {
      libraries: {
        Math: mathLib.address,
        Compute: computeLib.address
      },
    });
    treasury = await Treasury.deploy();
    await treasury.deployed();
    console.log("Treasury deployed at: "+treasury.address);

    const WarriorSkills = await hre.ethers.getContractFactory("WarriorSkills", {
      libraries: {
        Math: mathLib.address,
        SkillsLib: skillsLib.address,
        Compute: computeLib.address
      },
    });
    warriorSkills = await WarriorSkills.deploy( cronosWariors.address, treasury.address );
    await warriorSkills.deployed();
    console.log("Warrior Skills deployed at: "+warriorSkills.address);

    const CombatModule = await hre.ethers.getContractFactory("CombatModule", {
      libraries: {
        Math: mathLib.address,
        Compute: computeLib.address  
      },
    });
    combatModule = await CombatModule.deploy(warriorSkills.address, warriorStats.address, treasury.address);
    await combatModule.deployed();
    console.log("Combat Module deployed to: "+combatModule.address);

    const BattleBoard = await hre.ethers.getContractFactory("BattleBoard");
    battleBoard = await BattleBoard.deploy(cronosWariors.address, combatModule.address);
    await battleBoard.deployed();
    console.log("BattleBoard deployed to: "+battleBoard.address);

    const WarriorFactory = await hre.ethers.getContractFactory("WarriorFactory");
    warriorFactory = await WarriorFactory.deploy(cronosWariors.address, warriorSkills.address, warriorStats.address, warriorVisuals.address, treasury.address);
    await warriorFactory.deployed();
    console.log("Warrior Factory deployed to: ", warriorFactory.address);


  });
});

/*
describe("Access control basic negative test", function () {
  it("All requests should be denied", async function () {
    // Minting
    let request = cronosWariors.mint(0);
    await expect(request).to.be.reverted;

    request = treasury.mint(0);
    await expect(request).to.be.reverted;

    request = warriorSkills.mint(0);
    await expect(request).to.be.reverted;

    request = warriorStats.mint(0);
    await expect(request).to.be.reverted;

    request = warriorVisuals.mint(0);
    await expect(request).to.be.reverted;

    request = warriorStats.mint(0);
    await expect(request).to.be.reverted;

    // Burning

    request = cronosWariors.burn(0);
    await expect(request).to.be.reverted;

    request = treasury.withdrawExperience(0, 1);
    await expect(request).to.be.reverted;

    request = warriorSkills.burn(0);
    await expect(request).to.be.reverted;

    request = warriorStats.burn(0);
    await expect(request).to.be.reverted;

    request = warriorVisuals.burn(0);
    await expect(request).to.be.reverted;

    request = warriorStats.burn(0);
    await expect(request).to.be.reverted;

    //Fighting

    combatModule.fight(0,1);
    await expect(request).to.be.reverted;
  });
});
*/
async function addModuleAccess(modular, module, role){
  let grantRole = await modular.grantRole(role, module.address);
  await grantRole.wait();
  console.log(modular.address + " can now be accessed by " + module.address);
}

describe("Init access control", function () {
  it("Should init access control on all contracts", async function () {
    //Warrior factory controls mint/burn of storage
    await addModuleAccess(cronosWariors, warriorFactory, "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6");

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
    
  });
});

describe("Mint two Warriors", function () {
  it("Should mint two warriors", async function () {
    let w1 = await(warriorFactory.mint('Warrior 1',
    {
      value: "1000000000000000000"
    }
    ));
    await w1.wait();

    let exp = await treasury.experience(1);
    expect(exp.toString()).to.equal("1000000000000000000");
    let name = await warriorVisuals.warriorName(1);
    expect(name).to.equal("Warrior 1");
    let skills = await warriorSkills.warriorSkills(1);
    expect(skills).to.eql([BigNumber.from(0) ,BigNumber.from(1),BigNumber.from(1),BigNumber.from(1)]);
    let stats = await warriorStats.warriorStats(1);
    expect(stats).to.eql([BigNumber.from(0) ,BigNumber.from(0)]);
    let owner = await cronosWariors.ownerOf(1);
    expect(owner).to.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');

    warriorsMinted.push(w1);

    w1 = await(warriorFactory.mint('Warrior 2',
    {
      value: "1000000000000000000"
    }
    ));
    await w1.wait();

    exp = await treasury.experience(2);
    expect(exp.toString()).to.equal("1000000000000000000");
    name = await warriorVisuals.warriorName(2);
    expect(name).to.equal("Warrior 2");
    skills = await warriorSkills.warriorSkills(2);
    expect(skills).to.eql([BigNumber.from(0) ,BigNumber.from(1),BigNumber.from(1),BigNumber.from(1)]);
    stats = await warriorStats.warriorStats(2);
    expect(stats).to.eql([BigNumber.from(0) ,BigNumber.from(0)]);
    owner = await cronosWariors.ownerOf(2);
    expect(owner).to.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');

    warriorsMinted.push(w1);
  });
});