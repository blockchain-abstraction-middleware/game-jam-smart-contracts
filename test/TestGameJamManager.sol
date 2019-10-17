pragma solidity ^0.5.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ContractRegistry.sol";
import "../contracts/GameJam.sol";
import "../contracts/GameJamManager.sol";



contract TestGameJamManager {

    function testCreatingANewGameJamManager() public {
        GameJamManager gameJamManager = new GameJamManager(DeployedAddresses.ContractRegistry());
    }

    function testAddingNewGameJam() public {
        GameJamManager gameJamManager = new GameJamManager(DeployedAddresses.ContractRegistry());

        gameJamManager.addNewGameJam("Test GameJam", 1);
    }


}