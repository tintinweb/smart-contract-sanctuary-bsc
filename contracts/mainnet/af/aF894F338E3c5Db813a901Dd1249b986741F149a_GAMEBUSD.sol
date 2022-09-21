/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;


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

    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
    }

    function owner() public view returns (address) {
      return _owner;
    }

    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract GAMEBUSD is Context, Ownable {
    address constant busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    uint256 constant private feePercent = 10;
    uint256 constant private refPercent = 10;
    uint256 constant private minDeposit = 20 * 10**18;
    bool private initialized = false;

    struct User {
		uint256 deposit;
        uint256 withdraw;
		uint256 lastTime;
		uint256 bonus;
		uint256 totalBonus;
	}

    mapping (address => User) private users;

    constructor() {
    }
    
    function compound() external {
        checkState();
        
        address msgSender = _msgSender();
        uint256 amount = getRewardsSinceLastDeposit(msgSender);
        users[msgSender].deposit += amount;

        users[msgSender].lastTime = block.timestamp;
    }
    
    function withdraw() external {
        checkState();

        address msgSender = _msgSender();
        require(users[msgSender].withdraw <= users[msgSender].deposit * 3, "err: shouldn't withdraw more than 3X");

        uint256 amount = getRewardsSinceLastDeposit(msgSender);
        users[msgSender].lastTime = block.timestamp;
        users[msgSender].withdraw += amount;

        ERC20(busd).transfer(msgSender, amount);
    }
    
    function deposit(address ref, uint256 amount) external {
        require(initialized, "err: not started");
        require(amount >= minDeposit, "err: should deposit at least 20 BUSD");

        address msgSender = _msgSender();

        ERC20(busd).transferFrom(msgSender, address(this), amount);

        uint256 fee = calculateFee(amount);
        ERC20(busd).transfer(owner(), fee);

        uint256 reward_amount = getRewardsSinceLastDeposit(msgSender);
        users[msgSender].deposit += amount - fee + reward_amount;

        users[msgSender].lastTime = block.timestamp;

        // referral
        if(ref == msgSender) {
            ref = address(0);
        }
        
        if (ref != address(0))
        {
            uint256 referralFee = amount * refPercent / 100;
            users[ref].bonus += referralFee;
            users[ref].totalBonus += referralFee;
        }
    }
    
    function compoundRef() external {
        address msgSender = _msgSender();
        require(users[msgSender].bonus > 0, "err: zero amount");

        uint256 reward_amount = getRewardsSinceLastDeposit(msgSender);
        users[msgSender].deposit += users[msgSender].bonus + reward_amount;
        users[msgSender].bonus = 0;
        users[msgSender].lastTime = block.timestamp;
    }

    function withdrawRef() external {
        address msgSender = _msgSender();
        require(users[msgSender].bonus > 0, "err: zero amount");

        ERC20(busd).transfer(msgSender, users[msgSender].bonus);
        users[msgSender].bonus = 0;
    }

    function checkState() internal view {
        require(initialized, "err: not started");
        address msgSender = _msgSender();
        require(users[msgSender].lastTime > 0, "err: no deposit");
        require(users[msgSender].lastTime + 3600 * 24 * 7 < block.timestamp, "err: not in time");
    }
    
    function calculateFee(uint256 amount) private pure returns(uint256) {
        return amount * feePercent / 100;
    }
    
    function start() public onlyOwner {
        require(initialized == false, "err: already started");
        initialized=true;
    }
    
	function getUserReferralBonus(address addr) external view returns(uint256) {
		return users[addr].bonus;
	}

	function getUserReferralTotalBonus(address addr) external view returns(uint256) {
		return users[addr].totalBonus;
	}

	function getUserReferralWithdrawn(address addr) external view returns(uint256) {
		return users[addr].totalBonus - users[addr].bonus;
	}

	function getUserDepositAmount(address addr) external view returns(uint256) {
		return users[addr].deposit;
	}

	function getUserWithdrawAmount(address addr) external view returns(uint256) {
		return users[addr].withdraw;
	}

	function getUserCheckPoint(address addr) external view returns(uint256) {
		return users[addr].lastTime;
	}

    function getRewardsSinceLastDeposit(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(604800, block.timestamp - users[adr].lastTime);
        return secondsPassed * users[adr].deposit / 2280000;
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}