/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

/**                                                                     
                           
SHELTERv3 ($SHELTERv3) is the new community-driven buyback deflationary token, putting holder value first with exponentially multiplying reflections in SHIB, BUSD, and Investments while simultaneously harnessing the power of crypto to help end worldwide homelessness. SHELTERv3 becomes scarcer over time while providing five tier levels of stacked rewards. In addition, several safeguards are hardcoded into this Smart Contract to increase holder confidence.  

Website: https://sheltercoin.net/
Telegram: https://t.me/Shelter_Coin
Twitter: https://twitter.com/Shelter_Coin
BSC Testnet: 0x9451BF2bc8Cb17048675f3eE5bb606f4184737f3 

Tokenomics:
10% of every transaction is redistributed to all holders in $SHIB, $BUSD, and Investment Token.
5% of every transaction is transferred into the Liquidity Pool on Pancakeswap to create a stable price floor.
3% of every transaction is sent to the marketing wallet to fund marketing, utility development and community management.
1% of every transaction is used for massive strategic BuyBack & Burn.
1% of every transaction is sent to a public charity wallet to help fight worldwide homelessness.

Tier 1 - 12% Reflections
Tier 2 - 14% Reflections
Tier 3 - 16% Reflections
Tier 4 - 18% Reflections
Tier 5 - 20% Reflections

Features:
- 10 Year Locked Liquidity Pool
- 5 Tiers of Rewards
- BuyBack & Burn
- $BUSD Reflections
- $SHIB Reflections
- Investment Reflections
- Anti-Whale Mechanism
- Community-Driven

*/

//SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

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
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
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

