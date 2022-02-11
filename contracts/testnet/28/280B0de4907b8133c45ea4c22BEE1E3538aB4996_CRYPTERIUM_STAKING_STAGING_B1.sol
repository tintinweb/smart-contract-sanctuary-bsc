// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

import "../../../../deps/openzeppelin-contracts-release-v2.5.0/contracts/token/ERC20/IERC20.sol";
import "../../../../deps/openzeppelin-contracts-release-v2.5.0/contracts/token/ERC20/SafeERC20.sol";
import "../../../../deps/openzeppelin-contracts-release-v2.5.0/contracts/ownership/Ownable.sol";
import "../../../../deps/openzeppelin-contracts-release-v2.5.0/contracts/ownership/Secondary.sol";
import "../../../../deps/openzeppelin-contracts-release-v2.5.0/contracts/math/SafeMath.sol";
import "../../../../deps/openzeppelin-contracts-release-v2.5.0/contracts/GSN/Context.sol";
import "../../../../deps/openzeppelin-contracts-release-v2.5.0/contracts/utils/ReentrancyGuard.sol";

contract CRYPTERIUM_STAKING_STAGING_B1 is
    Context,
    ReentrancyGuard,
    Ownable,
    Secondary
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private _nativeStakeToken;
    address payable private _lockedRewardWallet;

    uint256 private _tokenStakedRaised;
    uint256 private _stakedId;
    uint256 private _poolLimitWei;
    uint256 private _poolDecimals;
    uint256 private _totalRewardLocked;
    uint256 private _totalstakedTickets;
    uint256 private withdrawCounter;

    mapping(uint256 => uint256) public withdrawCounterToAmount;

    struct StakedInfo {
        uint256 stakedId;
        uint256 amount;
        uint256 lockedReward;
        uint256 apr;
        uint256 starttimestamp;
        uint256 packPeriod;
        uint256 Maxpay;
        bool exists;
    }

    mapping(address => mapping(uint256 => StakedInfo[]))
        public stakerPackageList;

    mapping(address => uint256) private _stakers;

    event TokensStaked(
        address staker,
        uint256 package,
        uint256 id,
        uint256 amount,
        uint256 times
    );

    event TokensUnstaked(
        address unstaker,
        uint256 package,
        uint256 _claimedStakedId,
        uint256 _startTime,
        uint256 _unstakedAmount,
        uint256 _claimedTime
    );

    event RewardLocked(uint256 _lockedStakedId, uint256 _lockedAmount);
    event RewardSlash(
        uint256 _unstakedAPR,
        uint256 _count,
        uint256 _slashedReward,
        uint256 _slashedRemain
    );
    event WithdrawAll(uint256 blocknumber, uint256 value);

    uint256 NUM_PACKAGES = 3;
    uint256 BRONZE_STAKE_PACKAGE = 0;
    uint256 SILVER_STAKE_PACKAGE = 1;
    uint256 GOLD_STAKE_PACKAGE = 2;

    constructor(IERC20 _stakeToken) public {
        _nativeStakeToken = IERC20(_stakeToken);
        _tokenStakedRaised = 0;
        _stakedId = 0;
        _poolDecimals = 18;
        _totalRewardLocked = 0;
        _totalstakedTickets = 0;
        _poolLimitWei = 0;
        withdrawCounter = 0;
    }

    function stakeTokens(uint256 _amount, uint256 _pack) public {
        require(
            _amount >= 1000 * (10**_poolDecimals),
            "CRYPTERIUM_CROWDSALE: 1000 tokens is required minimum"
        );
        require(
            _pack < NUM_PACKAGES,
            "CRYPTERIUM_CROWDSALE: PACKAGE not valid"
        );

        _nativeStakeToken.transferFrom(msg.sender, address(this), _amount);

        //stake => chack pack =>checkpool have enough reward =>lock packreward to stakeID
        //get package info
        uint256 _timestamp = timeCall();
        uint256 packAPR = 0;
        uint256 packinterval = 0;
        uint256 packMaxpay = 0;
        (packAPR, packinterval, packMaxpay) = _getPackage(_amount, _pack);
        uint256 packReward = _lockReward(
            _stakedId,
            _amount,
            packAPR,
            packMaxpay
        );

        // update total pool
        _tokenStakedRaised = _tokenStakedRaised.add(_amount);

        //update staker steaked package list
        stakerPackageList[msg.sender][_pack].push(
            StakedInfo(
                _stakedId,
                _amount,
                packReward,
                packAPR,
                _timestamp,
                packinterval,
                packMaxpay,
                true
            )
        );

        //update staker total info
        _stakers[msg.sender] = _stakers[msg.sender] + _amount;

        //emit
        emit TokensStaked(msg.sender, _pack, _stakedId, _amount, _timestamp);

        _stakedId = _stakedId + 1;
    }

    function unStakeTokens(
        uint256 _pack,
        uint256 _packIndex,
        uint256 _packId
    ) public {
        require(
            stakerPackageList[msg.sender][_pack].length > 0,
            "CRYPTERIUM_CROWDSALE: Account currently non-staked"
        );
        require(
            _packIndex < stakerPackageList[msg.sender][_pack].length,
            "CRYPTERIUM_CROWDSALE: packIndex out of bound"
        );
        require(
            stakerPackageList[msg.sender][_pack][_packIndex].stakedId ==
                _packId,
            "CRYPTERIUM_CROWDSALE: stakedId does not exist."
        );

        uint256 _timestart = stakerPackageList[msg.sender][_pack][_packIndex]
            .starttimestamp;

        // Reward here.....
        //unstake => checktimecondition => slash reward by stakeId =>
        uint256 _timestampUnstake = timeCall();
        _slashLockReward(_pack, _packIndex, _packId, _timestampUnstake);

        //update staker total info
        uint256 _unstakeAmount = stakerPackageList[msg.sender][_pack][
            _packIndex
        ].amount;

        _stakers[msg.sender] = _stakers[msg.sender] - _unstakeAmount;

        // update total pool
        _tokenStakedRaised = _tokenStakedRaised.sub(_unstakeAmount);

        //update staker steaked package list
        stakerPackageList[msg.sender][_pack][_packIndex] = stakerPackageList[
            msg.sender
        ][_pack][stakerPackageList[msg.sender][_pack].length - 1];
        stakerPackageList[msg.sender][_pack].pop();

        //emit
        emit TokensUnstaked(
            msg.sender,
            _pack,
            _packIndex,
            _timestart,
            _unstakeAmount,
            _timestampUnstake
        );
    }

    function _getPackage(uint256 _amount, uint256 _pack)
        internal
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 _apr = 0;
        uint256 _interval = 0;
        uint256 _maxpay = 0;

        if (
            _pack == BRONZE_STAKE_PACKAGE &&
            _amount >= 1000 * (10**_poolDecimals)
        ) {
            _apr = 22;
            _interval = 604800;
            _maxpay = 10;
        } else if (
            _pack == SILVER_STAKE_PACKAGE &&
            _amount >= 5000 * (10**_poolDecimals)
        ) {
            _apr = 35;
            _interval = 7776000;
            _maxpay = 3;
        } else if (
            _pack == GOLD_STAKE_PACKAGE &&
            _amount >= 10000 * (10**_poolDecimals)
        ) {
            _apr = 50;
            _interval = 15552000;
            _maxpay = 2;
        } else {
            revert("CRYPTERIUM_CROWDSALE: stakedDetail not meet requirement");
        }

        return (_apr, _interval, _maxpay);
    }

    function _lockReward(
        uint256 lStakedId,
        uint256 lAmount,
        uint256 lAPR,
        uint256 lMaxpay
    ) internal returns (uint256) {
        uint256 Reward = lAmount.div(100).mul(lAPR).div(365).mul(7).mul(
            lMaxpay
        );
        //chacke maxpool
        if (_totalRewardLocked + Reward >= _poolLimitWei) {
            revert("CRYPTERIUM_CROWDSALE: poolLimit Exceed");
        }

        //transfer
        _nativeStakeToken.transfer(_lockedRewardWallet, Reward);

        //update totalRewardLocked
        _totalRewardLocked = _totalRewardLocked + Reward;

        //update totalstakedTickets
        _totalstakedTickets = _totalstakedTickets + 1;

        //emit
        emit RewardLocked(lStakedId, Reward);

        return Reward;
    }

    function _slashLockReward(
        uint256 _claimPack,
        uint256 _claimPackIndex,
        uint256 _claimPackId,
        uint256 _claimTimestamp
    ) internal returns (bool) {
        require(
            stakerPackageList[msg.sender][_claimPack][_claimPackIndex]
                .stakedId == _claimPackId,
            "CRYPTERIUM_CROWDSALE: stakedId does not exist."
        );

        uint256 V = stakerPackageList[msg.sender][_claimPack][_claimPackIndex]
            .amount;
        uint256 TR = stakerPackageList[msg.sender][_claimPack][_claimPackIndex]
            .lockedReward;
        uint256 St = stakerPackageList[msg.sender][_claimPack][_claimPackIndex]
            .starttimestamp;
        uint256 Pt = stakerPackageList[msg.sender][_claimPack][_claimPackIndex]
            .packPeriod;
        uint256 Mp = stakerPackageList[msg.sender][_claimPack][_claimPackIndex]
            .Maxpay;
        uint256 R = stakerPackageList[msg.sender][_claimPack][_claimPackIndex]
            .apr;

        uint256 unitReward = TR.div(Mp);
        uint256 timeOfStake = _claimTimestamp.sub(St);
        uint256 payCount = 0;

        uint256 slashedReward = 0;
        uint256 slashedRemain = 0;

        // if (timeOfStake.mod(Pt) >= Mp) {
        //     payCount = Mp;
        // } else {
        //     payCount = timeOfStake.mod(Pt);
        // }

        //test fast 5 sec
        if (timeOfStake.mod(50) >= Mp) {
            payCount = Mp;
        } else {
            payCount = timeOfStake.mod(Pt);
        }

        slashedReward = unitReward.mul(payCount);
        slashedRemain = TR.sub(slashedReward);

        //slashedReward to staker
        _nativeStakeToken.transferFrom(
            _lockedRewardWallet,
            msg.sender,
            slashedReward
        );

        //slashedRemain back
        _nativeStakeToken.transferFrom(
            _lockedRewardWallet,
            address(this),
            slashedRemain
        );

        //unstake to staker
        _nativeStakeToken.transfer(msg.sender, V);

        //update totalRewardLocked
        _totalRewardLocked = _totalRewardLocked - TR;

        //update totalstakedTickets
        _totalstakedTickets = _totalstakedTickets - 1;

        emit RewardSlash(R, payCount, slashedReward, slashedRemain);
        return true;
    }

    function totalstakedTickets() public view returns (uint256) {
        return _totalstakedTickets;
    }

    function totalRewardLocked() public view returns (uint256) {
        return _totalRewardLocked;
    }

    function tokenStakedRaised() public view returns (uint256) {
        return _tokenStakedRaised;
    }

    function getStakedPacks(uint256 _pack) public view returns (uint256) {
        return _getStakedPacks(msg.sender, _pack);
    }

    function getStaker() public view returns (uint256) {
        return _stakers[msg.sender];
    }

    function _getStakedPacks(address staker, uint256 _pack)
        internal
        view
        returns (uint256)
    {
        return stakerPackageList[staker][_pack].length;
    }

    function setPoolLimitWei(uint256 weiLimit) public onlyOwner {
        require(
            // weiLimit >= 5 * (10**6) * (10**18),
            weiLimit >= 1 * (10**18),
            "CRYPTERIUM_CROWDSALE: required minimum amount"
        );
        _poolLimitWei = weiLimit;
    }

    function getPoolLimitWei() public view returns (uint256) {
        return _poolLimitWei;
    }

    function setLockedRewardWallet(address payable wallet) public onlyOwner {
        _lockedRewardWallet = wallet;
    }

    function getLockedRewardWallet() public view returns (address) {
        return _lockedRewardWallet;
    }

    function timeCall() internal view returns (uint256) {
        return now;
    }

    function withdrawAll() public onlyOwner {
        uint256 totalToken = _nativeStakeToken.balanceOf(address(this));
        _nativeStakeToken.transfer(owner(), totalToken);

        withdrawCounter = withdrawCounter + 1;

        uint256 blockValue = uint256(block.number);
        emit WithdrawAll(blockValue, totalToken);

        withdrawCounterToAmount[withdrawCounter] = totalToken;
        _poolLimitWei = _poolLimitWei - totalToken;
    }

    function withdrawHistory() public view onlyOwner returns (uint256) {
        return withdrawCounter;
    }

    function metadata() public pure returns (string memory) {
        return
            '{"name":"CRYPTERIUM_STAGING_B1","version":"V1" ,"url":"https://www.crypterium.game","description":"we are crypterium","deployer":"[email protected]_moretomato.com"}';
    }
}

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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

