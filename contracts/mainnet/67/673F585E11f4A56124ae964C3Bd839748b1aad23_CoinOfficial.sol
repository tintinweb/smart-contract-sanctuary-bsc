/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

/**
                                          .ij12r.                                         
                                        :vYJLLLuJv:                                       
                                    :L0ZZkS15U5FqNMMOJ:                                   
                                 :Y0E05521U1U51F1kSPNMBMu:                                
                              :[email protected]@G,                             
                           :[email protected]@07.                              
                        :[email protected]                                  
                     :[email protected]                                     
                  :[email protected]@Ni                                        
               :[email protected]                          .                
            :[email protected]                          . ....,..           
         :[email protected]                          . ......,,::i:.        
      :[email protected]@Er                            ......,.,:::::iiri,     
   [email protected]                        . ........,,:,::::::iiii77Yr.  
  [email protected]                            ,,,.,.,.,:::::::i:ii;irr77J27 
 [email protected]                                 .::::::::::i:iiiirr7r7rv7Yk,
 [email protected]                                      .:;rriiiiir;rrrr7rv7vvLJUv
[email protected]                    ,LPr.                   .ivvvrrr7r77v7LvLLjJuuL
.uNFS5S5SSXkXkqNBB87                    ,vqZ0XEEXr.                   ,rUuL7v7LvYLJJuJUu5v
 1PkFkFkSXkPkqPMv                    ,vqGNF1uUU15EZX7.                   ,LjLYYjJuJuuUu11J
.10kkSXXPXqXqPZB                  ,LNZN52uUjuuujUu1FEZX7.                 rFjJuJuuUU1U51ku
[email protected]              ,LqG051uUuujUjujUuUuuu55EZkr.              7quUuUU2151SFkX2
.5GPqPNPNq0NEEOB.           .7XEN51uUjujujuJujuuujuuuuUu55EZNv:           Lq5u1251S5kSXX01
[email protected]          @[email protected]:          L85F1S5kkXkPXqqk
,XON0qZ0Z0ZEGZMB.          [email protected]:             j8kFkkXkqXqqENGS
,[email protected]          @@@[email protected]:                jMkXkqP0qE0E08GN
:qOEGZGZ8GOGOOBB.          [email protected]@[email protected]                   2M0P0q00EEGGO8M0
:[email protected]          @BBMMGO8OO8P5JJYuu22PEGUi                      [email protected]
:[email protected],          [email protected] [email protected]
:[email protected]          @@MZG0EPqXPSkFk5Sk;                            [email protected]
;[email protected]@.          [email protected]                             PBMOMMBMBMM8OGOF
;[email protected]          @BZqqPPSSFFUUuuj1S                             [email protected]
[email protected]          MBqPXX5S15U2uuYjjS                             EBBOM8OZG0ENEP0u
[email protected]          MMqkk5511uUjuYjLu1                             [email protected]
jOMOOZOZZ0EqNqZB.          BBPk5FU2uujJLLvLL2                             PBO0Eq0XPXXkS5kL
[email protected] [email protected] [email protected]
2qO0ZNNPqPPSkFPM.            i5Z8k1YJvLvv777Y                             5BNSXSS5F11U2u17
1P0NPqXXSXFk1F5M.               :uSXuYvvr7r7v                             uMkSF525U1uuJujr
k10XPSk5S5F25UFE                   :vu2L7rrr7                             LGf41z37#8177Lji
P2XPFS5521u2u2uX7.                    ,rvLrrr                            7XkDΞV#8294LLLLLi
ZUk1S25U2uujuJuJSXFr.                    .i7L                         vNMGkuujuYJLLvv7v7L:
7FS1U2uUjuYJYJvYLYjF5ur.                    ,                      7PM8P22jjYJvLvv7v77r77:
 LE1ujuYuYJLYvLvv7v7vvuuLi.                                     7PMOq22JjLYvLvv7v77r7rrrL 
  OPuuLYvLvLvv7v77r7rrrrrLv7:.                               rXMOP1UJuLYLLvv7v77rr;rrri77 
  .kqujvLvv7777r7rr;ri;iiiii7r;,                         .7PMGq1UJjYYvL7v7777r7rr;ri;i7r  
    i15ULv77r7rr;ri;ii:i:i:::::;;i,                     [email protected];r;;iiirri.   
      .rJjY77;riiii:i:::::::::::::ii:.                    ,7SXFJYvv77r7rr;ririii;rr:.     
         .:7v7r;ii::::::::::::::::::::::.                    .;uUuv7rr;r;ri;irrr:.        
             :rrri:::::::::,:::,:,:,,,:,::,.                    .iLLvr;iiirrr:.           
                ,iir::::,:::,:,:,,.,.,.,.,,:,,.                    .:rrrr;:.              
                   .:ii:::,,:.,,,.,.,.........,..                     .:.                 
                      .:::,,,,.,.,............ .....                                      
                         .:::,,.,.......... . . .   .                                     
                             ,,,...... . . .                                              
                                ....... . . .                                             
                                   ... . .                                                
                                                                                          
                                                                                          
*/
/**
 *Submitted for verification at Etherscan.io on 2022-11-30
*/

