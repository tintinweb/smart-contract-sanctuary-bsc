/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// Sources flattened with hardhat v2.12.0 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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


// File @openzeppelin/contracts/utils/math/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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


// File @openzeppelin/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}


// File contracts/BeeFarm.sol

pragma solidity 0.8.17;
interface IBeePay {
    function reward(address account, uint256 amount) external returns (bool);
    function sponsors(address user) external returns (address);
}

interface IHoney {
    function reflectBeeFarmBalance(address owner, uint256 balance)
        external
        returns (bool);
}

contract BeeFarm is Context, Ownable, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public totalSupply;

    string public name;
    string public symbol;
    uint8 public decimals;
    address public beePay;
    IHoney public honey;
    address public receiver;
    bool public transferEnabled;

    modifier onlyHoney() {
        require(
            address(honey) == _msgSender(),
            "Ownable: caller is not the Honey"
        );
        _;
    }

    modifier onlyBeePay() {
        require(beePay == _msgSender(), "Ownable: caller is not the BeePay");
        _;
    }

    constructor() {
        name = "BeeFarm";
        symbol = "$BeeFarm";
        decimals = 5;
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        pure
        override
        returns (bool)
    {
        require(false, "This token can not transfer");
        return true;
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        require(transferEnabled == true, "This token can not transfer");
        require(receiver != address(0), "Receiver must not be zero address");
        require(spender == receiver, "Only can allow to receiver");
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public pure override returns (bool) {
        require(false, "This token can not transfer");
        return true;
    }

    /**
     * @dev Mint `amount` tokens and increasing the total supply.
     */
    function mint(address account, uint256 amount)
        public
        onlyBeePay
        returns (bool)
    {
        require(
            address(beePay) != address(0) && address(honey) != address(0),
            "BeePay and Honey address is not set"
        );
        _mint(account, amount);
        honey.reflectBeeFarmBalance(account, balanceOf[account]);
        return true;
    }

    /**
     * @dev Burn `amount` tokens and decreasing the total supply.
     */
    function burn(address account, uint256 amount)
        public
        onlyHoney
        returns (bool)
    {
        require(
            address(beePay) != address(0) && address(honey) != address(0),
            "BeePay and Honey address is not set"
        );
        _burn(account, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        balanceOf[sender] = balanceOf[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        totalSupply = totalSupply.add(amount);
        balanceOf[account] = balanceOf[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        balanceOf[account] = balanceOf[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setTokens(address _beePay, address _honey) public onlyOwner {
        beePay = _beePay;
        honey = IHoney(_honey);
    }

    function enableTransfer(address _receiver, bool _enableTransfer)
        public
        onlyOwner
    {
        receiver = _receiver;
        transferEnabled = _enableTransfer;
    }
}


// File contracts/BeePay.sol

pragma solidity 0.8.17;
interface IBeeFarm {
    function burn(address account, uint256 amount) external returns (bool);
    function mint(address account, uint256 amount) external returns (bool);
}

contract BeePay is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => address[]) public affiliate;

    mapping(address => address) public sponsors;

    mapping(address => bool) public experienced;

    uint256 public totalSupply;
    uint8 public decimals;
    string public symbol;
    string public name;
    IBeeFarm public beeFarm;
    address public honey;
    uint256 public treasuryRewards;

    event Reward(address account, uint256 amount);

    modifier onlyHoney() {
        require(honey == _msgSender(), "Ownable: caller is not the Honey");
        _;
    }

    constructor() {
        name = "BeePay";
        symbol = "$BeePay";
        decimals = 5;
        totalSupply = 2_000_000_000_000_000;
        treasuryRewards = 900_000_000_000_000;
        balanceOf[address(this)] = treasuryRewards;
        balanceOf[msg.sender] = totalSupply.sub(treasuryRewards);
        experienced[msg.sender] = true;
        experienced[address(this)] = true;
        emit Transfer(
            address(0),
            msg.sender,
            totalSupply.sub(treasuryRewards)
        );
        emit Transfer(address(0), address(this), treasuryRewards);
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        if (recipient == msg.sender) {
            require(address(beeFarm) != address(0), "Tranfer error: BeeFarm address is not set");
            _transfer(_msgSender(), address(0), amount);
            beeFarm.mint(recipient, amount);
        } else {
            _transfer(_msgSender(), recipient, amount);
        }
        return true;
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            allowance[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            allowance[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            allowance[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    /**
     * @dev Burn `amount` tokens and decreasing the total supply.
     */
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        balanceOf[sender] = balanceOf[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        if (experienced[recipient] == false) {
            experienced[recipient] = true;
            if (isContract(sender) == false && isContract(recipient) == false && affiliate[sender].length < 10) {
                affiliate[sender].push(recipient);
                sponsors[recipient] = sender;
            }
        }
        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        balanceOf[account] = balanceOf[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowance for certain subsystems, etc.
   *

   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setTokens(address _honey, address _beeFarm) public onlyOwner {
        honey = _honey;
        beeFarm = IBeeFarm(_beeFarm);
    }
    
    function reward(address account, uint256 amount) public onlyHoney returns (bool) {
        _transfer(address(this), account, amount);
        emit Reward(
            account,
            amount
        );
        return true;
    }

    function isContract(address addr) public view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}


contract Honey is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private balances;

    uint256 public totalSupply;
    uint256 private payableSupply;
    uint8 public decimals;
    string public symbol;
    string public name;
    IBeeFarm public beeFarm;
    IBeePay public beePay;
    mapping(address => UserInfo) public userInfos;
    uint256[] public tierMembers = [
        0,
        0,
        0,
        0,
        0
    ];
    uint256 public multiplier = 1000;
    uint256 public sponsorReward = 50;
    uint256 public currentStage = 0;
    uint256 private lastUpdate;

    uint256[] public tiers = [
        1_000_000_000, // 10_000
        5_000_000_000, // 50_000
        10_000_000_000, // 100_000
        50_000_000_000, // 500_000
        100_000_000_000 // 1_000_000
    ];

    struct RewardStage {
        uint256 minimumSupply;
        uint256 startTime;
        uint256 endTime;
    }

    RewardStage[] public rewardStages;

    struct UserInfo {
        uint256 lastAction;
        uint256 beeFarmBalance;
        address sponsor;
    }

    event Withdraw (
        address account,
        uint256 amount
    );

    /**
     * @dev Constructor.
     *
     * Requirements:
     *
     * - `name` Honey
     * - `symbol` $Honey
     * - `decimals` 5
     * - `totalSupply` 9B
     */
    constructor() {
        name = "Honey";
        symbol = "$Honey";
        decimals = 5;
        _mint(address(this), 900_000_000_000_000);
        payableSupply = 900_000_000_000_000;
        emit Transfer(
            address(0),
            address(this),
            totalSupply
        );
        RewardStage memory _rewardStage;
        _rewardStage.minimumSupply = 700_000_000_000_000; // 7B
        _rewardStage.endTime = 9999999999;
        rewardStages.push(_rewardStage);
        _rewardStage.minimumSupply = 500_000_000_000_000; // 7B
        _rewardStage.endTime = 9999999999;
        rewardStages.push(_rewardStage);
        _rewardStage.minimumSupply = 200_000_000_000_000; // 7B
        _rewardStage.endTime = 9999999999;
        rewardStages.push(_rewardStage);
        _rewardStage.minimumSupply = 0; // 7B
        _rewardStage.endTime = 9999999999;
        rewardStages.push(_rewardStage);
    }

    modifier onlyBeeFarm() {
        require(address(beeFarm) == _msgSender(), "Ownable: caller is not the BeeFarm");
        _;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external view returns (uint256) {
        uint256 _pendingReward = calculatePendingReward(userInfos[account].lastAction, userInfos[account].beeFarmBalance);
        return balances[account].add(_pendingReward);
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        require(false, "Can not transfer this token");
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return 0;
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        require(false, "Can not transfer this token");
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        require(false, "Can not transfer this token");
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        require(false, "Can not transfer this token");
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        require(false, "Can not transfer this token");
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        balances[sender] = balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        totalSupply = totalSupply.add(amount);
        balances[account] = balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        balances[account] = balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function reflectBeeFarmBalance(address account, uint256 balance) public onlyBeeFarm returns (bool) {
        updateReward(account);
        uint256 _oldBeeFarmBalance = userInfos[account].beeFarmBalance;
        userInfos[account].beeFarmBalance = balance;
        if (userInfos[account].sponsor == address(0)) {
            address _sponsor = beePay.sponsors(account);
            if (_sponsor != address(0)) userInfos[account].sponsor = _sponsor;
        }
        updateRewardStages(_oldBeeFarmBalance, balance);
        return true;
    }

    function withdraw(uint256 amount) public returns (bool) {
        updateReward(_msgSender());
        require(balances[_msgSender()] >= amount, "Insufficient balance");
        require(amount <= userInfos[_msgSender()].beeFarmBalance.mul(2), "Withdraw amount can't exceed more than double BeeFarm balance");
        _burn(_msgSender(), amount);
        beeFarm.burn(_msgSender(), amount.div(2));
        uint256 _oldBeeFarmBalance = userInfos[_msgSender()].beeFarmBalance;
        userInfos[_msgSender()].beeFarmBalance = _oldBeeFarmBalance.sub(amount.div(2));
        updateRewardStages(_oldBeeFarmBalance, userInfos[_msgSender()].beeFarmBalance);
        address _sponsor = beePay.sponsors(_msgSender());
        if (_sponsor != address(0)) {
            beePay.reward(_sponsor, amount.mul(sponsorReward).div(multiplier));
            amount = amount.sub(amount.mul(sponsorReward).div(multiplier));
        }
        beePay.reward(_msgSender(), amount);
        emit Withdraw(
            _msgSender(),
            amount
        );
        return true;
    }

    function updateReward(address account) internal returns (bool) {
        uint256 beeFarmBalance = userInfos[account].beeFarmBalance;
        if (beeFarmBalance >= tiers[0]) {
            uint256 pendingReward = calculatePendingReward(userInfos[account].lastAction, beeFarmBalance);
            _transfer(address(this), account, pendingReward);
        }
        userInfos[account].lastAction = block.timestamp;
        return true;
    }

    function calculatePendingReward(uint256 lastAction, uint256 beeFarmBalance) internal view returns (uint256) {
        if (beeFarmBalance < tiers[0]) return 0;
        uint256 _lastStage = getLastStage(lastAction);
        if (_lastStage == rewardStages.length) return 0;
        uint256 _pendingReward;
        for(uint i=_lastStage; i<currentStage+1;i++) {
            uint256 _endTime = i == currentStage && block.timestamp < rewardStages[i].endTime ? block.timestamp : rewardStages[i].endTime;
            _pendingReward += getDailyRewards(beeFarmBalance, i).mul(_endTime.sub(lastAction)).div(86400);
            lastAction = _endTime;
        }
        return _pendingReward;
    }

    function getLastStage(uint256 lastAction) internal view returns (uint256) {
        for (uint i=0; i < rewardStages.length; i++) {
            if (rewardStages[i].endTime > lastAction) return i;
        }
        return rewardStages.length;
    }

    function updateRewardStages(uint256 oldBalance, uint256 newBalance) internal returns (bool) {
        updatePayableSupply();
        uint256 _oldTier = getTierIndex(oldBalance);
        uint256 _newTier = getTierIndex(newBalance);
        if (_oldTier == _newTier) return true;
        if (_oldTier < tiers.length) tierMembers[_oldTier] = tierMembers[_oldTier].sub(1);
        if (_newTier < tiers.length) tierMembers[_newTier] = tierMembers[_newTier].add(1);
        uint256 _initSupply = payableSupply;
        for (uint i=0; i<rewardStages.length; i++) {
            if (rewardStages[i].endTime <= block.timestamp) continue;
            uint256 _startTime = rewardStages[i].startTime > block.timestamp ? rewardStages[i].startTime : block.timestamp;
            uint256 _stageDailyRewards;
            for (uint j=0; j<tiers.length; j++) {
                _stageDailyRewards = _stageDailyRewards.add(getDailyRewards(tiers[j], i).mul(tierMembers[j]));
            }
            if (_stageDailyRewards == 0) continue;
            rewardStages[i].endTime = (_initSupply.sub(rewardStages[i].minimumSupply)).mul(86400).div(_stageDailyRewards).add(_startTime);
            if (i+1 < rewardStages.length) rewardStages[i+1].startTime = rewardStages[i].endTime;
            _initSupply = _initSupply.sub(_stageDailyRewards.mul(rewardStages[i].endTime.sub(_startTime)).div(86400));
        }
        return true;
    }

    function updatePayableSupply() internal returns (bool) {
        uint256 _startTime = lastUpdate;
        for (uint i=0; i<rewardStages.length; i++) {
            if (_startTime == block.timestamp) break;
            if (rewardStages[i].endTime <= lastUpdate) continue;
            uint256 _endTime = block.timestamp < rewardStages[i].endTime ? block.timestamp : rewardStages[i].endTime;
            uint256 _stageDailyRewards;
            for (uint j=0; j<tiers.length; j++) {
                _stageDailyRewards = _stageDailyRewards.add(getDailyRewards(tiers[j], i).mul(tierMembers[j]));
            }
            payableSupply = payableSupply.sub(_stageDailyRewards.mul(_endTime.sub(_startTime)).div(86400));
            _startTime = _endTime;
        }
        lastUpdate = block.timestamp;
        return true;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function getTierIndex(uint256 balance) internal view returns (uint256) {
        for(uint i=tiers.length; i>0; i--) {
            if (balance >= tiers[i - 1]) return i - 1;
        }
        return tiers.length;
    }

    function getDailyRewards(uint256 balance, uint256 stage) internal view returns (uint256) {
        if (stage == 0) { // 7B
            if (balance >= tiers[4]) return 1_500_000_000; // 15000
            if (balance >= tiers[3]) return 500_000_000; // 5000
            if (balance >= tiers[2]) return 150_000_000; // 1500
            if (balance >= tiers[1]) return 50_000_000; // 500
            if (balance >= tiers[0]) return 20_000_000; // 200
            return 0;
        }
        if (stage == 1) { // 5B
            if (balance >= tiers[4]) return 1_500_000_000; // 15000
            if (balance >= tiers[3]) return 500_000_000; // 5000
            if (balance >= tiers[2]) return 150_000_000; // 1500
            if (balance >= tiers[1]) return 50_000_000; // 500
            if (balance >= tiers[0]) return 20_000_000; // 200
            return 0;
        }
        if (stage == 2) { // 2B
            if (balance >= tiers[4]) return 1_500_000_000; // 15000
            if (balance >= tiers[3]) return 500_000_000; // 5000
            if (balance >= tiers[2]) return 150_000_000; // 1500
            if (balance >= tiers[1]) return 50_000_000; // 500
            if (balance >= tiers[0]) return 20_000_000; // 200
            return 0;
        }
        if (balance >= tiers[4]) return 1_500_000_000; // 15000
        if (balance >= tiers[3]) return 500_000_000; // 5000
        if (balance >= tiers[2]) return 150_000_000; // 1500
        if (balance >= tiers[1]) return 50_000_000; // 500
        if (balance >= tiers[0]) return 20_000_000; // 200
        return 0;
    }

    function setTokens(address _beePay, address _beeFarm) public onlyOwner {
        beePay = IBeePay(_beePay);
        beeFarm = IBeeFarm(_beeFarm);
    }
}