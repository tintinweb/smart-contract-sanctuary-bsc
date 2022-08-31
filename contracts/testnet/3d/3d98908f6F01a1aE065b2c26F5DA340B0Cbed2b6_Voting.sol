/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

/**
 *Submitted for verification at BscScan.com on 2021-06-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Voting{
    address owner;
    mapping(bytes16 => uint8) public votesReceived;//商品以及对应的票数
    ///投票商品的集合
    //["0x12653754000000000000000000000000","0x13653754000000000000000000000000","0x14653754000000000000000000000000"]
    bytes16[] public goodsArrayList;
    address[] public votersList;
    mapping(address => mapping(bytes16 => uint)) public getAddressGoodsCounts;//每个地址对应商品以及票数

    constructor(){
        owner = msg.sender;
    }

    //添加需要投票的商品
    function addGoodsArrayList(bytes16 goods)public {
        require(owner == msg.sender,'Operation without permission');
        goodsArrayList.push(goods);
    }

    //获取所有需要投票的商品
    function getAllGoodsArrayList()public view returns(bytes16[] memory ){
        return goodsArrayList;
    }

    //
    function totalVotesFor(bytes16 goods)public view returns(uint8){
        // require(validCandidate(candidate));
        return votesReceived[goods];
    }

    //开始投票
    function voteForGoods(bytes16 goods)public{
        require(validCounts() < 10,'The number of votes has exceeded');
        votesReceived[goods] += 1;
        getAddressGoodsCounts[msg.sender][goods] += 1;
        votersList.push(msg.sender);
    }

    //判断每个地址投票了多少次
    function validCounts()public view returns(uint){
        uint counts = 0;
        for(uint i = 0; i < goodsArrayList.length; i++){
            bytes16 goodsId = goodsArrayList[i];
            uint goodsCounts = getAddressGoodsCounts[msg.sender][goodsId];
            counts += goodsCounts;
        }
        return counts;
    }
}