pragma solidity ^0.5.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.5.0;

import "../GSN/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.5.0;

import "../GSN/Context.sol";
/**
 * @dev A Secondary contract can only be used by its primary account (the one that created it).
 */
contract Secondary is Context {
    address private _primary;

    /**
     * @dev Emitted when the primary contract changes.
     */
    event PrimaryTransferred(
        address recipient
    );

    /**
     * @dev Sets the primary account to the one that is creating the Secondary contract.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _primary = msgSender;
        emit PrimaryTransferred(msgSender);
    }

    /**
     * @dev Reverts if called from any account other than the primary.
     */
    modifier onlyPrimary() {
        require(_msgSender() == _primary, "Secondary: caller is not the primary account");
        _;
    }

    /**
     * @return the address of the primary.
     */
    function primary() public view returns (address) {
        return _primary;
    }

    /**
     * @dev Transfers contract to a new primary.
     * @param recipient The address of new primary.
     */
    function transferPrimary(address recipient) public onlyPrimary {
        require(recipient != address(0), "Secondary: new primary is the zero address");
        _primary = recipient;
        emit PrimaryTransferred(recipient);
    }
}

pragma solidity ^0.5.0;

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
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.5.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.5.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 *
 * _Since v2.5.0:_ this module is now much more gas efficient, given net gas
 * metering changes introduced in the Istanbul hardfork.
 */
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
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
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

pragma solidity ^0.5.5;

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
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
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}