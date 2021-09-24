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
  const CronosWarriors = await hre.ethers.getContractFactory("CronosWarriors");
  const warriors = await CronosWarriors.deploy();

  await warriors.deployed();

  console.log("Greeter deployed to:", warriors.address);

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

  const fight = await warriors.fight(1,2);
  await fight.wait();
  expect(await warriors.warriorLevel(2)).to.equals(2);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
