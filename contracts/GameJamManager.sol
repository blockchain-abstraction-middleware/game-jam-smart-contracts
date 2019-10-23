pragma solidity 0.5.12;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "./GameJam.sol";
import "./interfaces/IRegistry.sol";


contract GameJamManager {
  using Roles for Roles.Role;

  // Define a ContractRegistry to be setup in the Constructor
  IRegistry registry;

  //  Game Jam list so the Ethereum network can return a list of addresses
  address[] private gameJams;

  // Define a mapping to track GameJams using their name with their address
  mapping (bytes32 => address) public gameJamList;

  // Define RBAC List, Modifiers and Checks
  Roles.Role private _gameJamManager;

  event GameJamManagerAdded(address indexed account);
  event GameJamAdded(address indexed gameJamAddress);

  modifier onlyGameJamManager() {
    require(isGameJamManager(msg.sender), "GameJamManager role required: caller does not have the GameJamManager role");
    _;
  }

  // Function to check that the address is a valid Manager
  function isGameJamManager(
    address account
  )
    public
    view
    returns (bool)
  {
    return _gameJamManager.has(account);
  }

  // Return all tracked issuer addresses
  function getAllGameJamAddresses()
    public
    view
    returns (address[] memory)
  {
    return gameJams;
  }

  // Function to add a new manager
  function _addGameJamManager(address account)
   internal
  {
    _gameJamManager.add(account);
    emit GameJamManagerAdded(account);
  }

  constructor(
    address _registryAddress
  )
    public
  {
    require(_registryAddress != address(0));

    registry = IRegistry(_registryAddress);
    _addGameJamManager(msg.sender);
  }

  // createGameJam creates a new GameJam contract
  function createGameJam(
    uint prizeBalance,
    address admin
  )
    private
    returns (address _gameJamAddress)
  {
    return address((new GameJam).value(msg.value)(prizeBalance, admin));
  }

  // creates a new game jam contract and addNewGameJam contract to two lists
  function addNewGameJam(
    bytes32 _name,
    address admin
  )
    external
    payable
    onlyGameJamManager
    returns (bytes32)
  {
    address _gameJamAddress = createGameJam(msg.value, admin);

    gameJamList[_name] = _gameJamAddress;
    gameJams.push(_gameJamAddress);

    emit GameJamAdded(_gameJamAddress);
    return _name;
  }
}