// SPDX-License-Identifier: MIT

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

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
}

// SPDX-License-Identifier: MIT

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
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

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
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

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

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "./interfaces/ICurrencyManager.sol";
import "./interfaces/IElpisMetaverseEquipment.sol";

contract EquipmentDisassembler is Context, Ownable, ERC721Holder {
    ICurrencyManager public immutable currencyManager;
    IElpisMetaverseEquipment public immutable EMQ;

    //Disassembling end block
    uint256 public endBlock;
    uint256 public maxEquipmentPerTx;
    //The highest token that can disassemble
    uint256 public constant HIGHEST_TOKEN = 635;
    //Minimum value a token can get after disassembling
    uint256 public constant MIN_EQUIVALENT_VALUE = 25e20;
    //Maximum value a token can get after disassembling
    uint256 public constant MAX_EQUIVALENT_VALUE = 19e22;
    bytes32 public constant IRON =
        0x49524f4e00000000000000000000000000000000000000000000000000000000;

    //Mapping tokenId to equivalent value
    mapping(uint256 => uint256) public equivalentValues;

    event EndBlockChanged(address account, uint256 endBlock);
    event MaxEquipmentPerTxChanged(address account, uint256 maxEquipmentPerTx);
    event EquivalentValueSet(
        address account,
        uint256[] tokenIds,
        uint256 equivalentValue
    );
    event Disassembled(
        address account,
        uint256[] tokenIds,
        uint256[] equivalentValues
    );

    constructor(
        IElpisMetaverseEquipment _EMQ,
        ICurrencyManager _currencyManager,
        uint256 _endBlock,
        uint256 _maxEquipmentPerTx
    ) {
        EMQ = _EMQ;
        currencyManager = _currencyManager;
        endBlock = _endBlock;
        maxEquipmentPerTx = _maxEquipmentPerTx;
    }

    function updateEndBlock(uint256 _endBlock) external onlyOwner {
        endBlock = _endBlock;
        emit EndBlockChanged(_msgSender(), _endBlock);
    }

    function updateMaxEquipmentPerTx(uint256 _maxEquipmentPerTx)
        external
        onlyOwner
    {
        maxEquipmentPerTx = _maxEquipmentPerTx;
        emit MaxEquipmentPerTxChanged(_msgSender(), _maxEquipmentPerTx);
    }

    /** @dev This function allows to set one equivalent value for multiple different tokens
     *
     * Requirements
     * - Each token in `_tokenIds` must be less than or equal to HIGHEST_TOKEN
     * - `_equivalentValue` must be between minimum equivalent value and maximum equivalent value
     *
     * Can only be called by owner
     */
    function setEquivalentValues(
        uint256[] calldata _tokenIds,
        uint256 _equivalentValue
    ) external onlyOwner {
        uint256 length = _tokenIds.length;
        for (uint256 i = 0; i < length; ++i) {
            uint256 tokenId = _tokenIds[i];
            require(
                tokenId <= HIGHEST_TOKEN,
                "The token is not allowed to disassemble"
            );
            require(
                _equivalentValue >= MIN_EQUIVALENT_VALUE &&
                    _equivalentValue <= MAX_EQUIVALENT_VALUE,
                "Equivalent value overflow or underflow"
            );
            equivalentValues[tokenId] = _equivalentValue;
        }

        emit EquivalentValueSet(_msgSender(), _tokenIds, _equivalentValue);
    }

    /** @dev This function allows to disassemble multiple equipments to get IRON
     *
     * Requirements
     * - The current block has not reached the end block
     * - Each token in `_tokenIds` must be less than or equal to highest token
     *
     * Can be called by anyone
     */
    function disassemble(uint256[] calldata _tokenIds) external {
        require(block.number < endBlock, "The disassembling has ended");
        require(
            _tokenIds.length <= maxEquipmentPerTx,
            "Disassemble amount exceeds maximum"
        );

        uint256 length = _tokenIds.length;
        uint256[] memory _equivalentValues = new uint256[](length);
        for (uint256 i = 0; i < length; ++i) {
            uint256 tokenId = _tokenIds[i];
            uint256 equivalentValue = equivalentValues[tokenId];
            require(
                tokenId <= HIGHEST_TOKEN,
                "The token is not allowed to disassemble"
            );
            require(equivalentValue > 0, "Equivalent value is the zero value");

            EMQ.safeTransferFrom(_msgSender(), address(this), tokenId);
            EMQ.burn(tokenId);
            currencyManager.increase(IRON, _msgSender(), equivalentValue);
            _equivalentValues[i] = equivalentValue;
        }
        emit Disassembled(_msgSender(), _tokenIds, _equivalentValues);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface ICurrencyManager {
    function increase(bytes32 currency, address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IElpisMetaverseEquipment is IERC721 {
    function burn(uint256 tokenId) external;
}