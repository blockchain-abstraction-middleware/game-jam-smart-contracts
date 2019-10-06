pragma solidity ^0.5.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/GameJam.sol";

contract TestGameJam {
  // Truffle will send the TestGameJam one Ether after deploying the contract.
  uint public initialBalance = 1 ether;

  function testInitialBalanceUsingDeployedContract() public {
    GameJam gameJam = GameJam(DeployedAddresses.GameJam());
    uint expected = 0;
    Assert.equal(address(gameJam).balance, expected, "Initial Balance should be zero");
  }

}