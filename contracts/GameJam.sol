pragma solidity 0.5.12;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "./GameJamCommon.sol";


contract GameJam is GameJamCommon {
  event GameJamAdminAdded(address indexed account);
  event CompetitorAdded(address competitor);
  event VoteCast(address competitorVotedFor);
  event GameJameStarted(uint startTime);
  event WinnerDeclared(address payable[] winners);
  event GameJamFinished(address payable[] winners);

  function initializeGameJam(address admin)
    public
    payable
  {
    balance = msg.value;
    _addGameJamAdmin(admin);
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
    uint winningVoteCount = competitors[competitorAddresses[0]].votes;
    for(uint i = 0; i < competitorAddresses.length; i++) {
      if(winningVoteCount < competitors[competitorAddresses[i]].votes) {
        winningVoteCount = competitors[competitorAddresses[i]].votes;
        delete winners;
        winners.push(address(uint(competitorAddresses[i])));
      } else if(winningVoteCount == competitors[competitorAddresses[i]].votes) {
        winners.push(address(uint(competitorAddresses[i])));
      }
    }

    emit WinnerDeclared(winners);
  }

  // payoutWinner is used after the Jam to payout the declared winner
  function payoutWinner()
    external
    onlyGameJamAdmin
    onlyAtStage(Stages.Finished)
  {
    uint payout = balance / winners.length;
    for(uint i = 0; i < winners.length; i++) {
      if (payout > 0 && address(this).balance >= payout) {
        winners[i].transfer(payout);
      }
      balance = 0;
      emit GameJamFinished(winners);
    }
  }
}