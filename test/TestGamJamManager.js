const ContractRegistry = artifacts.require("../contracts/ContractRegistry.sol");
const GameJamManager = artifacts.require("../contracts/GameJamManager.sol");
const GameJam = artifacts.require("../contracts/GameJam.sol");
const IGameJam = artifacts.require("../interfaces/IGameJam.sol");

const { testWillThrow } =  require('./utils/helpers')

contract('GameJamManager', (accounts) => {
  const admin = accounts[0];
  const gameJamHost = accounts[1];
  const pleb = accounts[2]

  const initialValue = 100000
  const bytes32GMTK = '0x474d544b000000000000000000000000'

  let contractRegistry;
  let gameJam;
  let gameJamManager;

  before("instantiates a new game jam manager smart contract", async () => {
    contractRegistry = await ContractRegistry.new()
    gameJam = await GameJam.new()
    contractRegistry.updateContractAddress('GameJam', gameJam.address)
    gameJamManager = await GameJamManager.new(contractRegistry.address)
  });

  it("should create a new game jam contract", async () => {
    const gameJam = await gameJamManager.addNewGameJam(
      bytes32GMTK,
      gameJamHost,
      { from : admin, value: initialValue }
    )

    const GMTKGameJamAddress = await gameJamManager.gameJamList(bytes32GMTK)

    assert.equal(
      GMTKGameJamAddress, 
      gameJam.logs[0].args.gameJamAddress, 
      "Incorrect game jam created"
    )

    const newGameJamContract = await IGameJam.at(gameJam.logs[0].args.gameJamAddress)
    const balanceContract = await web3.eth.getBalance(gameJam.logs[0].args.gameJamAddress)

    assert.equal(
      initialValue,
      balanceContract,
      "Incorrect balance stored in contract"
    )

    await testWillThrow(
      newGameJamContract.start,
      [],
      { from: pleb },
      "Error: Returned error: VM Exception while processing transaction: revert"
    )
  });
});