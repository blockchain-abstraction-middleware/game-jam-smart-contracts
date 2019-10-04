var GameJam = artifacts.require("./GameJam.sol");

module.exports = async (deployer, network) => {
  console.log(`deploying on ${network} network`)

  await deployer.deploy.apply(deployer, [GameJam, 42])

  console.log(`deployed on ${network} network`)
};