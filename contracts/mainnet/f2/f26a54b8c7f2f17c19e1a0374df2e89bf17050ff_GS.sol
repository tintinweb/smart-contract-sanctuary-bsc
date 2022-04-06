/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
/**
 * SAFEMATH LIBRARY
 */
library SafeMath {
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit(uint balanceBefore) external;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;
    address immutable _token;
    struct Share {
        uint256 amount;
        uint256 totalExcluded;// excluded dividend
        uint256 totalRealised;
    }

    IBEP20 immutable USDT;
    IDEXRouter immutable router;

    address[] shareholders;
    mapping (address => uint256) public  shareholderIndexes;
    mapping (address => uint256) public shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;// to be shown in UI
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 public currentIndex;

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router, address _BUSD) {
        router = IDEXRouter(_router);
        USDT = IBEP20(_BUSD);
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

    function deposit(uint balanceBefore) external override onlyToken {
        uint256 amount = USDT.balanceOf(address(this)).sub(balanceBefore);
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
            USDT.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }
    /*
    returns the  unpaid earnings
    */
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

contract GS is IBEP20, Auth {
    using SafeMath for uint256;

    uint256 public constant MASK = type(uint128).max;
    address constant USDT  = 0x55d398326f99059fF775485246999027B3197955;
    address constant DEAD  = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "GS";
    string constant _symbol = "GS";
    uint8 constant _decimals = 18;

    uint256 constant _totalSupply = 1e10 * (10 ** _decimals);
    uint256 public _maxTxAmount = _totalSupply.mul(2).div(1000); // 0.2%

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;

    uint256 constant burnFee = 10;
    uint256 constant marketingFee = 10;
    uint256 constant distributefee = 60;
    uint256 constant inviterFee = 50;

    address public immutable marketingFeeReceiver;
    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;

    DividendDistributor immutable distributor;

    uint256 distributorGas = 500000;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 100000;
    bool inSwap;
    
    mapping (address => address) public inviter;

    modifier swapping() { inSwap = true; _; inSwap = false; }

    uint256 public _maxHavAmount = _totalSupply * 6 / 1000;
    mapping (address => bool) isHavLimitExempt;

    address public immutable protectionFeeReceiver;
    bool public isProtection;
    uint256 public INTERVAL = 24 * 60 * 60;
    uint256 public _protectionT;
    uint256 public _protectionP;

    bool public presaleEnded = false;

    constructor ( address _marketingAddress, address _protectionAddress) Auth(msg.sender) {
        address _dexRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        router = IDEXRouter(_dexRouter);
        pair = IDEXFactory(router.factory()).createPair(USDT, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        
        distributor = new DividendDistributor(_dexRouter, USDT);

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        isHavLimitExempt[msg.sender] = true;
        isHavLimitExempt[address(this)] = true;
        isHavLimitExempt[DEAD] = true;
        isHavLimitExempt[address(0)] = true;
        isHavLimitExempt[pair] = true;

        marketingFeeReceiver = _marketingAddress;
        protectionFeeReceiver = _protectionAddress;

        approve(_dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
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

    function updatePresaleStatus() external authorized {
        presaleEnded = true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if (recipient == pair && _balances[pair] == 0) {
            require(presaleEnded == true, "You are not allowed to add liquidity before presale is ended");
        }

        checkTxLimit(sender, amount);

        if(isProtection && block.timestamp.sub(_protectionT) >= INTERVAL){_resetProtection();}

        require(recipient == pair || _balances[recipient].add(amount) <= _maxHavAmount || isHavLimitExempt[recipient], "HAV Limit Exceeded");

        if(shouldSwapBack()){ swapBack(); }
        if(!launched() && recipient == pair){ require(_balances[sender] > 0); launch(); }

        bool shouldInvite = (_balances[recipient] == 0 && inviter[recipient] == address(0) 
            && !isContract(sender) && !isContract(recipient));

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);


        if(shouldInvite) { inviter[recipient] = sender; }

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        return true;
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 balanceBefore = IBEP20(USDT).balanceOf(address(distributor));
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDT);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            swapThreshold,
            0,
            path,
            address(distributor),
            block.timestamp
        );
        distributor.deposit(balanceBefore);
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return (sender == pair || recipient == pair) && !isFeeExempt[sender];
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        if(launchedAt + 8 >= block.number){
            uint some = amount.div(100);
            uint256 antAmount = amount.sub(some);
            _balances[address(this)] = _balances[address(this)].add(antAmount);
            emit Transfer(sender, address(this), antAmount);
            return some; 
        }

        uint invAmount = 0;
        if(sender == pair){
            address cur = sender;
            if (sender == pair) { cur = receiver; }
            uint8[5] memory inviteRate =  [20, 10, 10, 5, 5];
            for (uint8 i = 0; i < 5;) {
                uint8 rate = inviteRate[i];
                cur = inviter[cur];
                if (cur == address(0)) { cur = DEAD; }
                uint256 curTAmount = amount * rate / 1000;
                _balances[cur] += curTAmount;
                invAmount +=curTAmount;
                emit Transfer(sender, cur, curTAmount);
                unchecked { ++i; }
            }

        }

        uint protectionAmount = 0;
        uint disFee = distributefee;
        if(receiver == pair){ 
            disFee = disFee.add(70); 
            
            if(isProtection == true){
                uint256 currentP = IBEP20(USDT).balanceOf(pair).div(_balances[pair].div(10000));
                if(currentP < _protectionP.mul(90).div(100)){
                    protectionAmount = amount.mul(3).div(100);
                    _balances[protectionFeeReceiver] += protectionAmount;
                    emit Transfer(sender, protectionFeeReceiver, protectionAmount);
                }
            }

        }

        invAmount += protectionAmount;

        uint256 distributeAmount = amount.mul(disFee).div(1000);
        _balances[address(this)] = _balances[address(this)].add(distributeAmount);
        emit Transfer(sender, address(this), distributeAmount);

        uint256 burnFeeAmount = amount.mul(burnFee).div(1000);
        _balances[DEAD] = _balances[DEAD].add(burnFeeAmount);
        emit Transfer(sender, DEAD, burnFeeAmount);

        uint256 marketingAmount = amount.mul(marketingFee).div(1000);
        _balances[marketingFeeReceiver] = _balances[marketingFeeReceiver].add(marketingAmount);
        emit Transfer(sender, marketingFeeReceiver, marketingAmount);

        return amount
            .sub(invAmount)
            .sub(distributeAmount)
            .sub(burnFeeAmount)
            .sub(marketingAmount);
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function setMaxHavAmount(uint256 maxHavAmount) external authorized {
        _maxHavAmount = maxHavAmount;
    }

    function launch() internal {
        require(launchedAt == 0, "Already launched boi");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
    }

    function setSwapThreshold(uint256 _swapThreshold) external authorized {
        swapThreshold = _swapThreshold;
    }
    function setTxLimit(uint256 amount) external authorized {
        require(amount >= _totalSupply / 1000);
        _maxTxAmount = amount;
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

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt, bool havExempt) external authorized {
        isTxLimitExempt[holder] = exempt;
        isHavLimitExempt[holder] = havExempt;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000);
        distributorGas = gas;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function setProtection(bool _isProtection) external authorized {
        isProtection = _isProtection;
    }

    function _resetProtection() private {
        uint256 time = block.timestamp;
        if (time.sub(_protectionT) >= INTERVAL) {
        _protectionT = time;
        _protectionP = IBEP20(USDT).balanceOf(pair).div(_balances[pair].div(10000));
        }
    }

    function resetProtection() external authorized {
        _protectionT = block.timestamp;
        _protectionP = IBEP20(USDT).balanceOf(pair).div(_balances[pair].div(10000));
    }

}