/**
 *Submitted for verification at BscScan.com on 2022-02-28
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
        if (!Isnapshoot(Iconf(conf).snapshoot()).isResolution()) Isnapshoot(Iconf(conf).snapshoot()).veto(); 
        //if (!Iupgrade(Iconf(conf).upgrade()).isResolution()) Iupgrade(Iconf(conf).upgrade()).veto();
    }

    //更新执法者
    function updateExecuter() external{
        Isenator Is = Isenator(Iconf(conf).senator());
        emit log("1");
        require( block.timestamp > Is.executerIndate() || Isnapshoot(Iconf(conf).snapshoot()).isOutLine(), "access denied");
        emit log("2");
        _veto();
       emit log("3");
        if (block.timestamp > Is.epochIndate()){
            emit log("4");
            Is.updateSenator();
        }else{
            emit log("5");
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