// SPDX-License-Identifier: UNLICENSED


pragma solidity 0.6.12;

import "./BEP20.sol";

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

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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

contract HMCToken is BEP20, Ownable {
    using SafeMath for uint256;

    uint public feePercent = 1000;

    uint public Fees0 = 30;
    uint public Fees1 = 10;
    uint public Fees2 = 10;
    uint public Fees3 = 10;
    uint public Fees4 = 20;

    uint public Fees5 = 40;
    
    address public receive0 = address(0x16A76fb87C017e4882BABe6f821B12E7BA3B79ed);
    address public receive1 = address(0xd29adb16E3e4B06417EC9b6fd52bD4B9f20BC42b);
    address public receive2 = address(0x71fa28727e6C0ea44d553b9A2798E7A8a32af44E);
    address public receive3 = address(0x4680eacB5a20c4864555d6F9e51e9fA7D5c066D6);
    address public receive4 = address(0x0914A1000E65a588a3d0911Dc2b827A49E88fD9F);
    address public receive5 = address(0x2D71ebBa6F8464c8e09aF953CdF9A3BcDd614f9B);



    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapPair;

    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);

    mapping(address => bool) public whiteList;

    constructor(string memory name, string memory symbol,uint8 decimals, uint256 _total) BEP20(name, symbol, decimals) public {
        //dev
        // _mint(msg.sender, _total * (10 ** uint256(decimals)));
        //prod
        _mint(address(0x6BC0B6404a0D078F2B753222293157a15812ef07), _total * (10 ** uint256(decimals)));

        //poly
        // uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // address usdt = address(0x55d398326f99059fF775485246999027B3197955);

        
        //prod
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address usdt = address(0x55d398326f99059fF775485246999027B3197955);
        //rinkey
        // uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        // address usdt = address(0x10681E51eA76b0F66fe6a9433a4326Fd2B5c84c5);
        
        //bsctest
        // uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        // address usdt = address(0x10681E51eA76b0F66fe6a9433a4326Fd2B5c84c5);
        
        uniswapPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), usdt);
    }

    function setWhiteList(address _user) public onlyOwner returns (bool) {
        whiteList[_user] = !whiteList[_user];
        return true;
    }

    function _beforeTokenTransfer( address sender, address recipient, uint256 _amount )internal override returns (uint256){
        uint256 fee;

        if(whiteList[sender] == true || whiteList[recipient] == true) {
            return _amount;
        }

        //购买 卖出
        if(sender == uniswapPair || recipient == uniswapPair) {
            // 3%
            fee = _amount.mul(Fees0).div(feePercent);
            _balances[sender] = _balances[sender].sub(fee, 'BEP20: transfer amount exceeds balance');
            _balances[receive0] = _balances[receive0].add(fee);
            _amount = _amount.sub(fee);
            // 1%
            fee = _amount.mul(Fees1).div(feePercent);
            _balances[sender] = _balances[sender].sub(fee, 'BEP20: transfer amount exceeds balance');
            _balances[receive1] = _balances[receive1].add(fee);
            _amount = _amount.sub(fee);
            // 1%
            fee = _amount.mul(Fees2).div(feePercent);
            _balances[sender] = _balances[sender].sub(fee, 'BEP20: transfer amount exceeds balance');
            _balances[receive2] = _balances[receive2].add(fee);
            _amount = _amount.sub(fee);
            // 1%
            fee = _amount.mul(Fees3).div(feePercent);
            _balances[sender] = _balances[sender].sub(fee, 'BEP20: transfer amount exceeds balance');
            _balances[receive3] = _balances[receive3].add(fee);
            _amount = _amount.sub(fee);
            // 2%
            fee = _amount.mul(Fees4).div(feePercent);
            _balances[sender] = _balances[sender].sub(fee, 'BEP20: transfer amount exceeds balance');
            _balances[receive4] = _balances[receive4].add(fee);
            _amount = _amount.sub(fee);
        } else {
            //普通交易 
            // 4%
            fee = _amount.mul(Fees5).div(feePercent);
            _balances[sender] = _balances[sender].sub(fee, 'BEP20: transfer amount exceeds balance');
            _balances[receive5] = _balances[receive5].add(fee);
            _amount = _amount.sub(fee);
        }
    
        return _amount;
    }
}