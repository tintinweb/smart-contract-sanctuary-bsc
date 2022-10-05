pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./Interface/IDeepToken.sol";
import "./Interface/IDKeeper.sol";
import "./Interface/IDKeeperEscrow.sol";

contract DKeeperStake is Ownable, IERC721Receiver {
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    // DeepToken contract
    IDeepToken public deepToken;

    // DKeeper NFT contract
    IDKeeper public dKeeper;

    // DKeeper Escrow contract
    IDKeeperEscrow public dKeeperEscrow;

    // Timestamp of last reward
    uint256 public lastRewardTime;

    // Accumulated token per share
    uint256 public accTokenPerShare;

    // Staked users' NFT Ids
    mapping(address => mapping(uint256 => bool)) public userNFTs;

    // Info of each user that stakes LP tokens.
    mapping(address => UserInfo) public userInfo;

    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;

    // The block number when Deep distribution starts.
    uint256 public startTime;

    // The block number when Deep distribution ends.
    uint256 public endTime;

    uint256 public constant WEEK = 3600 * 24 * 7;

    event Deposited(address indexed user, uint256 indexed tokenId, uint256 amount);

    event Withdrawn(address indexed user, uint256 indexed tokenId, uint256 amount);

    event Claimed(address indexed user, uint256 amount);

    constructor(
        IDeepToken _deep,
        IDKeeper _dKeeper,
        uint256 _startTime,
        uint256 _endTime
    ) public {
        require(_endTime >= _startTime && block.timestamp <= _startTime, "Invalid timestamp");
        deepToken = _deep;
        dKeeper = _dKeeper;
        startTime = _startTime;
        endTime = _endTime;

        totalAllocPoint = 0;
        lastRewardTime = _startTime;
    }

    // View function to see pending Deeps on frontend.
    function pendingDeep(address _user) external view returns (uint256) {
        UserInfo memory user = userInfo[_user];

        uint256 updatedAccTokenPerShare = accTokenPerShare;
        if (block.timestamp > lastRewardTime && totalAllocPoint != 0) {
            uint256 rewards = getRewards(lastRewardTime, block.timestamp);
            updatedAccTokenPerShare += ((rewards * 1e12) / totalAllocPoint);
        }

        return (user.amount * updatedAccTokenPerShare) / 1e12 - user.rewardDebt;
    }

    // Update reward variables to be up-to-date.
    function updatePool() public {
        if (block.timestamp <= lastRewardTime || lastRewardTime >= endTime) {
            return;
        }
        if (totalAllocPoint == 0) {
            lastRewardTime = block.timestamp;
            return;
        }

        uint256 rewards = getRewards(lastRewardTime, block.timestamp);

        accTokenPerShare = accTokenPerShare + ((rewards * 1e12) / totalAllocPoint);
        lastRewardTime = block.timestamp;
    }

    // Deposit NFT to NFTStaking for DEEP allocation.
    function deposit(uint256 _tokenId) public {
        require(dKeeper.ownerOf(_tokenId) == msg.sender, "Invalid NFT owner");
        UserInfo storage user = userInfo[msg.sender];
        updatePool();

        if (user.amount != 0) {
            uint256 pending = (user.amount * accTokenPerShare) / 1e12 - user.rewardDebt;
            if (pending > 0) {
                safeDeepTransfer(msg.sender, pending);
                emit Claimed(msg.sender, pending);
            }
        }

        dKeeper.safeTransferFrom(address(msg.sender), address(this), _tokenId);
        user.amount = user.amount + dKeeper.mintedPrice(_tokenId);
        totalAllocPoint += dKeeper.mintedPrice(_tokenId);
        userNFTs[msg.sender][_tokenId] = true;

        user.rewardDebt = (user.amount * accTokenPerShare) / 1e12;
        emit Deposited(msg.sender, _tokenId, dKeeper.mintedPrice(_tokenId));
    }

    // Withdraw NFT token.
    function withdraw(uint256 _tokenId) public {
        require(userNFTs[msg.sender][_tokenId], "Invalid NFT owner");
        UserInfo storage user = userInfo[msg.sender];

        updatePool();
        uint256 pending = (user.amount * accTokenPerShare) / 1e12 - user.rewardDebt;
        if (pending > 0) {
            safeDeepTransfer(msg.sender, pending);
            emit Claimed(msg.sender, pending);
        }

        user.amount = user.amount - dKeeper.mintedPrice(_tokenId);
        dKeeper.safeTransferFrom(address(this), address(msg.sender), _tokenId);
        totalAllocPoint -= dKeeper.mintedPrice(_tokenId);
        userNFTs[msg.sender][_tokenId] = false;

        user.rewardDebt = (user.amount * accTokenPerShare) / 1e12;
        emit Withdrawn(msg.sender, _tokenId, dKeeper.mintedPrice(_tokenId));
    }

    // Claim rewards.
    function claim() public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount != 0, "Not deposited NFTs.");
        updatePool();

        uint256 pending = (user.amount * accTokenPerShare) / 1e12 - user.rewardDebt;
        if (pending > 0) {
            safeDeepTransfer(msg.sender, pending);
            emit Claimed(msg.sender, pending);
        }

        user.rewardDebt = (user.amount * accTokenPerShare) / 1e12;
    }

    // Safe DEEP transfer function, just in case if rounding error causes pool to not have enough DEEP
    function safeDeepTransfer(address _to, uint256 _amount) internal {
        dKeeperEscrow.mint(_to, _amount);
    }

    // Get rewards between block timestamps
    function getRewards(uint256 _from, uint256 _to) internal view returns (uint256 rewards) {
        while (_from + WEEK <= _to) {
            rewards += getRewardRatio(_from) * WEEK;
            _from = _from + WEEK;
        }

        if (_from + WEEK > _to) {
            rewards += getRewardRatio(_from) * (_to - _from);
        }
    }

    // Get rewardRatio from timestamp
    function getRewardRatio(uint256 _time) internal view returns (uint256) {
        if (52 < (_time - startTime) / WEEK) return 0;

        return (((1e25 * (52 - (_time - startTime) / WEEK)) / 52 / 265) * 10) / WEEK;
    }

    // Get rewardRatio from timestamp
    function setEscrow(address _escrow) public onlyOwner {
        require(_escrow != address(0), "Invalid address");
        dKeeperEscrow = IDKeeperEscrow(_escrow);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IDKeeper is IERC721 {
    function mintedPrice(uint256 tokenId) external returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDeepToken is IERC20 {
    function mint(address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity 0.8.4;

interface IDKeeperEscrow {
    function mint(address account, uint256 amount) external;
}

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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