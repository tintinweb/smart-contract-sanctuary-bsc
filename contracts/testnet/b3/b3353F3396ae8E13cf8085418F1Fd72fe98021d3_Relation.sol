/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// File: wanlaoban/relation.sol

//"SPDX-License-Identifier:UNLICENSED"
pragma solidity ^0.8.0;
contract RelationStorage {

    address public rootAddress = address(0x000000000000000000000000000000000000dEaD);

    uint public totalAddresses;
    //上线记录
    mapping (address => address) public _recommerMapping;
    //下线记录
    mapping (address => address[]) internal _recommerList;
    //团队总人数
    mapping (address => uint256) internal _teamPeople;
    // 删除了一个（）后面的 public  
    constructor()  {
        _recommerMapping[rootAddress] = address(0xdeaddead);
    }
}

contract Relation is RelationStorage() {

    // 绑定关系
    function addRelationEx(address recommer) external returns (bool) { // 传入上级地址

        require(recommer != msg.sender,"your_self");                    // 不能是自己

        require(_recommerMapping[msg.sender] == address(0),"binded"); // 自己未绑定上级

        if (_recommerMapping[recommer] == address(0)) {
            _recommerMapping[recommer] = rootAddress;
        }

        require(recommer == rootAddress || _recommerMapping[recommer] != address(0),"p_not_bind"); // 上级已有推荐人

        totalAddresses++;
        
        _recommerMapping[msg.sender] = recommer;    // 将自己 与 传入地址绑定关系
        _recommerList[recommer].push(msg.sender);   // 将自己列入上级的被推荐人列表

        // 记录团队总人数
        address parentAddr =   this.parentOf(msg.sender);
        for(uint256 i=0; i<10; i++){
            if(parentAddr == address(0) || parentAddr == rootAddress){
                break;
            }
            _teamPeople[parentAddr] += 1;
            parentAddr = this.parentOf(parentAddr);
        }

        return true;
    }
    // 获取团队总人数
    function getTeamTotalPeople(address addr)external view returns (uint256){
        return _teamPeople[addr] - 1;
    }

    // 查找自己的上级
    function parentOf(address owner) external view returns(address){
        return _recommerMapping[owner];
    }
    
    // 根据给定的层数，查找上级
    function getForefathers(address owner,uint num) external view returns(address[] memory fathers){

        fathers = new address[](num);

        address parent  = owner;
        for( uint i = 0; i < num; i++){
            parent = _recommerMapping[parent];

            if( parent == rootAddress || parent == address(0) ) break;

            fathers[i] = parent;
        }
    }
    
    // 查找自己的直推列表
    function childrenOf(address owner) external view returns(address[] memory){
        return _recommerList[owner];
    }
}