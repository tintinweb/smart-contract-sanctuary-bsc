/**
 *Submitted for verification at BscScan.com on 2022-05-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

/*


    ██╗   ██╗██╗███████╗██╗     ██████╗ ██╗      ██████╗  ██████╗██╗  ██╗    ████████╗ ██████╗ ██╗  ██╗███████╗███╗   ██╗
    ╚██╗ ██╔╝██║██╔════╝██║     ██╔══██╗██║     ██╔═══██╗██╔════╝██║ ██╔╝    ╚══██╔══╝██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║
     ╚████╔╝ ██║█████╗  ██║     ██║  ██║██║     ██║   ██║██║     █████╔╝        ██║   ██║   ██║█████╔╝ █████╗  ██╔██╗ ██║
      ╚██╔╝  ██║██╔══╝  ██║     ██║  ██║██║     ██║   ██║██║     ██╔═██╗        ██║   ██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║
       ██║   ██║███████╗███████╗██████╔╝███████╗╚██████╔╝╚██████╗██║  ██╗       ██║   ╚██████╔╝██║  ██╗███████╗██║ ╚████║
       ╚═╝   ╚═╝╚══════╝╚══════╝╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝       ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝
                                                                                                                                                                                                                                                    

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface InterfaceLP {
    function sync() external;
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _tokenDecimals
    ) {
        _name = _tokenName;
        _symbol = _tokenSymbol;
        _decimals = _tokenDecimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

interface IDEXRouter {
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
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract WhitelistedRole is Ownable {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "WhitelistedRole: caller does not have the Whitelisted role");
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyOwner {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyOwner {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    //Oceans Finance Mainnet: 0x7769d930BC6B087f960C5D21e34A4449576cf22a
    //Oceans Finance Testnet: 0x3034405C89b321BCbf81A738ea2F55E0FA34f88A

    IERC20 OceansFinance = IERC20(0x3034405C89b321BCbf81A738ea2F55E0FA34f88A); 

    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public currentIndex;

    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 18);

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        router = _router != address(0)
        ? IDEXRouter(_router)
        : IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function rescueToken(address tokenAddress,address _receiver, uint256 tokens) external onlyToken returns (bool success){
        return IERC20(tokenAddress).transfer(_receiver, tokens);
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = OceansFinance.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(OceansFinance);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = OceansFinance.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }


    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            OceansFinance.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

contract YIELDTOKEN is ERC20Detailed, Ownable, WhitelistedRole {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    bool public initialDistributionFinished = false;
    bool public swapEnabled = true;
    bool public autoRebase = false;
    bool public feesOnNormalTransfers = false;
    bool public isLiquidityInBnb = true;

    uint256 public rewardYield = 4252083;
    uint256 public rewardYieldDenominator = 10000000000;
    uint256 public maxSellTransactionAmount = 2500000 * 10 ** 18;

    uint256 public rebaseFrequency = 1800;
    uint256 public nextRebase = block.timestamp + 604800;

    mapping(address => bool) _isFeeExempt;
    address[] public _markerPairs;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => bool ) public isDividendExempt;

    uint256 public constant MAX_FEE_RATE = 20;

    uint256 private constant MAX_REBASE_FREQUENCY = 1800;
    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 1 * 10**9 * 10**DECIMALS;
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_SUPPLY = ~uint128(0);

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public liquidityReceiver = 0xfee1eDA9075244bdD34cf54516F04AE5803a4eC8;
    address public treasuryReceiver = 0xfee2879FAAb37E5662BD5E9D2f211cFc897C7340;
    address public riskFreeValueReceiver = 0xfee3d95BABd86Ca3a071233449F9A4ac32592cBC;
    
    address public externalWallet = 0x743C63aC0196BeFB98264f97BA784Ab3c71a18FE;

    //Testnet BUSD : 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    //Mainnet BUSD : 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56

    address public busdToken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

    IDEXRouter public router;
    address public pair;

    uint256 public _buyliquidityFee = 2;
    uint256 public _buytreasuryFee = 3;
    uint256 public _buyFeeRFV = 3;
    uint256 public _buyrewardFee = 3;
    uint256 public _buyexternalFee = 1;

    uint256 public _sellliquidityFee = 3;
    uint256 public _selltreasuryFee = 4;
    uint256 public _sellFeeRFV = 4;
    uint256 public _sellrewardFee = 5;
    uint256 public _sellexternalFee = 1;

    // uint256 public transferFee = 10;   
    
    uint256 public totalBuyFee = _buyliquidityFee.add(_buytreasuryFee).add(_buyFeeRFV).add(_buyrewardFee).add(_buyexternalFee);
    uint256 public totalSellFee = _sellliquidityFee.add(_selltreasuryFee).add(_sellFeeRFV).add(_sellrewardFee).add(_sellexternalFee);
    
    uint256 public totalDistribution = totalBuyFee.add(totalSellFee);

    uint256 public feeDenominator = 100;

    uint256 targetLiquidity = 50;
    uint256 targetLiquidityDenominator = 100;

    bool inSwap;
    uint256 public txfee = 1;

    DividendDistributor distributor;
    address public YieldDividendReceiver;
    uint256 distributorGas = 500000;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    struct user {
        uint256 firstBuy;
        uint256 lastTradeTime;
        uint256 tradeAmount;
    }

    uint256 public TwentyFourhours = 600;

    mapping(address => user) public tradeData;
    
    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    uint256 private gonSwapThreshold = (TOTAL_GONS * 10) / 10000;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    constructor() ERC20Detailed("YieldLock", "YLF", uint8(DECIMALS)) {

        //Pancake Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        //Pancake Testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3

        address _routerAdr = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

        router = IDEXRouter(_routerAdr);

        pair = IDEXFactory(router.factory()).createPair(address(this), router.WETH());
        address pairBusd = IDEXFactory(router.factory()).createPair(address(this), busdToken);

        distributor = new DividendDistributor(_routerAdr);
        YieldDividendReceiver = address(distributor);

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        _allowedFragments[address(this)][pair] = uint256(-1);
        _allowedFragments[address(this)][address(this)] = uint256(-1);
        _allowedFragments[address(this)][pairBusd] = uint256(-1);

        setAutomatedMarketMakerPair(pair, true);
        setAutomatedMarketMakerPair(pairBusd, true);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        isDividendExempt[msg.sender] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;

        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[riskFreeValueReceiver] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[msg.sender] = true;

        IERC20(busdToken).approve(address(router), uint256(-1));
        IERC20(busdToken).approve(address(pairBusd), uint256(-1));
        IERC20(busdToken).approve(address(this), uint256(-1));

        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner_, address spender) external view override returns (uint256){
        return _allowedFragments[owner_][spender];
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function checkSwapThreshold() external view returns (uint256) {
        return gonSwapThreshold.div(_gonsPerFragment);
    }

    function shouldRebase() internal view returns (bool) {
        return nextRebase <= block.timestamp;
    }

    function shouldTakeFee(address from, address to) internal view returns (bool) {
        if(_isFeeExempt[from] || _isFeeExempt[to]){
            return false;
        }else if (feesOnNormalTransfers){
            return true;
        }else{
            return (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]);
        }
    }

    function shouldSwapBack() internal view returns (bool) {
        return
        !automatedMarketMakerPairs[msg.sender] &&
        !inSwap &&
        swapEnabled &&
        totalBuyFee.add(totalSellFee) > 0 &&
        _gonBalances[address(this)] >= gonSwapThreshold;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(_gonsPerFragment);
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256){
        uint256 liquidityBalance = 0;
        for(uint i = 0; i < _markerPairs.length; i++){
            liquidityBalance.add(balanceOf(_markerPairs[i]).div(10 ** 9));
        }
        return accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply().div(10 ** 9));
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool){
        return getLiquidityBacking(accuracy) > target;
    }

    function manualSync() public {
        for(uint i = 0; i < _markerPairs.length; i++){
            InterfaceLP(_markerPairs[i]).sync();
        }
    }

    function transfer(address to, uint256 value) external override validRecipient(to) returns (bool){
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);

        emit Transfer(from, to, amount);

        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];

        require(initialDistributionFinished || excludedAccount, "Trading not started");

        
        if (
            automatedMarketMakerPairs[recipient] &&
            !excludedAccount
        ) {
            require(amount <= maxSellTransactionAmount, "Error amount");

            uint blkTime = block.timestamp;
          
            uint256 onePercent = balanceOf(sender).mul(txfee).div(100); //Should use variable
            require(amount <= onePercent, "ERR: Can't sell more than 1%");
            
            if( blkTime > tradeData[sender].lastTradeTime + TwentyFourhours) {
                tradeData[sender].lastTradeTime = blkTime;
                tradeData[sender].tradeAmount = amount;
            }
            else if( (blkTime < tradeData[sender].lastTradeTime + TwentyFourhours) && (( blkTime > tradeData[sender].lastTradeTime)) ){
                require(tradeData[sender].tradeAmount + amount <= onePercent, "ERR: Can't sell more than 1% in One day");
                tradeData[sender].tradeAmount = tradeData[sender].tradeAmount + amount;
            }
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);

        if (shouldSwapBack()) {
            swapBack();
        }

        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);

        uint256 gonAmountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, gonAmount) : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived);

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );

        if(shouldRebase() && autoRebase) {
            _rebase();

            if(!automatedMarketMakerPairs[sender] && !automatedMarketMakerPairs[recipient]){
                manualSync();
            }
        }

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, balanceOf(sender)) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, balanceOf(recipient)) {} catch {} }

        try distributor.process(distributorGas) {} catch {}

        return true;
    }

    function transferFrom(address from, address to, uint256 value) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
            msg.sender
            ].sub(value, "Insufficient Allowance");
        }

        _transferFrom(from, to, value);
        return true;
    }

    function _swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        if(isLiquidityInBnb){
            uint256 initialBalance = address(this).balance;

            _swapTokensForBNB(half, address(this));

            uint256 newBalance = address(this).balance.sub(initialBalance);

            _addLiquidity(otherHalf, newBalance);

            emit SwapAndLiquify(half, newBalance, otherHalf);
        }else{
            uint256 initialBalance = IERC20(busdToken).balanceOf(address(this));

            _swapTokensForBusd(half, address(this));

            uint256 newBalance = IERC20(busdToken).balanceOf(address(this)).sub(initialBalance);

            _addLiquidityBusd(otherHalf, newBalance);

            emit SwapAndLiquifyBusd(half, newBalance, otherHalf);
        }
    }

    function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidityReceiver,
            block.timestamp
        );
    }
    function _addLiquidityBusd(uint256 tokenAmount, uint256 busdAmount) private {
        router.addLiquidity(
            address(this),
            busdToken,
            tokenAmount,
            busdAmount,
            0,
            0,
            liquidityReceiver,
            block.timestamp
        );
    }

    function _swapTokensForBNB(uint256 tokenAmount, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }
    function _swapTokensForBusd(uint256 tokenAmount, address receiver) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = busdToken;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }

    function swapBack() internal swapping {

        uint256 realTotalFee = totalDistribution;

        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : _buyliquidityFee.add(_sellliquidityFee);
        uint256 contractTokenBalance = _gonBalances[address(this)].div(_gonsPerFragment);

        uint256 amountToLiquify = contractTokenBalance.mul(dynamicLiquidityFee).div(realTotalFee);

        uint256 amountToTreasury = contractTokenBalance.mul(_buytreasuryFee.add(_selltreasuryFee)).div(realTotalFee);
        uint256 amountToRFV = contractTokenBalance.mul(_buyFeeRFV.add(_sellFeeRFV)).div(realTotalFee);
        uint256 amountToReward = contractTokenBalance.mul(_buyrewardFee.add(_sellrewardFee)).div(realTotalFee);

        uint256 amountToExternal = contractTokenBalance.sub(amountToLiquify).sub(amountToRFV).sub(amountToTreasury).sub(amountToReward);

        if(amountToLiquify > 0){
            _swapAndLiquify(amountToLiquify);
        }

        if(amountToRFV > 0){
            _swapTokensForBusd(amountToRFV, riskFreeValueReceiver);
        }

        if(amountToTreasury > 0){
            _swapTokensForBNB(amountToTreasury, externalWallet);
        }

        if(amountToReward > 0) {
            uint bal = address(this).balance;
            _swapTokensForBNB(amountToReward,address(this));
            uint recBal = address(this).balance.sub(bal);
                
            try distributor.deposit { value: recBal } () {} catch {}
        }

        if(amountToExternal > 0) {
            _swapTokensForBNB(amountToExternal, treasuryReceiver);
        }

        emit SwapBack(contractTokenBalance, amountToLiquify, amountToRFV, amountToTreasury);
    }

    function takeFee(address sender, address recipient, uint256 gonAmount) internal returns (uint256){
        uint256 _realFee = 10;
        if(automatedMarketMakerPairs[sender]) _realFee = totalBuyFee;
        if(automatedMarketMakerPairs[recipient]) _realFee = totalSellFee;

        uint256 feeAmount = gonAmount.mul(_realFee).div(feeDenominator);

        _gonBalances[address(this)] = _gonBalances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));

        return gonAmount.sub(feeAmount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool){
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool){
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
        spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool){
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function _rebase() private {
        if(!inSwap) {
            uint256 circulatingSupply = getCirculatingSupply();
            int256 supplyDelta = int256(circulatingSupply.mul(rewardYield).div(rewardYieldDenominator));

            coreRebase(supplyDelta);
        }
    }

    function coreRebase(int256 supplyDelta) private returns (uint256) {
        uint256 epoch = block.timestamp;

        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
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

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        nextRebase = epoch + rebaseFrequency;

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    function manualRebase() external onlyWhitelisted{
        require(!inSwap, "Try again");
        require(nextRebase <= block.timestamp, "Not in time");

        uint256 circulatingSupply = getCirculatingSupply();
        int256 supplyDelta = int256(circulatingSupply.mul(rewardYield).div(rewardYieldDenominator));

        coreRebase(supplyDelta);
        manualSync();
    }

    function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyOwner {
        require(automatedMarketMakerPairs[_pair] != _value, "Value already set");

        automatedMarketMakerPairs[_pair] = _value;

        if(_value){
            _markerPairs.push(_pair);
        }else{
            require(_markerPairs.length > 1, "Required 1 pair");
            for (uint256 i = 0; i < _markerPairs.length; i++) {
                if (_markerPairs[i] == _pair) {
                    _markerPairs[i] = _markerPairs[_markerPairs.length - 1];
                    _markerPairs.pop();
                    break;
                }
            }
        }

        emit SetAutomatedMarketMakerPair(_pair, _value);
    }

    function setInitialDistributionFinished(bool _value) external onlyOwner {
        require(initialDistributionFinished != _value, "Not changed");
        initialDistributionFinished = _value;
    }

    function setFeeExempt(address _addr, bool _value) external onlyOwner {
        require(_isFeeExempt[_addr] != _value, "Not changed");
        _isFeeExempt[_addr] = _value;
    }

    function setTxFee(uint _addr) external onlyOwner {
        txfee = _addr;
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;

        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, balanceOf(holder));
        }
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000, "Gas must be lower than 750000");
        distributorGas = gas;
    }

    function setTwentyFourhours(uint256 _time) external onlyOwner {
        TwentyFourhours = _time;
    }

    function setTargetLiquidity(uint256 target, uint256 accuracy) external onlyOwner {
        targetLiquidity = target;
        targetLiquidityDenominator = accuracy;
    }

    function setSwapBackSettings(bool _enabled, uint256 _num, uint256 _denom) external onlyOwner {
        swapEnabled = _enabled;
        gonSwapThreshold = TOTAL_GONS.div(_denom).mul(_num);
    }

    function setFeeReceivers(address _liquidityReceiver, address _treasuryReceiver, address _riskFreeValueReceiver) external onlyOwner {
        liquidityReceiver = _liquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        riskFreeValueReceiver = _riskFreeValueReceiver;
    }

    function setFees(uint _buyliq, uint _buyTreasure, uint _buyRFV, uint _buyReward,
        uint _sellliq, uint _sellTreasure, uint _sellRFV, uint _sellReward,
        uint256 _feeDenominator) external onlyOwner {

        require(
            _buyliq <= MAX_FEE_RATE &&
            _buyTreasure <= MAX_FEE_RATE &&
            _buyRFV <= MAX_FEE_RATE &&
            _buyReward <= MAX_FEE_RATE &&

            _sellliq <= MAX_FEE_RATE &&
            _sellTreasure <= MAX_FEE_RATE &&
            _sellRFV <= MAX_FEE_RATE &&
            _sellReward <= MAX_FEE_RATE ,


            "wrong"
        );

        _buyliquidityFee = _buyliq;
        _buytreasuryFee = _buyTreasure;
        _buyFeeRFV = _buyRFV;
        _buyrewardFee = _buyReward;

        _sellliquidityFee = _sellliq;
        _selltreasuryFee = _sellTreasure;
        _sellFeeRFV = _sellRFV;
        _sellrewardFee = _sellReward;

    
        totalBuyFee = _buyliquidityFee.add(_buytreasuryFee).add(_buyFeeRFV).add(_buyrewardFee).add(_buyexternalFee);
        totalSellFee = _sellliquidityFee.add(_selltreasuryFee).add(_sellFeeRFV).add(_sellrewardFee).add(_sellexternalFee);
    
        totalDistribution = totalBuyFee.add(totalSellFee);
        feeDenominator = _feeDenominator;

        require(totalBuyFee < feeDenominator / 4);
    }

    function clearStuckBalance(address _receiver) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
    }

    function rescueToken(address tokenAddress,address _receiver, uint256 tokens) external onlyOwner returns (bool success){
        return ERC20Detailed(tokenAddress).transfer(_receiver, tokens);
    }

    function rescueDividentToken(address tokenAddress,address _receiver, uint256 tokens) external onlyOwner  returns (bool success) {
        return distributor.rescueToken(tokenAddress, _receiver,tokens);
    }

    function setAutoRebase(bool _autoRebase) external onlyOwner {
        require(autoRebase != _autoRebase, "Not changed");
        autoRebase = _autoRebase;
    }

    function setRebaseFrequency(uint256 _rebaseFrequency) external onlyOwner {
        require(_rebaseFrequency <= MAX_REBASE_FREQUENCY, "Too high");
        rebaseFrequency = _rebaseFrequency;
    }

    function setRewardYield(uint256 _rewardYield, uint256 _rewardYieldDenominator) external onlyOwner {
        rewardYield = _rewardYield;
        rewardYieldDenominator = _rewardYieldDenominator;
    }

    function setFeesOnNormalTransfers(bool _enabled) external onlyOwner {
        require(feesOnNormalTransfers != _enabled, "Not changed");
        feesOnNormalTransfers = _enabled;
    }

    function setIsLiquidityInBnb(bool _value) external onlyOwner {
        require(isLiquidityInBnb != _value, "Not changed");
        isLiquidityInBnb = _value;
    }

    function setNextRebase(uint256 _nextRebase) external onlyOwner {
        nextRebase = _nextRebase;
    }

    function setMaxSellTransaction(uint256 _maxTxn) external onlyOwner {
        maxSellTransactionAmount = _maxTxn;
    }

    event SwapBack(uint256 contractTokenBalance,uint256 amountToLiquify,uint256 amountToRFV,uint256 amountToTreasury);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event SwapAndLiquifyBusd(uint256 tokensSwapped, uint256 busdReceived, uint256 tokensIntoLiqudity);
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
}