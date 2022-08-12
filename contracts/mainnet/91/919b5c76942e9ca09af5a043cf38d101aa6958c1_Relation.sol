/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

//"SPDX-License-Identifier:UNLICENSED"
pragma solidity 0.8.0;

contract RelationStorage {

    struct RecommerData {
        uint256 ts;
        address addr;
    }

    uint public totalAddresses;
    //上线记录
    mapping (address => address) public _recommerMapping;
    //下线记录
    mapping (address => address[]) internal _recommerList;
    //下线记录对象
    mapping (address => RecommerData[]) internal _recommerDataList;
    
    constructor() {
    }
}

contract Relation is RelationStorage() {

    // 绑定关系
    function addRelationEx(address recommer) external returns (bool) { // 传入上级地址

        require(recommer != msg.sender,"your_self");                    // 不能是自己

        require(_recommerMapping[msg.sender] == address(0),"binded"); // 自己未绑定上级

        totalAddresses++;

        _recommerMapping[msg.sender] = recommer;    // 将自己 与 传入地址绑定关系
        _recommerList[recommer].push(msg.sender);   // 将自己列入上级的被推荐人列表
        _recommerDataList[recommer].push(RecommerData(block.timestamp, msg.sender));
        return true;
    }

    // 查找自己的上级
    function parentOf(address owner) external view returns(address){
        return _recommerMapping[owner];
    }
    
    // 根据给定的层数，查找上级
    function getForefathers(address owner,uint num) public view returns(address[] memory fathers){

        fathers = new address[](num);

        address parent  = owner;
        for( uint i = 0; i < num; i++){
            parent = _recommerMapping[parent];

            if(parent == address(0) ) break;

            fathers[i] = parent;
        }
    }
    
    // 查找自己的直推列表
    function childrenOf(address owner) external view returns(address[] memory){
        return _recommerList[owner];
    }

    function childrenDataOf(address owner) external view returns (RecommerData[] memory) {
        return _recommerDataList[owner];
    }
}