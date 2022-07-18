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
        assembly {
            size := extcodesize(account)
        }
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
        (bool success, ) = recipient.call{value: amount}("");
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

interface Staking {
    function setStakeBalance(address staker) external;
}

contract EWStakingPool is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    
    // treasury Subscription info
    address public treasury = 0x4aAB4ED440A8406eC15C140e3627dfc7701B9D0F;
    uint256 public subFee = 0;    
    uint256 public subEndBlock = 0;
    uint256 public subLengthDays = 60;
    address public subOperator;
    
    // staking fee info
    address public feeReceiver = 0x4aAB4ED440A8406eC15C140e3627dfc7701B9D0F;
    uint256 public stakingFee = 0;
    uint256 public unstakingFee = 0;

    bool public hasUserLimit;
    bool public isInitialized;
    uint256 public accTokenPerShare;
    uint256 public bonusEndBlock;
    uint256 public startBlock;
    uint256 public lastRewardBlock;
    uint256 public poolLimitPerUser;
    uint256 public rewardPerBlock;
    uint256 public PRECISION_FACTOR;
    IBEP20 public rewardToken;
    IBEP20 public stakedToken;
    uint256 public extraTokens;
    uint256 public totalNewReward;
    uint256 public totalStaked;
    uint256 private lockTime;
    uint256 public prevAndCurrentRewardsBalance;
    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt
        uint256 depositTime;    // The last time when the user deposit funds
    }

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event NewRewardPerBlock(uint256 rewardPerBlock);
    event NewPoolLimit(uint256 poolLimitPerUser);
    event RewardsStop(uint256 blockNumber);
    event Withdraw(address indexed user, uint256 amount);
    event NewLockTime(uint256 lockTime);
    // Subscription
    modifier onlySub() {
      require(msg.sender == subOperator || msg.sender == owner());
      _;
    }
    
    //constructor() {}

    receive() external payable {}
    //******************************************************************************************************
    // Owner functions
    //******************************************************************************************************
    
    function setSubOperator(address newSubOperator) public onlyOwner {
      require(subOperator != newSubOperator, "Already set to this");
      subOperator = newSubOperator;
    }
    
    function initializePool(IBEP20 _stakedToken, IBEP20 _rewardToken, uint256 _lockTime, address _admin, address _treasury, uint256 _subFee, uint256 _subLengthDays) external onlyOwner {
        require(_subFee <= 100000000000000000, "Max 1 bnb renew Fee");
        require(!isInitialized, "Already initialized");
        isInitialized = true;
        stakedToken = _stakedToken; // @param _stakedToken: staked token address
        rewardToken = _rewardToken; // @param _rewardToken: reward token address
        lockTime = _lockTime; // @param _poolLimitPerUser: pool limit per user in stakedToken (if any, else 0)
        emit NewLockTime(_lockTime);

        uint256 decimalsRewardToken = uint256(rewardToken.decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10**(uint256(30).sub(decimalsRewardToken)));
        prevAndCurrentRewardsBalance = 0;
        totalStaked = 0;
        extraTokens = 0;
        setSubOperator(_admin);

        treasury = _treasury;
        subFee = _subFee;
        subLengthDays = _subLengthDays;
    }

    function SetPool(bool _hasUserLimit, uint256 _poolLimitPerUser, uint256 _lockTime, uint256 _rewardPerBlock, uint256 _startBlock, uint256 _EndBlock) external onlyOwner {
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
            bonusEndBlock  = _EndBlock;
            lastRewardBlock = startBlock;
            emit NewStartAndEndBlocks(_startBlock, _EndBlock);
        }
        isInitialized = true;
    }
       
    function RecyclePool() external onlyOwner {
        require (subEndBlock >= block.number);
        isInitialized = false;
        prevAndCurrentRewardsBalance = 0;
        totalStaked = 0;
        extraTokens = 0;
        bonusEndBlock = block.number;
        setSubOperator(owner());
    }

    function stopReward() external onlyOwner {
        _updatePool();
        uint256 timeLeft = bonusEndBlock - block.number;
        uint256 rewardsLeft = rewardPerBlock * timeLeft;

        if (stakedToken == rewardToken) {           
            prevAndCurrentRewardsBalance = rewardToken.balanceOf(address(this)) - totalStaked;
        } else {
            // check how much new rewards are available
            prevAndCurrentRewardsBalance = rewardToken.balanceOf(address(this));
        }
        prevAndCurrentRewardsBalance -= rewardsLeft;
        prevAndCurrentRewardsBalance -= totalNewReward;
        bonusEndBlock = block.number;
    }

    
    // Token removal Functions
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        rewardToken.safeTransfer(address(msg.sender), _amount);
        prevAndCurrentRewardsBalance -= _amount; 
    }
    
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        if (block.number < bonusEndBlock + 960000) {
            require(_tokenAddress != address(stakedToken), "Cannot recover token for 1 month)");
            require(_tokenAddress != address(rewardToken), "Cannot recover reward token for 1 month)");
            IBEP20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        } 
        else {IBEP20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);}
        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }
    
    function withdawBNB() external onlyOwner {payable(msg.sender).transfer(address(this).balance);}
    
    function RemoveExtraStakingTokens() external onlyOwner {
        _updatePool();
        require(extraTokens > 0, "No extra Tokens to Withdrawl");
        IBEP20(stakedToken).safeTransfer(address(msg.sender), extraTokens);
        extraTokens = 0;
    }
    
    function NEWRewardWithdraw() external onlyOwner {
        require(totalNewReward > 0, "No New Reward Tokens to Withdrawl");
        rewardToken.safeTransfer(address(msg.sender), totalNewReward);
        totalNewReward = 0; 
    }
    //******************************************************************************************************
    // Subscriber functions
    //******************************************************************************************************
    function RenewOrExtendSubscription() external payable onlySub {
        require(subEndBlock > 0, "Subscription hasnt started");
        require(msg.value >= subFee,"Not Enough BNB");
        require(payable(treasury).send(subFee));
        uint256 subLength = subLengthDays * 28800;
        if(block.number <= subEndBlock) subEndBlock += subLength;
        else subEndBlock = block.number + subLength;    
    }

    function setFeeOptions(address _feeReceiver, uint256 _stakingFee, uint256 _unstakingFee) external onlySub {
        require(_stakingFee <= 5 && _unstakingFee <= 5, "Fees cannot exceed 5% each");
        feeReceiver = _feeReceiver;
        stakingFee = _stakingFee;
        unstakingFee = _unstakingFee;
    }

    function UpdateAPR() external onlySub {
        _updatePool();
        require(bonusEndBlock > block.number, "Pool has Ended, use startNewPool");
        require(totalNewReward > 0, "no NewRewards availavble, send tokens First");

        uint256 blocksLeft = bonusEndBlock - block.number;
        uint256 addedRPB = totalNewReward / blocksLeft;
        rewardPerBlock += addedRPB;
        totalNewReward = 0;
        if (stakedToken == rewardToken) {prevAndCurrentRewardsBalance = rewardToken.balanceOf(address(this)) - totalStaked;} 
        else {prevAndCurrentRewardsBalance = rewardToken.balanceOf(address(this));}
        _updatePool();
    }

    function ExtendPool() external onlySub {
        require(bonusEndBlock > block.number, "Pool has Ended, use startNewPool");
          
        _updatePool();
        require(totalNewReward > 0, "No funds to start new pool with");
        
        if (stakedToken == rewardToken) {prevAndCurrentRewardsBalance = rewardToken.balanceOf(address(this)) - totalStaked;} 
        else {prevAndCurrentRewardsBalance = rewardToken.balanceOf(address(this));}        
        
        uint256 timeExtended = totalNewReward / rewardPerBlock;
        bonusEndBlock = bonusEndBlock + (timeExtended);
        if(msg.sender != owner()) require(bonusEndBlock <= subEndBlock, "Subscription runs out before this end block renewSubscription");
        totalNewReward = 0;
    }

    function startNewPool( uint256 _startInDays, uint256 _poolLengthDays ) external onlySub {
        require(bonusEndBlock < block.number, "Pool has not ended, Try Extending");
        
         _updatePool();
        require(totalNewReward > 0, "No funds to start new pool with");
        
        uint256 startInBlocks;
        uint256 totalBlocks;
        startInBlocks = _startInDays * 28800;
        totalBlocks = _poolLengthDays * 28800;

        if (stakedToken == rewardToken) {prevAndCurrentRewardsBalance = rewardToken.balanceOf(address(this)) - totalStaked;} 
        else {prevAndCurrentRewardsBalance = rewardToken.balanceOf(address(this));}
        startBlock = (block.number + startInBlocks);
        lastRewardBlock = startBlock;
        
        bonusEndBlock = startBlock + totalBlocks;
        if(msg.sender != owner()) require(bonusEndBlock <= subEndBlock, "Subscription runs out before this end block renewSubscription");
        rewardPerBlock = totalNewReward / totalBlocks;
        totalNewReward = 0;
        if(subEndBlock == 0) subEndBlock = block.number + (subLengthDays * 28800);
        isInitialized = true;
    }
    //******************************************************************************************************
    // Public functions
    //******************************************************************************************************
    function Stake(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 preBalance;
        uint256 postBalance;

        if (hasUserLimit) {require(_amount.add(user.amount) <= poolLimitPerUser, "User amount above limit");}
        _updatePool();
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
            if (pending > 0) {
                rewardToken.safeTransfer(address(msg.sender), pending);
                prevAndCurrentRewardsBalance -= pending; 
            }
        }

        if (_amount > 0) {
            preBalance = stakedToken.balanceOf(address(this));
            if(stakingFee > 0) {
                uint256 FeeAmount = _amount.mul(stakingFee).mul(100).div(10000);
                stakedToken.safeTransferFrom(address(msg.sender), feeReceiver, FeeAmount);
                _amount -= FeeAmount;
                user.depositTime = block.timestamp; 
            }    
            stakedToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            postBalance = stakedToken.balanceOf(address(this));
            user.amount = user.amount.add(postBalance - preBalance);  
            totalStaked += (postBalance - preBalance);
        }
        user.rewardDebt = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR);
        Staking(address(stakedToken)).setStakeBalance(msg.sender);
        emit Deposit(msg.sender, _amount);
    }

    function UnStake(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Amount to withdraw too high");
        require(user.depositTime + lockTime < block.timestamp, "Can not withdraw in lock period");

        _updatePool();
        uint256 pending = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            totalStaked -= _amount;
            
            if(unstakingFee > 0) {
                uint256 FeeAmount = _amount.mul(unstakingFee).mul(100).div(10000);
                stakedToken.safeTransfer(feeReceiver, FeeAmount);
                _amount -= FeeAmount;
            }
            stakedToken.safeTransfer(address(msg.sender), _amount);
        }
        if (pending > 0) {
            rewardToken.safeTransfer(address(msg.sender), pending);
            prevAndCurrentRewardsBalance -= pending; 
        }
        user.rewardDebt = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR);
        Staking(address(stakedToken)).setStakeBalance(msg.sender);
        emit Withdraw(msg.sender, _amount);
    }

    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amountToTransfer = user.amount;
        totalStaked -= user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        if (amountToTransfer > 0) {stakedToken.safeTransfer(address(msg.sender), amountToTransfer);}
        Staking(address(stakedToken)).setStakeBalance(msg.sender);
        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 stakedTokenSupply = totalStaked;
        if (block.number > lastRewardBlock && stakedTokenSupply != 0) {
            uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
            uint256 cakeReward = multiplier.mul(rewardPerBlock);
            uint256 adjustedTokenPerShare =
                accTokenPerShare.add(cakeReward.mul(PRECISION_FACTOR).div(stakedTokenSupply));
            return user.amount.mul(adjustedTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
        } else {
            return user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
        }
    }

    function GetPoolInfo() external view returns (bool Initialised, IBEP20 Token, IBEP20 Reward, uint EndDay, uint EndHour, uint EndMinute, uint EndSecond, uint256 Limit, uint256 LockTime, uint currentblock){
        uint Day;
        uint Hour;
        uint Minute;
        uint Second;
        if (bonusEndBlock  >= block.number) {
            uint256 Remaining = (bonusEndBlock  - block.number)*3;
            Day = Remaining/86400;
            Hour = (Remaining-(Day*86400))/3600;
            Minute = (Remaining-(Day*86400)-(Hour*3600))/60;
            Second = Remaining-(Day*86400)-(Hour*3600)-(Minute*60);
        } else {
            Day = 0;
            Hour = 0;
            Minute = 0;
            Second = 0;
        }
        return(isInitialized, stakedToken, rewardToken, Day, Hour, Minute, Second, poolLimitPerUser, lockTime, block.number);
    }

    function GetPoolStatus() external view returns (bool Started, uint StartDay, uint StartHour, uint StartMinute, uint StartSecond) {
        bool started;
        uint Day;
        uint Hour;
        uint Minute;
        uint Second;
        if (startBlock <= block.number) {
            uint256 Remaining = (block.number - startBlock)*3;
            Day = Remaining/86400;
            Hour = (Remaining-(Day*86400))/3600;
            Minute = (Remaining-(Day*86400)-(Hour*3600))/60;
            Second = Remaining-(Day*86400)-(Hour*3600)-(Minute*60);
            started = false;
        } else {
            Day = 0;
            Hour = 0;
            Minute = 0;
            Second = 0;
            started = true;
        }
        return(started, Day, Hour, Minute, Second);
    }
    //******************************************************************************************************
    // Internal functions
    //******************************************************************************************************
    function _updateExtraAndNewRewards() internal {
        // Set the Extra Tokens Variable
        if (stakedToken == rewardToken) {
            extraTokens = (stakedToken.balanceOf(address(this)) - prevAndCurrentRewardsBalance - totalStaked);
        } else {
            extraTokens = (stakedToken.balanceOf(address(this)) - totalStaked);
        }
         

        // check how much new rewards are available
        if (stakedToken == rewardToken) {totalNewReward = (rewardToken.balanceOf(address(this)) - prevAndCurrentRewardsBalance - totalStaked);} 
        else {totalNewReward = (rewardToken.balanceOf(address(this)) - prevAndCurrentRewardsBalance);}
    }

    function _updatePool() internal {
        if (block.number <= lastRewardBlock) {return;}
        uint256 stakedTokenSupply = totalStaked;
        _updateExtraAndNewRewards();
    
        if (stakedTokenSupply == 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
        uint256 cakeReward = multiplier.mul(rewardPerBlock);
        accTokenPerShare = accTokenPerShare.add(cakeReward.mul(PRECISION_FACTOR).div(stakedTokenSupply));
        lastRewardBlock = block.number;
    }

    function _getMultiplier(uint256 _from, uint256 _to) internal view returns (uint256) {
        if (_to <= bonusEndBlock) {return _to.sub(_from);} 
        else if (_from >= bonusEndBlock) {return 0;} 
        else {return bonusEndBlock.sub(_from);}
    }
}