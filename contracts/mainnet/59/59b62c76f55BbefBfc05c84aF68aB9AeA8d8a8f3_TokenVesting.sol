// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenVesting is Ownable {
    // Contract libs
    using SafeMath for uint256;

    address public token;

    // Contract events
    event Released(address indexed beneficiary, uint256 amount);

    // Vesting information struct
    struct VestingBeneficiary {
        address beneficiary;
        uint256 lockDuration;
        uint256 duration;
        uint256 amount;
        uint256 leftOverVestingAmount;
        uint256 released;
        uint256 upfrontAmount;
        uint256 startedAt;
        uint256 interval;
        uint256 lastReleasedAt;
    }

    // Vesting beneficiary list
    mapping(address => VestingBeneficiary) public beneficiaries;
    address[] public beneficiaryAddresses;
    // Token deployed date
    uint256 public tokenListingDate;
    uint256 public tokenVestingCap;

    constructor(address _token, uint256 _tokenListingDate) {
        token = _token;
        if (_tokenListingDate > 0) {
            tokenListingDate = _tokenListingDate;
        }
    }

    // only owner or added beneficiaries can release the vesting amount
    modifier onlyBeneficiaries() {
        require(
            owner() == _msgSender() || beneficiaries[_msgSender()].amount > 0,
            "You cannot release tokens!"
        );
        _;
    }

    /**
     * @dev Set first day token listing on exchange for vesting process
     */
    function setTokenListingDate(uint256 _tokenListingDate) public onlyOwner {
        require(
            _tokenListingDate >= block.timestamp,
            "Token listing must be in future date"
        );

        tokenListingDate = _tokenListingDate;

        uint256 beneficiaryCount = beneficiaryAddresses.length;
        for (uint256 i = 0; i < beneficiaryCount; i++) {
            VestingBeneficiary storage info = beneficiaries[
            beneficiaryAddresses[i]
            ];

            info.startedAt = _tokenListingDate.add(info.lockDuration);
        }
    }

    /**
     * @dev Add new beneficiary to vesting contract with some conditions.
     */
    function addBeneficiary(
        address _beneficiary,
        uint256 _amount,
        uint256 _lockDuration,
        uint256 _duration,
        uint256 _upfrontAmount,
        uint256 _interval
    ) public onlyOwner {
        require(
            _beneficiary != address(0),
            "The beneficiary's address cannot be 0"
        );

        require(_amount > 0, "Shares amount has to be greater than 0");
        require(
            tokenVestingCap.add(_amount) <= IERC20(token).totalSupply(),
            "Full token vesting to other beneficiaries. Can not add new beneficiary"
        );
        require(
            beneficiaries[_beneficiary].amount == 0,
            "The beneficiary has added to the vesting pool already"
        );

        // Add new vesting beneficiary
        uint256 _leftOverVestingAmount = _amount.sub(_upfrontAmount);
        uint256 vestingStartedAt = tokenListingDate.add(_lockDuration);
        beneficiaries[_beneficiary] = VestingBeneficiary(
            _beneficiary,
            _lockDuration,
            _duration,
            _amount,
            _leftOverVestingAmount,
            _upfrontAmount,
            _upfrontAmount,
            vestingStartedAt,
            _interval,
            0
        );

        beneficiaryAddresses.push(_beneficiary);
        tokenVestingCap = tokenVestingCap.add(_amount);

        // Transfer immediately if any upfront amount
        if (_upfrontAmount > 0) {
            emit Released(_beneficiary, _amount);
            IERC20(token).transfer(_beneficiary, _upfrontAmount);
        }
    }

    /**
     * @dev Get new vested amount of beneficiary base on vesting schedule of this beneficiary.
     */
    function releasableAmount(address _beneficiary)
    public
    view
    returns (
        uint256,
        uint256,
        uint256
    )
    {
        VestingBeneficiary memory info = beneficiaries[_beneficiary];
        if (info.amount == 0) {
            return (0, 0, block.timestamp);
        }

        (uint256 _vestedAmount, uint256 _lastIntervalDate) = vestedAmount(
            _beneficiary
        );

        return (
        _vestedAmount,
        _vestedAmount.sub(info.released),
        _lastIntervalDate
        );
    }

    /**
     * @dev Get total vested amount of beneficiary base on vesting schedule of this beneficiary.
     */
    function vestedAmount(address _beneficiary)
    public
    view
    returns (uint256, uint256)
    {
        VestingBeneficiary memory info = beneficiaries[_beneficiary];
        require(info.amount > 0, "The beneficiary's address cannot be found");
        // Listing date is not set
        if (tokenListingDate == 0 || info.startedAt == 0) {
            return (info.released, info.lastReleasedAt);
        }

        // No vesting (All amount unlock at the TGE)
        if (info.duration == 0) {
            return (info.amount, info.startedAt);
        }

        // Vesting has not started yet
        if (block.timestamp < info.startedAt) {
            return (info.released, info.lastReleasedAt);
        }

        // Vesting is done
        if (block.timestamp >= info.startedAt.add(info.duration)) {
            return (info.amount, info.startedAt.add(info.duration));
        }

        // It's too soon to next release
        if (
            info.lastReleasedAt > 0 &&
            block.timestamp - info.interval < info.lastReleasedAt
        ) {
            return (info.released, info.lastReleasedAt);
        }

        // Vesting is interval counter
        uint256 totalVestedAmount = info.released;
        uint256 lastIntervalDate = info.lastReleasedAt > 0
        ? info.lastReleasedAt
        : info.startedAt;

        uint256 multiplyIntervals;
        while (block.timestamp >= lastIntervalDate.add(info.interval)) {
            multiplyIntervals = multiplyIntervals.add(1);
            lastIntervalDate = lastIntervalDate.add(info.interval);
        }

        if (multiplyIntervals > 0) {
            uint256 newVestedAmount = info
            .leftOverVestingAmount
            .mul(multiplyIntervals.mul(info.interval))
            .div(info.duration);

            totalVestedAmount = totalVestedAmount.add(newVestedAmount);
        }

        return (totalVestedAmount, lastIntervalDate);
    }

    /**
     * @dev Release vested tokens to a specified beneficiary.
     */
    function releaseTo(
        address _beneficiary,
        uint256 _amount,
        uint256 _lastIntervalDate
    ) internal returns (bool) {
        VestingBeneficiary storage info = beneficiaries[_beneficiary];
        if (block.timestamp < _lastIntervalDate) {
            return false;
        }
        // Update beneficiary information
        info.released = info.released.add(_amount);
        info.lastReleasedAt = _lastIntervalDate;

        // Emit event to of new release
        emit Released(_beneficiary, _amount);
        // Transfer new released amount to vesting beneficiary
        IERC20(token).transfer(_beneficiary, _amount);

        return true;
    }

    /**
     * @dev Release vested tokens to a all beneficiaries.
     */
    function releaseBeneficiaryTokens() public onlyOwner {
        // Get current vesting beneficiaries
        uint256 beneficiariesCount = beneficiaryAddresses.length;
        for (uint256 i = 0; i < beneficiariesCount; i++) {
            // Calculate the releasable amount
            (
            ,
            uint256 _newReleaseAmount,
            uint256 _lastIntervalDate
            ) = releasableAmount(beneficiaryAddresses[i]);

            // Release new vested token to the beneficiary
            if (_newReleaseAmount > 0) {
                releaseTo(
                    beneficiaryAddresses[i],
                    _newReleaseAmount,
                    _lastIntervalDate
                );
            }
        }
    }

    /**
     * @dev Release vested tokens to current beneficiary.
     */
    function releaseMyTokens() public onlyBeneficiaries {
        // Calculate the releasable amount
        (
        ,
        uint256 _newReleaseAmount,
        uint256 _lastIntervalDate
        ) = releasableAmount(_msgSender());

        // Release new vested token to the beneficiary
        if (_newReleaseAmount > 0) {
            releaseTo(_msgSender(), _newReleaseAmount, _lastIntervalDate);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

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