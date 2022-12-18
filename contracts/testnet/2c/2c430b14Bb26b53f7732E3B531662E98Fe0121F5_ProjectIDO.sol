// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

struct UserInfo {
	uint256 id;
	uint256 level;
	//index in level
	uint256 levelIndex;
	uint256 firstIdoTime;
	uint256 memberPoints;
	//=0 not initialized
	address parent;
}

interface IVNSCPD {
	function mint(address to, uint256 amount) external;
}

interface IVNSToken {
	function mint(address to, uint256 amount) external;

	function lockIdoAmount(address user, uint256 amount) external;

	function lockAirdropAmount(address user, uint256 amount) external;
}

interface IVNSNFT {
	function mintTo(address to, uint256 num) external returns (uint256);

	function blindBoxTo(address to) external returns (uint256);
}

interface IVNSMemberShip {
	function getUserInfo(address user) external view returns (UserInfo memory);

	function addUser(address user) external;

	function firstIdo(address user, address parent) external;

	function addMemberPoints(address user, uint256 points) external;

	function updateLevel(address user) external;
    function getLevelLength(uint256 level) external returns(uint256);

}

interface INFTStakingPool {
	function getStakedNft(address user) external returns (uint256[] memory);
}

interface IStakingPool {
	function stakeTo(
		uint256 poolId,
		uint256 amount,
		address to
	) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IVNS.sol";

interface IUniswapV2Pair {
	function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Factory {
	function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract ProjectIDO is Ownable {
	struct IdoConfig {
		address projectToken;
		uint256 price;
		uint256 startTime;
		uint256 endTime;
		uint256 claimExpTime;
		uint256 vnsPrice;
		address memberShip;
		address uniV2Factory;
		address[3] tokenAddress; //vns,cpd,usdt
		uint256[3] tokenTotalQuota; //taotal quota [vns,cpd,usdt]
	}

	enum TokenType {
		VNS_TOKEN,
		CPD_TOKEN,
		USDT_TOKEN
	}

	struct ProjectIdoUser {
		uint256 firstIdoTime;
		uint256[3] idoAmount; //amount by token[vns,cpd,usdt]
		uint256[3] idoQuota; //quota by u[vns,cpd,usdt]
		uint256 rewardVNSAmount;
		uint256 projectTokenClaimed;
	}
	IdoConfig config;

	uint256 public startClaimTime;
	uint256[3] public tokenQuotaPerShare; //vns,cpd,usdt
	uint256[3] public totalIdoAmount;
	uint256 public totalIdoAmountByUSDT; //total amount counted by usdt
	uint256 public totalProjectTokenClaimed;
	uint256 public totalRewardVNSAmount;
	uint256 public vnsPrice;

	mapping(address => ProjectIdoUser) users;

	event Claim(address indexed user, address indexed token, uint256 amount);
	event Redeem(address indexed user, address indexed token, uint256 amount);
	event Ido(address indexed user, address indexed token, uint256 tokenAmount, uint256 uAmount);

	constructor() {}

	function getUserInfo(address user) external view returns (ProjectIdoUser memory _user) {
		_user = users[user];
	}

	function getUserMaxIdoAmount(
		address user
	) public view returns (uint256 vnsQuota, uint256 cpdQuota, uint256 usdtQuota) {
		UserInfo memory userInfo = IVNSMemberShip(config.memberShip).getUserInfo(user);
		uint256 level = userInfo.level;
		uint256 coefficient;
		if (level == 3) coefficient = 10;
		if (level == 2) coefficient = 5;
		if (level == 1) coefficient = 1;

		vnsQuota = tokenQuotaPerShare[0] * coefficient;
		cpdQuota = tokenQuotaPerShare[1] * coefficient;
		usdtQuota = tokenQuotaPerShare[2] * coefficient;
	}

	function sweepToken(IERC20 token, uint256 amount) external onlyOwner {
		uint256 sweepAmount = token.balanceOf(address(this));
		require(amount < sweepAmount, "invalid amount");
		token.transfer(msg.sender, amount);
	}

	function setIdoConfig(IdoConfig memory _config) external onlyOwner {
		require(_config.endTime >= _config.startTime, "invalid time");
		require(_config.price > 0, "invalid price");
		config = _config;
	}

	function getIdoConfig() external view returns (IdoConfig memory _config) {
		_config = config;
	}

	function calQuota() external onlyOwner {
		uint256 level1User = IVNSMemberShip(config.memberShip).getLevelLength(1);
		uint256 level2User = IVNSMemberShip(config.memberShip).getLevelLength(2);
		uint256 level3User = IVNSMemberShip(config.memberShip).getLevelLength(3);
		uint256 denominator = (level1User + level2User * 5 + level3User * 10);

		tokenQuotaPerShare[0] = config.tokenTotalQuota[0] / denominator;
		tokenQuotaPerShare[1] = config.tokenTotalQuota[1] / denominator;
		tokenQuotaPerShare[2] = config.tokenTotalQuota[2] / denominator;
	}

	function getUsdtAmount(uint256 vnsAmount) internal view returns (uint256 usdtAmount) {
		if (config.vnsPrice == 0) {
			address VNS = config.tokenAddress[uint256(TokenType.VNS_TOKEN)];
			address USDT = config.tokenAddress[uint256(TokenType.VNS_TOKEN)];

			address lpAddress = IUniswapV2Factory(config.uniV2Factory).getPair(VNS, USDT);
			(uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(lpAddress).getReserves();
			(uint256 reserveInput, uint256 reserveOutput) = VNS < USDT ? (reserve0, reserve1) : (reserve1, reserve0);

			usdtAmount = (vnsAmount * 9975 * reserveOutput) / (reserveInput * 10000 + vnsAmount * 9975);
		} else {
			usdtAmount = vnsAmount * vnsPrice;
		}
	}

	function ido(TokenType tokentype, uint256 amount) external {
		require(config.tokenTotalQuota[uint256(tokentype)] > 0, "invalid tokentype");
		require(config.startTime != 0, "invalid time0");
		require(block.timestamp > config.startTime, "invalid time1");
		require(block.timestamp < config.endTime, "invalid time2");

		ProjectIdoUser storage user = users[msg.sender];
		if (user.firstIdoTime == 0) user.firstIdoTime == block.timestamp;

		uint256 uamount;
		uint256 index = uint256(tokentype);
		address tAddress = config.tokenAddress[index];
		uint256[3] memory maxQuota;
		(maxQuota[0], maxQuota[1], maxQuota[2]) = getUserMaxIdoAmount(msg.sender);

		if (tokentype == TokenType.VNS_TOKEN) {
			uamount = getUsdtAmount(amount);
		} else if (tokentype == TokenType.CPD_TOKEN) {
			uamount = amount / 100; //price 0.01
		} else if (tokentype == TokenType.USDT_TOKEN) {
			uamount = amount;
		} else {
			revert("!!!");
		}
		IERC20(tAddress).transferFrom(msg.sender, address(this), amount);

		user.idoAmount[index] += amount;
		user.idoQuota[index] += uamount;
		require(user.idoQuota[index] <= maxQuota[index], "exceeded maximum quota");
		emit Ido(msg.sender, tAddress, amount, uamount);

		totalIdoAmount[index] += amount;
		totalIdoAmountByUSDT += uamount;
	}

	function startClaim() external onlyOwner {
		require(block.timestamp > config.endTime, "invalid time0");
		require(startClaimTime == 0, "invalid time1");
		startClaimTime = block.timestamp;
	}

	function redeem(TokenType tokentype, uint256 amount) external {
		require(startClaimTime != 0, "invalid time1");
		require(block.timestamp > startClaimTime, "invalid time2");
		require(block.timestamp < startClaimTime + config.claimExpTime, "invalid time3");

		uint256 index = uint256(tokentype);
		address tAddress = config.tokenAddress[index];

		ProjectIdoUser storage user = users[msg.sender];
		require(user.idoAmount[index] >= amount, "invalid amount");

		IERC20(tAddress).transfer(msg.sender, amount);

		uint256 uamount = (amount * user.idoQuota[index]) / user.idoAmount[index];

		user.idoAmount[index] -= amount;
		user.idoQuota[index] -= uamount;
		totalIdoAmount[index] -= amount;
		totalIdoAmountByUSDT -= uamount;

		emit Redeem(msg.sender, tAddress, amount);

		if (tokentype == TokenType.VNS_TOKEN) {
			uint256 rewardAmount = (amount * (block.timestamp - user.firstIdoTime)) / (1000 * 1 days);
			IERC20(tAddress).transfer(msg.sender, rewardAmount);
			totalRewardVNSAmount += rewardAmount;
			user.rewardVNSAmount += rewardAmount;
		}
	}

	function claim(TokenType tokentype, uint256 amount) external {
		require(startClaimTime != 0, "invalid time1");
		require(block.timestamp > startClaimTime, "invalid time2");
		require(block.timestamp < startClaimTime + config.claimExpTime, "invalid time3");

		uint256 index = uint256(tokentype);
		address tAddress = config.tokenAddress[index];

		ProjectIdoUser storage user = users[msg.sender];
		require(user.idoAmount[index] >= amount, "invalid amount");

		uint256 uamount = (amount * user.idoQuota[index]) / user.idoAmount[index];
		user.idoAmount[index] -= amount;
		user.idoQuota[index] -= uamount;
		totalIdoAmount[index] -= amount;
		totalIdoAmountByUSDT -= uamount;

		uint256 pending = uamount / config.price;

		IERC20(config.projectToken).transfer(msg.sender, pending);

		emit Claim(msg.sender, config.projectToken, pending);

		user.projectTokenClaimed = pending;
		totalProjectTokenClaimed += pending;

		if (tokentype == TokenType.VNS_TOKEN) {
			uint256 rewardAmount = (amount * (block.timestamp - user.firstIdoTime)) / (1000 * 1 days);
			IERC20(tAddress).transfer(msg.sender, rewardAmount);
			totalRewardVNSAmount += rewardAmount;
			user.rewardVNSAmount += rewardAmount;
		}
	}
}