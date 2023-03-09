/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

abstract contract ERC20 {}

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

contract Wallet {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function withdraw(address token) external {
        assert(msg.sender == owner);
        IERC20(token).transfer(
            msg.sender,
            IERC20(token).balanceOf(address(this))
        );
    }
}

abstract contract Owned {
    event OwnerUpdated(address indexed user, address indexed newOwner);

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    constructor() {
        owner = msg.sender;

        emit OwnerUpdated(address(0), owner);
    }

    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}

interface IUniswapV2Router01 {
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
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

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

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

/**
 * @title Rebase Token
 */
contract SWP is Owned {

    event RebaseDone(uint256 delta, bool excludePair);

    address private constant _DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 private constant _ONE_TOKENS = 1e6;

    uint256 private constant _MIN_SUPPLY = 1000 * _ONE_TOKENS;

    IERC20 public BASE_TOKEN;
    IUniswapV2Router02 public SWAP_ROUTER;

    // work for swap token to usdt.
    Wallet private _wallet;

    // current token-basetoken pair in swap
    address public pairToken;

    // Allow transfer before running.
    mapping(address => bool) public whitelists;

    //加入白名单长度
    uint256 public whiteCount = 0;
    //记录变动过的白名单列表
    mapping(uint256 => address) public  recordWhiteList;

    //燃烧比例 0.3% （千分位）
    uint256 public burnRate = 3;
    //下次燃烧时间
    uint256 public nextBurnTime;

    uint256 public _addTime =1 hours;
    // uint256 public _addTime =10 minutes;

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    uint256 public constant TOTAL_SUPPLY = 10000 * 1e6;

    string public name;

    string public symbol;

    uint8 public decimals;

    uint256 public totalSupply;

    mapping(address => uint256) internal _balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    function _addBalance(address acct, uint256 amount) private {
        uint256 amountIn = (amount * TOTAL_SUPPLY) / totalSupply;
    unchecked {
        // handle this precision problem
        uint256 amountOut = (amountIn * totalSupply) / TOTAL_SUPPLY;
        if (amountOut < amount) {
            amountIn += 1;
        }
    }

        _balanceOf[acct] += amountIn;
    }

    function _subBalance(address acct, uint256 amount) private {
        amount = (amount * TOTAL_SUPPLY) / totalSupply;
        _balanceOf[acct] -= amount;
    }

    function balanceOf(address acct) public view returns (uint256) {
        return ((_balanceOf[acct] * totalSupply) / TOTAL_SUPPLY);
    }

    function approve(address spender, uint256 amount)
    public
    virtual
    returns (bool)
    {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount)
    public
    virtual
    returns (bool)
    {
        _beforeTransfer(msg.sender, to, amount);
        uint256 actual = amount;
        _subBalance(msg.sender, amount);
        _addBalance(to, actual);
        _afterTransfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, actual);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max)
            allowance[from][msg.sender] = allowed - amount;

        _beforeTransfer(from, to, amount);
        uint256 actual = amount;
        _subBalance(from, amount);
        _addBalance(to, actual);
        _afterTransfer(msg.sender, to, amount);
        emit Transfer(from, to, actual);
        return true;
    }

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
    unchecked {
        _balanceOf[to] += amount;
    }

        emit Transfer(address(0), to, amount);
    }

    function _burn(uint256 amount) internal virtual {
        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
    unchecked {
        totalSupply -= amount;
    }

        emit Transfer(address(0), address(0), amount);
    }

    constructor(bool prod) {
        name = "SWP";
        symbol = "SWP";
        decimals = 6;

        _wallet = new Wallet();
        if (prod) {
            //主网
            BASE_TOKEN = IERC20(0x55d398326f99059fF775485246999027B3197955);
            SWAP_ROUTER = IUniswapV2Router02(
                0x10ED43C718714eb63d5aA57B78B54704E256024E
            );
        } else {
            // 测试网
            BASE_TOKEN = IERC20(0x6B0AA926f4Bd81669aE269d8FE0124F5060A6aa9);
            //  router
            SWAP_ROUTER = IUniswapV2Router02(
                0xD99D1c33F9fC3444f8101754aBC46c52416550D1
            );
        }

        IUniswapV2Factory factory = IUniswapV2Factory(SWAP_ROUTER.factory());

        pairToken = factory.createPair(address(this), address(BASE_TOKEN));

        _addWhiteList(pairToken);

        nextBurnTime = block.timestamp + _addTime;
        // mint
        _mint(msg.sender, TOTAL_SUPPLY);

        // approve once.
        approveForSwap();
    }

    function _addWhiteList(address _addr) private {
        whitelists[_addr] = true;
        recordWhiteList[whiteCount] = _addr;
        whiteCount++;
    }

    /**
     * @dev approve once to save gas.
     * this function can be called by everyone.
     */
    function approveForSwap() public {
        allowance[address(this)][address(SWAP_ROUTER)] = type(uint256).max;
        BASE_TOKEN.approve(address(SWAP_ROUTER), type(uint256).max);
    }

    function rebase() private {
        if (nextBurnTime <= block.timestamp && totalSupply > _MIN_SUPPLY) {
            uint256 delta = (totalSupply * burnRate) / 1000;
            uint256 oldSupply = totalSupply;

            if (oldSupply - delta < _MIN_SUPPLY) {
                delta = oldSupply - _MIN_SUPPLY;
            }

            _burn(delta);
            //白名单不燃烧
            for (uint256 i = 0; i < whiteCount; i++) {
                if (whitelists[recordWhiteList[i]]) {
                    // keep the pair balance to remain the same after rebaseing
                    uint256 b = _balanceOf[recordWhiteList[i]];
                    // append = _balance[pair] * ( oldSupply / newSupply -1 )
                    _balanceOf[recordWhiteList[i]] =
                    (b * oldSupply) /
                    totalSupply;
                }
            }
            nextBurnTime = block.timestamp + _addTime;
            emit RebaseDone(delta, true);
            IUniswapV2Pair(pairToken).sync();
        }
    }

    function _beforeTransfer(
        address from,
        address to,
        uint256 amount
    ) internal view {
        require(to != address(0), "refuse");
    }

    function _afterTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        rebase();
    }

    function setWhitelists(address[] calldata accts, bool added)
    external
    onlyOwner
    {
        for (uint256 i = 0; i < accts.length; i++) {
            if (added) {
                _addWhiteList(accts[i]);
            } else {
                whitelists[accts[i]] = added;
            }
        }
    }
}