/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
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

contract WRTEST22 is Context, Ownable {
    address wings = 0x5E53cca99309B3A70Ed02d3A56556f222b27D8ef;
    bool private initialized = false;
    bool public isPaused;
    uint[2] public depositFee = [500, 500];
    uint[2] public withdrawFee = [500, 500];
    uint public compoundFee = 500;
    address public wallet1;
    address public wallet2;

    struct User {
		uint256 deposit;
        uint256 withdraw;
		uint256 lastTime;
		address referrer;
		uint256 bonus;
		uint256 totalBonus;
	}

    mapping (address => User) private users;

    modifier checkPaused() {
        require(isPaused == false, "err: deposits and compounding paused");
        _;
    }

    constructor() {
    }
    
    function compound() public checkPaused{
        checkState();
        
        uint256 amount = getRewardsSinceLastDeposit(msg.sender);
        uint256 fee = _takeFee(amount, 3);
        users[msg.sender].deposit += amount - fee;

        require(users[msg.sender].deposit <= 10000 * 10**18, "err: shouldn't greater than 10000");
        
        users[msg.sender].lastTime = block.timestamp;
    }
    
    function withdraw() public {
        checkState();

        require(users[msg.sender].withdraw <= users[msg.sender].deposit * 150 / 100, "err: shouldn't withdraw more than 365%");

        uint256 amount = getRewardsSinceLastDeposit(msg.sender);
        uint256 fee = _takeFee(amount, 2);
        users[msg.sender].lastTime = block.timestamp;
        users[msg.sender].withdraw += amount - fee;
        ERC20(wings).transfer(address(msg.sender), amount - fee);
    }
    
    function deposit(address ref, uint256 amount) public checkPaused{
        require(initialized, "err: not started");
        if (users[msg.sender].lastTime != 0) {
            require(users[msg.sender].lastTime + 60 < block.timestamp, "err: not in time");
        }
        require(amount >= 10 * 10**18, "err: should greater than 10");

        ERC20(wings).transferFrom(address(msg.sender), address(this), amount);
        uint256 fee = _takeFee(amount, 1);

        users[msg.sender].deposit += amount - fee;

        require(users[msg.sender].deposit <= 10000 * 10**18, "err: shouldn't greater than 10000");

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

    function withdrawRef() public {
        require(initialized, "err: not started");
        require(users[msg.sender].bonus > 0, "err: zero amount");

        ERC20(wings).transfer(address(msg.sender), users[msg.sender].bonus);
        users[msg.sender].bonus = 0;
    }

    function checkState() internal view {
        require(initialized, "err: not started");
        require(users[msg.sender].lastTime > 0, "err: no deposit");
        require(users[msg.sender].lastTime + 60 < block.timestamp, "err: not in time");
    }

    function _takeFee(uint256 amount, uint _type) internal returns(uint256) {
        if (_type == 1) {
            uint fee1 = amount * depositFee[0] / 10000;
            uint fee2 = amount * depositFee[1] / 10000;
            ERC20(wings).transfer(wallet1, fee1);
            ERC20(wings).transfer(wallet2, fee2);
            return fee1 + fee2;
        } else if (_type == 2) {
            uint fee1 = amount * withdrawFee[0] / 10000;
            uint fee2 = amount * withdrawFee[1] / 10000;
            ERC20(wings).transfer(wallet1, fee1);
            ERC20(wings).transfer(wallet2, fee2);
            return fee1 + fee2;
        } else if (_type == 3) {
            uint fee1 = amount * compoundFee / 10000;
            ERC20(wings).transfer(wallet1, fee1);
            return fee1;
        }
        return 0;
    }
    
    function start() public onlyOwner {
        require(initialized == false, "err: already started");
        initialized=true;
    }

    function emergencyWithdraw(address _token, uint _amount) external onlyOwner {
        ERC20(_token).transfer(owner(), _amount);
    }

    function togglePause() external onlyOwner {
        isPaused = !isPaused;
    }

    function setWallets(address _wallet1, address _wallet2) external onlyOwner {
        wallet1 = _wallet1;
        wallet2 = _wallet2;
    }

    function setFeePercentages(uint[2]memory _depositFee, uint[2]memory _withdrawFee, uint _compoundFee) external onlyOwner {
        depositFee = _depositFee;
        withdrawFee = _withdrawFee;
        compoundFee = _compoundFee;
    }
    
    function getBalance() public view returns(uint256) {
        return ERC20(wings).balanceOf(address(this));
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
        uint256 secondsPassed=min(60, block.timestamp - users[adr].lastTime);
        return secondsPassed * users[adr].deposit / 1000;
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}