contract DistributorFactory {
    using SafeMath for uint256;
    address _token;

    struct structDistributors {
        DividendDistributor distributorAddress;
        uint256 index;
        string tokenName;
        bool exists;
    }

    mapping(address => structDistributors) public distributorsMapping;
    address[] public distributorsArrayOfKeys;

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor() {
        _token = msg.sender;
    }

    function addDistributor(
        address _router,
        address _BEP_TOKEN,
        address _wbnb
    ) external onlyToken returns (bool) {
        require(
            !distributorsMapping[_BEP_TOKEN].exists,
            "Distributor already exists"
        );

        IBEP20 BEP_TOKEN = IBEP20(_BEP_TOKEN);
        DividendDistributor distributor = new DividendDistributor(
            _router,
            _BEP_TOKEN,
            _wbnb
        );

        distributorsArrayOfKeys.push(_BEP_TOKEN);
        distributorsMapping[_BEP_TOKEN].distributorAddress = distributor;
        distributorsMapping[_BEP_TOKEN].index =
            distributorsArrayOfKeys.length -
            1;
        distributorsMapping[_BEP_TOKEN].tokenName = BEP_TOKEN.name();
        distributorsMapping[_BEP_TOKEN].exists = true;

        // set shares
        if (distributorsArrayOfKeys.length > 0) {
            address firstDistributerKey = distributorsArrayOfKeys[0];

            uint256 shareholdersCount = distributorsMapping[firstDistributerKey]
                .distributorAddress
                .getShareholders()
                .length;

            for (uint256 i = 0; i < shareholdersCount; i++) {
                address shareholderAddress = distributorsMapping[
                    firstDistributerKey
                ].distributorAddress.getShareholders()[i];

                uint256 shareholderAmount = distributorsMapping[
                    firstDistributerKey
                ].distributorAddress.getShareholderAmount(shareholderAddress);

                distributor.setShare(shareholderAddress, shareholderAmount);
            }
        }

        return true;
    }

    function getShareholderAmount(address _BEP_TOKEN, address shareholder)
        external
        view
        returns (uint256)
    {
        return
            distributorsMapping[_BEP_TOKEN]
                .distributorAddress
                .getShareholderAmount(shareholder);
    }

    function deleteDistributor(address _BEP_TOKEN)
        external
        onlyToken
        returns (bool)
    {
        require(
            distributorsMapping[_BEP_TOKEN].exists,
            "Distributor not found"
        );

        structDistributors memory deletedDistributer = distributorsMapping[
            _BEP_TOKEN
        ];

        if (deletedDistributer.index != distributorsArrayOfKeys.length - 1) {
            address lastAddress = distributorsArrayOfKeys[
                distributorsArrayOfKeys.length - 1
            ];
            distributorsArrayOfKeys[deletedDistributer.index] = lastAddress;
            distributorsMapping[lastAddress].index = deletedDistributer.index;
        }
        delete distributorsMapping[_BEP_TOKEN];
        distributorsArrayOfKeys.pop();
        return true;
    }

    function getDistributorsAddresses() public view returns (address[] memory) {
        return distributorsArrayOfKeys;
    }

    function setShare(address shareholder, uint256 amount) external onlyToken {
        uint256 arrayLength = distributorsArrayOfKeys.length;
        for (uint256 i = 0; i < arrayLength; i++) {
            distributorsMapping[distributorsArrayOfKeys[i]]
                .distributorAddress
                .setShare(shareholder, amount);
        }
    }

    function process(uint256 gas) external onlyToken {
        uint256 arrayLength = distributorsArrayOfKeys.length;
        for (uint256 i = 0; i < arrayLength; i++) {
            distributorsMapping[distributorsArrayOfKeys[i]]
                .distributorAddress
                .process(gas);
        }
    }

    function deposit() external payable onlyToken {
        uint256 arrayLength = distributorsArrayOfKeys.length;
        uint256 valuePerToken = msg.value.div(arrayLength);

        for (uint256 i = 0; i < arrayLength; i++) {
            distributorsMapping[distributorsArrayOfKeys[i]]
                .distributorAddress
                .deposit{value: valuePerToken}();
        }
    }

    function getDistributor(address _BEP_TOKEN)
        public
        view
        returns (DividendDistributor)
    {
        return distributorsMapping[_BEP_TOKEN].distributorAddress;
    }

    function getTotalDistributers() public view returns (uint256) {
        return distributorsArrayOfKeys.length;
    }

    function setDistributionCriteria(
        address _BEP_TOKEN,
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyToken {
        distributorsMapping[_BEP_TOKEN]
            .distributorAddress
            .setDistributionCriteria(_minPeriod, _minDistribution);
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

    IBEP20 BEP_TOKEN;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyFactory() {
        require(msg.sender == _token); _;
    }

    constructor(
        address _router,
        address _BEP_TOKEN,
        address _wbnb
    ) {
        router = _router != address(0)
        ? IDEXRouter(_router)
        : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _token = msg.sender;
        BEP_TOKEN = IBEP20(_BEP_TOKEN);
        WBNB = _wbnb;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyFactory {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyFactory {
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

    function deposit() external payable override onlyFactory {
        uint256 balanceBefore = BEP_TOKEN.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(BEP_TOKEN);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = BEP_TOKEN.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyFactory {
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
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
        && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            BEP_TOKEN.transfer(shareholder, amount);
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

    function getShareholders() external view onlyFactory returns (address[] memory) {
        return shareholders;
    }

    function getShareholderAmount(address shareholder) external view returns (uint256) {
        return shares[shareholder].amount;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

contract SHELTERv3 is IBEP20, Auth {
    using SafeMath for uint256;

    uint256 public constant MASK = type(uint128).max;
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address SHIB = 0x2859e4544C4bB03966803b044A93563Bd2D0DD4D;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "SHELTERv3";
    string constant _symbol = "SHELTERv3";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 1_000_000_000_000_000 * (10 ** _decimals);
    uint256 public _maxTxAmount = _totalSupply.div(400); // 0.25%

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address=>bool) blackListed;

    uint256 liquidityFee = 500;
    uint256 buybackFee = 100;
    uint256 reflectionFee = 1000;
    uint256 marketingFee = 300;
    uint256 charityWallet = 100;
    uint256 totalFee = 2000;
    uint256 feeDenominator = 10000;

    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    address public charityWalletReceiver;

    uint256 targetLiquidity = 25;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;

    bool public autoBuybackEnabled = false;
    bool start = false;
    mapping (address => bool) buyBacker;
    uint256 autoBuybackCap;
    uint256 autoBuybackAccumulator;
    uint256 autoBuybackAmount;
    uint256 autoBuybackBlockPeriod;
    uint256 autoBuybackBlockLast;

    DistributorFactory distributor;
    uint256 distributorGas = 950000;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 2000; // 0.005%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        address _WBNBinput = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        WBNB = _WBNBinput;
        address _dexRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        router = IDEXRouter(_dexRouter);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        WBNB = router.WETH();
        distributor = new DistributorFactory();

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        buyBacker[msg.sender] = true;

        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = msg.sender;
        charityWalletReceiver = msg.sender;

        approve(_dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function getDistributorFactory() external view returns (DistributorFactory) {
        return distributor;
    }

    function addDistributor(address _dexRouter, address _BEP_TOKEN, address _WBNB) external authorized {
        distributor.addDistributor(_dexRouter, _BEP_TOKEN, _WBNB);
    }

    function deleteDistributor(address _BEP_TOKEN) external authorized {
        distributor.deleteDistributor(_BEP_TOKEN);
    }

    function getDistributersBEP20Keys() external view returns (address[] memory) {
        return distributor.getDistributorsAddresses();
    }

    function getDistributer(address _BEP_TOKEN) external view returns (DividendDistributor) {
        return distributor.getDistributor(_BEP_TOKEN);
    }

    function getTotalDividends(address _BEP_TOKEN) external view returns (uint256) {
        DividendDistributor singleDistributor = distributor.getDistributor(_BEP_TOKEN);
        return singleDistributor.totalDividends();
    }
  
    function tierLevel() public pure virtual returns (string memory) {
        return "0";
    }

    function tierName() public pure virtual returns (string memory) {
        return "Basic";
    }

    function getChainID() external view returns (uint256) {
        return block.chainid;
    }

    receive() external payable { }
    function donate() external payable {}
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    modifier onlyBuybacker() { require(buyBacker[msg.sender] == true, ""); _; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

         require(blackListed[sender]== false && blackListed[recipient]==false,"account" );

        if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]){
            require(start == true,"Trading not started yet");
        }
           
        checkTxLimit(sender, amount);

        if(shouldSwapBack()){ swapBack(); }
        if(shouldAutoBuyback()){ triggerAutoBuyback(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getTotalFee(bool ) public view returns (uint256) {
        if(launchedAt + 1 >= block.number){ return feeDenominator.sub(1); }
        return totalFee;
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountBNBCharity = amountBNB.mul(charityWallet).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        payable(marketingFeeReceiver).transfer(amountBNBMarketing);
        payable(charityWalletReceiver).transfer(amountBNBCharity);        

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }    

    function shouldAutoBuyback() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && autoBuybackEnabled
        && autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number // After N blocks from last buyback
        && address(this).balance >= autoBuybackAmount;
    }

    function triggerAutoBuyback() internal {
        buyTokens(autoBuybackAmount, DEAD);
        autoBuybackBlockLast = block.number;
        autoBuybackAccumulator = autoBuybackAccumulator.add(autoBuybackAmount);
        if(autoBuybackAccumulator > autoBuybackCap){ autoBuybackEnabled = false; }
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }

    function setAutoBuybackSettings(bool _enabled, uint256 _cap, uint256 _amount, uint256 _period) external authorized {
        autoBuybackEnabled = _enabled;
        autoBuybackCap = _cap;
        autoBuybackAccumulator = 0;
        autoBuybackAmount = _amount;
        autoBuybackBlockPeriod = _period;
        autoBuybackBlockLast = block.number;
    } 

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() public authorized {
        require(launchedAt == 0, "Already Launched");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
    }

    function setTxLimit(uint256 amount) external authorized {
        require(amount >= _totalSupply / 1000);
        _maxTxAmount = amount;
    }

    function setBlacklisted(address account, bool value) external authorized {
        blackListed[account]= value;
    }

    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }
    function startTrading() external authorized {
       start = true;
    }

    function burnTokens(uint256 amount) external authorized {
       uint256 contractBalance = _balances[address(this)];
       require(contractBalance > amount,"Not Enough tokens to burn");

       _transferFrom(address(this),DEAD,amount);

    }

    function TransferBNBsOutfromContract(uint256 amount, address payable receiver) external authorized {
       uint256 contractBalance = address(this).balance;
       require(contractBalance > amount,"Not Enough bnbs");
        receiver.transfer(amount);
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _buybackFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _charityWallet, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        require(liquidityFee >= feeDenominator/100); // 1% or more
        buybackFee = _buybackFee;
        reflectionFee = _reflectionFee;
        require(reflectionFee >= feeDenominator/10); // 10% or more
        marketingFee = _marketingFee;
        charityWallet = _charityWallet;
        require(charityWallet >= feeDenominator/100); // 1% or more
        totalFee = _liquidityFee.add(_buybackFee).add(_reflectionFee).add(_marketingFee).add(_charityWallet);
        feeDenominator = _feeDenominator;
        require(totalFee <= feeDenominator/5); // Fees cannot exceed 20%
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setCharityWallet(address _charityWalletReceiver) external authorized {
        charityWalletReceiver = _charityWalletReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function setDistributionCriteria(address _BEP_TOKEN, uint256 _minPeriod, uint256 _minDistribution) external authorized {
        distributor.setDistributionCriteria(_BEP_TOKEN, _minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external authorized {
         require(gas < 999999);
        distributorGas = gas;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function multiTransfer_Airdrop(
        address from,
        address[] calldata addresses,
        uint256 tokens
    ) external onlyOwner {
        require(
        addresses.length < 2001,
        "GAS Error: max airdrop limit is 2000 addresses"
    ); // to prevent overflow

        uint256 SCCC = tokens * addresses.length;

        require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

        for (uint256 i = 0; i < addresses.length; i++) {
            _basicTransfer(from, addresses[i], tokens);
            if (!isDividendExempt[addresses[i]]) {
                try
                distributor.setShare(addresses[i], balanceOf(addresses[i]))
                {} catch {}
            }
        }

            // Dividend tracker
        if (!isDividendExempt[from]) {
            try distributor.setShare(from, balanceOf(from)) {} catch {}
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event BuybackMultiplierActive(uint256 duration);
}