/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

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
abstract contract TEGAuth {
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
}

struct Share {
    uint256 amount;
    uint256 totalExcluded;
    uint256 totalRealised;
}
contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    // CHANGE BEFORE DEPLOYING
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

    event DistributorTransfer(address indexed from, address indexed to, uint256 value);

    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    // CHANGE BEFORE DEPLOYING
    // Router mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    // Router testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
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

            emit DistributorTransfer(address(this), shareholder, amount);

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend() external override {
        distributeDividend(msg.sender);
    }

    function getShare(address holder) public view returns (Share memory) {
        return shares[holder];
    }
    function getTotalShares() public view returns (uint256) {
        return totalShares;
    }
    function getDividendsPerShare() public view returns (uint256) {
        return dividendsPerShare;
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

contract IntegrityCoin is IBEP20, TEGAuth {
    using SafeMath for uint256;

    // CHANGE THIS BEFORE DEPLOYING
    // BUSD mainnet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    // BUSD testnet: 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    // BNB mainnet: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    // BNB testnet: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    address BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    
    // CHANGE / REMOVE AT LAUNCH
    string constant _name = "Integrity Coin";
    string constant _symbol = "TEG";
    uint8 constant _decimals = 18;

    uint256 _totalSupply =  1 * (10 ** 15) * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    struct Tax{
        uint256 total;
        uint256 reflection;
        uint256 liquidity;
        uint256 buyback;
    }

    Tax public buyFees;
    Tax public sellFees;
    Tax public highSellFees;
    Tax public transferFees;
    Tax public noneFees;
    uint256 public feeDenominator = 10000;

    // Exempt mappings
    mapping (address => bool) public isDividendExempt;
    mapping (address => bool) public isTradableLockExempt;
    mapping (address => bool) public isTransferFeeExempt; 
    mapping (address => bool) public isTradeFeeExempt; 
    mapping (address => bool) public isHighTaxExempt;

    address public autoLiquidityReceiver;
    address public buybackFeeReceiver;
    address public dividendDistributor;

    IDEXRouter public router;
    address pancakeV2BNBPair;
    address[] public pairs;

    uint256 public launchedAt;

    bool public swapEnabled = false;
    bool public tradableLock = true;
    bool public transferFeeEnabled = false;
    bool public highTaxEnabled = true;
    bool public swapThresholdEnabled = false;
    bool public inSwap;

    DividendDistributor distributor;
    uint256 distributorGas = 600000;
    uint256 buybackGas = 30000;
    // Limit variables
    uint256 public AirdropBUSDthreshold = 2000 * (10 ** 18);
    uint256 public highTaxMinimum = 200 * (10 ** 9) * (10 ** _decimals);
    uint256 public highTaxMinimumLimit = 50 * (10 ** 9) * (10 ** _decimals);
    uint256 public maxSellAmount = 1 * (10 ** 12) * (10 ** _decimals);
    uint256 public swapThreshold = 500 * (10 ** 9) * (10 ** _decimals);
    
    modifier swapping() { inSwap = true; _; inSwap = false; }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event Launched(uint256 blockNumber, uint256 timestamp);
    event SwapBackSuccess(uint256 amount);
    event SwapBackFailed(string message);
    event BuybackTransfer(bool status);

    // CHANGE BEFORE DEPLOYING
    // Router mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    // Router testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    constructor () TEGAuth(msg.sender) {
        address dexRouter_ = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        router = IDEXRouter(dexRouter_);
        
        pancakeV2BNBPair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = ~uint256(0);
        pairs.push(pancakeV2BNBPair);

        distributor = new DividendDistributor(address(router));
        dividendDistributor = address(distributor);

        approve(dexRouter_, _totalSupply);
        IBEP20(BUSD).approve(dexRouter_, _totalSupply);
        initTaxs();
        initOwner();
        launch();    
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
        // if(_allowances[sender][msg.sender] != ~uint256(0)){
        //     _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        // }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint16 _transferMethod = isTranferMethod(sender, recipient);
        if (checkTradableLock(sender, recipient)) { require(!tradableLock, "Locked this trade!"); }
        if (_transferMethod == 2) { require(amount <= maxSellAmount, "Sell amount can't be bigger than maxSellAmount!"); }

        if (shouldSwapBack()){ swapBack(sender, recipient, amount); }
        if (shouldSwapAirdropBUSD()) { swapAirdropBUSD(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = takeFee(sender, recipient, amount);
        _balances[recipient] = _balances[recipient].add(amountReceived);

        if (!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if (!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

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

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        Tax memory tax = getTax(sender, recipient, amount);
        uint256 feeAmount = amount.mul(tax.total).div(feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function isTrade(address sender, address recipient) internal view returns (bool) {
        address[] memory liqPairs = pairs;
        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (recipient == liqPairs[i] || sender == liqPairs[i]) return true;
        }
        return true;
    }

    function checkTradableLock(address sender, address recipient) internal view returns (bool) {
        return isTrade(sender, recipient) && !isTradableLockExempt[sender] && !isTradableLockExempt[recipient];
    }

    function isTranferMethod(address sender, address recipient) internal view returns (uint16) {
        address[] memory liqPairs = pairs;
        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (sender == liqPairs[i]) return 1; // Buy
            if (recipient == liqPairs[i]) return 2; // Sell
        }
        return 0; // General transfer
    }

    function shouldSwapAirdropBUSD() internal view returns (bool) {
        return  msg.sender != pancakeV2BNBPair
        && IBEP20(BUSD).balanceOf(address(this)) > AirdropBUSDthreshold;
    }

    // Send BUSD directly to the contract, and it will move to the distributor once it hits the threshold
    function swapAirdropBUSD() internal {
        uint256 sendBUSDAmount = IBEP20(BUSD).balanceOf(address(this));
        IBEP20(BUSD).transfer(address(distributor), sendBUSDAmount);
        distributor.depositBUSD(sendBUSDAmount);
    }

    // If you really want to send BUSD right now without hitting the threshold
    function swapAirdropBUSDManual() external authorizedFor(Permission.AdjustContractVariables) {
        uint256 sendBUSDAmount = IBEP20(BUSD).balanceOf(address(this));
        IBEP20(BUSD).transfer(address(distributor), sendBUSDAmount);
        distributor.depositBUSD(sendBUSDAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pancakeV2BNBPair
        && !inSwap
        && swapEnabled
        && (!swapThresholdEnabled || _balances[address(this)] >= swapThreshold);
    }

    function swapBack(address _sender, address _recipient, uint256 _amount) internal swapping {
        Tax memory tax = getTax(_sender, _recipient, _amount);
        if (tax.total == 0){
            return;
        }
        uint256 amountToLiquify = 0;
        uint256 amountToSwap = swapThreshold;
        uint256 swapLiquidityFee = tax.liquidity;
        if (tax.total > 0){
            amountToLiquify = swapThreshold.mul(swapLiquidityFee).div(tax.total).div(2);
            amountToSwap = swapThreshold.sub(amountToLiquify);
        }
        
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
            uint256 amountBNBLiquidity = 0;
            uint256 amountBNBReflection = amountBNB;
            uint256 amountBNBBuyback = 0;
            if (tax.total > 0){
                uint256 totalBNBFee = tax.total.sub(swapLiquidityFee.div(2));
                amountBNBLiquidity = amountBNB.mul(swapLiquidityFee).div(totalBNBFee).div(2);
                amountBNBReflection = amountBNB.mul(tax.reflection).div(totalBNBFee);
                amountBNBBuyback = amountBNB.mul(tax.buyback).div(totalBNBFee);

            }
            if (amountBNBReflection > 0) {
                try distributor.deposit{value: amountBNBReflection}() {} catch {}
            }
            if (amountBNBBuyback > 0){
                (bool buybackSuccess, ) = payable(buybackFeeReceiver).call{value: amountBNBBuyback, gas: buybackGas}("");
                emit BuybackTransfer(buybackSuccess);
            }
            if(amountToLiquify > 0){
                try router.addLiquidityETH{ value: amountBNBLiquidity }(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    autoLiquidityReceiver,
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
    
    function setAirdropBUSDthreshold(uint256 amount) external authorizedFor(Permission.AdjustContractVariables) {
        AirdropBUSDthreshold = amount;
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

    function setTaxs(uint16 _transferType, uint256 _totalFee, uint256 _liquidityFee, uint256 _reflectionFee, uint256 _buybackFee, uint256 _feeDenominator) external authorizedFor(Permission.AdjustContractVariables) {
        require(_totalFee==_liquidityFee+_reflectionFee+_buybackFee, "Total Fee should be same as the sum of other fees!");
        require(_totalFee.mul(100).div(_feeDenominator)<=60, "Total Fee shouldn't be bigger than 60%!");
        require(_transferType<5, "TransferType is smaller than 5!");

        if (_transferType == 1){ // Buy
            buyFees = Tax(_totalFee, _liquidityFee, _reflectionFee, _buybackFee);
            feeDenominator = _feeDenominator;
        }
        else if (_transferType == 2){ // Sell
            sellFees = Tax(_totalFee, _liquidityFee, _reflectionFee, _buybackFee);
            feeDenominator = _feeDenominator;
        }
        else if (_transferType == 3){ // High Sell
            highSellFees = Tax(_totalFee, _liquidityFee, _reflectionFee, _buybackFee);
            feeDenominator = _feeDenominator;
        }
        else if (_transferType == 4){ // Transfer
            transferFees = Tax(_totalFee, _liquidityFee, _reflectionFee, _buybackFee);
            feeDenominator = _feeDenominator;
        }
        else if (_transferType == 0){ // None
            noneFees = Tax(_totalFee, _liquidityFee, _reflectionFee, _buybackFee);
            feeDenominator = _feeDenominator;
        }
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _buybackFeeReceiver) external authorizedFor(Permission.AdjustContractVariables) {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        buybackFeeReceiver = _buybackFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorizedFor(Permission.AdjustContractVariables) {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }
    

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorizedFor(Permission.AdjustContractVariables) {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external authorizedFor(Permission.AdjustContractVariables) {
        distributorGas = gas;
    }

    function setBuybackGas(uint256 gas) external authorizedFor(Permission.AdjustContractVariables) {
        buybackGas = gas;
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

    function setIsTradableLockExempt(address holder, bool exempt) external authorizedFor(Permission.AdjustContractVariables) {
        isTradableLockExempt[holder] = exempt;
    }

    function setIsHighTaxExempt(address holder, bool exempt) external authorizedFor(Permission.AdjustContractVariables) {
        isHighTaxExempt[holder] = exempt;
    }

    function setIsTransferFeeExempt(address holder, bool exempt) external authorizedFor(Permission.AdjustContractVariables) {
        isTransferFeeExempt[holder] = exempt;
    }
    function setIsTradeFeeExempt(address holder, bool exempt) external authorizedFor(Permission.AdjustContractVariables) {
        isTradeFeeExempt[holder] = exempt;
    }

    function setIsAllExempt(address holder, bool exempt) internal authorizedFor(Permission.AdjustContractVariables) {
        isDividendExempt[holder] = exempt;
        isTradableLockExempt[holder] = exempt;
        isTransferFeeExempt[holder] = exempt;
        isTradeFeeExempt[holder] = exempt;
        isHighTaxExempt[holder] = exempt;
    }

    function setTradable() external authorizedFor(Permission.AdjustContractVariables) {
        tradableLock = false;
    }

    function setHighTaxEnabled(bool _enabled) external authorizedFor(Permission.AdjustContractVariables) {
        highTaxEnabled = _enabled;
    }

    function setSwapThresholdEnabled(bool _enabled) external authorizedFor(Permission.AdjustContractVariables) {
        swapThresholdEnabled = _enabled;
    }

    function setTransferFeeEnabled(bool _enabled) external authorizedFor(Permission.AdjustContractVariables) {
        transferFeeEnabled = _enabled;
    }

    function setHighTaxMinimum(uint256 _amount) external authorizedFor(Permission.AdjustContractVariables) {
        require(_amount >= highTaxMinimumLimit, "The high tax minimum amount can't be smaller than highTaxMinimumLimit");
        highTaxMinimum = _amount;
    }
    function setMaxSellAmount(uint256 _amount) external authorizedFor(Permission.AdjustContractVariables) {
        require(_amount >= 50 * (10 ** 9) * (10 ** _decimals), "The high tax minimum amount can't be smaller than 50 billion");
        maxSellAmount = _amount;
    }
    function initTaxs() internal authorizedFor(Permission.AdjustContractVariables) {
        buyFees = Tax(1800, 1400, 300, 100);
        sellFees = Tax(2000, 1600, 300, 100);
        highSellFees = Tax(3500, 3100, 300, 100);
        transferFees = Tax(1400, 1000, 300, 100);
        noneFees = Tax(0, 0, 0, 0);
    }
    function initOwner() internal authorizedFor(Permission.AdjustContractVariables) {
        address owner_ = msg.sender;
        setIsAllExempt(address(this), true);
        setIsAllExempt(owner_, true);
        isDividendExempt[pancakeV2BNBPair] = true;
        isDividendExempt[DEAD] = true;
        autoLiquidityReceiver = owner_;
        buybackFeeReceiver = owner_;
        _balances[owner_] = _totalSupply;
        emit Transfer(address(0), owner_, _totalSupply);
    }
    function getTax(address sender, address recipient, uint256 amount) public view returns (Tax memory) {
        uint16 _transferMethod = isTranferMethod(sender, recipient);
        if (_transferMethod==0 && transferFeeEnabled && !isTransferFeeExempt[sender]){ // General transfer
            return transferFees;
        }
        else if (_transferMethod==1 && !isTradeFeeExempt[sender]){ // Buy
            return buyFees;
        }
        else if (_transferMethod==2 && !isTradeFeeExempt[sender]){ // Sell
            if (highTaxEnabled && amount >= highTaxMinimum && !isHighTaxExempt[sender]) { // High Sell
                return highSellFees;
            }
            return sellFees;
        }
        return noneFees;
    }

    function getShare(address holder) public view returns (Share memory) {
        return distributor.getShare(holder);
    }
    function getTotalShares() public view returns (uint256) {
        return distributor.getTotalShares();
    }
    function getDividendsPerShare() public view returns (uint256) {
        return distributor.getDividendsPerShare();
    }
    function getUnpaidEarnings(address holder) public view returns (uint256) {
        return distributor.getUnpaidEarnings(holder);
    }
   
}