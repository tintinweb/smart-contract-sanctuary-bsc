// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "../Role/Operator.sol";
import "./AtlantisVesting.sol";


contract VestingFactory is Context, Ownable, Operator {

    address public atlantisToken;

    event NewVestingCreated(
        address indexed theVesting,
        uint256 startTimestamp,
        uint256 durationSeconds,
        address[] beneficiaries,
        uint256[] vestingAmounts
    );

    /**
     * @dev Set the beneficiary, start timestamp and vesting duration of the vesting wallet.
     */
    constructor(
        address _atlantisToken
    ) {
        require(
            _atlantisToken != address(0),
            "VestingFactory: token address is zero"  
        );

        atlantisToken = _atlantisToken;

    }

    /**
     * @dev charge the vesting contract
     */
    function createVesting(
        uint256 startTimestamp,
        uint256 durationSeconds,
        address[] memory beneficiaries,
        uint256[] memory vestingAmounts
    ) external onlyOperator returns (address){

        AtlantisVesting theVestingContract = new AtlantisVesting(
            atlantisToken,
            startTimestamp,
            durationSeconds,
            beneficiaries,
            vestingAmounts
        );

        theVestingContract.transferOwnership(_msgSender());

        address theVestingAddr = address(theVestingContract);

        emit NewVestingCreated(
            theVestingAddr, 
            startTimestamp,
            durationSeconds, 
            beneficiaries, 
            vestingAmounts
        );
        
        return theVestingAddr;
    }

    /**
     * @dev Add new operator
     */
    function addNewOperator(address newOprtr) external onlyOwner {
        _addOperator(newOprtr);
    }

     /**
     * @dev Add new operator
     */
    function removeOperator(address theOprtr) external onlyOwner {
        _removeOperator(theOprtr);
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

import "./Roles.sol";

contract Operator is Context {
    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    Roles.Role private _operators;

    constructor() {
        if (!isOperator(_msgSender())) {
            _addOperator(_msgSender());
        }
    }

    modifier onlyOperator() {
        require(
            isOperator(_msgSender()),
            "OperatorRole: caller does not have the Operator role"
        );
        _;
    }

    function isOperator(address account) public view returns (bool) {
        return _operators.has(account);
    }

    function renounceOperator() public {
        _removeOperator(_msgSender());
    }

    function _addOperator(address account) internal {
        _operators.add(account);
        emit OperatorAdded(account);
    }

    function _removeOperator(address account) internal {
        _operators.remove(account);
        emit OperatorRemoved(account);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";



contract AtlantisVesting is Context, Ownable {
    using SafeMath for uint256;

    event ReleaseVesting(address indexed beneficiary, uint256 amount);
    event VestingLocked();
    event VestingUnLocked();

    bool private _isLock;

    IERC20 public _token;
    uint256 public _totalVestedAmount;
    uint256 public _totalReleased;
    mapping(address => uint256) private _beneficiaries;
    mapping(address => uint256) private _releasedAmounts;
    uint256 private immutable _startDate;
    uint256 private immutable _durationTime;

    address public asNativeToken = 0x1111111111111111111010101010101010101010;


    /**
     * @dev Set the beneficiary, start timestamp and vesting duration of the vesting wallet.
     */
    constructor(
        address tokenAddr,
        uint256 startTimestamp,
        uint256 durationSeconds,
        address[] memory beneficiaries,
        uint256[] memory vestingAmounts
    ) {
        require(startTimestamp > block.timestamp,
            "VestingWallet: start date can't be in past"  
        );

        require(tokenAddr != address(0), 
            "VestingWallet: token is zero address"
        );

        require(beneficiaries.length == vestingAmounts.length,
            "VestingWallet: length of addresses and amounts mismatch"
        );

        require(beneficiaries.length != 0,
            "VestingWallet: pass at least 1 beneficiary"
        );

        _startDate = startTimestamp;
        _durationTime = durationSeconds;
        _token = IERC20(tokenAddr);

        for (uint256 i = 0; i < beneficiaries.length; i++) {

            // the first 0 address means the other addresses are also 0 so they won't be checked
            if (beneficiaries[i] == address(0) || vestingAmounts[i] == 0) {
                // do nothing 
            } else {
                _totalVestedAmount = _totalVestedAmount.add(vestingAmounts[i]);
                _beneficiaries[beneficiaries[i]] = vestingAmounts[i];
                _releasedAmounts[beneficiaries[i]] = 0;
            }
        }

        _totalReleased = 0;

        _isLock = true;

    }

    /**
     * @dev charge the vesting contract
     */
    function chargeVesting(address vestingCharger) external onlyOwner {

        require(_token.allowance(vestingCharger, address(this)) >= _totalVestedAmount,
            "VestingWallet: there is not enough token to vest"
        );

        _token.transferFrom(vestingCharger, address(this), _totalVestedAmount);

        _isLock = false;
    }

    /**
     * @dev The contract should be able to receive Eth.
     */
    receive() external payable virtual {}

    /**
     * @dev Getter for the isLocked
     */
    function isLocked() public view virtual returns (bool) {
        return _isLock;
    }

    /**
     * @dev Getter for the start timestamp.
     */
    function startDate() public view virtual returns (uint256) {
        return _startDate;
    }

    /**
     * @dev Getter for the vesting duration.
     */
    function durationTime() public view virtual returns (uint256) {
        return _durationTime;
    }

    /**
     * @dev Amount of eth already released
     */
    function releasedOf(address beneficiary) public view virtual returns (uint256) {
        return _releasedAmounts[beneficiary];
    }


    /**
     * @dev Amount of token already released
     */
    function totalVestingOf(address beneficiary) public view virtual returns (uint256) {
        return _beneficiaries[beneficiary];
    }

    /**
     * @dev Release the native token (ether) that have already vested.
     *
     * Emits a {TokensReleased} event.
     */
    function release() external {
        require(
            !_isLock,
            "VestingWallet: locked"
        );

        uint256 releasable = vestedAmount(_msgSender(), uint64(block.timestamp)) - releasedOf(_msgSender());
       
        // TODO: check the result of this line
        _releasedAmounts[_msgSender()] = releasable.add(_releasedAmounts[_msgSender()]);

         _totalReleased += releasable;

        emit ReleaseVesting(_msgSender(), releasable);
        require(
            _token.transfer(_msgSender(), releasable),
            "VestingWallet: couldn't transfer vested amount"
        );
    }

    /**
     * @dev Calculates the amount of ether that has already vested. Default implementation is a linear vesting curve.
     */
    function vestedAmount(address beneficiary, uint64 timestamp) public view virtual returns (uint256) {
        return _vestingSchedule(totalVestingOf(beneficiary), timestamp);
    }

    /**
     * @dev Virtual implementation of the vesting formula. This returns the amout vested, as a function of time, for
     * an asset given its total historical allocation.
     */
    function _vestingSchedule(uint256 totalAllocation, uint64 timestamp) internal view virtual returns (uint256) {
        if (timestamp < startDate()) {
            return 0;
        } else if (timestamp > startDate() + durationTime()) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - startDate())) / durationTime();
        }
    }

    /**
     * @dev the owner of the vesting can lock the vesting 
     */
    function lockVesting() external onlyOwner {
        _isLock = true;
        emit VestingLocked();
    }

    /**
     * @dev the owner of the vesting can un-lock the vesting 
     */
    function unLockVesting() external onlyOwner {
        _isLock = false;
        emit VestingUnLocked();
    }


    /**
     * @dev the owner of the vesting can un-lock the vesting 
     */
    function evacuateVesting(address stuckToken, address payable reciever, uint256 amount) external onlyOwner {
        require(
            _isLock,
            "VestingWallet: evacuation only possible when vesting is locked"
        );

        if (stuckToken == asNativeToken) {

            reciever.transfer(amount);

            // require(
            //     reciever.transfer(amount),
            //     "VestingWallet: couldn't transfer native token"
            // );
        } else {

            IERC20 theToken = IERC20(stuckToken);
            require(
                theToken.transfer(reciever, amount),
                "VestingWallet: couldn't transfer token"
            );
        }        

    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
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