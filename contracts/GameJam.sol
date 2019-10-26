pragma solidity 0.5.12;

import "openzeppelin-solidity/contracts/access/Roles.sol";


contract GameJam {
  using Roles for Roles.Role;

  // Define the roles
  Roles.Role private admins;

  enum Stages
  {
    Registration,
    InProgress,
    Finished
  }

  // Track the balance of the smart contract
  uint public balance;

  // List of addresses for Game Jam competitors
  address[] private competitorAddresses;

  // Set the initial Stage
  Stages public stage = Stages.Registration;

  // winner of the game jam
  address payable winner;

  // Struct for competitor data
  struct CompetitorData {
    string ipfsHash;
    uint votes;
  }

  // mapping for addresses to game locations
  mapping(address => CompetitorData) public competitors;

  event GameJamAdminAdded(address indexed account);
  event CompetitorAdded(address competitor);
  event VoteCast(address competitorVotedFor);
  event GameJameStarted(uint startTime);
  event WinnerDeclared(address winner);
  event GameJamFinished(address winner);

  // Modifier used to restrict access unless a given Stage is active
  modifier onlyAtStage(Stages _stage) {
    require(
      stage == _stage,
      "Function cannot be called at this time."
    );
    _;
  }

  // Create a GameJam with a _balance
  constructor(address admin)
    public
    payable
  {
    balance = msg.value;
    _addGameJamAdmin(admin);
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

  // Return all competitor addresses
  function getAllCompetitorAddresses()
    public
    view
    returns (address[] memory)
  {
    return competitorAddresses;
  }

  // addCompetitor is called when a user registers for a GameJam
  function addCompetitor(
    address competitor,
    string calldata ipfsHash
  )
    external
    onlyGameJamAdmin
    onlyAtStage(Stages.Registration)
  {
    require(bytes(ipfsHash).length != 0, "incorrect length");
    competitorAddresses.push(competitor);

    competitors[competitor].ipfsHash = ipfsHash;
    competitors[competitor].votes = 0;

    emit CompetitorAdded(competitor);
  }

  // start function is called when a game jam is ready to begin
  function start()
    external
    onlyGameJamAdmin
    onlyAtStage(Stages.Registration)
    transitionNext
  {
    emit GameJameStarted(now);
  }

  // vote function is used to vote for competitors
  function vote(address competitor)
    external
    onlyGameJamAdmin
    onlyAtStage(Stages.InProgress)
  {
    require(
      bytes(competitors[competitor].ipfsHash).length != 0,
      "Should be a registered competitor"
    );

    competitors[competitor].votes++;
    emit VoteCast(competitor);
  }

  // finish function is used to declare the winner via their address
  function finish()
    external
    onlyGameJamAdmin
    onlyAtStage(Stages.InProgress)
    transitionNext
  {
    address winningCompetitor = competitorAddresses[0];
    for(uint i = 0; i < competitorAddresses.length; i++) {
      if(competitors[winningCompetitor].votes < competitors[competitorAddresses[i]].votes) {
        winningCompetitor = competitorAddresses[i];
      }
    }

    // Have to do this strange conversion to make `address` => `address payable`
    winner = address(uint(winningCompetitor));

    emit WinnerDeclared(winningCompetitor);
  }

  // payoutWinner is used after the Jam to payout the declared winner
  function payoutWinner()
    external
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