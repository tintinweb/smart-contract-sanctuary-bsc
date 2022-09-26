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
        require(msg.sender == owner, 'SellTracker: owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

// 提供的接口
interface ISellTracker {
    function initSellTracker(address _Ettdao, address _EttdaoUsdtLP) external;
    function lpHolderDividend() external;
    function addOrRemove(address _from, address _to) external;
}


// 主合约
contract SellTracker is ISellTracker, Ownable {
    using SafeMath for uint256;

    address public immutable Factory; // 工厂合约地址
    address public immutable Router;  // 路由合约地址
    address public immutable Usdt;    // USDT合约地址
    address public Ettdao;    // ETTDAO合约地址
    address public EttdaoUsdtLP;  // ettdao-usdt池子地址 

    // 累积到一定的数量才开始分红
    uint256 public amountFalg = 200 * (10**18);
    // 分红给LP余额要大于一定的数量
    uint256 public lpMin = 1 * (10**15); // 15 = 0.001LP
    // 每个LP分多少个币
    uint256 public dividendPrice = 2 * (10**18); // 18 = 1U

    // 当前的指针开始位置
    uint256 public pointer = 0;
    // 一次性最多分配的地址个数
    uint256 public amount = 10;
    mapping(address => bool) public isHolder;   // 是不是持币者
    mapping(address => uint256) public indexOf; // 持币者对应的数组位置
    address[] public holders;                   // 全部的持币者地址
    mapping(address => bool) public notHolder;  // 不参与持LP币分红



    // 构造函数
    constructor(
        address _Factory,
        address _Router,
        address _Usdt
    ) {
        owner = msg.sender;
        Factory = _Factory;
        Router = _Router;
        Usdt = _Usdt;
    }

    // 初始化。只能调用一次, 设置完将不能更改
    function initSellTracker(address _Ettdao, address _EttdaoUsdtLP) external override {
        require(Ettdao == address(0), 'init ettdao address error');
        require(EttdaoUsdtLP == address(0), 'init ettdao usdt lp address error');
        Ettdao = _Ettdao;
        EttdaoUsdtLP= _EttdaoUsdtLP;
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

    // 设置多累积到多少数量才开始分红
    function setAmountFalg(uint256 _amountFalg) external onlyOwner {
        require(_amountFalg > 0, "value zero error");
        amountFalg = _amountFalg;
    }

    // 设置持有多少个LP才有资格分红
    function setLpMin(uint256 _lpMin) external onlyOwner {
        require(_lpMin > 0, "value zero error");
        lpMin = _lpMin;
    }

    // 设置每个LP分多少U
    function setDividendPrice(uint256 _dividendPrice) external onlyOwner {
        require(_dividendPrice > 0, "value zero error");
        dividendPrice = _dividendPrice;
    }

    // 设置一次最多分多少个地址
    function setAmount(uint256 _amount) public onlyOwner {
        amount = _amount;
    }

    // 设置不能参与分红的地址
    function setNotHolder(address _address) public onlyOwner {
        notHolder[_address] = !notHolder[_address];
    }


    // 添加分红地址
    event Add(address _key);
    // 移除分红地址
    event Remove(address _key);
    // 触发持币分红事情
    event LpRewards(address _address, uint256 _value); 
   

    // 添加或移除地址
    // 参数1: 发送方地址
    // 参数2: 接收方地址
    function addOrRemove(address _from, address _to) external override {
        _addOrRemove(_from, _to);
        _addOrRemove(_to, _from);
    }

    function _addOrRemove(address _from, address _to) private {
        // remove
        // 如果是持有者 && (余额不满足 || 是不能参与分红的地址)
        if(isHolder[_from] && (!isMin(_from) || notHolder[_to])) {
            // from address
            uint256 _fromIndex = indexOf[_from];
            
            // last address
            uint256 _lastIndex = holders.length - 1;
            address _lastAddress = holders[_lastIndex];
            holders[_fromIndex] = _lastAddress;
            indexOf[_lastAddress] = _fromIndex;

            holders.pop();
            isHolder[_from] = false;
            delete indexOf[_from]; 

            if(pointer >= holders.length) {
                pointer = 0;
            }
            
            emit Remove(_from);
        }
        // add
        // 不能是0地址 && 不能是合约 && 余额条件满足 && 不是持有者
        if(_to != address(0) && !isContract(_to) && isMin(_to) && !isHolder[_to]) {
            // 如果是不能参与分红地址, 就不添加。
            if(notHolder[_to]) return;

            isHolder[_to] = true;
            indexOf[_to] = holders.length;
            holders.push(_to);
            emit Add(_to);
        }
    }

    // 查询全部的持币者地址
    function getHolders() public view returns (address[] memory) {
        return holders;
    }

    // 查询持币者地址数量
    function getHoldersLength() public view returns (uint256) {
        return holders.length;
    }

    // 获取本次分红的持币者地址, 和他们的余额
    function _holdersAndBalance() private returns (address[] memory _addrs, uint256[] memory _values) {
        if (holders.length == 0) {
            return (new address[](0), new uint256[](0));
        }

        _addrs = holders.length <= amount ? new address[](holders.length) : new address[](amount);
        _values = new uint256[](_addrs.length);

        if (holders.length <= amount) {
            for(uint256 i = 0; i < holders.length; i++) {
                _addrs[i] = holders[i];
            }
            pointer = 0;
        }else if (holders.length - pointer >= amount) {
            for(uint256 i = 0; i < amount; i++) {
                _addrs[i] = holders[pointer+i];
            }
            pointer = pointer + amount;
            pointer = pointer >= holders.length ? 0 : pointer;
        }else {
            uint256 _end = holders.length > pointer ? holders.length - pointer : 0;
            uint256 _start = amount - _end;
            for(uint256 i = 0; i < _end; i++) {
                _addrs[i] = holders[pointer+i];
            }
            for(uint256 i = 0; i < _start; i++) {
                _addrs[_end+i] = holders[i];
            }
            pointer = _start;
        }

        for(uint256 i = 0; i < _addrs.length; i++) {
            _values[i] = IERC20(EttdaoUsdtLP).balanceOf(_addrs[i]);
        }
        // 获取到了本次分红的地址，和地址对应的余额.
    }

    // 分红
    function lpHolderDividend() external override {
        require(msg.sender == Ettdao, "must be ettdao address");

        // 获取到全部的地址和LP余额
        (address[] memory _addrs, uint256[] memory _values) = _holdersAndBalance();
        // 如果没有地址就不分红了
        if(_addrs.length == 0) return;
        // 查询合约U余额
        uint256 _thisBalanceUSDT = IERC20(Usdt).balanceOf(address(this));
        // 余额不满足条件不分红
        if(_thisBalanceUSDT < amountFalg) return;
        // 计算本次分红所需要的数量是多少
        uint256 _lpBalance;
        uint256 _balance;
        uint256 _zero18 = 10**18;
        for(uint256 i = 0; i < _values.length; i++) {
            // 除去18个0
            _balance = _values[i].div(_zero18);
            _lpBalance = _lpBalance.add(_balance);
            _values[i] = _balance;
        }
        // 如果余额不够, 就先不分红
        if(_lpBalance.mul(dividendPrice) > _thisBalanceUSDT) return;

        // 开始分红
        uint256 _dividendValue;
        for(uint256 i2 = 0; i2 < _values.length; i2++) {
            _dividendValue = _values[i2].mul(dividendPrice);
            TransferHelper.safeTransfer(Usdt, _addrs[i2], _dividendValue);
            emit LpRewards(_addrs[i2], _dividendValue); 
        }
        // 判断是不是需要移除
        for(uint256 i3 = 0; i3 < _addrs.length; i3++) {
            _addOrRemove(_addrs[i3], _addrs[i3]);
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
    function isMin(address _address) public view returns(bool) {
        uint256 _lpBalance = IERC20(EttdaoUsdtLP).balanceOf(_address);
        return _lpBalance >= lpMin;
    }



}