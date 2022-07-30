/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// File: cptx.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * Standard SafeMath, stripped down to just add/sub/mul/div
 */
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

enum Permission {
    ChangeFees,
    AdjustContractVariables,
    Authorize,
    Unauthorize,
    PauseUnpauseContract,
    BypassPause,
    LockPermissions,
    ExcludeInclude
}

/**
 * Allows for contract ownership along with multi-address authorization for different permissions
 */
abstract contract contractAuth {
    struct PermissionLock {
        bool isLocked;
        uint64 expiryTime;
    }

    address public owner;
    mapping(address => mapping(uint256 => bool)) private authorizations; // uint256 is permission index
    
    uint256 constant NUM_PERMISSIONS = 8; // always has to be adjusted when Permission element is added or removed
    mapping(string => uint256) permissionNameToIndex;
    mapping(uint256 => string) permissionIndexToName;

    mapping(uint256 => PermissionLock) lockedPermissions;

    constructor(address owner_) {
        owner = owner_;
        for (uint256 i; i < NUM_PERMISSIONS; i++) {
            authorizations[owner_][i] = true;
        }

        permissionNameToIndex["ChangeFees"] = uint256(Permission.ChangeFees);
        permissionNameToIndex["AdjustContractVariables"] = uint256(Permission.AdjustContractVariables);
        permissionNameToIndex["Authorize"] = uint256(Permission.Authorize);
        permissionNameToIndex["Unauthorize"] = uint256(Permission.Unauthorize);
        permissionNameToIndex["PauseUnpauseContract"] = uint256(Permission.PauseUnpauseContract);
        permissionNameToIndex["BypassPause"] = uint256(Permission.BypassPause);
        permissionNameToIndex["LockPermissions"] = uint256(Permission.LockPermissions);
        permissionNameToIndex["ExcludeInclude"] = uint256(Permission.ExcludeInclude);

        permissionIndexToName[uint256(Permission.ChangeFees)] = "ChangeFees";
        permissionIndexToName[uint256(Permission.AdjustContractVariables)] = "AdjustContractVariables";
        permissionIndexToName[uint256(Permission.Authorize)] = "Authorize";
        permissionIndexToName[uint256(Permission.Unauthorize)] = "Unauthorize";
        permissionIndexToName[uint256(Permission.PauseUnpauseContract)] = "PauseUnpauseContract";
        permissionIndexToName[uint256(Permission.BypassPause)] = "BypassPause";
        permissionIndexToName[uint256(Permission.LockPermissions)] = "LockPermissions";
        permissionIndexToName[uint256(Permission.ExcludeInclude)] = "ExcludeInclude";
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "Ownership required."); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorizedFor(Permission permission) {
        require(!lockedPermissions[uint256(permission)].isLocked, "Permission is locked.");
        require(isAuthorizedFor(msg.sender, permission), string(abi.encodePacked("Not authorized. You need the permission ", permissionIndexToName[uint256(permission)]))); _;
    }

    /**
     * Authorize address for one permission
     */
    function authorizeFor(address adr, string memory permissionName) public authorizedFor(Permission.Authorize) {
        uint256 permIndex = permissionNameToIndex[permissionName];
        authorizations[adr][permIndex] = true;
        emit AuthorizedFor(adr, permissionName, permIndex);
    }

    /**
     * Authorize address for multiple permissions
     */
    function authorizeForMultiplePermissions(address adr, string[] calldata permissionNames) public authorizedFor(Permission.Authorize) {
        for (uint256 i; i < permissionNames.length; i++) {
            uint256 permIndex = permissionNameToIndex[permissionNames[i]];
            authorizations[adr][permIndex] = true;
            emit AuthorizedFor(adr, permissionNames[i], permIndex);
        }
    }

    /**
     * Remove address' authorization
     */
    function unauthorizeFor(address adr, string memory permissionName) public authorizedFor(Permission.Unauthorize) {
        require(adr != owner, "Can't unauthorize owner");

        uint256 permIndex = permissionNameToIndex[permissionName];
        authorizations[adr][permIndex] = false;
        emit UnauthorizedFor(adr, permissionName, permIndex);
    }

    /**
     * Unauthorize address for multiple permissions
     */
    function unauthorizeForMultiplePermissions(address adr, string[] calldata permissionNames) public authorizedFor(Permission.Unauthorize) {
        require(adr != owner, "Can't unauthorize owner");

        for (uint256 i; i < permissionNames.length; i++) {
            uint256 permIndex = permissionNameToIndex[permissionNames[i]];
            authorizations[adr][permIndex] = false;
            emit UnauthorizedFor(adr, permissionNames[i], permIndex);
        }
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
    function isAuthorizedFor(address adr, string memory permissionName) public view returns (bool) {
        return authorizations[adr][permissionNameToIndex[permissionName]];
    }

    /**
     * Return address' authorization status
     */
    function isAuthorizedFor(address adr, Permission permission) public view returns (bool) {
        return authorizations[adr][uint256(permission)];
    }

    /**
     * Transfer ownership to new address. Caller must be owner.
     */
    function transferOwnership(address payable adr) public onlyOwner {
        address oldOwner = owner;
        owner = adr;
        for (uint256 i; i < NUM_PERMISSIONS; i++) {
            authorizations[oldOwner][i] = false;
            authorizations[owner][i] = true;
        }
        emit OwnershipTransferred(oldOwner, owner);
    }

    /**
     * Get the index of the permission by its name
     */
    function getPermissionNameToIndex(string memory permissionName) public view returns (uint256) {
        return permissionNameToIndex[permissionName];
    }
    
    /**
     * Get the time the timelock expires
     */
    function getPermissionUnlockTime(string memory permissionName) public view returns (uint256) {
        return lockedPermissions[permissionNameToIndex[permissionName]].expiryTime;
    }

    /**
     * Check if the permission is locked
     */
    function isLocked(string memory permissionName) public view returns (bool) {
        return lockedPermissions[permissionNameToIndex[permissionName]].isLocked;
    }

    /*
     *Locks the permission from being used for the amount of time provided
     */
    function lockPermission(string memory permissionName, uint64 time) public virtual authorizedFor(Permission.LockPermissions) {
        uint256 permIndex = permissionNameToIndex[permissionName];
        uint64 expiryTime = uint64(block.timestamp) + time;
        lockedPermissions[permIndex] = PermissionLock(true, expiryTime);
        emit PermissionLocked(permissionName, permIndex, expiryTime);
    }
    
    /*
     * Unlocks the permission if the lock has expired 
     */
    function unlockPermission(string memory permissionName) public virtual {
        require(block.timestamp > getPermissionUnlockTime(permissionName) , "Permission is locked until the expiry time.");
        uint256 permIndex = permissionNameToIndex[permissionName];
        lockedPermissions[permIndex].isLocked = false;
        emit PermissionUnlocked(permissionName, permIndex);
    }

    event PermissionLocked(string permissionName, uint256 permissionIndex, uint64 expiryTime);
    event PermissionUnlocked(string permissionName, uint256 permissionIndex);
    event OwnershipTransferred(address from, address to);
    event AuthorizedFor(address adr, string permissionName, uint256 permissionIndex);
    event UnauthorizedFor(address adr, string permissionName, uint256 permissionIndex);
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function depositBUSD(uint256 busdAmount) external;
    function process(uint256 gas) external;
    function claimDividend() external;
    function setdividendBNBThreshold(uint256 _bnbamount) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address ownerToken;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    // LAUNCH CHECK
    // BUSD mainnet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    // BUSD testnet: 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    // BNB mainnet: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    // BNB testnet: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    IBEP20 BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
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

    // LAUNCH CHECK
    // The threshold that the BNB in the distributor has to reach before it will swap for BUSD
    uint256 public dividendBNBThreshold = 1 * (10 ** 18);

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == ownerToken); _;
    }

    // LAUNCH CHECK
    // Router mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    // Router testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        ownerToken = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setdividendBNBThreshold(uint256 _bnbamount) external override onlyToken {
        dividendBNBThreshold = _bnbamount;
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
        uint256 balanceBefore = BUSD.balanceOf(address(this));
        if(address(this).balance > dividendBNBThreshold) {

            uint256 bnbToSwap = address(this).balance;
            
            address[] memory path = new address[](2);
            path[0] = WBNB;
            path[1] = address(BUSD);

            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbToSwap}(
                0,
                path,
                address(this),
                block.timestamp
            );

            uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

            totalDividends = totalDividends.add(amount);
            dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
        }
    }

    function depositBUSD(uint256 busdAmount) external override onlyToken {
        totalDividends = totalDividends.add(busdAmount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(busdAmount).div(totalShares));
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
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend() external override {
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
    receive() external payable {}
}

contract CryptoPositive is IBEP20, contractAuth {
    using SafeMath for uint256;

    // LAUNCH CHECK
    // BUSD mainnet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    // BUSD testnet: 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    // BNB mainnet: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    // BNB testnet: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    
    string constant _name = "Crypto Positive";
    string constant _symbol = "CPTX";
    uint8 constant _decimals = 18;

    uint256 _totalSupply =  1200000000000000 * (10 ** 18);

    // LAUNCH CHECK
    // Max TX limit
    uint256 public _maxTxAmount = 5000000000000 * (10 ** 18);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;

    uint256 public liquidityFee = 200;
    uint256 public rewardFee = 900;
    uint256 public operationsFee = 400;
    uint256 public charityFee = 500;
    uint256 public utilityFee = 200;
    uint256 totalFee = 2200;
    uint256 public feeDenominator = 10000;

    address public liquidityReceiver;
    address public kitchenReceiver;
    address public operationsReceiver;
    address public charityReceiver;
    address public utilityReceiver;

    IDEXRouter public router;
    address pancakeV2BNBPair;
    address[] public pairs;

    uint256 public launchedAt;

    bool public feesOnNormalTransfers = false;
    bool public liquifyEnabled = true;
    bool public freeze_contract = false;
    bool public swapEnabled = false;

    DividendDistributor distributor;
    uint256 distributorGas = 600000;

    // LAUNCH CHECK
    // Tokens to accumulate before swapping
    uint256 public swapThreshold = 1000000000 * (10 ** 18);
    bool public inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event Launched(uint256 blockNumber, uint256 timestamp);
    event SwapBackSuccess(uint256 amount);
    event SwapBackFailed(string message);
    event KitchenTransfer(bool status);

    // LAUNCH CHECK
    // Router mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    // Router testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    constructor () contractAuth(msg.sender) {
        address dexRouter_ = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        router = IDEXRouter(dexRouter_);
        
        pancakeV2BNBPair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = ~uint256(0);

        pairs.push(pancakeV2BNBPair);
        distributor = new DividendDistributor(address(router));

        address owner_ = msg.sender;

        isFeeExempt[owner_] = true;
        isFeeExempt[address(this)] = true;

        isTxLimitExempt[owner_] = true;
        isTxLimitExempt[address(this)] = true;

        isDividendExempt[pancakeV2BNBPair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[owner_] = true;

        liquidityReceiver = owner_;
        operationsReceiver = owner_;
        charityReceiver = owner_;
        utilityReceiver = owner_;

        approve(dexRouter_, _totalSupply);
        IBEP20(BUSD).approve(dexRouter_, 1000000000000000000000000);
        _balances[owner_] = _totalSupply;
        emit Transfer(address(0), owner_, _totalSupply);
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
        return approve(spender, ~uint256(0));
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != ~uint256(0)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!freeze_contract, "Contract frozen!");

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        
        checkTxLimit(sender, amount);

        if(shouldSwapBack()){ swapBack(); }
        if(shouldSendBUSD()) { sendBUSD(); }

        if(!launched() && recipient == pancakeV2BNBPair){ require(_balances[sender] > 0); launch(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

        try distributor.deposit() {} catch {}
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

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if (isFeeExempt[sender] || isFeeExempt[recipient] || !launched()) return false;

        address[] memory liqPairs = pairs;

        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (sender == liqPairs[i] || recipient == liqPairs[i]) return true;
        }

        return feesOnNormalTransfers;
    }

    function getTotalFee() public view returns (uint256) {
        if(launchedAt + 1 >= block.number){ return feeDenominator.sub(1); }
        return totalFee;
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee()).div(feeDenominator);
        
        uint256 finalFee = feeAmount;

        _balances[address(this)] = _balances[address(this)].add(finalFee);
        emit Transfer(sender, address(this), finalFee);

        return amount.sub(feeAmount);
    }

    function shouldSendBUSD() internal view returns (bool) {
        return msg.sender != pancakeV2BNBPair
        && IBEP20(BUSD).balanceOf(address(this)) > 0;
    }

    function sendBUSD() internal {
        uint256 sendBUSDAmount = IBEP20(BUSD).balanceOf(address(this));
        IBEP20(BUSD).transfer(address(distributor), sendBUSDAmount);
        distributor.depositBUSD(sendBUSDAmount);
    }

    function sendBUSDManual() external authorizedFor(Permission.AdjustContractVariables) {
        uint256 sendBUSDAmount = IBEP20(BUSD).balanceOf(address(this));
        IBEP20(BUSD).transfer(address(distributor), sendBUSDAmount);
        distributor.depositBUSD(sendBUSDAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pancakeV2BNBPair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 swapLiquidityFee = liquifyEnabled ? liquidityFee : 0;
        uint256 amountToLiquify = swapThreshold.mul(swapLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        ) {

            uint256 amountBNB = address(this).balance.sub(balanceBefore);

            uint256 totalBNBFee = totalFee.sub(swapLiquidityFee.div(2));

            uint256 amountBNBLiquidity = amountBNB.mul(swapLiquidityFee).div(totalBNBFee).div(2);
            uint256 amountBNBRewards = amountBNB.mul(rewardFee).div(totalBNBFee);
            uint256 amountBNBOperations = amountBNB.mul(operationsFee).div(totalBNBFee);
            uint256 amountBNBCharity = amountBNB.mul(charityFee).div(totalBNBFee);
            uint256 amountBNBUtility = amountBNB.mul(utilityFee).div(totalBNBFee);

            payable(address(distributor)).transfer(amountBNBRewards);
            payable(operationsReceiver).transfer(amountBNBOperations);
            payable(charityReceiver).transfer(amountBNBCharity);
            payable(utilityReceiver).transfer(amountBNBUtility);
        
            if(amountToLiquify > 0){
                try router.addLiquidityETH{ value: amountBNBLiquidity }(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    liquidityReceiver,
                    block.timestamp
                ) {
                    emit AutoLiquify(amountToLiquify, amountBNBLiquidity);
                } catch {
                    emit AutoLiquify(0, 0);
                }
            }

            emit SwapBackSuccess(amountToSwap);
        } catch Error(string memory e) {
            emit SwapBackFailed(string(abi.encodePacked("SwapBack failed with error ", e)));
        } catch {
            emit SwapBackFailed("SwapBack failed without an error message from pancakeSwap");
        }
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
        emit Launched(block.number, block.timestamp);
    }
    
    function freeze(bool _freeze) external authorizedFor(Permission.AdjustContractVariables) {
        freeze_contract = _freeze;
    }

    function setTxLimit(uint256 amount, bool _withCSupply) external authorizedFor(Permission.AdjustContractVariables) {
        if (_withCSupply) {
            require(amount >= getCirculatingSupply() / 1000);
            _maxTxAmount = amount;
        } else {
            require(amount >= _totalSupply / 1000);
            _maxTxAmount = amount;
        }
    }

    function setIsDividendExempt(address holder, bool exempt) external authorizedFor(Permission.ExcludeInclude) {
        require(holder != address(this) && holder != pancakeV2BNBPair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external authorizedFor(Permission.ExcludeInclude) {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorizedFor(Permission.ExcludeInclude) {
        isTxLimitExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _rewardFee, uint256 _operationsfee, uint256 _charityfee, uint256 _utilityfee, uint256 _feeDenominator) external authorizedFor(Permission.AdjustContractVariables) {
        liquidityFee = _liquidityFee;
        rewardFee = _rewardFee;
        operationsFee = _operationsfee;
        charityFee = _charityfee;
        utilityFee = _utilityfee;
        totalFee = _liquidityFee.add(_rewardFee).add(_operationsfee).add(_charityfee).add(_utilityfee);
        feeDenominator = _feeDenominator;
        uint256 effectiveTax = totalFee.mul(100).div(feeDenominator);
        require(effectiveTax <= 25);
    }

    function setFeeReceivers(address _liquidityreceiver, address _operationsreceiver, address _charityreceiver, address _utilityreceiver) external authorizedFor(Permission.AdjustContractVariables) {
        liquidityReceiver = _liquidityreceiver;
        operationsReceiver = _operationsreceiver;
        charityReceiver = _charityreceiver;
        utilityReceiver = _utilityreceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorizedFor(Permission.AdjustContractVariables) {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }
    
    function setLiquifyEnabled(bool _enabled) external authorizedFor(Permission.AdjustContractVariables) {
        liquifyEnabled = _enabled;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorizedFor(Permission.AdjustContractVariables) {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external authorizedFor(Permission.AdjustContractVariables) {
        distributorGas = gas;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function claimDividend() external {
        distributor.claimDividend();
    }

    function clearStuckBNB(address wallet) external authorizedFor(Permission.AdjustContractVariables) {
        payable(wallet).transfer(address(this).balance);
    }
    
    function addPair(address pair) external authorizedFor(Permission.AdjustContractVariables) {
        pairs.push(pair);
    }
    
    function removeLastPair() external authorizedFor(Permission.AdjustContractVariables) {
        pairs.pop();
    }
    
    function setFeesOnNormalTransfers(bool _enabled) external authorizedFor(Permission.AdjustContractVariables) {
        feesOnNormalTransfers = _enabled;
    }

    function setLaunchedAt(uint256 launched_) external authorizedFor(Permission.AdjustContractVariables) {
        launchedAt = launched_;
    }

    function setdividendBNBThreshold(uint256 _bnbamount) external authorizedFor(Permission.AdjustContractVariables) {
        distributor.setdividendBNBThreshold(_bnbamount);
    }
}