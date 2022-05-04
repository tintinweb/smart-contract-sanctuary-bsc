// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/IBEP20.sol";

/*
* @title Uphoria Protocol
* @author lileddie.eth / Enefte Studio
*/
contract UphoriaProtocol is Initializable, IBEP20 {

    /* V1 Vars */
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => uint256) public mintsForWallet; 
    uint256 public _totalSupply;
    uint256 public _decimals;
    uint256 public INITIAL_SUPPLY;
    uint256 public MAX_PRESALE_PER_WALLET;
    uint256 public MAX_PRESALE_SUPPLY;
    uint256 public LP_TOKENS;
    uint256 public BANK_CAP;
    uint256 public TOKEN_PRICE;
    uint256 public _presaleSold;
    uint256 public presaleOpens;
    uint256 public presaleCloses;
    string private _name;
    string private _symbol;
    bool public sellable;
    address private _owner;
    address private _teamWallet;
    address private _privateSaleWallet;
    address private _bankWallet;
    address private _refWallet;
    /* END V1 Vars */

    /* V2 Vars */
    using SafeMathUpgradeable for uint256;
    uint256 public sellFee;
    uint256 public buyFee;
    address public pairAddress;
    mapping(address => bool) private _isExcludedFromFee;
    /* END V2 Vars */


    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender]+=(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        require(_allowances[msg.sender][spender] >= subtractedValue, "decreased allowance below zero");
        _approve(msg.sender, spender, _allowances[msg.sender][spender]-=subtractedValue);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Cannot approve from the 0 address");
        require(spender != address(0), "Cannot approve to the 0 address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }  


    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(sellable, "Not yet transferrable");
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(sellable, "Not yet transferrable");
        require(_allowances[sender][msg.sender] >= amount, "Transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        uint256 allowedAmount = _allowances[sender][msg.sender] - amount;
        _approve(sender, msg.sender, allowedAmount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        uint256 sellTaxFee = amount.mul(sellFee).div(10000);
        uint256 buyTaxFee = amount.mul(buyFee).div(10000);

        
        bool takeFee = true;
        if (_isExcludedFromFee[sender]) {
            takeFee = false;
        }
        

        if(recipient==pairAddress && !_isExcludedFromFee[sender]){

            //uint256 totalSellerAmount = amount.add(sellTaxFee);
            //require(senderBalance >= totalSellerAmount, "Required amount exceeds balance");
            //_balances[sender] = _balances[sender].sub(totalSellerAmount);
            //_balances[_refWallet] = _balances[_refWallet].add(sellTaxFee);
            //emit Transfer(sender, _refWallet, sellTaxFee);
            //_balances[recipient] = _balances[recipient].add(amount);
            //emit Transfer(sender, recipient, amount);

            require(senderBalance >= amount, "Required amount exceeds balance");
            _balances[sender] = _balances[sender].sub(amount);

            _balances[_refWallet] = _balances[_refWallet].add(sellTaxFee);
            emit Transfer(sender, _refWallet, sellTaxFee);

            
            uint256 totalToSend = amount.sub(sellTaxFee);
            _balances[recipient] = _balances[recipient].add(totalToSend);
            emit Transfer(sender, recipient, totalToSend);

        }else if(sender==pairAddress && !_isExcludedFromFee[recipient]){
            require(senderBalance >= amount, "Required amount exceeds balance");
            _balances[sender] = _balances[sender].sub(amount);

            _balances[_refWallet] = _balances[_refWallet].add(buyTaxFee);
            emit Transfer(sender, _refWallet, buyTaxFee);

            uint256 totalBuyerAmount = amount.sub(buyTaxFee);
            _balances[recipient] = _balances[recipient].add(totalBuyerAmount);
            emit Transfer(sender, recipient, totalBuyerAmount);
        }else{
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
        
    }

    function setTax(uint256 _sellFee, uint256 _buyFee) external onlyOwner {
        sellFee = _sellFee;
        buyFee = _buyFee;
    }

    function setPairAddress(address _pairAddress) external onlyOwner {
        pairAddress = _pairAddress;
    }

    function excludeFromFee(address account) public onlyRef {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyRef {
        _isExcludedFromFee[account] = false;
    }

    /**
    * @notice minting process for the presale
    *
    * @param _amount number of tokens to be minted
    */
    function mint(uint256 _amount) external payable  {
        require(block.timestamp >= presaleOpens && block.timestamp <= presaleCloses, "Purchase: window closed");
        require(_presaleSold + _amount <= MAX_PRESALE_SUPPLY, "Not enough left");
        require(TOKEN_PRICE * _amount <= msg.value * 1000000000000000000, 'missing bnb');
        require(mintsForWallet[msg.sender] + _amount <= MAX_PRESALE_PER_WALLET, "Not enough left");
        _transfer(address(this), msg.sender, _amount);
        mintsForWallet[msg.sender] += _amount;
        _presaleSold += _amount;
    }

    /**
    * @notice set the timestamp of when the presale should begin
    *
    * @param _openTime the unix timestamp the presale opens
    * @param _closeTime the unix timestamp the presale closes
    */
    function setPresaleTimes(uint256 _openTime, uint256 _closeTime) external onlyRef {
        presaleOpens = _openTime;
        presaleCloses = _closeTime;
    }

    function toggleSellable() external onlyRef {
        sellable = !sellable;
    }
    
    /**
    * @notice set the price of the token for presale
    *
    * @param _price the price in wei
    */
    function setTokenPrice(uint256 _price) external onlyRef {
        TOKEN_PRICE = _price;
    }
    
    function setPresalePerWallet(uint256 _amount) external onlyRef {
        MAX_PRESALE_PER_WALLET = _amount;
    }
    
    /**
    * @notice return the total number of tokens that exist.
    */
    function totalSupply() public view virtual returns(uint256){
        return _totalSupply;
    }

    /**
     * @notice Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @notice Throws if called by any account other than the _refWallet.
     */
    modifier onlyRef() {
        require(_refWallet == msg.sender || _owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @notice Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(sellable, "Not yet transferrable");
        require(_balances[account] >= amount, "Burn amount exceeds balance");
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function withdrawBNBRef(uint256 _amount) external onlyRef {
        uint256 balance = address(this).balance;
        require(_amount <= balance, "Withdraw amount exceeds balance");
        payable(_refWallet).transfer(_amount);
        delete balance;
    }

    function withdrawUpRef(uint256 _amount) external {
        uint256 balance = address(this).balance;
        require(_amount <= balance.sub(BANK_CAP), "Withdraw amount exceeds limit");
        _transfer(address(this), _refWallet, _amount);
        delete balance;
    }

    function withdrawUpBank(uint256 _amount) external {
        require(_amount <= BANK_CAP, "Withdraw amount exceeds limit");
        _transfer(address(this), _bankWallet, _amount);
        BANK_CAP -= _amount;
    }

    /**
    * @notice Initialize the contract and it's inherited contracts, data is then stored on the proxy for future use/changes
    *
    */
    function initialize() public initializer {  
        // unused
    }

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
library SafeMathUpgradeable {
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

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/Clones.sol)

pragma solidity ^0.8.0;

interface IBEP20 {

    /**  
     * @dev Returns the total tokens supply  
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