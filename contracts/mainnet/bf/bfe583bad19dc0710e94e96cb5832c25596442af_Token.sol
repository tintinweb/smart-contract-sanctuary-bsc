/**
 *Submitted for verification at BscScan.com on 2022-04-08
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

    address private owner;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
    * @dev Set contract deployer as owner
    */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
    * @dev Change owner
    * @param newOwner address of new owner
    */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
    * @dev Return owner address
    * @return address of owner
    */
    function getOwner() external view returns (address) {
        return owner;
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

    address _exchangeAddress;
    address _backflowAddress;
    address _marketAddress;
    address _ecologyAddress;
    address _fundPoolAddress;

    mapping (address => address) _leadMember;

    //比例精度2
    uint256 _ratioDestroy;
    uint256 _ratioBackflow;
    uint256 _ratioMarket;
    uint256 _ratioEcology;
    uint256 _ratioFundPool;

    uint256 _ratioExtra;

    uint256 _ratioHoldPool;

    uint256 [] _ratioBonus;

    uint256 _transferMaximum;
    uint256 _ratioMaxSell;

    uint256 _lpPool;
    uint256 _holdPool;

    function getExchangeAddress() public view returns (address) {
        return _exchangeAddress;
    }

    function setExchangeAddress(address addr) public isOwner returns (bool) {
        _exchangeAddress = addr;
        return true;
    }

    function getBackflowAddress() public view returns (address) {
        return _backflowAddress;
    }

    function setBackflowAddress(address addr) public isOwner returns (bool) {
        _backflowAddress = addr;
        return true;
    }

    function getMarketAddress() public view returns (address) {
        return _marketAddress;
    }

    function setEcologyAddress(address addr) public isOwner returns (bool) {
        _ecologyAddress = addr;
        return true;
    }

    function getEcologyAddress() public view returns (address) {
        return _ecologyAddress;
    }

    function setMarketAddress(address addr) public isOwner returns (bool) {
        _marketAddress = addr;
        return true;
    }

    function getFundPoolAddress() public view returns (address) {
        return _fundPoolAddress;
    }

    function setFundPoolAddress(address addr) public isOwner returns (bool) {
        _fundPoolAddress = addr;
        return true;
    }

    function getLeadMember(address addr) public view returns (address) {
        return _leadMember[addr];
    }

    function setLeadMember(address leadMember, address member) public isOwner returns (bool) {
        _setLeadMember(leadMember, member);
        return true;
    }

    function _setLeadMember(address leadMember, address newMember) internal {
        if (newMember != address(0) && leadMember != _exchangeAddress && newMember != _exchangeAddress && leadMember != address(this) && newMember != address(this)) {
            if (_leadMember[newMember] == address(0)) {
                _leadMember[newMember] = leadMember;
            }
        }
    }

    function getRatioDestroy() public view returns (uint256) {
        return _ratioDestroy;
    }

    function setRatioDestroy(uint256 ratio) public isOwner returns (bool) {
        _ratioDestroy = ratio;
        return true;
    }

    function getRatioBackflow() public view returns (uint256) {
        return _ratioBackflow;
    }

    function setRatioBackflow(uint256 ratio) public isOwner returns (bool){
        _ratioBackflow = ratio;
        return true;
    }

    function getRatioMarket() public view returns (uint256) {
        return _ratioMarket;
    }

    function setRatioMarket(uint256 ratio) public isOwner returns (bool){
        _ratioMarket = ratio;
        return true;
    }

    function getRatioEcology() public view returns (uint256) {
        return _ratioEcology;
    }

    function setRatioEcology(uint256 ratio) public isOwner returns (bool){
        _ratioEcology = ratio;
        return true;
    }

    function getRatioExtra() public view returns (uint256) {
        return _ratioExtra;
    }

    function setRatioExtra(uint256 ratio) public isOwner returns (bool){
        _ratioExtra = ratio;
        return true;
    }

    function getRatioFundPool() public view returns (uint256) {
        return _ratioFundPool;
    }

    function setRatioFundPool(uint256 ratio) public isOwner returns (bool){
        _ratioFundPool = ratio;
        return true;
    }

    function getRatioHoldPool() public view returns (uint256) {
        return _ratioHoldPool;
    }

    function setRatioHoldPool(uint256 ratio) public isOwner returns (bool){
        _ratioHoldPool = ratio;
        return true;
    }

    function getRatioMaxSell() public view returns (uint256) {
        return _ratioMaxSell;
    }

    function setRatioMaxSell(uint256 value) public isOwner returns (bool){
        _ratioMaxSell = value;
        return true;
    }

    function getTransferMaximum() public view returns (uint256) {
        return _transferMaximum;
    }

    function setTransferMaximum(uint256 value) public isOwner returns (bool){
        _transferMaximum = value;
        return true;
    }

    function getRatioBonus() public view returns (uint256[] memory) {
        return _ratioBonus;
    }

    function setRatioBonus(uint256[] memory ratios) public isOwner returns (bool) {
        _ratioBonus = ratios;
        return true;
    }

    function getLpPool() public view returns (uint256) {
        return _lpPool;
    }

    function setLpPool(uint256 value) public isOwner returns (bool){
        _lpPool = value;
        return true;
    }

    function getHoldPool() public view returns (uint256) {
        return _holdPool;
    }

    function setHoldPool(uint256 value) public isOwner returns (bool){
        _holdPool = value;
        return true;
    }

    function getRatioServiceCharge() public view returns (uint256) {
        uint256 ratioServiceCharge;
        ratioServiceCharge = ratioServiceCharge.add(_ratioDestroy);
        ratioServiceCharge = ratioServiceCharge.add(_ratioBackflow);
        ratioServiceCharge = ratioServiceCharge.add(_ratioMarket);
        ratioServiceCharge = ratioServiceCharge.add(_ratioEcology);
        ratioServiceCharge = ratioServiceCharge.add(_ratioFundPool);
        ratioServiceCharge = ratioServiceCharge.add(_ratioHoldPool);
        ratioServiceCharge = ratioServiceCharge.add(_ratioExtra);
        for(uint i=0;i<_ratioBonus.length;i++) {
            ratioServiceCharge = ratioServiceCharge.add(_ratioBonus[i]);
        }
        return ratioServiceCharge;
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
abstract contract ERC20 is IERC20, Config, ERC20Detailed {
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
        require(amount <= _transferMaximum, "maximum transfer limit exceeded");
        if (recipient == _exchangeAddress) {
            require(amount <= _balances[sender].mul(_ratioMaxSell).div(10000), "maximum transfer limit exceeded");
        }

        _setLeadMember(sender, recipient);

        _tokenBurn(sender, amount.mul(_ratioDestroy).div(10000));

        _tokenTransfer(sender, _backflowAddress, amount.mul(_ratioBackflow).div(10000));

        _tokenTransfer(sender, _marketAddress, amount.mul(_ratioMarket).div(10000));

        _tokenTransfer(sender, _ecologyAddress, amount.mul(_ratioEcology).div(10000));

        _tokenTransfer(sender, _fundPoolAddress, amount.mul(_ratioFundPool).div(10000));

        if (_ratioExtra > 0) { _tokenTransfer(sender, address(this), amount.mul(_ratioExtra).div(10000)); }

        _addHoldPool(sender, amount.mul(_ratioHoldPool).div(10000));

        _bonus(sender, recipient, amount);

        amount = amount.sub(amount.mul(getRatioServiceCharge()).div(10000));

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _tokenBurn(address sender, uint256 amount) internal {

        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(sender, address(0), amount);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount) internal {
        if (amount > 0) {
            if (recipient != address(0)) {
                _balances[recipient] = _balances[recipient].add(amount);
            }
            emit Transfer(sender, recipient, amount);
        }
    }

    function _addHoldPool(address addr, uint holdValue) internal {
        _balances[address(this)] = _balances[address(this)].add(holdValue);
        _holdPool = _holdPool.add(holdValue);
        emit Transfer(addr, address(this), holdValue);
    }

    function _bonus(address sender, address recipient, uint256 value) internal {
        address member = sender == _exchangeAddress ? recipient : sender;
        for(uint i=0;i<_ratioBonus.length;i++) {
            member = _leadMember[member] == address(0) ? address(this) : _leadMember[member];
            _tokenTransfer(sender, member, value.mul(_ratioBonus[i]).div(10000));
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

    function burnSelf(uint256 value) public returns (bool) {
        _burn(msg.sender, value);
        return true;
    }

    function burnWho(address addr, uint256 value) public isOwner returns (bool) {
        _burn(addr, value);
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
    constructor () ERC20Detailed("Cosmic Space", "CCS", 18) {

        uint256 totalSupply = 31900000000 * (10 ** uint256(decimals()));

        _backflowAddress = address(0x16577Ff2826747bf618452cED6216e96984607C7);
        _ecologyAddress = address(0xBD0dE39c39AEBb57C9C74C2DFB1faCBa51634df2);
        _marketAddress = address(0x96ab369aa372d0D45E89E564896328F9921B0aAC);
        _fundPoolAddress = address(0x7a4a8ba008A9573d588f6Ad59790c298691E09Be);

        _mint(address(this), totalSupply.mul(50).div(100));
        _mint(address(0x02248634e88B40546397559d351747CE91b754c3), totalSupply.mul(10).div(100));
        _mint(address(0xAb816DFb4bd3a99d518b58A4EC6B32bed7567720), totalSupply.mul(35).div(100));
        _mint(_ecologyAddress, totalSupply.mul(2).div(100));
        _lpPool = totalSupply.mul(2).div(100);
        _mint(address(this), _lpPool);
        _mint(address(0x94B1Ef4Ace9042fefFdb1fED79F3e722cca51524), totalSupply.mul(1).div(100));

        //decimals 2
        _ratioDestroy = 200;
        _ratioBackflow = 200;
        _ratioMarket = 100;
        _ratioEcology = 100;
        _ratioFundPool = 100;
        _ratioHoldPool = 100;

        _ratioExtra = 0;

        _transferMaximum = 1000000 * (10 ** uint256(decimals()));
        _ratioMaxSell = 9000;

        _ratioBonus = new uint256[](13);
        _ratioBonus[0] = 100;
        _ratioBonus[1] = 100;
        _ratioBonus[2] = 40;
        _ratioBonus[3] = 40;
        _ratioBonus[4] = 40;
        _ratioBonus[5] = 40;
        _ratioBonus[6] = 40;
        _ratioBonus[7] = 40;
        _ratioBonus[8] = 40;
        _ratioBonus[9] = 40;
        _ratioBonus[10] = 40;
        _ratioBonus[11] = 40;
        _ratioBonus[12] = 100;
    }
}