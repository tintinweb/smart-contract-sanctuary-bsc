/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Iconf{
    function senator() external view returns(address);
    function snapshoot() external view returns(address);
    function upgrade() external view returns(address);
    function offLine() external view returns(uint);
}

interface Isnapshoot{
    function isResolution() external view returns(bool);
    function isOutLine() external view returns(bool);
    function veto() external;
}

interface Iupgrade{
    function isResolution() external view returns(bool);
    function veto() external;
}

interface Isenator{
    function epochId() external view returns(uint);
    function executerId() external view returns(uint);
    function epochIndate() external view returns(uint);
    function executerIndate() external view returns(uint);
    function isSenator(address) external returns(bool);
    function updateExecuter() external;
    function updateSenator() external;
}


contract Initialize {
    bool internal initialized;

    modifier init(){
        require(!initialized, "initialized");
        _;
        initialized = true;
    }
}


contract poc is Initialize{
    address public conf;

    forcedChangeExecuterProposal[] public fceps;

    enum Result{PENDING, SUCCESS, FAILED}


    struct forcedChangeExecuterProposal{
        uint epochId;
        uint executerId;
        address proposer;
        uint proposalTime;
        address[] assentors;
        address[] unAssentors;
        Result result;
    }

    event SendForcedChangeExecuterProposal(uint indexed index, uint indexed epochId, address proposer);

    modifier onlySenator{
        require(Isenator(Iconf(conf).senator()).isSenator(msg.sender), "only senators");
        _;
    }

    function initialize(address _conf) external init{
        conf = _conf;
    }


    function sendForcedChangeExecuterProposal() external onlySenator {
        require(isResolution(), "The latest proposal has no resolution");

        uint _epochId = Isenator(Iconf(conf).senator()).epochId();
        uint _executerId = Isenator(Iconf(conf).senator()).executerId();
        address[] memory nilArray;
        fceps.push(forcedChangeExecuterProposal(
                _epochId,
                _executerId,
                msg.sender,
                block.timestamp,
                nilArray,
                nilArray,
                Result.PENDING
            ));
        fceps[fceps.length -1].assentors.push(msg.sender);

        emit SendForcedChangeExecuterProposal(fceps.length-1, _executerId, msg.sender);
    }


    function isResolution() public view returns(bool){
        if (fceps.length == 0 || fceps[fceps.length-1].result != Result.PENDING) {
            return true;
        }else{
            return false;
        }
    }


    function vote(bool v) external onlySenator{
        Isenator Is = Isenator(Iconf(conf).senator());
        require(Is.isSenator(msg.sender), "access denied");
        require(!isResolution(), "Reached a consensus");
        for (uint i=0; i < fceps[fceps.length-1].assentors.length; i++){
            require(fceps[fceps.length-1].assentors[i] != msg.sender,  "multiple voting");
        }
        for (uint i=0; i < fceps[fceps.length-1].unAssentors.length; i++){
            require(fceps[fceps.length-1].unAssentors[i] != msg.sender,  "multiple voting");
        }

        if(v) {
            fceps[fceps.length-1].assentors.push(msg.sender);
            if (fceps[fceps.length-1].assentors.length >= Iconf(conf).offLine()){
                fceps[fceps.length-1].result = Result.SUCCESS;
                Is.updateExecuter();
            }
        }else{
            fceps[fceps.length-1].unAssentors.push(msg.sender);
            if (fceps[fceps.length-1].unAssentors.length >= Iconf(conf).offLine()) fceps[fceps.length-1].result = Result.FAILED;
        }

    }

    function veto() internal {
        if (fceps.length != 0) fceps[fceps.length-1].result = Result.FAILED;
    }


    function _veto() internal {
        Isnapshoot  It = Isnapshoot(Iconf(conf).snapshoot());
        if (!It.isResolution()) It.veto();
        if (!isResolution()) veto();
        }


    function updateExecuter() external{
        Isenator Is = Isenator(Iconf(conf).senator());
        Isnapshoot  It = Isnapshoot(Iconf(conf).snapshoot());
        if (msg.sender != Iconf(conf).snapshoot()) {
            require( block.timestamp > Is.executerIndate() || It.isOutLine(), "access denied");
            _veto();
        }


        if (block.timestamp > Is.epochIndate()){
            Is.updateSenator();
        }else{
            Is.updateExecuter();
        }

        //TODO: add award in the future
    }


    function updateSenator() external{
        _veto();
        Isenator(Iconf(conf).senator()).updateSenator();

        //TODO: add award in the future
    }
}