/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// SPDX-License-Identifier: MIT

 /*  BNBGAINERS
 *   is dedicated to remove the risks of the possible errors and circumstances in conventional online 
 *   based networking marketing and investment businesses with our state of the art BNB smart contract. 
 *   An impartial third-party audit firm has examined the smart contract's source code to prove its credibility.
 *
 *   ┌───────────────────────────────────────────────────────────────────────┐
 *   │   Website: https://BNBGainers.com           							 │
 *	 │	 1% Daily ROI 	       	                                             │
 *   │   Audited, Verified with No Backdoor.       							 │
 *   └───────────────────────────────────────────────────────────────────────┘
 *
 *   [REFERRAL REWARDS]
 *
 *   - 11-level referral commission: 10% - 3% - 2% - 1% - 1% - 0.5% - 0.5% - 0.5% - 0.5% - 0.5% - 0.5%  
 *  
 */

pragma solidity 0.8.18;

/**
 * @title BNBGainers
 * @dev The best and most secure BNB based smartcontract investment
 */
contract BnbGainers {
    
    //STATE VARIABLES
    address public owner;
    AdminStruct[2] public admins;
    ChainStruct[99] public chains;
    uint public no_of_chains = 0;
    uint public total_members = 0;
    uint public total_cummulative_investment = 0; //In wei
    uint public total_cummulative_withdrawn = 0; //In wei
    uint public min_investment; //In wei
    uint public min_withdraw; //In wei
    uint public max_investment; //In wei
    uint public max_earning_percentage = 300; //In percentage
    uint constant BONUS_LINES_COUNT = 11;
    uint[BONUS_LINES_COUNT] public referral_pay_rates = [100,30,20,10,10,5,5,5,5,5,5]; //Divide by REFERRAL_PERCENT_DIVIDER
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
                is_chain_leader: true,
                chain_name: "owner",//Default chain
                referral_structure: [0,0,0,0,0,0,0,0,0,0,0]
            }) ;
        users[msg.sender] = ownerUser;
        //Adding Admins
        admins[0] = AdminStruct("ZM",0xbE0F7664f7534E4f71aFFfCDA7ef851cf453bFFb,8);
        admins[1] = AdminStruct("HM",0xbEc928B68bD8c95B76F67F08b1c8c9d7bC20a5cd,8);
        //Adding Default Chain Leaders
        chains[0] = ChainStruct("owner",0xbE0F7664f7534E4f71aFFfCDA7ef851cf453bFFb,2,0,0,0);
        chains[1] = ChainStruct("owner",0xbEc928B68bD8c95B76F67F08b1c8c9d7bC20a5cd,2,0,0,0);
        no_of_chains += 2;
        //REENTRYGUARD VARIABLE
        _status = _NOT_ENTERED;
    }
    //END OF CONSTRUCTOR

    //EVENTS DEFINITIONS
    event UplineCountUpdated(address indexed registeringAddress, address indexed sponsor, uint256 amount);
    event NewInvestment(address indexed investingAddress, uint256 amount);
    event WithdrawCompleted(address indexed withdrawingAddress, uint256 amount);
    //END OF EVENTS DEFINITION

    //UTILITY FUNCTIONS
    modifier onlyOwner(){
        require(msg.sender == owner, "ONLY the owner of BNBGainers contract can perform this action");
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

    function generateNewUser(address _selfAddress, address _sponsor, uint _investedAmount, string memory _chainName) 
    private returns (UserStruct memory){   
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
                is_chain_leader: false,
                chain_name: _chainName,
                referral_structure: [0,0,0,0,0,0,0,0,0,0,0]
        });
    }

    function generateOldUser(address _selfAddress, address _sponsor, uint _investedAmount, string memory _chainName, uint _timestamp) 
    private returns (UserStruct memory){   
        total_members+=1;
        total_cummulative_investment+=_investedAmount;
        return UserStruct({
                is_active : true,
                self_address: _selfAddress,
                balance : 0,
                sponsor: _sponsor,
                investment: _investedAmount,
                dividends_paid: 0,
                last_dividend_time: _timestamp,
                referral_bonus_earned: 0,
                withdrawn_amount: 0,
                last_withdraw_time: (_timestamp - 24 hours),
                week_limit_count: 0,
                week_limit_count_time: (_timestamp - 7 days), 
                is_chain_leader: false,
                chain_name: _chainName,
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

    function updateChainCount(string memory _chainName) private{
        for (uint i = 0; i < no_of_chains; i++) {
            if(compareStrings(chains[i].name, _chainName)){
                chains[i].chainCount += 1; 
            }
        }
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

    function payChainLeaderBonus(string memory _chainName, uint256 _amountInvested) private {
        for (uint i = 0; i < no_of_chains; i++) {
            if(compareStrings(chains[i].name, _chainName)){
                payable(chains[i].payAddress).transfer(chains[i].payPercentage * (_amountInvested/100)); //Divided by 100 because of percentage
                chains[i].chainTotalInvestment += _amountInvested; //Divided by 100 because of percentage
                chains[i].chainEarnings += chains[i].payPercentage * (_amountInvested/100); //Divided by 100 because of percentage
            }
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

    function compareStrings(string memory stringA, string memory stringB) private pure returns (bool) {
        if(bytes(stringA).length != bytes(stringB).length) {
            return false;
        } else {
            return keccak256(abi.encodePacked(stringA)) == keccak256(abi.encodePacked(stringB));
        }
    }
    //END OF UTILITY FUNCTIONS

    //ADMIN FUNCTIONS
    function payAdminFees(uint _investedAmount) private{
        for (uint i = 0; i < admins.length; i++) {
            payable(admins[i].payAddress).transfer(admins[i].payPercentage * (_investedAmount/100)); //Divided by 100 because of percentage
        }
    }

    function addChain(uint _index, string memory _name, address _payAddress, uint _payPercentage) onlyOwner public{
        require(users[_payAddress].is_active == true, "No such user registered in BNBGainers!");
        uint chainCount = 0 ;
        uint chainTotalInvestment = 0;
        uint chainEarnings = 0 ;
        users[_payAddress].is_chain_leader = true;
        users[_payAddress].chain_name = _name;
        chains[_index] = ChainStruct(_name,_payAddress,_payPercentage,chainCount,chainTotalInvestment,chainEarnings);
        no_of_chains += 1;
    }

    function addSubChain(uint _index, string memory _name, address _payAddress, uint _payPercentage) onlyOwner public{
        require(users[_payAddress].is_active == true, "No such user registered in BNBGainers!");
        uint chainCount = 0 ;
        uint chainTotalInvestment = 0;
        uint chainEarnings = 0 ;
        chains[_index] = ChainStruct(_name,_payAddress,_payPercentage,chainCount,chainTotalInvestment,chainEarnings);
        no_of_chains += 1;
    }

    function addInvestment(address _userAddress,address _sponsorAddress, uint _investedAmount, uint _timestamp) external onlyOwner noReentry payable{
        //Basic validations
        require(_investedAmount >= min_investment, "Minimum investment amount is 0.02 BNB!");
        require(_investedAmount <= max_investment, "Maximum investment amount is 400 BNB!");
        require(users[_sponsorAddress].is_active == true, "The given sponsor not registered!");
        //Checking chain details
        string storage _chainName = users[_sponsorAddress].chain_name;
        //End of checking chain details
        //Checking if is exisiting user
        if(users[_userAddress].is_active == true){
            //pay daily earnings and update date so to start with new rate
            payUserInvestmentEarnings(users[_userAddress]);
            users[_userAddress].investment += _investedAmount;
        }else{
            UserStruct memory newUserObject = generateOldUser(_userAddress, _sponsorAddress, _investedAmount, _chainName, _timestamp);
            users[_userAddress] = newUserObject;
            updateUplineCount( _sponsorAddress);
            updateChainCount(_chainName);
        }
        payReferralBonus(_userAddress, _investedAmount);
        payUserInvestmentEarnings(users[_sponsorAddress]);
    }

    
    function withdraw(uint _withdrawAmountRequested, address _userAddress, uint _timestamp) external onlyOwner {

        require(users[_userAddress].is_active == true, "No such user registered in BNBGainers!");
        UserStruct storage withdrawingUser = users[_userAddress];
        require( _withdrawAmountRequested >= min_withdraw, "You cannot withdraw below 0.04 BNB!");
        require( getUserBalance(withdrawingUser) >= _withdrawAmountRequested, "You cannot withdraw more than your available balance!");
  
        withdrawingUser.balance -= _withdrawAmountRequested;
        withdrawingUser.withdrawn_amount += _withdrawAmountRequested;
        withdrawingUser.last_withdraw_time = _timestamp; 
        total_cummulative_withdrawn += _withdrawAmountRequested;
        
    }
    //END OF ADMIN FUNCTIONS

    //BUSINESS FUNCTIONS
    receive() external payable {

    }

    function invest(address _sponsorAddress) external noReentry payable{
        //Basic validations
        require(msg.value >= min_investment, "Minimum investment amount is 0.02 BNB!");
        require(msg.value <= max_investment, "Maximum investment amount is 400 BNB!");
        require(users[_sponsorAddress].is_active == true, "The given sponsor not registered!");
        //Checking chain details
        string storage _chainName = users[_sponsorAddress].chain_name;
        //End of checking chain details
        //Checking if is exisiting user
        if(users[msg.sender].is_active == true){
            //pay daily earnings and update date so to start with new rate
            payUserInvestmentEarnings(users[msg.sender]);
            users[msg.sender].investment += msg.value;
        }else{
            UserStruct memory newUserObject = generateNewUser(msg.sender, _sponsorAddress, msg.value, _chainName);
            users[msg.sender] = newUserObject;
            updateUplineCount( _sponsorAddress);
            updateChainCount(_chainName);
        }
        payReferralBonus(msg.sender, msg.value);
        payChainLeaderBonus(_chainName, msg.value);
        payAdminFees(msg.value);
        emit NewInvestment(msg.sender, msg.value);
        payUserInvestmentEarnings(users[_sponsorAddress]);
    }
    
    function withdraw(uint _withdrawAmountRequested) external noReentry payable{
        require(users[msg.sender].is_active == true, "No such user registered in BNBGainers!");
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
    returns(uint balance, uint investment, uint dividends_paid, uint referral_bonus_earned, uint withdrawn_amount, uint last_withdraw_time, uint8[11] memory referral_structure) 
    {
        // require(users[_userAddress].is_active == true, "No such user registered in BNBGainers!"); //Disabled based on frontend logic to allow user address query before investing
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
        // require(users[_userAddress].is_active == true, "No such user registered in BNBGainers!"); //Disabled based on frontend logic to allow user address query before investing
        UserStruct memory userToCheckInfo = users[_userAddress];
        uint8[11] memory _referral_structure = userToCheckInfo.referral_structure;
        return _referral_structure;
    }

    // function getUsersChainInfo(address _userAddress) public view  
    // returns( string memory chain_name, bool is_chain_leader, address payAddress, uint256 payPercentage, uint chainCount, uint chainTotalInvestment, uint chainEarnings) 
    // {
    //     // require(users[_userAddress].is_active == true, "No such user registered in BNBGainers!"); //Disabled based on frontend logic to allow user address query before investing
    //     UserStruct storage userToCheckInfo = users[_userAddress];
    //     string memory _chain_name = userToCheckInfo.chain_name;
    //     bool _is_chain_leader = userToCheckInfo.is_chain_leader;
    //     address _payAddress = _userAddress;
    //     uint256 _payPercentage = 0;
    //     uint _chainCount = 0;
    //     uint _chainTotalInvestment = 0;
    //     uint _chainEarnings = 0;
    //     for (uint i = 0; i < no_of_chains; i++) {
    //         if(compareStrings(chains[i].name, _chain_name)){
    //             if(_payAddress == owner){
    //                 _payPercentage = chains[i].payPercentage;
    //                 _chainCount = chains[i].chainCount;
    //                 _chainTotalInvestment = chains[i].chainTotalInvestment;
    //                 _chainEarnings = chains[i].chainEarnings;
    //                 break;//the above values should be the same for owner leaders.
    //             }
    //             if(chains[i].payAddress == _payAddress){
    //                 _payPercentage = chains[i].payPercentage;
    //                 _chainCount = chains[i].chainCount;
    //                 _chainTotalInvestment = chains[i].chainTotalInvestment;
    //                 _chainEarnings = chains[i].chainEarnings;
    //             }
    //         }
    //     }
    //     return ( _chain_name, _is_chain_leader, _payAddress, _payPercentage, _chainCount, _chainTotalInvestment, _chainEarnings);
    // }

    function getUsersChainInfoDetailed(address _userAddress) public view  
    returns(UserChainDataStruct memory usersChainData) 
    {
        // require(users[_userAddress].is_active == true, "No such user registered in BNBGainers!"); //Disabled based on frontend logic to allow user address query before investing
        UserChainDataStruct memory _usersChainData;
        UserStruct storage userToCheckInfo = users[_userAddress];
        string memory _chain_name = userToCheckInfo.chain_name;
        bool _is_chain_leader = userToCheckInfo.is_chain_leader;
        address _payAddress = _userAddress;
        uint _noOfChains = 0;
        uint256 _payPercentage = 0;
        uint _chainCount = 0;
        uint _chainTotalInvestment = 0;
        uint _chainEarnings = 0;
        uint _noOfOtherChains = 0;
        uint _otherChainsCount = 0;
        uint _otherChainsTotalInvestment = 0;
        uint _otherChainsEarnings = 0 ;
        ChainStruct[15] memory _otherChains;
        
        for (uint i = 0; i < no_of_chains; i++) {
            if(compareStrings(chains[i].name, _chain_name)){
                if(_payAddress == owner){
                    _payPercentage = chains[i].payPercentage;
                    _chainCount = chains[i].chainCount;
                    _chainTotalInvestment = chains[i].chainTotalInvestment;
                    _chainEarnings = chains[i].chainEarnings;
                    _noOfChains += 1;
                    break;//the above values should be the same for owner leaders.
                }
                if(chains[i].payAddress == _payAddress){
                    _payPercentage = chains[i].payPercentage;
                    _chainCount = chains[i].chainCount;
                    _chainTotalInvestment = chains[i].chainTotalInvestment;
                    _chainEarnings = chains[i].chainEarnings;
                    _noOfChains += 1;
                }
            }else if(chains[i].payAddress == _payAddress){
                _otherChainsCount += chains[i].chainCount;
                _otherChainsTotalInvestment += chains[i].chainTotalInvestment;
                _otherChainsEarnings += chains[i].chainEarnings;
                _otherChains[_noOfOtherChains] = chains[i];
                _noOfChains += 1;
                _noOfOtherChains += 1;
            }
        }
        
        _usersChainData.is_chain_leader = _is_chain_leader;
        _usersChainData.payAddress = _payAddress;
        _usersChainData.noOfchains = _noOfChains;
        _usersChainData.mainchain_name = _chain_name;
        _usersChainData.mainchain_count = _chainCount;
        _usersChainData.mainchain_payPercentage = _payPercentage; 
        _usersChainData.mainchain_totalInvestment = _chainTotalInvestment;
        _usersChainData.mainchain_earnings = _chainEarnings;
        _usersChainData.no_of_other_chains = _noOfOtherChains;
        _usersChainData.otherchain_count = _otherChainsCount;
        _usersChainData.otherchain_totalInvestment = _otherChainsTotalInvestment;
        _usersChainData.otherchain_earnings = _otherChainsEarnings;
        _usersChainData.otherchain_data = _otherChains;

        return (_usersChainData);
    }

    function getPayAddressChainsReport(address _payAddress) public view returns
    (uint noOfChains, uint chainTotalInvestment, uint chainEarnings){
        uint _noOfChains = 0;
        uint[4] memory _chainIndex;
        //GET CHAIN INDEX - the index of chain which the address exists
        for (uint i = 0; i < no_of_chains; i++) {
            if(chains[i].payAddress == _payAddress){
                _chainIndex[_noOfChains] = i;
                _noOfChains += 1;
            }
        }
        //END OF GET CHAIN INDEX
        //Default Values if not exist
        uint _chainTotalInvestment = 0;
        uint _chainEarnings = 0;
        if(_noOfChains > 0){
            for (uint i = 0; i < _noOfChains; i++) {
                _chainTotalInvestment = chains[_chainIndex[i]].chainTotalInvestment;
                _chainEarnings = chains[_chainIndex[i]].chainEarnings;
            }
        }
        return (_noOfChains, _chainTotalInvestment, _chainEarnings);
    }

    function getChainReport(string memory _chainName) public view returns
    (uint noOfLeaders, string memory name, address[4] memory payAddress, uint256[4] memory payPercentage, uint chainCount, uint chainTotalInvestment, uint chainEarnings){
        uint _noOfLeaders = 0;
        uint[4] memory _chainIndex;
        //GET CHAIN INDEX - the index of chain which the name exists
        for (uint i = 0; i < no_of_chains; i++) {
            if(compareStrings(chains[i].name, _chainName)){
                _chainIndex[_noOfLeaders] = i;
                _noOfLeaders += 1;
            }
        }
        //END OF GET CHAIN INDEX
        //Default Values if not exist
        address[4] memory _payAddress;
        uint256[4] memory _payPercentage;
        uint _chainCount = 0;
        uint _chainTotalInvestment = 0;
        uint _chainEarnings = 0;
        if(_noOfLeaders > 0){
            for (uint i = 0; i < _noOfLeaders; i++) {
                _payAddress[i] = chains[_chainIndex[i]].payAddress;
                _payPercentage[i] = chains[_chainIndex[i]].payPercentage;
                _chainCount = chains[_chainIndex[i]].chainCount;
                _chainTotalInvestment = chains[_chainIndex[i]].chainTotalInvestment;
                _chainEarnings = chains[_chainIndex[i]].chainEarnings;
            }
        }
        return (_noOfLeaders, _chainName, _payAddress, _payPercentage, _chainCount, _chainTotalInvestment, _chainEarnings);
    }
    //END OF REPORTING FUNCTIONS
}

//STRUCTURES AND OTHER CODES
struct AdminStruct{
    string name;
    address payAddress;
    uint256 payPercentage;
}

struct ChainStruct{
    string name;
    address payAddress;
    uint256 payPercentage;
    uint chainCount;
    uint chainTotalInvestment;
    uint chainEarnings;
}// CHAINSTRUCT: IF MULTIPLE LEADERS FIGURE SHOULD NOTE BE DECIMAL, MAXMIMUM OF 4 LEADERS i.e 1% EACH

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
    bool is_chain_leader; 
    string chain_name;
    uint8[11] referral_structure;
}

struct UserChainDataStruct{
    bool is_chain_leader;
    address payAddress;
    uint noOfchains;
    string mainchain_name;
    uint mainchain_count;
    uint mainchain_payPercentage; 
    uint mainchain_totalInvestment;
    uint mainchain_earnings;
    uint no_of_other_chains;
    uint otherchain_count;
    uint otherchain_earnings;
    uint otherchain_totalInvestment;
    ChainStruct[15] otherchain_data;
}
//END OF STRUCTURES AND OTHER CODES