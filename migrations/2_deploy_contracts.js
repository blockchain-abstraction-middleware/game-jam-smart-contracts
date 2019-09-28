var GameJam = artifacts.require("./GameJam.sol");

module.exports = async (deployer, network) => {
  console.log(`deploying on ${network} network`)

  deployer.deploy(GameJam);

  console.log(`deployed on ${network} network`)
};