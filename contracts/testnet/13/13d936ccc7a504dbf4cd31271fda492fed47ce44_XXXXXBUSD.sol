/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

// SPDX-License-Identifier: UNLICENSED
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

library SafeERC20 {

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(isContract(address(token)), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

contract XXXXXBUSD is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;
    //address private tokenAddr = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; mainnet
    address private tokenAddr = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; //testnet
    IERC20 public token;

	//uint256 constant public MIN = 10 ether; mainnet
    uint256 constant public MIN = 1 ether; //testnet
	uint256[] public REFERRAL_PERCENTS = [100];
	uint256 constant public TOTAL_REF = 100;
	uint256 constant public W_FEE = 500;
	uint256 constant public CEO_FEE = 90;
	uint256 constant public DEV_FEE = 10;
	uint256 constant public RATE = 100; 
	uint256 constant public MAX_R = 3; 
	uint256 constant public PERCENTS_DIVIDER = 1000;
	//uint256 constant public REWARD = 1000 ether; mainnet
    uint256 constant public REWARD = 2 ether; //testnet
	//uint256 constant public TIME_STEP = 1 days; mainnet
    uint256 constant public TIME_STEP = 1 minutes; //testnet
	//uint256 constant public W_PERIOD = 7 days; mainnet
    uint256 constant public W_PERIOD = 7 minutes; //testnet

	uint256 public totalInvested;
	uint256 public totalReferral;

	struct User {
		uint256 start;
		uint256 checkpoint;
		address referrer;
		uint256[1] levels;
		uint256 reserve;
		uint256 bonus;
		uint256 totalBonus;
		uint256 deposits;
		uint256 withdrawn;
		bool compoundStatus;
	}

	mapping (address => User) internal users;

	address payable public ceoWallet;
	address payable public devWallet;

	uint256 public topD_date;
	uint256 public topD_round;
	address public topD_tUser;
	uint256 public topD_tDeposit;
    address public topD_prev_tUser;
	mapping(uint256 => mapping(address => uint256)) public topD_users_deposits_sum;

	bool public init = false;


	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount, uint256 time);
	event NewReward(address indexed user, uint256 totalDeposit, uint256 reward, uint256 round, uint256 time);
	event Unstake(address indexed user, uint256 amount, uint256 time);
	event Withdrawn(address indexed user, uint256 amount, uint256 time);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor() {
		//ceoWallet = payable(); mainnet
        ceoWallet = payable(0x47b70fd05C0733D545100F641f40c87eE51A2003); //testnet
		//devWallet = payable(); mainnet
        devWallet = payable(0x47b70fd05C0733D545100F641f40c87eE51A2003); //testnet
		topD_round = 0;
		topD_tUser = address(0);
		topD_tDeposit = 0;

        token = IERC20(tokenAddr);

        signal_market(); //testnet
	}

	// initialized the Project
    function signal_market() public onlyOwner {
        init = true;
		topD_date = block.timestamp;
    }

	function invest(address referrer, uint256 _amount) public noReentrant {
        require(init, "Not Started Yet");
		require(_amount >= MIN,"lower than min deposit amount");

        uint256 depositAmount = _amount;
        require(depositAmount <= token.allowance(msg.sender, address(this)));
		token.safeTransferFrom(msg.sender, address(this), depositAmount);


		uint256 ceoFee = depositAmount * CEO_FEE / PERCENTS_DIVIDER;
		uint256 devFee = depositAmount * DEV_FEE / PERCENTS_DIVIDER;
        token.safeTransfer(ceoWallet, ceoFee);
        token.safeTransfer(devWallet, devFee);
		emit FeePayed(msg.sender, ceoFee + devFee);

		depositAmount -= (ceoFee + devFee);

		User storage user = users[msg.sender];

		if (user.referrer == address(0)) {
			if (users[referrer].start > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 1; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] += 1;
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 1; i++) {
				if (upline != address(0)) {
					uint256 amount = depositAmount * REFERRAL_PERCENTS[i] / PERCENTS_DIVIDER;
					users[upline].bonus = users[upline].bonus + amount;
					users[upline].totalBonus = users[upline].totalBonus + amount;
					totalReferral = totalReferral + amount;
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}else{
			uint256 amount = depositAmount * TOTAL_REF / PERCENTS_DIVIDER;
            token.safeTransfer(ceoWallet, amount);
			totalReferral = totalReferral + amount;
		}

		if (user.start == 0) {
			user.compoundStatus = false;
			user.start = block.timestamp;
			emit Newbie(msg.sender);
		}

		uint256 tDiv = getAndUpdateUserDividends(msg.sender);
		if(tDiv > 0){
			user.reserve += tDiv;
		}

		user.deposits += depositAmount;
		user.checkpoint = block.timestamp;

		totalInvested += depositAmount;
		emit NewDeposit(msg.sender, depositAmount, block.timestamp);

		topD_users_deposits_sum[topD_round][msg.sender] += depositAmount;
		if(topD_users_deposits_sum[topD_round][msg.sender] > topD_tDeposit){
			topD_tDeposit = topD_users_deposits_sum[topD_round][msg.sender];
			topD_tUser = msg.sender;
		}
		if((topD_date + W_PERIOD) < block.timestamp){
			topDraw();
		}
	}

	function withdraw() public noReentrant {
        require(init, "Not Started Yet");
		User storage user = users[msg.sender];

		require( (user.checkpoint + W_PERIOD) < block.timestamp, "only once a week");
		uint256 totalAmount = getAndUpdateUserDividends(msg.sender);

		if(user.reserve > 0){
			totalAmount += user.reserve;
			user.reserve = 0;
		}
		require(totalAmount > 0, "User has no dividends");

		totalAmount -= (totalAmount * W_FEE / PERCENTS_DIVIDER);

		uint256 contractBalance = getContractBalance();
		if (contractBalance < totalAmount) {
			user.reserve = totalAmount - contractBalance;
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
		user.withdrawn += totalAmount;

        token.safeTransfer(msg.sender, totalAmount);
		emit Withdrawn(msg.sender, totalAmount, block.timestamp);

        if((topD_date + W_PERIOD) < block.timestamp){
			topDraw();
		}
	}

	function compound() public noReentrant {
        require(init, "Not Started Yet");
		User storage user = users[msg.sender];

		require((user.checkpoint + W_PERIOD) < block.timestamp, "only once a week");
		uint256 totalAmount = getAndUpdateUserDividends(msg.sender);
		require(totalAmount >= 0, "no dividends");
		
		if(user.compoundStatus == false){
			user.compoundStatus = true;
		}
			
		user.deposits += totalAmount;
		user.checkpoint = block.timestamp;
		user.withdrawn += totalAmount;
		totalInvested += totalAmount;

		emit NewDeposit(msg.sender, totalAmount, block.timestamp);

        if((topD_date + W_PERIOD) < block.timestamp){
			topDraw();
		}
	}

	function refCompound() public noReentrant {
        require(init, "Not Started Yet");
		User storage user = users[msg.sender];
		require(user.bonus > 0, "no referral commission");
		uint256 totalAmount = user.bonus;
		user.bonus = 0;

		uint256 tDiv = getAndUpdateUserDividends(msg.sender);
		if(tDiv > 0){
			user.reserve += tDiv;
		}
		
		user.deposits += totalAmount;
		user.checkpoint = block.timestamp;
		user.withdrawn += totalAmount;
		totalInvested += totalAmount;

		emit NewDeposit(msg.sender, totalAmount, block.timestamp);

        if((topD_date + W_PERIOD) < block.timestamp){
			topDraw();
		}
	}

	function unstake() public noReentrant {
        require(init, "Not Started Yet");
		User storage user = users[msg.sender];
		require(user.compoundStatus == false, "unstake not allowed, you used compound system");
		uint256 totalDeposit = user.deposits;
		require(totalDeposit > user.withdrawn,"not allowed, withdraw is more than total deposit");
		uint256 totalAmount = (totalDeposit - user.withdrawn) / 2;
		user.checkpoint = block.timestamp;
		user.deposits = 0;
		user.withdrawn = 0;

        token.safeTransfer(msg.sender, totalAmount);
		emit Unstake(msg.sender, totalAmount, block.timestamp);

        if((topD_date + W_PERIOD) < block.timestamp){
			topDraw();
		}
	}

	function topDraw() public {
        require(init, "Not Started Yet");
		require( (topD_date + W_PERIOD) < block.timestamp, "only once a week");

		if (getContractBalance() >= REWARD) {
            topD_prev_tUser = topD_tUser;
            token.safeTransfer(topD_tUser, REWARD);
		    emit NewReward(topD_tUser, topD_tDeposit,REWARD, topD_round, block.timestamp);
		}else {
            topD_prev_tUser = address(0);
        }

		topD_date = block.timestamp;
		topD_tUser = address(0);
		topD_tDeposit = 0;
		topD_round++;
	}

	function getContractBalance() public view returns (uint256) {
		return token.balanceOf(address(this));
	}

	function getAndUpdateUserDividends(address userAddress) private returns (uint256) {
		User storage user = users[userAddress];
		uint256 totalAmount;
		uint256 max = user.deposits * MAX_R;
		if (user.withdrawn < max) {
			uint256 share = user.deposits * RATE / PERCENTS_DIVIDER;
			uint256 from = user.start > user.checkpoint ? user.start : user.checkpoint;
			uint256 to = block.timestamp;
			if (from < to) {
				totalAmount = (share * (to - from) / TIME_STEP);
			}
		}
		if(user.withdrawn + totalAmount > max){
			totalAmount = max - user.withdrawn;
			user.withdrawn = max;
		}

		return totalAmount;
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];
		uint256 totalAmount;
		uint256 max = user.deposits * MAX_R;
		if (user.withdrawn < max) {
			uint256 share = user.deposits * RATE / PERCENTS_DIVIDER;
			uint256 from = user.start > user.checkpoint ? user.start : user.checkpoint;
			uint256 to = block.timestamp;
			if (from < to) {
				totalAmount = (share * (to - from) / TIME_STEP);
			}
		}
		if(user.withdrawn + totalAmount > max){
			totalAmount = max - user.withdrawn;
		}

		return totalAmount;
	}

	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256[1] memory referrals) {
		return (users[userAddress].levels);
	}

	function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return users[userAddress].levels[0];
	}

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}

	function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus - (users[userAddress].bonus);
	}

	function getUserAvailable(address userAddress) public view returns(uint256) {
		return users[userAddress].reserve + (getUserDividends(userAddress));
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		return users[userAddress].deposits;
	}

	function getUserDepositInfo(address userAddress) public view returns(uint256 amount, uint256 withdrawn, uint256 start, bool isFinished) {
	    User storage user = users[userAddress];
		amount = user.deposits;
		withdrawn = user.withdrawn;
		start = user.start;
		if(user.withdrawn < user.deposits * MAX_R){
			isFinished = false;
		}
		else{
			isFinished = true;
		}
	}

	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalBonus, uint256 _contractBalance) {
		return(totalInvested, totalReferral, getContractBalance());
	}

	function getTopDepositInfo() public view returns(uint256 round, uint256 tDate, address tUser, uint256 tDeposit, address prevUser) {
		return(topD_round, topD_date, topD_tUser, topD_tDeposit, topD_prev_tUser);
	}

	function getUserInfo(address userAddress) public view returns(uint256 checkpoint, uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals, uint256 userBonus, uint256 userTotalBonus) {
		return(getUserCheckpoint(userAddress), getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress), getUserReferralBonus(userAddress), getUserReferralTotalBonus(userAddress));
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}