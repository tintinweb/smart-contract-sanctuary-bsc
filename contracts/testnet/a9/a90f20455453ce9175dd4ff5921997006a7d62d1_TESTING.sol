/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

// SPDX-License-Identifier: MIT

/* 
 * Website  : https://www.testing.com  
 * Name     : TESTING
 * Symbol   : TEST2
*/

pragma solidity 0.8.9;

/*
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Buy(address member, uint256 etherAmount, uint256 tokens);
    // event Sell(uint256 etherAmount, uint256 tokens);
}


/**
 * @dev Interface for the optional metadata functions from the BEP20 standard.
 *
 * _Available since v4.1._
 */
interface IBEP20Metadata is IBEP20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

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



contract BEP20 is Context, IBEP20, IBEP20Metadata {
    using SafeMath for uint256;
    mapping(address => uint256) public _balances;
    mapping(address => uint256) private _locktime_buy;

    string public _name;
    string public _symbol;
    uint8 public _decimal;
    address private owners;
    uint256 private _totalSupply;
    address[] public _freeze_account;
    uint256 public _token_rate = 18914000000000;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_, uint8 decimal_) {
        _name = name_;
        _symbol = symbol_;
        _decimal = decimal_;
        address msgSender = _msgSender();
        owners = msgSender;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {BEP20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimal;
    }

    function getOwner() public view virtual returns (address) {
        return owners;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function getOwnerBalance() public view returns (uint) {
        return owners.balance;
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
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */


    function buy() public payable returns (uint256) {
        uint256 _acc_balance = _balances[getOwner()];
        uint256 _one = 1000000000000000000;
        uint256 _one_bnb_token_qty = _one.div(_token_rate);//token qty of 1 bnb
        uint256 _token_qty = _one_bnb_token_qty.mul(msg.value);//token qty in value bnb

        require(_acc_balance >= _token_qty, "BEP20: transfer amount exceeds balance");
        // require(!_freeze_account[_msgSender()], "Account is freeze for 40 days!");
        require(_msgSender() != getOwner(), "Invalid sender");
        require(_msgSender() != address(0), "BEP20: transfer from the zero address");

        _balances[getOwner()] -= _token_qty;
        _balances[_msgSender()] += _token_qty;

        emit Transfer(getOwner(), _msgSender(), _token_qty);
        emit Buy(_msgSender(), msg.value, _token_qty);
        payable(getOwner()).transfer(msg.value);

        if (_locktime_buy[_msgSender()] <= 0) {
            freeze_account(_msgSender());
        }

        return _token_qty;
    }


    function sell(address recipient,uint256 amount) public returns (bool)  {
        uint256 _acc_balance = _balances[_msgSender()];
        uint256 _one = 1000000000000000000;
        // uint256 _hundred = 100000000000000000000;

        require(_acc_balance >= amount, "BEP20: transfer amount exceeds balance");
        require(_msgSender() != address(0), "BEP20: transfer from the zero address");
        uint256 _token_rate_bnb = _token_rate.div(_one);
        //uint256 _bnb_amount = _token_rate_bnb.mul(amount);


          _balances[_msgSender()] -= amount;
        //increment the token balance of this contract
        _balances[address(this)] += amount;

        /*
         * don't forget to emit the transfer event
         * so that external apps can reflect the transfer
         */
        emit Transfer(_msgSender(), recipient, amount);
        //emit Sell(address(this), _bnb_amount, amount);

        
        // e.g. the user is selling 100 tokens, send them 500 wei
        payable(_msgSender()).transfer(amount * _token_rate_bnb);

        // uint256 _bnb = _token_rate.mul(_hundred);
        // _balances[_msgSender()] -= amount;
        // _balances[recipient] += amount;
        // emit Transfer(_msgSender(), recipient, amount);
        // emit Sell(recipient, _bnb_amount, amount);
        // payable(_msgSender()).transfer(_bnb_amount);



        // uint256 _one_bnb_token_qty = _one.div(_token_rate);//token qty of 1 bnb
        // uint256 _token_qty = _one_bnb_token_qty.mul(msg.value);//token qty in value bnb

        // require(!_freeze_account[_msgSender()], "Account is freeze for 40 days!");



        // if (_locktime_buy[_msgSender()] <= 0) {
        //     freeze_account(_msgSender());
        // }
        return true;

    }

    function freeze_account(address account_address) private returns (bool) {
        _freeze_account.push(account_address);
        _locktime_buy[account_address] = block.timestamp;
        return true;
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        uint256 transfer_time = 3000 seconds;
        uint256 senderBalance = _balances[sender];
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(sender != recipient, "Sender and Receiver cannot be same");
        require(getOwner() != recipient, "Receiver cannot be owner");
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");

        if(block.timestamp >= _locktime_buy[_msgSender()] + transfer_time) {
            _balances[sender] = senderBalance - amount;
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        } else {
            revert("Account is freeze");
        }
    }
}

contract TESTING is BEP20,Ownable {

    constructor()
         BEP20("TESTING", "TEST2", 18) {
             /* 750 Million Total Supply */
            _mint(msg.sender, 10000000000000000000000);
        }

}