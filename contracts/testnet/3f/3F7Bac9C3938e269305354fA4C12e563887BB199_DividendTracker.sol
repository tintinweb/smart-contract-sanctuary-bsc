/**
 *Submitted for verification at BscScan.com on 2022-06-06
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

// ???????????????
interface IDividendTracker {
    function initBnbt(address _bnbtAddress) external returns (address, address);   // bnbt init
    function initBnbdao(address _bnbdaoAddress) external returns (address, address); // bnbdao init
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


// ?????????
contract DividendTracker is IDividendTracker, Ownable {
    using SafeMath for uint256;

    address public factoryAddress; // ??????????????????
    address public routerAddress;  // ??????????????????
    address public bnbtAddress;    // BNBT????????????
    address public wbnbAddress;    // wbnb
    address public ethAddress;     // eth, ??????????????????
    address public usdtAddress;    // usdt??????
    address public bnbdaoAddress;  // BNBDAO????????????
    address public bnbtWbnbLpAddress; // bnbt-wbnb-lp??????

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

    // ???????????????????????????
    uint256 public pointer = 0;
    // ????????????????????????????????????
    uint256 public amount = 10;
    // ?????????????????????LP(bnbdao-usdt-lp)??????????????????, ??????0.001???
    uint256 public lpMin = 1 * (10**15); // 15 = 0.001

    mapping(address => bool) public isHolder;   // ??????????????????
    mapping(address => uint256) public indexOf; // ??????????????????????????????
    address[] public holders;                   // ????????????????????????



    // ????????????
    // ?????????????????????, ????????????????????????
    constructor(
        address _owner,
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
        owner = _owner;

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

    // ???????????????
    receive() external payable {}

    // BNBT Token??????????????????????????????, ????????????????????????
    function initBnbt(address _bnbtAddress) public override returns(address, address) {
        require(bnbtAddress == address(0), 'DividendTracker: initialization address error');
        bnbtAddress = _bnbtAddress;

        bnbtWbnbLpAddress = IUniswapV2Factory(factoryAddress).createPair(bnbtAddress, wbnbAddress);
        return (routerAddress, bnbtWbnbLpAddress);
    }
    function initBnbdao(address _bnbdaoAddress) public override returns(address, address) {
        require(bnbdaoAddress == address(0), 'DividendTracker: initialization address error');
        bnbdaoAddress = _bnbdaoAddress;
        
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

    // ?????????????????????
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
    // ?????????fee??????1???2???3???4
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
    function setAmount(uint256 _amount) public onlyOwner {
        amount = _amount;
    }
    function setLpMin(uint256 _lpMin) public onlyOwner {
        lpMin = _lpMin;
    }

    // ??????
    function withdraw(address _token, address _to, uint256 _value) public onlyOwner {
        TransferHelper.safeTransfer(_token, _to, _value);
    }
    // ??????ETH
    function withdrawETH(address _to, uint256 _value) public onlyOwner {
        TransferHelper.safeTransferETH(_to, _value);
    }

    // ??????????????????
    event Add(address _key);
    // ??????????????????
    event Remove(address _key);
    // Token????????????
    event TokenSwap(uint256 _tokenBalances, uint256 _ethBalanceBefore, uint256 _ethBalanceNow);
    // ????????????????????????
    event BalanceInsufficient(uint256 _dividendTokenAmount, uint256 _dividendCoinAmount, uint256 _ethBalances);
    // ??????????????????
    event Fee1234Rewards(address feeAddress1, uint256 _fee1Amount, address feeAddress2, uint256 _fee2Amount, address feeAddress3, uint256 _fee3Amount, address feeAddress4, uint256 _fee4Amount);
    // ?????????????????????
    event SwapUsdtToBnbdaoUsdtLp(uint256 _backflowAmount);
    // ????????????????????????????????????, ???????????????
    event LinkedinRewards(address _address, uint256 _value);
    // ????????????????????????
    event LpRewards(address _address, uint256 _value); 
   

    // ?????????????????????
    // ??????1: ???????????????
    // ??????2: ???????????????
    function addOrRemove(address _from, address _to) public onlytokenAddress override lock {
        // remove
        if(!isContract(_from) && !isMin(_from) && isHolder[_from]) {
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
        if(_to != address(0) && !isContract(_to) && isMin(_to) && !isHolder[_to]) {
            isHolder[_to] = true;
            indexOf[_to] = holders.length;
            holders.push(_to);

            emit Add(_to);
        }
    }

    // ??????
    function _jump(address _from) private {
        // ?????????0??????????????????????????????????????????, ????????????
        if(_from == address(0) || isContract(_from) || !isHolder[_from]) return;
        
        address _pointerHolder = holders[pointer];  // ???????????????????????????
        uint256 _fromIndex = indexOf[_from];        // ??????from?????????
        // ????????????
        holders[pointer] = _from;
        holders[_fromIndex] = _pointerHolder;
        // ????????????
        indexOf[_from] = pointer;
        indexOf[_pointerHolder] = _fromIndex;
    }

    // ??????????????????????????????
    function getHolders() public view returns (address[] memory x) {
        uint256 len = holders.length;
        x = new address[](len);
        for(uint256 i = 0; i < len; i++) {
            x[i] = holders[i];
        }
    }

    // ???????????????????????????
    function getHoldersLength() public view returns (uint256) {
        return holders.length;
    }

    // ????????????????????????????????????, ??????????????????
    function _holdersDividend() private returns (address[] memory _addrs, uint256[] memory _values) {
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
            _values[i] = getBnbtWbnbLpBalance(_addrs[i]);
        }
        // ????????????????????????????????????????????????????????????.
    }

    // ??????????????????BNBT??????ETH????????????????????????
    function tokenSwap() public onlyOwner override {
        uint256 _ethBalanceBefore = IERC20(ethAddress).balanceOf(address(this)); // ???????????????

        // ???????????????bnbt?????????ETH???BNBT -> WBNB -> ETH
        uint256 _bnbtBalances = IERC20(bnbtAddress).balanceOf(address(this));
        address[] memory _path = new address[](3); // ??????
        _path[0] = bnbtAddress;
        _path[1] = wbnbAddress;
        _path[2] = ethAddress;
        // ???token????????????????????????
        TransferHelper.safeApprove(bnbtAddress, routerAddress, _bnbtBalances);
        if(_bnbtBalances == 0) return; 
        IUniswapV2Router02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _bnbtBalances,
            0, // ???????????????????????????
            _path,
            address(this),
            block.timestamp);
        uint256 _ethBalanceNow = IERC20(ethAddress).balanceOf(address(this)); // ???????????????
        emit TokenSwap(_bnbtBalances, _ethBalanceBefore, _ethBalanceNow);  // ???????????????
    }

    // ??????
    // ??????1???????????????, ?????????
    // ??????2??????????????????Token??????
    function dividendRewards(address _from, uint256 _dividendTokenAmount) public override onlytokenAddress lock {
        if(_dividendTokenAmount == 0) return; // Token?????????0???????????????
        uint256 _totalFees = IToken(bnbtAddress).totalFees();

        // ???????????????coin??????
        address[] memory _path = new address[](3);
        _path[0] = bnbtAddress;
        _path[1] = wbnbAddress;
        _path[2] = ethAddress;
        uint256[] memory _amounts = IUniswapV2Router02(routerAddress).getAmountsOut(_dividendTokenAmount, _path);
        uint256 _dividendCoinAmount0 = _amounts[_amounts.length - 1];  // ?????????????????????coin????????????
        uint256 _ethBalances = IERC20(ethAddress).balanceOf(address(this));                 // ?????????????????????
        if(_dividendCoinAmount0 == 0 || _ethBalances < _dividendCoinAmount0) return;       // coin?????????0???????????????, ????????????????????????????????????
        // ??????????????????coin
        uint256 _overflow = _ethBalances.sub(_dividendCoinAmount0);
        uint256 _dividendCoinAmount = _overflow.div(5).add(_dividendCoinAmount0); // ????????????????????????????????????, ?????????????????????????????????
        emit BalanceInsufficient(_dividendTokenAmount, _dividendCoinAmount, _ethBalances); // ????????????????????????
        // ????????????
        _jump(_from);
        
        // ????????????
        uint256[] memory _fee12345 = new uint256[](4);
        _fee12345[0] = _dividendCoinAmount.mul(fee1).div(_totalFees);
        _fee12345[1] = _dividendCoinAmount.mul(fee2).div(_totalFees);
        _fee12345[2] = _dividendCoinAmount.mul(fee3).div(_totalFees);
        _fee12345[3] = _dividendCoinAmount.mul(fee4).div(_totalFees);
        uint256 _backflowAmount = _dividendCoinAmount.mul(feeSwap).div(_totalFees);
        uint256 _linkedinAmount = _dividendCoinAmount.mul(feeLinkedin).div(_totalFees);
        uint256 _lpRewardsAmount = _dividendCoinAmount.mul(feeLp).div(_totalFees);

        // ????????????
        _fee1234Rewards(_fee12345[0], _fee12345[1], _fee12345[2], _fee12345[3]);  // fee1234??????
        _swapUsdtToBnbdaoUsdtLp(_backflowAmount);                             // ????????????
        _linkedinRewards(_from, _linkedinAmount);                             // ???????????????
        _lpRewards(_lpRewardsAmount);                                         // LP?????????????????????
    }

    // ??????1,2,3,4
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
        emit Fee1234Rewards(feeAddress1, _fee1Amount, feeAddress2, _fee2Amount, feeAddress3, _fee3Amount, feeAddress4, _fee4Amount); // ????????????
    }

    // eth??????usdt?????????B??????, bnbdao-usdt-lp
    function _swapUsdtToBnbdaoUsdtLp(uint256 _backflowAmount) private {
        if(_backflowAmount == 0) return;
        // ??????????????????????????????????????????, ????????????
        uint256 _totalSupply = IUniswapV2Pair(bnbdaoUsdtLpAdress).totalSupply();
        if(_totalSupply == 0) return;

        TransferHelper.safeApprove(ethAddress, routerAddress, _backflowAmount);
        address[] memory _path = new address[](2); // ??????
        _path[0] = ethAddress;
        _path[1] = usdtAddress;
        IUniswapV2Router02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _backflowAmount,
            0, // ???????????????????????????
            _path,
            bnbdaoUsdtLpAdress, // ?????????????????????
            block.timestamp);

        IUniswapV2Pair(bnbdaoUsdtLpAdress).sync();    // ???????????????
        emit SwapUsdtToBnbdaoUsdtLp(_backflowAmount);  // ????????????
    }

    // ???????????????
    function _linkedinRewards(address _from, uint256 _linkedinAmount) private {
        address[] memory _addrs = IToken(bnbtAddress).getLinkedinAddrs(_from); // ?????????????????????
        uint256 _everyAmount = _linkedinAmount.div(_addrs.length + 2); // ?????????3???, ????????????1???
        uint256 _moreAmount = _everyAmount * 3;
        
        uint256 _value;
        uint256 _marketingValue = 0;
        for(uint256 i = 0; i < _addrs.length; i++) {
            _value = i == 0 ? _moreAmount : _everyAmount;
            if(_addrs[i] != address(0)) {
                // ?????????????????????, ?????????
                TransferHelper.safeTransfer(ethAddress, _addrs[i], _value);
                emit LinkedinRewards(_addrs[i], _value);  // ??????????????????
            }else {
                // ????????????????????????????????????
                _marketingValue += _value;
            }
        }
        if(_marketingValue > 0) TransferHelper.safeTransfer(ethAddress, feeAddress1, _marketingValue);
    }

    // ????????????
    function _lpRewards(uint256 _lpRewardsAmount) private {
        // ?????????????????????????????????????????????????????????
        (address[] memory _addrs, uint256[] memory _values) = _holdersDividend();
        uint256 _totalValue;
        for(uint256 i = 0; i < _values.length; i++) {
            _totalValue += _values[i];
        }

        // ??????????????????
        for(uint256 i = 0; i < _addrs.length; i++) {
            uint256 _fee = _values[i].mul(_lpRewardsAmount).div(_totalValue);
            if (_fee > 0) {
                TransferHelper.safeTransfer(ethAddress, _addrs[i], _fee);
                emit LpRewards(_addrs[i], _fee); // ????????????????????????
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

    // lp????????????????????????
    function isMin(address _address) public view returns(bool) {
        uint256 _lpBalance = IERC20(bnbtWbnbLpAddress).balanceOf(_address);
        return _lpBalance >= lpMin;
    }
    // ???????????????lp??????
    function getBnbtWbnbLpBalance(address _address) internal view returns(uint256) {
        return IERC20(bnbtWbnbLpAddress).balanceOf(_address);
    }

    // =============================BNBDAO?????????=================================
    event BnbdaoSwapUsdtToLpAddress(uint256 _value, address _address1);
    event BnbdaoSwapBnbtToZeroAddress(uint256 _value, uint256 _bnbt);

    // BNBDAO???????????????????????????????????????????????????BNBDAO????????????
    // ?????????????????????USDT??????fee1??????, ???????????????BNBT??????????????????;
    function swapAndBurn() public onlyOwner {
        uint256 _bnbdaoBalances = IERC20(bnbdaoAddress).balanceOf(address(this));

        uint256 _value1 = _bnbdaoBalances.div(2);
        uint256 _value2 = _bnbdaoBalances.sub(_value1);
        _bnbdaoSwapUsdtToLpAddress(_value1);
        _bnbdaoSwapBnbtToZeroAddress(_value2);
    }

    // ???????????????BNBDAO?????????usdt, ??????fee1??????
    function _bnbdaoSwapUsdtToLpAddress(uint256 _v1) private {
        if(_v1 == 0) return;
        address[] memory _path = new address[](2);  // ??????
        _path[0] = bnbdaoAddress;
        _path[1] = usdtAddress;
        // ???token????????????????????????
        TransferHelper.safeApprove(bnbdaoAddress, routerAddress, _v1);
        IUniswapV2Router02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _v1,
            0,
            _path,
            feeAddress1,
            block.timestamp);

        // ????????????
        emit BnbdaoSwapUsdtToLpAddress(_v1, feeAddress1);
    }

    // ??????????????????BNBDAO????????????BNBT, ??????????????????
    function _bnbdaoSwapBnbtToZeroAddress(uint256 _v2) private {
        uint256 _zeroAddressBalanceBefore = IERC20(bnbtAddress).balanceOf(address(0));

        // BNBDAO??????BNBT
        address[] memory _path = new address[](4); // ??????
        _path[0] = bnbdaoAddress;
        _path[1] = usdtAddress;
        _path[2] = wbnbAddress;
        _path[3] = bnbtAddress;
        // ???token????????????????????????
        TransferHelper.safeApprove(bnbdaoAddress, routerAddress, _v2);
        IUniswapV2Router02(routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _v2,
            0,
            _path,
            address(0),
            block.timestamp);
        // ????????????
        uint256 _zeroAddressBalanceNow = IERC20(bnbtAddress).balanceOf(address(0));
        uint256 _bnbt = _zeroAddressBalanceNow.sub(_zeroAddressBalanceBefore);
        emit BnbdaoSwapBnbtToZeroAddress(_v2, _bnbt);
    }



}