// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import './interfaces/IGameFiDaoPoolsV1.sol';
import './library/ErrorCode.sol';
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

contract GameFiDaoPoolsV1 is IGameFiDaoPoolsV1 {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    uint256 public deployBlock;
    address public owner;
    mapping(address => bool) public operateOwner;
    address public gameFiDaoAddress;//gameFi dao
    address public gameFiDaoToken;//gameFi dao

    uint256 public poolCount = 0;
    mapping(address => RewardInfo) public rewardInfos;//User mining information
    mapping(uint256 => PoolInfo) public poolInfos;
    mapping(uint256 => PoolViewInfo) public poolViewInfos;
    mapping(uint256 => address[]) public pledgeAddresss;
    mapping(uint256 => mapping(address => UserInfo)) public pledgeUserInfo;


    uint256 public rewardTotal = 0;//Total mining bonus

    constructor (address _gameFiDaoAddress,address _gameFiDaoToken) {
        deployBlock = block.number;
        owner = msg.sender;
        gameFiDaoAddress = _gameFiDaoAddress;
        gameFiDaoToken = _gameFiDaoToken;
        _setOperateOwner(owner, true);
    }

    ////////////////////////////////////////////////////////////////////////////////////

    function transferOwnership(address _owner) override external {
        require(owner == msg.sender, ErrorCode.FORBIDDEN);
        require((address(0) != _owner) && (owner != _owner), ErrorCode.INVALID_ADDRESSES);
        _setOperateOwner(owner, false);
        _setOperateOwner(_owner, true);
        owner = _owner;
    }

    function setGameFiDaoAddress(address _gameFiDaoAddress) override external {
        _setGameFiDaoAddress(_gameFiDaoAddress);
    }
    
    function _setGameFiDaoAddress(address _gameFiDaoAddress) internal {
        require(owner == msg.sender, ErrorCode.FORBIDDEN);
        gameFiDaoAddress = _gameFiDaoAddress;
    }

    function setGameFiDaoToken(address _gameFiDaoToken) override external {
        _setGameFiDaoToken(_gameFiDaoToken);
    }

    function _setGameFiDaoToken(address _gameFiDaoToken) internal {
        require(owner == msg.sender, ErrorCode.FORBIDDEN);
        gameFiDaoToken = _gameFiDaoToken;
    }
    
    function deposit(uint256 _pool, uint256 _amount) override external {
        require(0 < _amount, ErrorCode.FORBIDDEN);
        PoolInfo storage poolInfo = poolInfos[_pool];
        require(address(0) != poolInfo.lp, ErrorCode.LP_ERROR);
        //require(0 == poolInfo.endBlock, ErrorCode.END_OF_MINING);
        if(poolInfo.depositLimit > 0){
            require(_amount == poolInfo.depositLimit, ErrorCode.DEPOSIT_LIMIT_ERROR);
        }
        if(poolInfo.depositMaxLimit > 0){
            require(poolInfo.amount.add(_amount) <= poolInfo.depositMaxLimit,ErrorCode.DEPOSIT_MAX_LIMIT_ERROR);
        }

        UserInfo storage userInfo = pledgeUserInfo[_pool][msg.sender];
        require(userInfo.amount == 0,ErrorCode.USER_HAD_DEPOSIT_ERROR);

        IERC20(poolInfo.lp).safeTransferFrom(msg.sender, address(this), _amount);

        computeReward(_pool);

        provideReward(_pool, poolInfo.rewardPerShare, poolInfo.lp, msg.sender);

        addPower(_pool, msg.sender, _amount);

        setRewardDebt(_pool, poolInfo.rewardPerShare, msg.sender);

        emit Stake(_pool, poolInfo.lp, msg.sender, _amount);
    }

    function withdraw(uint256 _pool, uint256 _amount) override external {
        PoolInfo storage poolInfo = poolInfos[_pool];
        require((address(0) != poolInfo.lp) && (poolInfo.startBlock <= block.number), ErrorCode.MINING_NOT_STARTED);
        if (0 < _amount) {
            UserInfo storage userInfo = pledgeUserInfo[_pool][msg.sender];
            require(_amount <= userInfo.amount, ErrorCode.BALANCE_INSUFFICIENT);
            require(block.timestamp >= poolInfo.lockTime,ErrorCode.LOCKTIME_ERROR);
        }


        computeReward(_pool);

        provideReward(_pool, poolInfo.rewardPerShare, poolInfo.lp, msg.sender);

        if (0 < _amount) {
            subPower(_pool, msg.sender, _amount);
        }

        setRewardDebt(_pool, poolInfo.rewardPerShare, msg.sender);

        if (0 < _amount) {
            IERC20(poolInfo.lp).safeTransfer(msg.sender, _amount);

            emit UnStake(_pool, poolInfo.lp, msg.sender, _amount);
        }
    }

    function poolPledgeAddresss(uint256 _pool) override external view returns (address[] memory) {
        return pledgeAddresss[_pool];
    }

    function getPledgeUserInfoList(uint256 _pool) override external view returns (UserViewInfo[] memory) {
        uint256 kl = pledgeAddresss[_pool].length;
        UserViewInfo [] memory userViewInfos;
        if(kl > 0)
        {
            userViewInfos = new UserViewInfo[](kl);
            for(uint256 i=0;i<kl;i++)
            {
                UserViewInfo memory uvi;
                uvi.user = pledgeAddresss[_pool][i];
                uvi.amount = pledgeUserInfo[_pool][uvi.user].amount;
                uvi.startBlock = pledgeUserInfo[_pool][uvi.user].startBlock;
                uvi.pledgePower = pledgeUserInfo[_pool][uvi.user].pledgePower;
                uvi.pendingReward = pledgeUserInfo[_pool][uvi.user].pendingReward;
                uvi.pledgeRewardDebt = pledgeUserInfo[_pool][uvi.user].pledgeRewardDebt;
                userViewInfos[i] = uvi;
            }
        }
        return userViewInfos;

    }

    function computeReward(uint256 _pool) internal {
        PoolInfo storage poolInfo = poolInfos[_pool];
        if ((0 < poolInfo.totalPower) && (poolInfo.rewardProvide < poolInfo.rewardTotal) && (poolInfo.startBlock <= block.number)) {
            uint256 reward = (block.number - poolInfo.lastRewardBlock).mul(poolInfo.rewardPerBlock);
            if (poolInfo.rewardProvide.add(reward) > poolInfo.rewardTotal) {
                reward = poolInfo.rewardTotal.sub(poolInfo.rewardProvide);
                poolInfo.endBlock = block.number;
            }

            rewardTotal = rewardTotal.add(reward);
            poolInfo.rewardProvide = poolInfo.rewardProvide.add(reward);
            poolInfo.rewardPerShare = poolInfo.rewardPerShare.add(reward.mul(1e24).div(poolInfo.totalPower));
            poolInfo.lastRewardBlock = block.number;

            emit Mint(_pool, poolInfo.lp, reward);

            if (0 < poolInfo.endBlock) {
                emit EndPool(_pool, poolInfo.lp);
            }
        }
    }

    function addPower(uint256 _pool, address _user, uint256 _amount) internal {
        PoolInfo storage poolInfo = poolInfos[_pool];
        poolInfo.amount = poolInfo.amount.add(_amount);

        uint256 pledgePower = _amount;
        UserInfo storage userInfo = pledgeUserInfo[_pool][_user];            
        userInfo.amount = userInfo.amount.add(_amount);
        userInfo.pledgePower = userInfo.pledgePower.add(pledgePower);
        poolInfo.totalPower = poolInfo.totalPower.add(pledgePower);
        if (0 == userInfo.startBlock) {
            userInfo.startBlock = block.number;
            pledgeAddresss[_pool].push(msg.sender);
        }

        emit UpdatePower(_pool, poolInfo.lp, poolInfo.totalPower, _user, userInfo.pledgePower);
    }

    function subPower(uint256 _pool, address _user, uint256 _amount) internal {
        PoolInfo storage poolInfo = poolInfos[_pool];
        UserInfo storage userInfo = pledgeUserInfo[_pool][_user];
        if (poolInfo.amount < _amount) {
            poolInfo.amount = 0;
        }else {
            poolInfo.amount = poolInfo.amount.sub(_amount);
        }

        uint256 pledgePower = _amount;
        userInfo.amount = userInfo.amount.sub(_amount);
        if (userInfo.pledgePower < pledgePower) {
            userInfo.pledgePower = 0;
        }else {
            userInfo.pledgePower = userInfo.pledgePower.sub(pledgePower);
        }
        if (poolInfo.totalPower < pledgePower) {
            poolInfo.totalPower = 0;
        }else {
            poolInfo.totalPower = poolInfo.totalPower.sub(pledgePower);    
        }

        emit UpdatePower(_pool, poolInfo.lp, poolInfo.totalPower, _user, userInfo.pledgePower);
    }

    function provideReward(uint256 _pool, uint256 _rewardPerShare, address _lp, address _user) internal {
        uint256 pledgeReward = 0;
        UserInfo storage userInfo = pledgeUserInfo[_pool][_user];
        if (0 < userInfo.pledgePower) {
            pledgeReward = userInfo.pledgePower.mul(_rewardPerShare).sub(userInfo.pledgeRewardDebt).div(1e24);

            userInfo.pendingReward = userInfo.pendingReward.add(pledgeReward);

            RewardInfo storage userRewardInfo = rewardInfos[_user];
            userRewardInfo.pledgeReward = userRewardInfo.pledgeReward.add(pledgeReward);
        }

        if (0 < userInfo.pendingReward) {
            IERC20(gameFiDaoToken).safeTransferFrom(gameFiDaoAddress, _user, userInfo.pendingReward);

            emit WithdrawReward(_pool, _lp, _user, userInfo.pendingReward);

            userInfo.pendingReward = 0;
        }

    }

    function setRewardDebt(uint256 _pool, uint256 _rewardPerShare, address _user) internal {
        UserInfo storage userInfo = pledgeUserInfo[_pool][_user];
        userInfo.pledgeRewardDebt = userInfo.pledgePower.mul(_rewardPerShare);
    }
    
    function powerScale(uint256 _pool, address _user) override external view returns (uint256) {
        PoolInfo memory poolInfo = poolInfos[_pool];
        if (0 == poolInfo.totalPower) {
            return 0;
        }

        UserInfo memory userInfo = pledgeUserInfo[_pool][_user];
        return (userInfo.pledgePower.mul(100)).div(poolInfo.totalPower);
    }

    function pendingReward(uint256 _pool, address _user) override external view returns (uint256) {
        uint256 totalReward = 0;
        PoolInfo memory poolInfo = poolInfos[_pool];
        if (address(0) != poolInfo.lp && (poolInfo.startBlock <= block.number)) {
            uint256 rewardPerShare = 0;
            if (0 < poolInfo.totalPower) {
                uint256 reward = (block.number - poolInfo.lastRewardBlock).mul(poolInfo.rewardPerBlock);
                if (poolInfo.rewardProvide.add(reward) > poolInfo.rewardTotal) {
                    reward = poolInfo.rewardTotal.sub(poolInfo.rewardProvide);
                }
                rewardPerShare = reward.mul(1e24).div(poolInfo.totalPower);
            }
            rewardPerShare = rewardPerShare.add(poolInfo.rewardPerShare);

            UserInfo memory userInfo = pledgeUserInfo[_pool][_user];
            totalReward = userInfo.pendingReward;
            totalReward = totalReward.add(userInfo.pledgePower.mul(rewardPerShare).sub(userInfo.pledgeRewardDebt).div(1e24));
        }

        return totalReward;
    }



    function poolNumbers(address _lp) override external view returns (uint256[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < poolCount; i++) {
            if (_lp == poolViewInfos[i].lp) {
                count = count.add(1);
            }
        }
        
        uint256[] memory numbers = new uint256[](count);
        count = 0;
        for (uint256 i = 0; i < poolCount; i++) {
            if (_lp == poolViewInfos[i].lp) {
                numbers[count] = i;
                count = count.add(1);
            }
        }

        return numbers;
    }

    function setOperateOwner(address _address, bool _bool) override external {
        _setOperateOwner(_address, _bool);
    }
    
    function _setOperateOwner(address _address, bool _bool) internal {
        require(owner == msg.sender, ErrorCode.FORBIDDEN);
        operateOwner[_address] = _bool;
    }

    ////////////////////////////////////////////////////////////////////////////////////

    function addPool(string memory _name, address _lp, uint256 _startBlock, uint256 _rewardTotal,
        uint256 _rewardPerBlock, uint256 _multiple,uint256 depositLimit,uint256 lockTime,uint256 depositMaxLimit) override external returns (bool) {
        require(operateOwner[msg.sender] && (address(0) != _lp) && (address(this) != _lp), ErrorCode.FORBIDDEN);
        _startBlock = _startBlock < block.number ? block.number : _startBlock;
        uint256 _pool = poolCount;
        poolCount = poolCount.add(1);

        PoolViewInfo storage poolViewInfo = poolViewInfos[_pool];
        poolViewInfo.lp = _lp;
        poolViewInfo.name = _name;
        poolViewInfo.multiple = _multiple;
        poolViewInfo.priority = _pool.mul(100).add(50);
        
        PoolInfo storage poolInfo = poolInfos[_pool];
        poolInfo.startBlock = _startBlock;
        poolInfo.rewardTotal = _rewardTotal;
        poolInfo.rewardProvide = 0;
        poolInfo.lp = _lp;
        poolInfo.amount = 0;
        poolInfo.lastRewardBlock = _startBlock.sub(1);
        poolInfo.rewardPerBlock = _rewardPerBlock;
        poolInfo.totalPower = 0;
        poolInfo.endBlock = 0;
        poolInfo.rewardPerShare = 0;
        poolInfo.depositLimit = depositLimit;
        poolInfo.lockTime = lockTime;
        poolInfo.depositMaxLimit = depositMaxLimit;

        emit UpdatePool(true, _pool, poolInfo.lp, poolViewInfo.name, poolInfo.startBlock, poolInfo.rewardTotal, poolInfo.rewardPerBlock, poolViewInfo.multiple, poolViewInfo.priority);

        return true;
    }
    
    function setRewardPerBlock(uint256 _pool, uint256 _rewardPerBlock) override external {
        require(operateOwner[msg.sender], ErrorCode.FORBIDDEN);
        PoolInfo storage poolInfo = poolInfos[_pool];
        require((address(0) != poolInfo.lp) && (0 == poolInfo.endBlock), ErrorCode.POOL_NOT_EXIST_OR_END_OF_MINING);
        
        computeReward(_pool);
        
        poolInfo.rewardPerBlock = _rewardPerBlock;

        PoolViewInfo memory poolViewInfo = poolViewInfos[_pool];

        emit UpdatePool(false, _pool, poolInfo.lp, poolViewInfo.name, poolInfo.startBlock, poolInfo.rewardTotal, poolInfo.rewardPerBlock, poolViewInfo.multiple, poolViewInfo.priority);
    }
    
    function setRewardTotal(uint256 _pool, uint256 _rewardTotal) override external {
        require(operateOwner[msg.sender], ErrorCode.FORBIDDEN);
        PoolInfo storage poolInfo = poolInfos[_pool];
        require((address(0) != poolInfo.lp) && (0 == poolInfo.endBlock), ErrorCode.POOL_NOT_EXIST_OR_END_OF_MINING);

        computeReward(_pool);
        
        require(poolInfo.rewardProvide < _rewardTotal, ErrorCode.REWARDTOTAL_LESS_THAN_REWARDPROVIDE);
        
        poolInfo.rewardTotal = _rewardTotal;

        PoolViewInfo memory poolViewInfo = poolViewInfos[_pool];

        emit UpdatePool(false, _pool, poolInfo.lp, poolViewInfo.name, poolInfo.startBlock, poolInfo.rewardTotal, poolInfo.rewardPerBlock, poolViewInfo.multiple, poolViewInfo.priority);
   }

   function setName(uint256 _pool, string memory _name) override external {
        require(operateOwner[msg.sender], ErrorCode.FORBIDDEN);
        PoolViewInfo storage poolViewInfo = poolViewInfos[_pool];
        require(address(0) != poolViewInfo.lp, ErrorCode.POOL_NOT_EXIST_OR_END_OF_MINING);
        poolViewInfo.name = _name;

        PoolInfo memory poolInfo = poolInfos[_pool];

        emit UpdatePool(false, _pool, poolInfo.lp, poolViewInfo.name, poolInfo.startBlock, poolInfo.rewardTotal, poolInfo.rewardPerBlock, poolViewInfo.multiple, poolViewInfo.priority);
   }

   function setMultiple(uint256 _pool, uint256 _multiple) override external {
        require(operateOwner[msg.sender], ErrorCode.FORBIDDEN);
        PoolViewInfo storage poolViewInfo = poolViewInfos[_pool];
        require(address(0) != poolViewInfo.lp, ErrorCode.POOL_NOT_EXIST_OR_END_OF_MINING);
        poolViewInfo.multiple = _multiple;

        PoolInfo memory poolInfo = poolInfos[_pool];

        emit UpdatePool(false, _pool, poolInfo.lp, poolViewInfo.name, poolInfo.startBlock, poolInfo.rewardTotal, poolInfo.rewardPerBlock, poolViewInfo.multiple, poolViewInfo.priority);
    }

    function setPriority(uint256 _pool, uint256 _priority) override external {
        require(operateOwner[msg.sender], ErrorCode.FORBIDDEN);
        PoolViewInfo storage poolViewInfo = poolViewInfos[_pool];
        require(address(0) != poolViewInfo.lp, ErrorCode.POOL_NOT_EXIST_OR_END_OF_MINING);
        poolViewInfo.priority = _priority;

        PoolInfo memory poolInfo = poolInfos[_pool];

        emit UpdatePool(false, _pool, poolInfo.lp, poolViewInfo.name, poolInfo.startBlock, poolInfo.rewardTotal, poolInfo.rewardPerBlock, poolViewInfo.multiple, poolViewInfo.priority);
    }

    ////////////////////////////////////////////////////////////////////////////////////

}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import './../interfaces/ITokenGameFi.sol';

