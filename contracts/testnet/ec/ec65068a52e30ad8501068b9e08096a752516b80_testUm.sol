/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

pragma solidity ^0.8.7;
//SPDX-License-Identifier: UNLICENCED

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
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
    
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

interface IpresaleAirdrop {
    function airdropPresale(address recipient, uint256 amount) external;
}

contract ManualDividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;
    mapping(address => bool) adminAccounts;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
   
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    
    IBEP20 public rewardtoken = IBEP20(WBNB);
    mapping (address => uint256) totaldividendsOfToken;
    IDEXRouter router;

    address[] public shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;
    mapping (address => mapping (address => Share)) public rewardshares;

    uint256 public totalShares;
    //uint256 public totalDividends;
    uint256 public totalDistributed;
    //uint256 public dividendsPerShare;
    mapping (address => uint256) public dividendsPerShareRewardToken;
    mapping (address => uint256) public totaldividendsrewardtoken;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 public currentIndex;

    bool initialized = false; // unneccesary as all booleans are initialiased to false;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyAdmin() {
        require(adminAccounts[msg.sender]); _;
    }

    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); //Mainnet
            //: IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //Testnet
        adminAccounts[msg.sender] = true;
        rewardtoken = IBEP20(_token);
    }

    function distributeToken(address[] calldata holders) external onlyAdmin {
        for(uint i = 0; i < holders.length; i++){
            if(shares[holders[i]].amount > 10000){ 
                distributeDividend(holders[i]);
            }
        }
    }
    

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyAdmin {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }
    
    function setRewardToken(IBEP20 newrewardToken) external onlyAdmin{
        rewardtoken = newrewardToken;
    }
    
    function addAdmin(address adminAddress) public onlyAdmin{
        adminAccounts[adminAddress] = true;
    }
    
    
    function removeAdmin(address adminAddress) public onlyAdmin{
        adminAccounts[adminAddress] = false;
    }
    
    
    function setInitialShare(address shareholder, uint256 amount) external onlyAdmin {
        addShareholder(shareholder);
        totalShares += amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }
    
    function setShareMultiple(address[] calldata addresses, uint256[] calldata amounts) external onlyAdmin
    {
        require(addresses.length == amounts.length, "must have the same length");
        for (uint i = 0; i < addresses.length; i++){
            setShareInternal(addresses[i], amounts[i]*(10**18));
        }
    }
    
    function setShareInternal(address shareholder, uint256 amount) internal {
        
        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares += (shares[shareholder].amount) + (amount);
        shares[shareholder].amount = amount;
        rewardshares[WBNB][shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function setShare(address shareholder, uint256 amount) external override onlyAdmin {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }
        
        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares -= (shares[shareholder].amount);
        shares[shareholder].amount = amount;
        totalShares += (amount);
        rewardshares[WBNB][shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override {
        totaldividendsOfToken[WBNB] = totaldividendsOfToken[WBNB] + msg.value;
        dividendsPerShareRewardToken[WBNB] = dividendsPerShareRewardToken[WBNB] + (dividendsPerShareAccuracyFactor * (msg.value) / (totalShares));
    }

    function process(uint256 gas) external override {
        // this shouldnt be called from outside
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            payable(shareholder).transfer(amount);
            shareholderClaims[shareholder] = block.timestamp;
            rewardshares[WBNB][shareholder].totalRealised  += (amount);
            rewardshares[WBNB][shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = rewardshares[WBNB][shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends - (shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share * dividendsPerShareRewardToken[WBNB] / dividendsPerShareAccuracyFactor;
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

contract testUm is IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "TestHG";
    string constant _symbol = "Test";
    uint8 constant _decimals = 18;

    struct historicalsells {
        address user;
        uint256[] amount;
    }

    uint256 _totalSupply = 1 * 10**11* (10 ** _decimals); //100 bil
    uint256 public _maxTxAmount = _totalSupply / 100; // 1%
    uint256 public _maxSellTxAMount = _totalSupply / 100; // 1%
    uint256 public _maxHoldAmount = _totalSupply / 100; // 1%

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) isMaxHoldExempt;
    mapping (address => bool) isHolder;
    mapping (address => uint) holderIndex;
    mapping (address => bool) canSell;
    mapping (address => bool) taxTaken;
    
    address[] holders;
    address[] players;
    address[] public canSellers;
    historicalsells[] public historicalSells;

    /* @dev   
        all fees are set wwith 2 decimal places added, please remember this when setting fees.
    */
    uint256 public gameCount = 20;
    uint256 public randomDivisor = 80;
    uint256 public liquidityFee = 100;
    uint256 public reflectionFee = 300;
    uint256 public developmentfee = 1100;
    uint256 public totalFee = 1500;
    uint256 public feeDenominator = 10000;

    address public autoLiquidityReceiver;
    address public devFeeReciever;

    IDEXRouter public router;
    address public pair;
    mapping (address => bool) public pairs;
    address public presaleContract;

    bool public canTrade = false;
    uint256 public launchedAt;

    ManualDividendDistributor public distributor;
    uint256 distributorGas = 500000;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 100; // 1%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor (
    ) Auth(msg.sender) {
        //router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); //Mainnet
        router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); //Testnet
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        pairs[pair] = true;
        _allowances[address(this)][address(router)] = _totalSupply;
        isMaxHoldExempt[pair] = true;
        

        distributor = new ManualDividendDistributor(address(router));
        distributor.addAdmin(address(msg.sender));

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        isTxLimitExempt[msg.sender] = true;
        isFeeExempt[msg.sender] = true;
        authorizations[msg.sender] = true;
        
        autoLiquidityReceiver = msg.sender;
        devFeeReciever = msg.sender;
        owner = msg.sender;
        isMaxHoldExempt[owner] = true;
        _balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender];} 
    
    function getEstimatedTokenForBnb(uint bnbAmount) public view returns (uint[] memory) {
            address[] memory path = new address[](2);
            path[0] = router.WETH();
            path[1] = address(this);
        return router.getAmountsOut(bnbAmount, path);
    }
    
    function getEstimatedBnbForToken(uint megaAmount) public view returns (uint[] memory) {
            address[] memory path = new address[](2);
            path[1] = router.WETH();
            path[0] = address(this);
        return router.getAmountsOut(megaAmount, path);
    }   

    function addHolder(address Player)internal {
        holderIndex[Player] = holders.length;
        holders.push(Player);
        isHolder[Player] = true;
    }

     function removeHolder(address Player)internal {
        delete isHolder[Player];
        uint idx = holderIndex[Player];
        address oldUser = holders[holders.length - 1];
        holders[idx] = oldUser;
        holderIndex[oldUser] = idx;
        holders.pop();
        delete holderIndex[Player];
    }

    function checkStatus()internal {
        bool selectRandomHolder = holders.length >= gameCount;
        uint AmountToRandomlyGenerate = 1;
        if(holders.length > 50){
            AmountToRandomlyGenerate = holders.length / randomDivisor;
        }
        // check for game status
        if(players.length >= gameCount){
            // this is where we select a random number
            uint idx = uint256((keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)))) % players.length;
            if(!canSell[players[idx]] ){
                canSell[players[idx]] = true;
                canSellers.push(players[idx]);
            }
            if(selectRandomHolder){
                uint idx2 = 0;
                for(uint i = 1; i <= AmountToRandomlyGenerate; i++){
                    idx2 = uint256((keccak256(abi.encodePacked(block.difficulty, block.timestamp, holders, i)))) % (holders.length - players.length) ;
                    if(!canSell[players[idx2]] ){
                        canSell[players[idx2]] = true;
                        canSellers.push(players[idx2]);
                    }
                }
               
            }
            delete players;
        }
    }
    function setRandomDivisor(uint divisor)external authorized{
        require(divisor >= 80);
        randomDivisor = divisor;
    }

    function setGameLength(uint length)external authorized{
        require(length > 20 && length <= 30);
        gameCount = length;
    }

    function removeFromSellers(address seller)internal {
        for(uint i = 0; i < canSellers.length; i++){
            if(canSellers[i] == seller){
                canSellers[i] = canSellers[canSellers.length - 1];
                canSellers.pop();
            }
        }
    }
    
    function buyTokens(uint amountOutMin)public payable {
        require(launched());
        address[] memory path = new address[](2);
            path[0] = router.WETH();
            path[1] = address(this);
            uint deadline = block.timestamp + 100;
            uint devTaxValue = msg.value.mul(totalFee).div(feeDenominator);
            payable(devFeeReciever).transfer(devTaxValue);
            taxTaken[msg.sender] = true;
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: msg.value - devTaxValue }(amountOutMin, path, address(msg.sender), deadline);
            checkStatus();
    }

    function sellTokens(uint amount)public{
        require(canSell[msg.sender]);
        require(balanceOf(msg.sender) >= amount);
        require(launched());
        address[] memory path = new address[](2);
            path[1] = router.WETH();
            path[0] = address(this);
            uint deadline = block.timestamp + 100;
        uint balancebefore = address(this).balance;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            deadline
        );
        uint balanceAfter = address(this).balance;
        
        uint selltax = (balanceAfter - balancebefore).mul(200).div(10000);
        payable(devFeeReciever).transfer(selltax);
        taxTaken[msg.sender] = true;
        payable(msg.sender).transfer(balanceAfter - balancebefore - selltax);
        canSell[msg.sender] = false;
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function setDistributor(ManualDividendDistributor dist)external authorized {
        distributor = dist;
    }

    function setSwapThresholdDivisor(uint divisor)external authorized {
        require(divisor >= 100, "HungerGains: max sell percent is 1%");
        swapThreshold = _totalSupply / divisor;
    }
    
    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }
    
    function setmaxholdpercentage(uint256 percentage) external authorized {
        require(percentage >= 1); // cant change percentage below 0, so everyone can hold the percentage
        _maxHoldAmount = _totalSupply * percentage / 100; // percentage based on amount
    }
    
    function allowtrading()external authorized {
        canTrade = true;
    }
    
    function addNewPair(address newPair)external authorized{
        pairs[newPair] = true;
        isMaxHoldExempt[newPair] = true;
        isDividendExempt[newPair] = true;
    }
    
    function removePair(address pairToRemove)external authorized{
        pairs[pairToRemove] = false;
        isMaxHoldExempt[pairToRemove] = false;
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != uint256(_totalSupply)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        if(!canTrade){
            require(sender == owner || sender == presaleContract); // only owner allowed to trade or add liquidity
        }
        if(sender != owner && recipient != owner){
            if(!pairs[recipient] && !isMaxHoldExempt[recipient]){
                require (balanceOf(recipient) + amount <= _maxHoldAmount, "cant hold more than max hold dude, sorry");
            }
        }
        
        
        if(shouldSwapBack()){ swapBack(); }
        
        checkTxLimit(sender, recipient, amount);
        
        if(!launched() && pairs[recipient]){ require(_balances[sender] > 0); launch(); }
        require(pairs[sender] || pairs[recipient], "cant transfer, can only buy or sell");
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = 0;
        if(pairs[sender]){ // its a buy
            if(!isHolder[recipient]){
                addHolder(recipient);
            }
            players.push(recipient);
            if(taxTaken[recipient]){
                amountReceived = amount;
                taxTaken[recipient] = false;
            }else{
                amountReceived = takeFee(sender, amount);
            }
            checkStatus();
        }
        if(pairs[recipient]){
            require(canSell[sender], "You arent allowed to sell, Your number hasnt come up yet");
            if(balanceOf(sender) <= 0){
                removeHolder(sender);
            }
            canSell[sender] = false;
            if(taxTaken[sender]){
                amountReceived = amount;
                taxTaken[sender] = false;
            }else{
                amountReceived = takeFee(sender, amount);
            }
            historicalSells.push(historicalsells(sender, getEstimatedBnbForToken(amount)));
            emit TokenSold(sender, amount);
        }
        

        _balances[recipient] = _balances[recipient].add(amountReceived);

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, address reciever, uint256 amount) internal view {
        if(sender != owner && reciever != owner){
            require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
        }
    }

    function shouldTakeFee(address endpt) internal view returns (bool) {
        return !isFeeExempt[endpt];
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);
        
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }
    
    // returns any mis-sent tokens to the marketing wallet
    function claimtokensback(IBEP20 tokenAddress) external authorized {
        payable(devFeeReciever).transfer(address(this).balance);
        tokenAddress.transfer(devFeeReciever, tokenAddress.balanceOf(address(this)));
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.timestamp;
    }

    function setTxLimit(uint256 amount) external authorized {
        require(amount >= _totalSupply / 1000);
        _maxTxAmount = amount;
    }

    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && !pairs[holder]);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _devFee,uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        developmentfee = _devFee;
        totalFee = _liquidityFee.add(_reflectionFee).add(developmentfee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/4); // cant be over 25% of total.
    }
    
    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2); // leave some tokens for liquidity addition
        uint256 amountToSwap = balanceOf(address(this)).sub(amountToLiquify); // swap everything bar the liquidity tokens. we need to add a pair

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
        
        if(reflectionFee > 0){
            uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
            try distributor.deposit{value: amountBNBReflection}() {} catch {}
        }
        
        uint256 amountBNBDev = amountBNB.mul(developmentfee).div(totalBNBFee);
        payable(devFeeReciever).transfer(amountBNBDev);
        
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

    function setFeeReceivers(address _autoLiquidityReceiver, address devWallet) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        devFeeReciever = devWallet;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }
    
    function shouldSwapBack() internal view returns (bool) {
        return !pairs[msg.sender]
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }


    event AutoLiquify(uint256 amountBNB, uint256 amount);
    event TokenSold(address indexed seller, uint256 indexed amount);
    
    
}