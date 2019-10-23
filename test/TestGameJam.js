const GameJam = artifacts.require("../contracts/GameJam.sol");

contract('GameJam', (accounts) => {
  const admin = accounts[0];
  const competitor = accounts[1];
  const initialBalance = 20

  var validIpfsHash = "QmPXgPCzbdviCVJTJxvYCWtMuRWCKRfNRVcSpARHDKFSha"

  let gameJam;

  it("balance variable should match the initialBalance passed in constructor", async () => {
    gameJam = await GameJam.new(initialBalance, admin)

    const contractBalance = await gameJam.balance()
    assert.equal(
      contractBalance,
      initialBalance,
      "gameJam balance should match initialBalance"
    )
  });

  it("should allow admin to be a competitor", async () => {
    const stage = await gameJam.stage();
    assert.equal(stage, 0, "Stage should be 0; Registration")
    const competitorAdded = await gameJam.addCompetitor(admin, validIpfsHash)

    assert.equal(
      competitorAdded.logs[0].args.competitor,
      admin,
      "Failed to add competitor"
    )
  });
  
  it("should allow a second competitor to be added", async () => {
    const competitorAdded = await gameJam.addCompetitor(competitor, validIpfsHash)

    assert.equal(
      competitorAdded.logs[0].args.competitor,
      competitor,
      "Failed to add competitor"
    )
  });

  
  it('should allow this contract to start the jam', async () => {
    const jamStarted = await gameJam.start()

    assert.ok(jamStarted.logs[0].args.startTime, "Start time was not entered")
  });

  it('should be In Progress after previous test which started the jam', async () => {
    const stage = await gameJam.stage();
    assert.equal(stage, 1, "Stage should be 1; InProgress")
  });

  it('should allow a new instance of the contract to start the jam with a transaction', async () => {
    const gameJam = await GameJam.new(initialBalance, admin);
    
    const jamStarted = await gameJam.start.sendTransaction({
      from: admin
    })
    assert.ok(jamStarted.logs[0].args.startTime, "Start time was not entered")
  });

  it("should allow a registered competitor to win the competition", async () => {
    const stage = await gameJam.stage();
    assert.equal(stage, 1, "Stage should be 1; InProgress")
    const declaredWinner = await gameJam.finish(competitor)

    assert.equal(
      declaredWinner.logs[0].args.winner,
      competitor,
      "Failed to declare winner"
    )
  });
});