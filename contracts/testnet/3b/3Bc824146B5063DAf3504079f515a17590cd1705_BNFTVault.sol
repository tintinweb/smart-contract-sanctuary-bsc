// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BNFTVault is Ownable {
    IERC20 private _beastnft;

    uint256 lockFeePenalisation = 20;

    bool canDeposit = true;

    address rewardsWallet = 0x3887354E6E37C8ca3d7a3ba09D2f326A1Cb6c5Bc;

    uint256 currentBNFTDeposited;
    uint256 totalBNFTWithdrawn;

    mapping(uint256 => uint256) percentageRewardForTimelock;

    uint256 earlyWithdrawalFeeBalance;

    struct BNFTDeposit {
        uint256 id;
        address depositOwner;
        uint256 depositValue;
        bool isWithdrawn;
        uint256 depositTime;
        uint256 timeLockInSeconds;
    }

    BNFTDeposit[] public bnftDeposits;

    event BNFTTokenDeposit(
        uint256 depositId,
        address depositOwner,
        uint256 depositValue,
        bool isWithdrawn,
        uint256 depositTime,
        uint256 timeLockInSeconds
    );
    event BNFTTokenWithdraw(
        uint256 depositId,
        address depositOwner,
        uint256 value,
        uint256 withdrawTime,
        bool forceWithdraw
    );
    event IncrementedEarlyWithdrawalFeeBalance(uint256 value);

    using SafeMath for uint256;

    constructor(IERC20 _token) {
        _beastnft = _token;
    }

    function totalAmountDeposited() external view returns (uint256) {
        return currentBNFTDeposited;
    }

    function totalAmountWithdrawnWithRewards() external view returns (uint256) {
        return totalBNFTWithdrawn;
    }

    function changeRewardsWallet(address newRewardsWallet)
        external
        onlyOwner
        returns (bool)
    {
        rewardsWallet = newRewardsWallet;
        return true;
    }

    function setPercentageRewardForTimelock(
        uint256 timelock,
        uint256 percentageReward
    ) external onlyOwner {
        percentageRewardForTimelock[timelock] = percentageReward;
    }

    function getPercentageRewardForTimelock(uint256 timelock)
        external
        view
        returns (uint256)
    {
        return percentageRewardForTimelock[timelock];
    }

    function getCanDeposit() external view returns (bool) {
        return canDeposit;
    }

    function switchCanDeposit() external onlyOwner {
        canDeposit = !canDeposit;
    }

    function setEarlyWithdrawalPenalisation(uint256 _lockFeePenalisation)
        external
        onlyOwner
    {        
        lockFeePenalisation = _lockFeePenalisation;
    }

    function getLockFeePenalisation() external view returns (uint256) {
        return lockFeePenalisation;
    }

    function getRewardsWallet() external view returns (address) {
        return rewardsWallet;
    }

    function getReflectionAndTaxBalance() external view returns (uint256) {
        return (_beastnft.balanceOf(address(this)) - currentBNFTDeposited);
    }

    function withdrawReflectionAndTaxBalance(address walletAddress)
        external
        onlyOwner
        returns (bool)
    {
        _beastnft.transfer(
            walletAddress,
            (_beastnft.balanceOf(address(this)) - currentBNFTDeposited)
        );

        return true;
    }

    function depositBNFT(uint256 amountToLockInWei, uint256 timeLockSeconds)
        external
    {
        require(canDeposit = true, "Deposit is temporarily disabled");
        require(amountToLockInWei != 0, "Cannot lock 0 amount of tokens");

        uint256 newItemId = bnftDeposits.length;

        bnftDeposits.push(
            BNFTDeposit(
                newItemId,
                msg.sender,
                amountToLockInWei,
                false,
                block.timestamp,
                timeLockSeconds
            )
        );

        currentBNFTDeposited += amountToLockInWei;

        _beastnft.transferFrom(msg.sender, address(this), amountToLockInWei);

        emit BNFTTokenDeposit(
            newItemId,
            msg.sender,
            amountToLockInWei,
            false,
            block.timestamp,
            timeLockSeconds
        );
    }

    function withdrawDeposit(uint256 depositId) external {
        require(depositId <= bnftDeposits.length);

        require(bnftDeposits[depositId].isWithdrawn == false, "This deposit has already been withdrawn.");

        require(bnftDeposits[depositId].depositOwner == msg.sender, "You can only withdraw your own deposits.");

        require((block.timestamp - bnftDeposits[depositId].depositTime) >= bnftDeposits[depositId].timeLockInSeconds, "You can't yet unlock this deposit.  please use forceWithdrawDeposit instead");

        require(percentageRewardForTimelock[bnftDeposits[depositId].timeLockInSeconds] > 0, "Smart contract owner hasn't defined reward for your deposit. Please contact BNFT team.");

        _beastnft.transfer(msg.sender, bnftDeposits[depositId].depositValue);

        _beastnft.transferFrom(
            rewardsWallet,
            msg.sender,
            (
                bnftDeposits[depositId]
                    .depositValue
                    .mul(
                        percentageRewardForTimelock[
                            bnftDeposits[depositId].timeLockInSeconds
                        ]
                    )
                    .div(100)
            )
        );

        currentBNFTDeposited -= bnftDeposits[depositId].depositValue;

        bnftDeposits[depositId].isWithdrawn = true;

        totalBNFTWithdrawn +=
            bnftDeposits[depositId].depositValue +
            (
                bnftDeposits[depositId]
                    .depositValue
                    .mul(
                        percentageRewardForTimelock[
                            bnftDeposits[depositId].timeLockInSeconds
                        ]
                    )
                    .div(100)
            );

        emit BNFTTokenWithdraw(
            depositId,
            msg.sender,
            bnftDeposits[depositId].depositValue,
            block.timestamp,
            false
        );
    }

    function forceWithdrawDeposit(uint256 depositId) external {
        require(depositId <= bnftDeposits.length);

        require(bnftDeposits[depositId].depositOwner == msg.sender, "Only the sender can withdraw this deposit");

        require(bnftDeposits[depositId].isWithdrawn == false, "This deposit has already been withdrawn.");

        _beastnft.transfer(
            msg.sender,
            bnftDeposits[depositId].depositValue -
                (
                    bnftDeposits[depositId]
                        .depositValue
                        .mul(lockFeePenalisation)
                        .div(100)
                )
        );

        earlyWithdrawalFeeBalance += (
            bnftDeposits[depositId].depositValue.mul(lockFeePenalisation).div(
                100
            )
        );

        currentBNFTDeposited -= bnftDeposits[depositId].depositValue;

        emit IncrementedEarlyWithdrawalFeeBalance(
            (
                bnftDeposits[depositId]
                    .depositValue
                    .mul(lockFeePenalisation)
                    .div(100)
            )
        );

        bnftDeposits[depositId].isWithdrawn = true;

        totalBNFTWithdrawn +=
            bnftDeposits[depositId].depositValue -
            (
                bnftDeposits[depositId]
                    .depositValue
                    .mul(lockFeePenalisation)
                    .div(100)
            );

        emit BNFTTokenWithdraw(
            depositId,
            msg.sender,
            bnftDeposits[depositId].depositValue,
            block.timestamp,
            true
        );
    }

    function getActivityLogs(address _walletAddress) external view returns (BNFTDeposit[] memory) {
        address walletAddress = _walletAddress;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for(uint256 i = 0; i < bnftDeposits.length; i ++){
            if(walletAddress == bnftDeposits[i].depositOwner){
                itemCount += 1;
            }
        }

        BNFTDeposit[] memory items = new BNFTDeposit[](itemCount);
        for (uint256 i = 0; i < bnftDeposits.length; i++) {
            if(walletAddress == bnftDeposits[i].depositOwner){
                BNFTDeposit storage item = bnftDeposits[i];
                items[currentIndex] = item;
                currentIndex += 1;
            }
        }
        return items;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}