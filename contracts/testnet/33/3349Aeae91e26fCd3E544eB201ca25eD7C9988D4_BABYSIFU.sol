/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

/*
    Website: https://sifuinu.io
    Telegram: https://t.me/sifuinio_official
    Donate: 0xEcC075cB2926564568F0b7C9a98ac0DC496817D1
    Discord: https://discord.gg/ep29yETXFC
    Contract Audited By: https://www.rugfreecoins.com/
    Contract Presale will be in https://www.pinksale.finance/#/.
    Contract Version: 2.02
    Contract Supply: 250,000,000,000 /1 Quad
    Contract Tokenomics:
    5% WBNB or any token Rewards, we can update based on community request.
    2% Liquidity.
    1% Scholarship/Charity.
    2% Marketing.
    1% Development.
    1% Burn Fee
    12% Total.
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

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

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
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
    //address public RWDSelectionMainNet = 0x16dae78f8b13fc7f86dfd8711e768e37d10a674f; //MainNet Cake 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82 Address // WBNB Peg 0x2859e4544C4bB03966803b044A93563Bd2D0DD4D
    //address public WBNBSelectionMainNet = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //MainNet WBNB Address
    address RWDSelectionTestnet = 0xE918B9DD95046B9ce8704E4f27a922310fB8b7d7; //0x55E0C4Cb24c146BEDF4AaCec69A1B492bE2cd309; //BUSD Testnet Address, CAKE wont work on Pancakeswap Testnet.
    address WBNBSelectionTestnet = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; //DAI Testnet Address, cant get WNBN address to compile.

    IBEP20 RWRD = IBEP20(RWDSelectionTestnet); //CAKE Mainnet Address
    address WBNB = WBNBSelectionTestnet;   //WBNB Mainnet Address
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

    uint256 public minPeriod = 45 * 60;
    uint256 public minDistribution = 1 * (10 ** 18);
    address public currentRouter;
    address public PancakerouterDev = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; //PancakeRouterDev
    address public PancakerouterProd = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //PancakerouterProd PancakeSwap Router According to https://docs.pancakeswap.finance/code/smart-contracts/pancakeswap-exchange/router-v2
    address public PancakeRouterDev2 = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //PancakeRouterDev2 PancakeSwap test according to https://bsc.kiemtienonline360.com/
    
    
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
    currentRouter = PancakeRouterDev2; //Define Current Router, I attempted to created a function to change this on the contract.
    
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(currentRouter); //MainNet Change to 0x10ED43C718714eb63d5aA57B78B54704E256024E  Testnet Option 1: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 PancakeSwapRouterDev2 = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
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
        uint256 balanceBefore = RWRD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(RWRD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = RWRD.balanceOf(address(this)).sub(balanceBefore);

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

    function updateWbnbandCakeAddress(address rWbnb, address rCake) external {
        WBNB = rWbnb;
        RWRD = IBEP20(rCake);
        //RWDSelectionMainNet = rCake; //Added to Update Rewards from current.
        //WBNBSelectionMainNet = rWbnb; //Added to Update Rewards from current.
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
            RWRD.transfer(shareholder, amount);
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

contract BABYSIFU is IBEP20, Auth {
    using SafeMath for uint256;
    address public CAKE = 0x55E0C4Cb24c146BEDF4AaCec69A1B492bE2cd309; //BUSD Testnet Address, CAKE wont work on Pancakeswap Testnet.
//CAKE Address
    address public WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;//0x2859e4544C4bB03966803b044A93563Bd2D0DD4D; //WBNB Pegged Address //testnet0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    address SCHOLARSHIP = 0x558B624De1d61379E0A131C7a9C6F6D9DcC14abE; //Scholarship Address
    address MARKETING = 0x4c0Eb12198d62b13Cad3E93b13Dc9ab99A02812B; // Marketing Wallet
    address DEV = 0x4816fEC583401c2117e924dC95BF21d37819FbD0; // Development Wallet
    address developerFeeReceiver2 = 0xC32F4a61231A9F461eC841813408e8C11bD7820A;//dev second wallet damsel
    address public nftReward = 0xf7f9E16A5fcF53C11c51BfEE1fc1667DeA03e174;
    address public cherryBombWallet = 0xD7fb7557CCf7DCC70f1CE3f4843782D9b11d1fCb;
        
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address LPR = 0x063f608bD5eF234F937BAb2B78218A939589CA3E;
    address PancakerouterDev = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; //PancakeRouterDev
    address PancakerouterProd = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //PancakerouterProd
    address PancakeRouterDev2 = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //PancakeRouterDev2
    address PINKSALE = 0xA188958345E5927E0642E5F31362b4E4F5e064A2; // PINKSALE.FINANCE  

    uint256 public jackpotWinnerPercent = 50;
    uint256 public jackpotRewardPercent = 25;
    uint256 public jackpotPercent = 25;
    /*
    staking start
    this is a module for the staking
    */
    uint[] public lockedInvestment;
    uint256 _investmentCount; //counting the number of time investment occur
    uint256 investmentPlan = 3;  //calculated In Date
    uint256 interestRate = 1; // 1% of the token supply

    function updateJackpotPercentage(uint256 _jackpotWinnerPercent,uint256 _jackpotRewardPercent, uint256 _jackpotPercent) public onlyOwner{
        jackpotWinnerPercent = _jackpotWinnerPercent;
        jackpotRewardPercent = _jackpotRewardPercent;
        jackpotPercent = _jackpotPercent;
    }
    function getInvestmentPlan() public view returns (uint256) {     
        return investmentPlan;
    }
    function getInterestRate() public view returns (uint256) {     
        return interestRate;
    }
    
    struct Invest{
    uint256 id;
    address owner;
    uint256 amountTokenInvested;
    uint256 interestRate;
    uint256 investDate;
    uint256 releaseDate;
    uint256 totalTokenEarned;
    bool releaseStatus;
    bool lock;
    }

    mapping (uint256=>address) public wallets;
    mapping (uint => Invest) public isInvested;
    Invest[] public allInvestment;
   // Invest[] public invests;
    event LogTokenBulkSent(address token, address from, uint256 total);
    event LogTokenApproval(address token, uint256 total);

    function setInvestmentPlan(uint256 _investmentPlan, uint256 _interestRate) public {
        investmentPlan = _investmentPlan;
        interestRate = _interestRate;
    }

    function getReleaseDate(uint256 time) public view returns (uint256) {
        uint256 newTimestamp = block.timestamp + (60 * time);
        return newTimestamp;
    }
   
    function calculateProfit(uint256 amount, uint256 _interestRate) public pure returns (uint256){
        return amount + ((_interestRate *  amount) / 100);
    }
    
    function claimInvestment(uint256 _id) public {
        address investor = msg.sender;
        uint256 ctime = block.timestamp;
        Invest memory invests = isInvested[_id];
        // uint id = invests.id;
        // bool status = invests.releaseStatus;
        uint releaseDate = invests.releaseDate;
        uint256 totalEarned = invests.totalTokenEarned;
        bool cstatus = invests.releaseStatus;
        require(cstatus==false, "You have already claim this investment.");
        require(ctime >= releaseDate, "you can't claim investment now, until investment period end.");
        bool rstatus = updateInvestment(_id, true);
        require(rstatus==true,"unable to claim investment");
        //invests.releaseStatus = true;
        _basicTransfer(address(this),investor,totalEarned);
       
        //releaseToken(investor, totalEarned);
        emit inventReleased(address(this), investor, totalEarned, ctime);
    }

    function investment(uint256 amount) public {

    address investor = msg.sender;
    require(investmentPlan >= 1, "You can't invest now. No investment plan available yet");
    require(interestRate >= 1, "You can't invest now. No interestRate is available for the investment plan");

    uint256 investedTime = block.timestamp;
    uint256 endTime = getReleaseDate(investmentPlan);
    uint totalTokenToEarned = calculateProfit(amount, interestRate);
    bool releaseStatus = false;
    allInvestment.push(Invest(_investmentCount, investor, amount, interestRate, investedTime, endTime, totalTokenToEarned, releaseStatus,false ));
    isInvested[_investmentCount] = Invest(_investmentCount, investor, amount, interestRate, investedTime, endTime, totalTokenToEarned, releaseStatus, false );
    
    _transferFrom(investor,address(this),amount);
    wallets[_investmentCount] = msg.sender;
    _investmentCount++;
    emit investmentReport(investor, amount, investmentPlan, interestRate, investedTime, endTime);

    }

    function updateInvestment(uint _id, bool _releaseStatus) public returns(bool){
        Invest storage stakerInvestment = isInvested[_id];
        stakerInvestment.releaseStatus = _releaseStatus; 
        allInvestment[_id].releaseStatus = _releaseStatus;
        return true;
    }

    function getAllInvestmentRecord() public view returns(Invest[] memory){
        return allInvestment;
    }
   
    function lockStakerInvestment(uint _id, bool _lockStatus) public {
        Invest storage stakerInvestment = isInvested[_id];
        stakerInvestment.lock = _lockStatus; 
        allInvestment[_id].lock = _lockStatus;
        lockedInvestment.push(_id);
    }
    //staking ends
    struct JACKPOT{
        uint id;
        string name;
        uint minStake;
        uint cherryBombMax;
        uint duration;
        uint startTime;
        uint endTime;
        address winner;
        bool status;
        uint dateTime;
    }

    uint256 public jackId = 0;

    JACKPOT[] public jackPots;

    mapping(uint256=> uint256) public jackpotBalances;

    struct jackpotStakers{
    uint id;
    uint jackpotId;
    uint amountStaked;
    address staker;
    bool win;
    uint timeStaked;
    }
    uint256 public jackpotTimer = 2;
    uint256 public minStake = 100000000000000;
    uint256 public cherryBombMax = 1000000000000000;
    uint256 public jackpotMaxBalance = 10000000000000000;
    uint256 public startingJackpot = 1000000000000000;
    uint256 public counter = 0;
    uint256 rewardYieldDenominator = 1000000;
    bool autocherrybomb = true;
    jackpotStakers[] public allStakers;

    //mapping(uint256=>jackpotStakers[]) stakerAddresses;
    mapping(uint256=>mapping(address=>uint256)) private stakeBalances;
    mapping (uint256 => mapping (uint256 => jackpotStakers)) internal stakerAddresses;
    uint256 public totalStakers = 0;
    //mapping (uint256 => uint256) public totalJackpots;
    event jackpotStaked(uint jid, uint amount, address staker, uint timeStaked);


    //check how much token is in lp
    function getPercentageOfToken(uint _amount, uint _jid) public view returns(uint){
        return  ((_amount * rewardYieldDenominator) / jackpotBalances[_jid]) ;
    }

    function getShareAmount(uint _amount, uint _jid, uint mybalance) private view returns(uint){
    uint256 Percent = getPercentageOfToken(mybalance,_jid);
    uint maxAmount = Percent * _amount;
    return maxAmount / rewardYieldDenominator;

    }

    function distributeBNBShare(uint256 _dAmount, uint256 _jid) public{
        
         uint256 holderCollected = 0;
         //uint256 totalAmount = 0;
        if(_dAmount > 0){
            for(uint256 i=0; i < totalStakers; i++){
                address addr   = stakerAddresses[_jid][i].staker;
                uint256 _balance = stakeBalances[_jid][addr];
            uint256 shareAmount = getShareAmount(_dAmount, _jid, _balance);
            //_basicTransfer(address(this),addr,shareAmount);
            (bool tmpSuccess,) = payable(addr).call{value: shareAmount, gas: 3000}("");
            tmpSuccess;
            //_dAmount = _dAmount.sub(shareAmount);
            holderCollected++;
            emit logDistribution (addr, shareAmount);
            //totalAmount = totalAmount + _balance;
                
            }
        
        }
    }

    function updateJackpotSettings(uint256 _timer, uint _minStake, uint _cherryBombMax, uint _startingJackpot, uint _jackpotMaxBalance, bool _autocherrybomb) public onlyOwner{
    jackpotTimer = _timer;
    minStake = _minStake;
    cherryBombMax = _cherryBombMax;
    jackpotMaxBalance = _jackpotMaxBalance;
    startingJackpot = _startingJackpot;
    autocherrybomb = _autocherrybomb;
    }

    function stakeJackpot() external payable {
        uint256 _jid = jackId;
        uint256 timestamp = block.timestamp;
        uint256 amount = msg.value;
        address staker = msg.sender;
        
        require(amount >= minStake && amount <= jackpotMaxBalance, "Min. stake is 0.1BNB and max. stake is 100BNB");
        //uint256 _jackpotPoolAmount = jackpotBalances[jackId];
        
        uint256 _jackpotPoolAmount = jackpotBalances[jackId];
        
        if(_jackpotPoolAmount >= cherryBombMax && autocherrybomb == true){
            buybackJackpot(_jackpotPoolAmount);
        }
        else{
        stakeBalances[_jid][staker] = stakeBalances[_jid][staker] + amount;
        JACKPOT storage jackpot = jackPots[_jid];
        require(jackpot.endTime > timestamp || jackpot.status==false, 'This jackpot has ended!');
        jackpot.startTime = timestamp;
        jackpot.endTime = timestamp + (60 * jackpotTimer);
        uint256 newBalance = jackpotBalances[_jid].add(amount);
        jackpotBalances[_jid] = newBalance;
        stakerAddresses[_jid][totalStakers]= jackpotStakers(counter, _jid, amount, staker, false, timestamp);
        allStakers.push(jackpotStakers(counter, _jid, amount, staker, false, timestamp));
        counter++;
        totalStakers++;
        emit jackpotStaked(_jid, amount, staker, timestamp);

        }
        
    }
    function buybackJackpot(uint256 _jackpotPoolAmount) public payable{
        
            uint256 burnPot = (jackpotWinnerPercent * _jackpotPoolAmount) / 100;        
            uint256 holdersReward = (jackpotRewardPercent * _jackpotPoolAmount) / 100;
            uint256 jpt = (jackpotPercent * _jackpotPoolAmount) / 100;
            jackpotBalances[jackId] = jpt;
           (bool tmpSuccess,) = payable(cherryBombWallet).call{value: burnPot}("");
           tmpSuccess;
        //   emit logDistribution (cherryBombWallet, holdersReward);
           distributeBNBShare(holdersReward, jackId);
        
        
    }

    function updateJackpot() public {
        uint256 _currentTime = block.timestamp;
        uint256 _jid = jackId;
        JACKPOT storage jackpot = jackPots[_jid];
        bool _jStatus = jackpot.status;
        uint _jEndTime = jackpot.endTime;
        address winnerAddress = allStakers[allStakers.length-1].staker;
        require(_jStatus==false, "This Jackpot round already finished");
        require(_jEndTime < _currentTime || _jEndTime > 0,"Jackpot still running!");

        jackpot.status = true;
        jackpot.winner = winnerAddress;
        uint256 jackpotPoolAmount = jackpotBalances[_jid];
        require(jackpotPoolAmount > startingJackpot,"Winning can not be claimed yet");
        uint256 winnerPercent = (jackpotWinnerPercent * jackpotPoolAmount) / 100;
        uint256 shareHolderPercent = (jackpotRewardPercent * jackpotPoolAmount) / 100;
        uint256 jackpotRestartPercent = (jackpotPercent * jackpotPoolAmount) / 100;
        distributeBNBShare(shareHolderPercent, _jid);
        (bool tmpSuccess,) = payable(winnerAddress).call{value: winnerPercent, gas: 30000}("");
        //create new jackpot;
        totalStakers = 0;
        jackId = _jid + 1;
        jackpotBalances[jackId] = jackpotRestartPercent;
        
       // uint256 _endtime = _currentTime + (60 * 5);
        string memory _jackpotName = string.concat('Jackpot Round ', uint2str(jackId)) ;
        address _winner = address(0x0);
        jackPots.push(JACKPOT(jackId, _jackpotName, minStake, cherryBombMax, jackpotTimer, 0, 0,_winner,false,_currentTime));
        // only to supress warning msg
        tmpSuccess = false;

    }
    function createJackopt(
        string memory _jname,
        uint _minStake,
        uint _cherryBombMax,
        uint duration,
        uint startTime,
        uint endTime,
        address winner,
        bool status,
        uint dateTime) public{
        //jackpot data 
        jackId++;
        jackPots.push(JACKPOT(jackId, _jname, _minStake, _cherryBombMax, duration, startTime, endTime,winner,status,dateTime));    
    }
    function getAllJackpot() public view returns(JACKPOT[] memory){
        return jackPots;
    }
    function getAllStakes() public view returns(jackpotStakers[] memory){
        return allStakers;
    }   
    function uint2str(uint256 _i) internal pure returns (string memory str){
    if (_i == 0){
        return "0";
    }
    uint256 j = _i;
    uint256 length;
    while (j != 0){
        length++;
        j /= 10;
    }
    bytes memory bstr = new bytes(length);
    uint256 k = length;
    j = _i;
    while (j != 0){
        bstr[--k] = bytes1(uint8(48 + j % 10));
        j /= 10;
    }
    str = string(bstr);
    }
    uint256 public currentRewardId = 0;
    uint256 public prevRewardId = 0;
    uint256 public nextRewardId = 0;
    uint256 public _itemId;
    uint256 public hour = 1;
    
    string constant _name = "BABY SIFUINU JACKPOT";
    string constant _symbol = "BSJ";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 250000000000 * 10**_decimals ; //250B

    uint256 public _maxTxAmount = _totalSupply;
    uint256 public _maxWalletToken = _totalSupply;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    bool public blacklistMode = true;
    mapping (address => bool) public isBlacklisted;


    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;

    uint256 public liquidityFee    = 2;
    uint256 public reflectionFee   = 3;
    uint256 public marketingFee    = 2;
    uint256 public developerFee    = 4;
    uint256 public charityFee      = 3;
    uint256 public burnFee         = 0;


    uint256 private _previousLiquidityFee = liquidityFee;
    uint256 private _previousDevFee = developerFee; 
    uint256 private _previousMarketingFee = marketingFee;
    uint256 private _previousCharityFee = charityFee;
    uint256 private _previousReflectionFee = reflectionFee;

    uint256 public totalFee = marketingFee + reflectionFee + liquidityFee + developerFee + burnFee + charityFee;
    uint256 public feeDenominator  = 100;

    uint256 public sellMultiplier  = 100;

    uint256 public _saleLiquidityFee = 2;
    uint256 public _saleDevFee = 4;
    uint256 public _saleMarketingFee = 4;
    uint256 public _saleCharityFee = 3;
    uint256 public _saleReflectionFee   = 3;
    uint256 marketShare = 0;

    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    address public developerFeeReceiver;
    address public burnFeeReceiver;
    address public charityFeeReceiver;
    address public currentRouter;

    uint256 targetLiquidity = 99;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;

    bool public tradingOpen = true;

    DividendDistributor public distributor;
    uint256 distributorGas = 500000;

    bool public buyCooldownEnabled = false;
    uint8 public cooldownTimerInterval = 60;
    mapping (address => uint) private cooldownTimer;

    bool public swapEnabled = true;
    
    uint256 public swapThreshold = _totalSupply * 10 / 100000; //0.001%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        //auto create jackpot
        uint256 _startTime = block.timestamp;
        //uint256 _endtime = _startTime + (60 * 5);
        
        string memory _jackpotName = string.concat('Jackpot Round ', uint2str(0)) ;
        address _winner = address(0x0);
        jackPots.push(JACKPOT(0, _jackpotName, minStake, cherryBombMax, jackpotTimer, 0, 0,_winner,false,_startTime));
        //auto create jackpot end;
        currentRouter = PancakeRouterDev2; //Define Current Router
        router = IDEXRouter(currentRouter);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        distributor = new DividendDistributor(address(router));

        isFeeExempt[msg.sender] = true;
        isFeeExempt[PINKSALE] = true; // PINKSALE.FINANCE  
        isTimelockExempt[msg.sender] = true;
        
        isTimelockExempt[address(this)] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = MARKETING;
        developerFeeReceiver = DEV;
        charityFeeReceiver = SCHOLARSHIP;
        burnFeeReceiver = DEAD;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    
