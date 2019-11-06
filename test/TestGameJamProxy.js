const ContractRegistry = artifacts.require("../contracts/ContractRegistry.sol");
const GameJam = artifacts.require("../contracts/GameJam.sol");
const GameJamProxy = artifacts.require("../contracts/GameJam.sol");

const { testWillThrow } =  require('./utils/helpers')

contract('GameJamProxy', (accounts) => {
  const admin = accounts[0]
  const gameJamHost = accounts[0]
  const competitor = accounts[1]
  const competitor2 = accounts[2]
  const competitor3 = accounts[3]

  const initialBalance = 100000
  const validIpfsHash = 'QmPXgPCzbdviCVJTJxvYCWtMuRWCKRfNRVcSpARHDKFSha'

  let contractRegistry
  let gameJam
  let gameJamProxy


  describe('it should test a full round trip using a Proxied GameJam contract', async () => {
    it("instantiates a new game jam proxy smart contract", async () => {
      contractRegistry = await ContractRegistry.new()
      gameJam = await GameJam.new()
      gameJamProxy = await GameJamProxy.new(contractRegistry.address, gameJam.address)
    });
  
    it("should be able to proxy the addCompetitor call to the GameJam Contract", async () => {
      await gameJamProxy.initializeGameJam(gameJamHost, {from: admin, value: initialBalance})
  
      
  
      const competitorAdded = await gameJamProxy.addCompetitor(competitor, validIpfsHash, { from: gameJamHost })
      assert.equal(
        competitorAdded.logs[0].args.competitor,
        competitor,
        'Failed to add competitor'
      )
  
      await gameJamProxy.addCompetitor(competitor2, validIpfsHash, { from: gameJamHost })
      await gameJamProxy.addCompetitor(competitor3, validIpfsHash, { from: gameJamHost })

      await testWillThrow(
        gameJamProxy.addCompetitor,
        [competitor2, validIpfsHash],
        { from: competitor },
        "Error: Returned error: VM Exception while processing transaction: revert"
      )
    });

    it("should be able to proxy the start call to the GameJam Contract", async () => {  
      await gameJamProxy.stage()
      const jamStarted = await gameJamProxy.start({ from: gameJamHost })
  
      assert.ok(jamStarted.logs[0].args.startTime, 'Start time was not entered')
    });

    it("should be able to proxy the vote call to the GameJam Contract", async () => {  
      const voteTx = await gameJamProxy.vote(competitor, { from: gameJamHost })

      assert.equal(
        voteTx.logs[0].args.competitorVotedFor,
        competitor,
        'Failed to vote'
      )

      await gameJamProxy.vote(competitor, { from: gameJamHost })
      await gameJamProxy.vote(competitor, { from: gameJamHost })
      await gameJamProxy.vote(competitor2, { from: gameJamHost })
      await gameJamProxy.vote(competitor2, { from: gameJamHost })
      await gameJamProxy.vote(competitor3, { from: gameJamHost })
      await gameJamProxy.vote(competitor3, { from: gameJamHost })

      await testWillThrow(
        gameJamProxy.vote,
        [competitor],
        { from: competitor },
        "Error: Returned error: VM Exception while processing transaction: revert"
      )
    });

    it("should be able to proxy the finish call to the GameJam Contract", async () => {  
      const finishTx = await gameJamProxy.finish({ from: gameJamHost })

      assert.equal(
        finishTx.logs[0].args.winners[0],
        competitor,
        'Failed to declare correct winner'
      )
    });

    it("should be able to proxy the payoutWinner call to the GameJam Contract", async () => {
      await testWillThrow(
        gameJamProxy.payoutWinner,
        [],
        { from: competitor },
        "Error: Returned error: VM Exception while processing transaction: revert"
      )

      const balanceBeforePayout = await web3.eth.getBalance(competitor)

      await gameJamProxy.payoutWinner({ from: gameJamHost })
  
      const balanceAfterPayout = await web3.eth.getBalance(competitor)
  
      assert.equal(balanceAfterPayout > balanceBeforePayout, true, "Winner was not transfered ETH")
    });
  })
});