/**
 *Submitted for verification at BscScan.com on 2022-02-15
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
        require(
            //执法者到期
            block.timestamp > Isenator(Iconf(conf).senator()).executerIndate() ||
            //执法者违规
            Isnapshoot(Iconf(conf).snapshoot()).isOutLine(), 
            "access denied"
        );

        _veto();
       
        if (block.timestamp > Isenator(Iconf(conf).senator()).epochIndate()){
            Isenator(Iconf(conf).senator()).updateSenator();
        }else{
            Isenator(Iconf(conf).senator()).updateExecuter();
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