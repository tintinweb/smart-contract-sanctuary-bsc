/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }
}


contract TestTokenContract is Context, Ownable {
    address payable private feeAddress;
    uint256 private feePercent = 3;
    bool private initialized = false;

    struct User {
		uint256 deposit;
        uint256 withdraw;
		uint256 lastTime;
		address referrer;
		uint256 bonus;
		uint256 totalBonus;
	}

    mapping (address => User) private users;

    constructor() {
        feeAddress = payable(msg.sender);
    }
    
    function compound() public {
        checkState();
        
        uint256 amount = getRewardsSinceLastDeposit(msg.sender);
        users[msg.sender].deposit += amount;

        require(users[msg.sender].deposit <= 100 * 10**18, "err: shouldn't greater than 100");
        
        users[msg.sender].lastTime = block.timestamp;
    }
    
    function withdraw() public {
        checkState();

        require(users[msg.sender].withdraw <= users[msg.sender].deposit * 365 / 100, "err: shouldn't withdraw more than 365%");

        uint256 amount = getRewardsSinceLastDeposit(msg.sender);
        uint256 fee = calculateFee(amount);
        users[msg.sender].lastTime = block.timestamp;
        users[msg.sender].withdraw += amount - fee;


        feeAddress.transfer(fee);

    }

    function deposit(address ref) public payable {
        require(initialized, "err: not started");
        if (users[msg.sender].lastTime != 0) {
            require(users[msg.sender].lastTime + 3600 * 24 * 7 < block.timestamp, "err: not in time");
        }
        require(msg.value >= 0.1 * 10**18, "err: should greater than 0.1");
        
        uint256 amount = msg.value;
        uint256 fee = calculateFee(amount);

        feeAddress.transfer(fee);
        

        users[msg.sender].deposit += amount - fee;

        require(users[msg.sender].deposit <= 100 * 10**18, "err: shouldn't greater than 100");

        users[msg.sender].lastTime = block.timestamp;
        // referral
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(users[msg.sender].referrer == address(0) && users[msg.sender].referrer != msg.sender) {
            users[msg.sender].referrer = ref;
        }

        if (users[msg.sender].referrer != address(0))
        {
            uint256 referralFee = amount * 5 / 100;
            users[users[msg.sender].referrer].bonus += referralFee;
            users[users[msg.sender].referrer].totalBonus += referralFee;
        }
    }
    
    function compoundRef() public {
        require(initialized, "err: not started");
        require(users[msg.sender].bonus > 0, "err: zero amount");

        users[msg.sender].deposit += users[msg.sender].bonus;
        users[msg.sender].bonus = 0;
        users[msg.sender].lastTime = block.timestamp;
    }

    function withdrawRef() public  {
        require(initialized, "err: not started");
        require(users[msg.sender].bonus > 0, "err: zero amount");


        address payable user = payable(msg.sender);

        user.transfer(users[msg.sender].bonus);
        users[msg.sender].bonus = 0;
    }

    function checkState() internal view {
        require(initialized, "err: not started");
        require(users[msg.sender].lastTime > 0, "err: no deposit");
        require(users[msg.sender].lastTime + 3600 * 24 * 7 < block.timestamp, "err: not in time");
    }
    
    function calculateFee(uint256 amount) private view returns(uint256) {
        return amount * feePercent / 100;
    }
    
    function start() public onlyOwner {
        require(initialized == false, "err: already started");
        initialized=true;
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
	function getUserReferralBonus(address addr) public view returns(uint256) {
		return users[addr].bonus;
	}

	function getUserReferralTotalBonus(address addr) public view returns(uint256) {
		return users[addr].totalBonus;
	}

	function getUserReferralWithdrawn(address addr) public view returns(uint256) {
		return users[addr].totalBonus - users[addr].bonus;
	}

	function getUserDepositAmount(address addr) public view returns(uint256) {
		return users[addr].deposit;
	}

	function getUserWithdrawAmount(address addr) public view returns(uint256) {
		return users[addr].withdraw;
	}

	function getUserCheckPoint(address addr) public view returns(uint256) {
		return users[addr].lastTime;
	}

    function getRewardsSinceLastDeposit(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(604800, block.timestamp - users[adr].lastTime);
        return secondsPassed * users[adr].deposit / 4320000;
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}