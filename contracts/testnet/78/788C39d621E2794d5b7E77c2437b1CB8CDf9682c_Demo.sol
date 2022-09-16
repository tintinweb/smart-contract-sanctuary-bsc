/**
 *Submitted for verification at BscScan.com on 2021-04-16
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.5.10;
import "./SafeMath.sol";
contract Demo{
	using SafeMath for uint256;

	struct User {
        uint id;
        address referrer;
        uint partnersCount;
       mapping(uint8 => Referu) referUser;
      
    }
    
    struct Referu {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
        uint partnersCount;
    }
    uint8 public LAST_LEVEL;
    uint public lastUserId;
     mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
     uint256[] public levelPrice=[5e18,2e18,1e18,0.75e18,0.5e18,0.25e18,0.1e18,0.1e18,0.1e18,0.1e18,0.1e18,0.1e18,0.1e18,0.1e18,0.1e18,0.1e18];
    mapping(address => User) public users;
	constructor() public {
		LAST_LEVEL = 16;

    User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0)
        });
        
        users[msg.sender] = user;
        idToAddress[1] = msg.sender;
        
       
        
        userIds[1] = msg.sender;
        lastUserId = 2;
  	}
	
	  function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    } 

	 function invest(address referrer) public payable {
		// require(!isUserExists(msg.sender), "user exists");
        require(isUserExists(referrer), "referrer not exists");
        address userAddress=msg.sender;
        User memory user = User({
            id: lastUserId,
            referrer: referrer,
            partnersCount: 0
        });
        
        users[userAddress] = user;
   
        idToAddress[lastUserId] = userAddress;
        userIds[lastUserId] = userAddress;
        lastUserId++;
        users[userAddress].referrer = referrer;
        users[referrer].partnersCount++;
        address upline = user.referrer;
        for (uint8 i = 0; i < LAST_LEVEL; i++) {
				if (upline != address(0)) {
		users[upline].referUser[i].currentReferrer=userAddress;
        users[upline].referUser[i].referrals.push(userAddress);
        users[upline].referUser[i].partnersCount++;
				} else break;
			}
       
    }
function getUserLevels(address userAddress,uint8 level) public view returns(address currentReferrer, address[] memory referUser,uint256 partnersCount,uint256 levelIncome) {
        require(level<LAST_LEVEL, "Level can not be greater than last level");
		return (users[userAddress].referUser[level].currentReferrer,users[userAddress].referUser[level].referrals,users[userAddress].referUser[level].partnersCount,users[userAddress].referUser[level].partnersCount*levelPrice[level]);
	}

}