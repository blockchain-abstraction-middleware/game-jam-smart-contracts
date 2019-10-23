pragma solidity 0.5.12;

interface IGameJam {
  function isGameJamAdmin(
    address account
  )
    external
    view
    returns (bool);

  function addCompetitor(
    address competitor,
    string calldata ipfsHash
  )
    external;

  function start()
    external
    payable;

  function finish(
    address winner
  )
    external
    payable;

  function payoutWinner(
    address payable winner
  )
    external
    payable;
}