/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

// File: contracts/IBEP20.sol

// File: contracts/IBEP20.sol
//SPDX-License-Identifier: unlicensed

pragma solidity ^0.8.0;

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
// File: contracts/SafeMath.sol

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
// File: contracts/DividendDistributor.sol



pragma solidity ^0.8.0;



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

interface IDividendDistributor {
    function setDistributionCriteria(/*uint256 _minPeriod,*/ uint256 _minTokenHolderBalance) external;
    function updateShareHolders(address shareholder, uint256 amount) external;
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

    struct MAP {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
        // mapping(address => uint) lastClaimTime;
        mapping(address => uint) lastDepositCountClaim;
        mapping(address => uint) totalClaimsMade;
    }

    MAP private tokenHoldersMap;

    // IBEP20 BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);mainnet busd
    IBEP20 BUSD = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    // address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; mainnet wbnb
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

    uint256 public minPeriod = 1 hours;
    uint256 public minTokenHolderBalance = 100000 * 10 ** 18;

    uint256 currentIndex;
    uint256 lastDepositTime;
    uint256 public totalDepositCounts;

    mapping(uint256 => uint256) recordedDeposit;
    mapping(uint256 => uint256) totalHolders;
    mapping(uint256 => uint256) recordedShare;

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        router = _router != address(0)
        ? IDEXRouter(_router)
        : IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        _token = msg.sender;
    }

    function setDistributionCriteria(/*uint256 _minPeriod, */uint256 _minTokenHolderBalance) external override onlyToken {
        // minPeriod = _minPeriod;
        minTokenHolderBalance = _minTokenHolderBalance;
    }
    function getDistributionCriteria() external view onlyToken returns(uint256) {
        return minTokenHolderBalance;
    }

    function setLastDepositTime(uint256 amountReceived) public onlyToken{
        lastDepositTime = block.timestamp;
        recordedDeposit[totalDepositCounts] = amountReceived;
        recordedShare[totalDepositCounts] = recordedDeposit[totalDepositCounts].div(totalHolders[totalDepositCounts]);
        totalShares = totalShares.add(recordedShare[totalDepositCounts]);
        totalDepositCounts++;
    }
    function getDepositCountDetails(uint256 _totalDepositCount) public view returns (uint256, uint256, uint256,uint256){
        return (recordedDeposit[_totalDepositCount], recordedShare[_totalDepositCount],totalHolders[_totalDepositCount],totalShares);
    }
    function showPendingRewards(address shareholder) public view returns (uint256){
        if(MAPGetIndexOfKey(shareholder) == -1){
            return 0;
        }
        uint256 lastUserCountClaim = tokenHoldersMap.lastDepositCountClaim[shareholder];
        uint256 totalPendingAmount = 0;
        for(uint i = lastUserCountClaim; i<=totalDepositCounts.sub(1); i++){
            totalPendingAmount = totalPendingAmount.add(recordedShare[i]);
        }
        return totalPendingAmount;
    }
    function claimRewards(address shareholder)public returns (uint256){
        uint256 totalPendingAmount = showPendingRewards(shareholder);
        if(totalPendingAmount > 0){
            BUSD.transfer(shareholder,totalPendingAmount);
            tokenHoldersMap.lastDepositCountClaim[shareholder] = totalDepositCounts;
            tokenHoldersMap.totalClaimsMade[shareholder] = tokenHoldersMap.totalClaimsMade[shareholder].add(totalPendingAmount);
        }
        return totalPendingAmount;
    }
    function updateShareHolders(address shareholder, uint256 _holderBalance) external override onlyToken {
        // if the shareholder doesn't exist and has the minimum balance needed to be part then add the shareholder
        if(MAPGetIndexOfKey(shareholder) == -1 && _holderBalance >= minTokenHolderBalance){
            MAPSet(shareholder,_holderBalance);
            totalHolders[totalDepositCounts] = tokenHoldersMap.keys.length;
        }
        // if the shareholder does exist but doesn't have the minimum balance needed to be part then remove the shareholder
        if(MAPGetIndexOfKey(shareholder) > -1 && _holderBalance < minTokenHolderBalance){
            MAPRemove(shareholder);
        }
    }
    function MAPGetKeyAtIndex(uint index) public view returns (address) {
        return tokenHoldersMap.keys[index];
    }

    function MAPSize() public view returns (uint) {
        return tokenHoldersMap.keys.length;
    }
    function MAPGet(address key) public view returns (uint) {
        return tokenHoldersMap.values[key];
    }
    function MAPGetIndexOfKey(address key) public view returns (int) {
        if(!tokenHoldersMap.inserted[key]) {
            return -1;
        }
        return int(tokenHoldersMap.indexOf[key]);
    }

    function MAPSet(address key, uint val) public {
        if (tokenHoldersMap.inserted[key]) {
            tokenHoldersMap.values[key] = val;
        } else {
            tokenHoldersMap.inserted[key] = true;
            tokenHoldersMap.values[key] = val;
            tokenHoldersMap.indexOf[key] = tokenHoldersMap.keys.length;
            tokenHoldersMap.keys.push(key);
            tokenHoldersMap.lastDepositCountClaim[key] = totalDepositCounts;
        }
    }

    function MAPRemove(address key) public {
        if (!tokenHoldersMap.inserted[key]) {
            return;
        }

        delete tokenHoldersMap.inserted[key];
        delete tokenHoldersMap.values[key];
        delete tokenHoldersMap.lastDepositCountClaim[key];

        uint index = tokenHoldersMap.indexOf[key];
        uint lastIndex = tokenHoldersMap.keys.length - 1;
        address lastKey = tokenHoldersMap.keys[lastIndex];

        tokenHoldersMap.indexOf[lastKey] = index;
        delete tokenHoldersMap.indexOf[key];

        tokenHoldersMap.keys[index] = lastKey;
        tokenHoldersMap.keys.pop();
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
        uint256 shareholderCount = tokenHoldersMap.keys.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            claimRewards(tokenHoldersMap.keys[currentIndex]);

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    // function shouldDistribute(address shareholder) internal view returns (bool) {
    //     return shareholderClaims[shareholder] + minPeriod < block.timestamp
    //     && getUnpaidEarnings(shareholder) > minTokenHolderBalance;
    // }

    // function distributeDividend(address shareholder) internal {
    //     if(shares[shareholder].amount == 0){ return; }

    //     uint256 amount = getUnpaidEarnings(shareholder);
    //     if(amount > 0){
    //         totalDistributed = totalDistributed.add(amount);
    //         BUSD.transfer(shareholder, amount);
    //         shareholderClaims[shareholder] = block.timestamp;
    //         shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
    //         shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    //     }
    // }

    // function claimDividend() external {
    //     distributeDividend(msg.sender);
    // }

    // function getUnpaidEarnings(address shareholder) public view returns (uint256) {
    //     if(shares[shareholder].amount == 0){ return 0; }

    //     uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
    //     uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

    //     if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

    //     return shareholderTotalDividends.sub(shareholderTotalExcluded);
    // }

    // function getCumulativeDividends(uint256 share) internal view returns (uint256) {
    //     return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    // }

    // function addShareholder(address shareholder) internal {
    //     shareholderIndexes[shareholder] = shareholders.length;
    //     shareholders.push(shareholder);
    // }

    // function removeShareholder(address shareholder) internal {
    //     shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
    //     shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
    //     shareholders.pop();
    // }
}
// File: contracts/Platinum.sol


