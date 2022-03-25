/**
 *Submitted for verification at BscScan.com on 2022-03-25
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
    address _fundPoolAddress;

    mapping (address => address) _leadMember; //推荐人
    address [] _whiteList;  //白名单

    //奖励层数
    uint256 _bonusLevel;

    //比例精度2
    uint256 _ratioDestroy; //销毁
    uint256 _ratioBackflow;  //回流
    uint256 _ratioMarket;  //营销
    uint256 _ratioFundPool;  //基金池
    uint256 _ratioWhitePool;  //白名单池
    uint256 _ratioHoldPool; //持币分红池
    mapping (uint256 => uint256) _ratioBonus; //奖金比例

    uint256 _whitePool;  //白名单分红池累计
    uint256 _holdPool; //持币分红池累计

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

    function _setLeadMember(address leadMember, address newMember) internal returns (bool) {
        if (newMember != address(0) && leadMember != _exchangeAddress && newMember != _exchangeAddress) {
            if (_leadMember[newMember] == address(0)) {
                _leadMember[newMember] = leadMember;
            }
        }
        return true;
    }

    function getWhiteList() public view returns (address[] memory) {
        return _whiteList;
    }

    function addWhiteList(address addr) public isOwner returns (bool) {
        _whiteList.push(addr);
        return true;
    }

    function removeWhiteList(uint256 index) public isOwner returns (bool) {
        if (index >= _whiteList.length) return false;

        for (uint i = index; i < _whiteList.length-1; i++) {
            _whiteList[i] = _whiteList[i+1];
        }

        delete _whiteList[_whiteList.length-1];

        return true;
    }

    function getRatioDestroy() public view returns (uint256) {
        return _ratioDestroy;
    }

    function setRatioDestroy(uint256 ratio) public isOwner returns (bool){
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

    function getRatioFundPool() public view returns (uint256) {
        return _ratioFundPool;
    }

    function setRatioFundPool(uint256 ratio) public isOwner returns (bool){
        _ratioFundPool = ratio;
        return true;
    }

    function getRatioWhitePool() public view returns (uint256) {
        return _ratioWhitePool;
    }

    function setRatioWhitePool(uint256 ratio) public isOwner returns (bool){
        _ratioWhitePool = ratio;
        return true;
    }

    function getRatioHoldPool() public view returns (uint256) {
        return _ratioHoldPool;
    }

    function setRatioHoldPool(uint256 ratio) public isOwner returns (bool){
        _ratioHoldPool = ratio;
        return true;
    }

    function getRatioBonus() public view returns (uint256[] memory) {
        uint256 [] memory ratioBonus = new uint256[](_bonusLevel);

        for(uint i=0;i<_bonusLevel;i++) {
            ratioBonus[i] = _ratioBonus[i];
        }
        return ratioBonus;
    }

    function setRatioBonus(uint256[] memory ratios) public isOwner returns (bool) {
        for(uint i=0;i<ratios.length;i++) {
            _ratioBonus[i] = ratios[i];
        }
        return true;
    }

    function getWhitePool() public view returns (uint256) {
        return _whitePool;
    }

    function setWhitePool(uint256 value) public isOwner returns (bool){
        _whitePool = value;
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
        ratioServiceCharge = ratioServiceCharge.add(_ratioFundPool);
        ratioServiceCharge = ratioServiceCharge.add(_ratioWhitePool);
        ratioServiceCharge = ratioServiceCharge.add(_ratioHoldPool);
        for(uint i=0;i<_bonusLevel;i++) {
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
contract ERC20 is IERC20, Config {
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

            _setLeadMember(sender, recipient);

            //销毁
            _tokenBurn(sender, amount.mul(_ratioDestroy).div(10000));

            //回流
            _tokenTransfer(sender, _backflowAddress, amount.mul(_ratioBackflow).div(10000));

            //营销
            _tokenTransfer(sender, _marketAddress, amount.mul(_ratioMarket).div(10000));

            //基金池
            _tokenTransfer(sender, _fundPoolAddress, amount.mul(_ratioFundPool).div(10000));

            //白名单分红池&持币分红池
            _addWhitePoolHoldPool(sender, amount.mul(_ratioWhitePool).div(10000), amount.mul(_ratioHoldPool).div(10000));

            //奖金
            _bonus(sender, amount);

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

    function _addWhitePoolHoldPool(address addr, uint256 whiteValue, uint holdValue) internal {
        _balances[address(this)] = _balances[address(this)].add(whiteValue.add(holdValue));

        _whitePool = _whitePool.add(whiteValue);
        emit Transfer(addr, address(this), whiteValue);

        _holdPool = _holdPool.add(holdValue);
        emit Transfer(addr, address(this), holdValue);
    }

    function _bonus(address addr, uint256 value) internal {
        address member = addr;
        for(uint i=0;i<_bonusLevel;i++) {
            member = _leadMember[member];
            if (member == address(0)) {
                break;
            }
            else {
                _balances[member] = _balances[member].add(value.mul(_ratioBonus[i]).div(10000));
                emit Transfer(addr, member, value.mul(_ratioBonus[i]).div(10000));
            }
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
contract Token is ERC20, ERC20Detailed {

    /**
    * @dev Constructor that gives msg.sender all of existing tokens.
    */
    constructor () ERC20Detailed("Css Token", "CSS", 18) {
        _mint(msg.sender, 31900000000 * (10 ** uint256(decimals())));

        _exchangeAddress = msg.sender;
        _backflowAddress = msg.sender;
        _marketAddress = msg.sender;
        _fundPoolAddress = msg.sender;

        _bonusLevel = 10;

        //精度2
        _ratioDestroy = 200;
        _ratioBackflow = 200;
        _ratioMarket = 100;
        _ratioFundPool = 100;
        _ratioWhitePool = 200;
        _ratioHoldPool = 100;
        _ratioBonus[0] = 100; //1代
        _ratioBonus[1] = 100; //2代
        _ratioBonus[2] = 50; //3代
        _ratioBonus[3] = 50; //4代
        _ratioBonus[4] = 50; //5代
        _ratioBonus[5] = 50; //6代
        _ratioBonus[6] = 50; //7代
        _ratioBonus[7] = 50; //8代
        _ratioBonus[8] = 50; //9代
        _ratioBonus[9] = 50; //10代

        _leadMember[0x2752d83440F741C9315952Ae27C969326D5387F9] = 0x81CD07D8C2F464A5Ca2eD9Ff74C8c5cADC7ad4cA;
        _leadMember[0x81CD07D8C2F464A5Ca2eD9Ff74C8c5cADC7ad4cA] = 0x950A439d8bc58C6D3d7129cd03976D3240CBeB91;
        _leadMember[0x950A439d8bc58C6D3d7129cd03976D3240CBeB91] = 0x53dFB83c90Ab15B1a1718D862F4Dd2C42E011dA4;
        _leadMember[0x53dFB83c90Ab15B1a1718D862F4Dd2C42E011dA4] = 0xCa290D8111C4bd74D8DaE8Ba1aAC8E762b9e0B5A;
        _leadMember[0xCa290D8111C4bd74D8DaE8Ba1aAC8E762b9e0B5A] = 0xCC25147b56607A14CEBF7775ecc04BE3F365df52;
        _leadMember[0xCC25147b56607A14CEBF7775ecc04BE3F365df52] = 0x44DdA226fE20D5b420b7bd29C7b0125F1dD28818;
        _leadMember[0x44DdA226fE20D5b420b7bd29C7b0125F1dD28818] = 0xF0d265887107B1603843231f477835bD091d057A;
        _leadMember[0xF0d265887107B1603843231f477835bD091d057A] = 0x97AD29d6E2877cd4C68eA6303EBc288345209105;
        _leadMember[0x97AD29d6E2877cd4C68eA6303EBc288345209105] = 0x0c0fcE7D3531ca618289C233D3999D0E9d7Bc5a2;
        _leadMember[0x0c0fcE7D3531ca618289C233D3999D0E9d7Bc5a2] = 0x304C609492A94BF272b5ee7a7d98B2c99Dbab047;
    }
}