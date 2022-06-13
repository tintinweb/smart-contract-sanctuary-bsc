/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface upgradeable{
    function upgrad(address newLogic) external returns(bool);
}

contract Initialize {
    bool internal initialized;

    modifier init(){
        require(!initialized, "initialized");
        _;
        initialized = true;
    }
}

contract Conf is Initialize {
    address public owner;
    address public pledge;
    address public snapshoot;
    address public upgrade;
    address public senator;
    address public poc;
    address public developer;
    //seting
    uint public epoch;          //共识周期
    uint public executEpoch;    //执法周期
    uint public stEpoch;        //提案周期
    uint public voteEpoch;      //投票周期
    uint public senatorNum;     //议员数量
    uint public offLine;        //共识下线
  

    function initialize(address _pledge, address _snapshoot, address _upgrade, address _senator, address _poc) external init{
        (owner, pledge, snapshoot, upgrade, senator, poc, developer) = (msg.sender, _pledge, _snapshoot, _upgrade, _senator, _poc, msg.sender);
        (epoch, executEpoch, stEpoch, voteEpoch, senatorNum, offLine) = (7 days,  1 days, 1 hours, 1 hours, 11, 6);
    }
    
    //仅用于测试环境
    /*function setEpoch(uint _epoch, uint _executEpoch, uint _stEpoch, uint _voteEpoch) external {
        (epoch, executEpoch, stEpoch, voteEpoch) = (_epoch, _executEpoch, _stEpoch, _voteEpoch);
    }*/

    //调试时测试，升级本合约情况是否合法。
    //pr需要增加人工审核流程（杜绝自动授权）
   /* function upgrad(address target, address newLogic) external {
        upgradeable(target).upgrad(newLogic);
    }*/
}