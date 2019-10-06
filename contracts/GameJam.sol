pragma solidity 0.5.11;

contract GameJam {
  enum Stages {
        JamInProgress,
        WinnerDeclaration,
        Finished
    }
  uint public balance;

  //Set the initial Stage
  Stages public stage = Stages.JamInProgress;

  // Modifier used to restrict access unless a given Stage is active
  modifier onlyAtStage(Stages _stage) {
      require(
          stage == _stage,
          "Function cannot be called at this time."
      );
      _;
  }
  //Advance the state of the contract to the next stage
  function nextStage() internal {
      stage = Stages(uint(stage) + 1);
  }

  // This modifier moves to the next stage
  // after the function is done.
  modifier transitionNext()
  {
      _;
      nextStage();
  }

  mapping(address => string) public competitors;

  event CompetitorAdded(address competitor);
  event WinnerDeclared(address winner);
  event GameJamFinished(address winner);

  // Create a GameJam with a _balance
  // which will be the amount to be distributed to winners
  constructor(uint _balance) public payable {
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
  // finish function is a payable used to declare the winner via their address
  // the function should only be called able when the GameJam is in Progress
  // otherwise, it would be possible to finish again and again
  function finish(address winner) public payable
    onlyAtStage(Stages.JamInProgress)
    transitionNext {


      emit WinnerDeclared(winner);
    }

  // payoutWinner is used after the Jam to payout the declared winner
  // and ultimately finish the GameJam.
  function payoutWinner(address payable winner) public payable
    onlyAtStage(Stages.WinnerDeclaration)
    transitionNext {
      // If there are prizes to distribute
      if (balance > 0) {
        //Send the winner their prize and progress the state to Finished Stage
        address(winner).transfer(balance);
      }
  }
}