//SPDX-License-Identifier: Unlicensed                    
pragma solidity 0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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

contract Ownable is Context {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Router01 {
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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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
}

interface CoinOfficialAntiBot {
    function setTokenOwner(address owner) external;

    function onPreTransferCheck(
        address from,
        address to,
        uint256 amount
    ) external;
}

contract CoinOfficial is ERC20, Ownable {
    
    // Global Variables
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
    address public constant deadAddress = address(0xdead);

    bool private swapping;

    address public treasuryWallet;
    
    uint256 public swapTokensAtAmount;

    bool public tradingActive = false;
    bool public swapEnabled = false;

    address public COAntiBot;
    bool public antiBotEnabled;
    
    uint256 public buyTotalFees;
    uint256 public buyTreasuryFee;
    uint256 public buyLiquidityFee;
    
    uint256 public sellTotalFees;
    uint256 public sellTreasuryFee;
    uint256 public sellLiquidityFee;
    
    uint256 public tokensForTreasury;
    uint256 public tokensForLiquidity;

     /******************/

    // Exclusion From Fees and And Allowed Trading When Trading Is Closed
    mapping (address => bool) private _isExcludedFromFees;

    // Store Addresses That Are Automatic Market Maker (AMM) Pairs. Any Transfer To Or From These Addresses Will Be Subject To A Fee
    mapping (address => bool) public automatedMarketMakerPairs;

    // Events Emitted
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event treasuryWalletUpdated(address indexed newWallet, address indexed oldWallet);
    event updatedTokensAtSwapAmount(uint256 indexed newAmount, uint256 indexed swapTokensAtAmount); 
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
    event updatedBuyTreasuryFee(uint256 indexed _treasuryFee, uint256 indexed buyTreasuryFee); 
    event updatedBuyLiquidityFee(uint256 indexed _liquidityFee, uint256 indexed buyLiquidityFee); 
    event updateSellTreasuryFee(uint256 indexed _treuasryFee, uint256 indexed sellTreasuryFee); 
    event updateSellLiquidityFee(uint256 indexed _liquidityFee, uint256 indexed sellLiquidityFee); 

    constructor() ERC20("Coin Official", "VOTE") {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);
        
        uint256 totalSupply = 10 * 1e6 * 1e18;
        swapTokensAtAmount = totalSupply * 1 / 1000; 

        buyTreasuryFee = 0;
        buyLiquidityFee = 0;
        buyTotalFees = buyTreasuryFee + buyLiquidityFee;

        sellTreasuryFee = 0;
        sellLiquidityFee = 10;
        sellTotalFees = sellTreasuryFee + sellLiquidityFee;

        COAntiBot =  0xDC6fcfa0416e5009b6555ad6f05FD9433e13fdD5;
        CoinOfficialAntiBot(COAntiBot).setTokenOwner(msg.sender);
        antiBotEnabled = true;

        treasuryWallet = 0xa095F781863f9f81836cB825dC0A0B3886028f10;

        // Exclude From Paying Fees 
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(deadAddress, true);

       // Mint Function Only Called Once
        _mint(0x6C9d1CE917A497b2E944514A39AD199F2e8D0E24, totalSupply);
    }

     receive() external payable {

  	}

     // Once Enabled, Trading Can Never Be Turned Back Off
    function enableTrading() external onlyOwner {
        tradingActive = true;
        swapEnabled = true;
    }

    // Change The Minimum Amount Of Tokens To Sell From Fees
    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner returns (bool){
  	    require(newAmount >= totalSupply() * 1 / 100000, "Swap tokens at amount cannot be lower than 0.001% total supply."); // This is to prevent the contract from constantly selling 
  	    swapTokensAtAmount = newAmount;
        emit updatedTokensAtSwapAmount(newAmount, swapTokensAtAmount); 
  	    return true;
  	}

    // Updates The Buy Taxes
    function updateBuyFees(uint256 _treasuryFee, uint256 _liquidityFee) external onlyOwner {
        emit updatedBuyTreasuryFee(_treasuryFee, buyTreasuryFee); 
        emit updatedBuyLiquidityFee(_liquidityFee, buyLiquidityFee); 
        buyTreasuryFee = _treasuryFee;
        buyLiquidityFee = _liquidityFee;
        buyTotalFees = buyTreasuryFee + buyLiquidityFee;
        require(buyTotalFees <= 20, "Must keep fees at 20% or less");
    }

    // Turns Anti-Bot Off
    function setAntiBotOff() external onlyOwner {
        antiBotEnabled = false;
    }
    
    // Updates The Sell Taxes
    function updateSellFees(uint256 _treasuryFee, uint256 _liquidityFee) external onlyOwner {
        emit updateSellTreasuryFee(_treasuryFee, sellTreasuryFee); 
        emit updateSellLiquidityFee(_liquidityFee, sellLiquidityFee); 
        sellTreasuryFee = _treasuryFee;
        sellLiquidityFee = _liquidityFee;
        sellTotalFees = sellTreasuryFee + sellLiquidityFee;
        require(sellTotalFees <= 20, "Must keep fees at 20% or less");
    }

    // Excludes Wallets From Fees
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }
    
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }
    
    // Update Treasury Wallet
    function updateTreasuryWallet(address newTreasuryWallet) external onlyOwner {
        require(newTreasuryWallet != address(0), "Treasury wallet can not be set to a zero address");
        emit treasuryWalletUpdated(newTreasuryWallet, treasuryWallet); 
        treasuryWallet = newTreasuryWallet;
    }

    // Renounce Ownership Of The Contract
    function renounceOwnership() public override onlyOwner {
        _isExcludedFromFees[_owner] = false;
        emit OwnershipTransferred(_owner, address(0));
        CoinOfficialAntiBot(COAntiBot).setTokenOwner(address(0));
        _owner = address(0);
    }

    // Transfer's Ownership Of The Contract
    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _isExcludedFromFees[_owner] = false;
        emit OwnershipTransferred(_owner, newOwner);
        CoinOfficialAntiBot(COAntiBot).setTokenOwner(newOwner);
        _owner = newOwner;
        _isExcludedFromFees[_owner] = true;
    }

    // View Which Wallet's Have Excluded From Fees
    function isExcludedFromFees(address account) external view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
         if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if(!tradingActive) {
            require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
        }
                  
        if(!tradingActive){
            require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
        }

         if (antiBotEnabled) {
            CoinOfficialAntiBot(COAntiBot).onPreTransferCheck(from, to, amount);
        }
                  
        if( 
            swapEnabled &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;
            
            swapBack();

            swapping = false;
        }
        
        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        
        uint256 fees = 0;
        uint256 tokensForTreasuryGained = 0;
        uint256 tokensForLiquidityGained = 0;
        
        // only take fees on buys/sells, do not take on wallet transfers
        if(takeFee){
            
            // on sell
            if (automatedMarketMakerPairs[to] && sellTotalFees > 0){
                fees = amount * sellTotalFees / 100;

                tokensForLiquidityGained = fees * sellLiquidityFee / sellTotalFees;
                tokensForTreasuryGained = fees * sellTreasuryFee / sellTotalFees;

                tokensForLiquidity += tokensForLiquidityGained;
                tokensForTreasury += tokensForTreasuryGained;
            }
            // on buy
            else if(automatedMarketMakerPairs[from] && buyTotalFees > 0) {
        	    fees = amount * buyTotalFees / 100;

                tokensForLiquidityGained = fees * buyLiquidityFee / buyTotalFees;
                tokensForTreasuryGained = fees * buyTreasuryFee / buyTotalFees;

                tokensForLiquidity += tokensForLiquidityGained;
                tokensForTreasury += tokensForTreasuryGained;
            }
        
            if(tokensForLiquidityGained > 0 || tokensForTreasuryGained > 0){    
                super._transfer(from, address(this), tokensForLiquidityGained);
                super._transfer(from, treasuryWallet, tokensForTreasuryGained);
            }
            
        	amount -= tokensForLiquidityGained + tokensForTreasuryGained;
        }

        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            deadAddress,
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));

        if(contractBalance > swapTokensAtAmount * 5) {
            contractBalance = swapTokensAtAmount * 5;
        }

        if(contractBalance == 0){
            return;
        }

        // Halve The Amount Of Liquidity Tokens
        uint256 liqudityTokens = contractBalance / 2;
        uint256 amountToSwapForEth = liqudityTokens;

        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amountToSwapForEth);
        uint256 ethBalance = address(this).balance - initialETHBalance;
        
        uint256 ethForLiquidity = ethBalance;

        if(liqudityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liqudityTokens, ethForLiquidity);
            emit SwapAndLiquify(amountToSwapForEth, ethForLiquidity, tokensForLiquidity);
        }

        tokensForLiquidity = 0;
        tokensForTreasury = 0;
    }

}