/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.5;

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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

/**
 * BEP20 standard interface.
 */
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
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, bool _enabled) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit(uint256 amount) external;
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

    IBEP20 public RWRD = IBEP20(0xa0f3038b2Df4911C329F8ddf37b0c4DDe620D6B5);

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    bool public distributionEnabled = true;

    uint256 public minPeriod = 45 * 60;
    uint256 public minDistribution = 2 * (10 ** 18);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
       require(msg.sender == _token); _;
    }

    constructor () {
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, bool _enabled) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
        distributionEnabled = _enabled;
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

    function deposit(uint256 amount) external override onlyToken {
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0 || !distributionEnabled) { return; }

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
        if(shares[shareholder].amount == 0 || !distributionEnabled) { return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            RWRD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function rescueToken(address tokenAddress, uint256 tokens) public onlyToken returns (bool success) {
        if(tokens == 0){
            tokens = IBEP20(tokenAddress).balanceOf(address(this));
        }
        return IBEP20(tokenAddress).transfer(msg.sender, tokens);
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

contract NODE is IBEP20, Ownable {
    using SafeMath for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address WAVAX = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address USDC = 0xDe9334C157968320f26e449331D6544b89bbD00F;
    address WAVAX_USDC = 0x35353e94B041A6731D69203752B4b5a10053Ca95;
    uint256 precision = 10 ** 36;
    uint256 Decimals = 10 ** 18;

    IBEP20 public Reward = IBEP20(0xa0f3038b2Df4911C329F8ddf37b0c4DDe620D6B5);

    string constant _name = "NODE";
    string constant _symbol = "Node";
    string constant ContractCreator = "@FrankFourier";
    uint8 constant _decimals = 0;

    uint256 _totalSupply;

    uint256 public _maxTxAmount = _totalSupply;
    uint256 public _maxWalletToken = _totalSupply;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    bool public blacklistMode = false;
    bool public paused = true;
    bool public contractSendEnabled = false;
    mapping (address => bool) public isBlacklisted;

    uint256 public MAX_Nodes = 2000;
    uint256 public MAX_BY_MINT = 20;
    uint256 public nodePrice = 100 * 10**18;
    uint256 public discount = 10;
    uint256 public percent = 100;

    uint256 public _WAVAX = IBEP20(WAVAX).balanceOf(WAVAX_USDC);
    uint256 public _USDC = IBEP20(USDC).balanceOf(WAVAX_USDC);
    uint256 internal price_WAVAX;

    uint256 public launchedAt = 0;

    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) isMaxWalletExempt;

    address public treasury;
    bool public tradingOpen = false;

    DividendDistributor public distributor;
    uint256 distributorGas = 500000;

    modifier saleIsOpen {
        require(_totalSupply <= MAX_Nodes, "Sale end");
        if (msg.sender != owner) {
            require(!paused, "Pausable: paused");
        }
        _;
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }

    constructor () Ownable(msg.sender) {
        distributor = new DividendDistributor();

        isTxLimitExempt[msg.sender] = true;

        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        treasury = 0x115131a15102E4A6D42e64Faa0637230Ed6e1A4F; 

        isMaxWalletExempt[msg.sender] = true;
        isMaxWalletExempt[address(this)] = true;
        isMaxWalletExempt[DEAD] = true;
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        uint256 usrAllowance = _allowances[sender][msg.sender];
        if(usrAllowance != type(uint256).max ){
            usrAllowance = usrAllowance.sub(amount,"Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        require(account != address(0), 'BEP20: burn from the zero address');

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);

        if(!isDividendExempt[account]) {
            try distributor.setShare(account, _balances[account]) {} catch {}
        }
        emit Transfer(account, address(0), amount);
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function CreateNode_Tokens(address account, uint256 _count) public saleIsOpen {
        require(IBEP20(Reward).allowance(msg.sender, address(this)) >= _count, "Allowance?");
        require(account != address(0), "BEP20: mint to the zero address");
        uint256 total = _totalSupply;
        require(total + _count <= MAX_Nodes, "Max limit");
        require(total <= MAX_Nodes, "Sale end");
        require(_count <= MAX_BY_MINT, "Exceeds number");
        uint256 balance = Reward.balanceOf(msg.sender);
        require(balance >= price_Tokens(_count), "Value below price");
        IBEP20(Reward).transferFrom(msg.sender, address(this), price_Tokens(_count));
        _totalSupply = _totalSupply.add(_count);
        _balances[account] = _balances[account].add(_count);

        if(!isDividendExempt[account]) {
            try distributor.setShare(account, _balances[account]) {} catch {}
        }
        emit Transfer(address(0), account, _count);
    }
    
    function getprice_count_AVAX(uint256 _count) public view returns (uint256) {
        uint256 _price = getprice_AVAX();
        return _price.mul(_count);
    }

    function price_Tokens(uint256 _count) public view returns (uint256) {
        return nodePrice.mul(_count);
    }

    function getprice_AVAX() public view returns (uint256) {
        return(_USDC.mul(precision).div(_WAVAX));
    }

    function updateDiscount(uint256 newdiscount) external onlyOwner {
        require(newdiscount < 100);
        discount = newdiscount;
    }

    function updateprice_Tokens(uint256 newPrice) external onlyOwner {
        nodePrice = newPrice;
    }

    function setMaxWallet(uint256 amount) external onlyOwner {
        _maxWalletToken = amount;
    }

    function setMaxTx(uint256 amount) external onlyOwner {
        _maxTxAmount = amount;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

            if(sender != owner && recipient != owner){            
            require(tradingOpen,"Trading not open yet");
            if(!contractSendEnabled && isContract(recipient) && sender != address(this)) {
                revert("Can't add Liquidity");
            }
        }

        // Blacklist
        if(blacklistMode){
            require(!isBlacklisted[sender] && !isBlacklisted[recipient],"Blacklisted");    
        }


        if (sender != owner && recipient != owner  && recipient != address(this) && sender != address(this) && recipient != address(DEAD) ){

            require(amount <= _maxTxAmount || isTxLimitExempt[sender],"TX Limit Exceeded");
            require((amount + balanceOf(recipient)) <= _maxWalletToken || isMaxWalletExempt[recipient],"Max wallet holding reached");
        }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, _balances[recipient]) {} catch {} 
        }

        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function distributeRewards() external onlyOwner {
        try distributor.process(distributorGas) {} catch {}  
    }

    function clearBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    function withdrawTokens(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        if(tokens == 0){
            tokens = IBEP20(tokenAddress).balanceOf(address(this));
        }
        return IBEP20(tokenAddress).transfer(msg.sender, tokens);
    }

    // switch Trading
    function tradingStatus() public onlyOwner {
        tradingOpen = true;
        launchedAt = block.number;
    }

    function isContract(address _target) internal view returns (bool) {
        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }

    function depositRewards(uint256 _amount) external onlyOwner {
        require(IBEP20(Reward).allowance(msg.sender, address(this)) >= _amount, "Allowance?");

        // Transfer rewards to contract for distributing
        bool transferred = IBEP20(Reward).transferFrom(msg.sender, address(this), _amount);
        require(transferred, "Not transferred");

        try distributor.deposit(_amount) {} catch {}
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this));
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function enable_blacklist(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

    function manage_blacklist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setTreasury(address _Treasury ) external onlyOwner {
        treasury = _Treasury;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, bool _enabled) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution, _enabled);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        distributorGas = gas;
    }

    function isExcludedFromTxLimit(address account) public view returns(bool) {
        return isTxLimitExempt[account];
    }

    function isExcludedFromMaxWallet(address account) public view returns(bool) {
        return isMaxWalletExempt[account];
    }

    function rescueToken(address token, address to) external onlyOwner {
        require(address(this) != token);
        IBEP20(token).transfer(to, IBEP20(token).balanceOf(address(this))); 
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function updateMaxSupply(uint256 newSupply) external onlyOwner {
        require(newSupply >= _totalSupply, "Incorrect value");
        MAX_Nodes = newSupply;
    }

    function updateMintLimit(uint256 newLimit) external onlyOwner {
        require(MAX_Nodes >= newLimit, "Incorrect value");
        MAX_BY_MINT = newLimit;
    }

    function enableContractSend() public onlyOwner {
        require(!contractSendEnabled, "");
        contractSendEnabled = true;
    }

/* Airdrop Begins */
function multiTransfer(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

    require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses");
    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    uint256 SCCC = 0;

    for(uint i=0; i < addresses.length; i++){
        SCCC = SCCC + tokens[i];
    }

    require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(from,addresses[i],tokens[i]);
        if(!isDividendExempt[addresses[i]]) {
            try distributor.setShare(addresses[i], _balances[addresses[i]]) {} catch {} 
        }
    }

    // Dividend tracker
    if(!isDividendExempt[from]) {
        try distributor.setShare(from, _balances[from]) {} catch {}
    }
}

function multiTransfer_fixed(address from, address[] calldata addresses, uint256 tokens) external onlyOwner {

    require(addresses.length < 801,"GAS Error: max airdrop limit is 800 addresses");

    uint256 SCCC = tokens * addresses.length;

    require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(from,addresses[i],tokens);
        if(!isDividendExempt[addresses[i]]) {
            try distributor.setShare(addresses[i], _balances[addresses[i]]) {} catch {} 
        }
    }

    // Dividend tracker
    if(!isDividendExempt[from]) {
        try distributor.setShare(from, _balances[from]) {} catch {}
    }
  }
}