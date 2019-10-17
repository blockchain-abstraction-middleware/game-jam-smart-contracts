var GameJam = artifacts.require("./GameJam.sol");
var GameJamManager = artifacts.require("./GameJamManager.sol");
var ContractRegistry = artifacts.require("./ContractRegistry.sol");


module.exports = async (deployer, network) => {
  console.log(`deploying on ${network} network`)

  const initialBalance = 1
  await deployer.deploy.apply(deployer, [GameJam, initialBalance])
  await deployer.deploy.apply(deployer, [ContractRegistry])

  const contractRegistry = await ContractRegistry.deployed()
  const gameJamContract = await GameJam.deployed()

  await deployer.deploy.apply(deployer, [GameJamManager , contractRegistry.address])

  const gameJamManager = await GameJamManager.deployed()

  console.log(`deployed on ${network} network`)
  console.log(`GameJamManagers address: ${gameJamManager.address}`)
};