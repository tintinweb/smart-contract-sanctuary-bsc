/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

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

/**
* @title Owner
* @dev Set & change owner
*/
contract Owner {

    address private _owner;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == _owner, "Caller is not owner");
        _;
    }

    /**
    * @dev Set contract deployer as owner
    */
    constructor() {
        _owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), _owner);
    }

    /**
    * @dev Change owner
    * @param newOwner address of new owner
    */
    function changeOwner(address newOwner) public virtual isOwner {
        emit OwnerSet(_owner, newOwner);
        _owner = newOwner;
    }

    /**
    * @dev Remove owner
    */
    function removeOwner() public virtual isOwner {
        emit OwnerSet(_owner, address(0));
        _owner = address(0);
    }

    /**
    * @dev Return owner address
    * @return address of owner
    */
    function getOwner() external view returns (address) {
        return _owner;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Config is Owner {
    using SafeMath for uint256;

    address public _swapPair;

    //Fee = x / 1000

    uint256 public _marketFee = 10;

    uint256 public _liquidityFee = 30;

    uint256 public _fundFee = 10;

    uint256 [] public _recommendFee = [30,20,10,5,5];

    address public _marketAddress = 0x827F2A72B23367Ed0EBD620855Aa24B3f24C2A62;
    address public _liquidityAddress = 0xb55b4f246AfaF75bFdAa1C3cBF28BE4de2EfBc5D;
    address public _fundAddress = 0xb46ced2b7977E8BCE3E3812d3a8298A01f7ae401;

    mapping (address => bool) _whiteList;

    bool public _botWall = true;

	function setSwapPair(address addr) public isOwner returns (bool) {
        _swapPair = addr;
        return true;
    }
	
    function addWhiteList(address addr) public isOwner returns (bool) {
        _whiteList[addr] = true;
        return true;
    }

    function removeWhiteList(address addr) public isOwner returns (bool) {
        _whiteList[addr] = false;
        return true;
    }

    function switchBotWall() public isOwner returns (bool) {
        _botWall = !_botWall;
        return true;
    }

    function getAllFee() public view returns (uint256) {
        uint256 all;

        all = all.add(_marketFee);
        all = all.add(_liquidityFee);
        all = all.add(_fundFee);

        for(uint256 i=0;i<_recommendFee.length;i++) {
            all = all.add(_recommendFee[i]);
        }

        return all;
    }
}

contract Team is Config {
    mapping (address => address) _recommend;

    mapping (address => bool) _publicAddress;

    event Recommend(address indexed recommendMember, address indexed member);

    constructor () {
        _publicAddress[address(0)] = true;
        _publicAddress[address(this)] = true;
        _publicAddress[0xB1b9b4bbe8a92d535F5Df2368e7Fd2ecFB3A1950] = true;
        _publicAddress[0x10ED43C718714eb63d5aA57B78B54704E256024E] = true;
        
        _recommend[msg.sender] = address(this);
        _recommend[0x827F2A72B23367Ed0EBD620855Aa24B3f24C2A62] = address(this);
        _recommend[0xb55b4f246AfaF75bFdAa1C3cBF28BE4de2EfBc5D] = address(this);
        _recommend[0xb46ced2b7977E8BCE3E3812d3a8298A01f7ae401] = address(this);
    }

    function getPublicAddress(address addr) public view returns (bool) {
        return _publicAddress[addr];
    }

    function setPublicAddress(address addr) public isOwner returns (bool) {
        _publicAddress[addr] = !_publicAddress[addr];
        return true;
    }

    function getRecommend(address addr) public view returns (address) {
        return _recommend[addr];
    }

    function setRecommend(address leadMember, address member) public isOwner returns (bool) {
        _recommend[member] = leadMember;
        return true;
    }

    function _setRecommend(address recommendMember, address member) internal returns (bool) {
        if (_recommend[member] != address(0)) { return false; }
        if (_recommend[recommendMember] == member) { return false; }

        if (_publicAddress[recommendMember] || _publicAddress[member]) { return false; }
        if (recommendMember == _swapPair  || member == _swapPair) { return false; }

        _recommend[member] = recommendMember;

        emit Recommend(recommendMember, member);

        return true;
    }
}

/**
* @dev Optional functions from the ERC20 standard.
*/
abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
    * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
    * these values are immutable: they can only be set once during
    * construction.
    */
    constructor (string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;
    }

    /**
    * @dev Returns the name of the token.
    */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
    * @dev Returns the symbol of the token, usually a shorter version of the
    * name.
    */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the number of decimals used to get its user representation.
    * For example, if `decimals` equals `2`, a balance of `505` tokens should
    * be displayed to a user as `5,05` (`505 / 10 ** 2`).
    *
    * Tokens usually opt for a value of 18, imitating the relationship between
    * Ether and Wei.
    *
    * NOTE: This information is only used for _display_ purposes: it in
    * no way affects any of the arithmetic of the contract, including
    * {IERC20-balanceOf} and {IERC20-transfer}.
    */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

/**
* @dev Implementation of the {IERC20} interface.
*
* This implementation is agnostic to the way tokens are created. This means
* that a supply mechanism has to be added in a derived contract using {_mint}.
* For a generic mechanism see {ERC20Mintable}.
*
* TIP: For a detailed writeup see our guide
* https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
* to implement supply mechanisms].
*
* We have followed general OpenZeppelin guidelines: functions revert instead
* of returning `false` on failure. This behavior is nonetheless conventional
* and does not conflict with the expectations of ERC20 applications.
*
* Additionally, an {Approval} event is emitted on calls to {transferFrom}.
* This allows applications to reconstruct the allowance for all accounts just
* by listening to said events. Other implementations of the EIP may not emit
* these events, as it isn't required by the specification.
*
* Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
* functions have been added to mitigate the well-known issues around setting
* allowances. See {IERC20-approve}.
*/
abstract contract ERC20 is IERC20, Team, ERC20Detailed {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
    * @dev See {IERC20-totalSupply}.
    */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev See {IERC20-balanceOf}.
    */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
    * @dev See {IERC20-transfer}.
    *
    * Requirements:
    *
    * - `recipient` cannot be the zero address.
    * - the caller must have a balance of at least `amount`.
    */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
    * @dev See {IERC20-allowance}.
    */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
    * @dev See {IERC20-approve}.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    */
    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
    * @dev See {IERC20-transferFrom}.
    *
    * Emits an {Approval} event indicating the updated allowance. This is not
    * required by the EIP. See the note at the beginning of {ERC20};
    *
    * Requirements:
    * - `sender` and `recipient` cannot be the zero address.
    * - `sender` must have a balance of at least `value`.
    * - the caller must have allowance for `sender`'s tokens of at least
    * `amount`.
    */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
    * @dev Atomically increases the allowance granted to `spender` by the caller.
    *
    * This is an alternative to {approve} that can be used as a mitigation for
    * problems described in {IERC20-approve}.
    *
    * Emits an {Approval} event indicating the updated allowance.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
    * @dev Atomically decreases the allowance granted to `spender` by the caller.
    *
    * This is an alternative to {approve} that can be used as a mitigation for
    * problems described in {IERC20-approve}.
    *
    * Emits an {Approval} event indicating the updated allowance.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    * - `spender` must have allowance for the caller of at least
    * `subtractedValue`.
    */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
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
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);

        _setRecommend(sender, recipient);

        if(_whiteList[sender] == false) {
            require(amount <= _balances[sender].mul(99).div(100), "the number of transactions cannot exceed 99%");

            if (sender == _swapPair){
                require(amount <= 10000000 * 10 ** 18, "10000000 more than the maximum number of transactions");

                if (_botWall == true) {  
                    require(getRecommend(recipient) != address(0), "bot get out");
                }
            }

            _tokenTransfer(sender, _marketAddress, amount.mul(_marketFee).div(1000));

            _tokenTransfer(sender, _liquidityAddress, amount.mul(_liquidityFee).div(1000));

            _tokenTransfer(sender, _fundAddress, amount.mul(_fundFee).div(1000));

            _bonus(sender, recipient, amount);

            amount = amount.sub(amount.mul(getAllFee()).div(1000));
        }

        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount) internal {
        if (amount > 0) {
            if (recipient != address(0)) {
                _balances[recipient] = _balances[recipient].add(amount);
            }
            emit Transfer(sender, recipient, amount);
        }
    }

    function _bonus(address sender, address recipient, uint256 value) internal {
        address member = sender == _swapPair ? recipient : sender;
        for(uint i=0;i<_recommendFee.length;i++) {
            member = _recommend[member] == address(0) ? address(this) : _recommend[member];
            _tokenTransfer(sender, member, value.mul(_recommendFee[i]).div(1000));
        }
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
    * the total supply.
    *
    * Emits a {Transfer} event with `from` set to the zero address.
    *
    * Requirements
    *
    * - `to` cannot be the zero address.
    */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
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
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        if (value > 0) {
            _totalSupply = _totalSupply.sub(value);
            _balances[account] = _balances[account].sub(value);
            emit Transfer(account, address(0), value);
        }
    }

    function burn(uint256 value) public returns (bool) {
        _burn(msg.sender, value);
        return true;
    }

    /**
    * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
    *
    * This is internal function is equivalent to `approve`, and can be used to
    * e.g. set automatic allowances for certain subsystems, etc.
    *
    * Emits an {Approval} event.
    *
    * Requirements:
    *
    * - `owner` cannot be the zero address.
    * - `spender` cannot be the zero address.
    */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
    * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
    * from the caller's allowance.
    *
    * See {_burn} and {_approve}.
    */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

/**
* @title SimpleToken
* @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
* Note they can later distribute these tokens as they wish using `transfer` and other
* `ERC20` functions.
*/
contract Token is ERC20 {
    using SafeMath for uint256;
    /**
    * @dev Constructor that gives msg.sender all of existing tokens.
    */
    constructor () ERC20Detailed("Queen", "QU", 18) {

        uint256 totalSupply = 21000000000 * (10 ** uint256(decimals()));

        _mint(msg.sender, totalSupply);
    }
}