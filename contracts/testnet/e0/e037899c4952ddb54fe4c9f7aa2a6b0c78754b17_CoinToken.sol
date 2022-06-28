/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

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
        return msg.data;
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
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
        require(owner() == _msgSender() || owner() == tx.origin, "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

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
        require(!paused(), "Pausable: paused");
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
    function _pause() internal virtual whenNotPaused {
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
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

/**
* @dev Main contract with liquidity provided by orders, mechanism that allows users 
*  sell and buy tokens like a exchange, transfer functions with taxes that can be configured.
*/
contract CoinToken is ERC20, Ownable, Pausable {

    // CONFIG START
    
    IERC20 public tradeToken;
    uint256 private initialSupply;
   
    uint256 private denominator = 100;
    uint8 private precision = 4;
    
    uint256 private devTaxBuy;
    uint256 private marketingTaxBuy;
    uint256 private liquidityTaxBuy;
    uint256 private charityTaxBuy;
    
    uint256 private devTaxSell;
    uint256 private marketingTaxSell;
    uint256 private liquidityTaxSell;
    uint256 private charityTaxSell;
    
    address private devTaxWallet;
    address private marketingTaxWallet;
    address private liquidityTaxWallet;
    address private charityTaxWallet;
    
    mapping (address => bool) private blacklist;
    mapping (address => bool) private excludeList;
    // CONFIG END

    /**
     * @dev Variables that store information of liquidity based on orders.
     * 
     */
    mapping (string => uint256) private buyTaxes;
    mapping (string => uint256) private sellTaxes;
    mapping (string => address) private taxWallets;
    orderData[] public orderBuy;
    orderData[] public orderSell;
    uint256 public marketQuotation;
    bool public taxStatus = true;

    struct orderData{
        uint256 timestamp;
        uint256 tokenPrice;
        uint256 quantity;
        uint256 filledQuantity;
        uint256 filledAmount;
        uint256 quotation;
        uint256 tax;
        address owner;
        bool fullFilled;
    }
    
    constructor()ERC20("Tokename", "TKN")
    {
        tradeToken = IERC20(0x7FF13360a12c64286a359E95ec79368B21571E67);
        initialSupply =  1000000 * (10**18);
        address owner = 0xf73eaEEAd16Ba9689085ff744a7db099deE37131;
        _setOwner(owner);
        exclude(owner);
        exclude(address(this));
        _mint(owner, initialSupply);
        taxWallets["liquidity"] = 0x07eaC1E864F9b3E7cadeF0dEeC3dAd0cF4c641e0;
        taxWallets["dev"] = 0x10365e8f2B40cA8bA15fF150Bf7A33bA1061173B;
        taxWallets["marketing"] = 0xeaF4b5ceD6Eab06506DafDeC6F94Ca65Ffe23AfF;
        taxWallets["charity"] = 0xf8EC2dD5aAb3b9da62128823F8bFf64F134719Bb;
        taxWallets["repurchase"] = 0xAF118fd1402e40f28B1aEfb5E7Ac5f173DDA02D5;
        sellTaxes["liquidity"] = 4;
        sellTaxes["dev"] = 2;
        sellTaxes["marketing"] = 1;
        sellTaxes["charity"] = 3;
        sellTaxes["repurchase"] = 5;
        buyTaxes["liquidity"] = 4;
        buyTaxes["dev"] = 2;
        buyTaxes["marketing"] = 1;
        buyTaxes["charity"] = 3;
        buyTaxes["repurchase"] = 5;
    }
    
    uint256 private marketingTokens;
    uint256 private devTokens;
    uint256 private liquidityTokens;
    uint256 private charityTokens;

    /**
     * @dev Create a order to buy main token arranged in descending order,
     *  send trade token to liquidity wallet, synchronize orders and liquidate them.
     */
    function sendBuyOrder(uint256 tokenPrice,uint256 quantity) public returns(bool){
        tradeToken.transferFrom(msg.sender,taxWallets["liquidity"],tokenPrice*quantity*10**(decimals()-precision*2));
        orderBuy.push(orderData(0,0,0,0,0,0,0,address(0),false));
        uint256 insertIndex = orderBuy.length - 1;
        for(uint256 i = 0; i < orderBuy.length - 1; i++){
            if(tokenPrice > orderBuy[i].tokenPrice){
                insertIndex = i;
                break;
            }
        }
        if(insertIndex == orderBuy.length - 1){
            orderBuy[insertIndex] = orderData(block.timestamp,tokenPrice,quantity,0,0,tokenPrice/quantity,0,msg.sender,false);
        }else{
            orderData[] memory tempBuy = orderBuy;
            for(uint256 i = insertIndex+1; i < orderBuy.length; i++){
                orderBuy[i] = tempBuy[i-1];
            }
            orderBuy[insertIndex] = orderData(block.timestamp,tokenPrice,quantity,0,0,tokenPrice/quantity,0,msg.sender,false);
        }
        synchronizeOrders();
        return true;
    }

    /**
     * @dev Create a order to buy main token via market price,arranged in descending order,
     *  send trade token to liquidity wallet, synchronize orders and liquidate them.
     */
    function sendBuyMarket(uint256 amount) public returns(bool){
        return sendBuyOrder(marketQuotation,amount);
    }

    /**
     * @dev Create a order to sell main token arranged in ascending order,
     *  send main token to liquidity wallet, synchronize orders and liquidate them.
     */
    function sendSellOrder(uint256 tokenPrice,uint256 quantity) public returns(bool){
        super._transfer(msg.sender,taxWallets["liquidity"],quantity*10**(decimals()-precision));
        orderSell.push(orderData(0,0,0,0,0,0,0,address(0),false));
        uint256 insertIndex = orderSell.length - 1;
        for(uint256 i = 0; i < orderSell.length - 1; i++){
            if(tokenPrice < orderSell[i].tokenPrice){
                insertIndex = i;
                break;
            }
        }
        if(insertIndex == orderSell.length - 1){
            orderSell[insertIndex] = orderData(block.timestamp,tokenPrice,quantity,0,0,tokenPrice/quantity,0,msg.sender,false);
        }else{
            orderData[] memory tempSell = orderSell;
            for(uint256 i = insertIndex+1; i < orderSell.length; i++){
                orderSell[i] = tempSell[i-1];
            }
            orderSell[insertIndex] = orderData(block.timestamp,tokenPrice,quantity,0,0,tokenPrice/quantity,0,msg.sender,false);
        }
        synchronizeOrders();
        return true;
    }

    /**
     * @dev Create a order to sell main token via market price arranged in ascending order,
     *  send main token to liquidity wallet, synchronize orders and liquidate them.
     */
    function sendSellMarket(uint256 amount) public returns(bool){
        return sendSellOrder(marketQuotation,amount);
    }

    /**
     * @dev Liquidate all orders, send bought and sold tokens to new owners wallet,
     *  send taxes to repurchase wallet, update orders data.
     */
    function synchronizeOrders() public{
        for(uint256 i = 0; i < orderBuy.length; i++){
            if(orderBuy[i].fullFilled == false){
                for(uint256 j = 0; j < orderSell.length; j++){
                    if(orderBuy[i].tokenPrice >= orderSell[j].tokenPrice){
                        uint256 remainingQuantityBuy = 0;
                        uint256 remainingQuantitySell = 0;
                        if(orderBuy[i].quantity > orderBuy[i].filledQuantity){
                            remainingQuantityBuy = orderBuy[i].quantity - orderBuy[i].filledQuantity;
                        }else{
                            orderBuy[i].fullFilled = true;
                            break;
                        }
                        if(orderSell[j].quantity > orderSell[j].filledQuantity){
                            remainingQuantitySell = orderSell[j].quantity - orderSell[j].filledQuantity;
                        }else{
                            orderSell[j].fullFilled = true;
                        }
                        if(orderSell[j].fullFilled == false){
                            if(remainingQuantityBuy > remainingQuantitySell){
                                _payOrder(remainingQuantitySell,
                                remainingQuantitySell*orderSell[j].tokenPrice*10**(decimals()-precision*2),
                                remainingQuantitySell*10**(decimals()-precision),i,j);
                            }else{
                                _payOrder(remainingQuantityBuy,
                                remainingQuantityBuy*orderSell[j].tokenPrice*10**(decimals()-precision*2),
                                remainingQuantityBuy*10**(decimals()-precision),i,j);
                            }
                        }
                    }
                }
            }
        }
    }
    /**
     * @dev Liquidate a buy and a sell order,
     *  send taxes to repurchase wallet, update orders data.
     */
    function _payOrder(uint256 orderQuantity, uint256 orderTradeValue,uint256 orderTokenValue,uint256 ibuy,uint256 isell) private{
        uint256 boughtTax = 0;
        uint256 sellTax = 0;
        if(!isExcluded(msg.sender)) {
            boughtTax = (orderTokenValue / denominator) * buyTaxes["repurchase"];
            sellTax = (orderTradeValue / denominator) * sellTaxes["repurchase"];
        }
        orderBuy[ibuy].filledAmount += orderTokenValue;
        orderBuy[ibuy].filledQuantity += orderQuantity;
        orderBuy[ibuy].tax += boughtTax;
        super._transfer(taxWallets["liquidity"],orderBuy[ibuy].owner,orderTokenValue-boughtTax);
        orderSell[isell].filledAmount += orderTradeValue;
        orderSell[isell].filledQuantity += orderQuantity;
        orderSell[isell].tax += sellTax;
        tradeToken.transferFrom(taxWallets["liquidity"],orderSell[isell].owner,orderTradeValue-sellTax);
        marketQuotation = orderSell[isell].tokenPrice;
        if(!isExcluded(msg.sender)) {
            super._transfer(orderBuy[ibuy].owner,taxWallets["repurchase"],boughtTax);
            tradeToken.transferFrom(orderSell[isell].owner,taxWallets["repurchase"],sellTax);
        }
        if(orderBuy[ibuy].filledQuantity >= orderBuy[ibuy].quantity){
            orderBuy[ibuy].fullFilled = true;
        }
        if(orderSell[isell].filledQuantity >= orderSell[isell].quantity){
            orderSell[isell].fullFilled = true;
        }
    }
    /**
     * @dev Define precision factor, variable use to add float point in a int number,
     *  when send a order to buy or sell token the floating point is represent by 
     *  (orderValue * 10 ** precision)
     */
    function setPrecisionFactor(uint8 precisionFactor) public{
        precision = precisionFactor;
    }
    
    /**
     * @dev Calculates the tax, transfer it to the contract. If the user is selling, and the swap threshold is met, it executes the tax.
     */
    function handleTax(address from, address to, uint256 amount) private returns (uint256) {
        if(!isExcluded(from) && !isExcluded(to)) {
            uint256 tax;
            uint256 baseUnit = amount / denominator;
            
            uint256 taxMarketing = baseUnit * buyTaxes["marketing"];
            uint256 taxDev = baseUnit * buyTaxes["dev"];
            uint256 taxLiquidity = baseUnit * buyTaxes["liquidity"];
            uint256 taxCharity = baseUnit * buyTaxes["charity"];

            tax += taxMarketing;
            tax += taxDev;
            tax += taxLiquidity;
            tax += taxCharity;

            super._transfer(msg.sender,taxWallets["marketing"],taxMarketing);
            super._transfer(msg.sender,taxWallets["dev"],taxDev);
            super._transfer(msg.sender,taxWallets["liquidity"],taxLiquidity);
            super._transfer(msg.sender,taxWallets["charity"],taxCharity);
            amount -= tax;
        }
        
        return amount;
    }
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override virtual {
        require(!paused(), "CoinToken: token transfer while paused");
        require(!isBlacklisted(msg.sender), "CoinToken: sender blacklisted");
        require(!isBlacklisted(recipient), "CoinToken: recipient blacklisted");
        require(!isBlacklisted(tx.origin), "CoinToken: sender blacklisted");
        
        if(taxStatus) {
            amount = handleTax(sender, recipient, amount);   
        }
        
        super._transfer(sender, recipient, amount);
    }
    
    
    /**
     * @dev Pauses transfers on the token.
     */
    function pause() public onlyOwner {
        require(!paused(), "CoinToken: Contract is already paused");
        _pause();
    }

    /**
     * @dev Unpauses transfers on the token.
     */
    function unpause() public onlyOwner {
        require(paused(), "CoinToken: Contract is not paused");
        _unpause();
    }
    
    /**
     * @dev Burns tokens from caller address.
     */
    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
    }
    
    /**
     * @dev Blacklists the specified account (Disables transfers to and from the account).
     */
    function enableBlacklist(address account) public onlyOwner {
        require(!blacklist[account], "CoinToken: Account is already blacklisted");
        blacklist[account] = true;
    }
    
    /**
     * @dev Remove the specified account from the blacklist.
     */
    function disableBlacklist(address account) public onlyOwner {
        require(blacklist[account], "CoinToken: Account is not blacklisted");
        blacklist[account] = false;
    }
    
    /**
     * @dev Excludes the specified account from tax.
     */
    function exclude(address account) public onlyOwner {
        require(!isExcluded(account), "CoinToken: Account is already excluded");
        excludeList[account] = true;
    }
    
    /**
     * @dev Re-enables tax on the specified account.
     */
    function removeExclude(address account) public onlyOwner {
        require(isExcluded(account), "CoinToken: Account is not excluded");
        excludeList[account] = false;
    }
    
    /**
     * @dev Sets tax for buys.
     */
    function setBuyTax(uint256 dev, uint256 marketing, uint256 liquidity, uint256 charity,uint256 repurchase) public onlyOwner {
        buyTaxes["dev"] = dev;
        buyTaxes["marketing"] = marketing;
        buyTaxes["liquidity"] = liquidity;
        buyTaxes["charity"] = charity;
        buyTaxes["repurchase"] = repurchase;
    }
    
    /**
     * @dev Sets tax for sells.
     */
    function setSellTax(uint256 dev, uint256 marketing, uint256 liquidity, uint256 charity,uint256 repurchase) public onlyOwner {

        sellTaxes["dev"] = dev;
        sellTaxes["marketing"] = marketing;
        sellTaxes["liquidity"] = liquidity;
        sellTaxes["charity"] = charity;
        sellTaxes["repurchase"] = repurchase;
    }
    
    /**
     * @dev Sets wallets for taxes.
     */
    function setTaxWallets(address liquidity,address dev, address marketing, address charity, address repurchase) public onlyOwner {
        taxWallets["liquidity"] = liquidity;
        taxWallets["dev"] = dev;
        taxWallets["marketing"] = marketing;
        taxWallets["charity"] = charity;
        taxWallets["repurchase"] = repurchase;
    }
    
    /**
     * @dev Enables tax globally.
     */
    function enableTax() public onlyOwner {
        require(!taxStatus, "CoinToken: Tax is already enabled");
        taxStatus = true;
    }
    
    /**
     * @dev Disables tax globally.
     */
    function disableTax() public onlyOwner {
        require(taxStatus, "CoinToken: Tax is already disabled");
        taxStatus = false;
    }
    
    /**
     * @dev Returns true if the account is blacklisted, and false otherwise.
     */
    function isBlacklisted(address account) public view returns (bool) {
        return blacklist[account];
    }
    
    /**
     * @dev Returns true if the account is excluded, and false otherwise.
     */
    function isExcluded(address account) public view returns (bool) {
        return excludeList[account];
    }
    
    receive() external payable {}
}