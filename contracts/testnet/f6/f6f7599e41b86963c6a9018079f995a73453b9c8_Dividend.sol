/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Dividend {
  address[] public createAddressLists;
  mapping(address => bool) isCreateAddress;
  address owner;
  mapping(address => bool) private canCallLists;

  constructor() {
    owner = msg.sender;
  }

  function setOwner(address _owner) external {
    require(msg.sender == owner);
    owner = _owner;
  }
  //init call _address = ido.sol
  function setCanCallLists(address _address) external {
    require(msg.sender == owner,'AFRD: only owner can call');
    canCallLists[_address] = true;
  }

  function setApprove(address _token,address _spender,uint256 _amount) external {
    require(msg.sender == owner);
    IERC20(_token).approve(_spender,_amount);
  }
  function setCreateAddress(address _address) external {
    require(canCallLists[msg.sender],'AFRD: no permission to call');
    if(!isCreateAddress[_address]) {
      createAddressLists.push(_address);
    }
  }
  function getCreateLists() public view returns(address[] memory) {
    address[] memory createLists = new address[](createAddressLists.length);
    for(uint256 i = 0; i < createAddressLists.length;i++) {
      createLists[i] = createAddressLists[i];
    }
    return createLists;
  }
}