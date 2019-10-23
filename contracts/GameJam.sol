pragma solidity 0.5.12;

import "openzeppelin-solidity/contracts/access/Roles.sol";


contract GameJam {
  using Roles for Roles.Role;

  enum Stages
  {
    Registration,
    InProgress,
    Finished
  }

  uint public balance;

  // Set the initial Stage
  Stages public stage = Stages.Registration;

  // Define the roles
  Roles.Role private admins;

  // Modifier used to restrict access unless a given Stage is active
  modifier onlyAtStage(Stages _stage) {
    require(
      stage == _stage,
      "Function cannot be called at this time."
    );
    _;
  }

  // Advance the state of the contract to the next stage
  function nextStage()
    internal
  {
    stage = Stages(uint(stage) + 1);
  }

  // This modifier moves to the next stage
  modifier transitionNext()
  {
    _;
    nextStage();
  }

  // On Deploy, the sender of the transaction will be added as a admin
  modifier onlyGameJamAdmin()
  {
    require(isGameJamAdmin(msg.sender), "GameJamAdmin role required: caller does not have the GameJamAdmin role");
    _;
  }

  // Function to check that the address is a valid admin
  function isGameJamAdmin(address account)
    public
    view
    returns (bool)
  {
    return admins.has(account);
  }

  function _addGameJamAdmin(address account)
    internal
  {
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
  constructor(uint _balance, address admin)
    public
    payable
  {
    balance = _balance;
    _addGameJamAdmin(admin);
  }

  function addCompetitor(
    address competitor,
    string calldata ipfsHash
  )
    external
    onlyAtStage(Stages.Registration)
  {
    require(bytes(ipfsHash).length == 46, "incorrect length");
    competitors[competitor] = ipfsHash;

    emit CompetitorAdded(competitor);
  }

  // start function is called when a game jam is ready to begin
  function start() external payable
    onlyGameJamAdmin
    onlyAtStage(Stages.Registration)
    transitionNext
  {
    emit GameJameStarted(now);
  }

  // finish function is a payable used to declare the winner via their address
  function finish(address winner)
    external
    payable
    onlyGameJamAdmin
    onlyAtStage(Stages.InProgress)
    transitionNext
  {
    require(
      bytes(competitors[winner]).length != 0,
      "Winner should be a registered competitor"
    );
    emit WinnerDeclared(winner);
  }

  // payoutWinner is used after the Jam to payout the declared winner
  function payoutWinner(address payable winner)
    external
    payable
    onlyGameJamAdmin
    onlyAtStage(Stages.Finished)
  {
    if (balance > 0 && address(this).balance >= balance) {
      winner.transfer(balance);
      balance = 0;
      emit GameJamFinished(winner);
    }
  }
}