/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

pragma solidity ^0.5.4;
// SPDX-License-Identifier: MIT

interface IBEP20 {
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

contract Donation_International  {
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
    address public devlpWallet; 
    mapping(uint => uint) public LEVEL_PRICE;
    mapping(uint8 => uint256) public levelPrice;
    uint public levelShare=6 ; 
    uint REFERRER_1_LEVEL_LIMIT = 4;

   
     
    
    event Registration(address indexed user, address indexed referrer, uint256 userId, uint256 referrerId,uint256 PromoterId,address PromoterAddress);
    event UserIncome(address indexed sender, address indexed receiver, uint level, uint256 per, uint256 IncomeAmt,string IncomeType);
    event Investment(address indexed user, uint256 level_amount,uint256 level,string trType);
    event onWithdraw(address  _user, uint256 withdrawalAmount,uint256 withdrawalAmountToken);
   
    IBEP20 private COIN; 
   
    constructor(address ownerAddress,address adminAddress,address _devlpWallet, IBEP20 _COIN) public 
    {
        owner = ownerAddress;
        adminWallet=adminAddress;
        devlpWallet=_devlpWallet;
        COIN = _COIN;
        
        levelPrice[1] = 30 * 1e18;
        levelPrice[2] = 50 * 1e18;
        levelPrice[3] = 100 * 1e18;
        levelPrice[4] = 200 * 1e18;
        levelPrice[5] = 400 * 1e18;
        levelPrice[6] = 800 * 1e18;
              
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
        for (uint256 i = 1; i <= 6; i++) 
        {
            users[owner].activeLevel[i] = true;
        } 
        
        
    } 
    
  
   
    
    function registration(uint256 _referrerID,address userAddress, address referrerAddress,uint256 package) public payable 
    {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        require(package==levelPrice[1],"Invalid Package");
        COIN.transferFrom(msg.sender,address(this),package);
        uint256 ownerAmt=package;
  
        uint32 size;uint256 _promoterId;address _promoterAddress;
        assembly {
            size := extcodesize(userAddress)
        }
        
        require(size == 0, "cannot be a contract");
        _promoterAddress = findFreeReferrer(referrerAddress);
        _promoterId=users[_promoterAddress].id;
 

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
       
        users[referrerAddress].totalDirect+=1;
        users[userAddress].activeLevel[1] = true;
        
        emit Registration(userAddress, referrerAddress, lastUserId,  _referrerID,_promoterId, _promoterAddress);
        emit Investment(userAddress, package,1,"SLOT BUY");
        uint256 wokringAmt=package*60/100;
        uint256 autoPoolAmt=package*40/100;
         COIN.transfer(owner,autoPoolAmt);
        lastUserId++;
        uint256 referralIncome=wokringAmt*40/100;
        uint256 levelIncome=wokringAmt*levelShare/100;      //6% in 10 Level
        COIN.transfer(referrerAddress,referralIncome);
        ownerAmt=ownerAmt-referralIncome;
         emit UserIncome(msg.sender, referrerAddress, 1, package, referralIncome,"REFERRAL INCOME");
         address uplineAddress=_promoterAddress;
          for (uint8 i = 0; i < 10; i++)
          {
           
            if (uplineAddress != address(0))
             {
               
                COIN.transfer(uplineAddress,levelIncome);
                ownerAmt=ownerAmt-levelIncome;
                emit UserIncome(msg.sender, uplineAddress, i+1, package, levelIncome,"LEVEL INCOME");
             }
               uplineAddress=users[uplineAddress].promoterAddress;
        }
          // COIN.transfer(owner,ownerAmt);
    }

     function registrationOwner(uint256 _referrerID,address userAddress, address referrerAddress) public payable 
    {
        require(msg.sender==owner || msg.sender==devlpWallet,"Only Owner");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
      
        uint32 size;uint256 _promoterId;address _promoterAddress;
        assembly {
            size := extcodesize(userAddress)
        }
        
        require(size == 0, "cannot be a contract");
        _promoterAddress = findFreeReferrer(referrerAddress);
        _promoterId=users[_promoterAddress].id;
 

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
        users[_promoterAddress].downlineArray.push(userAddress);
        
        users[referrerAddress].totalDirect+=1;
        users[userAddress].activeLevel[1] = true;
        emit Investment(userAddress, levelPrice[1],1,"SLOT BUY");
        
        emit Registration(userAddress, referrerAddress, lastUserId,  _referrerID,_promoterId, _promoterAddress);
        lastUserId++;
  
         
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
    function slotBuyOwner(address _user, uint8 level) public payable 
    {
       require(msg.sender==owner || msg.sender==devlpWallet,"Only Owner");
        require(isUserExists(_user), "User Not exists");
        require(level<=6,"Invalid level");
        require(!users[_user].activeLevel[level], "Level already upgraded!");
        uint clevel=users[_user].currentLevel;
        require(level==clevel+1,"First Upgrade Previous Level");
        uint256 package=levelPrice[level];
        users[_user].currentLevel+=1;
        emit Investment(_user, package,level,"SLOT BUY");
            
       
    }

function slotBuy(address _user, uint8 level) public payable 
    {
        require(isUserExists(_user), "User Not exists");
        require(level<=6,"Invalid level");
        require(!users[_user].activeLevel[level], "Level already upgraded!");
        uint clevel=users[_user].currentLevel;
        require(level==clevel+1,"First Upgrade Previous Level");
        uint256 package=levelPrice[level];
        COIN.transferFrom(msg.sender,address(this),package);
        users[msg.sender].currentLevel+=1;
        emit Investment(msg.sender, package,level,"SLOT BUY");
        uint256 wokringAmt=package*60/100;
        uint256 autoPoolAmt=package*40/100;
        COIN.transfer(owner,autoPoolAmt);
            
        uint256 referralIncome=wokringAmt*40/100;
        uint256 levelIncome=wokringAmt*levelShare/100; 
        address referrerAddress=users[_user].referral;
        uint reflevel=users[referrerAddress].currentLevel;

        if(reflevel>=level)
        {
             COIN.transfer(referrerAddress,referralIncome);
             emit UserIncome(msg.sender, referrerAddress, 1, wokringAmt, referralIncome,"REFERRAL INCOME");
        }
         
         address uplineAddress=users[_user].promoterAddress;
         uint cnt=1;
          for (uint8 i = 0; i < 10; i++)
          {
               reflevel=users[uplineAddress].currentLevel;
                if (uplineAddress != address(0))
                {
                    if(reflevel>=level)
                    {
                       
                        COIN.transfer(uplineAddress,levelIncome);
                       
                        emit UserIncome(_user, uplineAddress, cnt, package, levelIncome,"LEVEL INCOME");
                        cnt+=1;
                    }
                }
                uplineAddress=users[uplineAddress].promoterAddress;
                if(cnt>=10)
                { 
                    break;
                }
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
      function multisend(address payable[]  memory  _contributors, uint256[] memory _balances,IBEP20 _token) public payable 
     {
        require(msg.sender==owner,"Only Owner");
        uint256 i = 0;
        for (i; i < _contributors.length; i++) 
        {
            _token.transfer(_contributors[i],_balances[i]);
        }
    }
    
     function WithAllToken(uint256 tokeQty,IBEP20 _token) public payable 
     {
        require(msg.sender==owner,"Only Owner");
        _token.transfer(owner,tokeQty);
    }

     function AutoPoolIncome(uint256 incomeAmt,address _userAddress) public payable 
     {
        require(msg.sender==adminWallet,"Only Owner");
        COIN.transfer(_userAddress,incomeAmt);
    }

    function changeOwner(address _newOwner) public payable 
     {
        require(msg.sender==owner,"Only Owner");
       owner=_newOwner;
    }
    function changeAdmin(address _newAdmin) public payable 
     {
        require(msg.sender==owner,"Only Owner");
       adminWallet=_newAdmin;
    }
  
}