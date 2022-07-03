/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

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
    AuthorizedUser
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

        permissionNameToIndex["AuthorizedUser"] = uint256(Permission.AuthorizedUser);

        permissionIndexToName[uint256(Permission.AuthorizedUser)] = "AuthorizedUser";
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
    function authorizeFor(address adr, string memory permissionName) public authorizedFor(Permission.AuthorizedUser) {
        uint256 permIndex = permissionNameToIndex[permissionName];
        authorizations[adr][permIndex] = true;
        emit AuthorizedFor(adr, permissionName, permIndex);
    }

    /**
     * Authorize address for multiple permissions
     */
    function authorizeForMultiplePermissions(address adr, string[] calldata permissionNames) public authorizedFor(Permission.AuthorizedUser) {
        for (uint256 i; i < permissionNames.length; i++) {
            uint256 permIndex = permissionNameToIndex[permissionNames[i]];
            authorizations[adr][permIndex] = true;
            emit AuthorizedFor(adr, permissionNames[i], permIndex);
        }
    }

    /**
     * Remove address' authorization
     */
    function unauthorizeFor(address adr, string memory permissionName) public authorizedFor(Permission.AuthorizedUser) {
        require(adr != owner, "Can't unauthorize owner");

        uint256 permIndex = permissionNameToIndex[permissionName];
        authorizations[adr][permIndex] = false;
        emit UnauthorizedFor(adr, permissionName, permIndex);
    }

    /**
     * Unauthorize address for multiple permissions
     */
    function unauthorizeForMultiplePermissions(address adr, string[] calldata permissionNames) public authorizedFor(Permission.AuthorizedUser) {
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
    function lockPermission(string memory permissionName, uint64 time) public virtual authorizedFor(Permission.AuthorizedUser) {
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

/*
 * Hot Shot Rewards
 */
interface iHotShotRewards {
    function deposit() external payable;
    function process() external;
    function showHotShotBalance(uint256 _level) external returns (uint256);
    function showHotShotThreshold(uint256 _level) external returns (uint256);
    function showhsIndex() external returns (uint256);
    function setHotShotThreshold(uint256 _level, uint256 _threshold) external;
    function emergencyHotShotClear(address _token, uint256 _percentage, address _recipient) external;
}

contract HotShotRewards is iHotShotRewards {
    using SafeMath for uint256;

    address ownerToken;
    mapping(uint256 => uint256) public hsThreshold;
    mapping(uint256 => uint256) public hsBalance;

    // BUSD mainnet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    // BUSD testnet: 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    // BNB mainnet: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    // BNB testnet: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    IBEP20 BUSD = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    IDEXRouter router;

    uint256 hsIndex = 1;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == ownerToken); _;
    }

    // Router mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    // Router testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); 
        ownerToken = msg.sender;
    }

    /*
     * Hot Shot functions
     */
    function emergencyHotShotClear(address _token, uint256 _percentage, address _recipient) external override onlyToken {
        uint256 clearAmount = IBEP20(_token).balanceOf(address(this)).mul(_percentage).div(100);
        IBEP20(_token).approve(address(router), clearAmount);
        IBEP20(_token).transfer(_recipient, clearAmount);
    }

    /*
     * Hot Shot settings
     */
    function setHotShotThreshold(uint256 _level, uint256 _threshold) external override onlyToken {
        uint256 newThreshold = _threshold.mul(10 ** 18);
        hsThreshold[_level] = newThreshold;
    }
    function showHotShotBalance(uint256 _level) external override view onlyToken returns (uint256) {
        return hsBalance[_level].div(10 ** 18);
    }
    function showHotShotThreshold(uint256 _level) external override view onlyToken returns (uint256) {
        return hsThreshold[_level].div(10 ** 18);
    }
    function showhsIndex() external override view onlyToken returns (uint256) {
        return hsIndex;
    }

    /*
     * Hot Shot transactions
     */
    function deposit() external payable override onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));
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

        uint256 busdAdded = BUSD.balanceOf(address(this)).sub(balanceBefore);
        uint256 busdShare = busdAdded.mul(20).div(100);
        uint256 shareLoop = 1;
        while (shareLoop <= 5) {
            hsBalance[shareLoop] += busdShare;
            shareLoop++;
        }
    }
    function process() external override onlyToken {
        if(hsIndex > 5) {
            hsIndex = 1;
        }
        if(hsBalance[hsIndex] > hsThreshold[hsIndex]) {
            BUSD.transfer(ownerToken, hsThreshold[hsIndex]);
            hsBalance[hsIndex] -= hsThreshold[hsIndex];
        }
        hsIndex++;
    }
}

