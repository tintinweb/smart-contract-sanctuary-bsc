//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./SafeMath.sol";

abstract contract TronAbstract is ReentrancyGuard, Ownable {

uint256 _decimals = 0;

struct Plan{
    uint256 HelpAmount;
    uint256 HelpAdminAmount;
    uint256 TotalHelpAmount;
    uint256 TotalHelpCount;
    uint256 WithdrawDeduction;
    bool Concluded;
    PH[] HelpHash;
}  
struct PH{
    address HelpAddress;
    uint256 dateAt;
    address gotHelp1;
    address gotHelp2;
}

mapping(uint256=>Plan) public plans;

mapping(address=> string) public registeredUser;

mapping(address=> mapping(uint256 => uint256[])) public helpLists;

address public adminAddress;
uint256 internal planLimit = 4;

constructor(address _adminAddress)  {
    
        adminAddress=_adminAddress;
       
        plans[0].HelpAmount = 500 * 10 ** _decimals  ;
        plans[0].HelpAdminAmount = 100 * 10 ** _decimals;
        plans[0].TotalHelpAmount=0;
        plans[0].TotalHelpCount=0;
        plans[0].HelpHash.push();
        plans[0].HelpHash[0].HelpAddress=adminAddress;
        helpLists[adminAddress][0].push(0);
     
        plans[1].HelpAmount = 1000 * 10 ** _decimals;
        plans[1].HelpAdminAmount = 200 * 10 ** _decimals;
        plans[1].TotalHelpAmount=0;
        plans[1].TotalHelpCount=0;
        plans[1].HelpHash.push();
        plans[1].HelpHash[0].HelpAddress=adminAddress;
        helpLists[adminAddress][1].push(0);

        plans[2].HelpAmount = 2500 * 10 ** _decimals;
        plans[2].HelpAdminAmount = 500 * 10 ** _decimals;
        plans[2].TotalHelpAmount=0;
        plans[2].TotalHelpCount=0;
        plans[2].HelpHash.push();
        plans[2].HelpHash[0].HelpAddress=adminAddress;
        helpLists[adminAddress][2].push(0);
       
        plans[3].HelpAmount = 5000 * 10 ** _decimals;
        plans[3].HelpAdminAmount = 1000 * 10 ** _decimals;
        plans[3].TotalHelpAmount=0;
        plans[3].TotalHelpCount=0;
        plans[3].HelpHash.push();
        plans[3].HelpHash[0].HelpAddress=adminAddress;
        helpLists[adminAddress][3].push(0);
       
    }
    


    function Donation(uint256 _planId) public payable virtual;

    
    function gettotalhelpamount(uint256 _planId,address _address) public view returns(uint256){
        uint256[] memory _phList = helpLists[_address][_planId];
        if(_phList.length == 0){
        return 0;
        }
        else{
        return plans[_planId].HelpAmount * _phList.length;
        }
    }  

    function ProvideHelpAddress(uint256 _planId) public view returns(address){
        require(_planId < planLimit, "Plan is not available");
        uint256 donationLength = plans[_planId].TotalHelpCount;
        return plans[_planId].HelpHash[donationLength / 2].HelpAddress;
    }

    function ProvideHelpIndex(uint256 _planId) public view returns(uint256){
        require(_planId < planLimit, "Plan is not available");
        uint256 donationLength = plans[_planId].HelpHash.length;
        return donationLength / 2;
    }

    function setWithdrwalDeduction(uint256 _planId,uint256 _percentage) public onlyOwner {
        require(_planId < planLimit, "Plan is not available");
        plans[_planId].WithdrawDeduction=_percentage;
    }

    function setTerminatePlan(uint256 _planId) public onlyOwner{
        require(_planId < planLimit, "Plan is not available");
        plans[_planId].Concluded=true;
    }

    function gethelpHash(uint256 _planId,uint256 _index) public view returns (PH memory){
        require(_planId < planLimit, "Plan is not available" );
        require(plans[_planId].TotalHelpCount != 0, " Help Not Started !!" );
        require(_index < plans[_planId].TotalHelpCount, "Invalid Index !!" );
    
        PH memory activePH = plans[_planId].HelpHash[_index];
        return activePH;
    
    }

    function getHelpAddress(uint256 _planId, uint256 _index) public view returns (address ,address) {
        
        require(_index < plans[_planId].HelpHash.length, " Invalid Index !!");
        return ((plans[_planId].HelpHash[_index].gotHelp1),address( plans[_planId].HelpHash[_index].gotHelp2));
    }

    function getActiveHelp(uint256 _planId, address _address) public view returns (address,address){
        
        require(_address != address(0),"Address zero can not be active");
        uint256[] memory _phList = helpLists[_address][_planId];
        
        if(plans[_planId].TotalHelpCount == 0) return (address(0),address(0));
        
        uint256  activeIndex = _phList[_phList.length-1];
        address  a1 = plans[_planId].HelpHash[activeIndex].gotHelp1;
        address  a2 = plans[_planId].HelpHash[activeIndex].gotHelp2;

        return (a1,a2);
    }

    function getHelpHistory(uint256 _planId, address _address) public view returns(address[2][] memory,uint[] memory){
        require(_address != address(0),"Address zero can not be receiver");
        require( plans[_planId].TotalHelpCount != 0, " Help Not Started !!" );
        uint256[] memory _phList = helpLists[_address][_planId];
        require(_phList.length > 0,"No history found on This plan "  );
        
        address[2][] memory activelist= new address[2][](_phList.length);
        for(uint256 i=0; i<_phList.length; i++){
        //   activelist[i] = new address[](_phList.length);
        activelist[i][0]= plans[_planId].HelpHash[_phList[i]].gotHelp1;
        activelist[i][1]= plans[_planId].HelpHash[_phList[i]].gotHelp2;
        }
        return (activelist,_phList);
    }


    function isActive(address _address,uint256 _planId) public view returns(bool){
        require(_address != address(0),"Address zero can not be active");
        uint256[] memory _phList = helpLists[_address][_planId];
        
        if(_phList.length==0) return (false);
        
        uint256  activeIndex = _phList[_phList.length-1];
        address  a1 = plans[_planId].HelpHash[activeIndex].gotHelp1;
        address  a2 = plans[_planId].HelpHash[activeIndex].gotHelp2;
    
        return (a1== address(0) || a2 == address(0));
    
    }
    

    }

    contract TronExpert is TronAbstract{
        
        using SafeMath for uint256;
        uint256 MAXRLIMIT=100000;

        struct Referral {
            address referrer;
            address[] referees;
            mapping(address => uint256[][4]) referralHelps;    //address -> [][]plan  count
            uint256[] referralClaimes;                                               //used Referral referral income
            uint256[][3][4] referralEarnings;                          // plan ->level -> index;
        }
        
        mapping(uint256 => uint256) public referralLevelPercentage;
        mapping(address => Referral) public referrals; 
        uint256 referralLevels = 3;
        
        constructor(address _adminAddress) TronAbstract(_adminAddress)  {
            referralLevelPercentage[0] = 15;
            referralLevelPercentage[1] = 3;
            referralLevelPercentage[2] = 2;
        }
    // Function to receive Ether. msg.data must be empty
        receive() external payable {}

        // Fallback function is called when msg.data is not empty
        fallback() external payable {}

        // function deposit(uint256 amount) public payable {
        //     require(msg.value >= amount,"Deposit Not equal to demanded");
        // }
        function registerUser(address  _userAddress,string memory _userId) public {
            require(_userAddress != address(0),"Address zero can not be registered!!");
            registeredUser[_userAddress]=_userId;
        }

        function isSubscribe(address _user) public view returns (bool){

        return isActive(_user,0) && isActive(_user,1) && isActive(_user,2) && isActive(_user,3);

        }

    function balanceOf(address _address) public view returns(uint256){
        return _address.balance;
    }

    function referralDonation(uint256 _planId, address _referrer) public payable {
        require(_planId < planLimit, "Sorry, Help Plan not found!!");       
        require(_referrer!=msg.sender, "You can't refer yourself");
        require(!isActive(msg.sender,_planId),"You are already active in this plan");
        
        if(referrals[msg.sender].referrer == address(0)) {
            referrals[msg.sender].referrer = _referrer;
            referrals[_referrer].referees.push(msg.sender);
        }
        Plan storage plan = plans[_planId];
        require( !plan.Concluded, "Plan has ended for this Help pool");
        
        address _ghAddress = ProvideHelpAddress(_planId);

        uint256 index = ProvideHelpIndex(_planId);
        
       // uint256 initalContractBalance = address(this).balance;
        // deposit(plan.HelpAmount + plan.HelpAdminAmount); 
       // uint256 finalContractBalance = address(this).balance;
       // require(finalContractBalance- initalContractBalance >= plan.HelpAmount," Invalied Plan Help Amount !!"  );
        (bool sent,) = _ghAddress.call{value: plans[_planId].HelpAmount }("");
            require(sent, "Failed to send TRX");
        

        if(plan.HelpHash[index].gotHelp1 == address(0)){
            plan.HelpHash[index].gotHelp1= msg.sender;
        }
        else{
            plan.HelpHash[index].gotHelp2= msg.sender;
        }

        
        PH storage help = plans[_planId].HelpHash.push();
        help.HelpAddress = msg.sender;
        help.dateAt = block.timestamp;
        plan.TotalHelpCount += 1;
        plan.TotalHelpAmount += plan.HelpAmount;
         
        helpLists[msg.sender][_planId].push(plan.HelpHash.length - 1);
        
        if(referrals[msg.sender].referrer != address(0)) {
            address _referrerr = referrals[msg.sender].referrer;
            // if(referrals[_referrerr].referralHelps[msg.sender].length == 0){
            // referrals[_referrerr].referralHelps[msg.sender].push();
            // referrals[_referrerr].referralHelps[msg.sender].push();
            // referrals[_referrerr].referralHelps[msg.sender].push();
            // referrals[_referrerr].referralHelps[msg.sender].push();
            // }
            referrals[_referrerr].referralHelps[msg.sender][_planId].push(plan.HelpHash.length - 1);
            
            for(uint256 level = 0; level < referralLevels; level++){
                referrals[_referrerr].referralEarnings[_planId][level].push(plan.HelpHash.length - 1);
                _referrerr = referrals[_referrerr].referrer;
                if(referrals[msg.sender].referrer != address(0)){
                    break;
                }
            }
        }
    }
    
    function Donation(uint256 _planId) public payable override {
        
        require(_planId < planLimit, "Sorry, Help Plan not found!!");
        require(!isActive(msg.sender,_planId),"You are already active in this plan");
        
        Plan storage plan = plans[_planId];
        require( !plan.Concluded, "Plan has ended for this Help pool");
        
        address _ghAddress = ProvideHelpAddress(_planId);
        
        uint256 index = ProvideHelpIndex(_planId);
       // uint256 initalContractBalance = address(this).balance;
       // deposit(plan.HelpAmount + plan.HelpAdminAmount); 
       // uint256 finalContractBalance = address(this).balance;
       // require(finalContractBalance - initalContractBalance >= plan.HelpAmount," Invalied Plan Help Amount !!"  );
        (bool sent,) = _ghAddress.call{value: plans[_planId].HelpAmount }("");
            require(sent, "Failed to send TRX");

        if(plan.HelpHash[index].gotHelp1 == address(0)){
            plan.HelpHash[index].gotHelp1= msg.sender;
        }
        else{
            plan.HelpHash[index].gotHelp2= msg.sender;
        }
       
        PH storage help = plans[_planId].HelpHash.push();
        help.HelpAddress = msg.sender;
        help.dateAt = block.timestamp;
        plan.TotalHelpCount += 1;
        plan.TotalHelpAmount += plan.HelpAmount;
         
        helpLists[msg.sender][_planId].push(plan.HelpHash.length - 1);
        
        // if(referrals[_phAddress].referrer != address(0)) {
        //     address _referrer = referrals[_phAddress].referrer;
        //     referrals[_referrer].referralHelps[_phAddress][_planId].push(plan.HelpHash.length - 1);
            
        //     for(uint256 level =0; level < referralLevels; level++){
        //         referrals[_referrer].referralEarnings[_planId][level].push(plan.HelpHash.length - 1);
        //         _referrer = referrals[_referrer].referrer;
        //         if(referrals[_phAddress].referrer != address(0)){
        //             break;
        //         }
        //     }
        // }
        
        // if(referrals[msg.sender].referrer != address(0)) {
        //     address _referrer = referrals[msg.sender].referrer;
        //     referrals[_referrer].referralHelps[msg.sender][_planId].push(plan.HelpHash.length - 1);
        //     for(uint256 level =0; level < referralLevels; level++){
        //         referrals[_referrer].referralEarnings[_planId][level].push(plan.HelpHash.length - 1);
        //         _referrer = referrals[_referrer].referrer;
        //         if(referrals[msg.sender].referrer != address(0)){
        //             break;
        //         }
        //     }
        // }
    }

    function transferfundtoadmin(uint256 weiAmount) external {
        require(address(this).balance >= weiAmount, "insufficient balance");
        (bool sent,) = adminAddress.call{value: weiAmount }("");
        require(sent, "Failed to send TRX");
    }
    
    
    function getReferees(address _account) public view returns (address[] memory) {
        return referrals[_account].referees;
    }
    
    function getRefereelEarning(address _account)public view returns (uint256) {
        uint256 _tolalEarned=0;
       for(uint256 _plan=0; _plan < planLimit; _plan++){
            for(uint256 _level =0; _level < referralLevels; _level++){
                 
               _tolalEarned += referrals[_account].referralEarnings[_plan][_level].length * plans[_plan].HelpAmount * referralLevelPercentage[_level] / 100;
                 
            }
       }
        return _tolalEarned;
    }
    
    function getReferralClaims(address _account) public view returns (uint256 ){
        uint256 claim =0;
        if(referrals[_account].referralClaimes.length>0)
            for(uint256 i;i<referrals[_account].referralClaimes.length;i++){
                claim +=referrals[_account].referralClaimes[i];
            }
        return claim;
    }
    
    function getReferralBalance(address _account) public view returns (uint256 ) {
        require(_account!= address(0),"Account Does Not Exist or !! ");
        uint256 _refbalance = getRefereelEarning(_account) - getReferralClaims(_account);
        return _refbalance;
    }
    
    function getRefereelEarningData(address _account) public view returns (uint256[][3][4] memory){
            uint256[][3][4] memory _re= referrals[_account].referralEarnings;
            return  _re;
    }
    
    function getReferralEarningsData(address _account) public view returns (
        address[] memory, 
        uint256[] memory, 
        uint256[][4][] memory
    ) {
        return getLevelReferralEarningsData(_account, 0);         
    }
    function getLevelReferralEarningsData(address _referrer, uint256 _level) public view returns(
        address[] memory, 
        uint256[] memory,
        uint256[][4][] memory
    ) {
        address[] memory _referees;
        uint256[] memory _levels;
        uint256[][4][] memory _referralDonations;
         
        if(_level < referralLevels && _referrer != address(0)) {
            (_referees, _levels, _referralDonations) = getSingleLevelReferralEarningsData(_referrer, _level);
            address[] memory _nextReferees;
            uint256[] memory _nextLevels;
            uint256[][4][] memory _nextReferralDonations;
            uint256 count = MAXRLIMIT <= _referees.length ? MAXRLIMIT : _referees.length;
            for(uint256 i = 0; i < count; i++) {
                (_nextReferees, _nextLevels, _nextReferralDonations) = getLevelReferralEarningsData(_referees[i], _level + 1);
                _referees = concatenateAddresses(_referees, _nextReferees);
                _levels = concatenateIntegers(_levels, _nextLevels);
                _referralDonations = concatenateReferralDonations(_referralDonations, _nextReferralDonations);   
            }
        }
        return (_referees, _levels, _referralDonations);    
    }
    function getSingleLevelReferralEarningsData(address _referrer, uint256 _level) public view returns(
        address[] memory, 
        uint256[] memory,
        uint256[][4][] memory
    ) {      
        address[] memory _referees ;
        uint256[] memory _levels;
        uint256[][4][] memory _referralHelps;
        if(_referrer==address(0)||_level>=3)
        {
            return (_referees, _levels, _referralHelps);  
        }
            _referees = getReferees(_referrer);
        if(_referees.length != 0)
        {     
            _levels = new uint256[](_referees.length);
            _referralHelps = new uint256[][4][](_referees.length);
            uint256 count = MAXRLIMIT <= _referees.length ? MAXRLIMIT : _referees.length;
            for(uint256 i = 0; i < count; i++) {  
                _levels[i] = _level;
                _referralHelps[i] = referrals[_referrer].referralHelps[_referees[i]] ;
            }
        }
        return (_referees, _levels, _referralHelps);    
    }

    function concatenateReferralDonations(uint256[][4][] memory a1, uint256[][4][] memory a2) internal pure returns(uint256[][4][] memory) {
        
        uint256[][4][] memory returnArr = new uint256[][4][](a1.length + a2.length);

        uint256 i = 0;
        for (; i < a1.length; i++) {
            returnArr[i] = a1[i];
        }

        for (uint256 j = 0; j < a2.length; j++) {
            returnArr[i++] = a2[j];
        }

        return returnArr;
    } 
   

    function concatenateIntegers(uint256[] memory a1, uint256[] memory a2) internal pure returns(uint256[] memory) {
        uint256[] memory returnArr = new uint256[](a1.length + a2.length);

        uint256 i = 0;
        for (; i < a1.length; i++) {
            returnArr[i] = a1[i];
        }

        for (uint256 j = 0; j < a2.length; j++) {
            returnArr[i++] = a2[j];
        }

        return returnArr;
    }

    function concatenateAddresses(address[] memory a1, address[] memory a2) internal pure returns(address[] memory) {
        address[] memory returnArr = new address[](a1.length + a2.length);

        uint256 i = 0;
        for (; i < a1.length; i++) {
            returnArr[i] = a1[i];
        }

        for (uint256 j = 0; j < a2.length; j++) {
            returnArr[i++] = a2[j];
        }

        return returnArr;
    }

    function addressExists(address add, address[] memory array) internal pure returns (bool) {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == add) {
                return true;
            }
        }
        return false;
    }
}