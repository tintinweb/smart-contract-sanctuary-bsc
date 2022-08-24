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

contract SendToken is BEP20, Ownable {
    using SafeMath for uint256;

    uint public feePercent = 1000;
    uint public feeRate = 10;

    bool public onlySell = false;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    address public feeReciver0 = address(0xBdBfaa27Ad074107d1f63727C02182e3d5a122F2);
    address public feeReciver1 = address(0x6Ddf806fD8EADe630A1e067111568f86a4EBec03);

    address[] public shareholders;
    mapping(address => uint256) public shareholderIndexes;

    uint256 public currentIndex;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 5 minutes;
    uint256 public LPFeefenhong;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) isDividendExempt;
    mapping(address => bool) public _updated;

    mapping(address => bool) public isRoute;

    mapping(address => bool) public blackList;

    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);

    constructor(string memory name, string memory symbol,uint8 decimals, uint256 _total) BEP20(name, symbol, decimals) public {
        //dev
        // _mint(msg.sender, _total * (10 ** uint256(decimals)));
        //prod
        _mint(address(0x51A5Be51181c196AB8079AD1A860a9E6381072a7), _total * (10 ** uint256(decimals)));

        
        //prod
        isRoute[0x10ED43C718714eb63d5aA57B78B54704E256024E]=true;
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address usdt = address(0x55d398326f99059fF775485246999027B3197955);
        
        //rinkey
        // isRoute[0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D] = true;
        // uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        // address usdt = address(0x10681E51eA76b0F66fe6a9433a4326Fd2B5c84c5);

        //bsctest
        // isRoute[0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3] = true;
        // uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        // address usdt = address(0x7860554d6A0c9094299c5f9A41fFB305e2283f43);

        
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), usdt);

        _isExcludedFromFee[0x51A5Be51181c196AB8079AD1A860a9E6381072a7] = true;
        _isExcludedFromFee[0xBdBfaa27Ad074107d1f63727C02182e3d5a122F2] = true;
        _isExcludedFromFee[0x6Ddf806fD8EADe630A1e067111568f86a4EBec03] = true;
        _isExcludedFromFee[address(this)] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
    }

    function setWhiteList(address _user) public onlyOwner returns (bool) {
        _isExcludedFromFee[_user] = !_isExcludedFromFee[_user];
        return true;
    }

    function setBlackList(address _user) public onlyOwner returns (bool) {
        blackList[_user] = !blackList[_user];
        return true;
    }

    function setOnlySell() public onlyOwner {
        onlySell = !onlySell;
    }

    function _beforeTokenTransfer( address sender, address recipient, uint256 _amount )internal override returns (uint256){
        require(!blackList[sender] && !blackList[recipient], 'Black List');
        uint256 fee = 0;

        bool takeFee = false;

        if (sender == uniswapV2Pair && isRoute[recipient]){
            takeFee = false;
        }else if (sender == uniswapV2Pair && !isRoute[recipient]) {
            takeFee = false;
        }else if (recipient == uniswapV2Pair) {
            takeFee = true;
        }else{
            takeFee = false;
        }

        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient] ) {
            takeFee = false;
        }else{
            if(onlySell) {
                require(sender != uniswapV2Pair, 'only sell');
            }
        }

        if(!takeFee){
            return _amount;
        }
        
        if(recipient == uniswapV2Pair) { // 卖出
            fee = _amount.mul(feeRate).div(feePercent);

            _balances[feeReciver0] = _balances[feeReciver0] + fee.mul(5);
            emit Transfer(sender, feeReciver0, fee.mul(5));

            _balances[feeReciver1] = _balances[feeReciver1] + fee.mul(3);
            emit Transfer(sender, feeReciver1, fee.mul(3));

            _balances[_destroyAddress] = _balances[_destroyAddress] + fee;
            _totalSupply = _totalSupply.sub(fee);
            emit Transfer(sender, _destroyAddress, fee);

            _balances[address(this)] = _balances[address(this)] + fee;
            emit Transfer(sender, address(this), fee);

            _amount = _amount.sub(fee.mul(10));
        }

        if (!isDividendExempt[sender] && sender != uniswapV2Pair) setShare(sender);
        if (!isDividendExempt[recipient] && recipient != uniswapV2Pair) setShare(recipient);

        if (sender != address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
            process(distributorGas);
            LPFeefenhong = block.timestamp;
        }
    
        return _amount;
    }

    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) return;

        uint256 nowbanance = balanceOf(address(this));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            uint256 amount = nowbanance.mul(BEP20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(BEP20(uniswapV2Pair).totalSupply());
  
            if (balanceOf(address(this)) < amount) return;
            distributeDividend(shareholders[currentIndex], amount);

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function distributeDividend(address shareholder, uint256 amount) internal {
        _balances[address(this)] = _balances[address(this)].sub(amount);
        _balances[shareholder] = _balances[shareholder].add(amount);
        emit Transfer(address(this), shareholder, amount);
    }

    function setShare(address shareholder) private {
        if (_updated[shareholder]) {
            if (BEP20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);
            return;
        }
        if (BEP20(uniswapV2Pair).balanceOf(shareholder) == 0) return;
        addShareholder(shareholder);
        _updated[shareholder] = true;

    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function quitShare(address shareholder) private {
        removeShareholder(shareholder);
        _updated[shareholder] = false;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}