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
    external;

  function finish()
    external;

  function payoutWinner()
    external;
}