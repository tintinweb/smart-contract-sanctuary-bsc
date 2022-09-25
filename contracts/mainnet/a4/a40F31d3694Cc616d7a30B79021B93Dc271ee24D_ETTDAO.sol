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

    constructor(address owner_) {
        owner = owner_;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'Token: owner error');
        _;
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

// owner2
contract Ownable2 {
    address public owner2;

    constructor(address owner2_) {
        owner2 = owner2_;
    }

    modifier onlyOwner2() {
        require(msg.sender == owner2, 'Token: owner2 error');
        _;
    }

    function transferOwnership2(address newOwner2) public onlyOwner2 {
        if (newOwner2 != address(0)) {
            owner2 = newOwner2;
        }
    }
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


interface IBuyTracker {
    function initBuyTracker(address _Ettdao) external;
    function backLPAndBurn() external;
}
interface ISellTracker {
    function initSellTracker(address _Ettdao, address _EttdaoUsdtLP) external;
    function lpHolderDividend() external;
    function addOrRemove(address _from, address _to) external;
}


// ETTDAO
contract ETTDAO is IERC20, Ownable, Ownable2 {
    using SafeMath for uint256;

    address public immutable Factory;
    address public immutable Router;
    address public immutable Usdt;

    address public BuyTracker;    // 买入分红地址
    address public SellTracker;   // 卖出分红地址
    address public immutable EttdaoUsdtLP;  // ettdao-usdt池子地址 
    uint256 public buyBurn = 2;   // 买入销毁的ETTDAO费用
    uint256 public buyFee = 4;    // 买入(移除)费用
    uint256 public sellFee = 6;   // 卖出(添加)费用
    mapping(address => bool) public whitelistAddress;       // 白名单：不扣手续费，没有持币上限。
    mapping(address => bool) public blacklistAddress;       // 黑名单：不能做任何交易。
    uint256 public tokenLimit = 3 * 10**uint256(decimals);  // 持币上限数量
    bool public isOpen = false;    // 开盘。false=只能添加池子(卖)，true=可以任意操作。
    
    string constant public name = "ETTDAO Token";
    string constant public symbol = "ETTDAO";
    uint8 constant public decimals = 18;
    uint256 public totalSupply = 100000 * 10**uint256(decimals);  
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;


    // 构造函数
    constructor(
        address _owner,
        address _owner2,
        address _buyTracker,
        address _sellTracker,
        address _Factory,
        address _Router,
        address _Usdt
    ) Ownable(_owner) Ownable2(_owner2) {
        balances[_owner] = totalSupply;
        whitelistAddress[address(this)] = true;
        whitelistAddress[_owner] = true;
        whitelistAddress[_owner2] = true;
        emit Transfer(address(0), _owner, totalSupply);
        
        Factory = _Factory;
        Router = _Router;
        Usdt = _Usdt;
        EttdaoUsdtLP = IUniswapV2Factory(Factory).createPair(address(this), _Usdt);

        BuyTracker = _buyTracker;
        SellTracker = _sellTracker;
        IBuyTracker(BuyTracker).initBuyTracker(address(this));
        ISellTracker(SellTracker).initSellTracker(address(this), EttdaoUsdtLP);
        whitelistAddress[BuyTracker] = true;
        whitelistAddress[SellTracker] = true;

         // 授权ETTDAO最大值给路由合约
        TransferHelper.safeApprove(address(this), Router, type(uint256).max);
    }

    event Burn(address indexed from, uint256 value);


    // 设置买入分红合约地址
    function setBuyTracker(address _BuyTracker) public onlyOwner2 {
        require(_BuyTracker != address(0), "zero address error");
        BuyTracker = _BuyTracker;
    }

    // 设置卖出分红合约地址
    function setSellTracker(address _SellTracker) public onlyOwner2 {
        require(_SellTracker != address(0), "zero address error");
        SellTracker = _SellTracker;
    }

    // 设置买入销毁和买入费和移除费
    function setBuyAndSellFee(uint256 _buyBurn, uint256 _buyFee, uint256 _sellFee) public onlyOwner {
        buyBurn = _buyBurn;
        buyFee = _buyFee;
        sellFee = _sellFee;
    }

    // 设置白名单
    function setWhitelist(address _address) public onlyOwner {
        whitelistAddress[_address] = !whitelistAddress[_address];
    }
    // 设置黑名单
    function setBlacklist(address _address) public onlyOwner {
        blacklistAddress[_address] = !blacklistAddress[_address];
    }

    // 设置持币上限
    function setTokenLimit(uint256 _tokenLimit) public onlyOwner {
        tokenLimit = _tokenLimit;
    }
 
    // 开盘
    function setIsOpen() public onlyOwner {
        isOpen = true;
    }

    function balanceOf(address _address) external view override returns (uint256) {
        return balances[_address];
    }

    function _approve(address _owner, address _spender, uint256 _value) private {
        allowed[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }

    function approve(address _spender, uint256 _value) external override returns (bool) {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view override returns (uint256) {
        return allowed[_owner][_spender];
    }

    function _transfer(address _from, address _to, uint256 _value) private {
        balances[_from] = SafeMath.sub(balances[_from], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        emit Transfer(_from, _to, _value);
    }

    function _transferFull(address _from, address _to, uint256 _value) private {
        // 验证黑名单, 如果是黑名单交易，直接抛出错误。
        _verifyBlacklist(_from, _to);

        // 如果没有开盘, 不能买入和移除
        if(!isOpen) {
            _transferNotOpen(_from, _to, _value);
        }else if(_from == EttdaoUsdtLP) {
            // 开盘-买入和移除
            _transferBuy(_from, _to, _value);
        }else if(_to == EttdaoUsdtLP) {
            // 开盘-卖出和添加
            _transferSell(_from, _to, _value);
        }else {
            // 开盘-转账
            _transfer(_from, _to, _value);
        }

        // 买入分红
        try IBuyTracker(BuyTracker).backLPAndBurn() {} catch {}
        // 卖出分红
        try ISellTracker(SellTracker).lpHolderDividend() {} catch {}
        // 添加或移除地址
        try ISellTracker(SellTracker).addOrRemove(_from, _to) {} catch {}        
        // 验证余额
        _verifyTokenLimit(_to);
    }

    // 没有开盘的交易
    function _transferNotOpen(address _from, address _to, uint256 _value) private {
        // 任何人都不能买入(移除)
        require(_from != EttdaoUsdtLP, "not open buy and remove error");
        _transfer(_from, _to, _value);
    }

    // 买交易(移除)
    function _transferBuy(address _from, address _to, uint256 _value) private {
        if(whitelistAddress[_from] || whitelistAddress[_to]) {
            // 白名单交易
            _transfer(_from, _to, _value);
        }else {
            // 普通用户交易
            uint256 _burnValue = _value.mul(buyBurn).div(100);
            uint256 _swapValue = _value.mul(buyFee).div(100);
            uint256 _transferValue = _value.sub(_burnValue).sub(_swapValue);

            // 销毁
            _burn(_from, _burnValue);
            // 兑换成USDT转给买入分红合约地址, 先把币给到本合约
            _transfer(_from, address(this), _swapValue);
            _swapUSDT(BuyTracker);
            // 转账
            _transfer(_from, _to, _transferValue);
        }
    }

    // 卖交易(添加)
    function _transferSell(address _from, address _to, uint256 _value) private {
        if(whitelistAddress[_from] || whitelistAddress[_to]) {
            // 白名单交易
            _transfer(_from, _to, _value);
        }else {
            // 普通用户交易
            uint256 _swapValue = _value.mul(sellFee).div(100);
            uint256 _transferValue = _value.sub(_swapValue);

            // 兑换成USDT转给卖出分红合约地址, 先把币给到本合约
            _transfer(_from, address(this), _swapValue);
            _swapUSDT(SellTracker);
            // 转账
            _transfer(_from, _to, _transferValue);
        }
    }

    function transfer(address _to, uint256 _value) external override returns (bool) {
        require(balances[msg.sender] >= _value, 'Token: balance error');
        _transferFull(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external override returns (bool) {
        require(balances[_from] >= _value, 'Token: balance error');
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
       _transferFull(_from, _to, _value);
        return true;
    }

    // 销毁
    function _burn(address _from, uint256 _value) private {
        balances[_from] = SafeMath.sub(balances[_from], _value);
        totalSupply = SafeMath.sub(totalSupply, _value);
        emit Burn(_from, _value);
    }

    // ETTDAO兑换成U(卖出), 转给指定的地址
    function _swapUSDT(address _to) private {
        uint256 _pairBalanceETTDAO = balances[EttdaoUsdtLP];
        uint256 _pairBalanceUSDT = IERC20(Usdt).balanceOf(EttdaoUsdtLP);
        uint256 _thisBalancETTDAO = balances[address(this)];
        // 池子里面有币说明有人添加了池子, 才可以兑换
        if(_pairBalanceETTDAO > 0 && _pairBalanceUSDT > 0 && _thisBalancETTDAO > 0) {
            address[] memory _path = new address[](2);
            _path[0] = address(this);
            _path[1] = Usdt;
            // 开始兑换
            IUniswapV2Router02(Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _thisBalancETTDAO,
            0,
            _path,
            _to,
            block.timestamp);
        }
    }


    // 验证黑名单
    function _verifyBlacklist(address _from, address _to) private view {
        if(blacklistAddress[_from] || blacklistAddress[_to]) {
            revert('blacklist error');
        }
    }

    // 验证持币上限
    function _verifyTokenLimit(address _toAddress) private view {
        if(_toAddress != address(0)) {
            require(
                _toAddress == EttdaoUsdtLP || 
                whitelistAddress[_toAddress] || 
                balances[_toAddress] <= tokenLimit, 'Token: balance limit');
        }
    }


}