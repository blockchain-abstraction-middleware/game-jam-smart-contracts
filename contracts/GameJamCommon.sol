pragma solidity 0.5.12;

import "openzeppelin-solidity/contracts/access/Roles.sol";


contract GameJamCommon {
  using Roles for Roles.Role;

  enum Stages
  {
    Registration,
    InProgress,
    Finished
  }

  // Define the roles
  Roles.Role internal admins;

  // Track the balance of the smart contract
  uint public balance;

  // List of addresses for Game Jam competitors
  address[] internal competitorAddresses;

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

  // On Deploy, the sender of the transaction will be added as a admin
  modifier onlyGameJamAdmin()
  {
    require(isGameJamAdmin(msg.sender), "GameJamAdmin role required: caller does not have the GameJamAdmin role");
    _;
  }

  // Modifier used to restrict access unless a given Stage is active
  modifier onlyAtStage(Stages _stage) {
    require(
      stage == _stage,
      "Function cannot be called at this time."
    );
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
}