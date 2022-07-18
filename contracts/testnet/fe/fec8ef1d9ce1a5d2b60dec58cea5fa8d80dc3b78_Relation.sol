/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Relation {

    mapping(address => address) public _head;
    mapping(address => uint256) public _count;
    mapping(address => mapping(address=>uint256)) public _index;

    event BindEvent(address indexed sender,address indexed _level);
    
    function bind(address _level) external {
        require(msg.sender != _level,'AFRD: level can not set to youself');
        require(_level != address(0),'AFRD: level can not a zero address');
        require(_head[msg.sender] == address(0),'AFRD:has been bind');
        _head[msg.sender] = _level;
        uint256 current = _count[_level];
        _count[_level] = current;
        _index[_level][msg.sender] = current;
        emit BindEvent(msg.sender,_level);
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