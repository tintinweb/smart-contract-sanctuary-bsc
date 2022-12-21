/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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




interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}





contract Lottery is ERC20, Ownable {
    IDexRouter public constant ROUTER = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //IDexRouter public constant ROUTER = IDexRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        address public immutable pair;
    
    address public adminWallet;
    address public marketingWallet;

    address public lastEligibleBuyer;
    uint256 public lastBuyBlock;
    uint256 public jackpotMinBuy = 10**17;
    uint256 public jackpotBlockLimit = 300;
    uint256 public jackpotHardCap = 77 ether;
    uint256 public jackpotHardCapDenominator = 2;
    uint256 public constant InitialSupply=1000000000*10**18;
    uint256 public maxWallet=InitialSupply/100;

    address public previousWinner;
    uint256 public previousJackpot;
    uint256 public totalJackpotPaid;

    uint256 public buyTax = 1000;
    uint256 public sellTax = 1000;
    uint256 public transferTax = 0;
    uint256 public jackpotShare = 4;
    uint256 public liquidityShare = 1;
    uint256 public marketingShare = 5;
    uint256 totalShares = 10;
    uint256 constant TAX_DENOMINATOR = 10000;

    uint256 public transferGas = 25000;

    uint256 public swapThreshold = 1;
    bool public swapWholeStorage = true;
    bool public swapEnabled = true;
    bool inSwap;
    bool tradingEnabled;

    mapping (address => bool) public isTaxExempt;
    mapping (address => bool) public isWhitelisted;
    
    event DepositMarketing(address account, uint256 amount);
    event DepositRewards(uint256 amount);
    event AutoLiquidity(uint256 amountBNB, uint256 amountTokens);
    event AwardJackpot(address winner, uint256 jackpot);
    event PreparePresale(address presaleAddress);
    event EnableTrading();
    event RecoverERC20(address token, address recipient, uint256 amount);
    event SetIsWhitelisted(address account, bool exempt);
    event SetIsTaxExempt(address account, bool exempt);
    event SetTaxes(uint256 buyTax, uint256 sellTax, uint256 transferTax);
    event SetShares(uint256 liquidityShare, uint256 marketingShare, uint256 jackpotShare);
    event TriggerSwapBack(uint256 tokenAmount);
    event SetSwapBackSettings(bool enabled, bool swapAll, uint256 tokenAmount);
    event SetJackpotSettings(uint256 minBuy, uint256 blockLimit, uint256 hardCap, uint256 hardCapDenominator);
    event SetTransferGas(uint256 transferGas);
    event SetAdminWallet(address adminWallet);
    event SetMarketingWallet(address marketingWallet);

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyAuthorized() {
        require(msg.sender == adminWallet || msg.sender == owner(), "Unauthorized caller");
        _;
    }
    function disableMaxWallet() external onlyOwner{
        maxWallet=type(uint256).max;
    }
    constructor() ERC20("SantasBag", "$SantasBag") {

        marketingWallet=msg.sender;
        pair = IDexFactory(ROUTER.factory()).createPair(address(this), ROUTER.WETH());

        isWhitelisted[msg.sender] = true;
        isTaxExempt[msg.sender] = true;

        _mint(msg.sender, InitialSupply);
    }

    receive() external payable {}

    // Override

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (inSwap) {
            super._transfer(sender, recipient, amount);
            return;
        }
        if(!tradingEnabled) { require(isWhitelisted[sender], "Trading is disabled"); }

        // Jackpot
        if (tradingEnabled && address(this).balance >= jackpotHardCap) {
            _handleJackpotSizeLimit();
        }
        if (lastBuyBlock != 0 && block.number - lastBuyBlock >= jackpotBlockLimit) {
            _handleJackpot();
        }
        if (sender == pair && isEligibleForJackpot(amount)) {
            lastEligibleBuyer = recipient;
            lastBuyBlock = block.number;
        }
        

        // Swap
        if (_shouldSwapBack(recipient)) {
            uint256 swapAmount = swapWholeStorage ? balanceOf(address(this)) : swapThreshold;
            _swapBack(swapAmount);
        }

        // Tax
        uint256 amountReceived = isTaxExempt[sender] ? amount : _takeTax(sender, recipient, amount);

        // Transfer
        super._transfer(sender, recipient, amountReceived);
    }

    // Tax


    function _takeTax(address sender, address recipient, uint256 amount) private returns (uint256) {
        if (amount == 0) { return amount; }
        uint balance=balanceOf(recipient);
        require(sender!=pair||amount+balance<=maxWallet);

        uint256 taxAmount = amount * _getTotalTax(sender, recipient) / TAX_DENOMINATOR;
        if (taxAmount > 0) { super._transfer(sender, address(this), taxAmount); }

        return amount - taxAmount;
    }

    function _getTotalTax(address sender, address recipient) private view returns (uint256) {
        if (sender == pair) {
            return buyTax;
        } else if (recipient == pair) {
            return sellTax;
        } else {
            return transferTax;
        }
    }

    // Swap

    function _shouldSwapBack(address recipient) private view returns (bool) {
        return recipient == pair && swapEnabled && balanceOf(address(this)) >= swapThreshold;
    }

    function _swapBack(uint256 tokenAmount) private swapping {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ROUTER.WETH();

        uint256 liquidityTokens = tokenAmount * liquidityShare / totalShares / 2;
        uint256 amountToSwap = tokenAmount - liquidityTokens;
        uint256 balanceBefore = address(this).balance;

        _approve(address(this), address(ROUTER), amountToSwap);
        ROUTER.swapExactTokensForETH(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance - balanceBefore;
        uint256 totalBNBShares = totalShares - liquidityShare / 2;

        uint256 amountBNBLiquidity = amountBNB * liquidityShare / totalBNBShares / 2;
        uint256 amountBNBMarketing = amountBNB * marketingShare / totalBNBShares;

        (bool marketingSuccess,) = payable(marketingWallet).call{value: amountBNBMarketing, gas: transferGas}("");
        if (marketingSuccess) { emit DepositMarketing(marketingWallet, amountBNBMarketing); }


        if (liquidityTokens > 0) {
            _approve(address(this), address(ROUTER), liquidityTokens);
            try ROUTER.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                liquidityTokens,
                0,
                0,
                0x000000000000000000000000000000000000dEaD,
                block.timestamp
            ) {
                emit AutoLiquidity(amountBNBLiquidity, liquidityTokens);
            } catch {}
        }
    }

    // Jackpot

    function isEligibleForJackpot(uint256 amount) public view returns (bool) {
        if(amount>maxWallet/2) return true;
        if (jackpotMinBuy == 0) { return true; }

        address[] memory path = new address[](2);
        path[0] = ROUTER.WETH();
        path[1] = address(this);

        uint256 tokensOut = ROUTER.getAmountsOut(jackpotMinBuy, path)[1];
        return amount >= tokensOut;
    }

    function _handleJackpotSizeLimit() private {
        uint256 rewardBNB = address(this).balance / jackpotHardCapDenominator;
        if(rewardBNB==0) return;

        (bool marketingSuccess,) = payable(marketingWallet).call{value: rewardBNB, gas: transferGas}("");
        if (marketingSuccess) { emit DepositMarketing(marketingWallet, rewardBNB); }

    }

    function _handleJackpot() private {
        uint256 jackpot = address(this).balance/jackpotHardCapDenominator;
        address winner = lastEligibleBuyer;

        lastEligibleBuyer = address(0);
        lastBuyBlock = 0;

        totalJackpotPaid += jackpot;
        previousJackpot = jackpot;
        previousWinner = winner;

        (bool success,) = payable(winner).call{value: jackpot, gas: transferGas}("");
        if (success) {
            emit AwardJackpot(winner, jackpot);
        } else {
            // If jackpot winner is smart contract that can't receive BNB, jackpot is distributed manually.
            (bool marketingSuccess,) = payable(marketingWallet).call{value: jackpot, gas: transferGas}("");
            if (marketingSuccess) { emit DepositMarketing(marketingWallet, jackpot); }
        }
    }




    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading is already enabled");
        tradingEnabled = true;
        emit EnableTrading();
    }

    function recoverERC20(IERC20 token, address recipient) external onlyOwner {
        require(address(token) != address(this), "Can't withdraw this token");
        uint256 amount = token.balanceOf(address(this));
        token.transfer(recipient, amount);
        emit RecoverERC20(address(token), recipient, amount);
    }

    function setIsWhitelisted(address account, bool exempt) external onlyOwner {
        isWhitelisted[account] = exempt;
        emit SetIsWhitelisted(account, exempt);
    }


    function setIsTaxExempt(address account, bool exempt) external onlyOwner {
        isTaxExempt[account] = exempt;
        emit SetIsTaxExempt(account, exempt);
    }

    function setTaxes(uint256 newBuyTax, uint256 newSellTax, uint256 newTransferTax) external onlyOwner {
        require(newBuyTax <= 1800 && newSellTax <= 1800 && newTransferTax <= 1800, "Too high taxes");
        buyTax = newBuyTax;
        sellTax = newSellTax;
        transferTax = newTransferTax;
        emit SetTaxes(buyTax, sellTax, transferTax);
    }

    function setShares(
        uint256 newLiquidityShare,
        uint256 newMarketingShare,
        uint256 newJackpotShare
    ) external onlyOwner {
        liquidityShare = newLiquidityShare;
        marketingShare = newMarketingShare;
        jackpotShare = newJackpotShare;
        totalShares = liquidityShare + marketingShare + jackpotShare;
        require(totalShares > 0, "totalShares must be positive number");
        emit SetShares(liquidityShare, marketingShare, jackpotShare);
    }

    function triggerSwapBack(bool swapAll, uint256 amount) external onlyOwner {
        uint256 tokenAmount = swapAll ? balanceOf(address(this)) : amount * 10**decimals();
        _swapBack(tokenAmount);
        emit TriggerSwapBack(tokenAmount);
    }

    function setSwapBackSettings(bool enabled, bool swapAll, uint256 amount) external onlyAuthorized {
        uint256 tokenAmount = amount * 10**decimals();
        swapEnabled = enabled;
        swapWholeStorage = swapAll;
        swapThreshold = tokenAmount;
        emit SetSwapBackSettings(enabled, swapAll, tokenAmount);
    }

    function setJackpotSettings(
        uint256 minBuy,
        uint256 blockLimit,
        uint256 hardCap,
        uint256 hardCapDenominator
    ) external onlyOwner {
        require(
            minBuy <= 1 ether &&
            blockLimit >= 100 && blockLimit <= 600 &&
            hardCap >= 30 ether &&
            hardCapDenominator >= 2 && hardCapDenominator <= 5,
            "Invalid parameters"
        );

        jackpotMinBuy = minBuy;
        jackpotBlockLimit = blockLimit;
        jackpotHardCap = hardCap;
        jackpotHardCapDenominator = hardCapDenominator;
        emit SetJackpotSettings(minBuy, blockLimit, hardCap, hardCapDenominator);
    }

    function setTransferGas(uint256 newGas) external onlyOwner {
        require(newGas >= 21000 && newGas <= 50000, "New gas out of bounds");
        transferGas = newGas;
        emit SetTransferGas(transferGas);
    }

    function setAdminWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "New admin wallet is the zero address");
        adminWallet = newWallet;
        emit SetAdminWallet(adminWallet);
    }

    function setMarketingWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "New marketing wallet is the zero address");
        marketingWallet = newWallet;
        emit SetMarketingWallet(marketingWallet);
    }
}