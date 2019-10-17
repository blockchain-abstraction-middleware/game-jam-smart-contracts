pragma solidity ^0.5.11;

import "openzeppelin-solidity/contracts/access/Roles.sol";  //Import Roles to implement custom Role Based Access Control


import "./GameJam.sol";
import "./interfaces/IRegistry.sol";


contract GameJamManager {
    using Roles for Roles.Role;

    // Define a ContractRegistry to be setup in the Constructor
    IRegistry registry;
    // Define a mapping to track GameJams using their name with their address
    mapping (bytes32 => address) public gameJamList;

    // Define RBAC List, Modifiers and Checks
    Roles.Role private _gameJamManager;
    // On Deploy, the sender of the transaction will be added as a Manager
    // Further Managers could be added with a Role restricted _addGameJamManager() function
    //Modifier for Managers
    modifier onlyGameJamManager() {
        require(isGameJamManager(msg.sender), "GameJamManager role required: caller does not have the GameJamManager role");
        _;
    }

    // Function to check that the address is a valid Manager
    function isGameJamManager(address account) public view returns (bool) {
        return _gameJamManager.has(account);
    }

    // Function to add a new manager
    function _addGameJamManager(address account) internal {
        _gameJamManager.add(account);
        emit GameJamManagerAdded(account);
    }

    event GameJamManagerAdded(address indexed account);
    event GameJamAdded(bytes32 _name);

    constructor(address _registryAddress)
    public
    {
        //Ensure the null address hasn't been given.
        require(_registryAddress != address(0));
        //Setup the ContractRegistry
        registry = IRegistry(_registryAddress);
        //Setup the creator of this contract as the first Manager
        _addGameJamManager(msg.sender);
    }

    //Function to create a new GameJam contract
    function createGameJam(uint prizeBalance)
    private
    onlyGameJamManager
    returns (address _gameJamAddress)
    {
        return address((new GameJam).value(0)(prizeBalance));
    }

    function addNewGameJam(
        bytes32 _name,
        uint prizeBalance
    )
    external
    onlyGameJamManager
    returns (bytes32)
    {
        // Create a new GameJam and gather its address
        address _gameJamAddress = createGameJam(prizeBalance);
        // Add the new GameJam address to our mapping
        gameJamList[_name] = _gameJamAddress;

        emit GameJamAdded(_name);
        return _name;
    }

}