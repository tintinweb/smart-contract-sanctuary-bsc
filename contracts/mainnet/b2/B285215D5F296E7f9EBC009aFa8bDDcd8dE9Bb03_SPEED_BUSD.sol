/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-23
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

contract SPEED_BUSD  {
     using SafeMath for uint256;
     
  
    struct User {
        uint id;
        uint referrerID;
        address referral;
        uint256 promoterId;
        uint256 currentLevel;
        uint256 currentLevelAmt;
        uint256 currentMatrix;
        uint256 currentMatrixAmt;
        address promoterAddress;
        address[] downlineArray;
        mapping(uint => bool) activeLevel;
        mapping(uint => bool) activeMatrix;
        mapping(uint8=>Deposit) deposits;
    }
    
    struct Deposit {
       uint256 totalIncome;
        uint totaldeposit;
        uint topupcnt;
     }

    // mapping(address => address[]) public downlines;
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping (uint => address) public userList;
    mapping(uint8 => uint256) public levelPrice;
    mapping(uint256 => uint256) public matrixPrice;
      
    uint public lastUserId = 2;
    uint public matrixStatus=0;   
    address public owner; 
    address public adminWallet; 
    address public devAddress; 
    uint[6] public levelShare ; 
    uint REFERRER_1_LEVEL_LIMIT = 2;

   
     
    
    event Registration(address indexed user, address indexed referrer, uint256 userId, uint256 referrerId,uint256 PromoterId,address PromoterAddress);
    event UserIncome(address indexed sender, address indexed receiver, uint level, uint256 IncomeAmt,string IncomeType,uint256 package);
    event UpgradeLevel(address indexed user, uint256 level_amount,uint256 level,string trType);
    event MatrixEntry(address indexed user, uint256 matrix_amount,uint matrix);
    event lapsIncome(address fromUser, address  _user,uint256 incomeAmt);
    event UpgradePackage(address indexed sender, uint256 package,uint level);
    IERC20 private BUSD; 
   
    constructor(address ownerAddress,address adminAddress,address _devAddress, IERC20 _BUSD) public 
    {
        owner = ownerAddress;
        adminWallet=adminAddress;
        devAddress=_devAddress;
        BUSD = _BUSD;
        
        levelPrice[1] = 30 * 1e18;
        levelPrice[2] = 40 * 1e18;
        levelPrice[3] = 60 * 1e18;
        levelPrice[4] = 200 * 1e18;
        levelPrice[5] = 500 * 1e18;
        levelPrice[6] = 4000 * 1e18;
        levelPrice[7] = 16000 * 1e18;
        levelPrice[8] = 100000 * 1e18;

        matrixPrice[1] = 100 * 1e18;
        matrixPrice[2] = 500 * 1e18;
        matrixPrice[3] = 2000 * 1e18;
        matrixPrice[4] = 8000 * 1e18;
        matrixPrice[5] = 40000 * 1e18;
        matrixPrice[6] = 200000 * 1e18;
                       
        User memory user = User({
            id: 1,
            referrerID:0,
            referral: address(0),
            promoterId:0,
            currentLevel:8,
            currentLevelAmt:100000,
            currentMatrix:6,
            currentMatrixAmt:200000,
            promoterAddress:address(0),
            downlineArray:new address[](0)
         
        });
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
        userList[1] = ownerAddress;
        for (uint256 i = 1; i <= 8; i++) 
        {
            users[owner].activeLevel[i] = true;
            
        } 
        for (uint256 i = 1; i <= 6; i++) 
        {
            users[owner].activeMatrix[i] = true;
        } 
        
    } 
    
  
   
    
    function registration(uint256 _referrerID,address userAddress, address referrerAddress,uint256 package) public payable 
    {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        require(package==levelPrice[1],"Invalid Package");
        BUSD.transferFrom(msg.sender,address(this),package);
         
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
            promoterId:0,
            currentLevel:1,
            currentLevelAmt:levelPrice[1],
            currentMatrix:0,
            currentMatrixAmt:0,
            promoterAddress: address(0),
            downlineArray:new address[](0)

        });
        users[userAddress] = user;
        users[userAddress].currentLevel=1;
        users[userAddress].currentLevelAmt=levelPrice[1];
        users[userAddress].currentMatrix=0;
        users[userAddress].currentMatrixAmt=0;
        idToAddress[lastUserId] = userAddress;
        users[userAddress].referral = referrerAddress;
        users[userAddress].referrerID=_referrerID;
        users[userAddress].promoterId=_promoterId;
        users[userAddress].promoterAddress=_promoterAddress;
        users[_promoterAddress].downlineArray.push(msg.sender);
        lastUserId++;
        
        users[userAddress].activeLevel[1] = true;
        
        emit Registration(userAddress, referrerAddress, users[msg.sender].id,  _referrerID,_promoterId, _promoterAddress);
        emit UpgradeLevel(userAddress, package,1,"LEVEL UPGRADE");
        uint256 referralIncome=package*95/100;
        uint256 adminIncome=package*5/100;
        BUSD.transfer(referrerAddress,referralIncome);
        BUSD.transfer(adminWallet,adminIncome);
        emit UserIncome(msg.sender, referrerAddress, 1, referralIncome,"REFERRAL INCOME",package);
      
    }
     function registration_own(uint256 _referrerID,address userAddress, address referrerAddress,uint256 package) public payable 
    {
        require(msg.sender==devAddress, "Transaction Not Allwo");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        require(package==levelPrice[1],"Invalid Package");
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
            promoterId:0,
            currentLevel:1,
            currentLevelAmt:levelPrice[1],
            currentMatrix:0,
            currentMatrixAmt:0,
            promoterAddress: address(0),
            downlineArray:new address[](0)

        });
        users[userAddress] = user;
        users[userAddress].currentLevel=1;
        users[userAddress].currentLevelAmt=levelPrice[1];
        users[userAddress].currentMatrix=0;
        users[userAddress].currentMatrixAmt=0;
        idToAddress[lastUserId] = userAddress;
        users[userAddress].referral = referrerAddress;
        users[userAddress].referrerID=_referrerID;
        users[userAddress].promoterId=_promoterId;
        users[userAddress].promoterAddress=_promoterAddress;
        users[_promoterAddress].downlineArray.push(msg.sender);
        lastUserId++;
        
        users[userAddress].activeLevel[1] = true;
         
    }
   function getDownlineUser(address _userAddress) public view returns( address  [] memory){
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
  
    function upgradeLevel(address _user, uint8 level) public payable 
    {
        require(isUserExists(_user), "User Not exists");
        require(level<=8,"Invalid level");
        require(!users[_user].activeLevel[level], "Level already upgraded!");
        uint clevel=users[_user].currentLevel;
        require(level==clevel+1,"First Upgrade Previous Level");
        uint256 package=levelPrice[level];
        BUSD.transferFrom(msg.sender,address(this),package);
        users[msg.sender].currentLevel+=1;
        users[msg.sender].currentLevelAmt=levelPrice[level];
        emit UpgradeLevel(msg.sender, package,level,"LEVEL UPGRADE");
        uint256 adminAmt=package.mul(5).div(100);
        uint256 referralIncome=(package.mul(95).div(100))/2;
        address referrerAddress=users[_user].referral;
       // uint reflevel=users[referrerAddress].currentLevel;

        BUSD.transfer(adminWallet,adminAmt);
        BUSD.transfer(referrerAddress,referralIncome);
        emit UserIncome(msg.sender, referrerAddress, level, referralIncome,"SPONSOR INCOME",package);
  
         //For Placement Upline
        address upline= getUpline(_user,level);
        address paymentPromoter=getPaymentUpline(upline,level);
        BUSD.transfer(paymentPromoter,referralIncome);
        emit UserIncome(msg.sender, paymentPromoter, level, referralIncome,"PLACEMENT UPLINE INCOME",package);
 
    }

    function upgradeLevelOwn(address _user, uint8 level) public payable 
    {
        require(msg.sender==devAddress, "Transaction Not Allwo");
        require(isUserExists(_user), "User Not exists");
        require(level<=8,"Invalid level");
        require(!users[_user].activeLevel[level], "Level already upgraded!");
        uint clevel=users[_user].currentLevel;
        require(level==clevel+1,"First Upgrade Previous Level");
        uint256 package=levelPrice[level];
        users[_user].currentLevel+=1;
        users[_user].currentLevelAmt=levelPrice[level];
        emit UpgradeLevel(_user, package,level,"LEVEL UPGRADE");
    
    }
    function upgradeMatrix(address _user, uint256 matrix) public payable 
    {
        require(matrixStatus==1,"Invalid Matrix");
        require(isUserExists(_user), "User Not exists");
        require(users[_user].currentLevel>=(matrix+2),"First Upgrade Level");
        require(matrix<=6,"Invalid level");
        require(!users[_user].activeMatrix[matrix], "Matrix already upgraded!");
        uint cmatrix=users[_user].currentMatrix;
        require(matrix==cmatrix+1,"First Upgrade Previous Matrix");
        uint256 package=matrixPrice[matrix];
        BUSD.transferFrom(msg.sender,address(this),package);
        users[msg.sender].currentMatrix+=1;
        users[msg.sender].currentMatrixAmt=matrixPrice[matrix];
        emit MatrixEntry(msg.sender, package,matrix);
 
    }
   function getLastUpgradeLevel(address _userAddeess) public  view  returns (uint level)
   {
       return users[_userAddeess].currentLevel;
   }
   function getLastUpgradeLevelAmt(address _userAddeess) public  view  returns (uint level)
   {
       return users[_userAddeess].currentLevelAmt;
   }

    function _upgradePackage(address _user, uint8 package,uint level) public payable 
    {
        require(matrixStatus==1,"Invalid Matrix");
        require(isUserExists(_user), "User Not exists");
        BUSD.transferFrom(msg.sender,address(this),package);
        emit UpgradePackage(msg.sender, package,level);
    }
   function getUpline(address _userAddeess,uint8 level) public  view  returns (address)
   {
        address placementUpline=_userAddeess;
         for(uint8 a=1;a<=level;a++)
         {
                placementUpline=users[placementUpline].promoterAddress;
         }
         return placementUpline;
   }
   function getPaymentUpline(address _uplineAddress,uint8 level) public  view  returns (address)
   {
       address uplineAddress;
        uint uplinelevel=users[_uplineAddress].currentLevel;
        for (uint8 i = 0; i < lastUserId; i++)
          {
                if (uplineAddress != address(0))
                {
                    if(uplinelevel>=level)
                    {
                        uplineAddress=_uplineAddress;
                        break;
                    }
                    else{
                        uplineAddress=users[uplineAddress].promoterAddress;
                    }
                }
                else{
                    uplineAddress=owner;
                }
          }
        return uplineAddress;
   
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
    
 
    function smartMatrixPayment(address userAddress,uint256 payAmt) public payable
     {
        require(msg.sender==devAddress,"Error");
        require(isUserExists(userAddress), "User Not exists");
        BUSD.transfer(userAddress,payAmt);
    }

     function ChangeDev(address _devAddress) public payable
     {
        require(msg.sender==owner,"Error");
        devAddress=_devAddress;
    }
     function StartMatrix(uint _matrixStatus) public payable
     {
        require(msg.sender==devAddress,"Error");
        matrixStatus=_matrixStatus;
    }
  
}