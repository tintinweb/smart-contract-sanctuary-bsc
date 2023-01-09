// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13 <0.9.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


pragma solidity >=0.8.13 <0.9.0;
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
interface IERC20Meta is IERC20 {
    function tokenPair() external view returns (address pair);
}

contract Protector is Ownable {
    uint256 private MAX_INT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    using SafeMath for uint256;
    uint256 public minimalMarketCap = 6000000; //USD VALUE
    uint256 public USDdailyLimitNOADM = 20000; //USD VALUE
    uint256 public USDdailyLimitADM = 1000; //USD VALUE
    uint256 public PromileDailyLimitADM = 10; //1%
    uint256 public FixForPriceUSD = 9775; //97,75%


    struct user {
        uint256 startBalance;
        uint256 tradedUSD;
        uint256 tradedTokens;
        uint256 lastTradeTime;
    }

    uint256 public TwentyFourhours = 86400;

    mapping(address => user) public tradeData;


    uint256 pancakeswapFee = 250;
    bool public useSecondFromReserves = false;
    bool public useDirectWay = false;

    uint256 private createTime;


    IERC20Meta public metaGold;
  
    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Pair public tokenPair;
    address public uniswapRouter;
    address public busdToken;

    address public metaGoldAddress;

    mapping (address => bool) private _isExcludedFromProtection;
    mapping (address => bool) private _isBlacklisted;


    event AllowCheck (
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 mcLimit,
        uint256 ADMLimit
    );
    event AllowedMetaSell (
        address indexed from,
        address indexed to,
        uint256 amount
    );

    event WalletTransfer (
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event ProtectionFreeTransfer (
        address indexed from,
        address indexed to,
        uint256 amount
    );

    modifier onlyMetagold() {
        require(metaGoldAddress == _msgSender(), "OnlyMetagold: caller is not metagold contract");
        _;
    }

    constructor() {
            if( block.chainid == 97) {
                 busdToken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; //testnet
                 uniswapRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //testnet
            }
            else{
                 busdToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //mainnet
                 uniswapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //mainnet
            }

            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniswapRouter);
            uniswapV2Router = _uniswapV2Router;
            createTime = block.timestamp;
    }  

    function setMetaGold(address ma) external onlyOwner {
            metaGoldAddress = ma;
            metaGold = IERC20Meta(metaGoldAddress);
            tokenPair = IUniswapV2Pair(metaGold.tokenPair());
    }

    function setMetaGoldManually(address _metagoldAddress, address metagoldPair) external onlyOwner {
            metaGoldAddress = _metagoldAddress;
            metaGold = IERC20Meta(metaGoldAddress);
            tokenPair = IUniswapV2Pair(metagoldPair);
    }

    function getMyAddress() external view returns(address who) {
        return _msgSender();
    }

    function getTwentyFourHours() external onlyMetagold view returns (uint256 hrs){
        return TwentyFourhours;
    }

    function getMyAddressProtected() external onlyMetagold view returns(address who) {
        return _msgSender();
    }


    function processSell(address from, address to, uint256 amount) external onlyMetagold returns (bool allowed) {
        if(_isExcludedFromProtection[from] || _isExcludedFromProtection[to]) {
            emit ProtectionFreeTransfer(from,to,amount);
            return true;
        }
        if(_isBlacklisted[from] || _isBlacklisted[to]) {
            return false;
        }

        if( to == metaGold.tokenPair()) {  //selling tokens through PancakeSWAP

            if( from == metaGoldAddress){ //metagold contract is selling => allow
                emit AllowedMetaSell(from,to,amount);
                return true;
            }

           (uint256 limit1, uint256 limit2) = _getMaxTokenAllowedToSell(from);
           (, uint256 a2) = getADMLimits(from, limit1, limit2);


            uint256 myLimit;
            if( limit2 >= amount) {
               myLimit = limit2;
            }
            else {
                myLimit = a2;   
            }



            emit AllowCheck(from,to,amount, limit2, a2);
            if( myLimit >= amount) {
                if( block.timestamp > tradeData[from].lastTradeTime + TwentyFourhours) {
                    tradeData[from].startBalance = metaGold.balanceOf(from);
                    tradeData[from].tradedUSD = 0;
                    tradeData[from].tradedTokens = 0;
                }
                tradeData[from].lastTradeTime = block.timestamp;
                tradeData[from].tradedTokens = tradeData[from].tradedTokens.add(amount);

                uint256 currentPrice;
                if( useDirectWay) {
                    currentPrice = getPriceDirect(metaGoldAddress, busdToken, amount)[1];
                }
                else {
                    currentPrice = getPrice(metaGoldAddress, uniswapV2Router.WETH(), busdToken, amount)[2];
                }
                tradeData[from].tradedUSD = tradeData[from].tradedUSD.add(currentPrice.mul(FixForPriceUSD).div(10000));
                return true;
            }
            else{
                return false;
            }
        }
        else {
            //wallet transfers
            emit WalletTransfer(from,to,amount);
            return true;
        }
    }

    function excludeFromProtection(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromProtection[account] != excluded, "Account is already the value of 'excluded'");
        _isExcludedFromProtection[account] = excluded;
    }
    function isExcludedFromProtection(address account) public view returns(bool) {
        return _isExcludedFromProtection[account];
    }

    function blacklistAddresss(address account, bool excluded) public onlyOwner {
        require(_isBlacklisted[account] != excluded, "Account is already the value of 'excluded'");
        _isBlacklisted[account] = excluded;
    }
    function isBlacklisted(address account) public view returns(bool) {
        return _isBlacklisted[account];
    }

            


    function getTradeData(address whoWantsToSell) external onlyMetagold view returns(uint256 startBalance,
        uint256 tradedUSD,
        uint256 tradedTokens,
        uint256 lastTradeTime)  {
        return (tradeData[whoWantsToSell].startBalance,tradeData[whoWantsToSell].tradedUSD,tradeData[whoWantsToSell].tradedTokens,tradeData[whoWantsToSell].lastTradeTime);
    }

    function getRemainingPercentADMLimit(address whoWantsToSell) public view returns(uint256 remainingPercentADMLimit){
        uint256 startBalance;
        if( block.timestamp > tradeData[whoWantsToSell].lastTradeTime + TwentyFourhours) {
            startBalance = metaGold.balanceOf(whoWantsToSell);
        }
        else {
            startBalance = tradeData[whoWantsToSell].startBalance;
        }

        uint256 percentADMLimit = startBalance.mul(PromileDailyLimitADM).div(1000);
        return percentADMLimit.sub(tradeData[whoWantsToSell].tradedTokens);
    }

    function getTokensAllowedToSellUSDLimit(bool mcLimit, address whoWantsToSell) public view returns(uint256 tokensAllowedToSellUSDLimit) {
        uint256 startUSD;
        
        if( block.timestamp > tradeData[whoWantsToSell].lastTradeTime + TwentyFourhours) {
            startUSD = 0;
        }
        else {
            startUSD = tradeData[whoWantsToSell].tradedUSD;
        }
        uint256 remainingUSD;
        if( mcLimit) {
            remainingUSD = USDdailyLimitADM.mul(1 * 10**18).sub(startUSD);
        }
        else{
           remainingUSD = USDdailyLimitNOADM.mul(1 * 10**18).sub(startUSD);
        }

        uint256 currentPrice;
        if( useDirectWay) {
            currentPrice = getPriceDirect(metaGoldAddress, busdToken, 1 * 10**18)[1];
        }
        else {
            currentPrice = getPrice(metaGoldAddress, uniswapV2Router.WETH(), busdToken, 1 * 10**18)[2];
        }
        return remainingUSD.div(currentPrice);
    }
 
    function getADMLimits(address whoWantsToSell, uint256 mc1, uint256 tokensUntilMC) private view returns(uint256 maxTokens, uint256 maxTokensFilter) {
        bool mcLimit = false;
        if( mc1 == 0 && tokensUntilMC == 0) {
            //market cap limit activated;
            mcLimit = true;
        }

        uint256 remainingPercentADMLimit = getRemainingPercentADMLimit(whoWantsToSell);
        uint256 userBalance = metaGold.balanceOf(whoWantsToSell);


        uint256 tokensAllowedToSellUSDLimit = getTokensAllowedToSellUSDLimit(mcLimit, whoWantsToSell);
        if( mcLimit) {
            if( remainingPercentADMLimit < tokensAllowedToSellUSDLimit) {
                return (remainingPercentADMLimit.div(1*10**18),remainingPercentADMLimit);
            }
            else {
                if( userBalance <= tokensAllowedToSellUSDLimit) {
                    return (userBalance.div(1*10**18),userBalance);
                }
                else{
                    return (tokensAllowedToSellUSDLimit.div(1*10**18),tokensAllowedToSellUSDLimit);
                }
            }
        }

        if( userBalance <= tokensUntilMC) {
            return (userBalance.div(1*10**18),userBalance);
        }

        if( tokensUntilMC >= tokensAllowedToSellUSDLimit) {
            //if USD limit is lower than tokensUntilMC we apply USD limit
            return (tokensAllowedToSellUSDLimit.div(1*10**18),tokensAllowedToSellUSDLimit);
        }

        tokensAllowedToSellUSDLimit = getTokensAllowedToSellUSDLimit(true, whoWantsToSell);

        if( remainingPercentADMLimit < tokensAllowedToSellUSDLimit) {
                return (remainingPercentADMLimit.div(1*10**18),remainingPercentADMLimit);
        }
        else {
            if( userBalance <= tokensAllowedToSellUSDLimit) {
                return (userBalance.div(1*10**18),userBalance);
            }
            else{
                return (tokensAllowedToSellUSDLimit.div(1*10**18),tokensAllowedToSellUSDLimit);
            }
        }
    }

    function _getMaxTokenAllowedToSell(address whoWantsToSell) private view returns(uint256 maxTokens, uint256 maxTokensFilter)  {
        uint256 mcusd = getMarketCapUSD();
        if( mcusd < minimalMarketCap) {
            return getADMLimits(whoWantsToSell,0,0);
        }
        if(_isExcludedFromProtection[whoWantsToSell]) {
            return(MAX_INT,MAX_INT);
        }
        uint256 reserve_a_initial;
        if( useSecondFromReserves) {
            (,reserve_a_initial,) = tokenPair.getReserves();
        }
        else {
            (reserve_a_initial,,) = tokenPair.getReserves();
        }
        uint256 max_price_impact = uint256(100000).sub(uint256(100000).mul(minimalMarketCap).div(mcusd));
        uint256 leftImpact = uint256(100000).sub(max_price_impact);
        uint256 rightImpact = uint256(100000).sub(pancakeswapFee);
        uint256 divisor = leftImpact.mul(rightImpact);
        uint256 mT = reserve_a_initial.mul(100000).mul(max_price_impact).div(divisor);   
        return (mT.div(1*10**18),mT);
    }

    function getReserves() external view returns(uint256 a1, uint256 a2, uint256 a3)  {
        return tokenPair.getReserves();
    }

    function getVersion() external onlyMetagold view returns(uint256 version)  {
        return createTime;
    }

    function getMaxTokenAllowedToSell(address whoWantsToSell) external onlyMetagold view returns(uint256 maxTokens, uint256 maxTokensFilter, uint256 a1, uint256 a2)  {
        (uint256 mt1, uint256 mt2) = _getMaxTokenAllowedToSell(whoWantsToSell);
        (a1, a2) = getADMLimits(whoWantsToSell, mt1,mt2);
        return (mt1, mt2,a1,a2);
    }

     //to recieve ETH from uniswapV2Router when swaping

    function getPrice(address firstAddress, address secondAddress, address thirdAddress, uint256 inAmount) public view returns (uint256[] memory amounts ) {
        address[] memory path = new address[](3);
        path[0] = firstAddress;
        path[1] = secondAddress;
        path[2] = thirdAddress;
        return uniswapV2Router.getAmountsOut(inAmount, path);
    }
    function getPriceDirect(address firstAddress, address secondAddress, uint256 inAmount) public view returns (uint256[] memory amounts) {
        address[] memory path = new address[](2);
        path[0] = firstAddress;
        path[1] = secondAddress;
        return uniswapV2Router.getAmountsOut(inAmount, path);
    }

    function getMarketCapUSD() public view returns(uint256 marketCap) {
        uint256 totalsupply = metaGold.totalSupply(); 
        uint256 currentPrice;
        if( useDirectWay) {
            currentPrice = getPriceDirect(metaGoldAddress, busdToken, 1 * 10**18)[1];
        }
        else{
            currentPrice = getPrice(metaGoldAddress, uniswapV2Router.WETH(), busdToken, 1 * 10**18)[2];
        }
        uint256 mc = totalsupply.mul(currentPrice).div(1*10**36);
        return mc;
    }

    
    function setMinimalMarketCapUSD(uint256 value) external onlyOwner {
        minimalMarketCap = value;
    }
    function setTwentyFourHours(uint256 value) external onlyOwner {
        TwentyFourhours = value;
    }
    function setUseDirectWay(bool value) external onlyOwner {
        useDirectWay = value;
    }    
    function setUseSecondFromReserves(bool value) external onlyOwner {
        useSecondFromReserves = value;
    }



}


pragma solidity >=0.8.13 <0.9.0;

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

pragma solidity >=0.8.13 <0.9.0;

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



pragma solidity >=0.8 <0.9.0;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }


    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }

 
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

  
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }


    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

pragma solidity >=0.8 <0.9.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity >=0.8 <0.9.0;
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}