/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;


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


// owner
contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, 'BuyTracker: owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// 提供的接口
interface IBuyTracker {
    function initBuyTracker(address _Ettdao) external;
    function backLPAndBurn() external;
}


// 主合约
contract BuyTracker is IBuyTracker, Ownable {
    address public Factory; // 工厂合约地址
    address public Router;  // 路由合约地址
    address public Ettdao;  // ETTDAO合约地址
    address public Usdt;    // USDT合约地址
    address public Ett;     // ETT合约地址

    // 累积到一定的数量才兑换销毁
    uint256 public amountFalg = 500 * (10**18);


    // 构造函数
    constructor (
        address _Factory,
        address _Router,
        address _Usdt,
        address _Ett
    ) {
        owner = msg.sender;

        Factory = _Factory;
        Router = _Router;
        Usdt = _Usdt;
        Ett = _Ett;

        // 授权最大值给路由合约, USDT, ETT,
        TransferHelper.safeApprove(Usdt, Router, type(uint256).max);
        TransferHelper.safeApprove(Ett, Router, type(uint256).max);
    }

    // 初始化。只能调用一次, 设置完将不能更改
    function initBuyTracker(address _Ettdao) external override {
        require(_Ettdao != address(0), "0 address error");
        if(Ettdao == address(0)) Ettdao = _Ettdao;
    }

    // 取出token
    function takeToken(address _token, address _to , uint256 _value) external onlyOwner {
        require(_to != address(0), "zero address error");
        require(_value > 0, "value zero error");
        TransferHelper.safeTransfer(_token, _to, _value);
    }

    // 不能空投USDT和ETT, 把钱转进合约以后, 会被兑换销毁掉。
    // 批量转代币, 从合约里面扣币, 一样的数量
    // 参数1: Token地址
    // 参数2: 接收者地址数组equal
    // 参数3: 每个地址接收的数量
    function tranferEq(address _token, address[] memory _addr, uint256 _value) external onlyOwner {
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransfer(_token, _addr[i], _value);
        }
    }

    // 不能空投USDT和ETT, 把钱转进合约以后, 会被兑换销毁掉。
    // 批量转代币, 从合约里面扣币, 不一样的数量
    // 参数1: Token地址
    // 参数2: 接收者地址数组; [0x123...,0x234...,...](区块链浏览器格式)
    // 参数3: 数量数组; [1,2,...](区块链浏览器格式)
    function tranferNeq(address _token, address[] memory _addr, uint256[] memory _value) external onlyOwner {
        require(_addr.length == _value.length, "length error");
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransfer(_token, _addr[i], _value[i]);
        }
    }

    // 设置多少数量才可以进行回购销毁
    function setAmountFalg(uint256 _amountFalg) external onlyOwner {
        require(_amountFalg > 0, "value zero error");
        amountFalg = _amountFalg;
    }

    // 把USDT的一半兑换成ETT, 得到LP打入0地址
    function backLPAndBurn() external override {
        // 任何地址都可以调用其实
        uint256 _usdtBalance = IERC20(Usdt).balanceOf(address(this));
        
        if(_usdtBalance >= amountFalg) {
            uint256 _usdtHalf = SafeMath.div(_usdtBalance, 2);
            address[] memory _path = new address[](2); // 兑换
            _path[0] = Usdt;
            _path[1] = Ett;
      
            // 开始兑换
            IUniswapV2Router02(Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _usdtHalf,
            0,
            _path,
            address(this),
            block.timestamp);
            // 开始添加LP销毁
            uint256 _usdtBalance2 = IERC20(Usdt).balanceOf(address(this));
            uint256 _ettBalance2= IERC20(Ett).balanceOf(address(this));
            IUniswapV2Router02(Router).addLiquidity(
                Usdt,
                Ett,
                _usdtBalance2,
                _ettBalance2,
                0,
                0,
                address(0),
                block.timestamp
            );

        }
    }



}