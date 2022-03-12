/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


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

// File: @openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// File: contracts/METAPUNKNFTFARM.sol


pragma solidity ^0.8.4;





//import "@openzeppelin/contracts/token/ERC721/IERC20.sol";
contract MetaPunkNFTFarm is Ownable, ERC721Holder {
    IERC721 public NFT;
    IERC20 public Token;
    event LockedStake(address indexed _from, uint256 tokenId, uint256 period);
    //=======Stake Rewards Variables=========
    uint256 reward_rate_per_seconds = 1;
    mapping(address => uint256[]) Address_Staked_NFT;
    mapping(address => uint256) Address_Last_Reward;
    mapping(uint256 => uint256) Token_Locked_Period;

    constructor(address nftAddress) {
        NFT = IERC721(nftAddress);
    }

    //, address _tokenAddress
    function setNFTAddress(address _nftAddress) public onlyOwner {
        NFT = IERC721(_nftAddress);
        //     Token = IERC20(_tokenAddress);
    }

    function setTokenAddress(address _tokenAddress) public onlyOwner {
        Token = IERC20(_tokenAddress);
    }

    function stake(uint256 tokenId) external {
        require(NFT.ownerOf(tokenId) == msg.sender, "Not NFT Owner");
        NFT.safeTransferFrom(msg.sender, address(this), tokenId, "0X00");
        Address_Staked_NFT[msg.sender].push(tokenId);
        if (Address_Last_Reward[msg.sender] == 0)
            Address_Last_Reward[msg.sender] = block.timestamp;
    }

    function unstake(uint256 tokenId) external {
        require(
            Address_Staked_NFT[msg.sender].length > 0,
            "Address have no staking NFT"
        );
        int256 index = findTokenIdIndexInArray(
            tokenId,
            Address_Staked_NFT[msg.sender]
        );
        require(index >= 0, "Token Id not exist in staked data");
        require(
            block.timestamp > Token_Locked_Period[tokenId],
            "Token is currently locked"
        );
        uint256 array_length = Address_Staked_NFT[msg.sender].length;

        NFT.safeTransferFrom(address(this), msg.sender, tokenId);
        Address_Staked_NFT[msg.sender][uint256(index)] = Address_Staked_NFT[
            msg.sender
        ][array_length - 1];
        Address_Staked_NFT[msg.sender].pop();
    }

    function stakeWithTimeLock(uint256 tokenId, uint256 timeInDay) external {
        require(NFT.ownerOf(tokenId) == msg.sender, "Not NFT Owner");
        uint256 lockTime = timeInDay * 86400;
        NFT.safeTransferFrom(msg.sender, address(this), tokenId, "0X00");
        Address_Staked_NFT[msg.sender].push(tokenId);
        if (Address_Last_Reward[msg.sender] == 0)
            Address_Last_Reward[msg.sender] = block.timestamp;
        Token_Locked_Period[tokenId] = block.timestamp + lockTime;
        emit LockedStake(msg.sender, tokenId, lockTime);
    }

    function stakeWithTimeLockMinutes(uint256 tokenId, uint256 timeInMinutes) external {
        require(NFT.ownerOf(tokenId) == msg.sender, "Not NFT Owner");
        uint256 lockTime = timeInMinutes * 60;
        NFT.safeTransferFrom(msg.sender, address(this), tokenId, "0X00");
        Address_Staked_NFT[msg.sender].push(tokenId);
        if (Address_Last_Reward[msg.sender] == 0)
            Address_Last_Reward[msg.sender] = block.timestamp;
        Token_Locked_Period[tokenId] = block.timestamp + lockTime;
        emit LockedStake(msg.sender, tokenId, lockTime);
    }


    function emergengyUnlock(uint256 tokenId) external onlyOwner {
        Token_Locked_Period[tokenId] = 0;
    }

    function findTokenIdIndexInArray(uint256 tokenId, uint256[] memory arry)
        internal
        pure
        returns (int256)
    {
        for (uint256 i = 0; i < arry.length; i++) {
            if (arry[i] == tokenId) {
                return int256(i);
            }
        }
        return -1;
    }

    function getStakedToken(address stakerAddress)
        public
        view
        returns (uint256[] memory)
    {
        return Address_Staked_NFT[stakerAddress];
    }

    //Reward Methods

    function claimReward() external payable {
        uint256 nftAmount = Address_Staked_NFT[msg.sender].length;
        require(nftAmount > 0, "Address do not hold any MetaPunk NFT");
        require(
            Address_Last_Reward[msg.sender] != 0,
            "Address has no stake record"
        );
        uint256 time_now = block.timestamp;
        uint256 reward_amount = (time_now - Address_Last_Reward[msg.sender]) *
            nftAmount *
            reward_rate_per_seconds;
        require(reward_amount > 0, "Address do not have any reward");
        Token.transfer(msg.sender, reward_amount);
        Address_Last_Reward[msg.sender] = time_now;
    }

    function setRewardRate(uint256 new_rate) external onlyOwner {
        reward_rate_per_seconds = new_rate * 10**18;
    }

    function getRewardEstimate() external view returns (uint256) {
        uint256 nftAmount = Address_Staked_NFT[msg.sender].length;
        require(nftAmount > 0, "Address do not hold any MetaPunk NFT");
        uint256 time_now = block.timestamp;
        require(
            Address_Last_Reward[msg.sender] != 0,
            "Address has no stake record"
        );
        uint256 reward_amount = (time_now - Address_Last_Reward[msg.sender]) *
            reward_rate_per_seconds *
            nftAmount;
        return reward_amount;
    }
}