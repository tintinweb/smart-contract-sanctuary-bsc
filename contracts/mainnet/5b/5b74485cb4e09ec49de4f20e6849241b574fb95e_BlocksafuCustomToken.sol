/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

/**
* Blocksafu Custom Contract
* Deploy At: Jul, 19 2022
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens( 
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline 
    ) external; 

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  using SafeMath for uint256;
    
  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    require((value == 0) || (token.allowance(msg.sender, spender) == 0));
    require(token.approve(spender, value));
  }
  
  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    require(token.approve(spender, newAllowance));
  }
  
  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    require(token.approve(spender, newAllowance));
  }
}

contract BlocksafuCustomToken is ERC20, Ownable {
    using SafeMath for uint256;
    uint256 private constant initialSupply = 100_000_000 * 10**18;
    uint256 public constant denominator = 10000;
    uint256 public swapThreshold = 1; // The contract will only swap to ETH, once the fee tokens reach the specified threshold
    
    mapping (address => bool) public blacklist;
    mapping (address => bool) public excludeList;
    
    mapping (string => uint256) public buyTaxes;
    mapping (string => uint256) public sellTaxes;
    mapping (string => address) public taxWallets;
    
    bool public taxStatus = true;
    
    IUniswapV2Router02 public uniswapV2Router02;
    IUniswapV2Factory private uniswapV2Factory;
    address public uniswapV2Pair;
    
    constructor(address _router) ERC20("FUTURE BSC CARD", "FBC") payable
    {
        _setOwner(msg.sender);
        // _setOwner(0x94f80ad66c7fffa1b056d47Fe0aDfC0af20b7B71);

        uniswapV2Router02 = IUniswapV2Router02(_router);
        uniswapV2Factory = IUniswapV2Factory(uniswapV2Router02.factory());
        uniswapV2Pair = uniswapV2Factory.createPair(address(this), uniswapV2Router02.WETH());

        exclude(address(this));
        exclude(msg.sender);
        // exclude(0x94f80ad66c7fffa1b056d47Fe0aDfC0af20b7B71);

        // Buy Taxes
        buyTaxes["nftPrize"] = 500;
        buyTaxes["burn"] = 100;
        buyTaxes["liquidity"] = 200;

        // Sell Taxes
        sellTaxes["nftPrize"] = 500;
        sellTaxes["burn"] = 100;
        sellTaxes["liquidity"] = 400;

        // External wallets 
        taxWallets["nftPrize"] = msg.sender;
        taxWallets["liquidity"] = msg.sender;

        _mint(owner(), initialSupply);
    }
    
    uint256 private nftPrizeTokens;
    uint256 private liquidityTokens;
    uint256 private burnTokens;
    
    /**
     * @dev Calculates the tax, transfer it to the contract. If the user is selling, and the swap threshold is met, it executes the tax.
     */
    function handleTax(address from, address to, uint256 amount) private returns (uint256) {
        address[] memory sellPath = new address[](2);
        sellPath[0] = address(this);
        sellPath[1] = uniswapV2Router02.WETH();
        
        if(!isExcluded(from) && !isExcluded(to)) {
            uint256 tax = 0;
            uint256 baseUnit = amount.div(denominator);
            if(from == address(uniswapV2Pair)) {
                if(buyTaxes["nftPrize"] > 0){
                    tax += baseUnit * buyTaxes["nftPrize"];
                    nftPrizeTokens += baseUnit * buyTaxes["nftPrize"];
                }
                 
                if(buyTaxes["burn"] > 0) {
                    tax += baseUnit * buyTaxes["burn"];
                    burnTokens += baseUnit * buyTaxes["burn"];
                }
                if(buyTaxes["liquidity"] > 0) {
                    tax += baseUnit * buyTaxes["liquidity"];
                    liquidityTokens += baseUnit * buyTaxes["liquidity"];
                }
                
                if(tax > 0) {
                    _transfer(from, address(this), tax);   
                }
                
                
            } else if(to == address(uniswapV2Pair)) {
                if(sellTaxes["nftPrize"] > 0) {
                    tax += baseUnit * sellTaxes["nftPrize"];
                    nftPrizeTokens += baseUnit * sellTaxes["nftPrize"];
                }
                if(sellTaxes["burn"] > 0) {
                    tax += baseUnit * sellTaxes["burn"];
                    burnTokens += baseUnit * sellTaxes["burn"];
                }
                if(sellTaxes["liquidity"] > 0) {
                    tax += baseUnit * sellTaxes["liquidity"];
                    liquidityTokens += baseUnit * sellTaxes["liquidity"];
                }
                
                if(tax > 0) {
                    _transfer(from, address(this), tax);   
                }
                
                
                uint256 taxSum = nftPrizeTokens + liquidityTokens;
                
                
                if(taxSum == 0) return amount;
                
                uint256 ethValue = uniswapV2Router02.getAmountsOut(taxSum, sellPath)[1];
                
                if(ethValue >= swapThreshold) {
                    uint256 startBalance = address(this).balance;

                    uint256 toSell = nftPrizeTokens + liquidityTokens;
                    
                    
                    _approve(address(this), address(uniswapV2Router02), toSell);
                    
                    uniswapV2Router02.swapExactTokensForETH(
                        toSell,
                        0,
                        sellPath,
                        address(this),
                        block.timestamp
                    );
                    
                    uint256 ethGained = address(this).balance - startBalance;
                    
                    uint256 liquidityETH = (ethGained * ((liquidityTokens * 10**18) / taxSum)) / 10**18;
                    uint256 nftPrizeETH = (ethGained * ((nftPrizeTokens * 10**18) / taxSum)) / 10**18;
                    
                    
                    payable(taxWallets["nftPrize"]).transfer(nftPrizeETH);
                    payable(taxWallets["liquidity"]).transfer(liquidityETH);
                    _burn(address(this), burnTokens);
                    
                    nftPrizeTokens = 0;
                    burnTokens = 0;
                    liquidityTokens = 0;
                }
                
            }
            
            amount -= tax;
        }
        
        return amount;
    }
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override virtual {
        require(!isBlacklisted(msg.sender), "FBC: sender blacklisted");
        
        if(taxStatus) {
            amount = handleTax(sender, recipient, amount);   
        }
        
        super._transfer(sender, recipient, amount);
    }
    
    /**
     * @dev Triggers the tax handling functionality
     */
    function triggerTax() external onlyOwner {
        handleTax(address(0), address(uniswapV2Pair), 0);
    }
    
    /**
     * @dev Burns tokens from caller address.
     */
    function burn(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);
    }
    
    /**
     * @dev Blacklists the specified account (Disables transfers to and from the account).
     */
    function enableBlacklist(address account) external onlyOwner {
        require(isContract(account), "FBC: Cannot blacklist users");
        require(!blacklist[account], "FBC: Account is already blacklisted");
        blacklist[account] = true;
    }
    
    /**
     * @dev Remove the specified account from the blacklist.
     */
    function disableBlacklist(address account) external onlyOwner {
        require(blacklist[account], "FBC: Account is not blacklisted");
        blacklist[account] = false;
    }
    
    /**
     * @dev Excludes the specified account from tax.
     */
    function exclude(address account) public onlyOwner {
        require(!isExcluded(account), "FBC: Account is already excluded");
        excludeList[account] = true;
    }
    
    /**
     * @dev Re-enables tax on the specified account.
     */
    function removeExclude(address account) external onlyOwner {
        require(isExcluded(account), "FBC: Account is not excluded");
        excludeList[account] = false;
    }
    
    /**
     * @dev Sets tax for buys.
     */
    function setBuyTax(uint256 _nft, uint256 _burnAmount, uint256 _liquidity) external onlyOwner {
        require(_nft <= 500,"FBC: Maximum 5%");
        require(_burnAmount <= 500,"FBC: Maximum 5%");
        require(_liquidity <= 500,"FBC: Maximum 5%");

        buyTaxes["nftPrize"] = _nft;
        buyTaxes["burn"] = _burnAmount;
        buyTaxes["liquidity"] = _liquidity;
    }

    /**
     * @dev Sets tax for sells.
     */
    function setSellTax(uint256 _nft, uint256 _burnAmount, uint256 _liquidity) external onlyOwner {
        require(_nft <= 500,"FBC: Maximum 5%");
        require(_burnAmount <= 500,"FBC: Maximum 5%");
        require(_liquidity <= 500,"FBC: Maximum 5%");

        sellTaxes["nftPrize"] = _nft;
        sellTaxes["burn"] = _burnAmount;
        sellTaxes["liquidity"] = _liquidity;
    }
    
    /**
     * @dev Sets wallets for taxes.
     */
    function setTaxWallets(address _nft, address _liquidity) external onlyOwner {
        taxWallets["nftPrize"] = _nft;
        taxWallets["liquidity"] = _liquidity;
    }
    
    /**
     * @dev Enables tax globally.
     */
    function enableTax() external onlyOwner {
        require(!taxStatus, "FBC: Tax is already enabled");
        taxStatus = true;
    }
    
    /**
     * @dev Disables tax globally.
     */
    function disableTax() external onlyOwner {
        require(taxStatus, "FBC: Tax is already disabled");
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

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    function percentBuyNft() external view returns(uint256){
        return buyTaxes["nftPrize"];
    }

    function percentBuyBurn() external view returns(uint256){
        return buyTaxes["burn"];
    }

    function percentBuyLiquidity() external view returns(uint256){
        return buyTaxes["liquidity"];
    }

    function percentSellNft() external view returns(uint256){
        return sellTaxes["nftPrize"];
    }

    function percentSellBurn() external view returns(uint256){
        return sellTaxes["burn"];
    }

    function percentSellLiquidity() external view returns(uint256){
        return sellTaxes["liquidity"];
    }

    function setSwapTreshhold(uint256 _amount) external onlyOwner {
        swapThreshold = _amount;
    }
    
    receive() external payable {}
}