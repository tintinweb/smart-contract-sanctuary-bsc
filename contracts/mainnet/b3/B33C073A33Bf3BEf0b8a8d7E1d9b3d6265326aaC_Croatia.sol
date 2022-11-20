/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

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


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

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

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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



contract TokenHelper is Ownable {
    using SafeMath for uint256;

    address[] public shareholders;
    uint256 public currentIndex;  
    mapping(address => bool) private _updated;
    mapping (address => uint256) public shareholderIndexes;

    address public  uniswapV2Pair;
    address public lpRewardToken;
    // 上次分红时间
    uint256 public LPRewardLastSendTime;

    constructor(address uniswapV2Pair_, address lpRewardToken_){
        uniswapV2Pair = uniswapV2Pair_;
        lpRewardToken = lpRewardToken_;
    }

    function resetLPRewardLastSendTime() public onlyOwner {
        LPRewardLastSendTime = 0;
    }

    // LP分红发放
    function process(uint256 gas) external onlyOwner {
        uint256 shareholderCount = shareholders.length;	

        if(shareholderCount == 0) return;
        uint256 nowbanance = IERC20(lpRewardToken).balanceOf(address(this));

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                LPRewardLastSendTime = block.timestamp;
                return;
            }

            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());
            if( amount == 0) {
                currentIndex++;
                iterations++;
                return;
            }
            if(IERC20(lpRewardToken).balanceOf(address(this))  < amount ) return;
            IERC20(lpRewardToken).transfer(shareholders[currentIndex], amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    // 根据条件自动将交易账户加入、退出流动性分红
    function setShare(address shareholder) external onlyOwner {
        if(_updated[shareholder] ){      
            if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);           
            return;  
        }
        if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
        addShareholder(shareholder);	
        _updated[shareholder] = true;
        
    }
    function quitShare(address shareholder) internal {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function withdrawToken(
        address coin,
        address receiver,
        uint256 amount
    ) public onlyOwner {
        if (address(0) == coin) {
            payable(receiver).transfer(amount);
        } else {
            IERC20 coinContract = IERC20(coin);
            coinContract.transfer(receiver, amount);
        }
    }
    
}


