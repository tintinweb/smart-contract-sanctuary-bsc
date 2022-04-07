// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./lib/SafeMath.sol";
import "./lib/IERC20.sol";
import "./lib/SafeERC20.sol";
import "./lib/ReentrancyGuard.sol";
import "./Vault.sol";
import "./lib/Ownable.sol";


contract MarsDaoPartnership is ReentrancyGuard,Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    struct UserInfo {
        uint256 depositedAmount;
        uint256 lastHarvestedBlock;
        uint256 pendingAmount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        uint256 rewardPerBlockAmount;
        address rewardTokenAddress;
        address rewardsVaultAddress;
        address depositedTokenAddress;
        uint256 totalDepositedAmount;
        uint256 lastRewardBlock;
        uint256 harvestAvailableBlock;
        uint256 harvestPeriod;
        uint256 withdrawFeeBP;
        uint256 accRewardsPerShare;
    }

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    PoolInfo[] public poolInfo;
    address public constant burnAddress =
        0x000000000000000000000000000000000000dEaD;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event WithdrawEmergency(address indexed user, uint256 indexed pid, uint256 amount);

    modifier correctPID(uint256 _pid) {
        require(_pid<poolInfo.length,"bad pid");
        _;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }


    function addPool(uint256 _rewardPerBlockAmount,
                address _rewardTokenAddress,
                address _depositedTokenAddress,
                uint256 _startBlock,
                uint256 _harvestAvailableBlock,
                uint256 _harvestPeriod,
                uint256 _withdrawFeeBP) public onlyOwner {
        
        require(_withdrawFeeBP>=0 && _withdrawFeeBP<=300);//0-3%
        bytes memory bytecode = type(Vault).creationCode;
        bytecode = abi.encodePacked(bytecode, abi.encode(_rewardTokenAddress));
        bytes32 salt = keccak256(abi.encodePacked(poolInfo.length, block.number));

        address _rewardsVaultAddress;
        assembly {
            _rewardsVaultAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        require(_rewardsVaultAddress != address(0), "Create2: Failed on deploy");
        
        uint256 _lastRewardBlock = block.number > _startBlock ? block.number : _startBlock;

        poolInfo.push(PoolInfo({
            rewardPerBlockAmount:_rewardPerBlockAmount,
            rewardTokenAddress:_rewardTokenAddress,
            rewardsVaultAddress:_rewardsVaultAddress,
            depositedTokenAddress:_depositedTokenAddress,
            totalDepositedAmount:0,
            lastRewardBlock:_lastRewardBlock,
            harvestAvailableBlock:(block.number > _harvestAvailableBlock ? block.number : _harvestAvailableBlock),
            harvestPeriod: _harvestPeriod,
            withdrawFeeBP: _withdrawFeeBP,
            accRewardsPerShare:0
        }));

    }

    function getVaultTokens(
        uint256 _pid,
        uint256 _amount,
        address _to
    ) external correctPID(_pid) onlyOwner{
        Vault(poolInfo[_pid].rewardsVaultAddress).safeRewardsTransfer(_to,_amount);
    }

    function setRewardPerBlock(uint256 _pid,
            uint256 _rewardPerBlockAmount) 
            external correctPID(_pid) onlyOwner {
        poolInfo[_pid].rewardPerBlockAmount=_rewardPerBlockAmount;
    }

    function setWithdrawFeeBP(uint256 _pid,uint256 _feeBP) 
        external correctPID(_pid) onlyOwner {
        require(_feeBP>=0 && _feeBP<=300);//0-3%
        poolInfo[_pid].withdrawFeeBP=_feeBP;
    }

    function pendingRewards(uint256 _pid, address _user) 
            external view correctPID(_pid) returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 accRewardsPerShare = pool.accRewardsPerShare;
        
        if (block.number > pool.lastRewardBlock && pool.totalDepositedAmount != 0) {
            uint256 reward = block.number.sub(pool.lastRewardBlock).mul(pool.rewardPerBlockAmount);
            uint256 rewardBalance=IERC20(pool.rewardTokenAddress).balanceOf(pool.rewardsVaultAddress);
            if(rewardBalance<reward){
                reward=rewardBalance;
            }
            accRewardsPerShare = accRewardsPerShare.add(
                                                        reward
                                                        .mul(1e18)
                                                        .div(pool.totalDepositedAmount)
                                                    );
        }
        return user.depositedAmount
            .mul(accRewardsPerShare)
            .div(1e18)
            .sub(user.rewardDebt)
            .add(user.pendingAmount);
    }


    function updatePool(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (pool.totalDepositedAmount == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 reward = block.number.sub(pool.lastRewardBlock).mul(pool.rewardPerBlockAmount);
        reward=Vault(pool.rewardsVaultAddress).safeRewardsTransfer(address(this),reward);

        pool.accRewardsPerShare = pool.accRewardsPerShare
                                .add(
                                    reward
                                    .mul(1e18)
                                    .div(pool.totalDepositedAmount)
                                );
        pool.lastRewardBlock = block.number;
    }


    function deposit(uint256 _pid, uint256 _amount) 
            external correctPID(_pid) nonReentrant {
        
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        
        
        uint256 pending = user.depositedAmount.mul(pool.accRewardsPerShare).div(1e18).sub(user.rewardDebt);
        uint256 rewards=0;

        if(block.number>=pool.harvestAvailableBlock 
            && block.number>user.lastHarvestedBlock.add(pool.harvestPeriod)){

            rewards=rewards.add(pending).add(user.pendingAmount);
            user.pendingAmount=0;
            user.lastHarvestedBlock=block.number;

        }else {
            user.pendingAmount=user.pendingAmount.add(pending);
        }

        if(rewards>0){
            _safeRewardsTransfer(msg.sender, rewards, IERC20(pool.rewardTokenAddress));
        }
        
        if(_amount > 0) {
            IERC20(pool.depositedTokenAddress).safeTransferFrom(address(msg.sender), address(this), _amount);
            user.depositedAmount = user.depositedAmount.add(_amount);
            pool.totalDepositedAmount=pool.totalDepositedAmount.add(_amount);
            emit Deposit(msg.sender, _pid, _amount);
        }
        user.rewardDebt = user.depositedAmount.mul(pool.accRewardsPerShare).div(1e18);
    }

    function withdraw(uint256 _pid, uint256 _amount) 
        external correctPID(_pid) nonReentrant{

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.depositedAmount >= _amount, "withdraw: not good");
        
        updatePool(_pid);

        uint256 pending = user.depositedAmount.mul(pool.accRewardsPerShare).div(1e18).sub(user.rewardDebt);
        uint256 rewards=0;

        if(block.number>=pool.harvestAvailableBlock 
            && block.number>user.lastHarvestedBlock.add(pool.harvestPeriod)){

            rewards=rewards.add(pending).add(user.pendingAmount);
            user.pendingAmount=0;
            user.lastHarvestedBlock=block.number;

        }else {
            user.pendingAmount=user.pendingAmount.add(pending);
        }

        if(rewards>0){
            _safeRewardsTransfer(msg.sender, rewards, IERC20(pool.rewardTokenAddress));
        }

        if(_amount > 0) {

            user.depositedAmount = user.depositedAmount.sub(_amount);
            pool.totalDepositedAmount=pool.totalDepositedAmount.sub(_amount);
            uint256 burnAmount=_amount.mul(pool.withdrawFeeBP).div(10000);
            if(burnAmount>0){
                IERC20(pool.depositedTokenAddress).safeTransfer(burnAddress, burnAmount);
            }
            IERC20(pool.depositedTokenAddress).safeTransfer(address(msg.sender), _amount.sub(burnAmount));
            emit Withdraw(msg.sender, _pid, _amount);
        }
        user.rewardDebt = user.depositedAmount.mul(pool.accRewardsPerShare).div(1e18);
    }

    function withdrawEmergency(uint256 _pid) 
        external correctPID(_pid) nonReentrant{
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.depositedAmount>0, "withdraw: not good");
        uint256 withdrawAmount=user.depositedAmount;
        user.depositedAmount=0;
        user.rewardDebt=0;
        pool.totalDepositedAmount=pool.totalDepositedAmount.sub(withdrawAmount);
        uint256 burnAmount=withdrawAmount.mul(pool.withdrawFeeBP).div(10000);
        if(burnAmount>0){
            IERC20(pool.depositedTokenAddress).safeTransfer(burnAddress, burnAmount);
        }
        IERC20(pool.depositedTokenAddress).safeTransfer(address(msg.sender), withdrawAmount.sub(burnAmount));
        emit WithdrawEmergency(msg.sender, _pid, withdrawAmount);
    }

    function _safeRewardsTransfer(address _to, uint256 _amount,IERC20 _token) internal {
        uint256 balance = _token.balanceOf(address(this));
        if (_amount > balance) {
            _token.safeTransfer(_to, balance);
        } else {
            _token.safeTransfer(_to, _amount);
        }
    }

}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


library SafeMath {
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./Address.sol";
import "./SafeMath.sol";
import "./IERC20.sol";


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).add(value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).sub(
                value,
                "SafeERC20: decreased allowance below zero"
            );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
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

        bytes memory returndata =
            address(token).functionCall(
                data,
                "SafeERC20: low-level call failed"
            );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./Context.sol";


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) =
            target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
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

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./lib/Ownable.sol";
import "./lib/SafeERC20.sol";
import "./lib/IERC20.sol";

contract Vault is Ownable{
    using SafeERC20 for IERC20;
    
    IERC20 immutable public rewardToken;

    constructor(address _rewardToken) public {
        rewardToken=IERC20(_rewardToken);
    }

    function safeRewardsTransfer(address _to, uint256 _amount) 
            external 
            onlyOwner returns(uint256){
        uint256 rewardTokenBalance = rewardToken.balanceOf(address(this));
        
        if(rewardTokenBalance>0){
            if (_amount > rewardTokenBalance) {
                _amount=rewardTokenBalance;
            }
            rewardToken.safeTransfer(_to, _amount);
            return _amount;
        }
        
        return 0;
    }

}