interface IGameFiDaoPoolsV1 {

    struct RewardInfo {
        uint256 receiveReward;//receiveReward
        uint256 pledgeReward;//pledgeReward
    }

    struct UserInfo {
        uint256 startBlock;
        uint256 amount;
        uint256 pledgePower;
        uint256 pendingReward;
        uint256 pledgeRewardDebt;
    }

    struct UserViewInfo {
        address user;
        uint256 startBlock;
        uint256 amount;
        uint256 pledgePower;
        uint256 pendingReward;
        uint256 pledgeRewardDebt;
    }


    struct PoolViewInfo {
        address lp;
        string name;
        uint256 multiple;
        uint256 priority;
    }

    struct PoolInfo {
        uint256 startBlock;
        uint256 rewardTotal;
        uint256 rewardProvide;
        address lp;
        uint256 amount;
        uint256 lastRewardBlock;
        uint256 rewardPerBlock;
        uint256 totalPower;
        uint256 endBlock;
        uint256 rewardPerShare;
        uint256 depositLimit;
        uint256 lockTime;
        uint256 depositMaxLimit;
    }

    ////////////////////////////////////////////////////////////////////////////////////

    event UpdatePool(bool action, uint256 pool, address indexed lp, string name, uint256 startBlock, uint256 rewardTotal, uint256 rewardPerBlock, uint256 multiple, uint256 priority);

