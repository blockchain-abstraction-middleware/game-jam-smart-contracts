pragma solidity 0.5.11;

import "openzeppelin-solidity/contracts/access/Roles.sol";


contract ContractRegistry {
  using Roles for Roles.Role;

  Roles.Role private admin;

  mapping (string => address) private contractAddresses;

  event UpdateContract(string name, address indexed contractAddress);

  constructor()
    public
  {
    admin.add(msg.sender);
  }

  function updateContractAddress(
    string calldata _name,
    address _address
  )
    external
    returns (address)
  {
    require(bytes(_name).length != 0, "name must be at least one character long");
    require(admin.has(msg.sender), "Admin role required");

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