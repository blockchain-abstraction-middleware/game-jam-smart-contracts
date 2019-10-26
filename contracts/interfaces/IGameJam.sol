pragma solidity 0.5.12;

interface IGameJam {
  function initializeGameJam(address admin)
    external
    payable;

  function isGameJamAdmin(
    address account
  )
    external
    view
    returns (bool);

  function balance()
    external
    view
    returns (uint);

  function getAllCompetitorAddresses()
    external
    view
    returns (address[] memory);

  function addCompetitor(
    address competitor,
    string calldata ipfsHash
  )
    external;

  function start()
    external;

  function vote(address competitor)
    external;

  function finish()
    external;

  function payoutWinner()
    external;
}