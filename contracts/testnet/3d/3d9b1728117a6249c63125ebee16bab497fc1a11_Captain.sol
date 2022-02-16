/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

//SPDX-License-Identifier: MIT

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

    constructor (address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
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
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
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

    IBEP20 BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
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

    uint256 public minPeriod = 2 hours;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 currentIndex;

    modifier onlyToken() {
        require(msg.sender == _token,"msg.sender is not owner"); _;
    }

    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
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
        path[0] = router.WETH();
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
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend() external {
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
    
    function getRealisedbusd(address _useraddress) external view onlyToken returns(uint256) {
        return shares[_useraddress].totalRealised;
    }
    
    function getExcludedbusd(address _useraddress) external view onlyToken returns(uint256) {
        return shares[_useraddress].totalExcluded;
    }
    
    
}

abstract contract DepreciatingFees {
    using SafeMath for uint256;
    struct holderState {
        uint256 amount;
        bool exist;
    }

    struct TRANSACTIONDATA {
        uint256 [] amount;
        bool [] feeReduction;
        uint256 [] transactionTime;
    }
    struct feeStruct {
        address _useraddress;
        uint256 amount;
        uint256 length;
        uint256 __amount;
        uint256 __liquidityFee;
        uint256 __marketingFee;
        uint256 __charityFee;
        uint256 __reflectionFee; 
    }

    mapping(address => holderState) tokenHolder;
    mapping(address => TRANSACTIONDATA) transactionList;
    address[] holders;
    mapping (address => uint256) holdersIndexes;
    mapping (address => bool) public presalelist;
    mapping (address => bool) public privatesalelist;

    uint256 public marketingPenaltyFee = 6;
    uint256 public charityPenaltyFee = 4;
    uint256 public reflectionPenaltyFee = 4;
    
    uint256 public marketingPenaltyFee_sec;
    uint256 public charityPenaltyFee_sec;
    uint256 public reflectionPenaltyFee_sec;

    uint256 public penaltyDivisor = 10**9;
    
    uint256 public penaltyFreeTime;
    uint256 public penaltyFreeTime_normal = 1209600;
    uint256 public penaltyFreeTime_presale = 604800;
    uint256 public penaltyFreeTime_privatesale = 86400;

    uint256 public liquidityBuyFee = 2;
    uint256 public marketingBuyFee = 2;
    uint256 public charityBuyFee = 2;
    uint256 public reflectionBuyFee = 4;

    uint256 public liquiditySellFee = 2;
    uint256 public marketingSellFee = 4;
    uint256 public charitySellFee = 2;
    uint256 public reflectionSellFee = 8;

    uint256 internal liquidityBuyFee_ = liquidityBuyFee * penaltyDivisor;
    uint256 internal marketingBuyFee_ = marketingBuyFee * penaltyDivisor;
    uint256 internal charityBuyFee_ = charityBuyFee * penaltyDivisor;
    uint256 internal reflectionBuyFee_ = reflectionBuyFee * penaltyDivisor;

    uint256 internal liquiditySellFee_ = liquiditySellFee * penaltyDivisor;
    uint256 internal marketingSellFee_ = marketingSellFee * penaltyDivisor;
    uint256 internal charitySellFee_ = charitySellFee * penaltyDivisor;
    uint256 internal reflectionSellFee_ = reflectionSellFee * penaltyDivisor;

    function _getHolderFees (address _useraddress, bool isbuying, uint256 amount) public returns (uint256, uint256, uint256, uint256) {
        
        (uint256 _estimatedLiquidityFee, uint256 _estimatedMarketingFee, uint256 _estimatedCharityFee, 
            uint256 _estimatedReflectionFee) = getEstimatedFee(_useraddress, amount);

        uint256 getLiquidityFee = isbuying ? liquidityBuyFee_ : _estimatedLiquidityFee;
        uint256 getMarketingFee = isbuying ? marketingBuyFee_: _estimatedMarketingFee;
        uint256 getCharityFee = isbuying ? charityBuyFee_: _estimatedCharityFee;
        uint256 getReflectionFee = isbuying ? reflectionBuyFee_: _estimatedReflectionFee;

        return (
            getLiquidityFee,
            getMarketingFee,
            getCharityFee,
            getReflectionFee
        );

    }
    
    function _getPenaltyFee_sec(address _useraddress) internal {
        if (privatesalelist[_useraddress]) {
            penaltyFreeTime = penaltyFreeTime_privatesale;
        } else if (presalelist[_useraddress]) {
            penaltyFreeTime = penaltyFreeTime_presale;
        } else {
            penaltyFreeTime = penaltyFreeTime_normal;
        }
        
        marketingPenaltyFee_sec = marketingPenaltyFee.mul(penaltyDivisor).div(penaltyFreeTime);
        charityPenaltyFee_sec = charityPenaltyFee.mul(penaltyDivisor).div(penaltyFreeTime);
        reflectionPenaltyFee_sec = reflectionPenaltyFee.mul(penaltyDivisor).div(penaltyFreeTime);
    }
    
    function getEstimatedFee(address _useraddress, uint256 amount) internal returns(uint256 reduceLiquidityFee, uint256 reduceMarketingFee,
    uint256 reduceCharityFee, uint256 reduceReflectionFee) {
        require( tokenHolder[_useraddress].amount >= amount, "Token is not sufficient");
        require( amount > 0, "Token to transfer is bigger than 0");
        _getPenaltyFee_sec(_useraddress);
        feeStruct memory estimateFee;
        estimateFee._useraddress = _useraddress;
        estimateFee.length = transactionList[estimateFee._useraddress].amount.length;
        estimateFee.amount = amount;
        estimateFee.__amount = amount;
        estimateFee.__liquidityFee = liquiditySellFee_;
        estimateFee.__marketingFee = marketingSellFee_;
        estimateFee.__charityFee = charitySellFee_;
        estimateFee.__reflectionFee = reflectionSellFee_;
        TRANSACTIONDATA memory transactiondata = transactionList[estimateFee._useraddress];
        uint256 [] memory transaction_amount = transactiondata.amount;
        bool [] memory transaction_feeReduction = transactiondata.feeReduction;
        uint256 [] memory transaction_Time = transactiondata.transactionTime;
        for(uint8 i = 0; i < estimateFee.length; i++) {                       
            uint256 _amount = transaction_amount[i];
            uint256 rest_Time = (penaltyFreeTime > (block.timestamp - transaction_Time[i])) ? penaltyFreeTime - (block.timestamp - transaction_Time[i]) : 0;
            if(transaction_amount[i] > estimateFee.__amount) {
                if(transaction_feeReduction[i]) {
                    if(penaltyFreeTime > (block.timestamp - transaction_Time[i])) {
                        estimateFee.__marketingFee =  estimateFee.__marketingFee.add(marketingPenaltyFee_sec.mul(rest_Time).mul(estimateFee.__amount).div(estimateFee.amount));
                        estimateFee.__charityFee =  estimateFee.__charityFee.add(charityPenaltyFee_sec.mul(rest_Time).mul(estimateFee.__amount).div(estimateFee.amount));
                        estimateFee.__reflectionFee =  estimateFee.__reflectionFee.add(reflectionPenaltyFee_sec.mul(rest_Time).mul(estimateFee.__amount).div(estimateFee.amount));
                        transaction_amount[i] = transaction_amount[i].sub(estimateFee.__amount);
                        transactiondata.amount = transaction_amount;
                        transactionList[estimateFee._useraddress] = transactiondata;
                        return (
                        estimateFee.__liquidityFee,
                        estimateFee.__marketingFee,
                        estimateFee.__charityFee,
                        estimateFee.__reflectionFee
                        );
                    } else {
                        transaction_amount[i] = transaction_amount[i].sub(estimateFee.__amount);
                        transactiondata.amount = transaction_amount;
                        transactionList[estimateFee._useraddress] = transactiondata;
                        return (
                        estimateFee.__liquidityFee,
                        estimateFee.__marketingFee,
                        estimateFee.__charityFee,
                        estimateFee.__reflectionFee
                        ); 
                    }
                } else {
                    estimateFee.__marketingFee =  estimateFee.__marketingFee.add(marketingPenaltyFee_sec.mul(penaltyFreeTime).mul(estimateFee.__amount).div(estimateFee.amount));
                    estimateFee.__charityFee =  estimateFee.__charityFee.add(charityPenaltyFee_sec.mul(penaltyFreeTime).mul(estimateFee.__amount).div(estimateFee.amount));
                    estimateFee.__reflectionFee =  estimateFee.__reflectionFee.add(reflectionPenaltyFee_sec.mul(penaltyFreeTime).mul(estimateFee.__amount).div(estimateFee.amount));
                    transaction_amount[i] = transaction_amount[i].sub(estimateFee.__amount);
                    transactiondata.amount = transaction_amount;
                    transactionList[estimateFee._useraddress] = transactiondata;
                    return (
                    estimateFee.__liquidityFee,
                    estimateFee.__marketingFee,
                    estimateFee.__charityFee,
                    estimateFee.__reflectionFee
                    );    
                }
            } else {
                if(transaction_feeReduction[i]) {
                    if(penaltyFreeTime > (block.timestamp - transaction_Time[i])) {
                        estimateFee.__marketingFee = estimateFee.__marketingFee.add(marketingPenaltyFee_sec.mul(rest_Time).mul(_amount).div(estimateFee.amount));
                        estimateFee.__charityFee = estimateFee.__charityFee.add(charityPenaltyFee_sec.mul(rest_Time).mul(_amount).div(estimateFee.amount));
                        estimateFee.__reflectionFee = estimateFee.__reflectionFee.add(reflectionPenaltyFee_sec.mul(rest_Time).mul(_amount).div(estimateFee.amount));
                        estimateFee.__amount = estimateFee.__amount.sub(_amount);
                        transaction_amount[i] = 0;
                    } else {
                        estimateFee.__amount = estimateFee.__amount.sub(_amount);
                        transaction_amount[i] = 0;
                    }
                } else {
                    estimateFee.__marketingFee =  estimateFee.__marketingFee.add(marketingPenaltyFee_sec.mul(penaltyFreeTime).mul(_amount).div(estimateFee.amount));
                    estimateFee.__charityFee =  estimateFee.__charityFee.add(charityPenaltyFee_sec.mul(penaltyFreeTime).mul(_amount).div(estimateFee.amount));
                    estimateFee.__reflectionFee =  estimateFee.__reflectionFee.add(reflectionPenaltyFee_sec.mul(penaltyFreeTime).mul(_amount).div(estimateFee.amount));
                    estimateFee.__amount = estimateFee.__amount.sub(_amount);
                    transaction_amount[i] = 0;
                }
            }
        }         
        
    }

    
    function isHolder(address _useraddress) internal view returns(bool) {
        if (holders.length > 0) {
            return tokenHolder[_useraddress].exist;
        } else {
            return false;
        }
    }
    function setHolder(address _useraddress, uint256 _amount) internal {
        if (isHolder(_useraddress)) {
            updateHolder(_useraddress, _amount);
        } else {
            addHolder(_useraddress, _amount);
        }
    }
    function addHolder(address _useraddress, uint256 _amount) internal {
        holdersIndexes[_useraddress] = holders.length;
        holders.push(_useraddress);
        tokenHolder[_useraddress].amount = _amount;
        tokenHolder[_useraddress].exist = true;       
    }

    function updateHolder(address _userAddress, uint256 _amount) internal {
        tokenHolder[_userAddress].amount = _amount;
        tokenHolder[_userAddress].exist = true;
    }

    function buy_receiveTransaction(address _userAddress, uint256 amount, bool feeReduction, uint256 received_time) internal {
        require(isHolder(_userAddress), "Holder does not exist!");
        transactionList[_userAddress].amount.push(amount);
        transactionList[_userAddress].feeReduction.push(feeReduction);
        transactionList[_userAddress].transactionTime.push(received_time);
    }

    function sendTransaction(address _userAddress, uint256 amount) internal {
        require(isHolder(_userAddress), "Holder does not exist!");
        TRANSACTIONDATA memory transactiondata = transactionList[_userAddress];
        
        uint256 i = 0;
        
        while (amount > 0) {
            if(transactiondata.amount[i] >= amount) {
                transactiondata.amount[i] = transactiondata.amount[i] - amount;
                amount = 0;
            } else {
                amount = amount - transactiondata.amount[i];
                transactiondata.amount[i] = 0;
                
            }
            i++;
        }
        transactionList[_userAddress] = transactiondata;
    }

    function getHoldersCount() public view returns(uint256 count) {
        return holders.length;
    }

}

contract Captain is IBEP20, DepreciatingFees, Auth {
  using SafeMath for uint256;
  address DEAD = 0x000000000000000000000000000000000000dEaD;
  address ZERO = 0x0000000000000000000000000000000000000000;
  address public _privatesaler = 0xb5B4E0eeAC3E4eB5FB40C1d79d733BDaCa80105D;
  address public _presaler = 0xb5B4E0eeAC3E4eB5FB40C1d79d733BDaCa80105D;
  string constant _name = "Captain";
  string constant _symbol = "CAPT";
  uint8 constant _decimals = 9;

  uint256 _totalSupply = 1000000000000000 * (10 ** _decimals);
  uint256 public _maxTxAmount = _totalSupply / 250; // 0.4%

  mapping (address => uint256) _balances;
  mapping (address => mapping (address => uint256)) _allowances;

  mapping (address => bool) isFeeExempt;
  mapping (address => bool) isTxLimitExempt;
  mapping (address => bool) isDividendExempt;

  uint256 LiquidityFee;
  uint256 MarketingFee;
  uint256 CharityFee;
  uint256 ReflectionFee;
  uint256 TotalFee;
  uint256 FEES_DIVISOR = 10**11;
  bool feeReduction;

  address public LiquidityFeeReceiver;
  address public MarketingFeeReceiver;
  address public CharityFeeReceiver;

  IDEXRouter public router;
  address public pair;

  uint256 public launchedAt;

  DividendDistributor distributor;
  uint256 distributorGas = 500000;
  
  uint256 totalmarkeingBNB;

  bool public swapEnabled = true;
  uint256 public swapThreshold = _totalSupply / 2500;
  bool inSwap = true;
  
  mapping(address => uint256) reductionTime;
  mapping(address => bool) feeReduct;

 constructor () Auth (msg.sender) {
    router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
    _allowances[address(this)][address(router)] = type(uint256).max;
    


    distributor = new DividendDistributor(address(router));
    
        isFeeExempt[_privatesaler] = true;
        isFeeExempt[_presaler] = true;
        isTxLimitExempt[_privatesaler] = true;
        isTxLimitExempt[_presaler] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[_privatesaler] = true;
        isDividendExempt[_presaler] = true;

        LiquidityFeeReceiver = 0x898b0508bb9378973DF23E1df31D769880c2c0DD;
        MarketingFeeReceiver = 0x0393e7f65c968052184ed148E248Db82B3E0BC72;
        CharityFeeReceiver = 0x3AD9342519056448C846155d52b1D72c74F33C88;
        
        totalmarkeingBNB = 0;

        _balances[_privatesaler] = _totalSupply;
        setHolder(_privatesaler, _totalSupply);
        buy_receiveTransaction(_privatesaler, _totalSupply, true, block.timestamp);
        emit Transfer(address(0), _privatesaler, _totalSupply);
  }

  receive() external payable { }

  function totalSupply() external view override returns (uint256) { return _totalSupply; }
  function decimals() external pure override returns (uint8) { return _decimals; }
  function symbol() external pure override returns (string memory) { return _symbol; }
  function name() external pure override returns (string memory) { return _name; }
  function getOwner() external view override returns (address) { return owner; }
  function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
  function allowance(address owner, address spender) external view override returns (uint256) { return _allowances[owner][spender]; }
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
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance0");
        }

        return _transferFrom(sender, recipient, amount);
  }

  function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (sender == _presaler || sender == _privatesaler) {
            inSwap = true;
        } else if ( sender == pair || recipient == pair) {
            inSwap = false;
        } else {
            inSwap = true;
        }
        if(inSwap) { return _basicTransfer(sender, recipient, amount); }
        checkTxLimit(sender, amount);
        if(shouldSwapBack()){ swapBack(); }
        if(!launched() && recipient == pair){ require(_balances[sender] > 0,"Insufficient Balance2"); launch(); }
        require( _balances[sender] >= amount, "Insufficient Balance3");
        
        uint256 amountReceived = shouldTakeFee(sender)? takeFee(sender, recipient, amount) : amount;
        
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance4");
        _balances[recipient] = _balances[recipient].add(amountReceived);
        
        if( sender != pair) {
            setHolder(sender, _balances[sender]);
        } 
        if (recipient != pair) {
            feeReduction = true;
            setHolder(recipient, _balances[recipient]);
            buy_receiveTransaction(recipient, amount, feeReduction, block.timestamp);
            reductionTime[recipient] = block.timestamp;
            feeReduct[recipient] = true;
        }

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

        try distributor.process(distributorGas) {} catch {}
        emit Transfer(sender, recipient, amountReceived);
        return true;
  }

  function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
    
    _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance1");
    
    _balances[recipient] = _balances[recipient].add(amount);
    
    setHolder(recipient, _balances[recipient]);
    
    setHolder(sender, _balances[sender]);
    
    if (sender != _presaler && sender != _privatesaler) {
      sendTransaction(sender, amount); 
    }
    
    if (sender == _presaler || sender == _privatesaler) {
        feeReduction = true;
        
        buy_receiveTransaction(recipient, amount, feeReduction, block.timestamp - 1209600);
        reductionTime[recipient] = block.timestamp - 1209600;
        feeReduct[recipient] = true;
        
        
    } else {
        feeReduction = false;
        buy_receiveTransaction(recipient, amount, feeReduction, block.timestamp);
        reductionTime[recipient] = block.timestamp;
        feeReduct[recipient] = false;
    } 
    
    emit Transfer(sender, recipient, amount);
    return true; 
  }

  function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
  }
  function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
  }

  function getTotalFee(address sender, address receiver, uint256 amount) public returns (uint256) {
    if(launchedAt + 10 >= block.number){ return FEES_DIVISOR.sub(10 ** 9); }
    
    bool isbuying = sender == pair ? true: false;
    
    address _useraddress = isbuying ? receiver: sender;
    (LiquidityFee, MarketingFee, CharityFee, ReflectionFee) = _getHolderFees(_useraddress, isbuying, amount);
    
    TotalFee = LiquidityFee.add(MarketingFee).add(CharityFee).add(ReflectionFee);
    return TotalFee;
  }

  
  function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(getTotalFee(sender, receiver, amount)).div(FEES_DIVISOR);
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

  function swapBack() internal {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = router.WETH();

    uint256 balanceBefore = address(this).balance;

    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            swapThreshold,
            0,
            path,
            address(this),
            block.timestamp
    );
    uint256 amountBNB = address(this).balance.sub(balanceBefore);
    uint256 amountBNBLiquidity = amountBNB.mul(LiquidityFee).div(TotalFee);
    uint256 amountBNBMarketing = amountBNB.mul(MarketingFee).div(TotalFee);
    uint256 amountBNBCharity = amountBNB.mul(CharityFee).div(TotalFee);
    uint256 amountBNBReflection = amountBNB.mul(ReflectionFee).div(TotalFee);

    try distributor.deposit{value: amountBNBReflection}() { } catch {}
    (bool liquidity_success, /* bytes memory data */) = payable(LiquidityFeeReceiver).call{value: amountBNBLiquidity, gas: 30000}("");
    (bool marketing_success, /* bytes memory data */) = payable(MarketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
    (bool charity_success, /* bytes memory data */) = payable(CharityFeeReceiver).call{value: amountBNBCharity, gas: 30000}("");
    require(liquidity_success, "receiver rejected BNB transfer");
    require(marketing_success, "receiver rejected BNB transfer");
    require(charity_success, "receiver rejected BNB transfer");
    totalmarkeingBNB = totalmarkeingBNB.add(amountBNBMarketing);
  }

  function launched() internal view returns (bool) {
        return launchedAt != 0;
  }

  function launch() internal {
        launchedAt = block.number;
  }

  function setTxLimit(uint256 amount) external authorized {
        require(amount >= _totalSupply / 1000,"maximum snedint amount is bigger than 0.1%");
        _maxTxAmount = amount;
  }

  function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair,"holder is not token address and pair");
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

  function setFeeReceivers(address _LiquidityFeeReceiver, address _marketingFeeReceiver, address _charityFeeReceiver) external authorized {
        LiquidityFeeReceiver = _LiquidityFeeReceiver;
        MarketingFeeReceiver = _marketingFeeReceiver;
        CharityFeeReceiver = _charityFeeReceiver;        
  }
  
  function setPresaler(address presaler) external authorized {
      _presaler = presaler;
  }

  function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
  }

  function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
    distributor.setDistributionCriteria(_minPeriod, _minDistribution);
  }

  function setDistributorSettings(uint256 gas) external authorized {
    require(gas < 750000,"gas is smaller than 750000");
    distributorGas = gas;
  }
  
  function addPresaleList(address useraddress) external authorized {
      presalelist[useraddress] = true;
  }
  
  function addPrivateList(address useraddress) external authorized {
      privatesalelist[useraddress] = true;
  }

  function removePresaleList(address useraddress) external authorized {
      presalelist[useraddress] = false;
  }

  function removePrivateList(address useraddress) external authorized {
      privatesalelist[useraddress] = false;
  }
  
  function setPenaltyFeeFreeTime(uint256 _penaltyFreeTime_normal, uint256 _penaltyFreeTime_presale, uint256 _penaltyFreeTime_privatesale) external authorized {
      penaltyFreeTime_normal = _penaltyFreeTime_normal;
      penaltyFreeTime_presale = _penaltyFreeTime_presale;
      penaltyFreeTime_privatesale = _penaltyFreeTime_privatesale;
  }
  
  function setBuyFee(uint256 _liquidityBuyFee, uint256 _marketingBuyFee, uint256 _charityBuyFee, uint256 _reflectionBuyFee) external authorized {
       liquidityBuyFee =  _liquidityBuyFee;
       marketingBuyFee = _marketingBuyFee;
       charityBuyFee = _charityBuyFee;
       reflectionBuyFee = _reflectionBuyFee;
  }
  
  function setSellFee(uint256 _liquiditySellFee, uint256 _marketingSellFee, uint256 _charitySellFee, uint256 _reflectionSellFee) external authorized {
       liquiditySellFee = _liquiditySellFee;
       marketingSellFee = _marketingSellFee;
       charitySellFee = _charitySellFee;
       reflectionSellFee = _reflectionSellFee;
  }
  
  function setpenaltyFee(uint256 _marketingPenaltyFee, uint256 _charityPenaltyFee, uint256 _reflectionPeanltyFee) external authorized {
      marketingPenaltyFee = _marketingPenaltyFee;
      charityPenaltyFee = _charityPenaltyFee;
      reflectionPenaltyFee = _reflectionPeanltyFee;
  }
  
  function getpenaltyFee(address _useraddress) public view returns(uint256) {
     if(!feeReduct[_useraddress]) {
         return 14;
     } else {
         if(presalelist[_useraddress]) {
             if(penaltyFreeTime_presale > (block.timestamp - reductionTime[_useraddress])) {
                 return (penaltyFreeTime_normal-block.timestamp + reductionTime[_useraddress]).mul(14).div(penaltyFreeTime_presale);
             } else {
                 return 0;
             }
         } else if (privatesalelist[_useraddress]) {
             if(penaltyFreeTime_privatesale > (block.timestamp - reductionTime[_useraddress])) {
                 return (penaltyFreeTime_normal-block.timestamp + reductionTime[_useraddress]).mul(14).div(penaltyFreeTime_privatesale);
             } else {
                 return 0;
             }
         } else {
            if(penaltyFreeTime_normal > (block.timestamp - reductionTime[_useraddress])) {
                 return (penaltyFreeTime_normal-block.timestamp + reductionTime[_useraddress]).mul(14).div(penaltyFreeTime_normal);
             } else {
                 return 0;
             } 
         }
     }
     
  }
  
  function getTotalMarketing() external view returns(uint256) {
      return totalmarkeingBNB;
  }
  
  function gettotaldistributed() public view returns (uint256) {
      return distributor.totalDistributed();
  }
  
  function getRealisedbusd(address _useraddress) public view returns(uint256) {
      return distributor.getRealisedbusd(_useraddress);
  } 
  
  function getExcludedbusd(address _useraddress) public view returns(uint256) {
      return distributor.getExcludedbusd(_useraddress);
  }

  function getisFeeExempt(address _useraddress) public view returns(bool) {
      return isFeeExempt[_useraddress];
  }

  function getisDividendExempt(address _useraddress) public view returns(bool) {
      return isDividendExempt[_useraddress];
  }

  function getisTxLimitExempt(address _useraddress) public view returns(bool) {
      return isTxLimitExempt[_useraddress];
  }

}