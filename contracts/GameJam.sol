pragma solidity 0.5.11;

import "openzeppelin-solidity/contracts/access/Roles.sol";  //Import Roles to implement custom Role Based Access Control

contract GameJam {
  using Roles for Roles.Role;

  enum Stages {
        Registration,
        InProgress,
        Finished
    }
  uint public balance;
  

  //Set the initial Stage
  Stages public stage = Stages.Registration;

  //Define the roles
  Roles.Role private admins;

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

  //Role Setup
  // On Deploy, the sender of the transaction will be added as a admin
  // Further admins could be added with a Role restricted _addGameJamAdmin() function
  //Modifier for Admins
  modifier onlyGameJamAdmin() {
      require(isGameJamAdmin(msg.sender), "GameJamAdmin role required: caller does not have the GameJamAdmin role");
      _;
  }
  // Function to check that the address is a valid admin
  function isGameJamAdmin(address account) public view returns (bool) {
        return admins.has(account);
  }
  function _addGameJamAdmin(address account) internal {
    admins.add(account);
    emit GameJamAdminAdded(account);
  }

  mapping(address => string) public competitors;

  event GameJamAdminAdded(address indexed account);
  event CompetitorAdded(address competitor);
  event GameJameStarted(uint startTime);
  event WinnerDeclared(address winner);
  event GameJamFinished(address winner);

  // Create a GameJam with a _balance
  // which will be the amount to be distributed to winners
  constructor(uint _balance) public payable {
    balance = _balance;
    _addGameJamAdmin(msg.sender);
  }

  function addCompetitor(
    address competitor,
    string memory ipfsHash
  )
    public
    onlyAtStage(Stages.Registration)
  {
    require(bytes(ipfsHash).length == 46, "incorrect length");
    competitors[competitor] = ipfsHash;

    emit CompetitorAdded(competitor);
  }

  // finish function is a payable used to declare the winner via their address
  // the function should only be called able when the GameJam is in Registration
  function start() public payable
    onlyGameJamAdmin //Only an admin can start the GameJam
    onlyAtStage(Stages.Registration) //GameJam can only be start when in Registration State
    transitionNext {
      emit GameJameStarted(now);
    }

  // finish function is a payable used to declare the winner via their address
  // the function should only be called able when the GameJam is in Progress
  function finish(address winner) public payable
    onlyGameJamAdmin //Only an admin can finish the GameJam
    onlyAtStage(Stages.InProgress)
    transitionNext {
      //Ensure the winner is a registered competitor. The mapping result is initialised "" so if winner is not in competitors then 0x0 is returned
      require(
        bytes(competitors[winner]).length != 0,
        "Winner should be a registered competitor"
        );
      emit WinnerDeclared(winner);
    }

  // payoutWinner is used after the Jam to payout the declared winner
  // and ultimately finish the GameJam.
  function payoutWinner(address payable winner) public payable
    onlyGameJamAdmin //Only an admin can start the GameJam
    onlyAtStage(Stages.Finished) {
      
      // If there are prizes to distribute
      if (balance > 0 && address(this).balance >= balance) {
        //Send the winner their prize and progress the state to Finished Stage
        winner.transfer(balance);
        balance = 0;
        emit GameJamFinished(winner);
      }
  }
}