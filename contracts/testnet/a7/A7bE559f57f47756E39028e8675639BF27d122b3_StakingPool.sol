/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

// SPDX-License-Identifier: MIT

//*************************************************************************************************//

// Provided by EarthWalkers Dev Team
// TG : https://t.me/officialearthwalktoken

// Part of the MoonWalkers Eco-system
// Website : https://moonwalkerstoken.com/
// TG : https://t.me/officialmoonwalkerstoken
// Contact us if you need to build a contract
// Contact TG : @chrissou78, Mail : [email protected]
// Full Crypto services : smart-contracts, website, launch and deploy, KYC, Audit, Vault, BuyBot
// Marketing : AMA , Calls, TG Management (bots, security, links)

// and our on demand personnalised Gear shop
// TG : https://t.me/cryptojunkieteeofficial

//*************************************************************************************************//

pragma solidity ^0.8.15;

library Address {
   
    function isContract(address account) internal view returns (bool) {return account.code.length > 0;}
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {return functionCall(target, data, "Address: low-level call failed");}
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {return functionCallWithValue(target, data, 0, errorMessage);}
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {return functionCallWithValue(target, data, value, "Address: low-level call with value failed");}
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {return functionStaticCall(target, data, "Address: low-level static call failed");}
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {return functionDelegateCall(target, data, "Address: low-level delegate call failed");}
    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
 
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {return returndata;} 
        else {
            if (returndata.length > 0) {assembly {let returndata_size := mload(returndata) revert(add(32, returndata), returndata_size)}
            } else {revert(errorMessage);}
        }
    }
}

interface IBEP20 {
    
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
 
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {_callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));}
    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {_callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));}

    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0), 'SafeBEP20: approve from non-zero to non-zero allowance');
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, 'SafeBEP20: decreased allowance below zero');
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');}
    }
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {_status = _NOT_ENTERED;}

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
    function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {_transferOwnership(_msgSender());}

    function owner() public view virtual returns (address) {return _owner;}

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {_transferOwnership(address(0));}

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract SharedOwnable is Ownable {
    address private _creator;
    mapping(address => bool) private _sharedOwners;
    event SharedOwnershipAdded(address indexed sharedOwner);

    constructor() Ownable() {
        _creator = msg.sender;
        _setSharedOwner(msg.sender);
        renounceOwnership();
    }
    modifier onlySharedOwners() {require(_sharedOwners[msg.sender], "SharedOwnable: caller is not a shared owner"); _;}
    function getCreator() external view returns (address) {return _creator;}
    function isSharedOwner(address account) external view returns (bool) {return _sharedOwners[account];}
    function setSharedOwner(address account) internal onlySharedOwners {_setSharedOwner(account);}
    function _setSharedOwner(address account) private {_sharedOwners[account] = true; emit SharedOwnershipAdded(account);}
    function EraseSharedOwner(address account) internal onlySharedOwners {_eraseSharedOwner(account);}
    function _eraseSharedOwner(address account) private {_sharedOwners[account] = false;}
}

contract SafeToken is SharedOwnable {
    address payable safeManager;
    constructor() {safeManager = payable(msg.sender);}
    function setSafeManager(address payable _safeManager) public onlySharedOwners {safeManager = _safeManager;}
    function withdraw(address _token, uint256 _amount) external { require(msg.sender == safeManager); IBEP20(_token).transfer(safeManager, _amount);}
    function withdrawBNB(uint256 _amount) external {require(msg.sender == safeManager); safeManager.transfer(_amount);}
}

