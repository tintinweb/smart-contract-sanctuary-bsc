/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;


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
        // Solidity only autoLTCally asserts when dividing by 0
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

/**
 * Allows for contract ownership along with multi-address authorization
 */
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

    IBEP20 Reward = IBEP20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); 
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

    //SETMEUP, change this to 1 hour instead of 10mins
    uint256 public minPeriod = 45 minutes;
    uint256 public minDistribution = 1 * (10 ** 18);

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
       /* router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);*/
            
             router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
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
        uint256 balanceBefore = Reward.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(Reward);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = Reward.balanceOf(address(this)).sub(balanceBefore);

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
            Reward.transfer(shareholder, amount);
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
}

contract Abaddon is IBEP20, Auth {
    using SafeMath for uint256;
    
    bool public isLaunch = false;
    uint256 public lastDistribution;
    uint256 oneMounth = 60*60*24*30;
    uint256 public mounthNumber;

    address Reward = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Abaddon";
    string constant _symbol = "ABAD";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 2 * 10**9 * (10 ** _decimals);
    uint256 public _maxTxAmount = _totalSupply * 100 / 100;

    
    uint256 public _maxWalletToken = ( _totalSupply * 100 ) / 100;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;

    uint256 liquidityFee    = 3;
    uint256 marketingFee    = 2;
    uint256 public totalFee = 5;
    uint256 feeDenominator  = 100;

    address public autoLiquidityReceiver;

    address public team              = 0x0C73AbEf8D71cb2CAca0257437607BAF3dA7D6cb;
    address public enterpriseReserve = 0xa0BEa72af234D78809a00895A5778a0393b0c0E4;
    address public presale           = 0x237ADC13a5Ac940f0a95189471060f120AEE8533;
    address public liquidity         = 0xF401BE47e56Ec407ae22B31C257edb8d384cD0Fe;
    address public rewardEcosystem   = 0x7bf0a0a3Fe39A3EfAE729e7eFA41bC1CC5543623;
    address public marketing         = 0xa4b4c19EB08B8a53C353f9022C10f4e148867296;
    address public partnerShip       = 0xc72060b1F6011074954Fe72981c0B2642dFef56d;
    address public airdropAndGiveaway= 0x68efEa00e3e96DDAE92c7314595D0Fb56744B255;

   

    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;

    DividendDistributor distributor;
    uint256 distributorGas = 500000;

    // Cooldown & timer functionality
    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 45;
    mapping (address => uint) private cooldownTimer;
    uint256 reflectionFee   = 0;
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 10 / 10000; // 0.01% of supply
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = uint256(-1);

        distributor = new DividendDistributor(address(router));

        isFeeExempt[msg.sender]         = true;
        isFeeExempt[team]               = true;
        isFeeExempt[enterpriseReserve]  = true;
        isFeeExempt[presale]            = true;
        isFeeExempt[liquidity]          = true;
        isFeeExempt[rewardEcosystem]    = true;
        isFeeExempt[marketing]          = true;
        isFeeExempt[partnerShip]        = true;
        isFeeExempt[airdropAndGiveaway] = true;

        isTxLimitExempt[msg.sender]         = true;
        isTxLimitExempt[team]               = true;
        isTxLimitExempt[enterpriseReserve]  = true;
        isTxLimitExempt[presale]            = true;
        isTxLimitExempt[liquidity]          = true;
        isTxLimitExempt[rewardEcosystem]    = true;
        isTxLimitExempt[marketing]          = true;
        isTxLimitExempt[partnerShip]        = true;
        isTxLimitExempt[airdropAndGiveaway] = true;

        // No timelock for these people
        isTimelockExempt[msg.sender]         = true;
        isTimelockExempt[DEAD]               = true;
        isTimelockExempt[address(this)]      = true;
        isTimelockExempt[team]               = true;
        isTimelockExempt[enterpriseReserve]  = true;
        isTimelockExempt[presale]            = true;
        isTimelockExempt[liquidity]          = true;
        isTimelockExempt[rewardEcosystem]    = true;
        isTimelockExempt[marketing]          = true;
        isTimelockExempt[partnerShip]        = true;
        isTimelockExempt[airdropAndGiveaway] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        autoLiquidityReceiver = DEAD;
        marketing = msg.sender;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    
    function checkTimeToDistribute() public returns (bool) {
        if(isLaunch==true && (lastDistribution.add(oneMounth))<=block.timestamp){
            mounthNumber++;
            return true;
        }
        else{
            return false;
        }
    }
    
    function distribute() internal {
        if(checkTimeToDistribute()==true){
            // 1
            if(launchedAt.add(1*oneMounth)<=block.timestamp && mounthNumber==1){
                _basicTransfer(address(this), partnerShip, 16666666*(10**_decimals));
                _basicTransfer(address(this), airdropAndGiveaway, 16666666*(10**_decimals));
            }
            // 2
            if(launchedAt.add(2*oneMounth)<=block.timestamp && mounthNumber==2){
                _basicTransfer(address(this), marketing, 16666666*(10**_decimals));
                _basicTransfer(address(this), partnerShip, 16666666*(10**_decimals));
                _basicTransfer(address(this), airdropAndGiveaway, 16666666*(10**_decimals));
            }
            // 3
            if(launchedAt.add(3*oneMounth)<=block.timestamp && mounthNumber==3){
                _basicTransfer(address(this), team, 22222222*(10**_decimals));
                _basicTransfer(address(this), marketing, 16666666*(10**_decimals));
                _basicTransfer(address(this), partnerShip, 16666666*(10**_decimals));
                _basicTransfer(address(this), airdropAndGiveaway, 16666666*(10**_decimals));
            }
            // 4
            if(launchedAt.add(4*oneMounth)<=block.timestamp && mounthNumber==4){
                _basicTransfer(address(this), team, 22222222*(10**_decimals));
                _basicTransfer(address(this), marketing, 16666666*(10**_decimals));
                _basicTransfer(address(this), partnerShip, 16666666*(10**_decimals));
                _basicTransfer(address(this), airdropAndGiveaway, 16666666*(10**_decimals));

            }
            // 5
            if(launchedAt.add(5*oneMounth)<=block.timestamp && mounthNumber==5){
                _basicTransfer(address(this), team, 22222222*(10**_decimals));
                _basicTransfer(address(this), marketing, 16666666*(10**_decimals));
                _basicTransfer(address(this), partnerShip, 16666666*(10**_decimals));
                _basicTransfer(address(this), airdropAndGiveaway, 16666666*(10**_decimals));
            }
            // 6
            if(launchedAt.add(6*oneMounth)<=block.timestamp && mounthNumber==6){
                _basicTransfer(address(this), team, 22222222*(10**_decimals));
                _basicTransfer(address(this), enterpriseReserve, 10000000*(10**_decimals));
                _basicTransfer(address(this), marketing, 16666666*(10**_decimals));
            }
            // 7
            if(launchedAt.add(7*oneMounth)<=block.timestamp && mounthNumber==7){
                _basicTransfer(address(this), team, 22222222*(10**_decimals));
                _basicTransfer(address(this), enterpriseReserve, 10000000*(10**_decimals));
                 _basicTransfer(address(this), marketing, 16666666*(10**_decimals));
            }
            // 8
            if(launchedAt.add(8*oneMounth)<=block.timestamp && mounthNumber==8){
                _basicTransfer(address(this), team, 22222222*(10**_decimals));
                _basicTransfer(address(this), enterpriseReserve, 10000000*(10**_decimals));
                _basicTransfer(address(this), marketing, 16666666*(10**_decimals));
            }
            // 9
            if(launchedAt.add(9*oneMounth)<=block.timestamp && mounthNumber==9){
                _basicTransfer(address(this), team, 22222222*(10**_decimals));
                _basicTransfer(address(this), enterpriseReserve, 10000000*(10**_decimals));
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
                _basicTransfer(address(this), marketing, 16666666*(10**_decimals));
            }
            // 10
            if(launchedAt.add(10*oneMounth)<=block.timestamp && mounthNumber==10){
                _basicTransfer(address(this), team, 22222222*(10**_decimals));
                _basicTransfer(address(this), enterpriseReserve, 10000000*(10**_decimals));
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
                _basicTransfer(address(this), marketing, 16666666*(10**_decimals));
            }
            // 11
            if(launchedAt.add(11*oneMounth)<=block.timestamp && mounthNumber==11){
                _basicTransfer(address(this), team, 22222222*(10**_decimals));
                _basicTransfer(address(this), enterpriseReserve, 10000000*(10**_decimals));
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
                _basicTransfer(address(this), marketing, 16666666*(10**_decimals));
            }
            // 12
            if(launchedAt.add(12*oneMounth)<=block.timestamp && mounthNumber==12){
                _basicTransfer(address(this), enterpriseReserve, 10000000*(10**_decimals));
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
                _basicTransfer(address(this), marketing, 16666666*(10**_decimals));
            }
            // 13
            if(launchedAt.add(13*oneMounth)<=block.timestamp && mounthNumber==13){
                _basicTransfer(address(this), enterpriseReserve, 10000000*(10**_decimals));
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
                _basicTransfer(address(this), marketing, 16666666*(10**_decimals));
            }
            // 14
            if(launchedAt.add(14*oneMounth)<=block.timestamp && mounthNumber==14){
                _basicTransfer(address(this), enterpriseReserve, 10000000*(10**_decimals));
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            }
            // 15
            if(launchedAt.add(15*oneMounth)<=block.timestamp && mounthNumber==15){
                _basicTransfer(address(this), enterpriseReserve, 10000000*(10**_decimals));
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            }
            // 16
            if(launchedAt.add(16*oneMounth)<=block.timestamp && mounthNumber==16){
                _basicTransfer(address(this), enterpriseReserve, 10000000*(10**_decimals));
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            }
            // 17
            if(launchedAt.add(17*oneMounth)<=block.timestamp && mounthNumber==17){
                _basicTransfer(address(this), enterpriseReserve, 10000000*(10**_decimals));
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            }
            // 18
            if(launchedAt.add(18*oneMounth)<=block.timestamp && mounthNumber==18){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            }
            // 19
            if(launchedAt.add(19*oneMounth)<=block.timestamp && mounthNumber==19){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            }
            // 20
            if(launchedAt.add(20*oneMounth)<=block.timestamp && mounthNumber==20){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            }
            // 21
            if(launchedAt.add(21*oneMounth)<=block.timestamp && mounthNumber==21){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            }
            // 22
            if(launchedAt.add(22*oneMounth)<=block.timestamp && mounthNumber==22){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            }
            // 23
            if(launchedAt.add(23*oneMounth)<=block.timestamp && mounthNumber==23){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            }
            // 24
            if(launchedAt.add(24*oneMounth)<=block.timestamp && mounthNumber==24){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            }
            // 25
            if(launchedAt.add(25*oneMounth)<=block.timestamp && mounthNumber==25){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            } 
            // 26
            if(launchedAt.add(26*oneMounth)<=block.timestamp && mounthNumber==26){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            } 
            // 27
            if(launchedAt.add(27*oneMounth)<=block.timestamp && mounthNumber==27){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            } 
            // 28
            if(launchedAt.add(28*oneMounth)<=block.timestamp && mounthNumber==28){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            } 
            // 29
            if(launchedAt.add(29*oneMounth)<=block.timestamp && mounthNumber==29){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            } 
            // 30
            if(launchedAt.add(30*oneMounth)<=block.timestamp && mounthNumber==30){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            } 
            // 31
            if(launchedAt.add(31*oneMounth)<=block.timestamp && mounthNumber==31){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            } 
            // 32
            if(launchedAt.add(32*oneMounth)<=block.timestamp && mounthNumber==32){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            } 
            // 33
            if(launchedAt.add(33*oneMounth)<=block.timestamp && mounthNumber==33){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            } 
            // 34
            if(launchedAt.add(34*oneMounth)<=block.timestamp && mounthNumber==34){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            } 
            // 35
            if(launchedAt.add(35*oneMounth)<=block.timestamp && mounthNumber==35){
                _basicTransfer(address(this), rewardEcosystem, 33333333*(10**_decimals));
            } 
           
            lastDistribution=block.timestamp;
        }
    }

    function launch()external authorized{
        require(isLaunch != true,"Already launched");
        isLaunch=true;
        launchedAt=block.timestamp;
        mounthNumber=0;
    }

    function updateReward(address newReward)external authorized{
        require(newReward != Reward,"Current Reward");
        Reward=newReward;
    }

    function updateRouter(address newRouter)external authorized{
        require(router!=IDEXRouter(newRouter),"Current Router");
        router=IDEXRouter(newRouter);
    }

    function burn (uint256 amount)external{
        _balances[msg.sender] = _balances[msg.sender].sub(amount*(10**_decimals), "Insufficient Balance");
        _balances[DEAD] = _balances[DEAD].add(amount*(10**_decimals));
        emit Transfer(msg.sender, DEAD, amount*(10**_decimals));
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, uint256(-1));
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {

        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    //settting the maximum permitted wallet holding (percent of total supply)
     function setMaxWalletPercent(uint256 maxWallPercent) external authorized() {
        _maxWalletToken = (_totalSupply * maxWallPercent ) / 100;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        distribute();
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        // max wallet code
        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != marketing && recipient != autoLiquidityReceiver){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}
        

        
        // cooldown timer, so a bot doesnt do quick trades! 1min gap between 2 trades.
        if (sender == pair &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for cooldown between buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }


        // Checks max transaction limit
        checkTxLimit(sender, amount);

        // Liquidity, Maintained at 25%
        if(shouldSwapBack()){ swapBack(); }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, _balances[recipient]) {} catch {} 
        }

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

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);

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

    function clearStuckBalance(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(marketing).transfer(amountBNB * amountPercentage / 100);
    }

    // enable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public authorized {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }



    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
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

        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        (bool tmpSuccess,) = payable(marketing).call{value: amountBNBMarketing, gas: 30000}("");
        
        // only to supress warning msg
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }


    function setTxLimit(uint256 amount) external authorized {
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

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsTimelockExempt(address holder, bool exempt) external authorized {
        isTimelockExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        totalFee = _liquidityFee.add(marketingFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/4);
    }
    
    function setWalletTeam(address _team) external authorized {
        require(_team!= team,"Current Team Wallet");
        team = _team;
    }

    function setWalletEnterpriseReserve(address _enterpriseReserve) external authorized {
        require(_enterpriseReserve!= enterpriseReserve,"Current EnterpriseReserve Wallet");
        enterpriseReserve = _enterpriseReserve;
    }

    function setWalletLiquidity(address _liquidity) external authorized {
        require(_liquidity!= liquidity,"Current EnterpriseReserve Wallet");
        liquidity = _liquidity;
    }

    function setWalletPresale(address _presale) external authorized {
        require(_presale!= presale,"Current Presale Wallet");
        presale = _presale;
    }

    function setWalletRewardEcosystem(address _RewardEcoSystem) external authorized {
        require(_RewardEcoSystem!= rewardEcosystem,"Current Reward Ecosystem Wallet");
        rewardEcosystem = _RewardEcoSystem;
    }

    function setWalletMarketing(address _marketing) external authorized {
        require(_marketing!= marketing,"Current Marketing Wallet");
        marketing = _marketing;
    }

    function setWalletPartnerShip(address _partnerShip) external authorized {
        require(_partnerShip!= partnerShip,"Current PartnerShip Wallet");
        partnerShip = _partnerShip;
    }

    function setWalletAirdropAndGiveAway(address _airdropAndGiveAway) external authorized {
        require(_airdropAndGiveAway!= airdropAndGiveaway,"Current AirdropAndGiveAway Wallet");
        airdropAndGiveaway = _airdropAndGiveAway;
    }

    function setWalletPoolLiquidity(address _autoLiquidityReceiver) external authorized {
        require(_autoLiquidityReceiver!= autoLiquidityReceiver,"Current Liquidity Receiver");
        autoLiquidityReceiver = _autoLiquidityReceiver;
    }
    

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
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

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function airdrop(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

        uint256 SCCC = 0;

        require(addresses.length == tokens.length,"Mismatch between Address and token count");

        for(uint i=0; i < addresses.length; i++){
            SCCC = SCCC + tokens[i];
        }

        require(balanceOf(from) >= SCCC, "Not enough tokens to airdrop");

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
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}