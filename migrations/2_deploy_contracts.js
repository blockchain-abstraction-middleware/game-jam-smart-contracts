var GameJam = artifacts.require("./GameJam.sol");

module.exports = async (deployer, network) => {
  console.log(`deploying on ${network} network`)

  const initialBalance = 1
  await deployer.deploy.apply(deployer, [GameJam, initialBalance])
  console.log(`deployed on ${network} network`)
};