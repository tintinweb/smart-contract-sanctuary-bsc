/**
 *Submitted for verification at BscScan.com on 2022-07-11
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
    function senatorNum() external view returns(uint);
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
    uint public epochId;
    uint public epochIndate;
    uint public executerId;
    uint public executerIndate;
    uint public executerIndex;
    
    address[] public senators;
    address public conf;
    //uint[] public offset;
    
    event UpdateSenator(uint indexed _epochId, address[] _sentors, uint _epochIndate);
    event UpdateExecuter(uint indexed _executerId, address _executer, uint _executerIndate);

    modifier onlyPoc{
        require(msg.sender == Iconf(conf).poc());
        _;
    }

    modifier onlyConf{
        require(msg.sender == conf);
        _;
    }

    function initialize(address _conf) external init{
        conf = _conf;
        epochId = 1;
        executerId = 1;
        (senators,) = Ipledge(Iconf(conf).pledge()).queryNodeRank(1, Iconf(conf).senatorNum());
        epochIndate = block.timestamp + Iconf(conf).epoch();
        executerIndate = block.timestamp + Iconf(conf).executEpoch();

        emit UpdateSenator(epochId, senators, epochIndate);
        emit UpdateExecuter(executerId, _getExecuter(), executerIndate);
    }

    function _getExecuter() internal view returns(address) {
         return senators[executerIndex];
    }


    function getExecuter() external view returns(address){
        return _getExecuter();
    }

    function _getNextExecuter() internal view returns(address) {
        if (executerIndex == senators.length) return senators[0]; 
        return senators[executerIndex+1];
    }

    function getNextSenator() external view returns(address) {
        return _getNextExecuter();
    }

    function isSenator(address user) external view returns(bool) {
        for (uint i=0; i< senators.length; i++){
            if (user == senators[i] && i != executerIndex) return true;
        }
        return false;
    }

    function addSenator(address[] calldata newSenators) external onlyConf{
        for(uint i=0; i<newSenators.length; i++){
            senators.push(newSenators[i]);
        }
    }

    function updateSenator() external onlyPoc{
        require(block.timestamp > epochIndate, "unexpired");
        (senators,) = Ipledge(Iconf(conf).pledge()).queryNodeRank(1,Iconf(conf).senatorNum());

        epochId++;
        epochIndate = block.timestamp + Iconf(conf).epoch();
        
        executerId++;
        executerIndex = 0;
        executerIndate = block.timestamp + Iconf(conf).executEpoch();

        emit UpdateSenator(epochId, senators, epochIndate);
        emit UpdateExecuter(executerId, _getExecuter(), executerIndate);
    }

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