/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface IERC20 
{
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract GiveAndTake {
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
    uint256 public LAST_LEVEL=8;
    mapping (address => UserStruct) public users;
    IERC20 busd;

    uint256 public activeIdParent = 0;
    uint256 public activeChildId = 0;
     /**************Plan B*************************/
    mapping(uint256 => userInfo) public userInfos2x2;    
     mapping(uint256 => userInfo) public userInfos4x4;

    mapping(uint256 => address payable) public userAddressByID;
     
    uint256 public lastIDCount2x2;
    uint256 public lastIDCount4x4;
    uint256 public lastFreeParent2x2;
    uint256 public lastFreeParent4x4;
    
    event regLevelEvent(address indexed user,uint userId,uint referralID, address indexed referrer, uint time);
    event reentryLevelEvent(address indexed user,uint userId,uint referralID, uint time);
    
    event buyLevelEvent(address indexed user, uint level, uint time,uint amount);
    event binaryData(address indexed user,uint userId,uint referralID,uint level,address referralAddress);
    event netProfit(address indexed user,uint level,uint256 amount,uint256 _addr);
    event Hold(address indexed user,uint level,uint256 amount);

    constructor(address payable ownerAddress) {

        busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

        ownerWallet = ownerAddress;
        LEVEL_PRICE[1] =10 ether;
        LEVEL_PRICE[2] =10 ether;
        LEVEL_PRICE[3] = 20 ether;
        LEVEL_PRICE[4] = 20 ether;
        LEVEL_PRICE[5] = 40 ether;
        LEVEL_PRICE[6] = 40 ether;        
        LEVEL_PRICE[7] = 80 ether;
        LEVEL_PRICE[8] = 80 ether; 

        
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
        
       
        emit regLevelEvent(ownerWallet,1,0, address(0), block.timestamp);
    }

    
    
    /*************PLAN B ********************/
    
    function registration(address payable refAddress)public payable{
        busd.transferFrom(msg.sender, address(this), LEVEL_PRICE[1]);
        require(users[refAddress].isExist, 'Incorrect referrer Id');
        require(!users[msg.sender].isExist, 'Allready registered');
        users[msg.sender].upline = refAddress;
        users[msg.sender].isExist = true;
        regUser(payable(msg.sender),refAddress);
        
    }
   
    
       function regUser(address payable userAddress,address refAddress) internal{        
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
        emit buyLevelEvent(userAddress, 1, block.timestamp,LEVEL_PRICE[1]);
        
        emit binaryData(userAddress,lastIDCount2x2,lastFreeParent2x2,1,userAddressByID[lastFreeParent2x2]);
        emit regLevelEvent(userAddress,lastIDCount2x2,lastFreeParent2x2, refAddress, block.timestamp);
        distributeBonus(lastIDCount2x2,1);
    }
    
   
    
    function _buyLevel(uint _level, uint user) internal returns(bool)
    {
       
        address payable useradd=userAddressByID[user];
        emit buyLevelEvent(useradd, _level, block.timestamp,LEVEL_PRICE[_level]);
        distributeBonus(user,_level);
        users[useradd].activeLevel=_level;
        userInfos2x2[user].noofpayments = 0;
        userInfos2x2[user].referrerID = userInfos2x2[user].referrerID;
        return true;
    }
    
    function distributeBonus(uint _addr,uint _level) internal {
        uint up =    userInfos2x2[_addr].referrerID;
        
        paymentForUp1(up,_level,_addr);
    }

    function paymentForUp1(uint up,uint _level,uint _addr) internal
    {
        address payable receiver=userAddressByID[up];
        if(receiver==address(0)){
            busd.transfer(ownerWallet,LEVEL_PRICE[_level]);
        }
        else
        {
            userInfos2x2[up].noofpayments++;
            if(userInfos2x2[up].noofpayments==1 || _level==LAST_LEVEL)
            {
                busd.transfer(receiver,LEVEL_PRICE[_level]);
                //emit profit
                emit netProfit(receiver,_level,LEVEL_PRICE[_level],_addr);
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
    }


    function _buyLevel4x4(address payable userAddress)internal{
        if(lastIDCount4x4==1)
        {
            lastFreeParent4x4 = 1;
        }
        if(userInfos4x4[lastFreeParent4x4].childCount >= 3) lastFreeParent4x4++;

        lastIDCount4x4++;
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
        emit buyLevelEvent(userAddress, 2, block.timestamp,LEVEL_PRICE[1]);
        
        emit binaryData(userAddress,lastIDCount4x4,lastFreeParent4x4,2,userAddressByID[lastFreeParent4x4]);
      
        distributeBonus4x4(lastIDCount4x4,2);
        
    }
    
    
    function _upgradeLevel4x4(uint _level, uint user) internal returns(bool)
    {
        address payable useradd=userAddressByID[user];
        emit buyLevelEvent(useradd, _level, block.timestamp,LEVEL_PRICE[_level]);
        distributeBonus4x4(user,_level);
        users[useradd].activeLevel=_level;
        userInfos4x4[user].noofpayments = 0;
        userInfos4x4[user].referrerID = userInfos4x4[user].referrerID;
        return true;
    }

    function distributeBonus4x4(uint _addr,uint _level) internal {
        uint up2 =  userInfos4x4[_addr].referrerID;
        paymentForUp2(up2,_level,_addr);
    }

    function paymentForUp2(uint up2,uint _level,uint _addr) internal
    {
        address payable receiver2=userAddressByID[up2];
        if(receiver2==address(0)){
            busd.transfer(ownerWallet,LEVEL_PRICE[_level]);
        }
        else{
        userInfos4x4[up2].noofpayments++;
        if(userInfos4x4[up2].noofpayments==1 || _level==LAST_LEVEL)
        {
            if(_level==LAST_LEVEL && userInfos4x4[up2].noofpayments==3)
            {
                busd.transfer(receiver2,LEVEL_PRICE[_level].sub(LEVEL_PRICE[1]));
                emit netProfit(receiver2,_level,LEVEL_PRICE[_level].sub(LEVEL_PRICE[1]),_addr);
                emit reentryLevelEvent(userAddressByID[up2],up2,userInfos4x4[up2].referrerID, block.timestamp);
                regUser(userAddressByID[up2],users[userAddressByID[up2]].upline);
                
                //emit profit
            }
            else{
                busd.transfer(receiver2,LEVEL_PRICE[_level]);
                emit netProfit(receiver2,_level,LEVEL_PRICE[_level],_addr);
            //emit profit
            }
        }
        else if(userInfos4x4[up2].noofpayments==3)
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