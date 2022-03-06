// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./KelpToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title KELP token initial distribution
 *
 * @dev Distribute purchasers, airdrop, reserve, and founder tokens
 */
contract KelpAirdrop is Ownable {
    using SafeMath for uint256;

    KelpToken public KELP;

    uint256 private constant decimalFactor = 10**uint256(18);
    enum AllocationType {
        PRESALE,
        FOUNDER,
        AIRDROP,
        ADVISOR,
        RESERVE,
        BONUS1,
        BONUS2,
        BONUS3
    }
    uint256 public constant INITIAL_SUPPLY = 1000000000 * decimalFactor;
    uint256 public AVAILABLE_TOTAL_SUPPLY = 1000000000 * decimalFactor;
    uint256 public AVAILABLE_PRESALE_SUPPLY = 230000000 * decimalFactor; // 100% Released at Token Distribution (TD)
    uint256 public AVAILABLE_FOUNDER_SUPPLY = 150000000 * decimalFactor; // 33% Released at TD +1 year -> 100% at TD +3 years
    uint256 public AVAILABLE_AIRDROP_SUPPLY = 10000000 * decimalFactor; // 100% Released at TD
    uint256 public AVAILABLE_ADVISOR_SUPPLY = 20000000 * decimalFactor; // 100% Released at TD +7 months
    uint256 public AVAILABLE_RESERVE_SUPPLY = 513116658 * decimalFactor; // 6.8% Released at TD +100 days -> 100% at TD +4 years
    uint256 public AVAILABLE_BONUS1_SUPPLY = 39053330 * decimalFactor; // 100% Released at TD +1 year
    uint256 public AVAILABLE_BONUS2_SUPPLY = 9354408 * decimalFactor; // 100% Released at TD +2 years
    uint256 public AVAILABLE_BONUS3_SUPPLY = 28475604 * decimalFactor; // 100% Released at TD +3 years

    uint256 public grandTotalClaimed = 0;
    uint256 public startTime;

    // Allocation with vesting information
    struct Allocation {
        uint8 AllocationSupply; // Type of allocation
        uint256 endCliff; // Tokens are locked until
        uint256 endVesting; // This is when the tokens are fully unvested
        uint256 totalAllocated; // Total tokens allocated
        uint256 amountClaimed; // Total tokens claimed
    }
    mapping(address => Allocation) public allocations;

    // List of admins
    mapping(address => bool) public airdropAdmins;

    // Keeps track of whether or not a 250 KELP airdrop has been made to a particular address
    mapping(address => bool) public airdrops;

    modifier onlyOwnerOrAdmin() {
        require(msg.sender == owner() || airdropAdmins[msg.sender]);
        _;
    }

    event LogNewAllocation(
        address indexed _recipient,
        AllocationType indexed _fromSupply,
        uint256 _totalAllocated,
        uint256 _grandTotalAllocated
    );
    event LogKelpClaimed(
        address indexed _recipient,
        uint8 indexed _fromSupply,
        uint256 _amountClaimed,
        uint256 _totalAllocated,
        uint256 _grandTotalClaimed
    );

    /**
     * @dev Constructor function - Set the kelp token address
     * @param _startTime The time when KelpAirdrop goes live
     */
    constructor(uint256 _startTime) {
        require(_startTime >= block.timestamp);
        require(
            AVAILABLE_TOTAL_SUPPLY ==
                AVAILABLE_PRESALE_SUPPLY
                    .add(AVAILABLE_FOUNDER_SUPPLY)
                    .add(AVAILABLE_AIRDROP_SUPPLY)
                    .add(AVAILABLE_ADVISOR_SUPPLY)
                    .add(AVAILABLE_BONUS1_SUPPLY)
                    .add(AVAILABLE_BONUS2_SUPPLY)
                    .add(AVAILABLE_BONUS3_SUPPLY)
                    .add(AVAILABLE_RESERVE_SUPPLY)
        );
        startTime = _startTime;
        KELP = new KelpToken(address(this));
    }

    /**
     * @dev Allow the owner of the contract to assign a new allocation
     * @param _recipient The recipient of the allocation
     * @param _totalAllocated The total amount of KELP available to the receipient (after vesting)
     * @param _supply The KELP supply the allocation will be taken from
     */
    function setAllocation(
        address _recipient,
        uint256 _totalAllocated,
        AllocationType _supply
    ) public onlyOwner {
        require(
            allocations[_recipient].totalAllocated == 0 && _totalAllocated > 0
        );
        require(
            _supply >= AllocationType.PRESALE &&
                _supply <= AllocationType.BONUS3
        );
        require(_recipient != address(0));
        if (_supply == AllocationType.PRESALE) {
            AVAILABLE_PRESALE_SUPPLY = AVAILABLE_PRESALE_SUPPLY.sub(
                _totalAllocated
            );
            allocations[_recipient] = Allocation(
                uint8(AllocationType.PRESALE),
                0,
                0,
                _totalAllocated,
                0
            );
        } else if (_supply == AllocationType.FOUNDER) {
            AVAILABLE_FOUNDER_SUPPLY = AVAILABLE_FOUNDER_SUPPLY.sub(
                _totalAllocated
            );
            allocations[_recipient] = Allocation(
                uint8(AllocationType.FOUNDER),
                startTime + 1 * 365 days,
                startTime + 3 * 365 days,
                _totalAllocated,
                0
            );
        } else if (_supply == AllocationType.ADVISOR) {
            AVAILABLE_ADVISOR_SUPPLY = AVAILABLE_ADVISOR_SUPPLY.sub(
                _totalAllocated
            );
            allocations[_recipient] = Allocation(
                uint8(AllocationType.ADVISOR),
                startTime + 209 days,
                0,
                _totalAllocated,
                0
            );
        } else if (_supply == AllocationType.RESERVE) {
            AVAILABLE_RESERVE_SUPPLY = AVAILABLE_RESERVE_SUPPLY.sub(
                _totalAllocated
            );
            allocations[_recipient] = Allocation(
                uint8(AllocationType.RESERVE),
                startTime + 100 days,
                startTime + 4 * 365 days,
                _totalAllocated,
                0
            );
        } else if (_supply == AllocationType.BONUS1) {
            AVAILABLE_BONUS1_SUPPLY = AVAILABLE_BONUS1_SUPPLY.sub(
                _totalAllocated
            );
            allocations[_recipient] = Allocation(
                uint8(AllocationType.BONUS1),
                startTime + 1 * 365 days,
                startTime + 1 * 365 days,
                _totalAllocated,
                0
            );
        } else if (_supply == AllocationType.BONUS2) {
            AVAILABLE_BONUS2_SUPPLY = AVAILABLE_BONUS2_SUPPLY.sub(
                _totalAllocated
            );
            allocations[_recipient] = Allocation(
                uint8(AllocationType.BONUS2),
                startTime + 2 * 365 days,
                startTime + 2 * 365 days,
                _totalAllocated,
                0
            );
        } else if (_supply == AllocationType.BONUS3) {
            AVAILABLE_BONUS3_SUPPLY = AVAILABLE_BONUS3_SUPPLY.sub(
                _totalAllocated
            );
            allocations[_recipient] = Allocation(
                uint8(AllocationType.BONUS3),
                startTime + 3 * 365 days,
                startTime + 3 * 365 days,
                _totalAllocated,
                0
            );
        }
        AVAILABLE_TOTAL_SUPPLY = AVAILABLE_TOTAL_SUPPLY.sub(_totalAllocated);
        emit LogNewAllocation(
            _recipient,
            _supply,
            _totalAllocated,
            grandTotalAllocated()
        );
    }

    /**
     * @dev Add an airdrop admin
     */
    function setAirdropAdmin(address _admin, bool _isAdmin) public onlyOwner {
        airdropAdmins[_admin] = _isAdmin;
    }

    /**
     * @dev perform a transfer of allocations
     * @param _recipient is a list of recipients
     */
    function airdropTokens(address[] memory _recipient)
        public
        onlyOwnerOrAdmin
    {
        require(block.timestamp >= startTime);
        uint256 airdropped;
        for (uint256 i = 0; i < _recipient.length; i++) {
            if (!airdrops[_recipient[i]]) {
                airdrops[_recipient[i]] = true;
                require(KELP.transfer(_recipient[i], 250 * decimalFactor));
                airdropped = airdropped.add(250 * decimalFactor);
            }
        }
        AVAILABLE_AIRDROP_SUPPLY = AVAILABLE_AIRDROP_SUPPLY.sub(airdropped);
        AVAILABLE_TOTAL_SUPPLY = AVAILABLE_TOTAL_SUPPLY.sub(airdropped);
        grandTotalClaimed = grandTotalClaimed.add(airdropped);
    }

    /**
     * @dev Transfer a recipients available allocation to their address
     * @param _recipient The address to withdraw tokens for
     */
    function transferTokens(address _recipient) public {
        require(
            allocations[_recipient].amountClaimed <
                allocations[_recipient].totalAllocated
        );
        require(block.timestamp >= allocations[_recipient].endCliff);
        require(block.timestamp >= startTime);
        uint256 newAmountClaimed;
        if (allocations[_recipient].endVesting > block.timestamp) {
            // Transfer available amount based on vesting schedule and allocation
            newAmountClaimed = allocations[_recipient]
                .totalAllocated
                .mul(block.timestamp.sub(startTime))
                .div(allocations[_recipient].endVesting.sub(startTime));
        } else {
            // Transfer total allocated (minus previously claimed tokens)
            newAmountClaimed = allocations[_recipient].totalAllocated;
        }
        uint256 tokensToTransfer = newAmountClaimed.sub(
            allocations[_recipient].amountClaimed
        );
        allocations[_recipient].amountClaimed = newAmountClaimed;
        require(KELP.transfer(_recipient, tokensToTransfer));
        grandTotalClaimed = grandTotalClaimed.add(tokensToTransfer);
        emit LogKelpClaimed(
            _recipient,
            allocations[_recipient].AllocationSupply,
            tokensToTransfer,
            newAmountClaimed,
            grandTotalClaimed
        );
    }

    // Returns the amount of KELP allocated
    function grandTotalAllocated() public view returns (uint256) {
        return INITIAL_SUPPLY - AVAILABLE_TOTAL_SUPPLY;
    }

    // Allow transfer of accidentally sent ERC20 tokens
    function refundTokens(address _recipient, address _token) public onlyOwner {
        require(_token != address(KELP));
        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(_recipient, balance));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 */
contract KelpToken is IERC20 {
    using SafeMath for uint256;

    // Kelp Token parameters
    string public name = "Kelp Finance";
    string public symbol = "KELP";
    uint8 public constant decimals = 18;
    uint256 public constant decimalFactor = 10**uint256(decimals);
    uint256 public constant totalSupply = 1000000000 * decimalFactor;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    /**
     * @dev Constructor for Kelp creation
     * @dev Assigns the totalSupply to the KelpAirdrop contract
     */
    constructor(address _kelpAirdropContractAddress) {
        require(_kelpAirdropContractAddress != address(0));
        balances[_kelpAirdropContractAddress] = totalSupply;
        emit Transfer(address(0), _kelpAirdropContractAddress, totalSupply);
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return balance uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint256 _addedValue)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(
            _addedValue
        );
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint256 _subtractedValue)
        public
        returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
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