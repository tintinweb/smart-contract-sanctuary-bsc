/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


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

    constructor(address owner_) {
        owner = owner_;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

// 对外提供的接口
interface IETETracker {
    function initETETracker(address _Ete) external;
    function nftHolderDividendAndSwap() external;
    function addOrRemove(address _from, address _to) external;
}
// DIDNFT 接口
interface IETEDIDNFT {
    function getRank(address _user) external view returns(uint256);
    function getFreeze(address _user) external view returns(bool);
}



// 主合约
contract ETETracker is IETETracker, Ownable {
    using SafeMath for uint256;

    address public immutable Factory; // 工厂合约地址
    address public immutable Router;  // 路由合约地址
    address public immutable Usdt;    // USDT合约地址
    address public ete;               // ETE合约地址
    address public eteUsdtLP;         // ete-usdt池子地址
    address public leader;            // 收币地址
    address public eteDidNFT;         // ETE DID NFT 合约地址

    // 当前的指针开始位置
    uint256 public pointer = 0;
    // 一次性最多分配的地址个数
    uint256 public amount = 10;
    mapping(address => bool) public isHolder;   // 是不是持币者
    mapping(address => uint256) public indexOf; // 持币者对应的数组位置
    address[] public holders;                   // 全部的持币者地址


    // 构造函数
    constructor(
        address owner_,
        address Factory_,
        address Router_,
        address Usdt_,
        address leader_
    ) Ownable(owner_) {
        Factory = Factory_;
        Router = Router_;
        Usdt = Usdt_;
        leader = leader_;

        // 授权最大值给路由合约, ETE,
        TransferHelper.safeApprove(ete, Router, type(uint256).max);
    }

    // 初始化。只能调用一次, 设置完将不能更改
    function initETETracker(address _ete) external override {
        require(_ete != address(0), "0 address error");
        if(ete == address(0)) {
            address _lp = IUniswapV2Factory(Factory).createPair(_ete, Usdt);
            ete = _ete;
            eteUsdtLP = _lp;
        }
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

    // 设置项目方收币地址
    function setLeader(address _leader) public onlyOwner {
        require(_leader != address(0), "zero address error");
        leader = _leader;
    }

    // 设置DIDNFT地址
    function setEteDidNFT(address _eteDidNFT) public onlyOwner {
        require(_eteDidNFT != address(0), "zero address error");
        eteDidNFT = _eteDidNFT;
    }

    // 设置一次最多分多少个地址
    function setAmount(uint256 _amount) public onlyOwner {
        amount = _amount;
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
        // 如果是持有者 && 余额不满足
        if(isHolder[_from] && !isMin(_from)) {
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

    // 获取本次分红的持币者地址, 和他们的DIDNFT
    function _holdersAndBalance() private returns (address[] memory _addrs, uint256[] memory _values, uint256 _totalRank) {
        if (holders.length == 0) {
            return (new address[](0), new uint256[](0), 0);
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
            _values[i] = IETEDIDNFT(eteDidNFT).getRank(_addrs[i]);
            _totalRank += _values[i];
        }
        // 获取到了本次分红的地址，和地址对应的DIDNFT.
    }

    // 分红
    function nftHolderDividendAndSwap() external override {
        // 获取到全部的地址和DIDNFT
        (address[] memory _addrs, uint256[] memory _values, uint256 _totalRank) = _holdersAndBalance();
        // 如果没有地址就不分红了
        if(_addrs.length == 0) return;
        // 查询合约U余额
        uint256 _thisBalanceEte = IERC20(ete).balanceOf(address(this));
        // 没有余额不分红
        if(_thisBalanceEte == 0) return;
        // 拿出2/3去分红DIDNFT者
        _thisBalanceEte = _thisBalanceEte.mul(2).div(3);
        // 总分红金额除去每个级别可以获得的分红数量。
        uint256 _everyOne = _thisBalanceEte.div(_totalRank);

        // 开始分红
        uint256 _dividendValue;
        for(uint256 i = 0; i < _addrs.length; i++) {
            _dividendValue = _values[i].mul(_everyOne);
            TransferHelper.safeTransfer(ete, _addrs[i], _dividendValue);
            emit LpRewards(_addrs[i], _dividendValue); 
        }

        // 判断是不是需要移除
        for(uint256 i2 = 0; i2 < _addrs.length; i2++) {
            _addOrRemove(_addrs[i2], _addrs[i2]);
        }

        // 兑换给到收币地址
        _swapAndToLeader();
    }

    // 兑换U给收币地址
    function _swapAndToLeader() private {
        uint256 _eteBalance = IERC20(ete).balanceOf(address(this));
        if(_eteBalance > 0) {
            address[] memory _path = new address[](2); // 兑换
            _path[0] = ete;
            _path[1] = Usdt;

            // 开始兑换
            IUniswapV2Router02(Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _eteBalance,
            0,
            _path,
            leader,
            block.timestamp);
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

    // lp持有是否满足条件。DID NFT是否满足条件。
    function isMin(address _address) public view returns(bool) {
        uint256 _rank = IETEDIDNFT(eteDidNFT).getRank(_address);
        bool _freeze = IETEDIDNFT(eteDidNFT).getFreeze(_address);
        if(_rank != 0 && !_freeze) {
            // 如果不是0, 并且没有冻结。
            return true;
        }else {
            return false;
        }
    }



}