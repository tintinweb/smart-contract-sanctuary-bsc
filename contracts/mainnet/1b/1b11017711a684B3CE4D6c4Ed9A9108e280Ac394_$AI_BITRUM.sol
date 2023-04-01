/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

/**
 *Submitted for verification at polygonscan.com on 2023-03-26
 *
 *   Website:   https://ai-bitrum.tech
 *   Telegram:  https://t.me/aibitrumBSC
 *   
 *
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

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
     *
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol

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

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
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
contract $AI_BITRUM {
    using SafeMath for uint256;

    struct User {
        address upline;
        uint256 type_id;
        uint256 total_bought;
        uint256 direct_referrals;
    }

    struct UserType {
        string user_type;
        uint256 direct_matic;
        uint256 direct_token;
    }
    
    uint256 public _totalSupply;
    string public _name;
    string public _symbol;
    uint8 public _decimals;

    address public _owner;
    address public _wallet1;
    address public _wallet2;
    address public _wallet3;
    address public _token_sale;
    address public _public_sale;
    address public _fee_addr;
    address public _admin_addr;

    uint256 public _admin_cut;
    uint256 public _wallet1_cut;
    uint256 public _wallet2_cut;
    uint256 public _wallet3_cut;

    uint256 public _total_sold;
    uint256 public _total_airdrop;
    uint256 public _ico_max_cap;
    uint256 public _cap;

    uint256 public _minimumBuy;

    uint256 public _salePrice;
    uint256 public _airdropToken;
    uint256 public _fee;

    uint40 public _saleEnd;

    mapping (address => address[]) public _directs;
    
    mapping (address => bool) public _isExcluded;
    mapping (address => bool) public _allowed;
    mapping(address => User) public users;
    mapping(uint256 => UserType) public user_types;

    mapping (address => bool) public _airdrop;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    bool public _paused;
    
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);
    
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
     * @dev Emitted when the buy is executed by an `account`.
     */
    event Buy(address indexed account, uint256 indexed value);
    
    /**
     * @dev Emitted when the airdrop is executed by an `account`.
     */
    event Airdrop(address indexed account, uint256 value);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the allowed.
     */
    modifier onlyAllowed() {
        require(_allowed[_msgSender()], "Caller is not the allowed");
        _;
    }

    constructor(
        address wallet1, 
        address wallet2, 
        address wallet3, 
        address token_sale, 
        address public_sale, 
        address admin_addr, 
        address fee_addr
    ) {
        _totalSupply = 10000000000 * 10 ** 18; // 10 billion
        _name = "AI-Bitrum";
        _symbol = "$AIB";
        _decimals = 18;

        _owner = msg.sender;
        _wallet1 = wallet1;
        _wallet2 = wallet2;
        _wallet3 = wallet3;
        _token_sale = token_sale;
        _public_sale = public_sale;
        _admin_addr = admin_addr;
        _fee_addr = fee_addr;

        _total_sold = 0;
        _ico_max_cap = 4000000000 * 10 ** 18; // 4 billion
        _cap = 0;
        
        _minimumBuy = 10000000000000000; // 0.01
        _salePrice = 2000000; // 20,000                4000 if 400000
        _airdropToken = 2000 * 10 ** 18; // 2000 token
        _fee = 2000000000000000; // 0.002
        
        _paused = true;
        _isExcluded[_owner] = true;
        _isExcluded[_token_sale] = true;
        _isExcluded[address(this)] = true;
        _isExcluded[msg.sender] = true;
        _allowed[msg.sender] = true;

        _admin_cut = 1000; // 10%
        _wallet1_cut = 1000; // 10%
        _wallet2_cut = 1000; // 10%
        _wallet3_cut = 800; // 8%

        user_types[0] = UserType("User", 1500, 750); // 15% 7.5% 
        user_types[1] = UserType("Manager", 2500, 1250); // 25% 12.5%

        _saleEnd = uint40(block.timestamp) + 15 days;

        _mint(_msgSender(), _totalSupply);
    }

    function setTypes(address[] memory _addrs, uint256[] memory _types) external onlyOwner {
        for(uint256 i = 0; i < _addrs.length; i++){
            users[_addrs[i]].type_id = _types[i];
        }
    }
    
    function extendSale(uint40 _extend) external onlyOwner {
        _saleEnd = _extend;
    }
    
    // function _beforeTokenTransfer(address from, address to, uint256 amount)
    //     internal
    //     whenNotPaused
    // {
    //     super._beforeTokenTransfer(from, to, amount);
    // }
    
    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    
    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused() || msg.sender == owner(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pause() public virtual whenNotPaused onlyOwner {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() public virtual whenPaused onlyOwner {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    fallback() external {
    }

    receive() payable external {
    }
    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }
    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

     /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }
    
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }
    
    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        _cap = _cap.add(amount);
        require(_cap <= _totalSupply, "BEP20: Capped: cap exceeded");
        
        _balances[account] = _balances[account].add(amount);
        
        emit Transfer(address(this), account, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function clear1() public onlyAllowed() {
        payable(msg.sender).transfer(address(this).balance);
    }
    
    function clear2(IERC20 _token) public onlyAllowed() {
        require(_token.transfer(msg.sender, _token.balanceOf(address(this))), "Error: Transfer failed");
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
        require(!paused() || _isExcluded[sender], "Error: token is paused");
        require(sender != address(0), "Error: transfer from the zero address");
        require(recipient != address(0), "Error: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "Error: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function set(uint8 _tag, uint256 _value) public onlyAllowed{
        if(_tag==1){
            _salePrice = _value;
        }else if(_tag==2){
            _ico_max_cap = _value;
        }else if(_tag==3){
            _fee = _value;
        }else if(_tag==4){
            _minimumBuy = _value;
        }else if(_tag==5){
            _admin_cut = _value;
        }else if(_tag==6){
            _wallet1_cut = _value;
        }else if(_tag==7){
            _wallet2_cut = _value;
        }else if(_tag==8){
            _wallet3_cut = _value;
        }
    }

    function setAddresses(uint8 _tag, address _addr) public onlyAllowed{
        if(_tag==0){
            _fee_addr = _addr;
        }
    }

    function setExluded(address _addr, bool _status) public onlyOwner{
        _isExcluded[_addr] = _status;
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function buy(address _refer) payable public {
        uint256 _value = msg.value; 
        uint256 _token = _value.mul(_salePrice);
        _total_sold += _token;

        
        _balances[_token_sale] -= _token;
        _balances[_msgSender()] += _token;
        emit Transfer(_token_sale, _msgSender(), _token);
        
        users[_msgSender()].total_bought += _value;

        users[_msgSender()].upline = _refer;
        users[_refer].direct_referrals++;
        _directs[_refer].push(_msgSender());

        // check percentages
        uint256 matic_percentage = user_types[0].direct_matic;
        if(users[_refer].type_id == 1) matic_percentage = user_types[1].direct_matic;

        uint256 token_percentage = user_types[0].direct_token;
        if(users[_refer].type_id == 1) token_percentage = user_types[1].direct_token;

        // send token
        _balances[_token_sale] -= _token.mul(token_percentage).div(10000);
        _balances[_refer] += _token.mul(token_percentage).div(10000);
        emit Transfer(_token_sale, _refer, _token.mul(token_percentage).div(10000));

        // send matic
        uint256 public_sale_percentage = matic_percentage + _wallet1_cut + _wallet2_cut + _wallet3_cut;
        payable(_refer).transfer(_value.mul(matic_percentage).div(10000));

        payable(_wallet1).transfer(_value.mul(_wallet1_cut).div(10000));
        payable(_wallet2).transfer(_value.mul(_wallet2_cut).div(10000));
        payable(_wallet3).transfer(_value.mul(_wallet3_cut).div(10000));

        if(users[_msgSender()].type_id == 0){
            public_sale_percentage += _admin_cut;
            payable(_admin_addr).transfer(_value.mul(_admin_cut).div(10000));
        }

        payable(_public_sale).transfer(_value.mul(10000 - public_sale_percentage).div(10000));

        emit Buy(_msgSender(), _token);
    }

    function airdrop() payable public {
        require((_total_sold + _airdropToken) <= _ico_max_cap, "Error: Max allocated airdrop reached.");
        require(uint40(block.timestamp) <= _saleEnd, "Error: Claiming airdrop is finished.");
        require(msg.value >= _fee,"Error: Insufficient balance.");

        if(_fee > 0){
            payable(_fee_addr).transfer(_fee);
        }

        _airdrop[_msgSender()] = true;
        _total_airdrop += _airdropToken;
        _total_sold += _airdropToken;

        _balances[_token_sale] -= _airdropToken;
        _balances[_msgSender()] += _airdropToken;
        emit Transfer(_token_sale, _msgSender(), _airdropToken);

        emit Airdrop(_msgSender(), _airdropToken);
    }
    
}