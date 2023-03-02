/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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


  abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}


contract WyzthStaking is Initializable {
     using SafeMath for uint256;
     
  
    struct User {
        uint id;
        Deposit[] deposits;
       uint256 withdrawn;
     }

     	struct Deposit {
		uint256 amount;
		uint256 start;
        uint256 end;
       bool isWithdraw;
        bool isClaimed;
	     }
    
    

  
    // mapping(address => address[]) public downlines;
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    uint public time;
    uint public lastUserId = 2;
       
    address public owner; 
    address public adminWallet; 
    IERC20 private Wyzthtoken;
    event Registration(address indexed user);
event Withdrawn(address indexed user, uint256 amount);
    event Investment(address indexed user, uint256 amount,string stakingType);
    IERC20 private COIN; 

    function initialize(address ownerAddress, IERC20 _COIN) public
        initializer {
            owner = ownerAddress;
            Wyzthtoken = _COIN;
            time = 1 minutes ;
            // time = 1095 days;
            }
   
    constructor(address ownerAddress,address adminAddress, IERC20 _COIN)  
    {
        owner = ownerAddress;
        adminWallet=adminAddress;
        COIN = _COIN;
        users[adminAddress].id =1;   
    } 
   
    function registration(address userAddress) private 
    {
       users[userAddress].id = lastUserId;
        idToAddress[lastUserId] = userAddress;
        lastUserId++;
        emit Registration(userAddress);
    
    }
    
   
    function invest(address userAddress, uint amount,string memory stakingType) public payable 
    {
        
        require(!isContract(msg.sender),"Can not be contract");
        require(Wyzthtoken.balanceOf(msg.sender)>= amount,"Low Balance");
        if(!isUserExists(userAddress))
        {
            registration(userAddress);
        }
        COIN.transferFrom(msg.sender,address(this),amount);
        users[msg.sender].deposits.push(Deposit(amount, block.timestamp,block.timestamp.add(time),false,false));
        emit Investment(msg.sender, amount,stakingType);
     
    }

function claim() external {
		User storage user = users[msg.sender];
        uint256 totalAmount;
		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 finish = user.deposits[i].start.add(time);
            bool alreadyClaimed = user.deposits[i].isClaimed;
            bool alreadyWithdraw = user.deposits[i].isWithdraw;
			if (block.timestamp >= finish && !alreadyClaimed &&!alreadyWithdraw) {
				totalAmount=totalAmount.add(user.deposits[i].amount);
                user.deposits[i].isClaimed=true;
			}
		}
		require(totalAmount > 0);
		
		user.withdrawn = user.withdrawn.add(totalAmount);
		// Wyzthtoken.transfer(msg.sender,totalAmount);
		emit Withdrawn(msg.sender, totalAmount);
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
    
     function withdrawToken(uint256 tokeQty,IERC20 _token) public payable 
     {
        require(msg.sender==owner,"Only Owner");
        _token.transfer(owner,tokeQty);
    }
  
}