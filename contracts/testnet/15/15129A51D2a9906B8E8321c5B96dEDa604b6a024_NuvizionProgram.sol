/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

pragma solidity 0.5.4;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender)
  external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value)
  external returns (bool);
  
  function transferFrom(address from, address to, uint256 value)
  external returns (bool);
  function burn(uint256 value)
  external returns (bool);
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

contract NuvizionProgram  {
     using SafeMath for uint256;
     
      
     
    struct User {
        uint id;
        address referrer;
        uint256 totalDirect;
     
    }
    
    mapping(address => address[]) public referrals;

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    address public owner; 
    address public adminWallet; 
    uint256 public lastUserId = 2;
    uint256 public  FristLevel=20*1e18;
    uint256 public  SecondLevel=5*1e18;
    uint256 public  JoinAmt=100*1e18;
    
    event Registration(address indexed user, address indexed referrer, uint256 indexed userId, uint256 referrerId);
    event WithDraw(string  incomeType,address indexed  investor,uint256 WithAmt);
    event LevelUpgrade(string  investorId,uint256 investment,address indexed investor,string levelNAme);

    IBEP20 private AuraToken; 
    IBEP20 private busdToken; 

    constructor(address ownerAddress,address adminAddress, IBEP20 _busdToken) public 
    {
        owner = ownerAddress;
        adminWallet = adminAddress;
        busdToken = _busdToken;
               
        User memory user = User({
            id: 1,
            referrer: address(ownerAddress),
            totalDirect: uint(0)
  
        });
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
    } 
    
    function withdrawBalance(uint256 amt,uint8 _type) public 
    {
        require(msg.sender == owner, "onlyOwner");
        if(_type==1)
        msg.sender.transfer(amt);
        else if(_type==2)
        busdToken.transfer(msg.sender,amt);
     
    }
    
       
    function registration(address userAddress, address referrerAddress,uint256 investment) public payable  
    {
        require(investment>=JoinAmt,"Invalid Joing Amount");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        require(busdToken.balanceOf(msg.sender)>=investment);
		require(busdToken.allowance(msg.sender,address(this))>=investment,"Approve Your Token First");
        busdToken.transferFrom(msg.sender,address(this),investment);
        

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            totalDirect: 0
      
        });
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        users[userAddress].referrer = referrerAddress;
        referrals[referrerAddress].push(userAddress);
        lastUserId++;
        
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);

        busdToken.transfer(referrerAddress,FristLevel);
        referrerAddress=users[referrerAddress].referrer;
        busdToken.transfer(referrerAddress,SecondLevel);

        
    }
    function UpgradeLevel(string memory investorId,uint256 investment,string memory levelNAme) public payable
	{
        require(isUserExists(msg.sender), "referrer not exists");
	    require(busdToken.balanceOf(msg.sender)>=investment);
		require(busdToken.allowance(msg.sender,address(this))>=investment,"Approve Your Token First");
		busdToken.transferFrom(msg.sender ,address(this),investment);
		emit LevelUpgrade( investorId,investment,msg.sender,levelNAme);
	}
    function withdrawLostBNBFromBalance(address payable _sender) public {
        require(msg.sender == owner, "onlyOwner");
        _sender.transfer(address(this).balance);
    }
    
    function withdrawincome(string memory incomeType,address payable _userAddress,uint256 WithAmt) public {
        require(msg.sender == adminWallet, "onlyOwner");
        busdToken.transfer(_userAddress, WithAmt);
        emit WithDraw(incomeType,_userAddress,WithAmt);
    }
     
	function withdrawLostTokenFromBalance(uint QtyAmt) public 
	{
        require(msg.sender == owner, "onlyOwner");
        busdToken.transfer(owner,QtyAmt);
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
    function getReferall(address userAddress) public  view returns(address)
    {
         return users[userAddress].referrer;
    }
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}