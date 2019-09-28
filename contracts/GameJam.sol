pragma solidity 0.5.11;

contract GameJam {
  mapping(address => string) public competitors;

  event CompetitorAdded(address competitor);

  function addCompetitor(
    address competitor,
    string memory ipfsHash
  )
    public
  {
    competitors[competitor] = ipfsHash;

    emit CompetitorAdded(competitor);
  }
}