contract StakingPool is SharedOwnable, ReentrancyGuard, SafeToken {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    address public SMART_CHEF_FACTORY;
    bool public hasUserLimit;
    bool public isInitialized;
    uint256 public accTokenPerShare;
    uint256 public EndBlock;
    uint256 public startBlock;
    uint256 public lastRewardBlock;
    uint256 public poolLimitPerUser;
    uint256 public rewardPerBlock;
    uint256 public lockTime;
    uint256 public PRECISION_FACTOR;
    IBEP20 public rewardToken;
    IBEP20 public stakedToken;
    address Creator;
    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt
        uint256 depositTime;    // The last time when the user deposit funds
    }

    event Deposit(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event NewRewardPerBlock(uint256 rewardPerBlock);
    event NewPoolLimit(uint256 poolLimitPerUser);
    event RewardsStop(uint256 blockNumber);
    event Withdraw(address indexed user, uint256 amount);
    event NewLockTime(uint256 lockTime);
    event setLockTime(address indexed user, uint256 lockTime);

    constructor() {Creator = msg.sender;}
    //******************************************************************************************************
    // Public functions
    //******************************************************************************************************
    function deposit(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        if (hasUserLimit) {require(_amount.add(user.amount) <= poolLimitPerUser, "User amount above limit");}
        _updatePool();

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
            if (pending > 0) {rewardToken.safeTransfer(address(msg.sender), pending);}
        }

        if (_amount > 0) {
            user.amount = user.amount.add(_amount);
            stakedToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.depositTime = block.timestamp; 
        }
        user.rewardDebt = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR);
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Amount to withdraw too high");
        require(user.depositTime + lockTime < block.timestamp, "Can not withdraw in lock period");
        _updatePool();
        uint256 pending = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            stakedToken.safeTransfer(address(msg.sender), _amount);
        }
        if (pending > 0) {rewardToken.safeTransfer(address(msg.sender), pending);}
        user.rewardDebt = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR);
        emit Withdraw(msg.sender, _amount);
    }

    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amountToTransfer = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        if (amountToTransfer > 0) {stakedToken.safeTransfer(address(msg.sender), amountToTransfer);}
        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 stakedTokenSupply = stakedToken.balanceOf(address(this));
        if (block.number > lastRewardBlock && stakedTokenSupply != 0) {
            uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
            uint256 appleReward = multiplier.mul(rewardPerBlock);
            uint256 adjustedTokenPerShare =
            accTokenPerShare.add(appleReward.mul(PRECISION_FACTOR).div(stakedTokenSupply));
            return user.amount.mul(adjustedTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
        } else {
            return user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
        }
    }

    function GetPoolInfo() external view returns(IBEP20 Token, IBEP20 Reward, uint EndDay, uint EndHour, uint EndMinute, uint EndSecond, uint256 Limit, uint256 LockTime, uint currentblock){
        uint256 Remaining = EndBlock + block.timestamp;
        uint Day = Remaining/86400;
        uint Hour = (Remaining-(Day*86400))/3600;
        uint Minute = (Remaining-(Day*86400)-(Hour*3600))/60;
        uint Second = Remaining-(Day*86400)-(Hour*3600)-(Minute*60);

        return(stakedToken, rewardToken, Day, Hour, Minute, Second, poolLimitPerUser, lockTime, block.number);
    }
    //******************************************************************************************************
    // Write OnlyOwners functions
    //******************************************************************************************************
    function initializePool(IBEP20 _stakedToken, IBEP20 _rewardToken, uint256 _rewardPerBlock, uint256 _startBlock, uint256 _EndBlock, uint256 _poolLimitPerUser, uint256 _lockTime, address _admin) external onlySharedOwners {
        //require(msg.sender == Creator,"Only Creator can initialise");
        require(!isInitialized, "Already initialized");
        isInitialized = true;
        stakedToken = _stakedToken; // @param _stakedToken: staked token address
        rewardToken = _rewardToken; // @param _rewardToken: reward token address
        rewardPerBlock = _rewardPerBlock; // @param _rewardPerBlock: reward per block (in rewardToken)
        startBlock = _startBlock; // @param _startBlock: start block
        EndBlock = _EndBlock; // @param _EndBlock: end block
        lockTime = _lockTime; // @param _poolLimitPerUser: pool limit per user in stakedToken (if any, else 0)

        if (_poolLimitPerUser > 0) {
            hasUserLimit = true;
            poolLimitPerUser = _poolLimitPerUser;
        }
        uint256 decimalsRewardToken = uint256(rewardToken.decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10**(uint256(30).sub(decimalsRewardToken)));
        lastRewardBlock = startBlock;
        setSharedOwner(_admin); // @param _admin: admin address with ownership
    }

    function ResetPool() external onlySharedOwners {
        require(msg.sender == Creator,"Only Creator can reset");
        isInitialized = false;
    }

    function stopReward() external onlySharedOwners {EndBlock = block.number;}

    function UpdatePool(bool _hasUserLimit, uint256 _poolLimitPerUser, uint256 _lockTime, uint256 _rewardPerBlock, uint256 _startBlock, uint256 _EndBlock) external onlySharedOwners {
        // Pool Limit per user
        if (_hasUserLimit) {
            require(_poolLimitPerUser > poolLimitPerUser, "New limit must be higher");
            poolLimitPerUser = _poolLimitPerUser;
        } else {
            hasUserLimit = _hasUserLimit;
            poolLimitPerUser = 0;
        }
        emit NewPoolLimit(poolLimitPerUser);

        if(_lockTime != 0) {
            lockTime = _lockTime;
            emit NewLockTime(_lockTime);
        }

        if(_rewardPerBlock != 0) {
            rewardPerBlock = _rewardPerBlock;
            emit NewRewardPerBlock(_rewardPerBlock);
        }
        if(_startBlock != 0) {
            require(_startBlock < _EndBlock, "New startBlock must be lower than new endBlock");
            require(block.number < _startBlock, "New startBlock must be higher than current block");

            startBlock = _startBlock;
            EndBlock = _EndBlock;
            lastRewardBlock = startBlock;
            emit NewStartAndEndBlocks(_startBlock, _EndBlock);
        }
    }
    //******************************************************************************************************
    // Internal functions
    //******************************************************************************************************
    function _updatePool() internal {
        if (block.number <= lastRewardBlock) {return;}
        uint256 stakedTokenSupply = stakedToken.balanceOf(address(this));
        if (stakedTokenSupply == 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
        uint256 appleReward = multiplier.mul(rewardPerBlock);
        accTokenPerShare = accTokenPerShare.add(appleReward.mul(PRECISION_FACTOR).div(stakedTokenSupply));
        lastRewardBlock = block.number;
    }

    function _getMultiplier(uint256 _from, uint256 _to) internal view returns (uint256) {
        if (_to <= EndBlock) {return _to.sub(_from);} 
        else if (_from >= EndBlock) {return 0;} 
        else {return EndBlock.sub(_from);}
    }
}