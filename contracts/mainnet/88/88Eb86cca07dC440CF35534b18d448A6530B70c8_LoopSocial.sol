// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;
import "./ILoopSocial.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import { DateTimeLibrary } from "./DateTimeLibrary.sol";

contract LoopSocial is Ownable,ILoopSocial{
    using SafeMath for uint256;

    mapping(address=>bool) public loopDaos;

    mapping(address=>mapping(uint256=>uint256))public everyDayInviterCount;
    mapping(address=>mapping(uint256=>bool))public inviterCountExist;

    mapping(address=>uint256) public inviterTotalAmount;
    mapping(address=>address) private inviter;
    mapping(uint256=>uint256) private accelerateTarget;

    event Activate(address user,address inviter);

    constructor(){
        accelerateTarget[1] = 500000   * 1e18;
        accelerateTarget[2] = 1000000  * 1e18;
        accelerateTarget[3] = 5000000  * 1e18;
        accelerateTarget[4] = 10000000 * 1e18;
        accelerateTarget[5] = 20000000 * 1e18;
        inviter[msg.sender] = 0x000000000000000000000000000000000000dEaD;
    }

    function notify(address sender, uint256 amount)external override{
        require(loopDaos[msg.sender],"sender is not loop dao contract");
        uint256 _theDay = _formatDateTime(block.timestamp);
        address _inviter = _getInviter(sender);

        if(!inviterCountExist[sender][_theDay]){
            everyDayInviterCount[_inviter][_theDay]+=1;
        }

        inviterCountExist[sender][_theDay] = true;

        address _cacheInviter = sender;
        for (uint i = 1; i <= 10; i++) {
            _cacheInviter = _getInviter(_cacheInviter);
            if(_cacheInviter == address(0)){
                break;
            }
            inviterTotalAmount[_cacheInviter] +=amount;
        }
        
    }

    //activate
    function activate(address _inviter) public returns (bool){
        require(msg.sender != _inviter,"The invitee cannot be himself.");
        require(inviter[msg.sender] == address(0),"Already activated.");
        require(inviter[_inviter] != address(0),"The invitee is not activated.");

        inviter[msg.sender] = _inviter;
        emit Activate(msg.sender,_inviter);
        return true;
    }

    function sync(address[] memory _userArray,address[] memory _inviterArray)public virtual onlyOwner returns(bool){
        for (uint i = 0; i < _userArray.length; i++) {
            inviter[_userArray[i]] = _inviterArray[i];
        }
        return true;
    }
  
    function getInviter(address _sender)external override view returns(address){
        return inviter[_sender];
    }

    function _getInviter(address _sender)internal view returns(address){
        return inviter[_sender];
    }

    function _formatDateTime(uint256 _timestamp)internal pure returns(uint256){
        (uint256 _y,uint256 _m,uint256 _d) = DateTimeLibrary.timestampToDate(_timestamp);
        return _y.mul(10000).add(_m.add(10).mul(100)).add(_d.add(10));
    }

    function _formatDateTimeByDay(uint256 _timestamp,uint256 _addDays)internal pure returns(uint256){
        return _formatDateTime(DateTimeLibrary.addDays(_timestamp, _addDays));
    }

    function _getInviterCountByTimestamp(address _user,uint256 _timestamp)internal view returns(uint256){
        uint256 _totalCount = everyDayInviterCount[_user][_formatDateTime(_timestamp)];
        for (uint i = 1; i < 5; i++) {
            _totalCount = _totalCount.add(everyDayInviterCount[_user][_formatDateTimeByDay(_timestamp,i)]);
        }
        return _totalCount;
    }

    function getRewardLevel(address _user,uint256 _timestamp)external view returns(uint256){
        return _getLevel(_getInviterCountByTimestamp(_user,_timestamp));
    }

    function _getLevel(uint256 _inviterCount)internal pure  returns(uint256){
        if(_inviterCount>1 && _inviterCount<8){
            return _inviterCount-1;
        }else if(_inviterCount>=8 && _inviterCount<10){
            return 7;
        }else if(_inviterCount>=10 && _inviterCount<12){
            return 8;
        }else if(_inviterCount>12 && _inviterCount<14){
            return 9;
        }else if(_inviterCount>=14){
            return 10;
        }
        return 0;
    }

    function getAccelerateReleaseRatio(address _user)external override view returns(uint256){
        uint256 inviterAmount = inviterTotalAmount[_user];
        if(inviterAmount>=accelerateTarget[1] && inviterAmount<accelerateTarget[2]){
            return 1;
        }else if(inviterAmount>=accelerateTarget[2] && inviterAmount<accelerateTarget[3]){
            return 5;
        }else if(inviterAmount>=accelerateTarget[3] && inviterAmount<accelerateTarget[4]){
            return 7;
        }else if(inviterAmount>=accelerateTarget[4] && inviterAmount<accelerateTarget[5]){
            return 10;
        }else if(inviterAmount>=accelerateTarget[5]){
            return 18;
        }
        return 0;
    }

    function setLoopDaoAddress(address _loopDaoAddress) public virtual onlyOwner returns(bool){
        if(loopDaos[_loopDaoAddress]){
             loopDaos[_loopDaoAddress] = false;
        }else{
            loopDaos[_loopDaoAddress] = true;
        }
        return true;
    }

    function setAccelerateTarget(uint256 _index,uint256 _accelerateTarget) public virtual onlyOwner returns(bool){
       accelerateTarget[_index] = _accelerateTarget;
        return true;
    }

}