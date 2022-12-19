/**
 *Submitted for verification at BscScan.com on 2022-12-18
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC20 {
  function transferFrom(address from, address to, uint256 amount) external;
}

contract CallerProxy {
  address public admin;

  constructor(address _admin){
    admin = _admin;
  }

  modifier onlyAdmin(){
    require(msg.sender == admin, "!admin");
    _;
  }

  modifier onlyApproved(){
      require(isApproved[msg.sender], "!approved");
      _;
  }

  mapping(address => bool) public isApproved;
  mapping(address => mapping(uint256 => bool)) public usedIds;

  function transfer(address token, address to, uint256 amount, uint256 id) external onlyApproved {
    require(usedIds[token][id] == false, "already used");

    usedIds[token][id] = true;

    IERC20(token).transferFrom(msg.sender, to, amount);
  }

  function setAdmin(address _admin) external onlyAdmin {
    admin = _admin;
  }

  function addApproved(address _addr, bool approve) external onlyAdmin {
    isApproved[_addr] = approve;
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