    event EndPool(uint256 pool, address indexed lp);

    event Stake(uint256 pool, address indexed lp, address indexed from, uint256 amount);

    event UpdatePower(uint256 pool, address lp, uint256 totalPower, address indexed owner, uint256 ownerPledgePower);

    event UnStake(uint256 pool, address indexed lp, address indexed to, uint256 amount);

    event WithdrawReward(uint256 pool, address indexed lp, address indexed to, uint256 amount);

    event Mint(uint256 pool, address indexed lp, uint256 amount);
    
    ////////////////////////////////////////////////////////////////////////////////////

    function transferOwnership(address) external;

    function setGameFiDaoAddress(address _gameFiDaoAddress) external;

    function setGameFiDaoToken(address _gameFiDaoToken) external;

    function deposit(uint256, uint256) external;

    function withdraw(uint256, uint256) external;

    function poolPledgeAddresss(uint256) external view returns (address[] memory);

    function getPledgeUserInfoList(uint256 ) external view returns (UserViewInfo[] memory);

    function powerScale(uint256, address) external view returns (uint256);

    function pendingReward(uint256, address) external view returns (uint256);

    function poolNumbers(address) external view returns (uint256[] memory);

    function setOperateOwner(address, bool) external;

    ////////////////////////////////////////////////////////////////////////////////////    

