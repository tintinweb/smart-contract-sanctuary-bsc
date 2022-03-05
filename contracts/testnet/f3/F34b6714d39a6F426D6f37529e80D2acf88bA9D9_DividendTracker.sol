/**
 *Submitted for verification at BscScan.com on 2022-03-05
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
// BTM 
interface IBTM is IERC20 {
    function tokenRewardsFee() external view returns (uint256);
    function linkedinFee() external view returns (uint256);
    function liquidityFee() external view returns (uint256);
    function marketingFee() external view returns (uint256);
    function totalFees() external view returns (uint256);
    function getAllFees() external view returns (uint256, uint256, uint256, uint256);

    function superAddress(address _address) external view returns (address);
    function juniorAmount(address _address) external view returns (uint256);
    function juniorAddress(address _address) external view returns (address[] memory _addrs);
    function getLinkedinAddrs(address _address) external view returns (address[] memory _addrs);

    event BoundLinkedin(address from, address to);
}

// 提供的接口
interface IDividendTracker {
    function dividendRewards(address _from) external;
    function addOrRemoveKey(address _from, uint256 _fromBalances, address _to, uint256 _toBalances) external;
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
        require(msg.sender == owner, 'DividendTracker: owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// 主合约
contract DividendTracker is IDividendTracker, Ownable {
    using SafeMath for uint256;

    // 路由合约地址
    address public routerAddress;
    // 工厂合约地址
    address public factoryAddress;
    // BTM合约地址
    address public btmAddress;
    // BTC合约地址。不能转给0地址，发送者也不能为0, 金额可以为0。
    address public btcAddress;
    // WBNB合约地址
    address public wbnbAddress;
    // USDT合约地址
    address public usdtAddress;
    // 运营收币地址
    address public marketingFeeAddress;

    // 当前的指针开始位置
    uint256 public pointer = 0;
    // 一次性最多分配的地址个数
    uint256 public numberOne = 10;
    // 价值多少U才可以参与分红。100
    uint256 public tokenMinU = 100 * (10**18);

    // 全部的地址, 由前到后进行排序。黑名单不然进入, 合约地址也是。
    address[] public keys;
    // 地址是否存在于数组里面
    mapping(address => bool) public inserted;
    // 地址所在数组的索引位置
    mapping(address => uint256) public indexOf;
    // 地址的金额，地址的token余额
    mapping(address => uint256) public values;

    // 设置分红的黑名单地址。就是添加这个地址的时候, 不予添加进去
    mapping(address => bool) public blacklist;


    // 构造函数
    constructor(
        address _routerAddress,
        address _factoryAddress,
        address _btcAddress,
        address _wbnbAddress,
        address _usdtAddress,
        address _marketingFeeAddress
        ) public {
        owner = msg.sender;
        routerAddress = _routerAddress;
        factoryAddress = _factoryAddress;
        btcAddress = _btcAddress;
        wbnbAddress = _wbnbAddress;
        usdtAddress = _usdtAddress;
        marketingFeeAddress = _marketingFeeAddress;
    }

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'DividendTracker: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    modifier onlyBtmAddress() {
        require(msg.sender == btmAddress, 'DividendTracker: btm error');
        _;
    }

    // 设置新的路由合约地址
    function setRouterAddress(address _routerAddress) public onlyOwner {
        routerAddress = _routerAddress;
    }
    // 设置新的工厂合约地址
    function setFactoryAddress(address _factoryAddress) public onlyOwner {
        factoryAddress = _factoryAddress;
    }
    // 设置新的Btm地址
    function setBtmAddress(address _btmAddress) public onlyOwner {
        btmAddress = _btmAddress;
    }
    // 设置新的BTC地址
    function setBtcAddress(address _btcAddress) public onlyOwner {
        btcAddress = _btcAddress;
    }
    // 设置新的WBNB合约地址
    function setWbnbAddress(address _wbnbAddress) public onlyOwner {
        wbnbAddress = _wbnbAddress;
    }
    // 设置新的USDT地址
    function setUsdtAddress(address _usdtAddress) public onlyOwner {
        usdtAddress = _usdtAddress;
    }

    // 设置新的numberOne
    function setNumberOne(uint256 _numberOne) public onlyOwner {
        numberOne = _numberOne;
    }
    // 设置参与分红价值的最少U数量
    function setTokenMinU(uint256 _tokenMinU) public onlyOwner {
        tokenMinU = _tokenMinU;
    }
    // 设置分红黑名单地址
    function setBlacklist(address _address) public onlyOwner {
        blacklist[_address] = !blacklist[_address];
    }

    // 设置运营收币地址
    function setMarketingFeeAddress(address _marketingFeeAddress) public onlyOwner {
        marketingFeeAddress = _marketingFeeAddress;
    }
    // 提取
    function withdraw(address _token, address _to, uint256 _value) public onlyOwner {
        TransferHelper.safeTransfer(_token, _to, _value);
    }

    // 添加分红地址
    event AddKey(address _key);
    // 移除分红地址
    event RemoveKey(address _key);
    // 兑换BTC事件。 btm余额, wbnb余额, wbnb回流的数量, 剩余的wbnb数量, btc余额
    event SwapBTC(uint256 _btmBalances, uint256 _wbnbBalances, uint256 _wbnbLiquidityAmount, uint256 _wbnbSwapBtcAmount, uint256 _btcBalances);
    // btc数量计算事件。持币分红数量, 上下级分红数量, 运营分红数量
    event BTCAmountAllot(uint256 _tokenRewardsAmount, uint256 _linkedinAmount, uint256 _marketingAmount);
    // 持币分红事件。地址, 分红的BTC数量。
    event TokenRewards(address _address, uint256 _btcAmount);
    // 上下级分红事件。用户地址, 分红的数量
    event LinkedinRewards(address _from, uint256 _btcAmount);
    // 运营分红事件。运营方地址, 分红的数量
    event MarketingRewards(address _marketingAddress, uint256 _btcAmount);
    // 回流数量
    event LiquidityRewards(uint256 _lpBalance);

    // 添加或移除地址
    // 参数1: 发送方地址
    // 参数2: 放送方余额
    // 参数3: 接收方地址
    // 参数4: 接收方余额
    function addOrRemoveKey(address _from, uint256 _fromBalances, address _to, uint256 _toBalances) public override onlyBtmAddress lock {
        bool _fromMax = isMinU(_fromBalances);
        bool _toMax = isMinU(_toBalances);
        // 发送方-币够-存在-就插队
        // 发送方-币够-不存在-就排队
        // 发送方-币不够-存在-就移除
        // 发送方-币不够-不存在-就不管
        if(_fromMax && inserted[_from]) {
            _jumpKey(_from, _fromBalances);
        }else if(_fromMax && !inserted[_from]) {
            _addKey(_from, _fromBalances);
        }else if(!_fromMax && inserted[_from]) {
            _removeKey(_from);
        }else {}

        // 接受方-币够-存在-就不管
        // 发送方-币够-不存在-就排队
        // 发送方-币不够-存在-移除(没有这个可能性)
        // 发送方-币不够-不存在-就不管
        if(_toMax && inserted[_to]) {
        }else if(_toMax && !inserted[_to]) {
            _addKey(_to, _toBalances);
        }else if(!_toMax && inserted[_to]) {
            _removeKey(_to);
        }else {}
    }

    // 插队
    function _jumpKey(address _key, uint256 _value) private {
        if(blacklist[_key] || isContract(_key)) return; // 黑名单不然插队
        // 就是把用户的地址放到指针位置, 把指针位置放到用户位置。
        // 当前指针地址
        address _pointerKey = keys[pointer];
        // 用户地址的索引
        uint256 _keyIndex = indexOf[_key];
        // 调换位置
        keys[pointer] = _key;
        keys[_keyIndex] = _pointerKey;
        // 索引也要更换
        indexOf[_key] = pointer;
        indexOf[_pointerKey] = _keyIndex;
        values[_key] = _value;
    }

    // 排队
    function _addKey(address _key, uint256 _value) private {
        if(blacklist[_key] || isContract(_key)) return; // 黑名单不让排队, 合约也是
        indexOf[_key] = keys.length;
        inserted[_key] = true;
        values[_key] = _value;
        keys.push(_key);
        // 触发事件
        emit AddKey(_key);
    }

    // 移除
    function _removeKey(address _key) private {
        // 获取key的索引位置
        uint256 _keyIndex = indexOf[_key];
        // 获取最后一个key的索引位置
        uint256 _lastKeyIndex = keys.length - 1;
        // 获取最后一个key
        address _lastKey = keys[_lastKeyIndex];
        // 把最后一个key放在key的索引位置
        keys[_keyIndex] = _lastKey;
        // 看lastkey, 索引位置已经放进去了。改变索引值, 存在不变, 金额不变。
        indexOf[_lastKey] = _keyIndex;
        // 这个时候, 最后一个key就放到了key的位置
        // 看key, 已经不在数组里面了。是否存在删掉, 索引值删掉, 余额删掉。
        delete inserted[_key];
        delete indexOf[_key];
        delete values[_key];
        // 弹出最后一个key
        keys.pop();
        // 触发事件
        emit RemoveKey(_key);
    }

    // 分红逻辑。持币分红, 上下级分红
    // _from可以插队, 先分红完成后再插队, 也就是说下一次交易就有了。
    function dividendRewards(address _from) public override onlyBtmAddress lock {
        (uint256 _tokenRewardsFee,
        uint256 _linkedinFee,
        uint256 _liquidityFee,
        uint256 _marketingFee) = IBTM(btmAddress).getAllFees();
        uint256 _totalFees = _tokenRewardsFee + _linkedinFee + _liquidityFee + _marketingFee;
        // 查询合约当前的btm余额
        uint256 _btmBalances = IBTM(btmAddress).balanceOf(address(this));
        // 全部兑换成BNB先, 没有余额就算了
        if(_btmBalances == 0) return; 
        _btmSwapWbnb(_btmBalances); // BTM兑换WBNB
        // 获取当前的BNB余额
        uint256 _wbnbBalances = IERC20(wbnbAddress).balanceOf(address(this));
        if(_wbnbBalances == 0) return;

        // 计算出需要回流的WBNB+BTC的数量
        uint256 _wbnbLiquidityAmount = _wbnbBalances.mul(_liquidityFee).div(_totalFees).div(2);
        // 剩余的WBNB, 用于去兑换BTC的
        uint256 _wbnbSwapBtcAmount = _wbnbBalances.sub(_wbnbLiquidityAmount);
        _wbnbSwapBTC(_wbnbSwapBtcAmount); // WBNB兑换BTC
        // 获取当前的BTC余额
        uint256 _btcBalances = IERC20(btcAddress).balanceOf(address(this));
        if(_btcBalances == 0) return; // 没有余额就算了
        // 触发事件。现在合约有一点WBNB和BTC
        emit SwapBTC(_btmBalances, _wbnbBalances, _wbnbLiquidityAmount, _wbnbSwapBtcAmount, _btcBalances);
        
        // 先进行回流
        _liquidityRewards(_wbnbLiquidityAmount, _btcBalances); // wbnb已经全部给出, 剩下BTC了。
        // 持币分红数量, 上下级分红数量
        uint256 _tokenRewardsAmount = _btcBalances.mul(_tokenRewardsFee).div(_totalFees);
        uint256 _linkedinAmount = _btcBalances.mul(_linkedinFee).div(_totalFees);
        // 持币分红
        _tokenRewards(_tokenRewardsAmount);
        // 上下级分红
        _linkedinRewards(_from, _linkedinAmount);
        // 剩下的都是运营方分红
        uint256 _btcResidue = IERC20(btcAddress).balanceOf(address(this));
        _marketingRewards(_btcResidue);
       
        emit BTCAmountAllot(_tokenRewardsAmount, _linkedinAmount, _btcResidue); // 触发btc数量分配事件
    }

    // BTM先兑换成WBNB。BTM-WBNB
    function _btmSwapWbnb(uint256 _btmBalances) private {
        address[] memory _path = new address[](2);
        _path[0] = btmAddress;
        _path[1] = wbnbAddress;
        // 把btm授权给路由合约。
        TransferHelper.safeApprove(btmAddress, routerAddress, _btmBalances);
        IUniswapV2Router02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _btmBalances,
            0, // 接受任意金额的兑换
            _path,
            address(this), // BTC给到本合约
            block.timestamp + 300);
    }

    // WBNB兑换成BTC。WBNB-BTC
    // 当前没有WBNB-BTC的池子, 会报错
    // 当BTM数量为0, 会报错
    // 当兑换到的数量为0时, 会报错
    // 当池子没有储备量时, 会报错
    function _wbnbSwapBTC(uint256 _wbnbValue) private {
         address[] memory _path = new address[](2);
        _path[0] = wbnbAddress;
        _path[1] = btcAddress;
        // 把wbnb授权给路由合约。
        TransferHelper.safeApprove(wbnbAddress, routerAddress, _wbnbValue);
        IUniswapV2Router02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _wbnbValue,
            0, // 接受任意金额的兑换
            _path,
            address(this), // BTC给到本合约
            block.timestamp + 300);
    }

    // 持币分红
    // 如果地址数量是10, 那就是[0-10), 下一次就是[10-20)。
    function _tokenRewards( uint256 _tokenRewardsAmount) private {
        // 如果没有地址就不分红。
        if (keys.length == 0) {
            return;
        }
        // 定义数组长度
        address[] memory _addrs;
        // 定义本次的持币总量
        uint256 _totalValue;
        _addrs = keys.length <= numberOne ? new address[](keys.length) : new address[](numberOne);

        // 计算出地址
        if (keys.length <= numberOne) {
            for(uint256 i = 0; i < keys.length; i++) {
                _addrs[i] = keys[i];
                _totalValue += values[keys[i]];
            }
            pointer = 0;
        }else if (keys.length - pointer >= numberOne) {
            // 如果剩下的数量够的话。
            for(uint256 i = 0; i < numberOne; i++) {
                _addrs[i] = keys[pointer+i];
                _totalValue += values[keys[i]];
            }
            // 从新赋值指针
            pointer = pointer + numberOne;
        }else {
            // 需要末尾拿几个，开头拿几个。
            // 开头和结尾的数量
            uint256 _end = keys.length - pointer;
            uint256 _start = numberOne - _end;
            for(uint256 i = 0; i < _end; i++) {
                _addrs[i] = keys[pointer+i];
                _totalValue += values[keys[i]];
            }
            for(uint256 i = 0; i < _start; i++) {
                _addrs[_end+i] = keys[i];
                _totalValue += values[keys[i]];
            }
            pointer = _start;
        }
        // 已经计算出全部地址, _addrs;

        // 每个金额可分的BTC数量
        uint256 _share = _tokenRewardsAmount.mul(1e12).div(_totalValue);
        // 开始循环转账
        for(uint256 i = 0; i < _addrs.length; i++) {
            uint256 _fee = values[_addrs[i]].mul(_share).div(1e12);
            if (_fee > 0) {
                TransferHelper.safeTransfer(btcAddress, _addrs[i], _fee);
                emit TokenRewards(_addrs[i], _fee); // 触发持币分红事情
            } 
        }
    }

    // 上下级分红
    function _linkedinRewards(address _from, uint256 _linkedinAmount) private {
        uint256 _everyAmount = _linkedinAmount.mul(16).div(100); // 每个占比16%
        address[] memory _addrs = IBTM(btmAddress).getLinkedinAddrs(_from); // 获取上下级关系
        
        uint256 _marketingValue = 0;
        for(uint256 i = 0; i < _addrs.length; i++) {
            if(_addrs[i] != address(0)) {
                // 上下级存在的话, 就转。
                TransferHelper.safeTransfer(btcAddress, _addrs[i], _everyAmount);
                emit LinkedinRewards(_addrs[i], _everyAmount); // 触发分红事件
            }else {
                // 没有上下级给到运营方地址
                _marketingValue += _everyAmount;
            }
        }
        if(_marketingValue > 0) TransferHelper.safeTransfer(btcAddress, marketingFeeAddress, _marketingValue);
    }

    // 运营分红
    function _marketingRewards(uint256 _marketingAmount) private {
        if (marketingFeeAddress != address(0) && _marketingAmount > 0) {
            TransferHelper.safeTransfer(btcAddress, marketingFeeAddress, _marketingAmount);
        }
        // 触发事件
        emit MarketingRewards(marketingFeeAddress, _marketingAmount);
    }

    // 回流分红。添加池子获取到LP转给运营方地址
    function _liquidityRewards(uint256 _wbnbLiquidityAmount, uint256 _btcBalances) private {
        TransferHelper.safeApprove(wbnbAddress, routerAddress, _wbnbLiquidityAmount);
        TransferHelper.safeApprove(btcAddress, routerAddress, _btcBalances);

         IUniswapV2Router02(routerAddress).addLiquidity(
            wbnbAddress,
            btcAddress,
            _wbnbLiquidityAmount,
            _btcBalances,
            0, // 接受任意金额的兑换
            0,
            address(this), // BTC给到本合约
            block.timestamp + 300);
        // 添加完成合约收到LP, 把LP转给运营方地址
        address _lpAddress = IUniswapV2Factory(factoryAddress).getPair(wbnbAddress, btcAddress);
        uint256 _lpBalance = IERC20(_lpAddress).balanceOf(address(this));
        if(_lpBalance > 0) TransferHelper.safeTransfer(_lpAddress, marketingFeeAddress, _lpBalance);
        emit LiquidityRewards(_lpBalance); // 触发事件
    }

    // 判断是不是合约地址
    // 返回值true=合约, false=普通地址。
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    // 查询一定数量的token是否大于分红的最少U
    // 返回true = 可以持币分红
    // 返回false = 不可以持币分红
    function isMinU(uint256 _value) internal view returns (bool) {
        address _btmUsdtPair = IUniswapV2Factory(factoryAddress).getPair(btmAddress, usdtAddress); // 必须有BTM-USDT的池子
        if (_btmUsdtPair == address(0)) return false; // 没有就不满足
       
        // 获取token的价格
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(_btmUsdtPair).getReserves();
        address token0 = IUniswapV2Pair(_btmUsdtPair).token0();
        if (token0 == btmAddress) {
            return reserve1.mul(_value).div(reserve0) >= tokenMinU;
        }else {
            return reserve0.mul(_value).div(reserve1) >= tokenMinU;
        }
    }


}