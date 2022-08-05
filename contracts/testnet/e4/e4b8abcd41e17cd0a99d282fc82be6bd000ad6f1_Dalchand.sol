/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

pragma solidity 0.5.10;

contract Dalchand {
    address payable public ownerWallet;
    using SafeMath for uint256; 
   
    struct UserStruct {
        bool isExist;
        uint id;
        uint binaryIncome;
        address payable upline;
        uint referrerID;
        uint planbactivatedround;
        uint256 activeLevel;
    }
  
     struct userInfo {
        uint id;
        uint referrerID;
        uint childCount;
        address userAddress;
        uint256 noofpayments;
    }

    struct depthRange{
        uint256 minId;
        uint256 maxId;
    }
   
    

    mapping(uint => uint) public LEVEL_PRICE;
    uint256 public LAST_LEVEL=4;
    mapping (address => UserStruct) public users;
    mapping (uint => address payable) public userList;
    uint public currUserID = 0;
    uint public activeDepth = 1;
    uint public minId=2;
    mapping(uint256=>mapping(uint256=>uint256)) public userIdsRowWise;
    uint256 public activeDynamicId = 0;
    uint256 public activeParentRowNo = 1;
    uint256 public activeChildRowNo = 2;

    uint256 public activeIdParent = 0;
    uint256 public activeChildId = 0;
     /**************Plan B*************************/
    mapping(uint256 => userInfo) public userInfos2x2;    
     mapping(uint256 => userInfo) public userInfos4x4;

    mapping(uint256 => address payable) public userAddressByID;
     
    uint256 public lastIDCount2x2;
    uint256 public lastIDCount4x4;
    uint256 public lastFreeParent2x2;
    mapping(uint =>mapping(uint256=> uint)) public walletAmountPlanB;
    
    event regLevelEvent(address indexed _user,uint _userId,uint _referralID, address indexed _referrer, uint _time);
    event reentryLevelEvent(address indexed _user,uint _userId,uint _referralID, uint _time);
    
    event buyLevelEvent(address indexed _user, uint _level, uint _time,uint _amount);
    event binaryData(address indexed _user,uint _userId,uint _referralID,uint _level,address referralAddress);
    event netProfit(address indexed user,uint level,uint256 amount);
    event Hold(address indexed user,uint level,uint256 amount);

    constructor(address payable ownerAddress) public {
        ownerWallet = ownerAddress;
        LEVEL_PRICE[1] =0.0001 ether;
        LEVEL_PRICE[2] =0.0001 ether;
        LEVEL_PRICE[3] = 0.0003 ether;
        LEVEL_PRICE[4] = 0.0003 ether;
        LEVEL_PRICE[5] = 0.0009 ether;
        LEVEL_PRICE[6] = 0.0009 ether;        
        LEVEL_PRICE[7] = 0.0012 ether;
        LEVEL_PRICE[8] = 0.0012 ether; 

        userList[currUserID] = ownerWallet;
        
        userInfo memory UserInfo;
        
        UserInfo = userInfo({
            id: 1,
            referrerID: 0,
            childCount: 0,
            userAddress: ownerWallet,
            noofpayments:0
        });

        userInfos2x2[1] = UserInfo;
        lastIDCount2x2=1;
        lastIDCount4x4 = 0;
        lastFreeParent2x2=1;
        userAddressByID[1]=ownerWallet;
        users[ownerWallet].isExist = true;
        // users[ownerWallet].upline = ownerWallet;
        userIdsRowWise[1][0]=2;
        userIdsRowWise[1][1]=3;
        userIdsRowWise[1][2]=4;
        userIdsRowWise[1][3]=5;
       
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
        require(!users[msg.sender].isExist, 'Allready registered');
        users[msg.sender].upline = refAddress;
        users[msg.sender].isExist = true;
        regUser(msg.sender);
    }
   
    
       function regUser(address payable userAddress) internal{        
        if(userInfos2x2[lastFreeParent2x2].childCount >= 2) lastFreeParent2x2++;

        userInfo memory UserInfo;
        lastIDCount2x2++;

        UserInfo = userInfo({
            id: lastIDCount2x2,
            referrerID: lastFreeParent2x2,
            childCount: 0,
            userAddress:userAddress,
            noofpayments:0
        });

        userInfos2x2[lastIDCount2x2] = UserInfo;
        userInfos2x2[lastFreeParent2x2].childCount++;
        userAddressByID[lastIDCount2x2] = userAddress;
        users[userAddress].activeLevel=1;
        emit buyLevelEvent(userAddress, 1, now,LEVEL_PRICE[1]);
        
        emit binaryData(userAddress,lastIDCount2x2,lastFreeParent2x2,1,userAddressByID[lastFreeParent2x2]);
      
        distributeBonus(lastIDCount2x2,1);
        
    }
    
   
    
    function _buyLevel(uint _level, uint user) internal returns(bool)
    {
       
        address payable useradd=userAddressByID[user];
        emit buyLevelEvent(useradd, _level, now,LEVEL_PRICE[_level]);
        distributeBonus(user,_level);
        users[useradd].activeLevel=_level;
        userInfos2x2[user].noofpayments = 0;
        userInfos2x2[user].referrerID = userInfos2x2[user].referrerID;
        return true;
    }
    
    function distributeBonus(uint _addr,uint _level) internal {
        uint up =    userInfos2x2[_addr].referrerID;
        
        paymentForUp1(up,_level);
    }

    function paymentForUp1(uint up,uint _level) internal
    {
        address payable receiver=userAddressByID[up];
        userInfos2x2[up].noofpayments++;
        if(userInfos2x2[up].noofpayments==1 || _level==LAST_LEVEL)
        {
            receiver.transfer(LEVEL_PRICE[_level]);
            //emit profit
            emit netProfit(receiver,_level,LEVEL_PRICE[_level]);
        }
        else
        {
            if(_level==1){
            _buyLevel4x4(receiver);
            }
            else{
                _upgradeLevel4x4(_level+1,up);
            }
        }
    }


    function _buyLevel4x4(address payable userAddress)public{
         lastIDCount4x4++;
          uint256 lastFreeParent4x4 = getReferral();

        userInfo memory UserInfo;
       
        UserInfo = userInfo({
            id: lastIDCount4x4,
            referrerID: lastFreeParent4x4,
            childCount: 0,
            userAddress:userAddress,
            noofpayments:0
        });

        userInfos4x4[lastIDCount4x4] = UserInfo;
        userInfos4x4[lastFreeParent4x4].childCount++;
        users[userAddress].activeLevel=2;
        emit buyLevelEvent(userAddress, 2, now,LEVEL_PRICE[1]);
        
        emit binaryData(userAddress,lastIDCount4x4,lastFreeParent4x4,2,userAddressByID[lastFreeParent4x4]);
      
        // distributeBonus4x4(lastIDCount4x4,2);
        if(lastIDCount4x4>=6){
            userIdsRowWise[activeChildRowNo][activeChildId] = lastIDCount4x4;
            activeChildId++;
        }
    }

    function getReferral() internal returns(uint256)
    {
        if(lastIDCount4x4==1)
        {
            return 0;
        }
        if(lastIDCount4x4<=
        5)
        {
            return 1;
        }
        else
        {
            if(lastIDCount4x4==6)
            {
                activeChildId=0;
            }
            if(lastIDCount4x4==(minId)+(4**(activeParentRowNo))+(4**(activeChildRowNo)))
            {
                minId = (minId)+(4**(activeParentRowNo));
                activeParentRowNo++;
                activeChildRowNo++;
                activeChildId = 0;
                return userIdsRowWise[activeParentRowNo][minId];
            }
            else {
                uint256 index = ((lastIDCount4x4 - minId)%(4**activeParentRowNo))*(4**(activeParentRowNo-1));
                return minId+index;
            }
        }
    }


    function getReferralId(uint256 lastIDCount4x4,uint256 minId,uint256 activeDepth) external view returns(uint256)
    {
        return (minId)+(4**(activeParentRowNo))+(4**(activeChildRowNo));
    }

    
    
    function _upgradeLevel4x4(uint _level, uint user) internal returns(bool)
    {
        address payable useradd=userAddressByID[user];
        emit buyLevelEvent(useradd, _level, now,LEVEL_PRICE[_level]);
        distributeBonus4x4(user,_level);
        users[useradd].activeLevel=_level;
        userInfos4x4[user].noofpayments = 0;
        userInfos4x4[user].referrerID = userInfos4x4[user].referrerID;
        return true;
    }

    function distributeBonus4x4(uint _addr,uint _level) internal {
        uint up2 =  userInfos4x4[_addr].referrerID;
        paymentForUp2(up2,_level);
    }

    function paymentForUp2(uint up2,uint _level) internal
    {
        address payable receiver2=userAddressByID[up2];
        if(receiver2==address(0)){
            ownerWallet.transfer(LEVEL_PRICE[_level]);
        }
        else{
        userInfos4x4[up2].noofpayments++;
        if(userInfos4x4[up2].noofpayments==1 || _level==LAST_LEVEL)
        {
            if(_level==LAST_LEVEL && userInfos4x4[up2].noofpayments==4)
            {
                receiver2.transfer(LEVEL_PRICE[_level].sub(LEVEL_PRICE[1]));
                emit netProfit(receiver2,_level,LEVEL_PRICE[_level].sub(LEVEL_PRICE[1]));
                
                regUser(userAddressByID[up2]);
                //emit profit
            }
            else{
                receiver2.transfer(LEVEL_PRICE[_level]);
                emit netProfit(receiver2,_level,LEVEL_PRICE[_level]);
            //emit profit
            }
        }
        else if(userInfos4x4[up2].noofpayments==4)
        {
             emit Hold(receiver2,_level,LEVEL_PRICE[_level]);
            require(_buyLevel(users[receiver2].activeLevel + 1, up2),"level upgrade fail"); 

        }
        else{
             emit Hold(receiver2,_level,LEVEL_PRICE[_level]);
            //emit hold
        }
        }
    }
    
    
    
    function balanceOfcontract() public view returns(uint256)
    {
        return address(this).balance;
    }
    
     function Login(address _user) public view returns(uint) {
        if(users[_user].isExist){
        return 1;
        }
        else{
        return 0;
        }
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