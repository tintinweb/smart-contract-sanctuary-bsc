//// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12 ;


import "./promoter.sol";
import "./platform.sol";


contract UserPay is Platform,Promoter {

    //用户
    uint public orderID = 1 ;
    mapping(uint => payInfo) public userPayInfo ;   //通过订单编号进行查询用户的付费情况
    mapping(address => uint[]) public userOrders ;  //用户查询他的订单 ;


    struct payInfo {
        uint payTime ;
        uint payCash ;
        uint articleID ;
        bool status ;
        address  user ;
    }




    function payForArticle(uint _arid,address _promoter) external payable {

        //用户的需求 1.付了费能否阅读  2.记录 
        uint remainEther = msg.value ;
        require(remainEther >= articleInfo[_arid].payCash , "You need pay ether more to read" );
        require(articleInfo[_arid].status,"This article have been block");
        require(msg.sender != address(0));
        userPayInfo[orderID] = payInfo(block.timestamp,msg.value,_arid,true,msg.sender);
        userOrders[msg.sender].push(_arid);

        //推广者   1.知道是谁付了费  2.付了多少钱  3.我分了多少钱
        if(_promoter != address(0)){
            uint rewardPercent = articleInfo[_arid].rewardPercent ;
            uint promoterReward = rewardPercent * msg.value / 100 ;
            remainEther -= promoterReward ;
            promoterBalance[_promoter] += promoterReward ;
            promoteList[_promoter].push(orderID);
        }



        //平台  需求：手续费
        uint rewardAdmin = fee * msg.value / 100 ;
        adminBalance += rewardAdmin ;
        remainEther -= rewardAdmin ;

        //作者需求 ： 1.谁付了费   2.我分了多少钱   3.那篇文章  4.推广者
        uint aid = articleBelongAuthor[_arid] ;
        authorFansPay[aid].push(orderID);
        authorBalance[aid] += remainEther ;


        orderID++ ;

    }


    constructor(address _admin) public {
        admin = _admin ;
    }


    


}