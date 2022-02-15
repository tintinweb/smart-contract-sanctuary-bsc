// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/**
 * Tool to swap 1 to 1 tokens in big amounts.
 * Keep in mind tokens are expected to have the same decimal amount and to be exactly 1 to 1
 * Recieve a +5% bonus of the new tokens for all deposits before bonusTime.
 * End time and bonus time can be upgradable, but shold be over origin time.
 * By @developersuper
 */

import "./Auth.sol";
import "./IBEP20.sol";

contract TokenMigrator is Auth {

	struct Info{
		address tokenIn;
		address tokenOut;
		uint256 decimals;
		uint256 startTime;
		uint256 bonusTime;
	}

	uint256 immutable startTime = 1644678000;
	uint256 public bonusTime = 	1647097200;

	address public tokenIn = 0xA7339FAD4feDD614E2C113698Fd10fF334F98263;
	address public tokenOut;

	bool public claimable = false;

	mapping (address => uint256) public deposits;
	mapping (address => uint256) public claimed;

	event Deposit(address indexed depositer, uint256 quantity);
	event Claimed(address indexed receiver, uint256 quantity);

	constructor() Auth(msg.sender) {
	}

	/** setters **/
	function updateBonusTime(uint256 updatedTime_) external authorized {
		require(updatedTime_ > bonusTime, "Migrator::must be after old bonustime");
		bonusTime = updatedTime_;
	}


	function setClaimable(bool value) external authorized {
		require(value != claimable, "Migrator::must not be same with old value");
		if(value == true) {
			require(tokenOut != address(0), "Migrator::invalid out token address");
		}
		claimable = value;
	}

	function setTokenOut(address tokenAddress) external authorized {
		require(tokenAddress != address(0), "Migrator::invalid token address");
		tokenOut = tokenAddress;
	}

	function deposit(uint256 amount) external {
		require(block.timestamp > startTime, "Migrator::not started yet");
		require(amount > 0, "Migrator::must be over 0");

		IBEP20(tokenIn).transferFrom(msg.sender, address(this), amount);

		if(block.timestamp <= bonusTime) {
			deposits[msg.sender] += (amount * 105 / 100);
		}else {
			deposits[msg.sender] += amount;
		}

		emit Deposit(msg.sender, amount);
	}

	function depositAll() external {
		require(block.timestamp > startTime, "Migrator::not started yet");
		
		uint256 amount = IBEP20(tokenIn).balanceOf(msg.sender);
		require(amount > 0, "Migrator::must be over 0");
		require(IBEP20(tokenIn).allowance(msg.sender, address(this)) >= amount, "Migrator::not approved to transfer");

		IBEP20(tokenIn).transferFrom(msg.sender, address(this), amount);

		if(block.timestamp <= bonusTime) {
			deposits[msg.sender] += (amount * 105 / 100);
		}else {
			deposits[msg.sender] += amount;
		}

		emit Deposit(msg.sender, amount);
	}

	function claim() external {
		require(claimable && block.timestamp > startTime, "Migrator::not claimable");
		require(deposits[msg.sender] > 0, "Migrator::no balance");

		uint256 amount = deposits[msg.sender];
		deposits[msg.sender] = 0;
		claimed[msg.sender] += amount;

		IBEP20(tokenOut).transfer(msg.sender, amount);
		emit Claimed(msg.sender, amount);
	}

	/** getters **/

	function getInfo() external view returns (Info memory) {
		return Info(tokenIn, tokenOut, IBEP20(tokenIn).decimals(), startTime, bonusTime);
	}

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

/* Casper. */


// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}