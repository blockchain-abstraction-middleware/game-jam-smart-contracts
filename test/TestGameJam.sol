pragma solidity ^0.5.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/GameJam.sol";

contract TestGameJam {
    // Truffle will send the TestGameJam one Ether after deploying the contract.
    uint public initialBalance = 1 ether;
    //Rather than use the GameJam project deployed by Migrations, create a new one, making this address the admin
    GameJam gameJam = new GameJam(1);
    GameJam deployedGameJam = GameJam(DeployedAddresses.GameJam());

    string validIpfsHash = "QmPXgPCzbdviCVJTJxvYCWtMuRWCKRfNRVcSpARHDKFSha";

    function testInitialBalanceUsingDeployedContract() public {
        uint expected = 1;
        Assert.equal(gameJam.balance(), expected, "Initial Balance should be zero");
    }

    function testInitialBalanceUsingNewContract() public {
        GameJam gameJamNew = new GameJam(0);
        uint expected = 0;
        Assert.equal(gameJamNew.balance(), expected, "Initial Balance should be zero");
    }

    function testInitialStageUsingDeployedContract() public {
        require(gameJam.stage() == GameJam.Stages.Registration, "Initial Stage should be InProgress");
    }

    function testPayoutDoesNotWorkAtInitialState() public {
        address payable potentialWinner = address(uint160(address(this))); // Cast to an address payable
        bool r;

        // We're basically calling our contract externally with a raw call, forwarding all available gas, with
        // msg.data equal to the throwing function selector that we want to be sure throws and using only the boolean
        // value associated with the message call's success
        (r, ) = address(gameJam).call(abi.encodePacked(gameJam.payoutWinner.selector, potentialWinner));
        Assert.isFalse(r, "Call to payoutWinner should be unsuccessful when stage is InProgress");
    }
    function testAddingThisAddressAsACompetitor() public {
        require(gameJam.stage() == GameJam.Stages.Registration, "Stage should be Registration before start");
        gameJam.addCompetitor(address(this), validIpfsHash);
    }
    function testStartingTheDeployedContract() public {
        require(gameJam.stage() == GameJam.Stages.Registration, "Stage should be Registration before start");
        gameJam.start.value(0)();
        require(gameJam.stage() == GameJam.Stages.InProgress, "Stage should be InProgress after start");
    }


    function testFinishCantBeCalledWithANonRegisteredCompetitor() public {
        require(gameJam.stage() == GameJam.Stages.InProgress, "Stage should be Registration");
        bool r;
        // Make a call to finish the GameJam from this address, the admin
        // sends the address of the deployedGameJam contract as a winner
        // this address hasn't been registered as a competitor and the call should fail
        (r, ) = address(gameJam).call(abi.encodePacked(gameJam.finish.selector, address(deployedGameJam)));
        Assert.isFalse(r, "Call to finish on the deployed contract should be unsuccessful as the winner isin't in the list");

    }
    function testFinishingTheDeployedContract() public {
        require(gameJam.stage() == GameJam.Stages.InProgress, "Stage should be JamInProgress before finish");
        gameJam.finish.value(0)(address(this));
        require(gameJam.stage() == GameJam.Stages.Finished, "Stage should be WinnerDeclaration after finish");
    }

    function testFinishCantBeDoneTwice() public {
        bool r;
        require(gameJam.stage() != GameJam.Stages.InProgress, "Stage should not be JamInProgress");
        (r, ) = address(gameJam).call(abi.encodePacked(gameJam.finish.selector, address(this)));
        Assert.isFalse(r, "Call to finish should be unsuccessful when stage is not JamInProgress");
    }

    function testPayoutWinnerOnDeployedContract() public {
        address payable potentialWinner = address(uint160(address(this))); // Cast to an address payable
        require(gameJam.stage() == GameJam.Stages.Finished, "Stage should be Finished");
        gameJam.payoutWinner.value(0)(potentialWinner);
    }

    function testRoleBlocksStartingTheDeployedContract() public {
        require(deployedGameJam.stage() == GameJam.Stages.Registration, "Stage should be Registration");
        bool r;
        // We're basically calling our contract externally with a raw call, and using only the boolean
        // value associated with the message call's success
        // At this stage, before the JS tests have run, deployedGameJam should still be in Registration (asserted above)
        // and we can try to start eh contract from THIS contract, which should fail as this contract isin't an admin.
        (r, ) = address(gameJam).call(abi.encodePacked(deployedGameJam.start.selector, ""));
        Assert.isFalse(r, "Call to start on the deployed contract should be unsuccessful as it was deployed during Migrations");
    }

}