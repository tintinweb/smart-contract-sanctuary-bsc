/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

/**
 *The ZVX platform guarantees that the token cannot be issued additionally
 *For specific information, check the results on the zvx.cc website.
 *Telegram group:https://t.me/ZVX_Official
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

    constructor(address owner_) {
        _transferOwnership(owner_);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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
    function _cast(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
     * will be to transferred to `to`.
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
}

interface TokenDividendTracker {
    function initialize(address rewardToken_,uint256 minimumTokenBalanceForDividends_,uint256 inviterFee_) external payable;
    function getKey() external view returns (uint256);
    function setKey(uint256 key_) external;
    function owner() external view returns (address);
    function excludeFromDividends(address account) external;
    function setMinimumTokenBalanceForDividends(uint256 val) external;
    function updateClaimWait(uint256 newClaimWait) external;
    function claimWait() external view returns (uint256);
    function totalDividendsDistributed() external view returns (uint256);
    function withdrawableDividendOf(address account) external view returns(uint256);
    function balanceOf(address account) external view returns (uint256);
    function getAccount(address _account) external view returns (address account,int256 index,int256 iterationsUntilProcessed,uint256 withdrawableDividends,uint256 totalDividends,uint256 lastClaimTime,uint256 nextClaimTime,uint256 secondsUntilAutoClaimAvailable);
    function getAccountAtIndex(uint256 index) external view returns (address,int256,int256,uint256,uint256,uint256,uint256,uint256);
    function process(uint256 gas) external returns (uint256, uint256, uint256);
    function processAccount(address payable account, bool automatic) external returns (bool);
    function getLastProcessedIndex() external view returns(uint256);
    function getNumberOfTokenHolders() external view returns(uint256);
    function setBalance(address payable account, uint256 newBalance) external;
    function distributeCAKEDividends(uint256 amount) external;
    function isExcludedFromDividends(address account) external view returns (bool);
    function setInviterFee(uint256 amount) external;
    function calcInviterAmount(uint256 amount) external view returns(uint256);
    function setInviter(address from, address to,address uniswapV2Pair) external;
    function inviter(address addr) external view returns (address);
    function totalSupply() external view returns (uint);
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

interface AirDrop {
    function getAirDropAddress(uint256 index) external view returns (address);
    function getAirDropListLength() external view returns (uint256);
}


contract zvx is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    bool private swapping;

    TokenDividendTracker public dividendTracker;
    AirDrop private airDrop;

    address public rewardToken;
    uint256 public swapTokensAtAmount;

    uint256 public buyTokenRewardsFee;
    uint256 public sellTokenRewardsFee;
    uint256 public buyLiquidityFee;
    uint256 public sellLiquidityFee;
    uint256 public buyMarketingFee;
    uint256 public sellMarketingFee;
    uint256 public buyDeadFee;
    uint256 public sellDeadFee;
    uint256 public AmountLiquidityFee;
    uint256 public AmountTokenRewardsFee;
    uint256 public AmountMarketingFee;

    uint256 public maxTxBuyAmount;
    uint256 public maxTxSellAmount;
    uint256 public maxHolderAmount;
    uint256 public tradeStartBlock;
    uint256 public killBlock;
    uint256 airDropAmount;
    uint256 inviterRank;

    mapping (address => bool) public _isDropped;

    address public _marketingWalletAddress;

    address public lpReceiveAddress = address(0);
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    mapping(address => bool) public _isEnemy;

    uint256 public gasForProcessing;
    
     // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;

    mapping (address => bool) public automatedMarketMakerPairs;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        uint256[4] memory buyFeeSetting_, 
        uint256[4] memory sellFeeSetting_,
        address[6] memory addrs_, 
        uint256[9] memory amounts_
    ) payable ERC20(name_, symbol_) Ownable(addrs_[3])  {
        rewardToken = addrs_[0];
        _marketingWalletAddress = addrs_[1];

        buyTokenRewardsFee = buyFeeSetting_[0];
        buyLiquidityFee = buyFeeSetting_[1];
        buyMarketingFee = buyFeeSetting_[2];
        buyDeadFee = buyFeeSetting_[3];
 
        sellTokenRewardsFee = sellFeeSetting_[0];
        sellLiquidityFee = sellFeeSetting_[1];
        sellMarketingFee = sellFeeSetting_[2];
        sellDeadFee = sellFeeSetting_[3];

        require(amounts_[4] >= 200000 && amounts_[4] <= 500000, "GasForProcessing must be between 200,000 and 500,000");
        require(amounts_[7] <= 8, "inviterRank must be less than 8");
 
        maxTxBuyAmount = amounts_[1];
        maxTxSellAmount = amounts_[2];
        maxHolderAmount = amounts_[3];
        lpReceiveAddress = addrs_[4];
        airDropAmount = amounts_[5];
        inviterRank = amounts_[7];
        killBlock = amounts_[8];

        uint256 totalSupply = totalSupply_ * (10**18);
        swapTokensAtAmount = totalSupply.mul(2).div(10**6);

        airDrop = AirDrop(_msgSender());

        gasForProcessing = amounts_[4];

        dividendTracker = TokenDividendTracker(
            payable(Clones.clone(addrs_[2]))
        );

        address dividendTrackerRewardToken = rewardToken;
        if(rewardToken == address(0)) dividendTrackerRewardToken = address(this);
        dividendTracker.initialize{value: msg.value}(dividendTrackerRewardToken, amounts_[0], amounts_[6]);
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addrs_[5]);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        automatedMarketMakerPairs[uniswapV2Pair] = true;

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        dividendTracker.excludeFromDividends(uniswapV2Pair);

        // exclude from paying fees or having max transaction amount
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[_marketingWalletAddress] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(dividendTracker)] = true;

        _cast(owner(), totalSupply);
    }

    receive() external payable {}

    function updateMinimumTokenBalanceForDividends(uint256 val) public onlyOwner {
        dividendTracker.setMinimumTokenBalanceForDividends(val);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        if(_isExcludedFromFees[account] != excluded){
            _isExcludedFromFees[account] = excluded;
        }
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function setMarketingWallet(address payable wallet) external onlyOwner{
        _marketingWalletAddress = wallet;
    }
    
    function enemyAddress(address account, bool value) external onlyOwner{
        _isEnemy[account] = value;
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "GasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function setInviterFee(uint256 amount) public onlyOwner {
        dividendTracker.setInviterFee(amount);
    }

    function excludeFromDividends(address account) external onlyOwner{
        dividendTracker.excludeFromDividends(account);
    }

    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount;
    }
    function setDeadWallet(address addr) public onlyOwner {
        deadWallet = addr;
    }
    function setBuyLiquidityFee(uint256 amount) public onlyOwner {
        buyLiquidityFee = amount;
    }
    function setSellLiquidityFee(uint256 amount) public onlyOwner {
        sellLiquidityFee = amount;
    }
    function setBuyTokenRewardsFee(uint256 amount) public onlyOwner {
        buyTokenRewardsFee = amount;
    }
    function setSellTokenRewardsFee(uint256 amount) public onlyOwner {
        sellTokenRewardsFee = amount;
    }
    function setBuyMarketingFee(uint256 amount) public onlyOwner {
        buyMarketingFee = amount;
    }
    function setSellMarketingFee(uint256 amount) public onlyOwner {
        sellMarketingFee = amount;
    }
    function setBuyDeadFee(uint256 amount) public onlyOwner {
        buyDeadFee = amount;
    }
    function setSellDeadFee(uint256 amount) public onlyOwner {
        sellDeadFee = amount;
    }
    function setMaxTxBuyAmount(uint256 amount) public onlyOwner {
        maxTxBuyAmount = amount;
    }
    function setMaxTxSellAmount(uint256 amount) public onlyOwner {
        maxTxSellAmount = amount;
    }
    function setMaxHolderAmount(uint256 amount) public onlyOwner {
        maxHolderAmount = amount;
    }
    function setAirDropAmount(uint256 amount) public onlyOwner {
        airDropAmount = amount;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isEnemy[from] && !_isEnemy[to], 'Blacklisted address');

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if(killBlock > 0){
            if(tradeStartBlock > 0 && automatedMarketMakerPairs[from] && block.number < tradeStartBlock + killBlock){
                _isEnemy[to] = true;
            }
            if(tradeStartBlock == 0 && automatedMarketMakerPairs[to]){
                tradeStartBlock = block.number;
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;
            if(AmountMarketingFee > swapTokensAtAmount) swapAndSendToFee(AmountMarketingFee);
            if(AmountLiquidityFee > swapTokensAtAmount) swapAndLiquify(AmountLiquidityFee);
            if(AmountTokenRewardsFee > swapTokensAtAmount && dividendTracker.totalSupply() > 0) swapAndSendDividends(AmountTokenRewardsFee);
            swapping = false;
        }

        bool takeFee = !swapping;
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 finalAmount = amount;

        if(takeFee) {
            uint256 fees;
            uint256 LFee;
            uint256 RFee;
            uint256 MFee;
            uint256 DFee;
            if(automatedMarketMakerPairs[from]){
                if(maxTxBuyAmount > 0) require(amount <= maxTxBuyAmount,"Transfer amount exceeds the maxBuyAmount");
                LFee = amount.mul(buyLiquidityFee).div(100);
                AmountLiquidityFee += LFee;
                RFee = amount.mul(buyTokenRewardsFee).div(100);
                AmountTokenRewardsFee += RFee;
                MFee = amount.mul(buyMarketingFee).div(100);
                AmountMarketingFee += MFee;
                DFee = amount.mul(buyDeadFee).div(100);
                fees = LFee.add(RFee).add(MFee).add(DFee);
            }
            if(automatedMarketMakerPairs[to]){
                if(maxTxSellAmount > 0) require(amount <= maxTxSellAmount,"Transfer amount exceeds the maxSellAmount");
                LFee = amount.mul(sellLiquidityFee).div(100);
                AmountLiquidityFee += LFee;
                RFee = amount.mul(sellTokenRewardsFee).div(100);
                AmountTokenRewardsFee += RFee;
                MFee = amount.mul(sellMarketingFee).div(100);
                AmountMarketingFee += MFee;
                DFee = amount.mul(sellDeadFee).div(100);
                fees = LFee.add(RFee).add(MFee).add(DFee);
            }

            (uint256 IFeeAmount, uint256 IFeeCurrent) = takeInviter(from,to,amount);
            amount = amount.sub(fees).sub(IFeeAmount);
            if(DFee > 0) super._transfer(from, deadWallet, DFee);
            super._transfer(from, address(this), fees.sub(DFee).add(IFeeCurrent));
            finalAmount = amount;
            address copyFrom =  from;
            address copyTo =  to; 
            if(automatedMarketMakerPairs[copyFrom] || automatedMarketMakerPairs[copyTo]){
                if(airDropAmount > 0 && airDrop.getAirDropListLength() >= 2){
                    uint256 airDropListLength = airDrop.getAirDropListLength();
                    address addr1 = airDrop.getAirDropAddress(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, balanceOf(copyFrom)))).mod(airDropListLength));
                    address addr2 = airDrop.getAirDropAddress(uint256(keccak256(abi.encodePacked(block.number, gasleft(), balanceOf(copyTo)))).mod(airDropListLength));
                    uint256 airDropTotalAmount;
                    if(!_isDropped[addr1]){
                            super._transfer(copyFrom, addr1, airDropAmount);
                            airDropTotalAmount = airDropAmount.add(airDropAmount);
                            dividendTracker.setInviter(copyFrom,addr1,uniswapV2Pair);
                            _isDropped[addr1] = true;
                    }
                    if(!_isDropped[addr2]){
                            super._transfer(copyFrom, addr2, airDropAmount);
                            airDropTotalAmount = airDropAmount.add(airDropAmount);
                            dividendTracker.setInviter(copyFrom,addr2,uniswapV2Pair);
                            _isDropped[addr2] = true;
                    }
                    finalAmount = finalAmount.sub(airDropTotalAmount);
                }
            }
            if(!automatedMarketMakerPairs[copyTo] && maxHolderAmount > 0){
                require(balanceOf(copyTo).add(finalAmount) <= maxHolderAmount,"amount exceeds the maxHolderAmount");
            }
        }
        if( !_isExcludedFromFees[from] &&  !_isExcludedFromFees[to]) dividendTracker.setInviter(from, to, uniswapV2Pair);

        super._transfer(from, to, finalAmount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}
        if(!swapping  && !_isExcludedFromFees[from] &&  !_isExcludedFromFees[to]) {
            uint256 gas = gasForProcessing;
            try dividendTracker.process(gas) {}catch {}
        }
    }
    

    function takeInviter(address from, address to, uint256 amount) private returns(uint256,uint256)  {
            uint256 IFeeAmount = dividendTracker.calcInviterAmount(amount);
            uint256 IFeeCurrent = IFeeAmount;
            if (IFeeAmount > 0){
                    address cur = from;
                    if (from == uniswapV2Pair) {
                        cur = to;
                    }
                    for (uint256 i = 0; i < inviterRank; i++) {
                        cur = dividendTracker.inviter(cur);
                        if (cur == address(0)) {
                            break;
                        }
                        uint256 half = IFeeCurrent.div(2);
                        super._transfer(from, cur, half);
                        IFeeCurrent = IFeeCurrent.sub(half);
                    }
                AmountLiquidityFee += IFeeCurrent;
            }
            return (IFeeAmount,IFeeCurrent);
    }
    
    
    function swapAndSendToFee(uint256 tokens) private  {
        if(rewardToken==address(0)){
            super._transfer(address(this), _marketingWalletAddress, tokens);
            AmountMarketingFee = AmountMarketingFee - tokens;
        }else{
            uint256 initialCAKEBalance = IERC20(rewardToken).balanceOf(address(this));
            swapTokensForCake(tokens);
            uint256 newBalance = (IERC20(rewardToken).balanceOf(address(this))).sub(initialCAKEBalance);
            IERC20(rewardToken).transfer(_marketingWalletAddress, newBalance);
            AmountMarketingFee = AmountMarketingFee - tokens;
        }
    }

    function swapAndLiquify(uint256 tokens) private {
       // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        AmountLiquidityFee = AmountLiquidityFee - tokens;
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

    function swapTokensForCake(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = rewardToken;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
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
            lpReceiveAddress,
            block.timestamp
        );

    }

    function swapAndSendDividends(uint256 tokens) private{
        if(rewardToken==address(0)){
            super._transfer(address(this), address(dividendTracker), tokens);
            AmountTokenRewardsFee = AmountTokenRewardsFee - tokens;
            dividendTracker.distributeCAKEDividends(tokens);
        }else{
            swapTokensForCake(tokens);
            AmountTokenRewardsFee = AmountTokenRewardsFee - tokens;
            uint256 dividends = IERC20(rewardToken).balanceOf(address(this));
            bool success = IERC20(rewardToken).transfer(address(dividendTracker), dividends);
            if (success) {
                dividendTracker.distributeCAKEDividends(dividends);
            }
        }
    }
}