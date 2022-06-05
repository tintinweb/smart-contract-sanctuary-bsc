/**
 *Submitted for verification at BscScan.com on 2022-06-04
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
// Token
interface IToken is IERC20 {
    function totalFees() external view returns (uint256);
    function superAddress(address _address) external view returns (address);
    function juniorAddress(address _address) external view returns (address[] memory _addrs);
    function getLinkedinAddrs(address _address) external view returns (address[] memory _addrs);
    event BoundLinkedin(address from, address to);
}

// 提供的接口
interface IDividendTracker {
    function initBnbt() external returns (address, address);   // bnbt init
    function initBnbdao() external returns (address, address); // bnbdao init
    function tokenSwap() external;        // token swap
    function dividendRewards(address _from, uint256 _dividendTokenAmount) external; // dividend
    function addOrRemove(address _from, address _to) external; // add or remove
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

    address public factoryAddress; // 工厂合约地址
    address public routerAddress;  // 路由合约地址
    address public bnbtAddress;    // BNBT合约地址
    address public wbnbAddress;    // wbnb
    address public ethAddress;     // eth, 主要分红的币
    address public usdtAddress;    // usdt地址
    address public bnbdaoAddress;  // BNBDAO合约地址
    address public bnbtWbnblpAddress; // bnbt-wbnb-lp地址

    address public feeAddress1;   // address 1 = 1%
    address public feeAddress2;   // address 2 = 2%
    address public feeAddress3;   // address 3 = 2%
    address public feeAddress4;   // address 4 = 2%
    address public bnbdaoUsdtLpAdress; // 4% = swap USDT in bnbdao-Usdt-lp
    uint256 public fee1 = 1;  // address 1
    uint256 public fee2 = 2;  // address 2
    uint256 public fee3 = 2;  // address 3
    uint256 public fee4 = 2;  // address 4
    uint256 public feeSwap = 4;  // 4% = swap usdt in bnbdao-Usdt-lp
    uint256 public feeLinkedin = 2;  // 2% = Linkedin
    uint256 public feeLp = 2; // lp holder

    // 当前的指针开始位置
    uint256 public pointer = 0;
    // 一次性最多分配的地址个数
    uint256 public numberOne = 10;
    // 数量大于多少个LP(bnbdao-usdt-lp)才能参与分红, 默认0.001个
    uint256 public lpMin = 1 * (10**15); // 15 = 0.001

    // 全部的地址, 由前到后进行排序。黑名单不然进入, 合约地址也是。
    address[] public keys;
    // 地址是否存在于数组里面
    mapping(address => bool) public inserted;
    // 地址所在数组的索引位置
    mapping(address => uint256) public indexOf;
    // 地址的金额，地址的token余额
    mapping(address => uint256) public values;


    // 构造函数
    // 可以携带主链币, 放一点进去比较好
    constructor(
        address _factoryAddress,
        address _routerAddress,
        address _wbnbAddress,
        address _ethAddress,
        address _usdtAddress,
        address _feeAddress1,
        address _feeAddress2,
        address _feeAddress3,
        address _feeAddress4
    ) public {
        owner = msg.sender;

        factoryAddress = _factoryAddress;
        routerAddress = _routerAddress;
        wbnbAddress = _wbnbAddress;
        ethAddress = _ethAddress;
        usdtAddress = _usdtAddress;

        feeAddress1 = _feeAddress1;
        feeAddress2 = _feeAddress2;
        feeAddress3 = _feeAddress3;
        feeAddress4 = _feeAddress4;
    }

    // 接收主链币
    receive() external payable {}

    // BNBT Token初始化。只能调用一次, 设置完将不能更改
    function initBnbt() public override returns(address, address) {
        require(bnbtAddress == address(0), 'DividendTracker: initialization address error');
        bnbtAddress = msg.sender;

        bnbtWbnblpAddress = IUniswapV2Factory(factoryAddress).createPair(bnbtAddress, wbnbAddress);
        return (routerAddress, bnbtWbnblpAddress);
    }
    function initBnbdao() public override returns(address, address) {
        require(bnbdaoAddress == address(0), 'DividendTracker: initialization address error');
        bnbdaoAddress = msg.sender;
        bnbdaoUsdtLpAdress = IUniswapV2Factory(factoryAddress).createPair(bnbdaoAddress, usdtAddress);
        return (routerAddress, bnbdaoUsdtLpAdress);
    }

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'DividendTracker: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
    modifier onlytokenAddress() {
        require(msg.sender == bnbtAddress, 'DividendTracker: token error');
        _;
    }

    // 设置分红的占比
    function setFee(
        uint256 _fee1,
        uint256 _fee2,
        uint256 _fee3,
        uint256 _fee4,
        uint256 _feeSwap,
        uint256 _feeLinkedin,
        uint256 _feeLp
    ) public onlyOwner {
            fee1 = _fee1;
            fee2 = _fee2;
            fee3 = _fee3;
            fee4 = _fee4;
            feeSwap = _feeSwap;
            feeLinkedin = _feeLinkedin;
            feeLp = _feeLp;
            uint256 _all = fee1 + fee2 + fee3 + fee4 + feeSwap + feeLinkedin + feeLp;
            uint256 _totalFee = IToken(bnbtAddress).totalFees();
            require(_all == _totalFee, 'DividendTracker: fee error');
    }
    // 设置收fee地址1，2，3，4
    function setFeeAddress(
        address _feeAddress1,
        address _feeAddress2,
        address _feeAddress3,
        address _feeAddress4
    ) public onlyOwner {
        feeAddress1 = _feeAddress1;
        feeAddress2 = _feeAddress2;
        feeAddress3 = _feeAddress3;
        feeAddress4 = _feeAddress4;
    }
    function setNumberOne(uint256 _numberOne) public onlyOwner {
        numberOne = _numberOne;
    }
    function setLpMin(uint256 _lpMin) public onlyOwner {
        lpMin = _lpMin;
    }

    // 提取
    function withdraw(address _token, address _to, uint256 _value) public onlyOwner {
        TransferHelper.safeTransfer(_token, _to, _value);
    }
    // 提取ETH
    function withdrawETH(address _to, uint256 _value) public onlyOwner {
        TransferHelper.safeTransferETH(_to, _value);
    }

    // 添加分红地址
    event AddKey(address _key);
    // 移除分红地址
    event RemoveKey(address _key);
    // Token兑换事件。
    event TokenSwap(uint256 _tokenBalances, uint256 _ethBalanceBefore, uint256 _ethBalanceNow);
    // 触发本次金额事件
    event BalanceInsufficient(uint256 _dividendTokenAmount, uint256 _dividendCoinAmount, uint256 _ethBalances);
    // 分红金额事件。本次分红的token数量, 本次分红的coin数量, 此时的coin余额
    event Fee1234Rewards(address feeAddress1, uint256 _fee1Amount, address feeAddress2, uint256 _fee2Amount, address feeAddress3, uint256 _fee3Amount, address feeAddress4, uint256 _fee4Amount);
    // 回流资金池事件
    event SwapUsdtToBnbdaoUsdtLp(uint256 _backflowAmount);
    // 上下级分红事件。用户地址, 分红的数量
    event LinkedinRewards(address _address, uint256 _value);
    // 触发持币分红事情
    event LpRewards(address _address, uint256 _value); 
   

    // 添加或移除地址
    // 参数1: 发送方地址
    // 参数2: 放送方余额
    // 参数3: 接收方地址
    // 参数4: 接收方余额
    // function addOrRemove(address _from, address _to) public override onlytokenAddress lock {
    //     (bool _fromMax, uint256 _fromBalances) = isMin(_from);
    //     (bool _toMax, uint256 _toBalances) = isMin(_to);
    //     // 发送方-币够-存在-就插队
    //     // 发送方-币够-不存在-就排队
    //     // 发送方-币不够-存在-就移除
    //     // 发送方-币不够-不存在-就不管
    //     // if(_fromMax && inserted[_from]) {
    //     //    _jumpKey(_from, _fromBalances);
    //     // }else
    //     if(_fromMax && !inserted[_from]) {
    //         _addKey(_from, _fromBalances);
    //     }else if(!_fromMax && inserted[_from]) {
    //         _removeKey(_from);
    //     }else {}

    //     // 接受方-币够-存在-就不管
    //     // 接受方-币够-不存在-就排队
    //     // 接受方-币不够-存在-移除(没有这个可能性)
    //     // 接受方-币不够-不存在-就不管
    //     if(_toMax && inserted[_to]) {
    //     }else if(_toMax && !inserted[_to]) {
    //         _addKey(_to, _toBalances);
    //     }else if(!_toMax && inserted[_to]) {
    //         _removeKey(_to);
    //     }else {}
    // }
    event AAA(address _from, address _to);
    function addOrRemove(address _from, address _to) public override onlytokenAddress lock {
        emit AAA(_from, _to);
    }

    // 插队
    function _jumpKey(address _key) private {
        if(isContract(_key)) return;
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
        // values[_key] = _value;
    }

    // 排队
    function _addKey(address _key, uint256 _value) private {
        if(isContract(_key)) return; // 合约不让排队
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

    // 兑换
    // function tokenSwap() public override {
    //     uint256 _ethBalanceBefore = IERC20(ethAddress).balanceOf(address(this)); // 之前的余额

    //     // 当前全部的bnbt都换成ETH
    //     uint256 _bnbtBalances = IERC20(bnbtAddress).balanceOf(address(this));
    //     address[] memory _path = new address[](3); // 兑换
    //     _path[0] = bnbtAddress;
    //     _path[1] = wbnbAddress;
    //     _path[2] = ethAddress;
    //     // 把token授权给路由合约。
    //     TransferHelper.safeApprove(bnbtAddress, routerAddress, _bnbtBalances);
    //     if(_bnbtBalances == 0) return; 
    //     IUniswapV2Router02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //         _bnbtBalances,
    //         0, // 接受任意金额的兑换
    //         _path,
    //         address(this),
    //         block.timestamp + 300);
    //     uint256 _ethBalanceNow = IERC20(ethAddress).balanceOf(address(this)); // 现在的余额
    //     emit TokenSwap(_bnbtBalances, _ethBalanceBefore, _ethBalanceNow);  // 兑换事件。
    // }
    event BBB();
    function tokenSwap() public override {
        emit BBB();
    }

    // 分红
    // 参数1：用户地址, 可插队
    // 参数2：本次分红的Token数量
    // function dividendRewards(address _from, uint256 _dividendTokenAmount) public override onlytokenAddress lock {
    //     if(_dividendTokenAmount == 0) return; // Token数量为0就不分红了
    //     uint256 _totalFees = IToken(bnbtAddress).totalFees();

    //     // 计算分红的coin数量
    //     address[] memory _path = new address[](3);
    //     _path[0] = bnbtAddress;
    //     _path[1] = wbnbAddress;
    //     _path[2] = ethAddress;
    //     uint256[] memory _amounts = IUniswapV2Router02(routerAddress).getAmountsOut(_dividendTokenAmount, _path);
    //     uint256 _dividendCoinAmount0 = _amounts[_amounts.length - 1];  // 分红数量对应的coin分红数量
    //     uint256 _ethBalances = IERC20(ethAddress).balanceOf(address(this));                 // 当前合约的余额
    //     if(_dividendCoinAmount0 == 0 || _ethBalances < _dividendCoinAmount0) return;       // coin数量为0就不分红了, 本合约余额不够也不分红。
    //     // 防止累积沉淀coin
    //     uint256 _overflow = _ethBalances.sub(_dividendCoinAmount0);
    //     uint256 _dividendCoinAmount = _overflow.div(5).add(_dividendCoinAmount0); // 但余额比本次数量多的时候, 多给相差数量的五分之一
    //     emit BalanceInsufficient(_dividendTokenAmount, _dividendCoinAmount, _ethBalances); // 触发本次金额事件
        
    //     // 分红
    //     uint256[] memory _fee12345 = new uint256[](4);
    //     _fee12345[0] = _dividendCoinAmount.mul(fee1).div(_totalFees);
    //     _fee12345[1] = _dividendCoinAmount.mul(fee2).div(_totalFees);
    //     _fee12345[2] = _dividendCoinAmount.mul(fee3).div(_totalFees);
    //     _fee12345[3] = _dividendCoinAmount.mul(fee4).div(_totalFees);
    //     uint256 _backflowAmount = _dividendCoinAmount.mul(feeSwap).div(_totalFees);
    //     uint256 _linkedinAmount = _dividendCoinAmount.mul(feeLinkedin).div(_totalFees);
    //     uint256 _lpRewardsAmount = _dividendCoinAmount.mul(feeLp).div(_totalFees);

    //     _fee1234Rewards(_fee12345[0], _fee12345[1], _fee12345[2], _fee12345[3]);  // fee1234分红
    //     _swapUsdtToBnbdaoUsdtLp(_backflowAmount);                             // 运营分红
    //     _linkedinRewards(_from, _linkedinAmount);                             // 上下级分红
    //     _lpRewards(_lpRewardsAmount);                                         // LP和小区持币分红
    // }
    event CCC(address _from, uint256 _dividendTokenAmount);
    function dividendRewards(address _from, uint256 _dividendTokenAmount) public override onlytokenAddress lock {
        emit CCC(_from, _dividendTokenAmount);
    }

    // 分红1,2,3,4
    function _fee1234Rewards(
        uint256 _fee1Amount,
        uint256 _fee2Amount,
        uint256 _fee3Amount,
        uint256 _fee4Amount
        ) private {
        if(_fee1Amount > 0) TransferHelper.safeTransfer(ethAddress, feeAddress1, _fee1Amount);
        if(_fee2Amount > 0) TransferHelper.safeTransfer(ethAddress, feeAddress2, _fee2Amount);
        if(_fee3Amount > 0) TransferHelper.safeTransfer(ethAddress, feeAddress3, _fee3Amount);
        if(_fee4Amount > 0) TransferHelper.safeTransfer(ethAddress, feeAddress4, _fee4Amount);
        emit Fee1234Rewards(feeAddress1, _fee1Amount, feeAddress2, _fee2Amount, feeAddress3, _fee3Amount, feeAddress4, _fee4Amount); // 触发事件
    }

    // eth兑换usdt回流到B池子
    function _swapUsdtToBnbdaoUsdtLp(uint256 _backflowAmount) private {
        if(_backflowAmount == 0) return; 
        TransferHelper.safeApprove(ethAddress, routerAddress, _backflowAmount);

        address[] memory _path = new address[](2); // 兑换
        _path[0] = ethAddress;
        _path[1] = usdtAddress;
        IUniswapV2Router02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _backflowAmount,
            0, // 接受任意金额的兑换
            _path,
            bnbdaoUsdtLpAdress, // 给到bnbdao-usdt-lp池子地址
            block.timestamp);

        IUniswapV2Pair(bnbdaoUsdtLpAdress).sync();    // 更新储备量
        emit SwapUsdtToBnbdaoUsdtLp(_backflowAmount);  // 触发事件
    }

    // 上下级分红
    function _linkedinRewards(address _from, uint256 _linkedinAmount) private {
        address[] memory _addrs = IToken(bnbtAddress).getLinkedinAddrs(_from); // 获取上下级关系
        uint256 _everyAmount = _linkedinAmount.div(_addrs.length + 2); // 上一级3份, 其它都是1份
        uint256 _moreAmount = _everyAmount * 3;
        
        uint256 _value;
        uint256 _marketingValue = 0;
        for(uint256 i = 0; i < _addrs.length; i++) {
            _value = i == 0 ? _moreAmount : _everyAmount;
            if(_addrs[i] != address(0)) {
                // 上下级存在的话, 就转。
                TransferHelper.safeTransferETH(_addrs[i], _value);
                emit LinkedinRewards(_addrs[i], _value);  // 触发分红事件
            }else {
                // 没有上下级给到运营方地址
                _marketingValue += _value;
            }
        }
        if(_marketingValue > 0) TransferHelper.safeTransferETH(feeAddress1, _marketingValue);
    }

    // 持币分红
    // 如果地址数量是10, 那就是[0-9], 下一次就是[10-19]。
    function _lpRewards(uint256 _lpRewardsAmount) private {
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
            // 需要末尾拿几个, 开头拿几个。
            // 开头和结尾的数量
            uint256 _end = keys.length > pointer ? keys.length - pointer : 0;
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

        // 开始循环转账
        for(uint256 i = 0; i < _addrs.length; i++) {
            uint256 _fee = values[_addrs[i]].mul(_lpRewardsAmount).div(_totalValue);
            if (_fee > 0) {
                TransferHelper.safeTransferETH(_addrs[i], _fee);
                emit LpRewards(_addrs[i], _fee); // 触发持币分红事情
            }
        }
    }



    // true = contract
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

    // lp持有是否满足条件
    function isMin(address _address) internal view returns(bool, uint256) {
        uint256 _lpBalance = IERC20(bnbdaoUsdtLpAdress).balanceOf(_address);
        return (_lpBalance >= lpMin, _lpBalance);
    }

    // =====BNBDAO的接口====
    // BNBDAO币。添加流动性和卖出时会扣除手续费BNBDAO币到这里
    // 然后一半兑换成USDT打进BNBDAO-USDT池子, 一半兑换成BNBT打进黑洞地址;
    function swapAndBurn() public onlyOwner {
        uint256 _bnbdaoBalances = IERC20(bnbdaoAddress).balanceOf(address(this));

        uint256 _v1 = _bnbdaoBalances.div(2);
        uint256 _v2 = _bnbdaoBalances.sub(_v1);
        bnbdaoSwapUsdtToLpAddress(_v1);
        bnbdaoSwapBnbtToZeroAddress(_v2);
    }

    // 给定数量的BNBDAO兑换成usdt, 打进bnbt-usdt-lp池子里面
    function bnbdaoSwapUsdtToLpAddress(uint256 _v1) internal onlyOwner {
        if(_v1 == 0) return;
        address[] memory _path = new address[](2);  // 兑换
        _path[0] = bnbdaoAddress;
        _path[1] = usdtAddress;
        // 把token授权给路由合约。
        TransferHelper.safeApprove(bnbdaoAddress, routerAddress, _v1);
        IUniswapV2Router02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _v1,
            0, // 接受任意金额的兑换
            _path,
            address(0),
            block.timestamp);

        address _pair = IUniswapV2Factory(factoryAddress).getPair(bnbdaoAddress, usdtAddress);
        uint256 _usdtBalance = IERC20(usdtAddress).balanceOf(address(this));
        TransferHelper.safeTransfer(usdtAddress, _pair, _usdtBalance);
        IUniswapV2Pair(_pair).sync();
    }

    // 把一般数量的BNBDAO币兑换成BNBT, 打进黑洞地址
    function bnbdaoSwapBnbtToZeroAddress(uint256 _v2) internal onlyOwner {
        // BNBDAO换成BNB
        address[] memory _path = new address[](2); // 兑换
        _path[0] = bnbdaoAddress;
        _path[1] = bnbtAddress;
        // 把token授权给路由合约。
        TransferHelper.safeApprove(bnbdaoAddress, routerAddress, _v2);
        IUniswapV2Router02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _v2,
            0, // 接受任意金额的兑换
            _path,
            address(0),
            block.timestamp);
    }



}