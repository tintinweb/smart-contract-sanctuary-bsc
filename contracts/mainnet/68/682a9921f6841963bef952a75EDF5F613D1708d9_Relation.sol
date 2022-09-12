/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

// File: remix/Relation.sol


pragma solidity ^0.8.0;

contract Relation {
    mapping(address=>address) private parentAddress;
    mapping(address=>address[]) private childrens;

    address owner;
    address configAddress;
    address marketAddress;

    mapping(address=>uint256) public teamLeader;
    mapping(address=>address) public myLoader;

    event SetTeamLeader(address team,uint256 no);
    event BindParent(address user, address parent);
    event ClearRelation(address user, address parent);

    modifier onlyOwner {
        require (msg.sender == owner,"no owner");
        _;
    }

    constructor(){
        owner = msg.sender;
    }

    function setTeamLeader(address team,uint256 no) public onlyOwner{
        teamLeader[team] = no;
        emit SetTeamLeader(team,no);
    }

    function setMarketAddress(address mkt) public onlyOwner{
        marketAddress = mkt;
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
        emit ClearRelation(user,_parent);
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
        emit BindParent(msg.sender, _parent);
    }

    function addParent(address user, address _parent) public{
        require(msg.sender != marketAddress,"router error");
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

        if(teamLeader[_parent] == 1){
            myLoader[user] = _parent;
        } else if(myLoader[_parent] != address(0)){
            myLoader[user] = myLoader[_parent];
        }
        emit BindParent(user, _parent);
    }

    function getRelation(address con) public view returns(address[] memory){
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

    function getChildren(address account) public view returns(address[] memory){
        return childrens[account];
    }

    function parent(address account) public view returns(address){
        return parentAddress[account];
    }

    function leader(address account) public view returns(address){
        return myLoader[account];
    }
}