/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

pragma solidity 0.5.10;

contract Dalchand {
    address payable public ownerWallet;
    using SafeMath for uint256; 
   
    struct UserStruct {
        bool isExist;
        uint id;
        uint binaryIncome;
        uint activeLevelPlanB;
        address payable upline;
        address[] referral;
        uint256 binaryIncomeLevelWise;
        mapping(uint => uint) partnersLevelWise;
        uint referrerID;
        uint planbactivatedround;
    }
  
     struct userInfo {
        uint id;
        uint referrerID;
        uint childCount;
        address userAddress;
        uint256 noofpayments;
        uint256 activeLevel;
    }
   
    

    uint REFERRER_1_LEVEL_LIMIT = 2;
    mapping(uint => uint) public LEVEL_PRICE;
    uint256 public LAST_LEVEL=4;
   
    mapping (address => uint256) public uplines;
    mapping (address => UserStruct) public users;

    
    mapping (uint => address payable) public userList;
    uint public currUserID = 0;
     
     /**************Plan B*************************/
    mapping(uint256=>mapping(uint256 => userInfo)) public userInfos;    
     
    mapping(uint256=>mapping(uint256 => address payable)) public userAddressByID;
     
    mapping(uint256=>uint256) public lastIDCount;
    mapping(uint256=>uint256) public lastFreeParent;
    mapping(address=>uint) public userActiveId;
    mapping(uint =>mapping(uint256=> uint)) public walletAmountPlanB;


    
    event regLevelEvent(address indexed _user,uint _userId,uint _referralID, address indexed _referrer, uint _time);
    event reentryLevelEvent(address indexed _user,uint _userId,uint _referralID, uint _time);
    
    event buyLevelEvent(address indexed _user, uint _level, uint _time,uint _amount,uint _roundid);
    event paidForLevelEv(address indexed _user, address indexed _referral, uint _level, uint _amount, uint _time);
    event binaryData(address indexed _user,uint _userId,uint _referralID,uint _level,address referralAddress,uint _roundid);
    event netProfit(address indexed user,uint level,uint256 amount);
    
    constructor(address payable ownerAddress) public {
        ownerWallet = ownerAddress;
        LEVEL_PRICE[1] =0.001 ether;
        LEVEL_PRICE[2] =0.003 ether;
        LEVEL_PRICE[3] = 0.009 ether;
        LEVEL_PRICE[4] = 0.027 ether;
        

        userList[currUserID] = ownerWallet;
        
        userInfo memory UserInfo;
        
        UserInfo = userInfo({
            id: 1,
            referrerID: 0,
            childCount: 0,
            userAddress: ownerWallet,
            noofpayments:0,
            activeLevel:8
        });

        userInfos[1][1] = UserInfo;
        lastIDCount[1]=1;
        lastFreeParent[1]=1;
        userAddressByID[1][1]=ownerWallet;
        

       
    }

    function () external payable {
        // uint level;

        // if(msg.value == LEVEL_PRICE[1])       level = 1;
        // else revert('Incorrect Value send');

        //     address  referrer = bytesToAddress(msg.data);

        //     registration(payable(referrer)s);
    }

    
    
    /*************PLAN B ********************/
    
    function registration(address payable refAddress)public payable{
        require(msg.value==LEVEL_PRICE[1],"Invalid amount");
        require(users[refAddress].isExist, 'Incorrect referrer Id');
        require(!users[msg.sender].isExist, 'Incorrect referrer Id');
        users[msg.sender].upline = refAddress;
        users[msg.sender].isExist = true;
        regUser(msg.sender);
    }
   
    
       function regUser(address payable userAddress) internal{
          
            users[userAddress].planbactivatedround++;
            uint _roundid=users[userAddress].planbactivatedround;
       
        
        if(userInfos[_roundid][lastFreeParent[_roundid]].childCount >= REFERRER_1_LEVEL_LIMIT) lastFreeParent[_roundid]++;

        userInfo memory UserInfo;
        lastIDCount[_roundid]++;

        UserInfo = userInfo({
            id: lastIDCount[_roundid],
            referrerID: lastFreeParent[_roundid],
            childCount: 0,
            userAddress:userAddress,
            noofpayments:0,
            activeLevel:6
        });

        userInfos[_roundid][lastIDCount[_roundid]] = UserInfo;
        userInfos[_roundid][lastFreeParent[_roundid]].childCount++;
        userAddressByID[_roundid][lastIDCount[_roundid]] = userAddress;
        users[userAddress].activeLevelPlanB=6;
        userActiveId[userAddress]=lastIDCount[_roundid];
               
        emit buyLevelEvent(userAddress, 6, now,LEVEL_PRICE[6],_roundid);
        
        emit binaryData(userAddress,lastIDCount[_roundid],lastFreeParent[_roundid],6,userAddressByID[_roundid][lastFreeParent[_roundid]],_roundid);
      
        distributeBonus(lastIDCount[_roundid],6,_roundid);
        
    }
    
   
    
    function _buyLevel(uint _level, uint user,uint _roundid) internal returns(bool)
    {
       
        address payable useradd=userAddressByID[_roundid][user];
       uint256 refcommission=LEVEL_PRICE[_level].mul(5).div(100);
        users[useradd].upline.transfer(refcommission);
        emit buyLevelEvent(useradd, _level, now,LEVEL_PRICE[_level],_roundid);
        distributeBonus(user,_level,_roundid);
       users[useradd].activeLevelPlanB=_level;
       userInfos[_roundid][user].activeLevel=_level;
      
        return true;
    }
    
    function distributeBonus(uint _addr,uint _level,uint _roundid) internal {
        uint up =    userInfos[_roundid][_addr].referrerID;
        uint up2 =  userInfos[_roundid][up].referrerID;
     
        userInfos[_roundid][up].noofpayments++;
        userInfos[_roundid][up2].noofpayments++;

        paymentForUp1(up,_level,_roundid);
        paymentForUp2(up2,_level,_roundid);
    }

    function paymentForUp1(uint up,uint _level,uint _roundid) internal
    {
        address payable receiver=userAddressByID[_roundid][up];
        userInfos[_roundid][up].noofpayments++;
        if(userInfos[_roundid][up].noofpayments==1 || _level==LAST_LEVEL)
        {
            receiver.transfer(LEVEL_PRICE[_level]);
            //emit profit
            emit netProfit(receiver,_level,LEVEL_PRICE[_level]);

        }
        else
        {
            //emit hold
        }
    }

    function paymentForUp2(uint up2,uint _level,uint _roundid) internal
    {
        address payable receiver2=userAddressByID[_roundid][up2];
        userInfos[_roundid][up2].noofpayments++;
        if(userInfos[_roundid][up2].noofpayments==1 || _level==LAST_LEVEL)
        {
            if(_level==LAST_LEVEL && userInfos[_roundid][up2].noofpayments==4)
            {
                receiver2.transfer(LEVEL_PRICE[_level].sub(LEVEL_PRICE[1]));
                emit netProfit(receiver2,_level,LEVEL_PRICE[_level].sub(LEVEL_PRICE[1]));
                
                regUser(userAddressByID[_roundid][up2]);
                //emit profit
            }
            else{
                receiver2.transfer(LEVEL_PRICE[_level]);
                emit netProfit(receiver2,_level,LEVEL_PRICE[_level]);
            //emit profit
            }
        }
        else if(userInfos[_roundid][up2].noofpayments==4)
        {
            require(_buyLevel(userInfos[_roundid][up2].activeLevel + 1, up2,_roundid),"level upgrade fail"); 

        }
        else{
            //emit hold
        }
    }
    
    
    
    function balanceOfcontract() public view returns(uint256)
    {
        return address(this).balance;
    }
    
    
    function viewUserReferral(address _user) public view returns(address[] memory) {
        return users[_user].referral;
    }
    
    

     function viewUserLevelWiseBinaryIncome(address _user) public view returns(uint) {
        return users[_user].binaryIncomeLevelWise;
    }
    
     function Login(address _user) public view returns(uint) {
        if(users[_user].isExist){
        return 1;
        }
        else{
        return 0;
        }
    }
    
      function viewUserLevelWisePartners(address _user, uint _matrixLevel) public view returns(uint) {
        return users[_user].partnersLevelWise[_matrixLevel];
    }
    
      function  viewUserReferralId(address _user) public view returns(uint) {
          return users[_user].id;
    }
    
    
     function viewUserEarnedEather(address _user) public view returns(uint) {
        return (users[_user].binaryIncome);
    }
    
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}




library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b,"mul error");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0,"div error");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a,"sub error");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a,"add error");

        return c;
    }

}