contract Croatia is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public bep20usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public marketingAddress = 0xeeFe7EAFBe5c16cA2a2d6823BaD02e72a2B09a83;

    uint256 public buyRewardFee = 200;
    uint256 public sellRewardFee = 100;
    uint256 public sellMarketingFee = 100;

    uint256 public MarketingFeeAmount;
    uint256 public LpRewardAmount;
    
    uint256 public launchedAtTime = 0;
    uint256 public _protectTime = 1 minutes;

    TokenHelper public tokenHelper;
    uint256 public minPeriod = 24 hours;
    uint256 public swapTokensAtAmount;
    uint256 distributorGas = 500000;

    bool private swapping;
    address private fromAddress;
    address private toAddress;
    mapping(address => bool) public blackList;
    mapping(address => bool) public _isExcludedFromFees;
    mapping (address => bool) public isDividendExempt;

    constructor() ERC20("CrO", "CRO") {
        uint256 totalSupply = 100000000 * (10**18);
        swapTokensAtAmount = totalSupply.div(10**5);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), bep20usdt);

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        tokenHelper = new TokenHelper(_uniswapV2Pair, bep20usdt);

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[marketingAddress] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(tokenHelper)] = true;

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(tokenHelper)] = true;

        _mint(owner(), totalSupply);
    }

    receive() external payable {}

    function withdrawToken(
        address coin,
        address receiver,
        uint256 amount
    ) public onlyOwner {
        if (address(0) == coin) {
            payable(receiver).transfer(amount);
        } else {
            IERC20 coinContract = IERC20(coin);
            coinContract.transfer(receiver, amount);
        }
    }

    function withdrawHelperToken(
        address coin,
        address receiver,
        uint256 amount
    ) public onlyOwner {
        tokenHelper.withdrawToken(coin, receiver, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!blackList[from] && !blackList[to], "ERC20: banned address");
        if(amount == 0) { super._transfer(from, to, 0); return;}

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= MarketingFeeAmount.add(LpRewardAmount);
        if( canSwap &&
            !swapping &&
            from != uniswapV2Pair &&
            from != owner() &&
            to != owner()
        ) {
            swapping = true;
            if(MarketingFeeAmount > 0){
                swapToken(MarketingFeeAmount, marketingAddress);
                MarketingFeeAmount = 0;
            }
            if(LpRewardAmount > 0){
                swapToken(LpRewardAmount, address(tokenHelper));
                LpRewardAmount = 0;
            }
            swapping = false;
        }

        bool takeFee = !swapping;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to] || from == address(uniswapV2Router)) {
            takeFee = false;
        }

        if (takeFee) {
            if (from == uniswapV2Pair) {
                amount = takeBuyFee(from, amount);
            } else if (to == uniswapV2Pair) {
                amount = takeSellFee(from, amount);
            } else {
            }
        }

        super._transfer(from, to, amount);

        if(fromAddress == address(0) ) fromAddress = from;
        if(toAddress == address(0) ) toAddress = to;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair )   try tokenHelper.setShare(fromAddress) {} catch {}
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) try tokenHelper.setShare(toAddress) {} catch {}
        fromAddress = from;
        toAddress = to;  

        if (!swapping && 
            from != owner() &&
            to != owner() &&
            from !=address(this) &&
            tokenHelper.LPRewardLastSendTime().add(minPeriod) <= block.timestamp
        ) {
            try tokenHelper.process(distributorGas) {} catch {}    
        }

        if (!launched()) {
            launch();
        }

        if (takeFee) {    
            launchCheck(from, to);
        }
    }

    function takeBuyFee(address from, uint256 amount) private returns (uint256 amountAfter) {
        amountAfter = amount;

        uint256 BFee = amount.mul(buyRewardFee).div(10000);
        if (BFee > 0) {
            super._transfer(from, address(this), BFee);
            LpRewardAmount = LpRewardAmount.add(BFee);
            amountAfter = amountAfter.sub(BFee);
        }
        
    }

    function takeSellFee(address from, uint256 amount) private returns (uint256 amountAfter) {
        amountAfter = amount;

        uint256 SFee = amount.mul(sellRewardFee).div(10000);
        if (SFee > 0) {
            super._transfer(from, address(this), SFee);
            LpRewardAmount = LpRewardAmount.add(SFee);
            amountAfter = amountAfter.sub(SFee);
        }

        uint256 MFee = amount.mul(sellMarketingFee).div(10000);
        if (MFee > 0) {
            super._transfer(from, marketingAddress, MFee);
            MarketingFeeAmount = MarketingFeeAmount.add(MFee);
            amountAfter = amountAfter.sub(MFee);
        }
    }


    function launched() internal view returns (bool) {
        return launchedAtTime != 0;
    }

    function launch() internal {
        launchedAtTime = block.timestamp;
    }

    function launchCheck(address sender, address recipient) internal {
        if (block.timestamp > launchedAtTime + _protectTime) {
            return;
        }
        if (
            sender == address(uniswapV2Router) ||
            sender == address(uniswapV2Pair)
        ) {
            blackList[recipient] = true;
        }
        if (
            recipient == address(uniswapV2Router) ||
            recipient == address(uniswapV2Pair)
        ) {
            blackList[sender] = true;
        }
    }

    function swapToken(uint256 tokenAmount, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = bep20usdt;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    
    }

    //###########################################################################
    //#                                                                         #
    //#                              Setter                                     #
    //#                                                                         #
    //###########################################################################

    function updateDividendExempt(address account, bool dividend) public onlyOwner {
        isDividendExempt[account] = dividend;
    }
    
    function updateBlackList(address account, bool isBlack) public onlyOwner {
        if (blackList[account] != isBlack) {
            blackList[account] = isBlack;
        }
    }

    function updateBlackListBatch(address[] calldata accounts, bool isBlack) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            blackList[accounts[i]] = isBlack;
        }
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;
    }

    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function updateLaunchedAtTime(uint256 time_) public onlyOwner {
        launchedAtTime = time_;
    }

    function updateProtectTime(uint256 duration_) public onlyOwner {
        _protectTime = duration_;
    }

    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount;
    }

    function resetLPRewardLastSendTime() public onlyOwner {
        tokenHelper.resetLPRewardLastSendTime();
    }

    function updateDistributorGas(uint256 newValue) public onlyOwner {
        require(newValue >= 100000 && newValue <= 500000, "distributorGas must be between 200,000 and 500,000");
        require(newValue != distributorGas, "Cannot update distributorGas to same value");
        distributorGas = newValue;
    }

}