/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
}

interface EscroeLike {
    function getHostingInfo(uint256 order) external view returns (address partyA,address partyB,uint256 assetAmount);
    function arbitration(uint256 order,uint256 partyAAmount,uint256 partyBAmount) external;
}
interface NFTLike {
    function arbitrators(address) external view returns (bool);
}

contract  Arbitration {

   mapping(uint256 =>mapping(address =>uint256[2]))   public appealComp;
   mapping(uint256 =>mapping(uint256 =>uint256[2]))   public slates;
   mapping(uint256 => uint256)                        public arb; 

  ///仲裁员资格
    //通过抵押代币成为仲裁员
    function arbApply(uint256 wad) external {}

    //社区投票弹劾仲裁员，可以罚没部分保证金
    function Recall(address usr,uint256 fine) external {}

    // 仲裁员赎回保证金
    function exitArb(address usr, uint256 wad) external {}

    //仲裁员补位算法
    function cover(uint256 id) internal {}

    // 特邀仲裁员不受排位算法限制
    function setNFT(address sender) internal view  returns (bool){}

  ///第一轮仲裁 
    //支付仲裁费
    function payAppealFee(address escroecontroct,uint256 i,uint256 _appealFee) external {}

    //邀请仲裁员
    function inviteArbitrator(uint256 _order,address usr) external {}

    //获取仲裁订单对应的资产托管合约地址和订单号
    function getEscroeInfo(uint256 _order) public view   returns(address,uint256){}

    //当事双方设置仲裁诉求，设置后不可改变
    function setComp(uint256 _order, uint256 amountOfpartyA, uint256 amountOfpartyB) external  {
        (address escroecontroct,uint256 i) = getEscroeInfo(_order);
        (address partyA,address partyB,uint256 assetAmount) = EscroeLike(escroecontroct).getHostingInfo(i);
        require(partyA == msg.sender || partyB == msg.sender, "1");
        require(assetAmount == amountOfpartyA + amountOfpartyB, "1");
        require(appealComp[_order][msg.sender][0] + appealComp[_order][msg.sender][1] != assetAmount, "1");
        appealComp[_order][msg.sender] = [amountOfpartyA,amountOfpartyB];
    }
    //双方和解，甲方执行乙方方案，或乙方执行甲方方案
    function reconciliation(uint256 _order) external  {
        (address escroecontroct,uint256 i) = getEscroeInfo(_order);
        (address partyA,address partyB,) = EscroeLike(escroecontroct).getHostingInfo(i);
        if(partyA == msg.sender) EscroeLike(escroecontroct).arbitration(i,appealComp[_order][partyB][0],appealComp[_order][partyB][1]);
        if(partyB == msg.sender) EscroeLike(escroecontroct).arbitration(i,appealComp[_order][partyA][0],appealComp[_order][partyA][1]);
    }

    //仲裁员弃权或投赞成票，各方只有第一个仲裁员的投票有效
    function firstRoundOfArbitration(uint256 _order) external {}

    //执行第一轮仲裁结果
    function executeFirstRoundOfArbitration(uint256 _order) external  {
        //
        (address escroecontroct,uint256 i) = getEscroeInfo(_order);
        (address partyA,address partyB,) = EscroeLike(escroecontroct).getHostingInfo(i);
        if (arb[_order] == 1) EscroeLike(escroecontroct).arbitration(i,appealComp[_order][partyA][0],appealComp[_order][partyA][1]);
        if (arb[_order] == 2) EscroeLike(escroecontroct).arbitration(i,appealComp[_order][partyB][0],appealComp[_order][partyB][1]);
    }
    //执行第一轮仲裁费分配
    function execute(uint i) internal {}

  /// 第二轮仲裁
    // 第二轮报名
    function arbTwoApply(uint256 _order) external {}

    //第二轮仲裁员竞选资格
    function TwoApply(uint256 i, address usr) internal   returns (bool){}

    //第二轮仲裁员分配仲裁费
     function exeTwo(uint256 i, address usr,uint256 wad) external {}

    //第二轮仲裁员设置仲裁方案
    function scheme(uint256 _order, uint256 amountOfpartyA, uint256 amountOfpartyB) external returns(uint256){
        (address escroecontroct,uint256 i) = getEscroeInfo(_order);
        ( , ,uint256 assetAmount) = EscroeLike(escroecontroct).getHostingInfo(i);
        require(assetAmount == amountOfpartyA + amountOfpartyB, "1");
        //
    }
    //投票
    function vote(uint256 _order, uint256 pau) external   returns(uint256){}

    //取消投票
    function notVote(uint256 _order, uint256 pau) external {}

    //规定时间内，仲裁庭没有达成超过多数票的方案，将解散仲裁庭并重新选举
    function restartlArb(uint256 i) public {}

    //仲裁结果必须被当事方之一采纳才能生效
    function accept(uint256 i, uint256 pau) public {}

    //不满意仲裁结果的当事方可以上诉至社区，否决仲裁结果
    function notAccept(uint256 i,uint256 pau) public {}

    //执行第二轮仲裁结果
    function executeTwo(uint256 _order, uint256 pau) public {
        //
        (address escroecontroct,uint256 i) = getEscroeInfo(_order);
        EscroeLike(escroecontroct).arbitration(i,slates[_order][pau][0],slates[_order][pau][1]);
        //
    }
}