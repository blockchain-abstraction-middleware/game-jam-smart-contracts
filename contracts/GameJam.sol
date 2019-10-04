pragma solidity 0.5.11;

contract GameJam {
  uint public balance;

  mapping(address => string) public competitors;

  event CompetitorAdded(address competitor);

  // Create a GameJam with a _balance
  // which will be the amount to be distributed to winners
  constructor(uint _balance) public {
    balance = _balance;
  }

  function addCompetitor(
    address competitor,
    string memory ipfsHash
  )
    public
  {
    competitors[competitor] = ipfsHash;

    emit CompetitorAdded(competitor);
  }

  // Getter for the balance variable
  function getContractBalance() public view returns(uint) {
		return balance;
	}
}