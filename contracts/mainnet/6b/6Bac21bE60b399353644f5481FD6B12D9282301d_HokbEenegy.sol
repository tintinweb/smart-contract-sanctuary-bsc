/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender());
        _;
    }

    function transferOwnership(address account) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, account);
        _owner = account;
    }

}

contract HokbEenegy is Context, Ownable {

  mapping(address => bool) public permission;

  mapping(uint256 => uint256) public lastclaim;
  mapping(uint256 => uint256) public lastrefill;
  mapping(uint256 => uint256) public lastattack;
  mapping(uint256 => uint256) public lastwithdraw;

  modifier onlyPermission() {
    require(permission[msg.sender], "!PERMISSION");
    _;
  }

  constructor() {
    permission[msg.sender] = true;

  }

  function flagePermission(address _account,bool _flag) public onlyOwner returns (bool) {
    permission[_account] = _flag;
    return true;
  }

  function mod_lastclaim(uint256 tokenid,uint256 stamp) public onlyPermission returns (bool) {
    lastclaim[tokenid] = stamp;
    return true;
  }

  function mod_lastrefill(uint256 tokenid,uint256 stamp) public onlyPermission returns (bool) {
    lastrefill[tokenid] = stamp;
    return true;
  }

  function mod_lastattack(uint256 tokenid,uint256 stamp) public onlyPermission returns (bool) {
    lastattack[tokenid] = stamp;
    return true;
  }

  function mod_lastwithdraw(uint256 tokenid,uint256 stamp) public onlyPermission returns (bool) {
    lastwithdraw[tokenid] = stamp;
    return true;
  }
}