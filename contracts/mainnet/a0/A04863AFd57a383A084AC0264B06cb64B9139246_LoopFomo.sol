// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

import "./IFomo.sol";
import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./Pausable.sol";

contract LoopFomo is IFomo,Ownable,Pausable{
    using SafeMath for uint256;
    
    address public tokenAddress;
    uint256 public rewardBalance;

    struct TransferInfo{
        address _user;
        uint256 _time;
        uint256 _amount;
        bool _ok;
    }
    
    mapping(address=>uint256)public minFomoAmount;
    mapping(address=>bool) public loopDaos;
    mapping(address=>mapping(uint256=>TransferInfo)) public transferInfoQueue;

    mapping(address => uint256) public userFomoBalance;
    mapping(address => uint256) public poolFomoBalance;

    mapping(address => uint256) public userHistoryFomoAmount;
    mapping(address => uint256) public poolHistoryFomoAmount;

    uint256 public userTotalRewardBalance;

    constructor(address _tokenAddress){
        tokenAddress = _tokenAddress;
    }

    event PushTransferInfo(address sender,uint256 amount,uint256 timestamp);

    function notifyTransferInfo(address sender, uint256 amount)external override returns(bool){
        require(loopDaos[msg.sender],"sender is not loop dao contract");
        if(amount >= minFomoAmount[msg.sender]){
             _pushTransferInfo(msg.sender,sender,amount);
        }
        return true;
    }

    function notifyFomoBalance(uint256 amount)external override returns(bool){
        require(loopDaos[msg.sender],"sender is not loop dao contract");
        poolFomoBalance[msg.sender] +=  amount;
        return true;
    }

    function getPoolFoboBalance(address _loopDaoContract)public view returns(uint256){
        return userFomoBalance[_loopDaoContract];
    }

    function getUserFomoBalance(address _user)public view returns(uint256){
        return userFomoBalance[_user];
    }

    function getHistoryPoolFomoBalance(address _loopDaoContract)public view returns(uint256){
        return poolHistoryFomoAmount[_loopDaoContract];
    }

    function getHistoryUserFomoBalance(address _user)public view returns(uint256){
        return userHistoryFomoAmount[_user];
    }

    function getTransferInfoQueueByIndex(address _fromContract,uint256 _index)public view returns(TransferInfo memory){
        return transferInfoQueue[_fromContract][_index];
    }

    function _pushTransferInfo(address _fromContract,address _sender,uint256 _uAmount)internal{
        for (uint i = 10; i >1; i--){
            transferInfoQueue[_fromContract][i] = transferInfoQueue[_fromContract][i-1];
        }
        
        uint256 cuttentTime = block.timestamp;
        transferInfoQueue[_fromContract][1] = TransferInfo({
            _user:_sender,
            _time:cuttentTime,
            _amount:_uAmount,
            _ok: true
        });

        emit PushTransferInfo(_sender,_uAmount,cuttentTime);
    }

    function _rewardTo(address to,uint256 amount)internal{
        if(amount >0){
            IERC20(tokenAddress).transfer(to, amount);
        }
    }

    function reward() external override returns(bool){
        address dao = msg.sender;
        require(loopDaos[dao],"sender is not loop dao contract");
        uint256 contractBalance = IERC20(tokenAddress).balanceOf(address(this));
        uint256 rewardAmount = poolFomoBalance[dao];
        if(contractBalance>0 && contractBalance>=rewardAmount){
            if(transferInfoQueue[dao][1]._ok){
                uint256 reward1Amount = rewardAmount.div(10000).mul(3000);
                 _addFomoBalance(dao,transferInfoQueue[dao][1]._user,reward1Amount);
            }

            uint256 reward2Amount = rewardAmount.div(10000).mul(3000);
            uint256 total23 = transferInfoQueue[dao][2]._amount.add(transferInfoQueue[dao][3]._amount);
            if(transferInfoQueue[dao][2]._ok){
                _addFomoBalance(dao,transferInfoQueue[dao][2]._user,reward2Amount.mul(transferInfoQueue[dao][2]._amount).div(total23));
            }
            if(transferInfoQueue[dao][3]._ok){
                _addFomoBalance(dao,transferInfoQueue[dao][3]._user,reward2Amount.mul(transferInfoQueue[dao][3]._amount).div(total23));
            }

            uint256 reward3Amount = rewardAmount.div(10000).mul(4000);
            uint256 total456789 = 0;
            for (uint i = 4; i <=10; i++){
                total456789 = total456789.add(transferInfoQueue[dao][i]._amount);
            }

            for (uint i = 4; i <=10; i++){
                if(transferInfoQueue[dao][i]._ok){
                    _addFomoBalance(dao,transferInfoQueue[dao][i]._user,reward3Amount.mul(transferInfoQueue[dao][i]._amount).div(total456789));
                }
            }
            return true;
        }
        return false;
    }

    function _addFomoBalance(address _dao, address _user,uint256 amount)internal{
        userFomoBalance[_user] += amount;
        
        userTotalRewardBalance += amount;
        poolFomoBalance[_dao] -= amount;

        userHistoryFomoAmount[_user] += amount;
        poolHistoryFomoAmount[_dao] += amount;
    }

    //withdraw
    function withdraw() public whenNotPaused returns (bool){
        require(userFomoBalance[msg.sender]>0,"Fomo balance is 0");
        _rewardTo(msg.sender,userFomoBalance[msg.sender]);
        userTotalRewardBalance -= userFomoBalance[msg.sender];
        userFomoBalance[msg.sender] = 0;
        return true;
    }

    function clear()external override returns (bool){
        require(loopDaos[msg.sender],"sender is not loop dao contract");
        for (uint i = 1; i <= 10; i++){
            transferInfoQueue[msg.sender][i]._ok = false;
        }
        return true;
    }

    function setTokenAddress(address _tokenAddress) public virtual onlyOwner returns(bool){
        tokenAddress = _tokenAddress;
        return true;
    }

    function setLoopDaoAddress(address _loopDaoAddress,uint256 _minAmount) public virtual onlyOwner returns(bool){
        if(loopDaos[_loopDaoAddress]){
             loopDaos[_loopDaoAddress] = false;
        }else{
            loopDaos[_loopDaoAddress] = true;
            minFomoAmount[_loopDaoAddress] = _minAmount;
        }
        
        return true;
    }

}