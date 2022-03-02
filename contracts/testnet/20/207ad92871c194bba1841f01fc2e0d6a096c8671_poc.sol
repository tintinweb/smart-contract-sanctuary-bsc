/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Iconf{
    function senator() external view returns(address);
    function snapshoot() external view returns(address);
    function upgrade() external view returns(address);
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
    function epochIndate() external view returns(uint);
    function executerIndate() external view returns(uint);
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
    event log(string);

    function initialize(address _conf) external init{
        conf = _conf;
    }

    //一票否决还未通过的提案
    function _veto() internal {
        Isnapshoot  It = Isnapshoot(Iconf(conf).snapshoot());
        if (!It.isResolution()) It.veto(); 
        //if (!Iupgrade(Iconf(conf).upgrade()).isResolution()) Iupgrade(Iconf(conf).upgrade()).veto();
    }

    //更新执法者
    function updateExecuter() external{
        Isenator Is = Isenator(Iconf(conf).senator());
        Isnapshoot  It = Isnapshoot(Iconf(conf).snapshoot());
        require( block.timestamp > Is.executerIndate() || It.isOutLine(), "access denied");
        
        _veto();
    
        if (block.timestamp > Is.epochIndate()){
            Is.updateSenator();
        }else{
            Is.updateExecuter();
        }

        //TODO: 添加奖励
    }


    //更新共识集
    function updateSenator() external{
        _veto();
        Isenator(Iconf(conf).senator()).updateSenator();

        //TODO: 添加奖励
    }
}