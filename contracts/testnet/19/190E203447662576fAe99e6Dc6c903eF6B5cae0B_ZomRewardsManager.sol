// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../includes/interfaces/IERC20.sol";
import "../includes/interfaces-modified/IERC721.sol";
import "../includes/interfaces-modified/IERC1155.sol";
import "../includes/interfaces/IPriceConsumerV3.sol";

contract ZomRewardsManager {
    enum RewardType { ERC20, ERC721, ERC1155 }

    struct RewardInfo {
        RewardType rewardType;
        address rewardAddress;
        uint amount;
        uint tokenId;
        uint fee;
        uint maxClaims;
        uint maxClaimsPerUser;
        bool isSet;
        bool useReviveRug;

        uint totalClaims;
        mapping (address => uint) allowedUserClaims;
        mapping (address => uint) userClaimed;
    }

    address public owner;
    address public gameMaster;
    address public treasury;
    IPriceConsumerV3 public priceConsumer;

    mapping (uint => RewardInfo) rewards;
    mapping (address => bool) distributors;

    event RewardClaimed(address player, uint id, address reward);
    event OwnershipTransferred(address previousOwner, address newOwner);

    constructor(address _gameMaster, address _treasury, address _priceConsumer) {
        gameMaster = _gameMaster;
        treasury = _treasury;
        priceConsumer = IPriceConsumerV3(_priceConsumer);
        owner = msg.sender;
    }

    function feeInBnb(uint _id) public view returns (uint256) { return priceConsumer.usdToBnb(rewards[_id].fee); }

    function setGameMaster(address _gameMaster) public {
        require(msg.sender == owner, 'Ownable: caller is not contract owner');
        gameMaster = _gameMaster;
    }

    function setDistributor(address _distributor, bool _allowed) public {
        require(msg.sender == owner, 'Ownable: caller is not contract owner');
        distributors[_distributor] = _allowed;
    }

    function setTreasury(address _treasury) public {
        require(msg.sender == owner, 'Ownable: caller is not contract owner');
        treasury = _treasury;
    }
    
    function setUseReviveRug(uint _id, bool _use) public {
        require(msg.sender == owner, 'Ownable: caller is not contract owner');
        rewards[_id].useReviveRug = _use;
    }

    function setPriceConsumer(address _priceConsumer) public {
        require(msg.sender == owner, 'Ownable: caller is not contract owner');
        priceConsumer = IPriceConsumerV3(_priceConsumer);
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, 'Ownable: caller is not contract owner');
        require(newOwner != address(0), 'Ownable: new owner cannot be zero address');
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, owner);
    }

    function recoverERC20(address _token) public {
        require(msg.sender == owner, 'Ownable: caller is not contract owner');
        IERC20 token = IERC20(_token);
        uint balance = token.balanceOf(address(this));
        token.approve(address(this), balance);
        token.transferFrom(address(this), owner, balance);
    }

    function checkReward(uint _id, address _wallet) public view returns (bool hasClaimed, bool hasClaims, bool availableClaims) {
        RewardInfo storage reward = rewards[_id];
        require(reward.isSet, 'Reward is not set');
        uint claimed = reward.userClaimed[_wallet];
        hasClaimed = claimed > 0;
        hasClaims = reward.allowedUserClaims[_wallet] > claimed;
        availableClaims = reward.allowedUserClaims[_wallet] < reward.maxClaimsPerUser;
        return (hasClaimed, hasClaims, availableClaims);
    }

    function setReward(
        uint _id, 
        RewardType _type, 
        address _rewardAddress, 
        uint _amount, 
        uint _tokenId,
        uint _fee, 
        uint _maxClaims, 
        uint _maxClaimsPerUser
    ) public {
        require(msg.sender == owner, 'Ownable: caller is not contract owner');
        require(rewards[_id].totalClaims == 0, 'Reward cannot be changed after being claimed');
        rewards[_id].rewardType = _type;
        rewards[_id].rewardAddress = _rewardAddress;
        rewards[_id].amount = _amount;
        rewards[_id].tokenId = _tokenId;
        rewards[_id].fee = _fee;
        rewards[_id].maxClaims = _maxClaims;
        rewards[_id].maxClaimsPerUser = _maxClaimsPerUser;
        rewards[_id].isSet = true;
    }

    function allowClaim(uint _id, address _wallet, uint _claims) public {
        require(rewards[_id].isSet, 'Reward is not set');
        require(msg.sender == gameMaster, 'Must be called by game master');
        require(rewards[_id].allowedUserClaims[_wallet] + _claims <= rewards[_id].maxClaimsPerUser, 'User has maximum claims');
        rewards[_id].allowedUserClaims[_wallet] += _claims;
    }

    function claim(address _user, uint _id) public payable {
        require (msg.sender == _user || tx.origin == _user && distributors[msg.sender], 'Not authorized');

        RewardInfo storage reward = rewards[_id];
        require(reward.allowedUserClaims[_user] > reward.userClaimed[_user], 'No claims available');
        require(msg.value >= feeInBnb(_id));
        require(reward.totalClaims < reward.maxClaims || reward.maxClaims == 0, 'Maximum claims for this reward have been issued');
        
        _safeTransfer(treasury, msg.value);

        if (reward.rewardType == RewardType.ERC20) _claimERC20(_user, reward.rewardAddress, reward.amount);
        else if (reward.rewardType == RewardType.ERC721) _claimERC721(_user, reward.rewardAddress, reward.useReviveRug);
        else _claimERC1155(_user, reward.rewardAddress, reward.tokenId, reward.amount);

        reward.totalClaims++;
        reward.userClaimed[_user]++;
        emit RewardClaimed(_user, _id, reward.rewardAddress);
    }

    function _claimERC20(address _user, address _reward, uint _amount) private {
        IERC20 token = IERC20(_reward);
        require(token.balanceOf(address(this)) >= _amount, 'Insufficient token balance');
        token.approve(address(this), _amount);
        token.transferFrom(address(this), _user, _amount);
    }

    function _claimERC721(address _user, address _reward, bool _reviveRug) private {
        IERC721 nft = IERC721(_reward);
        if (_reviveRug) nft.reviveRug(_user);
        else nft.mint(_user);
    }

    function _claimERC1155(address _user, address _reward, uint _tokenId, uint _amount) private {
        IERC1155 nft = IERC1155(_reward);
        nft.mint(_user, _tokenId, _amount);
    }

    function _safeTransfer(address _recipient, uint _amount) private {
        (bool _success, ) = _recipient.call{value: _amount}("");
        require(_success, "transfer failed");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address _account) external view returns (uint256);
    function transfer(address _recipient, uint256 _amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transferFrom(address _sender, address _recipient, uint256 _amount) external returns (bool);
    event Transfer(address _from, address _to, uint256 _value);
    event Approval(address _owner, address _spender, uint256 _value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../utils/introspection/IERC165.sol";

/**x
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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    function mint(address _to) external returns (uint);
    function reviveRug(address _to) external returns(uint);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.4;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function mint(address _to, uint256 _id, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IPriceConsumerV3 {
    function getLatestPrice() external view returns (uint);
    function unlockFeeInBnb(uint) external view returns (uint);
    function usdToBnb(uint) external view returns (uint);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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