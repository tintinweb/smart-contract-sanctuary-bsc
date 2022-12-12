/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

pragma solidity >=0.5.4;

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

contract W_USDT_Thunder  {
     using SafeMath for uint256;
     
  
    struct User {
        uint id;
        address referrer;
        uint256 referralid;
    }
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
     
    uint public lastUserId = 2;
  
    address public owner; 

    event Registration(address indexed user, address indexed referrer, uint256 indexed userId, uint256 referrerId);
  
    event Reinvestment(address indexed user, uint256 investAmt);
    event onWithdraw(address  _user, uint256 withdrawalAmount);
  
    IBEP20 private WYZToken; 
  
    constructor(address ownerAddress, IBEP20 _WYZToken) public 
    {
        owner = ownerAddress;
        
        WYZToken = _WYZToken;
     
           
        User memory user = User({
            id: 1,
            referrer: address(0),
            referralid: uint(0)
         
        });
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
        
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
  
    function registration(address userAddress, address referrerAddress,uint256 referralId) public payable 
    {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            referralid: referralId
          
        });
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        users[userAddress].referrer = referrerAddress;
        lastUserId++;
        emit Registration(userAddress, referrerAddress, users[userAddress].id, referralId);
 
      
    }
    
    function reinvestment(uint256 package) public payable 
    {
        require(isUserExists(msg.sender), "User Not exists");
       // require(package==50*1e18,"Lot Price 50 BUSD");

        WYZToken.transferFrom(msg.sender,owner,package);
        emit Reinvestment(msg.sender,package);
  
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