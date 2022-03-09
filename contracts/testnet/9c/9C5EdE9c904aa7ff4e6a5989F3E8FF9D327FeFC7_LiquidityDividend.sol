/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

pragma solidity =0.6.6;


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

// erc20
interface IERC20 {
    function balanceOf(address _address) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// safe math
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Math error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "Math error");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Math error");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
}


// safe transfer
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// BTM初始化
interface ILiquidityDividend {
    function initialization(address _btmAddress) external;
}


// owner
contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, 'Liquidity: owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// 回流收币合约
contract LiquidityDividend is ILiquidityDividend, Ownable {
    using SafeMath for uint256;

    address public routerAddress;    // 路由合约地址
    address public factoryAddress;   // 工厂合约地址
    address public btmAddress;       // BTM合约地址
    address public wbnbAddress;      // WBNB合约地址
    address public btcAddress;       // WBNB合约地址

    // 构造函数
    constructor(
        address _owner,
        address _routerAddress,
        address _factoryAddress,
        address _wbnbAddress,
        address _btcAddress
    ) public {
        owner = _owner;
        routerAddress = _routerAddress;
        factoryAddress = _factoryAddress;
        wbnbAddress = _wbnbAddress;
        btcAddress = _btcAddress;
    }

    function initialization(address _btmAddress) public override {
        require(btmAddress == address(0), 'Liquidity: initialization error'); // 必须当前是没有btm地址的
        btmAddress = _btmAddress;
    }

    // 设置BTM地址
    function setBtmAddress(address _btmAddress) public onlyOwner {
        if(_btmAddress != address(0)) {
            btmAddress = _btmAddress;
        }
    }

    function withdraw(address _token, address _to, uint256 _value) public onlyOwner {
        TransferHelper.safeTransfer(_token, _to, _value);
    }

    function withdrawAllBtc() public onlyOwner {
        uint256 _btcBalance = IERC20(btcAddress).balanceOf(address(this));
        TransferHelper.safeTransfer(btcAddress, owner, _btcBalance);
    }

    function withdrawAllLp() public onlyOwner {
        address _pairAddress = IUniswapV2Factory(factoryAddress).getPair(wbnbAddress, btmAddress);
        uint256 _lpBalance = IERC20(_pairAddress).balanceOf(address(this));
        TransferHelper.safeTransfer(_pairAddress, owner, _lpBalance);
    }

    // swap LP to address
    function swapLpToOwner() public onlyOwner {
        _btcSwapLP(owner);
    }
    function swapLpToThis() public onlyOwner {
        _btcSwapLP(address(this));
    }

    function _btcSwapLP(address _to) private {
        uint256 _btcBalance = IERC20(btcAddress).balanceOf(address(this));
        if(_btcBalance == 0) return;
        // btc-wbnb
        address[] memory _path = new address[](2);
        _path[0] = btcAddress;
        _path[1] = wbnbAddress;
        // 把btc授权给路由合约。
        TransferHelper.safeApprove(btcAddress, routerAddress, _btcBalance);
        IUniswapV2Router02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _btcBalance,
            0, // 接受任意金额的兑换
            _path,
            address(this),
            block.timestamp + 300);
        
        uint256 _wbnbBalance = IERC20(wbnbAddress).balanceOf(address(this)); // 兑换之后的wbnb
        uint256 _swapBtmAmount = _wbnbBalance.div(2); // 一半兑换成btm
        // wbnb-btm
        address[] memory _path2 = new address[](2);
        _path2[0] = wbnbAddress;
        _path2[1] = btmAddress;
        // 把wbnb授权给路由合约。
        TransferHelper.safeApprove(wbnbAddress, routerAddress, _swapBtmAmount);
        IUniswapV2Router02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _swapBtmAmount,
            0, // 接受任意金额的兑换
            _path2,
            address(this),
            block.timestamp + 300);

        // 兑换成功, 添加流动性
        uint256 _wbnbBalance2 = IERC20(wbnbAddress).balanceOf(address(this));
        uint256 _btmBalance2 = IERC20(btmAddress).balanceOf(address(this));
        TransferHelper.safeApprove(wbnbAddress, routerAddress, _wbnbBalance2);
        TransferHelper.safeApprove(btmAddress, routerAddress, _btmBalance2);
        IUniswapV2Router02(routerAddress).addLiquidity(
            wbnbAddress,
            btmAddress,
            _wbnbBalance2,
            _btmBalance2,
            0,
            0,
            _to,
            block.timestamp + 300
        );
    }



}