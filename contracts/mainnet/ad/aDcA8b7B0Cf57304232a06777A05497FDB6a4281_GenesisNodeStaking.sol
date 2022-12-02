// SPDX-License-Identifier: No License

pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract GenesisNodeStaking is Ownable, ReentrancyGuard {
    IERC20 public MVCC;
    IERC721 public genesisNodeNFT;

    //Info of each user
    struct UserInfo {
        bool staked;                    // User stake status
        uint256 tokenId;
        uint256 stakeTimestamp;         // User staked amount in the pool
        uint256 unstakeTimestamp;       // User staked amount in the pool
        uint256 lastClaimTimestamp;     // User last harvest timestamp 
        uint256 pendingRewards;
        uint256 claimedRewards;
        uint256 rewardCheckpoint;
    }

    // Info of each user that stakes LP tokens.
    mapping (address => UserInfo) public userInfo;
    mapping (address => bool) private operator;
    mapping (address => bool) private blacklists;
    address[] public stakeList;

    // Rewards processing
    uint256 public totalStaked;
    uint256 public rewardsPool;
    uint256 public currentAllocation;
    uint256 public currentRewardCheckpoint = 0;

    modifier onlyOperator {
        require(isOperator(msg.sender), "Only operator can perform this action");
        _;
    }

    constructor(address _MVCC, address _genesisNodeNFT) {
        MVCC = IERC20(_MVCC);
        genesisNodeNFT = IERC721(_genesisNodeNFT);

        operator[msg.sender] = true;
    }

    /**
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function stake(uint256 _tokenId) external nonReentrant {  
        UserInfo storage _userInfo = userInfo[msg.sender];
        require(!isBlacklisted(msg.sender), "Blacklisted");
        require(!_userInfo.staked, "Already staking");
        require(genesisNodeNFT.ownerOf(_tokenId) == msg.sender, "Not NFT Owner");

        // Transfer NFT into the contract
        genesisNodeNFT.safeTransferFrom(msg.sender, address(this), _tokenId);

        // Update user staking info
        _userInfo.staked = true;
        _userInfo.tokenId = _tokenId;
        _userInfo.stakeTimestamp = block.timestamp;
		
		// Push user address to stakeList if the address never stake before
        if(_userInfo.unstakeTimestamp == 0) {
            stakeList.push(msg.sender);
        }

        // update tracker
        totalStaked++;

        emit Stake(msg.sender, block.timestamp, _tokenId);
    }

    function unstake() external nonReentrant {
        UserInfo storage _userInfo = userInfo[msg.sender];

        require(!isBlacklisted(msg.sender), "Blacklisted");
        require(_userInfo.staked, "Not in staking");
        uint256 _tokenId = _userInfo.tokenId;

        // Update userinfo
        _userInfo.staked = false;
        _userInfo.tokenId = 0;
        _userInfo.unstakeTimestamp = block.timestamp;

        // Transfer NFT from the contract
        genesisNodeNFT.safeTransferFrom(address(this), msg.sender, _tokenId);

        // Claim pending rewards
        uint256 _pendingRewards = _userInfo.pendingRewards;
        if(_pendingRewards > 0) {
            claimProcess(_pendingRewards);
        }

        // update tracker
        totalStaked--;

        emit Unstake(msg.sender, _tokenId);
    }

    function claim() external nonReentrant {
        UserInfo storage _userInfo = userInfo[msg.sender];
        uint256 _pendingRewards = _userInfo.pendingRewards;

        require(!isBlacklisted(msg.sender), "Blacklisted");
        require(_userInfo.staked, "Not in staking");
        require(_pendingRewards > 0, "No pending rewards found");
        require(MVCC.balanceOf(address(this)) >= _userInfo.pendingRewards, "Insufficient MVCC in contract");

        claimProcess(_pendingRewards);

        emit Claim(msg.sender, _pendingRewards);
    }

    function claimProcess(uint256 _pendingRewards) internal {
        UserInfo storage _userInfo = userInfo[msg.sender];

        // update user info
        _userInfo.pendingRewards = 0;
        _userInfo.claimedRewards += _pendingRewards;
        _userInfo.lastClaimTimestamp = block.timestamp;

        // update rewardsPool
        rewardsPool -= _pendingRewards;

        MVCC.transfer(msg.sender, _pendingRewards);
    }

    function calculateRewards() external nonReentrant onlyOperator {
        uint256 contractBalance = MVCC.balanceOf(address(this));
        uint256 newBalance = contractBalance - rewardsPool;

        require(contractBalance > rewardsPool, "Contract balance must be larger than rewards pool");
        require(totalStaked > 0, "No active staker found");

        // Calculate allocation
        currentAllocation = newBalance / totalStaked;
        currentRewardCheckpoint++;
        rewardsPool = contractBalance;

        emit CalculateRewards(contractBalance, rewardsPool, currentAllocation, currentRewardCheckpoint);
    }

    function processRewardByIndex(uint256 _startIndex, uint256 _endIndex) external nonReentrant onlyOperator {
        if(_endIndex > stakeList.length)
            _endIndex = stakeList.length;

        // Distribute allocation to all active stakers
        for(uint i=_startIndex; i<_endIndex; i++) {
            UserInfo storage _userInfo = userInfo[stakeList[i]];

            if(_userInfo.staked && (_userInfo.rewardCheckpoint == 0 || _userInfo.rewardCheckpoint < currentRewardCheckpoint)) {
                _userInfo.pendingRewards += currentAllocation;
                _userInfo.rewardCheckpoint = currentRewardCheckpoint;
            }
        }

        emit ProcessRewardByIndex(_startIndex, _endIndex);
    }

    function rescueToken(address _tokenAddress, address _recipient, uint256 _amount) external onlyOwner {
        require(_recipient != address(0), "Address zero");
        require(_amount > 0, "Amount must be larger than zero");
        require(IERC20(_tokenAddress).balanceOf(address(this)) >= _amount, "Insufficient token balance");

        IERC20(_tokenAddress).transfer(_recipient, _amount);

        emit RescueToken(_tokenAddress, _recipient, _amount);
    }
    

    // ===================================================================
    // GETTERS
    // ===================================================================

    function isOperator(address _userAddress) public view returns(bool) {
        return operator[_userAddress];
    }

    function isBlacklisted(address _userAddress) public view returns(bool) {
        return blacklists[_userAddress];
    }

    // ===================================================================
    // SETTERS
    // ===================================================================

    function setMvccAddress(address _mvcc) external onlyOwner {
        MVCC = IERC20(_mvcc);

        emit SetMvccAddress(_mvcc);
    }

    function setGenesisNodeNFTAddress(address _genesisNodeNFT) external onlyOwner {
        genesisNodeNFT = IERC721(_genesisNodeNFT);

        emit SetGenesisNodeNFTAddress(_genesisNodeNFT);
    }

    function blacklist(address _userAddress, bool _boolValue) external onlyOwner {
        require(_userAddress != address(0), "Address zero");
        blacklists[_userAddress] = _boolValue;

        emit Blacklist(_userAddress, _boolValue);
    }

    function setOperator(address _userAddress, bool _boolValue) external onlyOwner {
        require(_userAddress != address(0), "Address zero");
        operator[_userAddress] = _boolValue;

        emit SetOperator(_userAddress, _boolValue);
    }

    // ===================================================================
    // EVENTS
    // ===================================================================

    event Stake(address indexed account, uint256 stakeTimestamp, uint256 tokenId);
    event Unstake(address indexed account, uint256 tokenId);
    event Claim(address indexed account, uint256 value);
    event CalculateRewards(uint256 contractBalance, uint256 rewardsPool, uint256 currentAllocation, uint256 currentRewardCheckpoint);
    event ProcessRewardByIndex(uint256 startIndex, uint256 endIndex);
    event RescueToken(address token, address to, uint256 amount);
    event SetMvccAddress(address mvcc);
    event SetGenesisNodeNFTAddress(address _genesisNodeNFT);
    event Blacklist(address userAddress, bool boolValue);
    event SetOperator(address userAddress, bool boolValue);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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