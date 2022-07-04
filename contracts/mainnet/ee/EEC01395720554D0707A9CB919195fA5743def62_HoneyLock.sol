/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
            require(currentAllowance >= amount, "HONEYLOCK: insufficient allowance");
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
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    // function addLiquidityETH(
    //     address token,
    //     uint amountTokenDesired,
    //     uint amountTokenMin,
    //     uint amountETHMin,
    //     address to,
    //     uint deadline
    // ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function addLiquidityAVAX(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountAVAX,
            uint256 liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IJoeRouter02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountAVAX,
            uint256 liquidity
        );

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}

interface IJoeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);

}


contract HoneyLockManager {
    IJoeRouter02 public router;
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    constructor(
        address _router
    ){
        router = IJoeRouter02(_router);
    }

    function addLiquidityAvax(address _tokenAddress, uint _tokenAmount)
        public
        payable
    {
        // console.log("TESTING ADD LIQUIDITY");
        IERC20(_tokenAddress).transferFrom(
            msg.sender,
            address(this),
            _tokenAmount
        );
        IERC20(_tokenAddress).approve(address(router), _tokenAmount);

        
        // console.log("Balance OF Contract", IERC20(_tokenAddress).balanceOf(address(this)));

        router.addLiquidityETH{value: msg.value}(
            _tokenAddress,
            _tokenAmount,
            1,
            1,
            DEAD,
            block.timestamp
        );
    }
}

