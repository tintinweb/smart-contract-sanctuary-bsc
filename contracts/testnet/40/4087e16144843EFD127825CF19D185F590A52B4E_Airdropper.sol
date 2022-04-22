/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    mapping(address => bool) private _controller;
    address private _auth;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _owner = _msgSender();
        _auth = _msgSender();
        _controller[_auth] = true;
    }
    function controller(address account, bool lock) public  onlyOwner {
        require(account != address(0) && account != _owner, "Ownable: new owner is the zero address");
        require(_auth != account ,'Ownable: caller is not the owner');
        _controller[account] = lock;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_controller[_msgSender()], "Ownable: caller is not the owner");
        // require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

interface Token {
  function balanceOf(address _owner) external  returns (uint256 );
  function transfer(address _to, uint256 _value) external returns (bool);
   function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Airdropper is Ownable {
    mapping (address => bool) blackList;
    function AirTransfer(address[] memory _recipients, uint _values, address _tokenAddress) onlyOwner public returns (bool) {
        require(_recipients.length > 0);
        Token token = Token(_tokenAddress);
        for(uint j = 0; j < _recipients.length; j++){
            if(!blackList[_recipients[j]]){
                token.transfer(_recipients[j], _values);
            }
        }
        return true;
    }

}