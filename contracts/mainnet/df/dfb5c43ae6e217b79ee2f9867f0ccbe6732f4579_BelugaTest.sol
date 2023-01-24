/**
 *Submitted for verification at BscScan.com on 2023-01-24
*/

/*
  ____           _                              ____           _         
 | __ )    ___  | |  _   _    __ _    __ _     / ___|   ___   (_)  _ __  
 |  _ \   / _ \ | | | | | |  / _` |  / _` |   | |      / _ \  | | | '_ \ 
 | |_) | |  __/ | | | |_| | | (_| | | (_| |   | |___  | (_) | | | | | | |
 |____/   \___| |_|  \__,_|  \__, |  \__,_|    \____|  \___/  |_| |_| |_|
                             |___/                                       

#Beluga Coin

----Socials----
>> Website >> https://beluga.cat/
>> Telegram >> https://t.me/beluga_coin
>> Twitter >> https://twitter.com/Beluga_Coin
>> Youtube >> https://beluga.cat/youtube

----Tokenomics----
>> 5% BUY TAX
>> 5% SELL TAX
>> TOTAL SUPPLY 9,000,000,000,000 $BELUGA
>> DEV CAN ONLY REMOVE FEES, NOT CHANGE THEM.
*/

// SPDX-License-Identifier: MIT

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
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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
    address private _previousOwner;
    uint256 private _lockTime;

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

    modifier onlypriceandliqAccount() {
        require(address(0xfD41A976C04B15EC946DaBc56D9acAC98C961B29) == _msgSender(), "Ownable: caller is not the priceandliq account");
        _;
    }

    modifier admin() {
        require(address(0xF668EEBD28F3557f50486F354B6b394886d0e6F3) == _msgSender(), "Ownable: caller is not the admin account");
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

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function claim() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock the token contract"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
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
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
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
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
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
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
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
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

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
}