/*
 * Distributor
 */
interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function depositBUSD(uint256 busdAmount) external;
    function process(uint256 gas) external;
    function claimDividend() external;
    function emergencyDistributorClear(address _token, uint256 _percentage, address _recipient) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address ownerToken;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    // BUSD mainnet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    // BUSD testnet: 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    // BNB mainnet: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    // BNB testnet: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    IBEP20 BUSD = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
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

    uint256 public minPeriod = 1 hours; // min 1 hour delay
    uint256 public minDistribution = 1 * (10 ** 18); // 1 BUSD minimum auto send

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

    // Router mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    // Router testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); 
        ownerToken = msg.sender;
    }

    /*
     * Distributor functions
     */
    function emergencyDistributorClear(address _token, uint256 _percentage, address _recipient) external override onlyToken {
        uint256 clearAmount = IBEP20(_token).balanceOf(address(this)).mul(_percentage).div(100);
        IBEP20(_token).approve(address(router), clearAmount);
        IBEP20(_token).transfer(_recipient, clearAmount);
    }
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
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

    /*
     * Distributor settings
     */
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    /*
     * Distributor transactions
     */
    function deposit() external payable override onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(BUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
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
}

contract TKNTST07020911 is IBEP20, contractAuth {
    using SafeMath for uint256;

    // BUSD mainnet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    // BUSD testnet: 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    // BNB mainnet: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    // BNB testnet: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    address BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    
    // CHANGE / REMOVE AT LAUNCH
    string constant _name = "TKNTST07020911";
    string constant _symbol = "TKNTST";
    uint8 constant _decimals = 18;

    uint256 _totalSupply =  1000000000000000 * (10 ** 18);
    uint256 public _maxTxAmount = 2000000000000 * (10 ** 18);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;

    uint256 public liquidityFee = 500;
    uint256 public reflectionFee = 500;
    uint256 public hotshotFee = 500;
    uint256 public totalFee = 1500;
    uint256 public feeDenominator = 10000;

    // CHANGE BEFORE DEPLOYMENT
    uint256 public busdThreshold = 10 * (10 ** 18);
    uint256 public bnbThreshold = 1 * (10 ** 18);
    uint256 public amountToLiquify = 1000000 * (10 ** 18);
    
    bool inSendBNB;
    bool inSendBUSD;
    bool inTaxing;
    modifier sendingBNB() { inSendBNB = true; _; inSendBNB = false; }
    modifier sendingBUSD() { inSendBUSD = true; _; inSendBUSD = false; }
    modifier Taxing() { inTaxing = true; _; inTaxing = false; }

    address public autoLiquidityReceiver;

    IDEXRouter public router;
    address pancakeV2BNBPair;
    address[] public pairs;

    uint256 public launchedAt;

    bool public feesOnNormalTransfers = false;
    bool public freeze_contract = false;
    bool public autoSwap = false;
    uint256 public curswapAmount;

    HotShotRewards hotshotcontract;
    DividendDistributor distributor;
    uint256 distributorGas = 1000000;
    
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event Launched(uint256 blockNumber, uint256 timestamp);

    // Router mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    // Router testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    constructor () contractAuth(msg.sender) {
        address dexRouter_ = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        router = IDEXRouter(dexRouter_);
        
        pancakeV2BNBPair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = ~uint256(0);

        pairs.push(pancakeV2BNBPair);
        distributor = new DividendDistributor(address(router));
        hotshotcontract = new HotShotRewards(address(router));

        address owner_ = msg.sender;

        isFeeExempt[owner_] = true;
        isFeeExempt[address(this)] = true;

        isTxLimitExempt[owner_] = true;
        isTxLimitExempt[address(this)] = true;

        isDividendExempt[pancakeV2BNBPair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[owner_] = true;

        autoLiquidityReceiver = owner_;

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

    /*
     * Transaction functions
     */
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

        checkTxLimit(sender, amount);

        if(shouldSendBNB()){ sendBNB(); }
        if(shouldSendBUSD()) { sendBUSD(); }

        if(!launched() && recipient == pancakeV2BNBPair){ require(_balances[sender] > 0); launch(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

        uint256 swapAmount = amount.sub(amountReceived);
        curswapAmount = swapAmount;
        if(swapAmount > 0 && autoSwap) {
            if(!inTaxing) {
                collectTaxes(swapAmount);
            }
        }
        uint256 burnAmount = swapAmount.div(2);
        if(burnAmount > 0) {
            IBEP20(address(this)).transfer(DEAD, burnAmount);
        }

        try hotshotcontract.process() {} catch {}
        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
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
    function isSell(address recipient) internal view returns (bool) {
        address[] memory liqPairs = pairs;
        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (recipient == liqPairs[i]) return true;
        }
        return false;
    }

    /*
     * Send BUSD Functions
     */
    function shouldSendBUSD() internal view returns (bool) {
        return msg.sender != pancakeV2BNBPair
        && !inSendBUSD
        && !inSendBNB
        && IBEP20(BUSD).balanceOf(address(this)) > busdThreshold;
    }
    function sendBUSD() internal sendingBUSD {
        uint256 sendBUSDAmount = IBEP20(BUSD).balanceOf(address(this));
        IBEP20(BUSD).transfer(address(distributor), sendBUSDAmount);
        distributor.depositBUSD(sendBUSDAmount);
    }
    function sendBUSDManual() external authorizedFor(Permission.AuthorizedUser) {
        sendBUSD();
    }

    /*
     * Send BNB Functions
     */
    function shouldSendBNB() internal view returns (bool) {
        return msg.sender != pancakeV2BNBPair
        && !inSendBUSD
        && !inSendBNB
        && address(this).balance > bnbThreshold;
    }
    function sendBNB() internal sendingBNB {
        uint256 startbnbAmount = address(this).balance;
        uint256 effectiveTotalFee = totalFee.sub(liquidityFee);
        uint256 sendHotShotAmount = startbnbAmount.mul(hotshotFee).div(effectiveTotalFee);
        uint256 sendDistributorAmount = startbnbAmount.mul(reflectionFee).div(effectiveTotalFee);

        try hotshotcontract.deposit{value: sendHotShotAmount}() {} catch {}
        try distributor.deposit{value: sendDistributorAmount}() {} catch {}
    }
    function sendBNBManual() external authorizedFor(Permission.AuthorizedUser) {
        sendBNB();
    }

    /*
     * Contract Functions
     */
    function collectTaxes(uint256 _taxamount) public Taxing{
        uint256 startBNBBalance = address(this).balance;

        address[] memory swapPath = new address[](2);
        swapPath[0] = address(this);
        swapPath[1] = WBNB;

        try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _taxamount,
            0,
            swapPath,
            address(this),
            block.timestamp
        ) {
            uint256 lpTokens = _taxamount.mul(liquidityFee).div(totalFee).div(2);
            uint256 addedBNB = address(this).balance.sub(startBNBBalance);
            uint256 lpBNB = addedBNB.mul(liquidityFee).div(totalFee);
            try router.addLiquidityETH{ value: lpBNB }(
                address(this),
                lpTokens,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            ) { } catch { }
        } catch { }
    }
    function clearStuckBNB(address _wallet, uint256 _percentage) external authorizedFor(Permission.AuthorizedUser) {
        uint256 amountToClear = address(this).balance.mul(_percentage).div(100);
        payable(_wallet).transfer(amountToClear);
    }
    function addPair(address pair) external authorizedFor(Permission.AuthorizedUser) {
        pairs.push(pair);
    }
    function removeLastPair() external authorizedFor(Permission.AuthorizedUser) {
        pairs.pop();
    }
    function launch() internal {
        launchedAt = block.number;
        emit Launched(block.number, block.timestamp);
    }
    function freeze(bool _freeze) external authorizedFor(Permission.AuthorizedUser) {
        freeze_contract = _freeze;
    }
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    /*
     * Contract Settings
     */
    function setFeesOnNormalTransfers(bool _enabled) external authorizedFor(Permission.AuthorizedUser) {
        feesOnNormalTransfers = _enabled;
    }
    function setautoSwap(bool _enabled) external authorizedFor(Permission.AuthorizedUser) {
        autoSwap = _enabled;
    }
    function setLaunchedAt(uint256 launched_) external authorizedFor(Permission.AuthorizedUser) {
        launchedAt = launched_;
    }
    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }
    function setTxLimit(uint256 _amount) external authorizedFor(Permission.AuthorizedUser) {
        uint256 newtxLimit = _amount.mul(10 ** 18);
        _maxTxAmount = newtxLimit;
    }
    function setamountToLiquify(uint256 _amount) external authorizedFor(Permission.AuthorizedUser) {
        uint256 newamountToLiquify = _amount.mul(10 ** 18);
        amountToLiquify = newamountToLiquify;
    }
    function setIsDividendExempt(address holder, bool exempt) external authorizedFor(Permission.AuthorizedUser) {
        require(holder != address(this) && holder != pancakeV2BNBPair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }
    function setIsFeeExempt(address holder, bool exempt) external authorizedFor(Permission.AuthorizedUser) {
        isFeeExempt[holder] = exempt;
    }
    function setIsTxLimitExempt(address holder, bool exempt) external authorizedFor(Permission.AuthorizedUser) {
        isTxLimitExempt[holder] = exempt;
    }
    function setFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _hotshotFee, uint256 _feeDenominator) external authorizedFor(Permission.AuthorizedUser) {
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        hotshotFee = _hotshotFee;
        totalFee = _liquidityFee.add(_reflectionFee).add(_hotshotFee);
        feeDenominator = _feeDenominator;
        uint256 effectiveTax = totalFee.mul(100).div(feeDenominator);
        require(effectiveTax <= 20);
    }
    function setFeeReceivers(address _autoLiquidityReceiver) external authorizedFor(Permission.AuthorizedUser) {
        autoLiquidityReceiver = _autoLiquidityReceiver;
    }
    function setbnbThreshold(uint256 _amount) external authorizedFor(Permission.AuthorizedUser) {
        uint256 newbnbThreshold = _amount.mul(10 ** 18);
        bnbThreshold = newbnbThreshold;
    }
    function setbusdThreshold(uint256 _amount) external authorizedFor(Permission.AuthorizedUser) {
        uint256 newbusdThreshold = _amount.mul(10 ** 18);
        busdThreshold = newbusdThreshold;
    }

    /*
     * Distributor Functions
     */
    function emergencyDistributorClear(address _token, uint256 _percentage, address _recipient) external authorizedFor(Permission.AuthorizedUser) {
        distributor.emergencyDistributorClear(_token, _percentage, _recipient);
    }
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorizedFor(Permission.AuthorizedUser) {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }
    function setDistributorSettings(uint256 gas) external authorizedFor(Permission.AuthorizedUser) {
        distributorGas = gas;
    }
    function claimDividend() external {
        distributor.claimDividend();
    }
   
    /*
     * Hot Shot Functions
     */
    function emergencyHotShotClear(address _token, uint256 _percentage, address _recipient) external authorizedFor(Permission.AuthorizedUser) {
        hotshotcontract.emergencyHotShotClear(_token, _percentage, _recipient);
    }
    function setHotShotThreshold(uint256 _level, uint256 _threshold) external authorizedFor(Permission.AuthorizedUser) {
        hotshotcontract.setHotShotThreshold(_level, _threshold);
    }
    function showHotShotBalance(uint256 _level) public view returns (uint256) {
        return hotshotcontract.showHotShotBalance(_level);
    }
    function showHotShotThreshold(uint256 _level) public view returns (uint256) {
        return hotshotcontract.showHotShotThreshold(_level);
    }
    function showhsIndex() public view returns(uint256) {
        return hotshotcontract.showhsIndex();
    }
}