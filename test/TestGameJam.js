const GameJam = artifacts.require("../contracts/GameJam.sol");

contract('GameJam', (accounts) => {
  const admin = accounts[0];
  const competitor = accounts[1];

  var validIpfsHash = "QmPXgPCzbdviCVJTJxvYCWtMuRWCKRfNRVcSpARHDKFSha"

  let gameJam

  beforeEach(async () => {
    gameJam = await GameJam.new()
  })

  it("whitelisted admin votes on a ballot", async () => {
    const competitorAdded = await gameJam.addCompetitor(admin, validIpfsHash)

    assert.equal(competitorAdded.logs[0].args.competitor, admin, "Failed to add competitor")
  });
});