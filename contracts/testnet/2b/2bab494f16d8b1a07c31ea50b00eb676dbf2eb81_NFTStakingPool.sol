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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

struct UserInfo {
	uint256 id;
	uint256 level;
	uint256 levelIndex; //index in level
	uint256 firstIdoTime;
	uint256 lastIdoTime;
	uint256 lastTransferTime;
	bool alreadyTransferred;
	uint256 memberPoints;
	uint256 pointsRefunded;//max memberPoints*0.9
	address parent; //=0 not initialized
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

	function bindParent(address user, address parent) external;
function recordTrans(address user)external ;

	function addMemberPoints(address user, uint256 points) external;

	function updateLevel(address user) external;

	function getLevelLength(uint256 level) external returns (uint256);
}

interface INFTStakingPool {
	function getStakedNft(address user) external returns (uint256[] memory);
	function dividend(uint256 amount) external;
}

interface IStakingPool {
	function stakeTo(uint256 poolId, uint256 amount, address to) external;
	function dividend(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "./IVNS.sol";

interface IUniswapV2Router02 {
	function addLiquidity(
		address tokenA,
		address tokenB,
		uint256 amountADesired,
		uint256 amountBDesired,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	)
		external
		returns (
			uint256 amountA,
			uint256 amountB,
			uint256 liquidity
		);

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;
}

contract NFTStakingPool is INFTStakingPool, Ownable, IERC721Receiver {
	struct NFTStaker {
		uint256[] ids; //staked ids
		uint256 totalRewardVNS; // total rewarded token amount
		uint256 totalRewardCPD; // total rewarded token amount
		uint256 lastDividendClaimTime; // User's last claim time.
	}
	struct NFTInfo {
		uint256 nftClaimedVns;
		uint256 nftClaimedCpd;
		uint256 nftDeployTime;
		uint256 lastVNSClaimTime;
		uint256 lastCPDClaimTime;
	}
	//vns & cpd daily quota
	uint256 public constant DAY_QUOTA = 500 * 1e18;
	uint256 public constant MAX_VNS_QUOTA = 500000 * 1e18;

	IERC721 public immutable VNS_NFT;
	address public immutable VNS;
	address public immutable CPD;
	address public immutable USDT;
	address public immutable LP_VNS_USDT;
	address public immutable UNI_V2_ROUTER02; //IUniswapV2Router02

	uint256 public rewardVNSPerSecond; // rewardToken tokens  per second.
	uint256 public totalStaked; //total staked amount;
	uint256 public totalRewardVNS; //total reward amount;
	uint256 public totalRewardCPD; //total reward amount;

	address public lpStakingPool;

	//90 / 180 pool id
	uint256 public lpStakingPoolId;
	uint256 public dividendClaimColdTime = 1 days;
	uint256 public curDividendBalance;
	uint256 public totalDividendAmount;

	bool public isOpen = true;

	mapping(address => NFTStaker) public stakers;
	mapping(uint256 => NFTInfo) public nftInfo;

	error InvalidId(uint256 id);
	error NotEnoughBalance(address token, uint256 balance);

	event Stake(address user, uint256 amount);
	event Withdraw(address user, uint256 amount);
	event RewardTokenTransfer(address token, address user, uint256 amount);
	event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);

	modifier needPoolOpen() {
		require(isOpen, "closed");
		_;
	}

	constructor(
		address _usdt,
		address _rewardVNS,
		address _rewardCPD,
		address _uniswapV2Router,
		address _lpVnsUsdt,
		address _stakedToken
	) {
		USDT = _usdt;
		VNS = _rewardVNS;
		CPD = _rewardCPD;
		VNS_NFT = IERC721(_stakedToken);
		UNI_V2_ROUTER02 = _uniswapV2Router;
		LP_VNS_USDT = _lpVnsUsdt;
	}

	function setDividendClaimColdTime(uint256 coldtime) external onlyOwner {
		require(coldtime > 1 days, "minimum 1 days");
		dividendClaimColdTime = coldtime;
	}

	function toggleSwitch() external onlyOwner {
		isOpen = !isOpen;
	}

	function getStakedNft(address user) external view override returns (uint256[] memory) {
		return stakers[user].ids;
	}

	function sweepToken(IERC20 token)external onlyOwner {
		token.transfer(msg.sender, token.balanceOf(address(this)));
	}
	//vns from swap feess
	function dividend(uint256 amount) external {
		IERC20(VNS).transferFrom(msg.sender, address(this), amount);
		curDividendBalance += amount;
		totalDividendAmount += amount;
	}

	function setLPStakingInfo(address lpAddress, uint256 poolId) external onlyOwner {
		lpStakingPool = lpAddress;
		lpStakingPoolId = poolId;
	}

	function stake(uint256[] calldata ids) external needPoolOpen {

		NFTStaker storage user = stakers[msg.sender];

		if (user.ids.length == 0) user.lastDividendClaimTime = block.timestamp;

		for (uint256 i; i < ids.length; ++i) {
			uint256 id = ids[i];

			if (VNS_NFT.ownerOf(id) != msg.sender) revert InvalidId(id);

			user.ids.push(id);
			totalStaked += 1;

			nftInfo[id].nftDeployTime = block.timestamp;
			nftInfo[id].lastVNSClaimTime = block.timestamp;
			nftInfo[id].lastCPDClaimTime = block.timestamp;

			VNS_NFT.transferFrom(msg.sender, address(this), id);
			emit Stake(msg.sender, id);
		}
	}

	function withdraw(uint256[] calldata ids) external needPoolOpen {
		require(isOpen, "closed");

		NFTStaker storage user = stakers[msg.sender];
		require(user.ids.length > 0, "staked 0");

		claimVNS();
		claimCPD();

		for (uint256 i; i < ids.length; ++i) {
			uint256 id = ids[i];

			if (VNS_NFT.ownerOf(id) != address(this)) revert InvalidId(id);

			for (uint256 j; j < user.ids.length; ++j) {
				if (user.ids[j] == id) {
					user.ids[j] = user.ids[user.ids.length - 1];
					user.ids.pop();

					totalStaked -= 1;

					nftInfo[id].nftDeployTime = 0;
					nftInfo[id].lastVNSClaimTime = 0;
					nftInfo[id].lastCPDClaimTime = 0;

					VNS_NFT.transferFrom(address(this), msg.sender, id);
					emit Withdraw(msg.sender, id);
					break;
				}
			}
		}
	}

	function claimVNS() public needPoolOpen {
		NFTStaker storage user = stakers[msg.sender];

		uint256 pending = pendingVNSWithEdit(msg.sender);
		if (pending > 0) {
			uint256 halfPending = pending / 2;
			uint256 otherHalf = pending - halfPending;
			rewardVNSTransfer(msg.sender, halfPending);
			rewardVNSTransfer(address(this), otherHalf);

			user.totalRewardVNS += pending;
			totalRewardVNS += pending;

			//sell half,add liquidity
			swapAndLiquify(otherHalf);
		}
	}

	function claimCPD() public needPoolOpen {
		NFTStaker storage user = stakers[msg.sender];

		uint256 pending = pendingCPDWithEdit(msg.sender);
		if (pending > 0) {
			rewardCPDTransfer(msg.sender, pending);
			user.totalRewardCPD += pending;
			totalRewardCPD += pending;
		}
	}

	function pendingVNSWithEdit(address _user) internal returns (uint256 pendingVNS) {
		NFTStaker storage user = stakers[_user];

		if (user.ids.length > 0) {
			for (uint256 i; i < user.ids.length; i++) {
				uint256 id = user.ids[i];
				uint256 claimedReward = nftInfo[id].nftClaimedVns;
				uint256 newClaimAmount = ((block.timestamp - nftInfo[id].lastVNSClaimTime) * DAY_QUOTA) / 1 days;

				if (claimedReward + newClaimAmount >= MAX_VNS_QUOTA) newClaimAmount = MAX_VNS_QUOTA - claimedReward;
				pendingVNS += newClaimAmount;
				
				nftInfo[id].nftClaimedVns += newClaimAmount;
				nftInfo[id].lastVNSClaimTime = block.timestamp;
			}

			//dividend vns
			if (block.timestamp > user.lastDividendClaimTime + dividendClaimColdTime && totalStaked != 0) {
				uint256 dividendAmount = (user.ids.length * curDividendBalance) / totalStaked;
				pendingVNS += dividendAmount;

				curDividendBalance -= dividendAmount;
				user.lastDividendClaimTime = block.timestamp;
			}
		}
	}

	function pendingVNS(address _user) external view returns (uint256 pendingVNS) {
		NFTStaker storage user = stakers[_user];

		if (user.ids.length > 0) {
			for (uint256 i; i < user.ids.length; i++) {
				uint256 id = user.ids[i];
				uint256 claimedReward = nftInfo[id].nftClaimedVns;
				uint256 newClaimAmount = ((block.timestamp - nftInfo[id].lastVNSClaimTime) * DAY_QUOTA) / 1 days;

				if (claimedReward + newClaimAmount >= MAX_VNS_QUOTA) newClaimAmount = MAX_VNS_QUOTA - claimedReward;
				pendingVNS += newClaimAmount;
			}

			//dividend vns
			if (block.timestamp > user.lastDividendClaimTime + dividendClaimColdTime && totalStaked != 0){
				uint256 dividendAmount = (user.ids.length * curDividendBalance) / totalStaked;
				pendingVNS +=dividendAmount;
			}
		}
	}

	function pendingCPDWithEdit(address _user) internal returns (uint256 pendingCPD) {
		NFTStaker storage user = stakers[_user];

		if (user.ids.length > 0) {
			for (uint256 i; i < user.ids.length; i++) {
				uint256 id = user.ids[i];
				uint256 newClaimAmount = ((block.timestamp - nftInfo[id].lastCPDClaimTime) * DAY_QUOTA) / 1 days;
				pendingCPD += newClaimAmount;

				nftInfo[id].nftClaimedCpd += newClaimAmount;
				nftInfo[id].lastCPDClaimTime = block.timestamp;
			}
		}
	}

	function pendingCPD(address _user) external view returns (uint256 pendingCPD) {
		NFTStaker storage user = stakers[_user];

		if (user.ids.length > 0) {
			for (uint256 i; i < user.ids.length; i++) {
				uint256 id = user.ids[i];
				uint256 newClaimAmount = ((block.timestamp - nftInfo[id].lastCPDClaimTime) * DAY_QUOTA) / 1 days;

				pendingCPD += newClaimAmount;
			}
		}
	}

	function rewardVNSTransfer(address to, uint256 amount) internal {
		emit RewardTokenTransfer(to, VNS, amount);

		uint256 balance = IERC20(VNS).balanceOf(address(this));
		if (balance < amount) {
			IVNSToken(VNS).mint(to, amount);
		} else {
			if (to != address(this)) IERC20(VNS).transfer(to, amount);
		}
	}

	function rewardCPDTransfer(address to, uint256 amount) internal {
		emit RewardTokenTransfer(to, CPD, amount);

		uint256 balance = IERC20(CPD).balanceOf(address(this));
		if (balance < amount) {
			IVNSCPD(CPD).mint(to, amount);
		} else {
			IERC20(CPD).transfer(to, amount);
		}
	}

	function swapAndLiquify(uint256 tokens) private {
		uint256 half = tokens / 2;
		uint256 otherHalf = tokens - half;

		uint256 initialBalance = IERC20(USDT).balanceOf(address(this));

		swapTokensForCake(half);

		uint256 newBalance = IERC20(USDT).balanceOf(address(this)) - initialBalance;

		addLiquidity(otherHalf, newBalance);

		emit SwapAndLiquify(half, newBalance, otherHalf);
	}

	function swapTokensForCake(uint256 tokenAmount) private {
		address[] memory path = new address[](2);

		path[0] = VNS;
		path[1] = USDT;

		IERC20(VNS).approve(address(UNI_V2_ROUTER02), tokenAmount);

		// make the swap
		IUniswapV2Router02(UNI_V2_ROUTER02).swapExactTokensForTokensSupportingFeeOnTransferTokens(
			tokenAmount,
			0,
			path,
			address(this),
			block.timestamp
		);
	}

	function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
		// approve token transfer to cover all possible scenarios
		IERC20(VNS).approve(UNI_V2_ROUTER02, tokenAmount);
		IERC20(USDT).approve(UNI_V2_ROUTER02, usdtAmount);

		//origin lp balance
		uint256 lpbalance = IERC20(LP_VNS_USDT).balanceOf(address(this));

		// add the liquidity
		IUniswapV2Router02(UNI_V2_ROUTER02).addLiquidity(
			VNS,
			USDT,
			tokenAmount,
			usdtAmount,
			0, // slippage is unavoidable
			0, // slippage is unavoidable
			address(this),
			block.timestamp
		);

		//new lp balance
		uint256 retBalance = IERC20(LP_VNS_USDT).balanceOf(address(this)) - lpbalance;

		IERC20(LP_VNS_USDT).approve(lpStakingPool, retBalance);
		IStakingPool(lpStakingPool).stakeTo(lpStakingPoolId, retBalance, msg.sender);
	}

	function onERC721Received(
		address _operator,
		address _from,
		uint256 _tokenId,
		bytes calldata _data
	) external pure override returns (bytes4) {
		return this.onERC721Received.selector;
	}
}