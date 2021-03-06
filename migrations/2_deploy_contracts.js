var GameJam = artifacts.require("./GameJam.sol");
var GameJamManager = artifacts.require("./GameJamManager.sol");
var ContractRegistry = artifacts.require("./ContractRegistry.sol");


module.exports = async (deployer, network) => {
  console.log(`Deploying on ${network} network`)
  const [admin] = await web3.eth.getAccounts();
  
  await deployer.deploy.apply(deployer, [ContractRegistry])
  const contractRegistry = await ContractRegistry.deployed()
  console.log(`Contract Registry Contract address: ${contractRegistry.address}`)

  await deployer.deploy.apply(deployer, [GameJam, admin])
  const gameJamContract = await GameJam.deployed()
  console.log(`Game Jam Contract address: ${gameJamContract.address}`)

  await deployer.deploy.apply(deployer, [GameJamManager , contractRegistry.address])
  const gameJamManager = await GameJamManager.deployed()
  console.log(`Game Jam Manager Contract address: ${gameJamManager.address}`)

  contractRegistry.updateContractAddress('GameJamManager', gameJamManager.address)
  contractRegistry.updateContractAddress('GameJam', gameJamContract.address)

  console.log(`Updated contract manager to contain contracts`)

  console.log(`Finished deployment on ${network} network`)
};