// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { expect } = require("chai");
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const MathLib = await hre.ethers.getContractFactory("Math");
  const mathlib = await MathLib.deploy();
  await mathlib.deployed();
  
  const CronosWarriors = await hre.ethers.getContractFactory("CronosWarriors", {
  libraries: {
    Math: mathlib.address,
  },
  });
  
  const warriors = await CronosWarriors.deploy();
  await warriors.deployed();

  console.log("Greeter deployed to:", warriors.address);

  const BattleBoard = await hre.ethers.getContractFactory("BattleBoard");
  const battleBoard = await BattleBoard.deploy(warriors.address);
  await battleBoard.deployed();

  let updateWarriors = await warriors.setBattleBoard(battleBoard.address);
  await updateWarriors.wait();

  const w1 = await(warriors.mint('Warrior 1',
    {
      value: "1000000000000000000"
    }
  ));
  await w1.wait();
  expect(await warriors.warriorLevel(1)).to.equals(1);
  console.log("Minted first Warrior");

  const w2 = await(warriors.mint('Warrior 2',
    {
      value: "1000000000000000000"
    }
  ));
  await w2.wait();
  expect(await warriors.warriorLevel(2)).to.equals(1);
  console.log("Minted second Warrior");

  let battleRequest = await battleBoard.challangeWarrior(1,2);
  await battleRequest.wait();

  console.log('Battle was requested');

  const battleAccept = await battleBoard.acceptBattleRequest(2,1);
  await battleAccept.wait();

  let ep = await warriors.warriorExperience(1);
  console.log("Ep Warrior 1 " + ep.toString());

  ep = await warriors.warriorExperience(2);
  console.log("Ep Warrior 2 " + ep.toString());

  let reserve = await warriors.strategicReserve();
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

  let battleDeny = await battleBoard.denyBattleRequest(2,1);
  await battleDeny.wait();

  battleRequest = await battleBoard.doesBattleRequestExist(1,2);
  expect(battleRequest).to.equal(false);

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
