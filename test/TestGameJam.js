const GameJam = artifacts.require('../contracts/GameJam.sol');

const { testWillThrow } =  require('./utils/helpers')

contract('GameJam', (accounts) => {
  const admin = accounts[0];
  const competitor = accounts[1];
  const pleb = accounts[2];
  const initialBalance = 100000

  var validIpfsHash = 'QmPXgPCzbdviCVJTJxvYCWtMuRWCKRfNRVcSpARHDKFSha'

  let gameJam;

  describe('it should test a full round trip using one GameJam contract', async () => {
    before(async() => {
      gameJam = await GameJam.new(admin, { from: admin, value: initialBalance })
    })

    it('balance variable should match the initialBalance passed in constructor', async () => {
      const contractBalance = await gameJam.balance()
      assert.equal(
        contractBalance,
        initialBalance,
        'gameJam balance should match initialBalance'
      )
    });
  
    it('should allow admin to be a competitor', async () => {
      const stage = await gameJam.stage();
      assert.equal(stage, 0, 'Stage should be 0; Registration')
      const competitorAdded = await gameJam.addCompetitor(admin, validIpfsHash)
  
      assert.equal(
        competitorAdded.logs[0].args.competitor,
        admin,
        'Failed to add competitor'
      )
    });
    
    it('should allow a second competitor to be added', async () => {
      const competitorAdded = await gameJam.addCompetitor(competitor, validIpfsHash)
  
      assert.equal(
        competitorAdded.logs[0].args.competitor,
        competitor,
        'Failed to add competitor'
      )
    });
  
    it('should not allow a pleb to add a competitor', async () => {
      await testWillThrow(
        gameJam.addCompetitor,
        [competitor, validIpfsHash],
        { from: pleb },
        'GameJamAdmin role required: caller does not have the GameJamAdmin role'
      )
    });
    
    it('should allow this contract to start the jam', async () => {
      const jamStarted = await gameJam.start()
  
      assert.ok(jamStarted.logs[0].args.startTime, 'Start time was not entered')
    });
  
    it('should be In Progress after previous test which started the jam', async () => {
      const stage = await gameJam.stage();
      assert.equal(stage, 1, 'Stage should be 1; InProgress')
    });
  
    it('should allow a new instance of the contract to start the jam with a transaction', async () => {
      const gameJam = await GameJam.new(admin);
      
      const jamStarted = await gameJam.start.sendTransaction({
        from: admin
      })
      assert.ok(jamStarted.logs[0].args.startTime, 'Start time was not entered')
    });
  
    it('should allow have two registered competitors', async () => {
      const competitorAddresses = await gameJam.getAllCompetitorAddresses()
  
      assert.equal(
        competitorAddresses.length,
        2,
        'Failed get all competitors'
      )
    });
  
    it('should allow a registered competitor recieve a vote', async () => {
      const voteTx = await gameJam.vote(competitor)
  
      assert.equal(
        voteTx.logs[0].args.competitorVotedFor,
        competitor,
        'Failed to vote'
      )
    });

    it('should throw as competitor is not registered', async () => {
      await testWillThrow(
        gameJam.vote,
        [pleb],
        { from: admin },
        'Should be a registered competitor'
      )
    });
  
    it('should allow a registered competitor to win the competition', async () => {
      const stage = await gameJam.stage();
      assert.equal(stage, 1, 'Stage should be 1; InProgress')

      const finishTx = await gameJam.finish()
  
      assert.equal(
        finishTx.logs[0].args.winner,
        competitor,
        'Failed to declare correct winner'
      )

      const finalStage = await gameJam.stage();
      assert.equal(finalStage, 2, 'Stage should be 2; Finished')
    });

    it('should payout the correct winner', async () => {
      const balanceBeforePayout = await web3.eth.getBalance(competitor)
      const payoutWinnerTx = await gameJam.payoutWinner();

      assert.equal(
        payoutWinnerTx.logs[0].args.winner,
        competitor,
        'Failed to pay correct winner'
      )

      const balanceAfterPayout = await web3.eth.getBalance(competitor)
      assert.equal(balanceAfterPayout > balanceBeforePayout, true, "Winner was not transfered ETH")
    });
  })
});