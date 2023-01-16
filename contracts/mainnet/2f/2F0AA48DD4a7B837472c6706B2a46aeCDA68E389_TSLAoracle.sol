// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
import "./IERC20.sol";
import "./Ownable.sol";
import "./Chain.sol";

interface _BUSDOracle {
   function OracleHolder() external view returns(address);
   function getWhitelist() external view returns(address[] memory);
   function Topdeposit() external view returns(uint256);
}

contract TSLAoracle is Context, Ownable {
    AggregatorV3Interface internal priceFeed;

    //address public BUSDaddress = 0xe4eD68F6aB0Bba986bf4b039b6F7CdB1fB219B34; //BUSD Oracle Teestnet address
    address public BUSDaddress = 0xAC82EF603D3Faf774be7A648A46529EF9ff4DfBA; //BUSD Oracle Mainnet address
    uint256 public constant min = 50 ether;
    uint256 public max = 100000 ether;
    uint256 roi = 20;
    uint256 public fee = 8;
    uint256 public constant ref_fee = 5;
    int256 public pricediff;
    uint256 resets;
    uint256 smallresets;
    uint256 public WhiteTime;
    int256 public lastprice;
    address public teamwallet;
    address public mkt;
    IERC20 private BusdInterface;
    address public tokenAdress;
    address TSLAholder = address(0);
    address smallTSLAholder = address(0);
    address Kingholder = address(0);
    uint256 topdeposit;
    uint256 smalltopdeposit;
    bool public init = false;
    address[] public Whitelist_TSLA = _BUSDOracle(BUSDaddress).getWhitelist();

    constructor(address _teamwallet, address _mkt) {
       teamwallet =_teamwallet;
       mkt =_mkt;
        priceFeed = AggregatorV3Interface(0xEEA2ae9c074E87596A85ABE698B2Afebc9B57893); //TSLA/usd pricefeed mainnet
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

    struct user_weekly_details {
        address user_address;
        uint256 invested;
        uint256 reset_pasttime;
        uint256 smallreset_pasttime;
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
    struct userROI {
        address user_address;
        uint256 amount;
    }

    mapping(address => refferal_system) public refferal;
    mapping(address => user_investment_details) public investments;
    mapping(address => user_weekly_details) public weekly_investments;
    mapping(address => weeklyWithdraw) public weekly;
    mapping(address => claimDaily) public claimTime;
    mapping(address => userWithdrawal) public approvedWithdrawal;
    mapping(address => userTotalWithdraw) public totalWithdraw;
    mapping(address => userTotalRewards) public totalRewards; 
    mapping(address => refferal_withdraw) public refTotalWithdraw;
    mapping(address => userROI) public currentROI;

    //check if address is whitelisted in BUSD Oracle
    function isWhiteListed(address _address) public view returns (bool) {
    for (uint i = 0; i < Whitelist_TSLA.length; i++) {
        if (Whitelist_TSLA[i] == _address) {
            return true;
            }
        }
        return false;
    }

    function ChangeROI() private {
        if (getLatestPrice() - lastprice != 0){
        pricediff = getLatestPrice() - lastprice;
            if (pricediff < 0 && roi <= 29) {
                roi += 1;
            }else if (pricediff > 0 && roi >= 11) {
                roi -= 1;    
            }
            if (pricediff > 0 && currentROI[msg.sender].amount <= 29) {currentROI[msg.sender].amount -= 1;}
            else if (pricediff < 0 && currentROI[msg.sender].amount >= 11) {currentROI[msg.sender].amount += 1;}
            }
        lastprice = getLatestPrice();
    }

    //get BUSDoracle current holder
    function currentBUSDHolder() external view returns(address) {
            return _BUSDOracle(BUSDaddress).OracleHolder();
    }

    function Oraclemanagement(address _user, uint256 _amount) internal {

            uint256 totinvested = weekly_investments[_user].invested + _amount;
            uint256 _nowtime = block.timestamp;

             //weekly deposits reset for a new Oracle to be assigned, this event happens weekly only
            if (_nowtime >= resets){
                TSLAholder = address(0);
                topdeposit = 0;
                resets = _nowtime + 7 days;
            }

            if (block.timestamp >= smallresets){
                smallTSLAholder = address(0);
                smalltopdeposit = 0;
                smallresets = _nowtime + 2 days;
            }

            //check needed to reset weekly investement of the user
            if (weekly_investments[_user].reset_pasttime != resets){
                weekly_investments[_user].reset_pasttime = resets;
                weekly_investments[_user].invested = 0;
                }
            if (weekly_investments[_user].smallreset_pasttime != smallresets){
                weekly_investments[_user].smallreset_pasttime = smallresets;
                weekly_investments[_user].invested = 0;
                }
            
            //if weekly top depositor, users gets the oracle
            if (totinvested > topdeposit && totinvested >= 3000 ether){
                TSLAholder =  _user;
                topdeposit = totinvested;
            }
            else if (totinvested > smalltopdeposit && totinvested < 3000 ether && totinvested >= 50 ether){
                smallTSLAholder =  _user;
                smalltopdeposit = totinvested;
            }
        }

    // invest function 
    function deposit(address _ref, uint256 _amount) public  {
        require(init && !isContract(msg.sender));
        require(_amount >= min && _amount <= max, "Cannot Deposit");

        Oraclemanagement(msg.sender, _amount);
        uint256 total_fee = depositFee(_amount);
        uint256 nowtimer = block.timestamp;

        if (nowtimer - WhiteTime <= 2 days){
            //update whitelist
            Whitelist_TSLA = _BUSDOracle(BUSDaddress).getWhitelist();
            require (isWhiteListed(msg.sender) == true, "only whitelists allowed for the first 3 days");
            //fees are 1/3 lower for whitelists (4% total fee)
            total_fee = total_fee / 2;
        }

        //ref system, only 1 ref for new deposits
        if(!checkAlready()){  
            uint256 ref_fee_add = refFee(_amount);

            //if user is new their ROI = General ROI
            currentROI[msg.sender] = userROI(msg.sender,roi);
        if(_ref != address(0) && _ref != msg.sender) {
            uint256 ref_last_balance = refferal[_ref].reward;
            uint256 totalRefFee = ref_fee_add + ref_last_balance;   
            refferal[_ref] = refferal_system(_ref,totalRefFee);
            }
        } 

        //If user not new, update user ROI
        else {ChangeROI();}
        
        // investment details
        uint256 userLastInvestment = investments[msg.sender].invested;
        uint256 userCurrentInvestment = _amount - depositFee(_amount);
        
        //totalweekly is the amount that users deposit in a 7 days range, unlike the total user deposit, this refreshes weekly
        uint256 totalweekly = weekly_investments[msg.sender].invested + _amount;
        weekly_investments[msg.sender] = user_weekly_details(msg.sender,totalweekly,resets,smallresets);

        uint256 totalInvestment = userLastInvestment + userCurrentInvestment;
        investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);

        // fees 
        uint256 fee_oracle = total_fee / 8 * 4;  //4% goes into BUSD Oracle
        uint256 fee_gen = (total_fee - fee_oracle);
        uint256 total_contract = _amount - total_fee;
        BusdInterface.transferFrom(msg.sender,teamwallet,fee_gen / 2);  //2% goes to the team
        BusdInterface.transferFrom(msg.sender,mkt,fee_gen / 2);  //2% goes to mkt
        BusdInterface.transferFrom(msg.sender,BUSDaddress,fee_oracle); //4% to the BUSD oracle
        BusdInterface.transferFrom(msg.sender,address(this),total_contract);


        //oracle swap
        
        UpdateTime();        
    }

    function UpdateTime() internal {
       
        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp + 4 days;
        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);

        uint256 weeklyStart = block.timestamp;
        uint256 deadline_weekly = block.timestamp + 8 days;
        weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);
        
    }

    function userReward(address _userAddress) public view returns(uint256) {
        uint256 userInvestment = investments[_userAddress].invested;

        //daily rewards need to be mutiplied for max claiming deadline (4 days)
        uint256 userDailyReturn = DailyRoi(userInvestment, _userAddress) * 4;
    
        // invested time
        uint256 claimInvestTime = claimTime[_userAddress].startTime;
        uint256 claimInvestEnd = claimTime[_userAddress].deadline;

        uint256 totalTime = claimInvestEnd - claimInvestTime;
        uint256 value = userDailyReturn / totalTime;
        uint256 nowTime = block.timestamp;

        if(claimInvestEnd >= nowTime) { 
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
    require(weekly[msg.sender].deadline <= block.timestamp, "You cant withdraw");    
    Oraclemanagement(msg.sender, 0);

    uint256 weeklyStart = block.timestamp;
    uint256 deadline_weekly = block.timestamp + 8 days;
    weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);
    
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
   
    if (weekly[msg.sender].deadline <= block.timestamp){
            weekly[msg.sender].deadline = block.timestamp + 2 days; 
        }
        else {
            weekly[msg.sender].deadline += 2 days;
        }
    
    uint256 aval_withdraw = approvedWithdrawal[msg.sender].amount;
    approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender , 0);

    Oraclemanagement(msg.sender, aval_withdraw);
    weekly_investments[msg.sender].invested += aval_withdraw;

    uint256 claimTimeStart = block.timestamp;
    uint256 claimTimeEnd = block.timestamp + 4 days;
    claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);

    // investment details
    uint256 userLastInvestment = investments[msg.sender].invested;
    uint256 userCurrentInvestment = aval_withdraw;
    uint256 totalInvestment = userLastInvestment + userCurrentInvestment;
    investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);

    ChangeROI();
    }
    
    function claimDailyRewards() public {
        require(init, "Not Started Yet");
        
        //Users can claim only after 1 days or keep accumulating rewards up to 4 days
        require(claimTime[msg.sender].deadline - 3 days <= block.timestamp, "You cant claim before 24 days");  

        Oraclemanagement(msg.sender, 0);
        //claim rewards before assigning a new claiming time
        uint256 rewards = userReward(msg.sender);
        uint256 claimTimeStart = block.timestamp;

        uint256 claimTimeEnd = claimTimeStart + 4 days;
        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);

        
        uint256 currentApproved = approvedWithdrawal[msg.sender].amount;
        uint256 value = rewards + currentApproved;

        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,value);
        uint256 amount = totalRewards[msg.sender].amount; 
        uint256 totalRewardAmount = amount + rewards; 
        totalRewards[msg.sender].amount = totalRewardAmount;
        address nowholder = _BUSDOracle(BUSDaddress).OracleHolder();

        //the oracle holder receives a bonus on any claim, if they holder holds both Oracles this bonus is doubled
        if (nowholder == TSLAholder){
            Kingholder = TSLAholder;
            if (msg.sender != TSLAholder){
                uint256 BonusOracle = (rewards * 6 / 100) + approvedWithdrawal[TSLAholder].amount;
                approvedWithdrawal[TSLAholder] = userWithdrawal(TSLAholder,BonusOracle);
                } 
            }
                else {
                Kingholder = address(0);
                uint256 BonusOracle = (rewards * 3 / 100) + approvedWithdrawal[TSLAholder].amount;
                approvedWithdrawal[TSLAholder] = userWithdrawal(TSLAholder,BonusOracle);
                }

        if (msg.sender != smallTSLAholder && msg.sender != TSLAholder){
                uint256 BonusOracle = (rewards / 100) + approvedWithdrawal[smallTSLAholder].amount;
                approvedWithdrawal[smallTSLAholder] = userWithdrawal(smallTSLAholder,BonusOracle);
                } 
            
        //set new ROI
        ChangeROI();
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
    function signal_market() external onlyOwner {
        require (init == false, "Already Init");
        init = true;
        WhiteTime = block.timestamp;

        //the first cycle of resets has 1 more day (1 full day is wasted before users can claim)
        resets = block.timestamp + 8 days;
        smallresets = block.timestamp + 3 days;
    }

    //Owner can call Oraclemanagement to update the platform (in case there there are few claims to trigger it in the first few days after 1 week)
    function callmanagement() external onlyOwner {
        require(block.timestamp >= resets,"Oracle can reset every 7 days only");
        Oraclemanagement(msg.sender, 0);
    }

    //Owner can change team wallet and BUSD oracle address, necessary for future Oracle launches
    function changeDev (address _teamwallet, address _neworacle, address _mkt) external onlyOwner {

       teamwallet = _teamwallet;
       BUSDaddress = _neworacle;
       mkt = _mkt;
    }

    function resetRoi() external {
        require(init, "Not Started Yet");
        BusdInterface.transferFrom(msg.sender,address(this), 50 ether);
        currentROI[msg.sender].amount = 20;
    }

    //to be used if the max is reached so the Oracle can be passed again
    function changeMaxdep (uint256 _max) external onlyOwner {
        require (_max > max, "you cant lower max deposit");
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

    function DailyRoi(uint256 _amount, address _sender) public view returns(uint256) {
        uint256 currentrr = currentROI[_sender].amount;
            return _amount * currentrr / 1000;
    }

    function OracleHolder() external view returns(address) {
            return TSLAholder;
    }

    function smallOracleHolder() external view returns(address) {
            return smallTSLAholder;
    }

    function smallTopdeposit() external view returns(uint256) {
            return smalltopdeposit;
    }

    function KNGHolder() external view returns(address) {
            if (_BUSDOracle(BUSDaddress).OracleHolder() == TSLAholder){
            return TSLAholder;
    }       else{
            return address(0);
            }
    }

    function BUSDoracleHolder() external view returns(address) {
            return _BUSDOracle(BUSDaddress).OracleHolder();
    }

    function BUSDoracledeposit() external view returns(uint256) {
            return _BUSDOracle(BUSDaddress).Topdeposit();
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

    function resetTime() external view returns(uint256) {
            return resets;
    }

    function smallresetTime() external view returns(uint256) {
            return smallresets;
    }

    function MinClaim(address _user) external view returns(uint256) {
            return claimTime[_user].deadline - 3 days;
    }

    function smallOralceStake(address _user) external view returns(uint256) {
            return weekly_investments[_user].invested;
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

    function depositFee(uint256 _amount) private view returns(uint256){
     return _amount * fee / 100;
    }

    function refFee(uint256 _amount) public pure returns(uint256) {
        return _amount * ref_fee / 100;
    }

    function getBalance() public view returns(uint256){
         return BusdInterface.balanceOf(address(this));
    }
}