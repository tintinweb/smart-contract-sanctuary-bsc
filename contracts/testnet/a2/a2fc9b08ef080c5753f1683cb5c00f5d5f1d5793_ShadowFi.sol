/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// File: ShadowFi.sol

/**
                                                       
                             
                                                                                          
                                                                                          
                                                 .-==+*###%%                              
                                            -+*%@@@@@@@@@@@@                              
                                        :+#@@@@@@@@@@@@@@@@@                              
                                     -*@@@@@@@@@@@@@@@@@@@@@                              
                                  :*@@@@@@@@@@@@@@@@@@@@@@@@                              
                                -#@@@@@@@@@@@@@@@@@#*+=-::..                              
                              -%@@@@@@@@@@@@@@%+-.                                        
                            .*@@@@@@@@@@@@@#-                                             
                           [email protected]@@@@@@@@@@@#=.                                               
                          *@@@@@@@@@@@#:                                                  
                        .%@@@@@@@@@@@-               :=+*#%%                              
                        %@@@@@@@@@@*             -*%@@@@@@@@                              
                       #@@@@@@@@@@-           .*@@@@@@@@@@@@                              
                      [email protected]@@@@@@@@@-          .*@@@@@@@@@@@@@@                              
                     :@@@@@@@@@@-          [email protected]@@@@@@@@@@@@@@@                              
                     *@@@@@@@@@*          [email protected]@@@@@@@@@@@%*=:.                              
                     @@@@@@@@@@          [email protected]@@@@@@@@@%-                                    
                    :@@@@@@@@@*         :@@@@@@@@@@*                                      
                    [email protected]@@@@@@@@-         *@@@@@@@@@#                                       
                    *@@@@@@@@@:         @@@@@@@@@@:                                       
                     .........         [email protected]@@@@@@@@%          @@@@@@@@@@                    
                                       [email protected]@@@@@@@@+         [email protected]@@@@@@@@@                    
                                      [email protected]@@@@@@@@@:         [email protected]@@@@@@@@#                    
                                     *@@@@@@@@@@#          #@@@@@@@@@=                    
                                .:=#@@@@@@@@@@@%          :@@@@@@@@@@.                    
                              %@@@@@@@@@@@@@@@%           %@@@@@@@@@*                     
                              %@@@@@@@@@@@@@@+           #@@@@@@@@@@.                     
                              %@@@@@@@@@@@@+.           #@@@@@@@@@@:                      
                              %@@@@@@@@@*-            :%@@@@@@@@@@-                       
                              %@@@%#+-.              *@@@@@@@@@@@=                        
                                                   [email protected]@@@@@@@@@@@:                         
                                                 [email protected]@@@@@@@@@@@%.                          
                                             .-#@@@@@@@@@@@@@=                            
                                          :+%@@@@@@@@@@@@@@*                              
                                  .:-=+*%@@@@@@@@@@@@@@@@*:                               
                              %@@@@@@@@@@@@@@@@@@@@@@@@+                                  
                              %@@@@@@@@@@@@@@@@@@@@@#-                                    
                              %@@@@@@@@@@@@@@@@@%+:                                       
                              %@@@@@@@@@@@@@#+:                                           
                              %@@@@@%#*+=:.                                               
                              ..                                                          
                                                                                          
                                                       
ShadowFi.
Safe, simple, private spending, online and in person. 
| Website: https://shadowfi.com
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
    Buyback,
    AdjustContractVariables,
    Authorize,
    Unauthorize,
    LockPermissions,
    ExcludeInclude
}

/**
 * Allows for contract ownership along with multi-address authorization for different permissions
 */
