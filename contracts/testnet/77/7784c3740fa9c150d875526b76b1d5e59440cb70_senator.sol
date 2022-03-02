/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Ipledge{
    function queryNodeRank(uint256 start, uint256 end) external view returns(address[] calldata, uint256[] calldata);
}

interface Iconf{
    function pledge() external view returns(address);
    function poc() external view returns(address);
    function epoch() external view returns(uint);
    function executEpoch() external view returns(uint);
}

contract Initialize {
    bool internal initialized;

    modifier init(){
        require(!initialized, "initialized");
        _;
        initialized = true;
    }
}

contract senator is Initialize {
    uint public epochId;                       //共识周期
    uint public epochIndate;                   //本届共识集有效期
    uint public executerId;                    //执法者序号
    uint public executerIndate;                //执法者有效期
    uint public executerIndex;                 //执法者在共识集中的序号
    
    address[] public senators;                 //当前共识集
    address public conf;                       //配置合约
    //uint[] public offset;                      //换届偏移量
    
    event UpdateSenator(uint indexed _epochId, address[] _sentors, uint _epochIndate);
    event UpdateExecuter(uint indexed _executerId, address _executer, uint _executerIndate);

    modifier onlyPoc{
        require(msg.sender == Iconf(conf).poc());
        _;
    }

    function initialize(address _conf) external init{
        conf = _conf;
        epochId = 1;
        executerId = 1;
        (senators,) = Ipledge(Iconf(conf).pledge()).queryNodeRank(1,11);
        epochIndate = block.timestamp + Iconf(conf).epoch();
        executerIndate = block.timestamp + Iconf(conf).executEpoch();

        emit UpdateSenator(epochId, senators, epochIndate);
        emit UpdateExecuter(executerId, _getExecuter(), executerIndate);
    }

    function _getExecuter() internal view returns(address) {
         return senators[executerIndex];
    }

    //仅用于测试环境
    function reset() external {
        epochIndate = Iconf(conf).epoch();
        executerIndate =  Iconf(conf).executEpoch();
    }
    
    //查询执法者
    function getExecuter() external view returns(address){
        return _getExecuter();
    }

    function _getNextExecuter() internal view returns(address) {
        if (executerIndex == senators.length) return senators[0]; 
        return senators[executerIndex+1];
    }
    
    //查询执法者继任人
    function getNextSenator() external view returns(address) {
        return _getNextExecuter();
    }

    //查询是否共识成员
    function isSenator(address user) external view returns(bool) {
        for (uint i=0; i< senators.length; i++){
            if (user == senators[i] && i != executerIndex) return true;
        }
        return false;
    }

    //更新共识集
    function updateSenator() external onlyPoc{
        require(block.timestamp > epochIndate, "unexpired");
        (senators,) = Ipledge(Iconf(conf).pledge()).queryNodeRank(1,11);

        epochId++;
        epochIndate = block.timestamp + Iconf(conf).epoch();
        
        executerId++;
        executerIndex = 0;
        executerIndate = block.timestamp + Iconf(conf).executEpoch();

        emit UpdateSenator(epochId, senators, epochIndate);
        emit UpdateExecuter(executerId, _getExecuter(), executerIndate);
    }

    //更新执法者
    function updateExecuter() external onlyPoc{
        if (executerIndex == senators.length-1){
            executerIndex = 0;
        }else{
            executerIndex++;
        }
        
        executerId++;
        executerIndate = block.timestamp + Iconf(conf).executEpoch();

        emit UpdateExecuter(executerId, _getExecuter(), executerIndate);
    }
}