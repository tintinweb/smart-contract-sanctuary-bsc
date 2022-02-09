/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Iconf{
    function senator() external view returns(address);
    function upgrad(address, address) external;
    function poc() external view returns(address);
}

interface Isenator{
    function developer() external view returns(address);
    function isSenator(address) external view returns(bool);
}

contract Initialize {
    bool internal initialized;

    modifier init(){
        require(!initialized, "initialized");
        _;
        initialized = true;
    }
}

contract upgrade is Initialize {
    address public conf;

    //升级提案集
    upgradeProposal[] public upgrades;

    //提案状态:{等待，成功，失败}
    enum Result{PENDING, SUCCESS, FAILED}
    
    //升级提案
    struct upgradeProposal{
        address target;                       //升级目标
        address newAddress;                   //新合约地址
        string descURL;                       //升级描述
        uint proposalTime;                    //提案时间
        uint assentor;                        //赞同者数量
        uint unAssentor;                      //反对者数量
        Result result;                        //共识结果
    }

    event SendUpgradeProposal(address target, address newAddress, string descURL);

    modifier onlyDeveloper(){
        require(Isenator(Iconf(conf).senator()).developer() == msg.sender, "access denied: only developer");
        _;
    }

    modifier onlySentor(){
        require(Isenator(Iconf(conf).senator()).isSenator(msg.sender), "access denied: only senator");
        _;
    }

    modifier onlyPoc(){
        require(Iconf(conf).poc() == msg.sender, "access denied: only poc");
        _;
    }

   function initialize(address _conf) external init{
        conf = _conf;
    }
    
    //发起升级提案
    function sendUpgradeProposal(address _target, address _newAddress, string memory _descURL) external onlyDeveloper{
        require(isResolution(), "The latest proposal has no resolution");
        upgrades.push(upgradeProposal(
            {
                target:         _target,
                newAddress:     _newAddress,                           
                descURL:        _descURL,                       
                proposalTime:   block.timestamp,                  
                assentor:       0,
                unAssentor:     0,                
                result:         Result.PENDING 
            }
        ));   

        emit SendUpgradeProposal(_target, _newAddress, _descURL);
    }
    
     //获取最新提案
    function latestUpgradeProposal() external view returns(address target, address newAddress, string memory descURL){
        upgradeProposal memory up = upgrades[upgrades.length -1];
        return(up.target, up.newAddress, up.descURL);
    }

    //表决提案
    function vote(bool v) external onlySentor{
        require(!isResolution(),"Reached a consensus");
        if(v) {
            upgrades[upgrades.length-1].assentor++;
            if (upgrades[upgrades.length-1].assentor>=6) {
                upgrades[upgrades.length-1].result = Result.SUCCESS;
                Iconf(conf).upgrad(upgrades[upgrades.length-1].target, upgrades[upgrades.length-1].newAddress);
            }
        }else{
            upgrades[upgrades.length-1].unAssentor++;
            if (upgrades[upgrades.length-1].unAssentor>=6) upgrades[upgrades.length-1].result = Result.FAILED;
        }
    }

      //一票否决
    function veto() external onlyPoc{
        upgrades[upgrades.length-1].result = Result.FAILED;
    }

    //最新提案是否已完成表决
    function isResolution() public view returns(bool){
         if (upgrades[upgrades.length-1].result != Result.PENDING) {
             return true;
         }else{
             return false;
         }
    }
}