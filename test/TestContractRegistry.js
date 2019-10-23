const ContractRegistry = artifacts.require("../contracts/ContractRegistry.sol");
const GameJam = artifacts.require("../contracts/GameJam.sol");

const { testWillThrow } =  require('./utils/helpers')

contract('ContractRegistry', (accounts) => {
  const admin = accounts[0];
  const pleb = accounts[1];

  let contractRegistry;
  let gameJam;

  it("instantiates a new contract registry smart contract", async () => {
    contractRegistry = await ContractRegistry.new()
    gameJam = await GameJam.new(0, admin)
  });

  it("should allow admin to register a contract", async () => {
    const register =  await contractRegistry.updateContractAddress("GameJam", gameJam.address)

    assert.equal(
      register.logs[0].args.name,
      "GameJam",
      "Incorrect contract name stored"
    )
    assert.equal(
      register.logs[0].args.contractAddress,
      gameJam.address,
      "Incorrect contract address stored"
    )
  });

  it("should allow admin to be a competitor", async () => {
    await testWillThrow(
      contractRegistry.updateContractAddress,
      ["GameJam", admin],
      { from: pleb },
      "Admin role required"
    )
  });

  it("a pleb user should get a contract address", async () => {
    const address = await contractRegistry.getContractAddress("GameJam", { from: pleb })

    assert.equal(
      address,
      gameJam.address,
      "Incorrect contract address stored"
    )
  });
});