/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.7;

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


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
}


contract ListingController {

    IUniswapV2Router02 public v2Router;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    uint internal listingFeePercent = 0;
    uint internal listingDuration;
    uint internal listingStartAt =  0;

    uint internal minFeeWhenLissting = 5;

    bool internal listingFinished;

    constructor(uint listingDuration_){
        listingDuration = listingDuration_;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
             .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
    }

    function _startListing() private{
        listingStartAt = block.timestamp;
        listingFeePercent = 100;
    }

    function _finishListing() private{
        listingFinished = true;
    }

    function _updateListingTime(address recipient_, uint amount_) internal {
        if (listingStartAt == 0) { 
            // first addLiquidity
            if (recipient_ == uniswapV2Pair && amount_ > 0) {
                _startListing();
            }
        } else {
            if (listingStartAt + listingDuration <= block.timestamp) {
                _finishListing();
            }
        }
    }

    function getListingDuration() external view returns (uint){
        return listingDuration;
    }

    function isListingFinished() external view returns (bool){
        return listingFinished;
    }

    function listingStartAtBlock() external view returns (uint){
        return listingStartAt;
    }

}

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

contract PiSoccer is ERC20, Ownable, ListingController {

    mapping(address => bool) private blackListedList;
    mapping(address => bool) private isExcludedFromFee;
    uint256 public maxAmount =  600 * 10**3 * 10**18;
    uint256 public swapTokensAtAmount = 300**3 * 10**18;

    STransferFee private _transferFee;
    uint constant private DEMI = 100;

    event SetTransferFee(
        STransferFee transferFee
    );

    struct STransferFee {
        address to;
        uint buy;
        uint sell;
        uint normal;
    }

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() ERC20("PiSoccer", "PISO") ListingController(100) {
        _mint(msg.sender,  3000000000 * (10**18));
        excludeFromFee(address(this));
        excludeFromFee(msg.sender);
        uint buyFee = 10;
        uint sellFee = 10;
        uint normalFee = 0;
        _setTransferFee(address(this), buyFee, sellFee, normalFee);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(
            !blackListedList[from] && !blackListedList[to],
            "Address is blacklisted"
        );
        super._beforeTokenTransfer(from, to, amount);
    }

    function _transfer(address sender_, address recipient_,uint256 amount_) internal override  {
        if (!listingFinished) {
            _updateListingTime(recipient_, amount_);

            uint feeDemi = recipient_ == ListingController.uniswapV2Pair
                ? _transferFee.sell
                : (sender_ == ListingController.uniswapV2Pair ? _transferFee.buy : 0);
            uint fee = amount_ * feeDemi / 100;
            if (recipient_ == ListingController.uniswapV2Pair) {   // sell
                if (isExcludedFromFee[sender_]) fee = 0;
            } else {
                if (sender_ == ListingController.uniswapV2Pair) {  // buy
                    if (isExcludedFromFee[recipient_]) fee = 0;
                } 
            }
            require(fee <= amount_, "Token: listing fee too high");
            uint transferA = amount_ - fee;
            if (fee > 0) {
                require(amount_ <= maxAmount, "Token: buy too much");
                super._transfer(sender_, _getTransferFeeTo(), fee);
            }
            super._transfer(sender_, recipient_, transferA);
        } else {
            if (inSwap) { 
                    super._transfer(sender_, recipient_, amount_); 
            } else {
                uint256 feeTransferDemi = recipient_ == ListingController.uniswapV2Pair
                ? _transferFee.sell
                : (sender_ == ListingController.uniswapV2Pair ? _transferFee.buy : 0);
                uint feeTransfer = amount_ * feeTransferDemi / 100;
                uint hold =0;
                if (recipient_ == ListingController.uniswapV2Pair) {   // sell
                    feeTransfer = amount_ * _transferFee.sell / 100;
                    hold = 1;
                    if (isExcludedFromFee[sender_]) feeTransfer = 0;
                } else {
                    if (sender_ == ListingController.uniswapV2Pair) {  // buy
                        feeTransfer = amount_ * _transferFee.buy / 100;
                        if (isExcludedFromFee[recipient_]) feeTransfer = 0;
                    } else {
                        feeTransfer = amount_ * _transferFee.normal / 100;
                    }
                }
                if(shouldSwapBack(sender_)){
                    swapBack();
                }
                require(feeTransfer <= amount_, "Token: transferFee too high");
                uint transferA = amount_ - feeTransfer;
                if (feeTransfer > 0) {
                    super._transfer(sender_, _getTransferFeeTo(), feeTransfer);
                }
                if (transferA > 0) {
                    super._transfer(sender_, recipient_, transferA - hold);
                }
            }
            
        }
    }

    function _setTransferFee(address to_, uint buyFee_, uint sellFee_, uint normalFee_) internal{
        require(buyFee_ <= 10, "TransferFee: fee must be less or equal 10%");
        require(sellFee_ <= 10, "TransferFee: fee must be less or equal 10%");
        require(normalFee_ <= 10, "TransferFee: fee must be less or equal 3%");
        _transferFee.to = to_;
        _transferFee.buy = buyFee_;
        _transferFee.sell = sellFee_;
        _transferFee.normal = normalFee_;
        emit SetTransferFee(_transferFee);
    }

    function _getTransferFeeTo() internal view returns (address){
        return _transferFee.to;
    }

    function transferFee() external view returns (STransferFee memory){
        return _transferFee;
    }


    function addBlackList(address add) external onlyOwner {
        blackListedList[add] = true;
    }

    function addBlackLists(address[] calldata listAddress) external onlyOwner {
        uint256 count = listAddress.length;
        for (uint256 i = 0; i < count; i++) {
            blackListedList[listAddress[i]] = true;
        }
    }

    function removeBlackList(address add) external onlyOwner {
        blackListedList[add] = false;
    }

    function removeBlackLists(address[] calldata listAddress) external onlyOwner {
        uint256 count = listAddress.length;
        for (uint256 i = 0; i < count; i++) {
            blackListedList[listAddress[i]] = false;
        }
    }

    function excludeFromFee(address address_) public onlyOwner{
        isExcludedFromFee[address_] = true;
    }

    function removeExcludeFee(address address_) external onlyOwner{
        isExcludedFromFee[address_] = false;
    }

    /*
        Settings
    */


    function setTransferFee(address to_, uint buyFee_, uint sellFee_, uint normalFee_) external onlyOwner{
        _setTransferFee(to_, buyFee_, sellFee_, normalFee_);
    }

    function setMaxAmount(uint256 _maxAmount) external onlyOwner{
        require(_maxAmount > 3000 * 10**3 * 10**18, "maxAmount too small");
        maxAmount = _maxAmount;
    }

    function setSwapTokensAtAmount(uint256 _swapTokensAtAmount) external onlyOwner{
        swapTokensAtAmount = _swapTokensAtAmount;
    }

    function shouldSwapBack(address sender_) internal view returns (bool) {
        uint256 _contractBalance = balanceOf(address(this));
        return !(sender_ == ListingController.uniswapV2Pair) && !inSwap && _contractBalance >= swapTokensAtAmount;
    }

    function swapBack() public onlyOwner {
        swapTokensForEth(balanceOf(address(this)));
    }
    
    function swapTokensForEth(uint256 tokenAmount) internal swapping {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ListingController.uniswapV2Router.WETH();
        _approve(address(this), address(ListingController.uniswapV2Router), tokenAmount);

        try
        ListingController.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        ){}
        catch{}
    }


    /*
         Withdraw
     */

    function withdrawBalance() external onlyOwner {
        address payable _owner = payable(_msgSender());
        _owner.transfer(address(this).balance);
    }

    function withdrawTokens(address _tokenAddr, address _to) external onlyOwner{
        require(
            _tokenAddr != address(this),
            "Cannot transfer out tokens from contract!"
        );
        require(isContract(_tokenAddr), "Need a contract address");
        ERC20(_tokenAddr).transfer(
            _to,
            ERC20(_tokenAddr).balanceOf(address(this))
        );
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    receive() external payable { }
}