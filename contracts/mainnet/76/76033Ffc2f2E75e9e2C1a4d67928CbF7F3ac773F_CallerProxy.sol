/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IMain {
  function withdraw(uint256 user, address receiver, uint256 amount) external;
  function transferOwnership(address owner) external;
}

contract CallerProxy {
  address public admin;
  address public main;

  constructor(address _admin, address _main){
    admin = _admin;
    main = _main;
  }

  modifier onlyAdmin(){
    require(msg.sender == admin, "!admin");
    _;
  }

  mapping(uint256 => bool) public usedIds;

  function withdraw(uint256 user, address receiver, uint256 amount, uint256 id) external onlyAdmin {
    require(usedIds[id] == false, "already used");

    usedIds[id] = true;

    IMain(main).withdraw(user, receiver, amount);
  }

  function set(address _admin, address _main) external onlyAdmin {
    admin = _admin;
    main = _main;
  }

  function transferMainOwnership(address _new) external onlyAdmin {
    IMain(main).transferOwnership(_new);
  }

  function call(address target, uint256 value, string memory signature, bytes memory data) external onlyAdmin {
    bytes memory callData;
    if (bytes(signature).length == 0) {
        callData = data;
    } else {
        callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
    }

    (bool success, ) = target.call{value: value}(callData);
    require(success, "Transaction execution reverted.");
  }
}