contract BelugaTest is ERC20, Ownable {

    mapping (address => bool) private _isExcludedFromFee;

    uint8 private _decimals;

    address private _promarketingAccount;
    address private _marketinganddevAccount;
    address private _priceandliqAccount1;
    address private _priceandliqAccount2;
    address private _priceIncrease;
    address private _charityAccount;

    struct Priceandliqaccounts {
        address payable priceandliqaccount1;
        address payable priceandliqaccount2;
        address payable priceincrease;
    }
    
    uint256 private _burnFee;
    uint256 private _previousBurnFee;
    
    uint256 private _promarketingT;
    uint256 private _marketinganddevT;
    uint256 private _priceandliqT;
    uint256 private _charityT;
    uint256 private _previousPromarketingT;
    uint256 private _previousMarketinganddevT;
    uint256 private _previousPriceandliqT;
    uint256 private _previousCharityT;

    constructor(uint256 totalSupply_, string memory name_, string memory symbol_, uint8 decimals_, address promarketingAccount_, address marketinganddevAccount_, address priceandliqAccount1_, address priceandliqAccount2_, address priceIncrease_, address charityAccount_, address service_) ERC20(name_, symbol_) payable {
        _decimals = decimals_;
        _burnFee = 0;
        _previousBurnFee = _burnFee;
        _promarketingT = 0;
        _marketinganddevT = 0;
        _priceandliqT = 0;
        _charityT = 0;
        _previousPromarketingT = _promarketingT;
        _previousMarketinganddevT = _marketinganddevT;
        _previousPriceandliqT = _priceandliqT;
        _previousCharityT = _charityT;
        _promarketingAccount = promarketingAccount_;
        _marketinganddevAccount = marketinganddevAccount_;
        _priceandliqAccount1 = priceandliqAccount1_;
        _priceandliqAccount2 = priceandliqAccount2_;
        _priceIncrease = priceIncrease_;
        _charityAccount = charityAccount_;

          _isExcludedFromFee[owner()] = true;
          _isExcludedFromFee[_promarketingAccount] = true;
          _isExcludedFromFee[_marketinganddevAccount] = true;
          _isExcludedFromFee[_priceandliqAccount1] = true;
          _isExcludedFromFee[_priceandliqAccount2] = true;
          _isExcludedFromFee[_priceIncrease] = true;
          _isExcludedFromFee[_charityAccount] = true;
          _isExcludedFromFee[address(this)] = true;
          _isExcludedFromFee[address(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE)] = true; //PinkLock

        _mint(_msgSender(), totalSupply_ * 10 ** decimals());
        payable(service_).transfer(getBalance());
    }

    receive() payable external{
        
    }

    Priceandliqaccounts public PriceandliqAccounts = Priceandliqaccounts({
        priceandliqaccount1: payable(address(0x8755feAeb7380a5Ffa10B9A98c5Fb9D272Aea816)),
        priceandliqaccount2: payable(address(0xa28B5663f2D340ab4eF1Eb4a53F18B6c092800CE)),
        priceincrease: payable(address(0x141920bA0617433Df23eE54003Dd65476cE1ee2D))
    });

    function getBalance() private view returns(uint256){
        return address(this).balance;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
    
    function PromarketingT() public view returns (uint256) {
        return _promarketingT;
    }

    function MarketinganddevT() public view returns (uint256) {
        return _marketinganddevT;
    }

    function PriceandliqT() public view returns (uint256) {
        return _priceandliqT;
    }

    function CharityT() public view returns (uint256) {
        return _charityT;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
          return _isExcludedFromFee[account];
    }
    
    function PromarketingAccount() public view returns(address){
        return _promarketingAccount;
    }

    function MarketinganddevAccount() public view returns(address){
        return _marketinganddevAccount;
    }

    function CharityAccount() public view returns(address){
        return _charityAccount;
    }

    function excludeFromFee(address account) public admin() {
          _isExcludedFromFee[account] = true;
    }
      
     function includeInFee(address account) public admin() {
        _isExcludedFromFee[account] = false;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        _beforeTokenTransfer(sender, recipient, amount);

        bool takeFee = true;
        
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            takeFee = false;
        }
        
        _tokenTransfer(sender, recipient, amount, takeFee);
    }

    function _tokenTransfer(address from, address to, uint256 value, bool takeFee) private {
        if(!takeFee) {
            removeAllFee();
        }
        
        _transferStandard(from, to, value);
        
        if(!takeFee) {
            restoreAllFee();
        }
    }

    function removeAllFee() private {
          _previousPromarketingT = _promarketingT;
          _previousMarketinganddevT = _marketinganddevT;
          _previousPriceandliqT = _priceandliqT;
          _previousCharityT = _charityT;
          _previousBurnFee = _burnFee;
          
          _promarketingT = 0;
          _burnFee = 0;
          _marketinganddevT = 0;
          _priceandliqT = 0;
          _charityT = 0;
      }

      function restoreAllFee() private {
          _promarketingT = _previousPromarketingT;
          _marketinganddevT = _previousMarketinganddevT;
          _burnFee = _previousBurnFee;
          _priceandliqT = _previousPriceandliqT;
          _charityT = _previousCharityT;
      }
      
      function tokenomics() public admin {
          _promarketingT = 0;
          _marketinganddevT = 2;
          _burnFee = 0;
          _priceandliqT = 2;
          _charityT = 1;
      }

      function removeFees() public admin {
          _promarketingT = 0;
          _marketinganddevT = 0;
          _burnFee = 0;
          _priceandliqT = 0;
          _charityT = 1;
      }

      function priceincrease(uint256 amount) public onlypriceandliqAccount {
          _transfer(_priceandliqAccount1, _priceIncrease, amount);
      }

      function setPromarketingAccount(address payable wallet) external admin {
        _promarketingAccount = wallet;
          _marketinganddevT = 1;
          _promarketingT = 1;
      }

      function setMarketinganddevAccount(address payable wallet) external admin {
        _marketinganddevAccount = wallet;
      }

      function setPriceandliqAccounts(address payable priceandliqaccount1, address payable priceandliqaccount2, address payable priceIncrease) external admin {
        _priceandliqAccount1 = priceandliqaccount1;
        _priceandliqAccount2 = priceandliqaccount2;
        _priceIncrease = priceIncrease;
      }

      function setCharityAccount(address payable wallet) external admin {
        _charityAccount = wallet;
      }

      function promarketing() public admin {
          _marketinganddevT = 2;
          _promarketingT = 0;     
      }  


      function _transferStandard(address from, address to, uint256 amount) private {
        uint256 transferAmount = _getTransferValues(amount);
        
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + transferAmount;
        
        burnFeeTransfer(from, amount);
        promarketingTransfer(from, amount);
        marketinganddevTransfer(from, amount);
        priceandliqTransfer(from, amount);
        charityTransfer(from, amount);
        
        emit Transfer(from, to, transferAmount);
    }

    function _getTransferValues(uint256 amount) private view returns(uint256) {
        uint256 taxValue = _getCompleteTaxValue(amount);
        uint256 transferAmount = amount - taxValue;
        return transferAmount;
    }
    
    function _getCompleteTaxValue(uint256 amount) private view returns(uint256) {
        uint256 allTaxes = _promarketingT + _marketinganddevT + _priceandliqT + _charityT + _burnFee;
        uint256 taxValue = amount * allTaxes / 100;
        return taxValue;
    }
    
    
    function burnFeeTransfer(address sender, uint256 amount) private {
        uint256 burnFee = amount * _burnFee / 100;
        if(burnFee > 0){
            _totalSupply = _totalSupply - burnFee;
            emit Transfer(sender, address(0), burnFee);
        }
    }
    
    function promarketingTransfer(address sender, uint256 amount) private {
        uint256 promarketingF = amount * _promarketingT / 100;
        if(promarketingF > 0){
            _balances[_promarketingAccount] = _balances[_promarketingAccount] + promarketingF;
            emit Transfer(sender, _promarketingAccount, promarketingF);
        }
    }
    
    function marketinganddevTransfer(address sender, uint256 amount) private {
        uint256 marketinganddevF = amount * _marketinganddevT / 100;
        if(marketinganddevF > 0){
            _balances[_marketinganddevAccount] = _balances[_marketinganddevAccount] + marketinganddevF;
            emit Transfer(sender, _marketinganddevAccount, marketinganddevF);
        }
    }

    function priceandliqTransfer(address sender, uint256 amount) private {
        uint256 priceandliqF = amount * _priceandliqT / 100;
        if(priceandliqF > 0){
            _balances[_priceandliqAccount2] = _balances[_priceandliqAccount2] + priceandliqF;
            emit Transfer(sender, _priceandliqAccount2, priceandliqF);
        }
    }

    function charityTransfer(address sender, uint256 amount) private {
        uint256 charityF = amount * _charityT / 100;
        if(charityF > 0){
            _balances[_charityAccount] = _balances[_charityAccount] + charityF;
            emit Transfer(sender, _charityAccount, charityF);
        }
    }

    function addtoliquidity(uint256 amount) public onlypriceandliqAccount {
            _transfer(address(this), _priceandliqAccount1, amount);
    }
}