pragma solidity ^0.8.0;

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

contract PlatinumFinanceToken is IBEP20, Auth {
    using SafeMath for uint256;

    uint256 public constant MASK = type(uint128).max;
    //******************* Mainnet addresses
    // address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    // address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    //******************* Testnet addresses
    address BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address public WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    IBEP20 busdToken = IBEP20(BUSD);
    // ************************************
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "PlatinumFinanceToken";
    string constant _symbol = "PLATINUM";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100*10**6 * (10 ** _decimals);
    uint256 public _maxTxAmount = _totalSupply.div(400); // 0.25%
    uint256 public _maxWallet = _totalSupply.div(200); // 0.25%

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isMaxWalletExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) isRewardsExempt;
    mapping (address=>bool) blackListed;
    mapping (address=>bool) whiteListed;

    uint256 busdFee = 3; // 3% busd fee
    uint256 liquidityFee = 3; // 3% liquidity fee
    uint256 marketingFee = 4; // 4% marketing
    uint256 burnFee = 1; // 1% burn
    uint256 teamFee = 1; // 1% team
    uint256 devFee = 1; // 1% dev
    uint256 totalFee = 13; // 13% total dex buy

    uint256 sBusdFee = 2; // 3% busd sell fee
    uint256 sLiquidityFee = 4; // 4% liquidity sell fee
    uint256 sMarketingFee = 9; // 9% marketing sell fee
    uint256 sBurnFee = 1; // 1% burn sell fee
    uint256 sTeamFee = 1; // 1% team sell fee
    uint256 sDevFee = 1; // 1% dev sell fee
    uint256 sTotalFee = 18; // 18% total dex sell

    // uint256 buybackFee = 200;
    // uint256 reflectionFee = 1000;

    uint256 feeDenominator = 100;

    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    address public teamFeeReceiver;
    address public devFeeReceiver;

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

    DividendDistributor public distributor;
    address public distributorAddress;

    uint256 distributorGas = 500000;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 2000; // 0.005%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor (
        address _dexRouter
    ) Auth(msg.sender) {
        router = IDEXRouter(_dexRouter);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        WBNB = router.WETH();
        distributor = new DividendDistributor(_dexRouter);
        distributorAddress = address(distributor);

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isMaxWalletExempt[msg.sender] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        buyBacker[msg.sender] = true;

        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = msg.sender;
        teamFeeReceiver = msg.sender;
        devFeeReceiver = msg.sender;

        approve(_dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

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
        checkMaxWallet(recipient, amount);
        //
        if(shouldSwapBack()){ swapBack(); }
        if(shouldAutoBuyback()){ triggerAutoBuyback(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);

        if(!isDividendExempt[sender]){ distributor.updateShareHolders(sender, _balances[sender]); }
        if(!isDividendExempt[recipient]){ distributor.updateShareHolders(recipient, _balances[recipient]); }

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

    function checkMaxWallet(address receiver, uint256 amount) internal view {
        require((amount <= _maxWallet && amount.add(_balances[receiver]) <= _maxWallet) || isMaxWalletExempt[receiver] , "Max Wallet Limit Exceeded");
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return (!isFeeExempt[sender] && recipient == pair) || (!isFeeExempt[recipient] && sender == pair); // no p2p charges only dex
        // return !isFeeExempt[sender];
    }

    function getTotalBuyFee() public view returns (uint256) {
        // if(launchedAt + 1 >= block.number){ return feeDenominator.sub(1); }
        return totalFee;
    }
    function getTotalSellFee() public view returns (uint256) {
        if(launchedAt + 1 >= block.number){ return feeDenominator.sub(1); }
        return sTotalFee;
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;

        if(sender == pair){
            // take buy fees
            feeAmount = amount.mul(getTotalBuyFee()).div(feeDenominator);
        }else if(receiver == pair){
            // take sell fees
            feeAmount = amount.mul(getTotalSellFee()).div(feeDenominator);
        }

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
        uint256 amountToLiquify = swapThreshold.mul(liquidityFee).div(totalFee).div(2);
        // uint256 amountForBusd = busdFee.mul(balanceOf(address(this))).div(feeDenominator);
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

        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        // uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountBNBTeam = amountBNB.mul(teamFee).div(totalBNBFee);
        uint256 amountBNBDev = amountBNB.mul(devFee).div(totalBNBFee);
        uint256 amountBNBBUSD = amountBNB.mul(busdFee).div(totalBNBFee);

        // try distributor.deposit{value: amountBNBReflection}() {} catch {}
        payable(marketingFeeReceiver).transfer(amountBNBMarketing);
        payable(teamFeeReceiver).transfer(amountBNBTeam);
        payable(devFeeReceiver).transfer(amountBNBDev);

        uint256 busdBalanceBefore = busdToken.balanceOf(address(this));
        address[] memory nPath = new address[](2);
        nPath[0] = WBNB;
        nPath[1] = BUSD;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountBNBBUSD}(
            0,
            nPath,
            address(this),
            block.timestamp
        );

        uint256 amountBUSD = busdToken.balanceOf(address(this)).sub(busdBalanceBefore);
        busdToken.transfer(distributorAddress,amountBUSD);

        try distributor.setLastDepositTime(amountBUSD) {} catch {}
        

        processLiquidity(amountToLiquify, amountBNBLiquidity);
    }

    function processLiquidity(uint256 _amountToLiquify, uint256 _amountBNBLiquidity) internal{
        if(_amountToLiquify > 0){
            router.addLiquidityETH{value: _amountBNBLiquidity}(
                address(this),
                _amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(_amountBNBLiquidity, _amountToLiquify);
        }
    }

    function shouldAutoBuyback() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && autoBuybackEnabled
        && autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number // After N blocks from last buyback
        && address(this).balance >= autoBuybackAmount;
    }

    // function SolarFlare(uint256 amount) external authorized {
    //     buyTokens(amount, DEAD);
    // }

  

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

    function setTxLimit(uint256 amount) external authorized {
        _maxTxAmount = amount;
    }
    function setMaxWallet(uint256 amount) external authorized {
        _maxWallet = amount;
    }
      function setBlacklisted(address account, bool value) external authorized {
        blackListed[account]= value;
    }
    function setWhitelisted(address account, bool value) external authorized {
        whiteListed[account]= value;
    }
    function setRewardsExempt(address account, bool value) external authorized {
        isRewardsExempt[account]= value;
    }


    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.updateShareHolders(holder, 0);
        }else{
            distributor.updateShareHolders(holder, _balances[holder]);
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

    //    function TransferBNBsOutfromContract(uint256 amount, address payable receiver) external authorized {
    //    uint256 contractBalance = address(this).balance;
    //    require(contractBalance > amount,"Not Enough bnbs");
    //     receiver.transfer(amount);
      

    // }


    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }
    function setBuyFees(uint256 _busdFee, uint256 _liquidityFee, uint256 _marketingFee, uint256 _burnFee, uint256 _teamFee, uint256 _devFee, uint256 _feeDenominator) external authorized {
        busdFee = _busdFee;
        liquidityFee = _liquidityFee;
        // buybackFee = _buybackFee;
        // reflectionFee = _reflectionFee;
        burnFee = _burnFee;
        teamFee = _teamFee;
        devFee = _devFee;
        marketingFee = _marketingFee;
        totalFee = _liquidityFee.add(_busdFee).add(_marketingFee).add(_burnFee).add(_teamFee).add(_devFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/4);
    }
    function setSellFees(uint256 _busdFee, uint256 _liquidityFee, uint256 _marketingFee, uint256 _burnFee, uint256 _teamFee, uint256 _devFee, uint256 _feeDenominator) external authorized {
        sBusdFee = _busdFee;
        sLiquidityFee = _liquidityFee;
        // buybackFee = _buybackFee;
        // reflectionFee = _reflectionFee;
        sBurnFee = _burnFee;
        sTeamFee = _teamFee;
        sDevFee = _devFee;
        sMarketingFee = _marketingFee;
        sTotalFee = _liquidityFee.add(_busdFee).add(_marketingFee).add(_burnFee).add(_teamFee).add(_devFee);
        feeDenominator = _feeDenominator;
        require(sTotalFee < feeDenominator/4);
    }

    function setFeeReceivers(address _teamFeeReceiver, address _devFeeReceiver, address _marketingFeeReceiver) external authorized {
        // autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        teamFeeReceiver = _teamFeeReceiver;
        devFeeReceiver = _devFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function setDistributionCriteria(uint256 _minTokenHolderBalance) external authorized {
        distributor.setDistributionCriteria(_minTokenHolderBalance);
    }
    function setDistributorSettings(uint256 gas) external authorized {
         require(gas < 750000);
        distributorGas = gas;
    }
    function getDistributionCriteria() external view returns(uint256){
        return distributor.getDistributionCriteria();
    }
    function showPendingRewards() external view returns(uint256){
        return distributor.showPendingRewards(msg.sender);
    }
    function getTotalDepositCounts() public view returns(uint256){
        return distributor.totalDepositCounts();
    }
    function getDepositCountDetails() public view returns(uint256, uint256, uint256, uint256){
        return distributor.getDepositCountDetails(getTotalDepositCounts());
    }
    function claimRewards() public returns (uint256){
        return distributor.claimRewards(msg.sender);
    }
    function automateRewards() external authorized{
        distributor.process(distributorGas);
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

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event BuybackMultiplierActive(uint256 duration);
}