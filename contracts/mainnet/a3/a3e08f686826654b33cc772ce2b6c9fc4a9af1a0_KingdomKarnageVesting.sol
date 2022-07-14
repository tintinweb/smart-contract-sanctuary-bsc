/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.2;

interface IBEP20 {
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
    function allowance(address _owner, address spender)
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
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
contract Ownable is Context {
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
    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

contract KingdomKarnageVesting is Context, Ownable {
    using SafeMath for uint256;

    address public kingdomToken;
    
    uint256 constant public SECONDS_IN_A_DAY = 28800;
    
    uint256 constant public VESTING_LONG_PERIOD = 450; // 15 months
    uint256 constant public VESTING_MID_PERIOD = 360; // 12 months
    uint256 constant public VESTING_SHORT_PERIOD = 270; // 9 months

    address[] public users;
    mapping (address => uint256) private _userIndex;
    mapping (address => bool) public isFreezed;
    mapping (address => uint256) public vestingAmounts;
    mapping (address => uint256) public claimedAmounts;
    mapping (address => uint) public vestingPeriods;

    uint256 public minAmount;
    uint256 public maxAmount;

    uint256 public startTime;

    event Claim(address indexed sender, uint amount, uint time);
    event StartVesting(address indexed sender, uint time);
    event AddUsers(address indexed sender, address[] addrs, uint256[] amounts);
    event RemoveUsers(address indexed sender, address[] addrs);
    event Freeze(address indexed sender, address addr);
    event Unfreeze(address indexed sender, address addr);
    event Withdraw(address indexed sender, address to, uint256 amount);

    constructor(address _kingdomToken, uint256 _min, uint256 _max) public {
        require(_kingdomToken != address(0x0), 'Vesting: Invalid Address');
        require(_max > _min, 'Vesting: Invalid Range');
        minAmount = _min;
        maxAmount = _max;
        kingdomToken = _kingdomToken;
        users.push(address(0x0));
    }

    function startVesting() external onlyOwner {
        startTime = block.number;
        emit StartVesting(msg.sender, startTime);
    }

    function addUsers(address[] calldata addrs, uint256[] calldata amounts, uint256[] calldata periods) external onlyOwner {
        require(addrs.length == amounts.length, 'Vesting: Invalid Data');
        require(amounts.length == periods.length, 'Vesting: Invalid Data');
        
        for (uint i = 0; i < addrs.length; i++) {
            require(addrs[i] != address(0x0), 'Vesting: Invalid Address');
            require(amounts[i] >= minAmount && amounts[i] <= maxAmount, 'Vesting: Invalid Amount');
            require(periods[i] >= 0 && periods[i] <= 2, 'Vesting: Invalid Period');
            if (_userIndex[addrs[i]] == 0 ) {
                users.push(addrs[i]);
                vestingAmounts[addrs[i]] = amounts[i];
                vestingPeriods[addrs[i]] = periods[i];
                _userIndex[addrs[i]] = users.length - 1;
            }
        }

        emit AddUsers(msg.sender, addrs, amounts);
    }

    function removeUsers(address[] calldata addrs) external onlyOwner {
        for (uint i = 0; i < addrs.length; i++) {
            require(addrs[i] != address(0x0), 'Vesting: Invalid Address');
            if (_userIndex[addrs[i]] != 0) {
                address lastAddr = users[users.length -1];
                users[_userIndex[addrs[i]]] = lastAddr;
                _userIndex[lastAddr] = _userIndex[addrs[i]];
                _userIndex[addrs[i]] = 0;
                vestingAmounts[addrs[i]] = 0;
                users.pop();
            }
        }
        emit RemoveUsers(msg.sender, addrs);
    }

    function freeze(address _addr) external onlyOwner {
        isFreezed[_addr] = true;
        emit Freeze(msg.sender, _addr);
    }

    function unfreeze(address _addr) external onlyOwner {
        isFreezed[_addr] = false;
        emit Unfreeze(msg.sender, _addr);
    }

    function withdraw(address to, uint256 amount) external onlyOwner {
        IBEP20(kingdomToken).transfer(to, amount);
        emit Withdraw(msg.sender, to, amount);
    }

    function availableAmount(address account) public view returns (uint256) {
        if ((isFreezed[account] == false) && (startTime > 0)) {
            uint256 timePassed = block.number.sub(startTime);
            uint256 vestingPeriod;
            if (vestingPeriods[account] == 0) {
                vestingPeriod = VESTING_SHORT_PERIOD;
            } else if (vestingPeriods[account] == 1) {
                vestingPeriod = VESTING_MID_PERIOD;
            } else if (vestingPeriods[account] == 2) {
                vestingPeriod = VESTING_LONG_PERIOD;
            }
            uint256 unlockedAmount = vestingAmounts[account].mul(timePassed).div(SECONDS_IN_A_DAY).div(vestingPeriod);

            uint256 claimableAmount = unlockedAmount.sub(claimedAmounts[account]);
            return claimableAmount;
        }
        return 0;
    }

    function claim() external {
        require(startTime > 0, 'Vesting: Not started');
        require(vestingAmounts[msg.sender] > 0, 'Vesting: Not vested');
        
        uint256 claimableAmount = availableAmount(msg.sender);

        require(claimableAmount > 0, 'Vesting: No claimable amount');
        IBEP20(kingdomToken).transfer(msg.sender, claimableAmount);
        claimedAmounts[msg.sender] = claimedAmounts[msg.sender].add(claimableAmount);

        emit Claim(msg.sender, claimableAmount, block.number);
    }

    function userLength() external view returns (uint256) {
        return users.length;
    }
}