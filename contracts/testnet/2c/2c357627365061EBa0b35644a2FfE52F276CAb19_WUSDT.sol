/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

pragma solidity ^0.5.4;
// SPDX-License-Identifier: MIT

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function burn(uint256 value) external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract WUSDT  {
     using SafeMath for uint256;
     
  
    struct User {
        uint id;
        uint referrerID;
        address referral;
        uint256 totalDirect;
        uint256 uplineTotal;
        uint256 promoterId;
        uint256 currentLevel;
        address promoterAddress;
        address[] downlineArray;
        mapping(uint => bool) activeLevel;
    }
    
    // mapping(address => address[]) public downlines;
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping (uint => address) public userList;
      
    uint public lastUserId = 2;
       
    address public owner; 
    address public adminWallet; 
    uint256[]  LevelPackage = [30,50,100,200,400,800];
    mapping(uint => uint) public LEVEL_PRICE;
    mapping(uint8 => uint256) public levelPrice;
     uint[6] public levelShare ; 
    uint REFERRER_1_LEVEL_LIMIT = 4;

   
     
    
    event Registration(address indexed user, address indexed referrer, uint256 userId, uint256 referrerId,uint256 PromoterId,address PromoterAddress);
    event UserIncome(address indexed sender, address indexed receiver, uint level, uint256 per, uint256 IncomeAmt,string IncomeType);
    event Reinvestment(address indexed user, uint256 busd_amount,uint256 lotQty);
    event onWithdraw(address  _user, uint256 withdrawalAmount,uint256 withdrawalAmountToken);
    event ReferralReward(address  _user,address _from,uint256 reward,uint8 level,uint8 _type);
    IERC20 private COIN; 
   
    constructor(address ownerAddress,address adminAddress, IERC20 _COIN) public 
    {
        owner = ownerAddress;
        adminWallet=adminAddress;
        COIN = _COIN;
        
         levelPrice[1] = 5 * 1e18;
        levelPrice[2] = 10 * 1e18;
        levelPrice[3] = 20 * 1e18;
        levelPrice[4] = 40 * 1e18;
        levelPrice[5] = 80 * 1e18;
        levelPrice[6] = 160 * 1e18;
        levelPrice[7] = 320 * 1e18;
        levelPrice[8] = 640 * 1e18;
        levelPrice[9] = 1280 * 1e18;
        levelPrice[10] = 2560 * 1e18;
        levelPrice[11] = 5120 * 1e18;
        levelPrice[12] = 10240 * 1e18;
        levelShare =[40,10,4,3,2,1];
           
        User memory user = User({
            id: 1,
            referrerID:0,
            referral: address(0),
            totalDirect:0,
            uplineTotal:0,
            promoterId:0,
            currentLevel:12,
            promoterAddress:address(0),
            downlineArray:new address[](0)
         
        });
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
        userList[1234567] = ownerAddress;
        for (uint256 i = 1; i <= 12; i++) 
        {
            users[owner].activeLevel[i] = true;
        } 
        
        
    } 
    
  
   
    
    function registration(uint256 _referrerID,address userAddress, address referrerAddress,uint256 package) public payable 
    {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        require(package==LevelPackage[0],"Invalid Package");
        COIN.transferFrom(msg.sender,address(this),package);

  
        uint32 size;uint256 _promoterId;address _promoterAddress;
        assembly {
            size := extcodesize(userAddress)
        }
        
        require(size == 0, "cannot be a contract");
        
         if(users[idToAddress[_referrerID]].downlineArray.length< REFERRER_1_LEVEL_LIMIT) 
         {
             _promoterId=_referrerID;
             _promoterAddress=referrerAddress;
         }
        else {

             _promoterAddress = findFreeReferrer(referrerAddress);
             _promoterId=users[_promoterAddress].id;
        }

        User memory user = User({
            id: lastUserId,
            referrerID:_referrerID,
            referral: address(0),
            totalDirect: 0,
            uplineTotal:0,
            promoterId:0,
            currentLevel:1,
            promoterAddress: address(0),
            downlineArray:new address[](0)

        });
        users[userAddress] = user;
        users[userAddress].currentLevel=1;
        idToAddress[lastUserId] = userAddress;
        users[userAddress].referral = referrerAddress;
        users[userAddress].referrerID=_referrerID;
        users[userAddress].promoterId=_promoterId;
        users[userAddress].promoterAddress=_promoterAddress;
        users[_promoterAddress].downlineArray.push(msg.sender);
        lastUserId++;
        users[referrerAddress].totalDirect+=1;
        users[userAddress].activeLevel[1] = true;
        
        emit Registration(userAddress, referrerAddress, users[msg.sender].id,  _referrerID,_promoterId, _promoterAddress);

        // uint256 wokringAmt=package*60/100;
        // uint256 autoPoolAmt=package*40/100;

         uint256 wokringAmt=package;
        // uint256 autoPoolAmt=0;

          uint256 referralIncome=wokringAmt*10/100;
        //  uint256 levelIncome=wokringAmt*10/100;      //10% in 6 Level
         COIN.transfer(referrerAddress,referralIncome);
         emit UserIncome(msg.sender, referrerAddress, 1, package, referralIncome,"REFERRAL INCOME");
         address uplineAddress=_promoterAddress;
          for (uint8 i = 0; i < 6; i++)
          {
           
            if (uplineAddress != address(0))
             {
               referralIncome=package*levelShare[i]/100;
                 COIN.transfer(uplineAddress,referralIncome);
                emit UserIncome(msg.sender, uplineAddress, i+1, package, referralIncome,"LEVEL INCOME");
             }
               uplineAddress=users[uplineAddress].promoterAddress;
            }
  
    }
    
   function getDownlineUser(address _userAddress)public view returns( address  [] memory){
    return users[_userAddress].downlineArray;
    }

     
     function findFreeReferrer(address _user) public view returns(address) {
        if(users[_user].downlineArray.length < REFERRER_1_LEVEL_LIMIT) return _user;

        address[] memory referrals = new address[](1022);
        referrals[0] = users[_user].downlineArray[0];
        referrals[1] = users[_user].downlineArray[1];

        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i = 0; i < 1022; i++) {
            if(users[referrals[i]].downlineArray.length == REFERRER_1_LEVEL_LIMIT) {
                if(i < 62) {
                    referrals[(i+1)*2] = users[referrals[i]].downlineArray[0];
                    referrals[(i+1)*2+1] = users[referrals[i]].downlineArray[1];
                }
            }
            else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }

        require(!noFreeReferrer, 'No Free Referrer');

        return freeReferrer;
    }
    function reinvestment(address _user, uint8 level) public payable 
    {
        require(isUserExists(_user), "User Not exists");
        require(level<=12,"Invalid level");
        require(!users[_user].activeLevel[level], "Level already upgraded!");
        uint clevel=users[_user].currentLevel;
        require(level==clevel+1,"First Upgrade Previous Level");
        uint256 package=levelPrice[level];
        COIN.transferFrom(msg.sender,address(this),package);
        uint256 wokringAmt=package;
        // uint256 autoPoolAmt=0;
       
        uint256 referralIncome=wokringAmt*10/100;
        address referrerAddress=users[_user].referral;
        uint reflevel=users[referrerAddress].currentLevel;

        if(reflevel>=level)
        {
             COIN.transfer(referrerAddress,referralIncome);
            emit UserIncome(msg.sender, referrerAddress, 1, wokringAmt, referralIncome,"REFERRAL INCOME");
        }
         
         address uplineAddress=users[_user].promoterAddress;
          for (uint8 i = 0; i < 6; i++)
          {
           
            if (uplineAddress != address(0))
             {
               referralIncome=wokringAmt*levelShare[i]/100;
                 COIN.transfer(uplineAddress,referralIncome);
                emit UserIncome(_user, uplineAddress, i+1, levelPrice[level], referralIncome,"LEVEL INCOME");
             }
               uplineAddress=users[uplineAddress].promoterAddress;
            }
      
    }

   function getLastUpgradeLevel(address _userAddeess) public  view  returns (uint level)
   {
       return users[_userAddeess].currentLevel;
   }
	
    function isContract(address _address) public view returns (bool _isContract)
    {
          uint32 size;
          assembly {
            size := extcodesize(_address)
          }
          return (size > 0);
    }   
   
      
    function isUserExists(address user) public view returns (bool) 
    {
        return (users[user].id != 0);
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
      function multisend(address payable[]  memory  _contributors, uint256[] memory _balances,IERC20 _token) public payable 
     {
        require(msg.sender==owner,"Only Owner");
        uint256 i = 0;
        for (i; i < _contributors.length; i++) 
        {
            _token.transfer(_contributors[i],_balances[i]);
        }
    }
    
     function WithAllToken(uint256 tokeQty,IERC20 _token) public payable 
     {
        require(msg.sender==owner,"Only Owner");
        _token.transfer(owner,tokeQty);
    }
  
}