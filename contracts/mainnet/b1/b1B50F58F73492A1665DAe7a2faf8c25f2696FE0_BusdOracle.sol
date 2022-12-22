// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
import "./IERC20.sol";
import "./Ownable.sol";
import "./Chain.sol";

contract BusdOracle is Context, Ownable {
    AggregatorV3Interface internal priceFeed;

    uint256 public constant min = 20 ether;
    uint256 public max = 20000 ether;
    uint256 public roi = 30;
    uint256 public constant fee = 8;
    uint256 public constant ref_fee = 5;
    int256 public pricediff;
    int256 public lastprice;
    address public dev;
    address public mkt;
    address public mkt2;
    IERC20 private BusdInterface;
    address public tokenAdress;
    address public Oracleholder = address(0);
    uint256 public topdeposit;
    bool public init = false;
    bool public alreadyInvested = false;

    constructor(address _dev, address _mkt, address _mkt2) {
        require(!isContract(_dev) && !isContract(_mkt));
        dev = _dev;
        mkt = _mkt;
        mkt2 = _mkt2;
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE); //BNB/usd pricefeed mainnet
        //priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526); //BNB/usd pricefeed testnet
        //tokenAdress = 0x25C7c87B42ec086b01528eE72465F1e3c49B7B9D; //testnet
        tokenAdress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //Mainnet
        BusdInterface = IERC20(tokenAdress);
        lastprice = getLatestPrice();
        }

    struct refferal_system {
        address ref_address;
        uint256 reward;
    }

    struct refferal_withdraw {
        address ref_address;
        uint256 totalWithdraw;
    }

    struct user_investment_details {
        address user_address;
        uint256 invested;
    }

    struct weeklyWithdraw {
        address user_address;
        uint256 startTime;
        uint256 deadline;
    }

    struct claimDaily {
        address user_address;
        uint256 startTime;
        uint256 deadline;
    }

    struct userWithdrawal {
        address user_address;
        uint256 amount;
    }

    struct userTotalWithdraw {
        address user_address;
        uint256 amount;
    }
     struct userTotalRewards {
        address user_address;
        uint256 amount;
    } 
    struct userUnlock {
        address user_address;
        bool lock;
    } 

    mapping(address => refferal_system) public refferal;
    mapping(address => user_investment_details) public investments;
    mapping(address => weeklyWithdraw) public weekly;
    mapping(address => claimDaily) public claimTime;
    mapping(address => userWithdrawal) public approvedWithdrawal;
    mapping(address => userTotalWithdraw) public totalWithdraw;
    mapping(address => userTotalRewards) public totalRewards; //hhnew 
    mapping(address => refferal_withdraw) public refTotalWithdraw;
    mapping(address => userUnlock) public unlock;

    function ChangeROI() private {
        if (getLatestPrice() - lastprice != 0){
        pricediff = getLatestPrice() - lastprice;
        if (pricediff < 0 && roi <= 50) {roi += 1;}
        else if (pricediff > 0 && roi >= 10 ) { roi -= 1;}
        }
        lastprice = getLatestPrice();
    }

    // invest function 
    function deposit(address _ref, uint256 _amount) public  {
        require(init && !isContract(msg.sender));
        require(_amount >= min && _amount <= max, "Cannot Deposit");
       
        //ref only works on first deposits
        if(!checkAlready()){  
            uint256 ref_fee_add = refFee(_amount);
        if(_ref != address(0) && _ref != msg.sender) {
            uint256 ref_last_balance = refferal[_ref].reward;
            uint256 totalRefFee = ref_fee_add + ref_last_balance;   
            refferal[_ref] = refferal_system(_ref,totalRefFee);
        }
        //dev & mkt get 1/4 of unused ref each, 1/2 stays in the contract
        else {
            uint256 ref_last_balance = refferal[dev].reward;
            uint256 refmkt_last_balance = refferal[mkt].reward;
            uint256 totalRefFee = (ref_fee_add / 4) + ref_last_balance; 
            uint256 totalRefFee2 = (ref_fee_add / 4) + refmkt_last_balance; 
            refferal[dev] = refferal_system(dev,totalRefFee);
            refferal[mkt] = refferal_system(mkt,totalRefFee2);
            }
        }
        
        // investment details
        uint256 userLastInvestment = investments[msg.sender].invested;
        uint256 userCurrentInvestment = _amount;
        uint256 totalInvestment = userLastInvestment + userCurrentInvestment;
        investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);

        // fees 
        uint256 total_fee = depositFee(_amount);
        uint256 fee_mkt2 = total_fee / 8;
        uint256 fee_gen = (total_fee - fee_mkt2) / 2;
        uint256 total_contract = _amount - total_fee;
        BusdInterface.transferFrom(msg.sender,dev,fee_gen);
        BusdInterface.transferFrom(msg.sender,mkt,fee_gen);
        BusdInterface.transferFrom(msg.sender,mkt2,fee_mkt2);
        BusdInterface.transferFrom(msg.sender,address(this),total_contract);

        if (_amount > topdeposit){
            Oracleholder = msg.sender;
            topdeposit = _amount;
        }

        ChangeROI();
        UpdateTime();        
    }

    function UpdateTime() internal {
        if (unlock[msg.sender].lock == false){
        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp + 1 days;
        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);

        uint256 weeklyStart = block.timestamp;
        uint256 deadline_weekly = block.timestamp + 7 days;
        weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);
        } 
        else if (unlock[msg.sender].lock == true){
        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp + 120 days;
        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);

        uint256 weeklyStart = block.timestamp;
        uint256 deadline_weekly = block.timestamp + 120 days;
        weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);
        }
    }

    function userReward(address _userAddress) public view returns(uint256) {
        uint256 userInvestment = investments[_userAddress].invested;
        uint256 userDailyReturn;
        if (unlock[_userAddress].lock == true){

            //if unlocked the calculation or daily rewards has to be multiplied by the days assigned to get the same daily %
            userDailyReturn = DailyRoi(userInvestment) * 120;
        } 
        else {
            userDailyReturn = DailyRoi(userInvestment);
        } 
    
        // invested time
        uint256 claimInvestTime = claimTime[_userAddress].startTime;
        uint256 claimInvestEnd = claimTime[_userAddress].deadline;

        uint256 totalTime = claimInvestEnd - claimInvestTime;
        uint256 value = userDailyReturn / totalTime;
        uint256 nowTime = block.timestamp;

        if(claimInvestEnd >= nowTime) {  //|| unlock[msg.sender].lock == true
        uint256 earned = nowTime - claimInvestTime;
        uint256 totalEarned = earned * value;

        return totalEarned;
        }
        else {
            return userDailyReturn;
        }
    }

    function withdrawal() public {
    require(init, "Not Started Yet");   
    if (unlock[msg.sender].lock == false){
            require(weekly[msg.sender].deadline <= block.timestamp, "You cant withdraw");    
            uint256 weeklyStart = block.timestamp;
            uint256 deadline_weekly = block.timestamp + 7 days;
            weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);
        } 
    
    uint256 aval_withdraw = approvedWithdrawal[msg.sender].amount;
    BusdInterface.transfer(msg.sender,aval_withdraw);
    approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender , 0 ); 
    uint256 amount = totalWithdraw[msg.sender].amount;
    uint256 totalAmount = amount + aval_withdraw; 
    totalWithdraw[msg.sender] = userTotalWithdraw(msg.sender,totalAmount);

    ChangeROI();
    }
    
    function compound() public {
    require(init, "Not Started Yet");   

    if (unlock[msg.sender].lock == false){    
            weekly[msg.sender].deadline += 1 days;
        } 
    
    uint256 aval_withdraw = approvedWithdrawal[msg.sender].amount;
    approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender , 0); 
    
    // investment details
    uint256 userLastInvestment = investments[msg.sender].invested;
    uint256 userCurrentInvestment = aval_withdraw;
    uint256 totalInvestment = userLastInvestment + userCurrentInvestment;
    investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);

    ChangeROI();
    }
    
    function claimDailyRewards() public {
        require(init, "Not Started Yet");
        
        //claim rewards before assigning a new claiming time
        uint256 rewards = userReward(msg.sender);

        //check the current state of the lock and assign a new claiming time
        if (unlock[msg.sender].lock == false){
            require(claimTime[msg.sender].deadline <= block.timestamp, "You cant claim");    
            uint256 claimTimeStart = block.timestamp;
            uint256 claimTimeEnd = block.timestamp + 1 days;
            claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);
        }
        else if (unlock[msg.sender].lock == true){
            uint256 claimTimeStart = block.timestamp;
            claimTime[msg.sender].startTime = claimTimeStart;
        }
        
        uint256 currentApproved = approvedWithdrawal[msg.sender].amount;
        uint256 value = rewards + currentApproved;

        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,value);
        uint256 amount = totalRewards[msg.sender].amount; 
        uint256 totalRewardAmount = amount + rewards; 
        totalRewards[msg.sender].amount = totalRewardAmount;

        //the oracle holder receives a bonus on any claim
        if (msg.sender != Oracleholder){
        uint256 BonusOracle = (rewards * 2 / 100) + approvedWithdrawal[Oracleholder].amount;
        approvedWithdrawal[Oracleholder] = userWithdrawal(Oracleholder,BonusOracle);
        }

        //set new ROI
        ChangeROI();
    }

    
    function unlockTime() external {
        require(init, "Not Started Yet");
        require(unlock[msg.sender].lock == false, "Already unlocked");
        BusdInterface.transferFrom(msg.sender,address(this), 200 ether);
        
        uint256 rewards = userReward(msg.sender);
        uint256 currentApproved = approvedWithdrawal[msg.sender].amount;
        uint256 value = rewards + currentApproved;

        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,value);
        uint256 amount = totalRewards[msg.sender].amount;
        uint256 totalRewardAmount = amount + rewards;
        totalRewards[msg.sender].amount = totalRewardAmount;

        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp + 120 days;
        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);

        uint256 weeklyStart = block.timestamp;
        uint256 deadline_weekly = block.timestamp + 120 days;
        weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);

        unlock[msg.sender].lock = true;
    }

    function Ref_Withdraw() external {
        require(init, "Not Started Yet");
        uint256 value = refferal[msg.sender].reward;

        BusdInterface.transfer(msg.sender,value);
        refferal[msg.sender] = refferal_system(msg.sender,0);

        uint256 lastWithdraw = refTotalWithdraw[msg.sender].totalWithdraw;
        uint256 totalValue = value + lastWithdraw;

        refTotalWithdraw[msg.sender] = refferal_withdraw(msg.sender,totalValue);
    }

    // initialized the market
    function signal_market(uint256 _amount) external onlyOwner {
        init = true;
        unlock[msg.sender].lock = true;
        deposit(msg.sender, _amount);
    }

    function changeDev (address _dev, address _mkt, address _mkt2) external onlyOwner {
        dev = _dev;
        mkt = _mkt;
        mkt2 = _mkt2;
    }

    //to be used if the max is reached so the Oracle can be passed again
    function changeMaxdep (uint256 _max) external onlyOwner {
        max = _max;
    }

    // only view functions

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    // call Chainlink to fetch a new BNB price
    function getLatestPrice() public view returns (int) {
        (
            ,
            /*uint80 roundID*/ int price /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,
        ) = priceFeed.latestRoundData();
        return price;
    }

    function DailyRoi(uint256 _amount) public view returns(uint256) {
            return _amount * roi / 1000;
    }

    function OracleHolder() external view returns(address) {
            return Oracleholder;
    }

    function returnROI() external view returns(uint256) {
            return roi;
    }
    
    function returnDIFF() external view returns(int256) {
            return pricediff;
    }

    function Topdeposit() external view returns(uint256) {
            return topdeposit;
    }

    function checkAlready() public view returns(bool) {
         address _address= msg.sender;
        if(investments[_address].user_address == _address){
            return true;
        }
        else{
            return false;
        }
    }

    function depositFee(uint256 _amount) public pure returns(uint256){
     return _amount * fee / 100;
    }

    function refFee(uint256 _amount) public pure returns(uint256) {
        return _amount * ref_fee / 100;
    }

    function getBalance() public view returns(uint256){
         return BusdInterface.balanceOf(address(this));
    }

    function checkLock(address _address) public view returns(bool){
         return unlock[_address].lock;
    }

}