// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";

interface Marketplace {
    function sellItem(address _seller, address _buyer, uint256 _tokenId, uint256 _priceToken, bytes32 _hashId) external returns(bool);
    function addSale(address _sender, uint256 _idToken, uint256 _priceToken) external returns(bool);
    function removeUserSale(address _sender, uint256 _tokenId, bytes32 _hashId) external returns (bool);

    function salePriceByHash(bytes32 _hashId) external view returns (uint256);
    function saleOwnerByHash(bytes32 _hashId) external view returns (address);
    function saleTokenByHash(bytes32 _hashId) external view returns (uint256);
}

interface Staking {
    function stake (address sender, uint256 _amount, uint256 _stakingType) external returns(bool);
}

contract CypherRouter is Ownable {

    IERC20 private cypherToken;
    IERC1155 private cypherCollectionable;
    Marketplace private cypherMarket;
    Staking private cypherStake;
    address private rewardPool;

    mapping(address => uint256[]) private _deposits;

    event requestDeposit(address indexed sender, uint256 indexed tokenId);
    event requestExtract(address indexed sender, uint256 indexed tokenId);
    event depositNFT(address indexed sender, uint256 indexed tokenId, bytes32 indexed hashId);
    event extractNFT(address indexed sender, uint256 indexed tokenId, bytes32 indexed hashId);

    constructor(address _cypherContract, address _collectionContract, address _marketContract, address _stakingContract, address _rewardPool) {
        cypherToken = IERC20(_cypherContract);
        cypherCollectionable = IERC1155(_collectionContract);
        cypherMarket = Marketplace(_marketContract);
        cypherStake = Staking(_stakingContract);
        rewardPool = _rewardPool;
    }

    function _removeItemOfArray(uint256[] storage array, uint256 tmpId) private {
        if ((array.length > 0) && tmpId != (array.length - 1)) {
            uint256 tmpToken = array[array.length - 1];
            array[tmpId] = tmpToken;
        }

        array.pop();
    }

    function canWithdraw(address sender, uint256 _tokenId) private view returns (bool checkWithdraw, uint256 pos) {
        checkWithdraw = false;

        for (uint256 i = 0; i < _deposits[sender].length; i++) {
            if (_deposits[sender][i] == _tokenId) {
                checkWithdraw = true;
                pos = i;
            }
        }

        return (checkWithdraw, pos);
    }

    function executeStake(uint256 _amount, uint256 _stakeType) public returns (bool) {
        require(cypherToken.allowance(msg.sender, address(this)) >= _amount, "Insufficient approve");
        cypherToken.transferFrom(msg.sender, address(cypherStake), _amount);
        require(cypherStake.stake(msg.sender, _amount, _stakeType));

        return true;
    }

    function executeNewSale(uint256 _idToken, uint256 _priceToken) public returns (bool) {
        require(cypherCollectionable.isApprovedForAll(msg.sender, address(this)), "NOT APPROVE");
        cypherCollectionable.safeTransferFrom(msg.sender, owner(), _idToken, 1, "");

        cypherMarket.addSale(msg.sender, _idToken, _priceToken);
        return true;
    }

    function executeSell(address _seller, uint256 _tokenId, uint256 _priceToken, bytes32 _hashId) public returns (bool) {
        require(_seller != address(0));
        require(_seller == cypherMarket.saleOwnerByHash(_hashId));
        require(_tokenId == cypherMarket.saleTokenByHash(_hashId));
        require(_priceToken == cypherMarket.salePriceByHash(_hashId));

        require(msg.sender != _seller);
        require(cypherCollectionable.balanceOf(owner(), _tokenId) > 0);
        require(cypherToken.allowance(msg.sender, address(this)) >= _priceToken);

        uint256 taxFee = (_priceToken * 5) / 100; 
        require(cypherToken.transferFrom(msg.sender, rewardPool, taxFee));
        require(cypherToken.transferFrom(msg.sender, _seller, _priceToken - taxFee));
        
        cypherCollectionable.safeTransferFrom(owner(), msg.sender, _tokenId, 1, "");
        cypherMarket.sellItem(_seller, msg.sender, _tokenId, _priceToken, _hashId);

        return true;
    }

    function executeRemoveSell(uint256 _tokenId, bytes32 _hashId) public returns (bool) {
        require(cypherCollectionable.balanceOf(owner(), _tokenId) > 0);
        require(cypherMarket.removeUserSale(msg.sender, _tokenId, _hashId));

        cypherCollectionable.safeTransferFrom(owner(), msg.sender, _tokenId, 1, "");
        return true;
    }

    function requestDepositToken(uint256 _tokenId) public payable returns (bool) {
        require(cypherCollectionable.isApprovedForAll(msg.sender, address(this)));
        require(cypherCollectionable.balanceOf(msg.sender, _tokenId) > 0);
        require(msg.value == 5000000000000000);

        cypherCollectionable.safeTransferFrom(msg.sender, owner(), _tokenId, 1, "");
        payable(owner()).transfer(msg.value);
        emit requestDeposit(msg.sender, _tokenId);
        return true;
    }

    function requestExtractToken(uint256 _tokenId) public payable returns (bool) {
        (bool checkWithdraw, uint256 pos) = canWithdraw(msg.sender, _tokenId);
        require(checkWithdraw, "No puedes retirar en este momento");
        require(msg.value == 5000000000000000);

        _removeItemOfArray(_deposits[msg.sender], pos);
        emit requestExtract(msg.sender, _tokenId);
        return true;
    }

    function executeDepositToken(address _sender, uint256 _tokenId, bytes32 _hashId) public onlyOwner returns (bool) {
        _deposits[_sender].push(_tokenId);
        emit depositNFT(_sender, _tokenId, _hashId);
        return true;
    }

    function executeExtractToken(address _sender, uint256 _tokenId, bytes32 _hashId) public onlyOwner returns (bool) {    
        cypherCollectionable.safeTransferFrom(msg.sender, _sender, _tokenId, 1, "");
        emit extractNFT(_sender, _tokenId, _hashId);
        return true;
    }

    function getDeposits(address _user) public view returns (uint[] memory){
        return _deposits[_user];
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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