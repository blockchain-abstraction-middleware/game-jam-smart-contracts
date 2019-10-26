pragma solidity 0.5.12;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "./GameJamProxy.sol";
import "./interfaces/IGameJam.sol";
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

  // Return all game jam addresses
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
  function createGameJamProxy()
    private
    returns (address _gameJamProxyAddress)
  {
    address gameJamAddress = registry.getContractAddress("GameJam");
    address gameJamProxyAddress = address((new GameJamProxy).value(msg.value)(address(registry), gameJamAddress));
    return gameJamProxyAddress;
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
    address payable _gameJamProxyAddress = address(uint(createGameJamProxy()));

    IGameJam(_gameJamProxyAddress).initializeGameJam(
      admin
    );

    gameJamList[_name] = _gameJamProxyAddress;
    gameJams.push(_gameJamProxyAddress);

    emit GameJamAdded(_gameJamProxyAddress);
    return _name;
  }
}