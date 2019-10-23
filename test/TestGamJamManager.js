const ContractRegistry = artifacts.require("../contracts/ContractRegistry.sol");
const GameJamManager = artifacts.require("../contracts/GameJamManager.sol");
const GameJam = artifacts.require("../contracts/GameJam.sol");

const { testWillThrow } =  require('./utils/helpers')

contract('GameJamManager', (accounts) => {
  const admin = accounts[0];
  const gameJamHost = accounts[1];

  const bytes32GMTK = '0x474d544b000000000000000000000000'

  let contractRegistry;
  let gameJamManager;

  beforeEach("instantiates a new game jam manager smart contract", async () => {
    contractRegistry = await ContractRegistry.new()
    gameJamManager = await GameJamManager.new(contractRegistry.address)
  });

  it("should create a new game jam contract", async () => {
    const gameJam = await gameJamManager.addNewGameJam(
      bytes32GMTK,
      gameJamHost,
      { from : admin, value: 100000 }
    )

    const GMTKGameJam = await gameJamManager.gameJamList(bytes32GMTK)

    assert.equal(
      GMTKGameJam, 
      gameJam.logs[0].args.gameJamAddress, 
      "Incorrect game jam created"
    )

    const newGameJamContract = await GameJam.at(gameJam.logs[0].args.gameJamAddress)
    const balanceVar = await newGameJamContract.balance()
    const balanceContract = await web3.eth.getBalance(gameJam.logs[0].args.gameJamAddress)

    assert.equal(
      balanceVar.words[0],
      balanceContract,
      "Incorrect balance stored in contract"
    )

    await testWillThrow(
      newGameJamContract.start,
      [],
      { from: admin },
      "GameJamAdmin role required: caller does not have the GameJamAdmin role"
    )
  });
});