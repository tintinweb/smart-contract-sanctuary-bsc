/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;


/**
*
*    ███████╗████████╗██╗  ██╗     █████╗ ██╗   ██╗████████╗ ██████╗ ███╗   ███╗██╗███╗   ██╗███████╗██████╗ 
*    ██╔════╝╚══██╔══╝██║  ██║    ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗████╗ ████║██║████╗  ██║██╔════╝██╔══██╗
*    █████╗     ██║   ███████║    ███████║██║   ██║   ██║   ██║   ██║██╔████╔██║██║██╔██╗ ██║█████╗  ██████╔╝
*    ██╔══╝     ██║   ██╔══██║    ██╔══██║██║   ██║   ██║   ██║   ██║██║╚██╔╝██║██║██║╚██╗██║██╔══╝  ██╔══██╗
*    ███████╗   ██║   ██║  ██║    ██║  ██║╚██████╔╝   ██║   ╚██████╔╝██║ ╚═╝ ██║██║██║ ╚████║███████╗██║  ██║
*    ╚══════╝   ╚═╝   ╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
*
*/

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

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
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

contract ETHAutoMiner is Context, Ownable {
    address eth = 0x690afF4a3A0d346332b8b3edDF6034Fe48C2caDb;//0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    address private feeAddress;
    uint256 private feePercent = 5;
    uint256 private feeTVLPercent = 5;
    uint256 private referralPercent = 3;
    uint256 private minDeposit = 10**16;
    uint256 private minerPower = 7560000; // 8% weekly
    uint256 private nextActionTime = 2 * 60;//3600 * 24 * 7;
    uint256 private actionTime = 1 * 60;//2600 * 24;
    uint256 private maxPayoutPercent = 365;
    uint256 private maxCompoundPercent = 100;

    bool private initialized = false;

    struct User {
        uint256 realDeposit;
		uint256 deposit;
        uint256 withdraw;
		uint256 lastTime;
		address referrer;
		uint256 bonus;
		uint256 totalBonus;
	}

    mapping (address => User) private users;

    constructor(address feeAddr) {
        feeAddress = feeAddr;
    }
    
    function compound() public {
        checkState();
        
        uint256 amount = getRewardsSinceLastDeposit(msg.sender);
        users[msg.sender].deposit += amount;
        users[msg.sender].withdraw += amount;
        require(users[msg.sender].deposit <= users[msg.sender].realDeposit * (1 + maxCompoundPercent / 100), "err: shouldn't compound over max compound");
        
        users[msg.sender].lastTime = block.timestamp;
    }
    
    function withdraw() public {
        checkState();

        require(users[msg.sender].withdraw <= users[msg.sender].deposit * maxPayoutPercent / 100, "err: shouldn't withdraw more than max payout");

        uint256 amount = getRewardsSinceLastDeposit(msg.sender);
        uint256 fee = calculateFee(amount);
        uint256 tvlfee = calculateTVLFee(amount);
        users[msg.sender].lastTime = block.timestamp;
        users[msg.sender].withdraw += amount - (fee + tvlfee);
        ERC20(eth).transfer(feeAddress, fee);

        ERC20(eth).transfer(address(msg.sender), amount - (fee + tvlfee));
    }
    
    function deposit(address ref, uint256 amount) public {
        require(initialized, "err: not started");
        if (users[msg.sender].lastTime != 0) {
            require((block.timestamp - users[msg.sender].lastTime) % (nextActionTime + actionTime) > nextActionTime, "err: not in time");
        }
        require(amount >= minDeposit, "err: should greater than min deposit");

        ERC20(eth).transferFrom(address(msg.sender), address(this), amount);
        uint256 fee = calculateFee(amount);
        uint256 tvlfee = calculateTVLFee(amount);
        ERC20(eth).transfer(feeAddress, fee);

        uint256 rewards = getRewardsSinceLastDeposit(msg.sender);
        users[msg.sender].deposit += amount - (tvlfee + fee) + rewards;
        users[msg.sender].realDeposit += amount - (tvlfee + fee);

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
            uint256 referralFee = amount * referralPercent / 100;
            users[users[msg.sender].referrer].bonus += referralFee;
            users[users[msg.sender].referrer].totalBonus += referralFee;
        }
    }
    
    function compoundRef() public {
        require(initialized, "err: not started");
        require(users[msg.sender].bonus > 0, "err: zero amount");

        uint256 rewards = getRewardsSinceLastDeposit(msg.sender);
        users[msg.sender].deposit += users[msg.sender].bonus + rewards;
        users[msg.sender].bonus = 0;
        users[msg.sender].lastTime = block.timestamp;
    }

    function withdrawRef() public {
        require(initialized, "err: not started");
        require(users[msg.sender].bonus > 0, "err: zero amount");

        ERC20(eth).transfer(address(msg.sender), users[msg.sender].bonus);
        users[msg.sender].bonus = 0;
    }

    function checkState() internal view {
        require(initialized, "err: not started");
        require(users[msg.sender].lastTime > 0, "err: no deposit");
        require((block.timestamp - users[msg.sender].lastTime) % (nextActionTime + actionTime) > nextActionTime, "err: not in time");
    }
    
    function calculateFee(uint256 amount) private view returns(uint256) {
        return amount * feePercent / 100;
    }
    
    function calculateTVLFee(uint256 amount) private view returns(uint256) {
        return amount * feeTVLPercent / 100;
    }

    function start() public onlyOwner {
        require(initialized == false, "err: already started");
        initialized=true;
    }
    
    function getBalance() public view returns(uint256) {
        return ERC20(eth).balanceOf(address(this));
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

	function getUserRealDepositAmount(address addr) public view returns(uint256) {
		return users[addr].realDeposit;
	}

	function getUserWithdrawAmount(address addr) public view returns(uint256) {
		return users[addr].withdraw;
	}

	function getUserCheckPoint(address addr) public view returns(uint256) {
		return users[addr].lastTime;
	}

    function getRewardsSinceLastDeposit(address adr) public view returns(uint256) {
        uint256 secondsSinceLastAction = block.timestamp - users[adr].lastTime;
        uint256 cutoffTime = secondsSinceLastAction % (nextActionTime + actionTime);
        uint256 secondsPassed=min(nextActionTime, cutoffTime);
        return secondsPassed * users[adr].deposit / minerPower;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function setFeeAddress(address addr) public onlyOwner {
        require(addr != address(0));
        feeAddress = addr;
    }
    
    function setFeePercent(uint256 percent) public onlyOwner {
        require(percent > 0);
        feePercent = percent;
    }

    function setTVLFeePercent(uint256 percent) public onlyOwner {
        feeTVLPercent = percent;
    }

    function setMinerPower(uint256 power) public onlyOwner {
        require(power > 0);
        minerPower = power;
    }

    function setReferralPercent(uint256 percent) public onlyOwner {
        require(percent > 0);
        referralPercent = percent;
    }

    function setMinDeposit(uint256 amount) public onlyOwner {
        minDeposit = amount;
    }

    function setMaxCompoundPercent(uint256 percent) public onlyOwner {
        require(percent > 0);
        maxCompoundPercent = percent;
    }

    function setMaxPayoutPercent(uint256 percent) public onlyOwner {
        require(percent > 200);
        maxPayoutPercent = percent;
    }

    function setNextActionTime(uint256 _days) public onlyOwner {
        require(_days > 0);
        nextActionTime = _days * 3600 * 24;
    }

    function setActionTime(uint256 _hours) public onlyOwner {
        require(_hours > 200);
        actionTime = _hours * 3600;
    }
}