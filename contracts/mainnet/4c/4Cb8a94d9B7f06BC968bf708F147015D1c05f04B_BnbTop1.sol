/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

// SPDX-License-Identifier: MIT

 /*  BNBTOP1
 *   is dedicated to remove the risks of the possible errors and circumstances in conventional online 
 *   based networking marketing and investment businesses with our state of the art BNB smart contract. 
 *   An impartial third-party audit firm has examined the smart contract's source code to prove its credibility.
 *
 *   ┌───────────────────────────────────────────────────────────────────────┐
 *   │   Website: https://BNBTop1.com           							 │
 *	 │	 1% Daily ROI 	       	                                             │
 *   │   Audited, Verified with No Backdoor.       							 │
 *   └───────────────────────────────────────────────────────────────────────┘
 *
 *   [REFERRAL REWARDS]
 *
 *   - 11-level referral commission: 10% - 4% - 2% - 1% - 1% - 0.5% - 0.5% - 0.4% - 0.3% - 0.2% - 0.1%  
 *  
 */

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title BNBTop1
 * @dev The best and most secure BNB based smartcontract investment
 */
contract BnbTop1 {
    
    //STATE VARIABLES
    address public owner;
    AdminStruct[3] public admins;
    uint public total_members = 0;
    uint public total_cummulative_investment = 0; //In wei
    uint public total_cummulative_withdrawn = 0; //In wei
    uint public min_investment; //In wei
    uint public min_withdraw; //In wei
    uint public max_investment; //In wei
    uint public max_earning_percentage = 300; //In percentage
    uint constant BONUS_LINES_COUNT = 11;
    uint[BONUS_LINES_COUNT] public referral_pay_rates = [100,40,20,10,10,5,5,4,3,2,1]; //Divide by REFERRAL_PERCENT_DIVIDER
    uint constant REFERRAL_PERCENT_DIVIDER = 1000;
    uint constant DAY_INTEREST_PERCENT = 1; //In percentage
    mapping(address => UserStruct) private users;
    //END OF STATE VARIABLES

    //REENTRY GUARD VARIABLES
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    //END REENTRY GUARD VARIABLES

    //CONSTRUCTOR
    constructor(){
        owner = payable(msg.sender);
        min_investment = bnbTimes100ToWei(2);
        min_withdraw = bnbTimes100ToWei(4);
        max_investment = bnbTimes100ToWei(40000);
        //First Upline User - Owner - For breaking loop 
        total_members+=1;
        total_cummulative_investment+=0;
        UserStruct memory ownerUser =  UserStruct({
                is_active: true,
                self_address: msg.sender,
                balance : 0,
                sponsor: address(0),
                investment: max_investment,
                dividends_paid: 0,
                last_dividend_time: block.timestamp,
                referral_bonus_earned: 0,
                withdrawn_amount: 0,
                last_withdraw_time: block.timestamp,
                week_limit_count: 0,
                week_limit_count_time: block.timestamp, 
                referral_structure: [0,0,0,0,0,0,0,0,0,0,0]
            }) ;
        users[msg.sender] = ownerUser;
        //Adding Admins
        admins[0] = AdminStruct("ZM",0xbE0F7664f7534E4f71aFFfCDA7ef851cf453bFFb,8);
        admins[1] = AdminStruct("HM",0xbEc928B68bD8c95B76F67F08b1c8c9d7bC20a5cd,8);
        admins[2] = AdminStruct("KL",0x63F795Ba855D6677C3AE8943ceA85481D0C5164f,4);
        //REENTRYGUARD VARIABLE
        _status = _NOT_ENTERED;
    }
    //END OF CONSTRUCTOR

    //EVENTS DEFINITIONS
    event UplineCountUpdated(address indexed registeringAddress, address indexed sponsor, uint256 amount);
    event NewInvestment(address indexed investingAddress, uint256 amount);
    event WithdrawCompleted(address indexed withdrawingAddress, uint256 amount);
    //END OF EVENTS DEFINITION

    //TESTING FUNCTION FOR DEVELOPMENT PURPOSES
    function tester() public pure returns (int){
        return 0;
    }
    //END OF TESTING FUNCTION FOR DEVELOPMENT PURPOSES

    //UTILITY FUNCTIONS
    modifier onlyOwner(){
        require(msg.sender == owner, "ONLY the owner of BNBTop1 contract can perform this action");
        _;
    }

    modifier noReentry() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call. Action Stopped!");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    function bnbTimes100ToWei(uint _bnbTimes100) private pure returns(uint){
        uint convesionRate = 1000000000000000000;
        uint weiConverted = _bnbTimes100 * (convesionRate/100);//(convesionRate/100) because _bnbTimes100 is X 100
        return weiConverted;
    }

    function generateNewUser(address _selfAddress, address _sponsor, uint _investedAmount) private returns (UserStruct memory){   
        total_members+=1;
        total_cummulative_investment+=_investedAmount;
        return UserStruct({
                is_active : true,
                self_address: _selfAddress,
                balance : 0,
                sponsor: _sponsor,
                investment: _investedAmount,
                dividends_paid: 0,
                last_dividend_time: block.timestamp,
                referral_bonus_earned: 0,
                withdrawn_amount: 0,
                last_withdraw_time: (block.timestamp - 24 hours),
                week_limit_count: 0,
                week_limit_count_time: (block.timestamp - 7 days), 
                referral_structure: [0,0,0,0,0,0,0,0,0,0,0]
        });
    }

    function getUserBalance(UserStruct storage _user) private returns (uint){
        payUserInvestmentEarnings(_user);
        return _user.balance;
    }

    function getUserTotalEarnings(UserStruct memory _user) private pure returns(uint){
        return (_user.dividends_paid + _user.referral_bonus_earned);
    }

    function getUserMaximumEarningsLimit(UserStruct memory _user) private view returns(uint){
        return (_user.investment * (max_earning_percentage/100));
    }
    
    function getUserRemainingEarningLimit(UserStruct memory _user) private view returns(uint){
        return (getUserMaximumEarningsLimit(_user) - getUserTotalEarnings(_user));
    }

    function getUserRemainingWithdrawLimit(UserStruct memory _user) private view returns(uint){
        return (getUserMaximumEarningsLimit(_user) - _user.withdrawn_amount);
    }

    function howMuchShouldEarn(UserStruct memory _user, uint _payingAmount) private view returns(uint){
        //FUNCTION NOT USED IN CONTRACT BUT MATBE USED TO CUT THE AMOUNT A USER RECEIVES AFTER REACHING 300% OF EARNINGS
        uint remainingLimit = getUserRemainingEarningLimit(_user);
        if(remainingLimit >= _payingAmount){
            return _payingAmount;
        }
        return remainingLimit;
    }

    function updateUplineCount(address _sponsorAddress) private{
        for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
            users[_sponsorAddress].referral_structure[i]++;
            _sponsorAddress = users[_sponsorAddress].sponsor;
            if(_sponsorAddress == address(0)) break; //Owner is first upline - break loop
        }
        emit UplineCountUpdated(_sponsorAddress, users[_sponsorAddress].sponsor, users[_sponsorAddress].investment);
    }

    function payReferralBonus(address _investingAddress, uint256 _amountInvested) private{
        address uplineAddress = users[_investingAddress].sponsor;
        for(uint8 i = 0; i < referral_pay_rates.length; i++) {
            if(uplineAddress == address(0)) break; //Owner is first upline - break loop
            uint bonusPayAmount = (_amountInvested/REFERRAL_PERCENT_DIVIDER) * referral_pay_rates[i];
            users[uplineAddress].balance += bonusPayAmount;
            users[uplineAddress].referral_bonus_earned += bonusPayAmount;
            uplineAddress = users[uplineAddress].sponsor;           
        }
    }

    function payUserInvestmentEarnings(UserStruct storage _user) private {
        uint earningsFromLastPay = calculateEaringsFromLastPaytime(_user.investment, _user.last_dividend_time);
        _user.balance += earningsFromLastPay;
        _user.dividends_paid += earningsFromLastPay;
        _user.last_dividend_time = block.timestamp;
    }

    function calculateEaringsFromLastPaytime(uint _investedAmount, uint _lastPayTime) private view returns(uint){
        uint secondsPassed = block.timestamp - _lastPayTime;
        uint earnings =  ((secondsPassed * (_investedAmount * DAY_INTEREST_PERCENT/100)) / (24*60*60));
        return earnings;
    }
    //END OF UTILITY FUNCTIONS

    //ADMIN FUNCTIONS
    function payAdminFees(uint _investedAmount) private{
        for (uint i = 0; i < admins.length; i++) {
            payable(admins[i].payAddress).transfer(admins[i].payPercentage * (_investedAmount/100)); //Divided by 100 because of percentage
        }
    }
    //END OF ADMIN FUNCTIONS

    //BUSINESS FUNCTIONS
    function invest(address _sponsorAddress) external noReentry payable{
        //Basic validations
        require(msg.value >= min_investment, "Minimum investment amount is 0.02 BNB!");
        require(msg.value <= max_investment, "Maximum investment amount is 400 BNB!");
        require(users[_sponsorAddress].is_active == true, "The given sponsor not registered in BNB!");
        //Checking if is exisiting user
        if(users[msg.sender].is_active == true){
            //pay daily earnings and update date so to start with new rate
            payUserInvestmentEarnings(users[msg.sender]);
            users[msg.sender].investment += msg.value;
        }else{
            UserStruct memory newUserObject = generateNewUser(msg.sender, _sponsorAddress, msg.value);
            users[msg.sender] = newUserObject;
            updateUplineCount( _sponsorAddress);
        }
        payReferralBonus(msg.sender, msg.value);
        payAdminFees(msg.value);       
        emit NewInvestment(msg.sender, msg.value);
        payUserInvestmentEarnings(users[_sponsorAddress]);
    }
    
    function withdraw(uint _withdrawAmountRequested) external noReentry payable{
        require(users[msg.sender].is_active == true, "No such user registered in BNBTop1!");
        UserStruct storage withdrawingUser = users[msg.sender];
        require( _withdrawAmountRequested >= min_withdraw, "You cannot withdraw below 0.04 BNB!");
        require( getUserBalance(withdrawingUser) >= _withdrawAmountRequested, "You cannot withdraw more than your available balance!");
        require( getUserRemainingWithdrawLimit(withdrawingUser) > 0, "Increase you earning limit by investing more to withdraw your balance!");
        require( getUserRemainingWithdrawLimit(withdrawingUser) >= _withdrawAmountRequested, "You cannot withdraw beyond 300% your investment!");
        require(block.timestamp >= (withdrawingUser.last_withdraw_time + 24 hours ), "You can only withdraw once every 24 hours!");
        if(block.timestamp > (withdrawingUser.week_limit_count_time + 7 days)){
            withdrawingUser.week_limit_count_time = block.timestamp;
            withdrawingUser.week_limit_count = 0; 
        }
        require((withdrawingUser.week_limit_count + _withdrawAmountRequested) <= bnbTimes100ToWei(2000), "You can only withdraw 20 BNB in 7 days!");
        uint contractBalance = address(this).balance;
        if (contractBalance < _withdrawAmountRequested) {
            _withdrawAmountRequested = contractBalance;
        }
        payable(msg.sender).transfer(_withdrawAmountRequested);  
        withdrawingUser.balance -= _withdrawAmountRequested;
        withdrawingUser.withdrawn_amount += _withdrawAmountRequested;
        withdrawingUser.last_withdraw_time = block.timestamp; 
        total_cummulative_withdrawn += _withdrawAmountRequested;
        //Update weekly limit check
        withdrawingUser.week_limit_count += _withdrawAmountRequested;
        //End of weekly limit check 
        emit WithdrawCompleted(msg.sender, _withdrawAmountRequested);
        payUserInvestmentEarnings(withdrawingUser);
    }
    //END OF BUSINESS FUNCTIONS

    //REPORTING FUNCTIONS
    function getUsersInfo(address _userAddress) public view  
    returns(uint balance, uint investment, uint dividends_paid, 
    uint referral_bonus_earned, uint withdrawn_amount, uint last_withdraw_time, uint8[11] memory referral_structure) 
    {
        // require(users[_userAddress].is_active == true, "No such user registered in BNBTop1!"); //Disabled based on frontend logic to allow user address query before investing
        UserStruct storage userToCheckInfo = users[_userAddress];
        uint balanceToAdd = calculateEaringsFromLastPaytime(userToCheckInfo.investment, userToCheckInfo.last_dividend_time);
        uint _balance = userToCheckInfo.balance + balanceToAdd;
        uint _investment = userToCheckInfo.investment;
        uint _dividends_paid = userToCheckInfo.dividends_paid + balanceToAdd;
        uint _referral_bonus_earned = userToCheckInfo.referral_bonus_earned;
        uint _withdrawn_amount = userToCheckInfo.withdrawn_amount;
        uint _last_withdraw_time = userToCheckInfo.last_withdraw_time;
        uint8[11] memory _referral_structure = userToCheckInfo.referral_structure;
        return (_balance, _investment, _dividends_paid, _referral_bonus_earned, _withdrawn_amount, _last_withdraw_time, _referral_structure);
    }

    function getUsersReferralsCount(address _userAddress) public view returns(uint8[11] memory referral_structure){
        // require(users[_userAddress].is_active == true, "No such user registered in BNBTop1!"); //Disabled based on frontend logic to allow user address query before investing
        UserStruct memory userToCheckInfo = users[_userAddress];
        uint8[11] memory _referral_structure = userToCheckInfo.referral_structure;
        return _referral_structure;
    }
    //END OF REPORTING FUNCTIONS
}

//STRUCTURES AND OTHER CODES
struct AdminStruct{
    string name;
    address payAddress;
    uint256 payPercentage;
}

struct UserStruct{
    bool is_active; //For checking if registered on reinvestment
    address self_address;
    uint balance;
    address sponsor;
    uint investment;
    uint dividends_paid;
    uint last_dividend_time;
    uint referral_bonus_earned;
    uint withdrawn_amount;
    uint last_withdraw_time;
    uint week_limit_count;
    uint week_limit_count_time;
    uint8[11] referral_structure;
}
//END OF STRUCTURES AND OTHER CODES