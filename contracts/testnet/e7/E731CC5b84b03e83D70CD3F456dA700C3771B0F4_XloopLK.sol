/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

// SPDX-License-Identifier: MIT
// FOR EDUCATIONAL AND INSPIRATIONAL PURPOSES ONLY.
// POWERED BY WWW.XLOOP.LINK

// File: contracts/LIB/XLTContext.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.11;

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
abstract contract XLTContext {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// File: contracts/LIB/SafeMath.sol

pragma solidity 0.8.11;

/**
 *
 * @notice Math operations with safety checks that revert on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
// File: contracts/INTF/IXloopFactory.sol

pragma solidity 0.8.11;

interface IXLoopFactory {
    function reward(address user) external;
}

// File: contracts/INTF/IXLT_IERC20.sol

// This is a file copied from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol

pragma solidity 0.8.11;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IXLT_IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

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
}

// File: contracts/INTF/IXLoopLK.sol

pragma solidity 0.8.11;

interface IXLoopLK is IXLT_IERC20 {
    function initialize(
        address p_pair,
        string memory p_name,
        string memory p_symbol,
        uint8 p_decimal,
        bool p_is_reward
    ) external;

    function mint(address user, uint256 value) external returns (bool);

    function burn(address user, uint256 value) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

// File: contracts/XloopLK.sol

pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

contract XloopLK is IXLoopLK, XLTContext {
    using SafeMath for uint256;

    address public immutable FACTORY;
    bool private _initialized = false;

    uint8 private _decimals;
    string private _symbol;
    string private _name;
    uint256 private _totalSupply;
    address private _pair;
    bool private _is_reward;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Mint(address indexed user, uint256 value);
    event Burn(address indexed user, uint256 value);

    constructor() {
        require(_msgSender() != address(0), "ADDR_ZERO");
        FACTORY = _msgSender();
    }

    function factory() public view virtual returns (address) {
        return FACTORY;
    }

    function initialized() public view virtual returns (bool) {
        return _initialized;
    }

    function initialize(
        address p_pair,
        string memory p_name,
        string memory p_symbol,
        uint8 p_decimal,
        bool p_is_reward
    ) external {
        require(_msgSender() == FACTORY && _initialized == false, "FORBIDDEN");
        _pair = p_pair;
        _name = p_name;
        _symbol = p_symbol;
        _decimals = p_decimal;
        _is_reward = p_is_reward;
        _initialized = true;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function pair() external view returns (address) {
        return _pair;
    }

    function isReward() external view returns (bool) {
        return _is_reward;
    }

    modifier onlyPair() {
        require(_msgSender() == _pair, "NOT_PAIR_OWNER");
        _;
    }

    /**
     * @dev transfer token for a specified address
     * @param to The address to transfer to.
     * @param amount The amount to be transferred.
     */
    function transfer(address to, uint256 amount) public returns (bool) {
        require(amount <= _balances[_msgSender()], "BALANCE_NOT_ENOUGH");
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(_msgSender(), to, amount);
        // Reward
        if (_is_reward) {
            IXLoopFactory(FACTORY).reward(_msgSender());
        }
        return true;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the the balance of.
     * @return balance An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) external view returns (uint256 balance) {
        return _balances[owner];
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param amount uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(amount <= _balances[from], "BALANCE_NOT_ENOUGH");
        require(
            amount <= _allowances[from][_msgSender()],
            "ALLOWANCE_NOT_ENOUGH"
        );
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        _allowances[from][_msgSender()] = _allowances[from][_msgSender()].sub(
            amount
        );
        emit Transfer(from, to, amount);
        // Reward
        if (_is_reward) {
            IXLoopFactory(FACTORY).reward(from);
        }
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of _msgSender().
     * @param spender The address which will spend the funds.
     * @param amount The amount of tokens to be spent.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner _allowances to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function mint(address user, uint256 amount)
        external
        onlyPair
        returns (bool)
    {
        _balances[user] = _balances[user].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), user, amount);
        return true;
    }

    function burn(address user, uint256 amount)
        external
        onlyPair
        returns (bool)
    {
        require(amount > 0 && amount <= _balances[user], "BALANCE_NOT_ENOUGH");
        _balances[user] = _balances[user].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(user, address(0), amount);
        return true;
    }
}