/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Relation {

    mapping(address => address) public _head;
    mapping(address => uint256) public _count;
    mapping(address => bool) private canCallLists;
    address owner;

    constructor() {
      owner = msg.sender;
    }

    event BindEvent(address indexed sender,address indexed _level);
    
    function bind(address _sender,address _level) external {
        require(canCallLists[msg.sender],'AFRD: only ido can call');
        require(_sender != _level,'AFRD: level can not set to youself');
        require(_level != address(0),'AFRD: level can not a zero address');
        require(_head[_sender] == address(0),'AFRD:has been bind');
        _head[_sender] = _level;
        uint256 current = _count[_level];
        _count[_level] = current+1;
        emit BindEvent(_sender,_level);
    }

    function setOwner(address _owner) external {
      require(msg.sender == owner,'AFRD: only owner can call');
      owner = _owner;
    }
    //init call func _address = ido.sol
    function setCanCallLists(address _address) external {
      require(msg.sender == owner,'AFRD: only owner can call');
      canCallLists[_address] = true;
    }


    function getHigherAddressList(address sub,uint256 depth) external view returns(address[] memory){
        address current  = sub;
        address level ;
        address[] memory levels = new address[](depth);
        for(uint256 i=0; i<depth; i++){
            level = _head[current];
            current = level;
            levels[i] = level;
        }
        return levels;
    }

    function getHigherAddress(address sub,uint256 depth) external view returns(address){
        address result = address(0);
        address current  = sub;
        for(uint256 i=0; i< depth; i++){
            result = _head[current];
            current = _head[current];
        }
        return result;
    }
}