abstract contract ShadowAuth {
    struct PermissionLock {
        bool isLocked;
        uint64 expiryTime;
    }

    address public owner;
    mapping(address => mapping(uint256 => bool)) private authorizations; // uint256 is permission index
    
    uint256 constant NUM_PERMISSIONS = 10; // always has to be adjusted when Permission element is added or removed
    mapping(string => uint256) permissionNameToIndex;
    mapping(uint256 => string) permissionIndexToName;

    mapping(uint256 => PermissionLock) lockedPermissions;

    constructor(address owner_) {
        owner = owner_;
        for (uint256 i; i < NUM_PERMISSIONS; i++) {
            authorizations[owner_][i] = true;
        }

        permissionNameToIndex["ChangeFees"] = uint256(Permission.ChangeFees);
        permissionNameToIndex["Buyback"] = uint256(Permission.Buyback);
        permissionNameToIndex["AdjustContractVariables"] = uint256(Permission.AdjustContractVariables);
        permissionNameToIndex["Authorize"] = uint256(Permission.Authorize);
        permissionNameToIndex["Unauthorize"] = uint256(Permission.Unauthorize);
        permissionNameToIndex["LockPermissions"] = uint256(Permission.LockPermissions);
        permissionNameToIndex["ExcludeInclude"] = uint256(Permission.ExcludeInclude);

        permissionIndexToName[uint256(Permission.ChangeFees)] = "ChangeFees";
        permissionIndexToName[uint256(Permission.Buyback)] = "Buyback";
        permissionIndexToName[uint256(Permission.AdjustContractVariables)] = "AdjustContractVariables";
        permissionIndexToName[uint256(Permission.Authorize)] = "Authorize";
        permissionIndexToName[uint256(Permission.Unauthorize)] = "Unauthorize";
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
        require(adr != address(0), "Invalid Address");
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
    function process(uint256 gas) external;
    function claimDividend() external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IBEP20 constant BUSD = IBEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
    address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 constant dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 hours; // min 1 hour delay
    uint256 public minDistribution = 1 * (10 ** 18); // 1 BUSD minimum auto send

    event ParameterUpdated();

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

    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        require(_minPeriod <= 24 hours && _minDistribution <= 10000000000000000000, "Outside of allowed limits.");
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
        emit ParameterUpdated();
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
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
            BUSD.transfer(shareholder, amount);
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
}

contract ShadowFi is IBEP20, ShadowAuth {
    using SafeMath for uint256;

    address constant BUSD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "ShadowFi";
    string constant _symbol = "SDF";
    uint8 constant _decimals = 9;

    uint256 constant _totalSupply = 10 ** 8 * (10 ** _decimals);
    uint256 constant _maxSupply = 10 ** 8 * (10 ** _decimals);
    uint256 public _maxTxAmount; // 0.1%
    uint256 private gasPriceLimit = 7 * 1 gwei; 

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) allowedAddresses;
    mapping(address => bool) private airdropped; // airdropped addresses
    mapping(address => bool) private blackList;
    mapping(address => bool) private authorizedContract;

    uint256 liquidityFee = 200;
    uint256 buybackFee = 0;
    uint256 reflectionFee = 200;
    uint256 marketingFee = 200;
    uint256 totalBuyFee = 600;
    uint256 totalSellFee = 600;
    uint256 feeDenominator = 10000;

    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;

    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address pancakeV2BNBPair;
    address[] public pairs;

    uint256 public launchedAt;

    uint256 buybackMultiplierNumerator = 150;
    uint256 buybackMultiplierDenominator = 100;
    uint256 buybackMultiplierTriggeredAt;
    uint256 buybackMultiplierLength = 30 minutes;

    bool public feesOnNormalTransfers = false;

    DividendDistributor distributor;
    uint256 distributorGas = 500000;

    bool public swapEnabled = true;
    uint256 public swapThreshold;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    uint256 transferBlockTime;
    bool gasLimitsEnabled = true;

    event ParameterUpdated();

    constructor (uint256 _transferBlockTime) ShadowAuth(msg.sender) {
        router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pancakeV2BNBPair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = ~uint256(0);

        pairs.push(pancakeV2BNBPair);
        distributor = new DividendDistributor(address(router));

        address owner_ = msg.sender;
        allowedAddresses[owner_] = true;
        authorizedContract[owner_] = true;
        isFeeExempt[owner_] = true;
        isTxLimitExempt[owner_] = true;
        isDividendExempt[pancakeV2BNBPair] = true;
        isDividendExempt[address(this)] = true;
        isFeeExempt[address(this)] = true;
        isTxLimitExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        autoLiquidityReceiver = owner_;
        marketingFeeReceiver = owner_;

        transferBlockTime = _transferBlockTime;

        _maxTxAmount = _maxSupply / 1000;
        swapThreshold = _totalSupply / 5000; // 0.02%

        _balances[owner_] = _totalSupply;
        emit Transfer(address(0), owner_, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO)); }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        if (!allowedAddresses[msg.sender]) {
            require(block.timestamp > transferBlockTime, "Transfers have not been enabled yet.");
        }

        require(!blackList[msg.sender], "You are a bad boy!");

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
        if (!allowedAddresses[msg.sender] && !allowedAddresses[recipient]) {
            require(block.timestamp > transferBlockTime, "Transfers have not been enabled yet.");
        }
       
       require(!blackList[sender] && !blackList[recipient], "Either the spender or recipient is blacklisted.");

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(gasLimitsEnabled && sender == pancakeV2BNBPair){
            require(tx.gasprice <= gasPriceLimit,"Gas price exceeds limit.");
        }
        
        checkTxLimit(sender, amount);

        if(shouldSwapBack()){ swapBack(); }

        if(!launched() && recipient == pancakeV2BNBPair){ require(_balances[sender] > 0); launch(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
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

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if (isFeeExempt[sender] || isFeeExempt[recipient] || !launched()) return false;

        address[] memory liqPairs = pairs;

        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (sender == liqPairs[i] || recipient == liqPairs[i]) return true;
        }

        return feesOnNormalTransfers;
    }

    function getTotalFee(bool selling) public view returns (uint256) {
        if(launchedAt + 1 >= block.number){ return feeDenominator.sub(1); }
        if(selling && buybackMultiplierTriggeredAt.add(buybackMultiplierLength) > block.timestamp){ return getMultipliedFee(); }
        return selling ? totalSellFee : totalBuyFee;
    }

    function getMultipliedFee() public view returns (uint256) {
        uint totalFee = totalSellFee;
        uint256 remainingTime = buybackMultiplierTriggeredAt.add(buybackMultiplierLength).sub(block.timestamp);
        uint256 feeIncrease = totalFee.mul(buybackMultiplierNumerator).div(buybackMultiplierDenominator).sub(totalFee);
        return totalFee.add(feeIncrease.mul(remainingTime).div(buybackMultiplierLength));
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(isSell(recipient))).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }
        
    function isSell(address recipient) internal view returns (bool) {
        address[] memory liqPairs = pairs;
        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (recipient == liqPairs[i]) return true;
        }
        return false;
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pancakeV2BNBPair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalBuyFee).div(2);
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

            uint256 totalBNBFee = totalBuyFee.sub(dynamicLiquidityFee.div(2));

            uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
            uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
            uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);

            try distributor.deposit{value: amountBNBReflection}() {} catch {}
            payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000};

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

    function triggerBuyback(uint256 amount, bool triggerBuybackMultiplier) external authorizedFor(Permission.Buyback) {
        buyTokens(amount, DEAD);
        if(triggerBuybackMultiplier){
            buybackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(buybackMultiplierLength);
        }
    }
    
    function clearBuybackMultiplier() external authorizedFor(Permission.Buyback) {
        buybackMultiplierTriggeredAt = 0;
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        try router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: amount }(
            0,
            path,
            to,
            block.timestamp
        ) {
            emit BoughtBack(amount, to);
        } catch Error(string memory reason) {
            revert(string(abi.encodePacked("Buyback failed with error ", reason)));
        } catch {
            revert("Buyback failed without an error message from pancakeSwap");
        }
    }

    function setBuybackMultiplierSettings(uint256 numerator, uint256 denominator, uint256 length) external authorizedFor(Permission.AdjustContractVariables) {
        require(numerator / denominator <= 3 && numerator > denominator);
        buybackMultiplierNumerator = numerator;
        buybackMultiplierDenominator = denominator;
        buybackMultiplierLength = length;
        emit ParameterUpdated();
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
        emit Launched(block.number, block.timestamp);
    }

    function setTxLimit(uint256 amount) external authorizedFor(Permission.AdjustContractVariables) {
        require(amount >= _totalSupply / 2000);
        _maxTxAmount = amount;
        emit ParameterUpdated();
    }

    function setIsDividendExempt(address holder, bool exempt) external {
        require(authorizedContract[msg.sender], "Not Authorized Contract");
        require(holder != address(this) && holder != pancakeV2BNBPair);
        
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
        emit ParameterUpdated();
    }

    function setIsFeeExempt(address holder, bool exempt) external {
        require(authorizedContract[msg.sender], "Not Authorized Contract");
        isFeeExempt[holder] = exempt;
        emit ParameterUpdated();
    }

    function setIsTxLimitExempt(address holder, bool exempt) external {
        require(authorizedContract[msg.sender], "Not Authorized Contract");
        isTxLimitExempt[holder] = exempt;
        emit ParameterUpdated();
    }

    function setFees(uint256 _liquidityFee, uint256 _buybackFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _feeDenominator, uint256 _totalSellFee) external authorizedFor(Permission.AdjustContractVariables) {
        require(totalBuyFee <= feeDenominator / 10, "Buy fee too high");
        require(totalSellFee <= feeDenominator / 5, "Sell fee too high");
        liquidityFee = _liquidityFee;
        buybackFee = _buybackFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        totalBuyFee = _liquidityFee.add(_buybackFee).add(_reflectionFee).add(_marketingFee);
        feeDenominator = _feeDenominator;
        totalSellFee = _totalSellFee;
        emit ParameterUpdated();
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver) external authorizedFor(Permission.AdjustContractVariables) {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        emit ParameterUpdated();
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorizedFor(Permission.AdjustContractVariables) {
        swapEnabled = _enabled;
        swapThreshold = _amount;
        emit ParameterUpdated();
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorizedFor(Permission.AdjustContractVariables) {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
        emit ParameterUpdated();
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorizedFor(Permission.AdjustContractVariables) {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
        emit ParameterUpdated();
    }

    function setDistributorSettings(uint256 gas) external authorizedFor(Permission.AdjustContractVariables) {
        require(gas <= 1000000);
        distributorGas = gas;
        emit ParameterUpdated();
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _maxSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pancakeV2BNBPair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function claimDividend() external {
        distributor.claimDividend();
    }
    
    function addPair(address pair) external authorizedFor(Permission.AdjustContractVariables) {
        pairs.push(pair);
        emit ParameterUpdated();
    }
    
    function removeLastPair() external authorizedFor(Permission.AdjustContractVariables) {
        pairs.pop();
        emit ParameterUpdated();
    }
    
    function setFeesOnNormalTransfers(bool _enabled) external authorizedFor(Permission.AdjustContractVariables) {
        feesOnNormalTransfers = _enabled;
        emit ParameterUpdated();
    }

    function setLaunchedAt(uint256 launched_) external authorizedFor(Permission.AdjustContractVariables) {
        launchedAt = launched_;
    }

    /*******************************************************************************************************/
    /************************************* Added Functions *************************************************/
    /*******************************************************************************************************/
    function setAllowedAddress(address user, bool flag) external onlyOwner {
        allowedAddresses[user] = flag;
        emit ParameterUpdated();
    }

    function setGasPriceLimit(uint256 GWEI) external onlyOwner {
        require(GWEI >= 5, "can never be set below 5");
        gasPriceLimit = GWEI * 1 gwei;
        emit ParameterUpdated();
    }

    function enableGasLimit(bool flag) external onlyOwner {
        gasLimitsEnabled = flag;
        emit ParameterUpdated();
    }

    function burn(uint256 _amount) public {
        _transferFrom(msg.sender, DEAD, _amount);

        emit burnTokens(msg.sender, _amount);
    }

    function airdrop(address _user, uint256 _amount) external onlyOwner {
        if(airdropped[_user] == false){
        _transferFrom(msg.sender, _user, _amount);
        airdropped[_user] = true;

        emit airdropTokens(_user, _amount);
        }
    }

    function isAirdropped(address account) external view returns (bool) {
        return airdropped[account];
    }
    
    function checkFeeExempt(address account) external view returns (bool) {
        return isFeeExempt[account];
    }
    
    function checkDividendExempt(address account) external view returns (bool) {
        return isDividendExempt[account];
    }
    
    function checkTXLimitExempt(address account) external view returns (bool) {
        return isTxLimitExempt[account];
    }

    function checkAuthorized(address _authorizedContract) external view returns (bool) {
        return authorizedContract[_authorizedContract];
    }

    function setBlackListed(address user, bool flag) external onlyOwner {
        blackList[user] = flag;
    }
    
    function setAuthorized(address _authorizedContract, bool flag) external onlyOwner {
        authorizedContract[_authorizedContract] = flag;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event BuybackMultiplierActive(uint256 duration);
    event BoughtBack(uint256 amount, address to);
    event Launched(uint256 blockNumber, uint256 timestamp);
    event SwapBackSuccess(uint256 amount);
    event SwapBackFailed(string message);
    event burnTokens(address account, uint256 amount);
    event airdropTokens(address user, uint256 amount);
}