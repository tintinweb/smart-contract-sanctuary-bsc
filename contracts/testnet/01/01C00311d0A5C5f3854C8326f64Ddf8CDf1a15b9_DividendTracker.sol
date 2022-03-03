/**
 *Submitted for verification at BscScan.com on 2022-03-03
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

// erc20 contract
interface ERC20 {
    function balanceOf(address _address) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// baby token
interface IBabyERC20 is ERC20 {
    function getTokenRewardsFee() external view returns (uint256);
    function getLinkedinFee() external view returns (uint256);
    function getLiquidityFee() external view returns (uint256);
    function getMarketingFee() external view returns (uint256);
    function getTotalFees() external view returns (uint256);
    function getAllFees() external view returns (uint256, uint256, uint256, uint256);
}


interface IDividendTracker {
    function dividendTokenSwapBTC() external;
    function tokenRewards(address _from, uint256 _tokenRewardsFee, uint256 _totalFees) external;
    function linkedinRewards(address _from, uint256 _linkedinFee, uint256 _totalFees) external;
    function marketingRewards(uint256 _marketingFee, uint256 _totalFees) external;
    function liquidityRewards(uint256 _liquidityFee, uint256 _totalFees) external;

    function addKey(address _to, uint256 _value) external;
    function removeKey(address _from, uint256 _value) external;
    function boundLinkedin(address _from, address _to) external;
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
    // Baby合约地址
    address public babyAddress;
    // BTC合约地址。不能转给0地址，发送者也不能为0, 金额可以为0。
    address public btcAddress;
    // USDT合约地址
    address public usdtAddress;
    // BTC-BabyToken配对合约地址
    address public btcAndBabyAddress;
    // USDT-Baby配对合约地址
    address public usdtAndBabyAddress;

    // 当前的指针开始位置
    uint256 public pointer = 0;
    // 一次性最多分配的地址个数
    uint256 public numberOne = 10;
    // 价值多少U才可以参与分红。100
    uint256 public tokenMinU = 100000000000000000000;
    // 记录持币的总量
    uint256 public total;

    // 全部的地址, 由前到后进行排序
    address[] public keys;
    // 地址是否存在于数组里面
    mapping(address => bool) public inserted;
    // 地址所在数组的索引位置
    mapping(address => uint256) public indexOf;
    // 地址的金额，地址的token余额
    mapping(address => uint256) public values;

    // 设置分红的黑名单地址。就是添加这个地址的时候, 不予添加进去
    mapping(address => bool) public blacklist;
    // 上级地址
    mapping(address => address) public superAddress;
    // 多个下级地址
    mapping(address => address[]) public juniorAddress;

    // 运营收币地址
    address public marketingFeeAddress;



    // 构造函数
    constructor(
        address _routerAddress,
        address _btcAddress,
        address _usdtAddress,
        address _marketingFeeAddress
        ) public {
        owner = msg.sender;
        routerAddress = _routerAddress;
        btcAddress = _btcAddress;
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

    modifier onlyBabyAddress() {
        require(msg.sender == babyAddress, 'DividendTracker: baby error');
        _;
    }

    // 设置新的路由合约地址
    function setRouterAddress(address _routerAddress) public onlyOwner {
        routerAddress = _routerAddress;
    }
    // 设置新的Baby地址
    function setBabyAddress(address _babyAddress) public onlyOwner {
        babyAddress = _babyAddress;
    }
    // 设置新的BTC地址
    function setBtcAddress(address _btcAddress) public onlyOwner {
        btcAddress = _btcAddress;
    }
    // 设置新的USDT地址
    function setUsdtAddress(address _usdtAddress) public onlyOwner {
        usdtAddress = _usdtAddress;
    }
    // 设置新的BTC-Baby配对合约地址
    function setBtcAndBabyAddress(address _btcAndBabyAddress) public onlyOwner {
        btcAndBabyAddress = _btcAndBabyAddress;
    }
    // 设置新的USDT-Baby配对合约地址
    function setUsdtAndBabyAddress(address _usdtAndBabyAddress) public onlyOwner {
        usdtAndBabyAddress = _usdtAndBabyAddress;
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

    // 兑换成BTC
    // 使用Baby兑换BTC, 如果兑换失败, 合约就没有BTC了。
    // 失败的可能性, 合约没有Baby,池子不存在,池子没有储备量。
    function dividendTokenSwapBTC() public override onlyBabyAddress {
        // 获取本合约的baby余额
        uint256 _babyBalance = IBabyERC20(babyAddress).balanceOf(address(this));
        // 去swap兑换成BTC, 留一部分token
        uint256 _liquidityFee = IBabyERC20(babyAddress).getLiquidityFee();
        uint256 _totalFees = IBabyERC20(babyAddress).getTotalFees();
        // 留下注入池子的, 兑换的
        uint256 _babyAmount = _babyBalance.mul(_liquidityFee).div(_totalFees).div(2);
        uint256 _swapAmount = _babyBalance.sub(_babyAmount);
        // 如果_babyAmount>0的话, 那么_swapAmount必然大于_babyAmount; _babyAmount+_swapAmount=余额。
        // 拿着_swapAmount全部兑换成BTC
         address[] memory _path = new address[](2);
        _path[0] = babyAddress;
        _path[1] = btcAddress;
        // 当池子没有储备量的时候, 会计算报错。
        // 如果输入的数量为0的话, 为0也会报错。
        // 如果输出数量为0的话, 就当他也会报错。
        if (_swapAmount > 0) {
            try IUniswapV2Router02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _swapAmount,
            0, // 接受任意金额的兑换
            _path,
            address(this), // BTC给到本合约
            block.timestamp + 300) {}
            catch {} // 成功或失败不用管, 大不了就是合约里面的Baby太少了, 不能兑换到一点点的BTC。
        }
        // 到了这里, 说明兑换成了, 约等于80%兑换成了BTC给到本合约, 20%Baby还是合约里面。
        // 到时候20%baby+20%BTC注入池子, 60%拿去分红收益。
        // 本合约里面永远有20%的Baby+80%的BTC。如果说一直重复兑换BTC的话, 那Baby占比会变少, 但不影响。
    }

    // 持币分红
    // 如果地址数量是10, 那就是[0-10), 下一次就是[10-20)。
    // 假设现在开始一笔交易, 找出本次领取的地址
    // 本次调用地址, 如果存在就插队。
    // 参数1：占比
    // 参数2：总占比
    function tokenRewards(address _from, uint256 _tokenRewardsFee, uint256 _totalFees) public override onlyBabyAddress lock {
        address _key = _from;
        // 获取到本合约的BTC余额和Baby余额
        uint256 _btcBalance = ERC20(btcAddress).balanceOf(address(this));
        _btcBalance = _btcBalance.div(2);
        if(_btcBalance < 0) {
            return; // 如果没有了BTC那就不分了。
        }
        // 持币分红的数量
        uint256 _tokenRewardsAmount = _btcBalance.mul(_tokenRewardsFee).div(_totalFees);

        // 如果没有地址就不分红。
        if (keys.length == 0) {
            return;
        }
        if (inserted[_key]) {
            // 如果地址存在, 将先插队。
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
        }
        // 不存在的话就不管了
        // 定义数组长度
        address[] memory _addrs;
        _addrs = keys.length <= numberOne ? new address[](keys.length) : new address[](numberOne);

        // 计算出地址
        if (keys.length <= numberOne) {
            for(uint256 i = 0; i < keys.length; i++) {
                _addrs[i] = keys[i];
            }
            pointer = 0;
        }else if (keys.length - pointer >= numberOne) {
            // 如果剩下的数量够的话。
            for(uint256 i = 0; i < numberOne; i++) {
                _addrs[i] = keys[pointer+i];
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
            }
            for(uint256 i = 0; i < _start; i++) {
                _addrs[_end+i] = keys[i];
            }
            pointer = _start;
        }
        // 已经计算出全部地址, _addrs;

        // 计算每个代币可以分配到的btc数量, 乘以1e12
        // _tokenRewardsAmount / total
        uint256 _share = _tokenRewardsAmount.mul(1e12).div(total);
        // 开始循环转账
        for(uint256 i = 0; i < _addrs.length; i++) {
            uint256 _fee = values[_addrs[i]].mul(_share).div(1e12);
            if (_fee > 0) TransferHelper.safeTransfer(btcAddress, _addrs[i], _fee);
        }
    }
    
    // 上下级分红
    // 参数1：占比
    // 参数2：总占比
    function linkedinRewards(address _from, uint256 _linkedinFee, uint256 _totalFees) public override onlyBabyAddress lock {
        // 获取到本合约的BTC余额和Baby余额
        uint256 _btcBalance = ERC20(btcAddress).balanceOf(address(this));
        _btcBalance = _btcBalance.div(2);
        if(_btcBalance < 0) {
            return; // 如果没有了BTC那就不分了。
        }
        // 上下级分红
        uint256 _linkedinAmount = _btcBalance.mul(_linkedinFee).div(_totalFees);

        address[] memory _addrs = new address[](6);
        uint256 _everyAmount = _linkedinAmount.mul(16).div(100); //每个占比16%
        if (_everyAmount < 0) {
            return;
        }

        address _superNow = _from;
        address _juniorNow = _from;
        uint256 _leaderValue = 0;
        for(uint256 i = 0; i < _addrs.length; i++) {
            if(i < 3) {
                // 上三级
                _addrs[i] = superAddress[_superNow];
                _superNow = _addrs[i];
                if (_superNow == address(0)) _leaderValue = _leaderValue + _everyAmount;
            }else {
                // 下三级
                if(juniorAddress[_juniorNow].length > 0) {
                    // 说明有下级
                    uint256 _index = radomNumber(juniorAddress[_juniorNow].length);
                    _addrs[i] = juniorAddress[_juniorNow][_index];
                    _juniorNow = _addrs[i];
                }else {
                    // 没有下级
                    _leaderValue = _leaderValue + _everyAmount;
                }
            }
        }
        // 16%。上级1(10%),上级2(5%),上级3(5%),下级1(40%),下级2(20%),下级3(10%)。
        for(uint256 i = 0; i < _addrs.length; i++) {
            if(_addrs[i] != address(0)) {
                // 如果上下级存在的话, 就转。
                TransferHelper.safeTransfer(btcAddress, _addrs[i], _everyAmount);
            }
        }
        if(_leaderValue > 0) TransferHelper.safeTransfer(btcAddress, marketingFeeAddress, _leaderValue);
    }

    // 运营分红
    // 参数1：占比
    // 参数2：总占比
    function marketingRewards(uint256 _marketingFee, uint256 _totalFees) public override onlyBabyAddress lock  {
        // 获取到本合约的BTC余额和Baby余额
        uint256 _btcBalance = ERC20(btcAddress).balanceOf(address(this));
        _btcBalance = _btcBalance.div(2);
        if(_btcBalance < 0) {
            return; // 如果没有了BTC那就不分了。
        }
        // 运营分红
        uint256 _marketingAmount = _btcBalance.mul(_marketingFee).div(_totalFees);
        if (marketingFeeAddress != address(0) && _marketingAmount > 0) {
            TransferHelper.safeTransfer(btcAddress, marketingFeeAddress, _marketingAmount);
        }
    }

    // 回流分红
    // 参数1：占比
    // 参数2：总占比
    function liquidityRewards(uint256 _liquidityFee, uint256 _totalFees) public override onlyBabyAddress lock {
        // 获取到本合约的BTC余额和Baby余额
        uint256 _btcBalance = ERC20(btcAddress).balanceOf(address(this));
        uint256 _babyBalance = ERC20(babyAddress).balanceOf(address(this));
        // 回流分红
        uint256 _btcTokenAmount = _btcBalance.mul(_liquidityFee).div(_totalFees).div(2);
        uint256 _babyTokenAmount = _babyBalance.div(2);
        // 如果LP地址存在的话
        if (btcAndBabyAddress != address(0)) {
            // 回流LP
            TransferHelper.safeTransfer(babyAddress, btcAndBabyAddress, _babyTokenAmount);
            TransferHelper.safeTransfer(btcAddress, btcAndBabyAddress, _btcTokenAmount);
            IUniswapV2Pair(btcAndBabyAddress).sync();
        }
    }

    // 添加可分红地址。针对于交易时的to地址。
    // 如果是黑名单地址, 就不添加到分红数组。
    // 如果是合约地址, 就不添加到分红数组。
    // 如果该地址的Baby余额价值没有大于规定U的数量, 就不添加到分红数组。
    // 如果地址已经存在, 并且Baby余额价值大于规定U的数量, 就从新赋值余额。
    // 参数1：地址
    // 参数2：余额
    // 失败的可能性, 几乎没有。失败也只能没有添加进去而已。
    function addKey(address _to, uint256 _value) public override onlyBabyAddress lock {
        address _key = _to;
        // 黑名单, 或是合约地址, 就不添加
        if (blacklist[_key] || isContract(_key)) {
            return;
        }
        // 如果金额不达标也不添加
        if(!isMinU(_value)) {
            return;
        }

        if(inserted[_key]) {
            // 存在
            // 计算总量
            total = total + _value - values[_key];
            // 从新设置金额
            values[_key] = _value;
        }else {
            // 不存在
            // 添加
            indexOf[_key] = keys.length;
            inserted[_key] = true;
            values[_key] = _value;
            keys.push(_key);
            // 增加总量
            total += _value;
        }
    }

    // 移除地址。针对于交易时的from地址。
    // 如果地址不存在, 就过。
    // 如果地址存在, 但价值的U不满足, 就移除。
    // 如果地址存在, 当价值的U满足, 就从新赋值金额。
    // 失败的可能性, 几乎没有。失败也只能没有移除成功而已。
    function removeKey(address _from, uint256 _value) public override onlyBabyAddress lock {
        address _key = _from;
        // 不存在就过。
        if(!inserted[_key]) {
        }
        // 存在, 但不满足。移除
        else if(!isMinU(_value)) {
            // 计算总量
            total -= values[_key];

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
        } 
        // 存在, 也满足。修改余额和总量
        else {
            // 总量
            total = total + _value - values[_key];
            // 余额
            values[_key] = _value;
        }
    }

    // 绑定关系
    // 失败的可能性, 几乎没有。失败也只能没有绑定成功关系而已。
    function boundLinkedin(address _from, address _to) public override onlyBabyAddress lock {
        // 不能和合约绑定关系, 过。
        if(isContract(_from) || isContract(_to)) {
            return;
        }
        // 如果to地址没有上级
        if(superAddress[_to] == address(0)) {
            superAddress[_to] = _from;
            juniorAddress[_from].push(_to);
        }
    }
    // 查询全部的下级地址
    function getJuniorAddress(address _address) public view returns (address[] memory _addrs) {
        uint256 _length = juniorAddress[_address].length;
        _addrs = new address[](_length);
        for(uint256 i = 0; i < _length; i++) {
            _addrs[i] = juniorAddress[_address][i];
        }
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
    function isMinU(uint256 _value) public view returns (bool) {
        if (usdtAndBabyAddress == address(0)) {
            // 如果没有池子, 就都不满足分红要求
            return false;
        }else {
            // 获取token的价格
            (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(usdtAndBabyAddress).getReserves();
            address token0 = IUniswapV2Pair(usdtAndBabyAddress).token0();
            if (token0 == babyAddress) {
                return reserve1.mul(_value).div(reserve0) >= tokenMinU;
            }else {
                return reserve0.mul(_value).div(reserve1) >= tokenMinU;
            }
        }
    }

    // 随机生成一个区间数, [0-max)
    function radomNumber(uint256 _max) public view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % _max;
    }


}