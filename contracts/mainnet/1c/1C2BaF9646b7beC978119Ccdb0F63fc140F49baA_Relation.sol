/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRelation {
    function parent(address con) external view returns(address);
    function getRelation(address con) external view returns(address[] memory);
    function getChildren(address acccount) external view returns(address[] memory);
}

contract Relation is IRelation{

    mapping(address=>address) private parentAddress;

    address owner;

    mapping(address=>address[]) private childrens;

    event BingParent(address user, address parent);

    modifier onlyOwner {
        require (msg.sender == owner,"no owner");
        _;
    }
    constructor(){
        owner = msg.sender;
    }

    function clearRelation(address user, address _parent) public onlyOwner{
        address[] storage child = childrens[_parent];
        uint256 idx = 0;
        for(uint256 i=0; i<child.length; i++){
            if(child[i] == user){
                idx = i;
            }
        }
        for (uint256 i = idx; i < child.length-1; i++) {
            child[i] = child[i+1];
        }
        child.pop();
        parentAddress[user] = address(0);
    }

    function addRelation(address user, address _parent) onlyOwner public {
        require(user != _parent,"parnt == user");
        require(parentAddress[user] == address(0),"has parentAddress");

        address[] memory addrs = getRelation(_parent);
        for(uint256 i=0; i<addrs.length; i++){
            if(addrs[i] == user){
                require(false,"closed loop");
            }
        }
        parentAddress[user] = _parent;
        address[] storage child = childrens[_parent];
        for(uint256 i=0; i<child.length; i++){
            if(child[i] == user){
                return;
            }
        }
        child.push(user);
        emit BingParent(msg.sender, _parent);
    }

    function getRelation(address con) public view override returns(address[] memory){
        address[] memory addrs = new address[](10);
        address _parent = con;
        for(uint256 i=0; i<10; i++){
            if(parentAddress[_parent] != address(0)){
                _parent = parentAddress[_parent];
                addrs[i] = _parent;
            } else {
                break;
            }
        }
        return addrs;
    }

    function addParent(address _parent) public{
        require(msg.sender != _parent,"parnt == user");
        require(parentAddress[msg.sender] == address(0),"has parentAddress");

        address[] memory addrs = getRelation(_parent);
        for(uint256 i=0; i<addrs.length; i++){
            if(addrs[i] == msg.sender){
                require(false,"closed loop");
            }
        }
        parentAddress[msg.sender] = _parent;
        address[] storage child = childrens[_parent];
        for(uint256 i=0; i<child.length; i++){
            if(child[i] == msg.sender){
                return;
            }
        }
        child.push(msg.sender);
        emit BingParent(msg.sender, _parent);
    }

    function getChildren(address account) public view override returns(address[] memory){
        return childrens[account];
    }

    function parent(address account) public view override returns(address){
        return parentAddress[account];
    }
}