function restoreAllFee() private {
        liquidityFee = _previousLiquidityFee;
        developerFee = _previousDevFee;
        marketingFee = _previousMarketingFee;
        charityFee = _previousCharityFee;
        reflectionFee = _previousReflectionFee;
        totalFee = marketingFee + reflectionFee + liquidityFee + developerFee + burnFee + charityFee;
       }

    function setSaleFee() private {
        liquidityFee = _saleLiquidityFee;
        developerFee = _saleDevFee;
        marketingFee = _saleMarketingFee;
        charityFee = _saleCharityFee;
        reflectionFee = _saleReflectionFee;
        totalFee = marketingFee + liquidityFee + developerFee + burnFee + charityFee;
    }

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
            return approve(spender, type(uint256).max);
        }
    
        function transfer(address recipient, uint256 amount) external override returns (bool) {
            return _transferFrom(msg.sender, recipient, amount);
        }
    
        function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
            if(_allowances[sender][msg.sender] != type(uint256).max){
                _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
            }
    
            return _transferFrom(sender, recipient, amount);
        }

    function setMaxWalletPercent_base1000(uint256 maxWallPercent_base1000, uint256 maxTXPercentage_base1000) external onlyOwner() {
        _maxWalletToken = (_totalSupply * maxWallPercent_base1000 ) / 1000;
        _maxTxAmount = (_totalSupply * maxTXPercentage_base1000 ) / 1000;
    }
    function setTxLimit(uint256 amount) external authorized {
        _maxTxAmount = amount;
    }

    function minting(uint256 amount) public onlyOwner{
        require(amount > 1000, 'amount must be greater than 1');
        amount = amount * 10**_decimals ;
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        emit Transfer(address(0), msg.sender, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
       // checkTime();
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
        }

        // Blacklist
        if(blacklistMode){
            require(!isBlacklisted[sender] && !isBlacklisted[recipient],"Blacklisted");    
        }


        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != marketingFeeReceiver && recipient != developerFeeReceiver  && recipient != autoLiquidityReceiver && recipient != burnFeeReceiver){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}
        
        if (sender == pair &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for 1min between two buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }

        // Checks max transaction limit
        checkTxLimit(sender, amount);

        if(shouldSwapBack()){ swapBack(); }
        if(sender==pair) { setSaleFee(); } 
        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = (!shouldTakeFee(sender) || !shouldTakeFee(recipient)) ? amount : takeFee(sender, amount,(recipient == pair));
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, _balances[recipient]) {} catch {} 
        }

       // try distributor.process(distributorGas) {} catch {}

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

    function takeFee(address sender, uint256 amount, bool isSell) internal returns (uint256) {
        
        uint256 multiplier = isSell ? sellMultiplier : 100;
        uint256 feeAmount = amount.mul(totalFee).mul(multiplier).div(feeDenominator * 100);

        uint256 burnTokens = feeAmount.mul(burnFee).div(totalFee);
        uint256 contractTokens = feeAmount.sub(burnTokens);

        _balances[address(this)] = _balances[address(this)].add(contractTokens);
        _balances[burnFeeReceiver] = _balances[burnFeeReceiver].add(burnTokens);
        emit Transfer(sender, address(this), contractTokens);
        
        if(burnTokens > 0){
            emit Transfer(sender, burnFeeReceiver, burnTokens);    
        }

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    // function set_sell_multiplier(uint256 Multiplier) external onlyOwner{
    //     sellMultiplier = Multiplier;        
    // }

    // switch Trading
    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }

    // enable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
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
        uint256 amountBNBDeveloper = amountBNB.mul((developerFee / 2)).div(totalBNBFee);
        uint256 amountBNBCharity = amountBNB.mul(charityFee).div(totalBNBFee);
        marketShare = amountBNBMarketing.div(2);
        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        (bool tmpSuccess,) = payable(nftReward).call{value: marketShare, gas: 30000}("");
        (tmpSuccess,) = payable(marketingFeeReceiver).call{value: marketShare, gas: 30000}("");
        (tmpSuccess,) = payable(developerFeeReceiver).call{value: amountBNBDeveloper, gas: 30000}("");
        (tmpSuccess,) = payable(developerFeeReceiver2).call{value: amountBNBDeveloper, gas: 30000}("");
        (tmpSuccess,) = payable(address(this)).call{value: amountBNBCharity, gas: 30000}("");

        if(jackpotBalances[jackId] <= 50000000000000000000){
        jackpotBalances[jackId] = jackpotBalances[jackId].add(amountBNBCharity);
        }
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

    function setWbnbandCakeAddress(address wbnb, address cake) external authorized {
        // require(wbnb != WBNB,"Please enter valid and unique address");
        //require(cake != CAKE,"Please enter valid and unique address");
        WBNB = wbnb;
        CAKE = cake;
        distributor.updateWbnbandCakeAddress(wbnb,cake);
        emit updateWbnbAndCake(wbnb, cake);

    }

    function manuelCreatePair(address wBnb) external authorized {
        pair = IDEXFactory(router.factory()).createPair(wBnb, address(this));
    }

    function setRouterAndDistributorAddress(address newRouter, address newPair) external authorized {
        router = IDEXRouter(newRouter);
        pair = newPair;
    }

    // function setIsDividendExempt(address holder, bool exempt) external authorized {
    //     require(holder != address(this) && holder != pair);
    //     isDividendExempt[holder] = exempt;
    //     if(exempt){
    //         distributor.setShare(holder, 0);
    //     }else{
    //         distributor.setShare(holder, _balances[holder]);
    //     }
    // }

    function enable_blacklist(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

    function manage_blacklist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
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

    function setFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _developerFee, uint256 _burnFee, uint256 _charityFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        developerFee = _developerFee;
        charityFee = _charityFee;
        burnFee = _burnFee;
        totalFee = _liquidityFee + _reflectionFee + _marketingFee + _developerFee + _burnFee + _charityFee;
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/2, "Fees cannot be more than 50%");
    }

    function setSaleFeePercent(uint256 _liquidityFee, uint256 _devFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _charityFee) 
    external onlyOwner
    {
        _saleLiquidityFee = _liquidityFee;
        _saleDevFee = _devFee;
        _saleMarketingFee = _marketingFee;
        _saleCharityFee = _charityFee;
        _saleReflectionFee = _reflectionFee;
    }

    function setFeeReceivers(address _nftReward, address _autoLiquidityReceiver, address _marketingFeeReceiver, address _developerFeeReceiver, address _burnFeeReceiver, address _charityFeeReceiver, address _cherryBombWallet) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        developerFeeReceiver = _developerFeeReceiver;
        burnFeeReceiver = _burnFeeReceiver;
        charityFeeReceiver = _charityFeeReceiver;
        nftReward = _nftReward;
        cherryBombWallet = _cherryBombWallet;
    }
    
    function setCurrentRouter (address _NewRouter) external authorized {
        currentRouter = _NewRouter;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount, uint256 gas) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
        require(gas < 750000);
        distributorGas = gas;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    // function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
    //     distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    // }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }
        // Withdraw ETH that's potentially stuck in the Tres Leches Cupcake Contract
    function recoverETHfromtomorrowlandCC() public virtual onlyOwner {
        payable(charityFeeReceiver).transfer(address(this).balance);
    }

    // Withdraw ERC20 tokens that are potentially stuck in the Tres Leches Cupcake Contract
    function recoverTokensFromtomorrowlandCC(address _tokenAddress, uint256 _amount) public onlyOwner {                               
        IBEP20(_tokenAddress).transfer(charityFeeReceiver, _amount);
    }



/* Airdrop Begins */
function multiTransfer(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

    require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses");
    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    uint256 SCCC = 0;

    for(uint i=0; i < addresses.length; i++){
        SCCC = SCCC + tokens[i];
    }

    require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

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
event updateWbnbAndCake(address wBnb, address cake);
event logDistribution (address wallets, uint256 amount);
event investmentReport(address investorAddress, uint256 amount, uint256 investmentPlan, uint256 interestRate, uint256 investmentDate, uint256 releaseDate);
event inventReleased(address from, address to, uint256 totalEarned, uint256 ctime); 

}

//Blade Code