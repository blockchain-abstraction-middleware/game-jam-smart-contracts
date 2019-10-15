pragma solidity ^0.5.11;

contract ContractRegistry {
  mapping (string => address) private contractAddresses;

  event UpdateContract(string name, address indexed contractAddress);

  function updateContractAddress(
    string calldata _name,
    address _address
  )
    external
    returns (address)
  {
    contractAddresses[_name] = _address;
    emit UpdateContract(_name, _address);

    return _address;
  }

  function getContractAddress(string calldata _name)
    external
    view
    returns (address)
  {
    return contractAddresses[_name];
  }
}