    function addPool(string memory, address, uint256, uint256, uint256, uint256,uint256,uint256,uint256) external returns (bool);

    function setRewardPerBlock(uint256, uint256) external;

    function setRewardTotal(uint256, uint256) external;

    function setName(uint256, string memory) external;

    function setMultiple(uint256, uint256) external;

    function setPriority(uint256, uint256) external;
    
    ////////////////////////////////////////////////////////////////////////////////////
    
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;

library ErrorCode {

    string constant FORBIDDEN = 'GameFi:FORBIDDEN';
    string constant IDENTICAL_ADDRESSES = 'GameFi:IDENTICAL_ADDRESSES';
    string constant ZERO_ADDRESS = 'GameFi:ZERO_ADDRESS';
    string constant INVALID_ADDRESSES = 'GameFi:INVALID_ADDRESSES';
    string constant BALANCE_INSUFFICIENT = 'GameFi:BALANCE_INSUFFICIENT';
    string constant REWARDTOTAL_LESS_THAN_REWARDPROVIDE = 'GameFi:REWARDTOTAL_LESS_THAN_REWARDPROVIDE';
    string constant PARAMETER_TOO_LONG = 'GameFi:PARAMETER_TOO_LONG';
    string constant REGISTERED = 'GameFi:REGISTERED';
    string constant MINING_NOT_STARTED = 'GameFi:MINING_NOT_STARTED';
    string constant END_OF_MINING = 'GameFi:END_OF_MINING';
    string constant POOL_NOT_EXIST_OR_END_OF_MINING = 'GameFi:POOL_NOT_EXIST_OR_END_OF_MINING';
    string constant ONE_ADDRESS_AMOUNT_LIMIT = 'GameFi:ONE_ADDRESS_AMOUNT_LIMIT';
    string constant ONE_ADDRESS_AMOUNT_ERROR = 'GameFi:ONE_ADDRESS_AMOUNT_ERROR';
    string constant LAST_STAKE_TIME_ERROR = 'GameFi:LAST_STAKE_TIME_ERROR';
    string constant DEPOSIT_LIMIT_ERROR = 'GameFi:DEPOSIT_LIMIT_ERROR';
    string constant DEPOSIT_MAX_LIMIT_ERROR = 'GameFi:DEPOSIT_MAX_LIMIT_ERROR';
    string constant LOCKTIME_ERROR = 'GameFi:LOCKTIME_ERROR';
    string constant USER_HAD_DEPOSIT_ERROR = 'GameFi:USER_HAD_DEPOSIT_ERROR';
    string constant LP_ERROR = 'GameFi:LP_ERROR';
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;

interface ITokenGameFi {
    
    function mint(address recipient, uint256 amount) external;
    
    function decimals() external view returns (uint8);
    
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}