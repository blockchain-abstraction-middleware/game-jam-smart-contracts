pragma solidity 0.5.11;

contract GameJam {
  enum Stages {
        Registration,
        InProgress,
        Finished
    }
  uint public balance;

  //Set the initial Stage
  Stages public stage = Stages.Registration;

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
  event GameJameStarted(uint startTime);
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
    onlyAtStage(Stages.Registration)
  {
    competitors[competitor] = ipfsHash;

    emit CompetitorAdded(competitor);
  }

  // finish function is a payable used to declare the winner via their address
  // the function should only be called able when the GameJam is in Registration
  function start() public payable
    onlyAtStage(Stages.Registration)
    transitionNext {

      emit GameJameStarted(now);
    }

  // finish function is a payable used to declare the winner via their address
  // the function should only be called able when the GameJam is in Progress
  function finish(address winner) public payable
    onlyAtStage(Stages.InProgress)
    transitionNext {


      emit WinnerDeclared(winner);
    }

  // payoutWinner is used after the Jam to payout the declared winner
  // and ultimately finish the GameJam.
  function payoutWinner(address payable winner) public payable
    onlyAtStage(Stages.Finished) {
      emit GameJamFinished(winner);
      // If there are prizes to distribute
      if (balance > 0 && address(this).balance >= balance) {
        //Send the winner their prize and progress the state to Finished Stage
        winner.transfer(balance);
        balance = 0;
      }
  }
}