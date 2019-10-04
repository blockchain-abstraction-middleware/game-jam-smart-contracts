const GameJam = artifacts.require("../contracts/GameJam.sol");

contract('GameJam', (accounts) => {
  const admin = accounts[0];
  const competitor = accounts[1];
  const initialBalance = 20

  var validIpfsHash = "QmPXgPCzbdviCVJTJxvYCWtMuRWCKRfNRVcSpARHDKFSha"

  let gameJam

  beforeEach(async () => {
    gameJam = await GameJam.new(initialBalance)
  })

  it("whitelisted admin votes on a ballot", async () => {
    const competitorAdded = await gameJam.addCompetitor(admin, validIpfsHash)

    assert.equal(competitorAdded.logs[0].args.competitor, admin, "Failed to add competitor")
  });

  it("balance variable should match the initialBalance passed in constructor", async () => {
    const contractBalance = await gameJam.getContractBalance()
    assert.equal(contractBalance, initialBalance, "gameJam balance should match initialBalance")
  });

  
});