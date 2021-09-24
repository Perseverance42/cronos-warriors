# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Running scripts without persistense:

1. change 'defaultNetwork' in 'hardhat.config.js' to 'hardhat'
```shell
npx hardhat compile
node scripts/sample-script.js
```

Run deploying script with persistense for frontend:

change 'defaultNetwork' in 'hardhat.config.js' to 'devnode'
```shell
npx hardhat node
```
```shell
npx hardhat compile
node scripts/sample-script.js
```
