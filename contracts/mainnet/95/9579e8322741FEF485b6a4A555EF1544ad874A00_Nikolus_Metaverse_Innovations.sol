/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

pragma solidity 0.5.4;

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

contract Nikolus_Metaverse_Innovations  {
     using SafeMath for uint256;
     
  
    struct User {
        uint id;
        address referrer;
        uint256 totalStakingBusd;
        uint256 totalStakingToken;
        uint256 directReferral;
    }
    
    mapping(address => address[]) public referrals;

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
     
    uint public lastUserId = 2;
    uint256 public currentLot=40000;
    uint256 public investStatus=0;
    uint256 public FirstDate;
    uint256 public SecondDate;
    uint256 public ThirdDate;
    uint256 public ForthDate;
    uint256 public FifthDate;
    uint256 public SixthDate;
    uint256 public SevonthDate;
	uint256 public EightDate;
	uint256 public NinethDate;
    uint public buyStatus=0;
    
    address public owner; 
    uint256[]  levelPer = [200,200,100,100,100,100,50,50,50,50];
    
    event Registration(address indexed user, address indexed referrer, uint256 indexed userId, uint256 referrerId,uint256 tokenLot);
    event LevelIncome(address indexed sender, address indexed receiver, uint level, uint256 per, uint256 busd_amount);
    event Reinvestment(address indexed user, uint256 busd_amount,uint256 lotQty);
    event onWithdraw(address  _user, uint256 withdrawalAmount,uint256 withdrawalAmountToken);
    event ReferralReward(address  _user,address _from,uint256 reward,uint8 level,uint8 _type);
    IBEP20 private BusdToken; 
    IBEP20 private NILSToken; 

    constructor(address ownerAddress, IBEP20 _busdToken, IBEP20 _NILSToken) public 
    {
        owner = ownerAddress;
        
        NILSToken = _NILSToken;
        BusdToken = _busdToken;
        
           
        User memory user = User({
            id: 1,
            referrer: address(0),
            totalStakingBusd: uint(0),
            totalStakingToken: uint(0),
            directReferral:0
         
        });
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;

         FirstDate=block.timestamp.add(45*24*60*60);
         SecondDate=block.timestamp.add(90*24*60*60);
         ThirdDate=block.timestamp.add(135*24*60*60);
         ForthDate=block.timestamp.add(180*24*60*60);
         FifthDate=block.timestamp.add(225*24*60*60);
         SixthDate=block.timestamp.add(270*24*60*60);
         SevonthDate=block.timestamp.add(315*24*60*60);
		 EightDate=block.timestamp.add(360*24*60*60);
		 NinethDate=block.timestamp.add(405*24*60*60);
    	

        
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
  
    function registration(address userAddress, address referrerAddress,uint256 package,uint256 referralId) public payable 
    {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        require(package==50*1e18,"Lot Price 50 BUSD");
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            totalStakingBusd: 0,
            totalStakingToken: 0,
            directReferral: 0
    
        });
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        users[userAddress].referrer = referrerAddress;
        referrals[referrerAddress].push(userAddress);
        lastUserId++;
        users[referrerAddress].directReferral+=1;
        

        uint256 adminAmt=package;
        uint256 referralIncome=package*5/100;
        BusdToken.transferFrom(msg.sender,address(this),package);
        BusdToken.transfer(referrerAddress,referralIncome);
        emit LevelIncome(msg.sender, referrerAddress, 1, 500, referralIncome);
        adminAmt=adminAmt-referralIncome;
         for (uint8 i = 0; i < 10; i++)
          {
             referrerAddress=users[referrerAddress].referrer;
            if (referrerAddress != address(0))
             {

                referralIncome=package*levelPer[i]/10000;
                 adminAmt=adminAmt-referralIncome;
                 BusdToken.transfer(referrerAddress,referralIncome);
                emit LevelIncome(msg.sender, referrerAddress, i+2, levelPer[i], referralIncome);
              
               
             }
            }
        getLotQuantity();
        uint256 lotQty=currentLot;
        NILSToken.transfer(msg.sender, lotQty*1e18);
        BusdToken.transfer(owner,adminAmt);
        emit Registration(userAddress, referrerAddress, users[userAddress].id, referralId,lotQty);
        users[userAddress].totalStakingBusd+=package;
        users[userAddress].totalStakingToken+=lotQty;
      
    }
    
    function reinvestment(uint256 package) public payable 
    {

        require(isUserExists(msg.sender), "User Not exists");
        require(package==50*1e18,"Lot Price 50 BUSD");
        require(buyStatus==1,"Not Allwoe");
        uint256 adminAmt=package;
        address referrerAddress=users[msg.sender].referrer;
        uint256 referralIncome=package*5/100;
        adminAmt=adminAmt-referralIncome;
        BusdToken.transferFrom(msg.sender,address(this),package);
        BusdToken.transfer(referrerAddress,referralIncome);
        emit LevelIncome(msg.sender, referrerAddress, 1, 500, referralIncome);
      
         for (uint8 i = 0; i < 10; i++)
          {
             referrerAddress=users[referrerAddress].referrer;
            if (referrerAddress != address(0))
             {

                referralIncome=package*levelPer[i]/10000;
                 BusdToken.transfer(referrerAddress,referralIncome);
                emit LevelIncome(msg.sender, referrerAddress, i+2, levelPer[i], referralIncome);
                 adminAmt=adminAmt-referralIncome;
               
             }
            }
        getLotQuantity();
        uint256 lotQty=currentLot;
        NILSToken.transfer(msg.sender, lotQty*1e18);
        BusdToken.transfer(owner,adminAmt);
        emit Reinvestment(msg.sender,package,lotQty);
        users[msg.sender].totalStakingBusd+=package;
        users[msg.sender].totalStakingToken+=lotQty;
      
    }

    function getLotQuantity() public 
    {
        if(block.timestamp<=FirstDate)
        {
            currentLot=40000;
        }
        else if (block.timestamp>FirstDate && block.timestamp<=SecondDate)
        {
            currentLot=30000;
        }
        else if (block.timestamp>SecondDate && block.timestamp<=ThirdDate)
        {
            currentLot=20000;
        }
        else if (block.timestamp>ThirdDate && block.timestamp<=ForthDate)
        {
            currentLot=10000;
        }
        else if (block.timestamp>ForthDate && block.timestamp<=FifthDate)
        {
            currentLot=5000;
            buyStatus=1;
        }
         else if (block.timestamp>SixthDate && block.timestamp<=SevonthDate)
        {
            currentLot=3000;
            buyStatus=1;
        }
        else if (block.timestamp>SevonthDate && block.timestamp<=EightDate)
        {
            currentLot=2000;
            buyStatus=1;
        }
         else if (block.timestamp>EightDate && block.timestamp<=NinethDate)
        {
            currentLot=1000;
            buyStatus=1;
        }
		  else if (block.timestamp>=NinethDate )
        {
            currentLot=400;
            buyStatus=1;
        }
       
    }

     function getlotSize() public  view  returns (uint256)
     {
         return currentLot;
     }  

    function getbuyStatys() public  view  returns (uint256)
     {
         return buyStatus;
     } 
 
   function switchBuy(uint _buyStatus) public payable 
     {
        require(msg.sender==owner,"Only Owner");
        buyStatus=_buyStatus;
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
}