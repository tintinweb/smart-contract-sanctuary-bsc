/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

// SPDX-License-Identifier: MIT
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


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


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

// File: contracts/WoolStateV2/WoolRewards.sol


pragma solidity ^0.8.4;






enum State {
    Created,
    Approved,
    Declined
}

struct Project {
    uint256 projectId;
    uint256 totalSupply;
    uint256 currentSupply;
    uint256 totalCost;
    uint256 endDate;
    State status;
}

interface IWoolStateNFT {
    function remainingTokensAtProject(uint256 projectId) external view returns (uint256);
    function getProject(uint256 projectId) external view returns (Project memory);
    function getProjectIdByTokenId(uint256 tokenId) external view returns (uint256);
    function safeMint(uint256 projectId, address to, uint256 amount) external;
    function activateProject(uint256 projectId) external returns (bool);
}

contract WoolRewardsV2 is ERC721Holder, Pausable, Ownable {
    address _aceptedToken; // = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    address _nftRegistry;
    uint256 rewardCounter;

    // projectId => rewardId => tokenId => used (bool)
    mapping (uint256 => mapping (uint256 => mapping (uint256 => bool))) public _rewardsClaimed;

    // projectId => tokenId => refunded (bool)
    mapping (uint256 => mapping (uint256 => bool)) public _refundPayments;

    // rewardId => data
    mapping (uint256 => Reward) public _rewardsAvailable;

    // projectId => amount
    mapping (uint256 => uint256) public  _collected;

    // events
    event RewardClaimed (address indexed account, uint256 indexed rewardId, uint256 projectId, uint256 tokenId, uint256 amountReceived);
    event NewReward (uint256 rewardId, uint256 projectId, uint256 totalAmount);
    event RefundPayment(address indexed account, uint256 projectId, uint256 tokenId, uint256 amount);

    struct Reward {
        uint256 rewardId;
        uint256 projectId;
        uint256 totalRewards; 
        uint256 remainingRewards;
    }

    constructor(address aceptedToken, address nftRegistry) {
        _aceptedToken = aceptedToken;
        _nftRegistry = nftRegistry;
    }

    function setAceptedToken(address aceptedToken) external onlyOwner {
        _aceptedToken = aceptedToken;
    }

    function supplyForSale(uint256 projectId) public view returns (uint256) {
        return IWoolStateNFT(_nftRegistry).remainingTokensAtProject(projectId); 
    }

    function refundPaymentsOfProject(uint256 projectId, uint256[] calldata tokenIds) external {
        Project memory project = IWoolStateNFT(_nftRegistry).getProject(projectId);
        require (project.status == State.Declined, "Can't refund nothing on this Project");
        require (_collected[projectId] >= 0, "Insufficient funds");

        for (uint256 i=0; i < tokenIds.length; i++) {
            if (_refundPayments[projectId][tokenIds[i]] == false) {
                _refundPayments[projectId][tokenIds[i]] = true;
                address account = IERC721(_nftRegistry).ownerOf(tokenIds[i]);
                uint256 amountToReceive = calculateCost(
                    project.totalCost,
                    1,
                    project.totalSupply
                );

                require(amountToReceive <= _collected[projectId], "Insufficient funds");
                _collected[projectId] -= amountToReceive;

                require(IERC20(_aceptedToken).transfer(account, amountToReceive), "ERC20: Transfer has failed");

                emit RefundPayment(account, projectId, tokenIds[i], amountToReceive);
            }
        }
    }

    function _checkProjectStatus(uint256 projectId) internal {
        Project memory project = IWoolStateNFT(_nftRegistry).getProject(projectId);
        if(project.status == State.Approved && _collected[projectId] > 0) {
            require(IERC20(_aceptedToken).transfer(owner(), _collected[projectId]), "ERC20: Transfer to owner has failed");
        }
    }

    function buyTokens(uint256 projectId, uint256 amount) external {
        Project memory project = IWoolStateNFT(_nftRegistry).getProject(projectId);
        require(project.status == State.Created || project.status == State.Approved, "Project Declined");
        uint256 remaining = project.totalSupply - project.currentSupply; 

        require(remaining >= amount, "Not enough tokens left for sale");

        uint256 totalCost = project.totalCost * amount / project.totalSupply;

        address receiver = address(this);
        if (project.status == State.Approved) {
            receiver = owner();
        }
        require(IERC20(_aceptedToken).allowance(msg.sender, address(this)) >= totalCost, "ERC20: insufficient allowance");
        require(IERC20(_aceptedToken).transferFrom(msg.sender, receiver, totalCost), "ERC20: Transfer has failed");
        IWoolStateNFT(_nftRegistry).safeMint(projectId, msg.sender, amount);

        _collected[projectId] += totalCost;
        _checkProjectStatus(projectId);
    }

    function addReward(uint256 projectId, uint256 totalRewards) external onlyOwner {

        Project memory project = IWoolStateNFT(_nftRegistry).getProject(projectId);
        require (project.status == State.Approved, "Can't add reward if project is not approved yet");

        rewardCounter++;
        Reward memory _reward;
        _reward.rewardId = rewardCounter;
        _reward.projectId = projectId;
        _reward.totalRewards = totalRewards;
        _reward.remainingRewards = totalRewards;
        _rewardsAvailable[rewardCounter] = _reward;

        require(IERC20(_aceptedToken).allowance(msg.sender, address(this)) >= totalRewards, "ERC20: insufficient allowance");
        require(IERC20(_aceptedToken).transferFrom(msg.sender, address(this), totalRewards), "ERC20: Transfer has failed");

        emit NewReward (rewardCounter, projectId, totalRewards);
    }

    function claimReward(uint256 rewardId, uint256[] calldata tokenIds) external {

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(IWoolStateNFT(_nftRegistry).getProjectIdByTokenId(tokenIds[i]) == _rewardsAvailable[rewardId].projectId, "Token not linked to this project");
            if (_rewardsClaimed[_rewardsAvailable[rewardId].projectId][rewardId][tokenIds[i]] == false) {
                _rewardsClaimed[_rewardsAvailable[rewardId].projectId][rewardId][tokenIds[i]] = true;

                address account = IERC721(_nftRegistry).ownerOf(tokenIds[i]);

                uint256 amountToReceive = calculateCost(
                    _rewardsAvailable[rewardId].totalRewards,
                    1,
                    IWoolStateNFT(_nftRegistry).getProject(_rewardsAvailable[rewardId].projectId).totalSupply
                );

                require(_rewardsAvailable[rewardId].remainingRewards - amountToReceive >= 0, "Insufficient funds");

                _rewardsAvailable[rewardId].remainingRewards -= amountToReceive;

                require(IERC20(_aceptedToken).transfer(account, amountToReceive), "ERC20: Transfer has failed");

                emit RewardClaimed (account, rewardId, _rewardsAvailable[rewardId].projectId, tokenIds[i], amountToReceive);
            }
        }
    }

    function calculateCost(uint256 totalRewards, uint256 balance, uint256 totalSupply) public pure returns (uint256) {
        return totalRewards * balance / totalSupply;
    }

    receive() external payable {
        revert();
    }

    fallback() external payable {
        revert();
    }

    function destroySmartContract() public onlyOwner {
        withdraw();
        selfdestruct(payable(owner()));
    }

    function withdraw() public onlyOwner {
        uint256 balanceICO = IERC20(_aceptedToken).balanceOf(
            address(this)
        );
        if (balanceICO > 0) {
            require(
                IERC20(_aceptedToken).transfer(
                    owner(),
                    balanceICO
                ), 
                "Transfer failed."
            );
        }
    }
}