contract HoneyLock is ERC20, Ownable {

    /* State Variables */
    uint256 private _decimals = 18;
    mapping(address => bool) private _isWhitelisted;
    mapping(address => bool) private _isBlacklisted;
    uint256 private unlockTime;
    uint256 private minBlocks;
    mapping(address => bool) private _isGoldenAddress;
    bool private isTrading;
    bool private isSelling;
    // address RouterV2 = 0xE58BaF94B10122c056C3F0514Cd9C5331f82dDEb;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    /* Token Variables */
    IJoeRouter02 public router;
    IJoeFactory public factory;
    HoneyLockManager public honeyLockManager;
    address WBNB;
    //Marketing Wallet
    address private marketingWallet;
    //Liquidity Wallet
    address private lpWallet;
    //Liquidity Pair Address
    address private lpPair;
    //Buyback Wallet
    address private buybackWallet;

    /* Tax Variables */
    uint8[] private sellTaxValues = [10,15,20,25,30,35,40,45,50];
    uint8 private buyTax = 6;
    uint8 private marketingTax;
    uint8 private buyBackTax;
    uint16 private sellCount;
    uint16 private buyCount;
    uint16 private maxSell;
    uint16 private maxBuy;
    uint8 private maxSellAmount;
    uint8 private maxTransactionAmount = 2;
    uint8 private sellDecimals = 4;
    uint256 private threshold;
    bool private swapAndLiquifyEnabled;
    bool private takeTax = false;

    constructor(
        uint256 _totalSupply,
        address _marketing,
        address _lpWallet,
        uint8 _marketingTax,
        uint8 _buyBackTax,
        uint16 _maxSell,
        uint16 _maxBuy,
        uint8 _maxSellAmount,
        uint256 _threshold
    ) ERC20("HoneyLock", "HLCK"){
        marketingWallet = _marketing;
        lpWallet = _lpWallet;
        marketingTax = _marketingTax;
        buyBackTax = _buyBackTax;
        maxSell = _maxSell;
        maxBuy = _maxBuy;
        maxSellAmount = _maxSellAmount;
        threshold = _threshold;

        router = IJoeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        factory = IJoeFactory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);

        WBNB = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

        lpPair = factory.createPair(WBNB, address(this));
        swapAndLiquifyEnabled = false;
        _mint(msg.sender, _totalSupply * (10**_decimals));
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override virtual { 
        uint256 amountReceived;

        if (takeTax){
            uint256 taxAmount = takeTaxes(from, to, amount);
            amountReceived = amount - taxAmount;
            uint256 contractBalance = address(this).balance;

            if (swapAndLiquifyEnabled) {
                super._transfer(from, address(this), taxAmount);
                uint256 contractTokenBalance = balanceOf(address(this));
                if (contractTokenBalance > threshold) {
                    swapTokensForBNB(taxAmount);
                }
            require(distributeTax());
            }
        } else {
            amountReceived = amount;
        }
        
        super._transfer(from, to, amountReceived);
        emit Transfer(from, to, amount); 
    }

    function addLiquidity(uint256 amount) external payable {
        // console.log("TESTING ADD LIQUIDITY");
        approve(address(this), amount);
        IERC20(address(this)).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        IERC20(address(this)).approve(address(router), amount);

        
        // console.log("Balance OF Contract", IERC20(_tokenAddress).balanceOf(address(this)));

        router.addLiquidityETH{value: msg.value}(
            address(this),
            amount,
            1,
            1,
            DEAD,
            block.timestamp
        );
    }

    /* Tax Functions */
    function takeTaxes(
        address from, 
        address to, 
        uint256 amount
    ) internal returns (uint256) {
        require(!_isBlacklisted[_msgSender()]);
        uint256 currentFee;
        uint256 finalAmount;

        // uint256 transactionThreshold = (totalSupply() / 1000) * maxTransactionAmount;
        // require(amount < transactionThreshold);
        if (from == lpPair /* address(this)*/) { // buying

            if(!_isWhitelisted[msg.sender]){
                require(isTrading, "Trading Disabled");
                require(buyCount + 1 <=  maxBuy, "Transfer Failed");
                if(unlockTime + minBlocks >= block.number) {
                    currentFee = buyTax;
                    finalAmount = (amount/100)*currentFee;
                }else{
                    _isBlacklisted[_msgSender()] = true;
                }
            }else{
                finalAmount = 0;
            }
            buyCount++;
        } else if (to == lpPair /* address(this)*/) { //selling
            // console.log("TOTAL SUPPLY", totalSupply());
            uint256 sellAmount = (totalSupply() / sellDecimals) * maxSellAmount;
            if (!_isWhitelisted[_msgSender()] /*&& !_isGoldenAddress[_msgSender()]*/){
                require(amount < sellAmount);
                require(isSelling, "HoneyLock Active");
                require(isTrading, "Trading Disabled");
                require(sellCount + 1 <= maxSell, "Transfer Failed");
                uint256 tokenBalance = balanceOf(from);
                uint256 percentage = (amount/tokenBalance)*100;
                currentFee = getTax(percentage);
                finalAmount = (amount/100)*currentFee;
            }else if (_isGoldenAddress[_msgSender()]) {
                require(sellCount + 1 <= maxSell, "Transfer Failed");
                uint256 tokenBalance = balanceOf(from);
                uint256 percentage = (amount/tokenBalance)*100;
                currentFee = getTax(percentage);
                finalAmount = (amount/100)*currentFee;
            }else{
                finalAmount = 0;
            }
            sellCount++;
        } else {
            finalAmount = 0; 
        }
        return finalAmount;
    }

    function distributeTax() internal returns (bool) {
        uint256 contractBalance = address(this).balance;
        uint256 toMarketing = (contractBalance/100)*marketingTax;
        uint256 toBuyBack = (contractBalance/100)*buyBackTax;
        uint256 toLp = contractBalance - toMarketing - toBuyBack;

        (bool tmpSuccess,) = payable(marketingWallet).call{value: toMarketing}("");
        (tmpSuccess,) = payable(buybackWallet).call{value: toBuyBack}("");
        (tmpSuccess,) = payable(lpWallet).call{value: toLp}("");

        return true;
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        // generate the pancake pair path of token -> wbnb
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);
        
        // make the swap
        router.swapExactTokensForETH(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    /* Parameter Functions */
    //1 - MarketingWallet 2 - LiquidityWallet
    function setWallets(address[3] calldata wallets) external onlyOwner{
        marketingWallet = wallets[0];
        lpWallet = wallets[1];
        buybackWallet = wallets[2];
    }

    // 1 - BuyTax 2 - MarketingTax 
    function setTaxes(uint8[2] calldata taxes) external onlyOwner{
        buyTax = taxes[0];
        marketingTax = taxes[1];
    }

    function toggleSwapLiquify() external onlyOwner {
        swapAndLiquifyEnabled = !swapAndLiquifyEnabled;
    }

    //Set Max Buy
    function setMaxBuy(uint16 _maxBuy) external onlyOwner {
        maxBuy = _maxBuy;
    }

    //Set Max Sell
    function setMaxSell(uint16 _maxSell) external onlyOwner {
        maxSell = _maxSell;
    }

    //Reset Sell Count
    function resetSellCount() external onlyOwner {
        sellCount = 0;
    }

    //Reset Buy Count
    function resetBuyCount() external onlyOwner {
        buyCount = 0;
    }

    //Set LP Pair Address
    function setLpPair(address _lpPair) external onlyOwner {
        lpPair = _lpPair;
    }

    //Whitelist Address
    function setWhitelist(address account, bool _bool) public onlyOwner {
        _isWhitelisted[account] = _bool;
    }

    //Blacklist Address
    function setBlacklist(address account, bool _bool) public onlyOwner {
        _isBlacklisted[account] = _bool;
    }

    //Toggle trading 
    function toggleTrading() external onlyOwner{
        isTrading = !isTrading;
    }

    //Toggle Taxes
    function toggleTaxes() external onlyOwner{
        takeTax = !takeTax;
    }

    //Toggle HoneyLock
    function honeyLock() external onlyOwner {
        isSelling = !isSelling;
        unlockTime = block.number;
    }   

    //Set MinBlocks
    function setMinBlocks(uint256 _minBlocks) external onlyOwner {
        minBlocks = _minBlocks;
    }

    //Set Max Sell Amount Percentage
    function setMaxSellPerc(uint8 _maxSellAmount) external onlyOwner {
        maxSellAmount = _maxSellAmount;
    }

    //Set Max Transaction Amount Percentage
    function setMaxTransactionPerc(uint8 _maxTransactionAmount) external onlyOwner {
        maxTransactionAmount = _maxTransactionAmount;
    }

    //Set Sell Amount Decimals
    function setSellAmountDecimals(uint8 _sellDecimals) external onlyOwner {
        sellDecimals = _sellDecimals;
    }

    //Set Threshold
    function setThreshold(uint256 _threshold) external onlyOwner {
        threshold = _threshold;
    }

    //Create Pair
    function createPair(address _token) external onlyOwner {
        IDEXFactory(router.factory()).createPair(_token, address(this));
    }

    /* View / Pure Functions */
    function getTax(uint256 percentage) internal view returns (uint256) {
        if (percentage < 20){
            return sellTaxValues[0];
        } else if (percentage >= 20 && percentage < 30){
            return sellTaxValues[1];
        } else if (percentage >= 30 && percentage < 40){
            return sellTaxValues[2];
        } else if (percentage >= 40 && percentage < 50){
            return sellTaxValues[3];
        } else if (percentage >= 50 && percentage < 60){
            return sellTaxValues[4];
        } else if (percentage >= 60 && percentage < 70){
            return sellTaxValues[5];
        } else if (percentage >= 70 && percentage < 80){
            return sellTaxValues[6];
        } else if (percentage >= 80 && percentage < 90){
            return sellTaxValues[7];
        } else  {
            return sellTaxValues[8];
        }   
    }

    function getTaxRates() external view onlyOwner returns (uint8[3] memory) {
        return [buyTax, buyBackTax, marketingTax];
    }

    function getBuyCount() external view returns (uint256) {
        return buyCount;
    }

    function getSellCount() external view returns (uint256) {
        return sellCount;
    }

    function getTradingStatus() external view returns (bool) {
        return isTrading;
    }

    function getHoneyLockStatus() external view returns (bool) {
        return isSelling;
    }

    function checkWhitelist(address user) external view returns (bool) {
        return _isWhitelisted[user];
    }

    function checkBlacklist(address user) external view returns (bool) {
        return _isBlacklisted[user];
    }

    function getWBNBPair() external view returns (address) {
        return lpPair;
    }

    function getPair(address _token) external view returns (address) {
        return  IDEXFactory(router.factory()).getPair(_token, address(this));
    }

    // Withdraw Stuck BNB
    function withdrawBNB() external onlyOwner {
        (bool hs, ) = payable(owner()).call{value: address(this).balance}("");
        require(hs);
    }

    // Withdraw stuck tokens 
    function rescueToken(IERC20 token, uint256 amount, address to) external onlyOwner {
        if( token.balanceOf(address(this)) < amount ) {
            amount = token.balanceOf(address(this));
        }
        token.transfer(to, amount);
    }

}