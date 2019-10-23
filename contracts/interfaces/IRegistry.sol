pragma solidity 0.5.12;

interface IRegistry {

  function updateContractAddress(
    string calldata _name,
    address _address
  )
    external
    returns (address);

  function getContractAddress(
    string calldata _name
  )
    external
    view
    returns (address);
}