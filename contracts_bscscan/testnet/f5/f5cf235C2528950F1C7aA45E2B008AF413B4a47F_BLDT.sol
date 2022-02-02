/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

pragma solidity ^0.8.0;

//SPDX-License-Identifier: UNLICENSED

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

library SafeMath {
  
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }


    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

   
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

   
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

   
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

  
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

  
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

   
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

   
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract BLDT is Initializable {

    using SafeMath for uint256;

    struct User {
        uint256 id;
        address referrer;
        uint256 partnersCount;
        uint256 levelIncome;
        uint256 sponcerIncome;
        Deposit []deposits;	
		uint256 checkpoint;
        uint256 withdrawn;
    }

	struct Deposit {
		uint256 amount;
		uint256 start;
        uint256 end;
	}

    mapping(uint8=>uint256 ) public defaultPakcage;
    mapping(address => User) public users;
    mapping(uint256 => address) public idToAddress;

    uint256 public lastUserId;
    address public owner;

    address public dev;
    uint256 public price;
    uint256 public TIME_STEP;

    event Registration(address indexed user,address indexed referrer,uint256 indexed userId,uint256 referrerId,uint8 package);
    event UserIncome(address sender,address receiver,uint256 amount,uint8 level,string _for );
    event Upgrade (address user , uint8 package);
    event PriceChanged(uint256 newPrice);

    modifier onlyDev() {
        require(dev == msg.sender, "Ownable: caller is not the developer");
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function initialize(address _ownerAddress,address _devwallet,uint256 bdltInUsd)
        public
        initializer
    {

        defaultPakcage[1]= 50*1e18*bdltInUsd;
        defaultPakcage[2]= 100*1e18*bdltInUsd;
        
        price =bdltInUsd;
        dev =_devwallet;

        lastUserId = 2;
        owner = _ownerAddress;

        TIME_STEP =30 days;

        users[owner].id = 1;
        users[owner].referrer = address(0);
        users[owner].partnersCount = uint256(0);
        idToAddress[1] = owner;


        emit Registration(owner, address(0), users[owner].id, 0,1);

    }

    function registrationExt(address referrerAddress,uint8 package) external payable {
        registration(msg.sender, referrerAddress,package);
    }

    function registration(address userAddress, address referrerAddress,uint8 package) private {
        // require(msg.value>= 75*1e15,"Low Balance");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "Referrer not exists");
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        idToAddress[lastUserId] = userAddress;
        users[userAddress].id = lastUserId;
        users[userAddress].referrer = referrerAddress;
        users[userAddress].partnersCount = 0;

        lastUserId++;
        users[referrerAddress].partnersCount++;
        // payable(referrerAddress).transfer(defaultPakcage[package].mul(10).div(100));
        users[userAddress].deposits.push(Deposit(defaultPakcage[package], block.timestamp,block.timestamp.add(608 days)));
        users[referrerAddress].sponcerIncome+=defaultPakcage[package].mul(10).div(100);
        emit UserIncome(userAddress,referrerAddress,defaultPakcage[package].mul(10).div(100),1,"direct_sponcer");
        emit Registration(userAddress,referrerAddress,users[userAddress].id,users[referrerAddress].id,package);
        _calculateReferrerReward(defaultPakcage[package],referrerAddress,userAddress);
    }

    function _calculateReferrerReward(uint256 _investment, address _referrer,address sender) private {
         uint8 noOfuser=0;
	     for(uint8 i=1;i<=15;i++)
	     {
	        if(_referrer!=address(0) && users[_referrer].partnersCount>=2){
               noOfuser++;
             if(users[_referrer].referrer!=address(0))
                _referrer=users[_referrer].referrer;
            else
                break;
	         }
	         
	     }
         
	     for(uint8 i=1;i<=15;i++)
	     {
	        if(_referrer!=address(0) && users[_referrer].partnersCount>=2){
                // payable(_referrer).transfer(_investment.div(noOfuser)); 
                users[_referrer].levelIncome+=_investment.mul(40).div(100).div(noOfuser);
                emit UserIncome(sender,_referrer,_investment.mul(40).div(100).div(noOfuser),i,"level_income");
             if(users[_referrer].referrer!=address(0))
                _referrer=users[_referrer].referrer;
            else
                break;
	         }
	         
	     }
         
    }
     
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];
		uint256 totalAmount;
		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 finish = user.deposits[i].end;
			if (user.checkpoint < finish) {
				uint256 share = user.deposits[i].amount.mul(10).div(100);
				uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
				}
			}
		}

		return totalAmount;
	}

    function UpgradePackage(address user ,uint8 package) external payable {
        require(isUserExists(user), "User not exists");
        users[user].deposits.push(Deposit(defaultPakcage[package], block.timestamp,block.timestamp.add(608 days)));
        // payable(users[user].referrer).transfer(defaultPakcage[package].mul(10).div(100));
        emit UserIncome(user,users[user].referrer,defaultPakcage[package].mul(10).div(100),1,"direct_sponcer");
        _calculateReferrerReward(defaultPakcage[package],users[user].referrer,user);
         
    }

    function ChangePrice(uint256 bdltInUsd) external onlyDev{
        defaultPakcage[1]= 50*1e18*bdltInUsd;
        defaultPakcage[2]= 100*1e18*bdltInUsd;

        price = bdltInUsd;
    
        emit PriceChanged(price);
    }

    function withdrawETH(uint256 amt, address payable adr)
        public
        payable
        onlyOwner
    {
        adr.transfer(amt);
    }

}