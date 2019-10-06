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

  function testInitialStageUsingDeployedContract() public {
    GameJam gameJam = GameJam(DeployedAddresses.GameJam());
    require(gameJam.stage() == GameJam.Stages.JamInProgress, "Initial Stage should be JamInProgress");
  }

  function testPayoutDoesNotWorkAtInitialState() public {
    GameJam gameJam = GameJam(DeployedAddresses.GameJam());
    address payable potentialWinner = address(uint160(address(this))); // Cast to an address payable
    bool r;
    
    // We're basically calling our contract externally with a raw call, forwarding all available gas, with
    // msg.data equal to the throwing function selector that we want to be sure throws and using only the boolean
    // value associated with the message call's success
    (r, ) = address(gameJam).call(abi.encodePacked(gameJam.payoutWinner.selector, potentialWinner));
    Assert.isFalse(r, "Call to payoutWinner should be unsuccessful when stage is JamInProgress");
  }
 
  function testFinishingTheDeployedContract() public {
    GameJam gameJam = GameJam(DeployedAddresses.GameJam());
    require(gameJam.stage() == GameJam.Stages.JamInProgress, "Stage should be JamInProgress before finish");
    gameJam.finish.value(0)(address(this));
    require(gameJam.stage() == GameJam.Stages.WinnerDeclaration, "Stage should be WinnerDeclaration after finish");
  }

}