/**
 *Submitted for verification at BscScan.com on 2022-04-13
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
    function juniorAmount(address _address) external view returns (uint256);
    function juniorAddress(address _address) external view returns (address[] memory _addrs);
    function getLinkedinAddrs(address _address) external view returns (address[] memory _addrs);

    event BoundLinkedin(address from, address to);
}

// ???????????????
interface IDividendTracker {
    function initialization() external;
    function tokenSwap() external; // ??????token?????????????????????
    function dividendRewards(address _from, uint256 _dividendTokenAmount) external; // ??????
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

    address public routerAddress;  // ??????????????????
    address public factoryAddress; // ??????????????????
    address public tokenAddress;   // Token????????????
    address public coinAddress;    // ?????????????????????????????????, ?????????????????????BNB(WBNB??????)
    address public bAddress;       // B???, ?????????BNBDAO????????????
    address public liquidityFeeAddress;   // ??????????????????, ????????????????????????
    address public marketingFeeAddress;   // ??????????????????, ????????????????????????
    address public dropFeeAddress;        // ????????????????????????

    uint256 public liquidityFee = 2;  // ????????????, ????????????
    uint256 public marketingFee = 1;  // ????????????, ????????????
    uint256 public bFee = 4;          // ?????????BNB?????????B-BNB?????????
    uint256 public linkedinFee = 4;   // ???????????????
    uint256 public dropFee = 1 + 2;   // ????????????, ???????????????LP???????????????


    // ????????????
    // ?????????????????????, ????????????????????????
    constructor(
        address _routerAddress,
        address _factoryAddress,
        address _coinAddress,
        address _bAddress,
        address _liquidityFeeAddress,
        address _marketingFeeAddress,
        address _dropFeeAddress
    ) public payable {
        owner = msg.sender;
        routerAddress = _routerAddress;
        factoryAddress = _factoryAddress;
        coinAddress = _coinAddress;
        bAddress = _bAddress;
       
        liquidityFeeAddress = _liquidityFeeAddress;
        marketingFeeAddress = _marketingFeeAddress;
        dropFeeAddress = _dropFeeAddress;
    }

    // ???????????????
    receive() external payable {}

    // Token??????????????????????????????, ????????????????????????
    function initialization() public override {
        require(tokenAddress == address(0), 'DividendTracker: initialization address error');
        tokenAddress = msg.sender; // ??????token??????
    }

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'DividendTracker: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
    modifier onlytokenAddress() {
        require(msg.sender == tokenAddress, 'DividendTracker: token error');
        _;
    }
    // ?????????????????????
    function setFee(
        uint256 _liquidityFee,
        uint256 _marketingFee,
        uint256 _bFee,
        uint256 _linkedinFee,
        uint256 _dropFee
        ) public onlyOwner {
            liquidityFee = _liquidityFee;
            marketingFee = _marketingFee;
            bFee = _bFee;
            linkedinFee = _linkedinFee;
            dropFee = _dropFee;
            uint256 _all = liquidityFee + marketingFee + bFee + linkedinFee + dropFee;
            uint256 _totalFee = IToken(tokenAddress).totalFees();
            require(_all == _totalFee, 'DividendTracker: fee error');
    }
    // ????????????LP????????????
    function setLiquidityFeeAddress(address _liquidityFeeAddress) public onlyOwner {
        if(_liquidityFeeAddress != address(0)) {
            liquidityFeeAddress = _liquidityFeeAddress;
        }
    }
    // ????????????????????????
    function setMarketingFeeAddress(address _marketingFeeAddress) public onlyOwner {
        if(_marketingFeeAddress != address(0)) {
            marketingFeeAddress = _marketingFeeAddress;
        }
    }
    // ??????????????????
    function setDropFeeAddress(address _dropFeeAddress) public onlyOwner {
        if(_dropFeeAddress != address(0)) {
            dropFeeAddress = _dropFeeAddress;
        }
    }
    // ??????
    function withdraw(address _token, address _to, uint256 _value) public onlyOwner {
        TransferHelper.safeTransfer(_token, _to, _value);
    }
    // ??????ETH
    function withdrawETH(address _to, uint256 _value) public onlyOwner {
        TransferHelper.safeTransferETH(_to, _value);
    }

    // Token??????????????? ??????Token??????, ????????????????????????
    event TokenSwap(uint256 _tokenBalances, uint256 _coinBalances);
    // ????????????????????????????????????token??????, ???????????????coin??????, ?????????coin??????
    event BalanceInsufficient(uint256 _dividendTokenAmount, uint256 _dividendCoinAmount, uint256 _coinBalances);
    // ??????????????????????????????????????????, ?????????coin?????????
    event LiquidityRewards(address _address, uint256 _coinAmount);
    // ????????????????????????????????????, ???????????????
    event MarketingRewards(address _address, uint256 _coinAmount);
    // ????????????????????????????????????, ???????????????
    event LinkedinRewards(address _address, uint256 _coinAmount);
    // ???????????????????????????????????????, ???????????????
    event DropRewards(address _address, uint256 _coinAmount);

    // ??????
    function tokenSwap() public override {
        uint256 _bnbBalanceBefore = address(this).balance; // ???????????????

        // ???????????????Token?????????BNB
        uint256 _tokenBalances = IERC20(tokenAddress).balanceOf(address(this));
        address[] memory _path = new address[](2); // ??????
        _path[0] = tokenAddress;
        _path[1] = coinAddress;
        // ???token????????????????????????
        TransferHelper.safeApprove(tokenAddress, routerAddress, _tokenBalances);
        if(_tokenBalances == 0) return; 
        IUniswapV2Router02(routerAddress).swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokenBalances,
            0, // ???????????????????????????
            _path,
            address(this),
            block.timestamp + 300);
        uint256 _coinBalances = address(this).balance;  // ???????????????
        emit TokenSwap(_tokenBalances, _coinBalances);  // ???????????????

        // ????????????BNB(WBNB)?????????B-BNB????????????, ?????????????????????
        address _bLpAddress = IUniswapV2Factory(factoryAddress).getPair(bAddress, coinAddress);
        uint256 _totalFee = IToken(tokenAddress).totalFees();
        uint256 _v = _coinBalances.sub(_bnbBalanceBefore); // ???????????????????????????BNB??????
        uint256 _bAmount = _v.mul(bFee).div(_totalFee);
        if(_bLpAddress != address(0)) {
            // ???BNB?????????WBNB
            TransferHelper.safeTransferETH(coinAddress, _bAmount);
            // ???WBNB?????????B-BNB????????????
            TransferHelper.safeTransfer(coinAddress, _bLpAddress, _bAmount);
            IUniswapV2Pair(_bLpAddress).sync();
        }
    }

    // ??????
    // ??????1???????????????, ?????????
    // ??????2??????????????????Token??????
    function dividendRewards(address _from, uint256 _dividendTokenAmount) public override onlytokenAddress lock {
        if(_dividendTokenAmount == 0) return; // Token?????????0???????????????
        uint256 _totalFees = IToken(tokenAddress).totalFees();

        // ???????????????coin??????
        address[] memory _path = new address[](2);
        _path[0] = tokenAddress;
        _path[1] = coinAddress;
        uint256[] memory _amounts = IUniswapV2Router02(routerAddress).getAmountsOut(_dividendTokenAmount, _path);
        uint256 _dividendCoinAmount0 = _amounts[_amounts.length - 1];  // ?????????????????????coin????????????
        uint256 _coinBalances = address(this).balance;                 // ?????????????????????
        if(_dividendCoinAmount0 == 0 || _coinBalances < _dividendCoinAmount0) return; // coin?????????0???????????????, ????????????????????????????????????
        // ??????????????????coin
        uint256 _overflow = _coinBalances.sub(_dividendCoinAmount0);
        uint256 _dividendCoinAmount = _overflow.div(2).add(_dividendCoinAmount0);
        emit BalanceInsufficient(_dividendTokenAmount, _dividendCoinAmount, _coinBalances); // ????????????????????????
        
        // ???????????????????????????, ???????????????????????????, ???????????????, ??????+LP???????????????
        uint256 _liquidityAmount = _dividendCoinAmount.mul(liquidityFee).div(_totalFees);
        uint256 _marketingAmount = _dividendCoinAmount.mul(marketingFee).div(_totalFees);
        uint256 _linkedinAmount = _dividendCoinAmount.mul(linkedinFee).div(_totalFees);
        uint256 _dropAmount = _dividendCoinAmount.mul(dropFee).div(_totalFees);

        _liquidityRewards(_liquidityAmount);            // ???????????????
        _marketingRewards(_marketingAmount);            // ????????????
        _linkedinRewards(_from, _linkedinAmount);       // ???????????????
        _dropRewards(_dropAmount);                      // LP?????????????????????
    }

    // ???????????????
    function _liquidityRewards(uint256 _liquidityAmount) private {
        if(_liquidityAmount > 0) TransferHelper.safeTransferETH(liquidityFeeAddress, _liquidityAmount);
        emit LiquidityRewards(liquidityFeeAddress, _liquidityAmount); // ????????????
    }

    // ????????????
    function _marketingRewards(uint256 _marketingAmount) private {
        if(_marketingAmount > 0) TransferHelper.safeTransferETH(marketingFeeAddress, _marketingAmount);
        emit MarketingRewards(marketingFeeAddress, _marketingAmount);  // ????????????
    }

    // ???????????????
    function _linkedinRewards(address _from, uint256 _linkedinAmount) private {
        address[] memory _addrs = IToken(tokenAddress).getLinkedinAddrs(_from); // ?????????????????????
        uint256 _everyAmount = _linkedinAmount.div(_addrs.length + 3); // ?????? ??? ????????????, ??????????????????
        uint256 _moreAmount = _everyAmount * 2;
        
        uint256 _value;
        uint256 _marketingValue = 0;
        for(uint256 i = 0; i < _addrs.length; i++) {
            _value = i < 3 ? _moreAmount : _everyAmount;
            if(_addrs[i] != address(0)) {
                // ?????????????????????, ?????????
                TransferHelper.safeTransferETH(_addrs[i], _value);
                emit LinkedinRewards(_addrs[i], _value);  // ??????????????????
            }else {
                // ????????????????????????????????????
                _marketingValue += _value;
            }
        }
        if(_marketingValue > 0) TransferHelper.safeTransferETH(marketingFeeAddress, _marketingValue);
    }

    // ????????????
    function _dropRewards(uint256 _dropAmount) private {
        if(_dropAmount > 0) TransferHelper.safeTransferETH(dropFeeAddress, _dropAmount);
        emit DropRewards(dropFeeAddress, _dropAmount);  // ????????????
    }

}