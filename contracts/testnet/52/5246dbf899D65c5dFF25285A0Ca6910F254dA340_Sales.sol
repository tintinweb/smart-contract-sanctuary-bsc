//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./Authorizable.sol";

contract Sales is ERC721Holder, Authorizable {
  enum SaleStatus {
    LIVE,
    CANCELED,
    DONE
  }

  enum TokenStatus {
    DISABLED,
    ENABLED,
    SOLD
  }

  struct SaleToken {
    uint256 tokenId;
    uint256 price;
    TokenStatus status;
  }

  struct Sale {
    uint256 id;
    address tokenAddress;
    address fundReceiver;
    uint256[] tokenIds;
    SaleStatus status;
  }

  uint256 public currentId;

  mapping(uint256 => Sale) public sales;
  mapping(uint256 => mapping(uint256 => SaleToken)) public tokens;
  mapping(uint256 => address) public managers;
  mapping(address => uint256) public saleIdOfAccount;

  event Created(uint256 indexed saleId, Sale sale);
  event Updated(uint256 indexed saleId, Sale sale);
  event Canceled(uint256 indexed saleId, Sale sale);
  event Bought(
    uint256 indexed saleId,
    uint256 indexed tokenId,
    uint256 indexed price
  );

  modifier onlyManager(uint256 _saleId) {
    require(
      _msgSender() == managers[_saleId],
      "Caller must be the manager of this sale!"
    );
    _;
  }

  modifier saleExists(uint256 _saleId) {
    require(0 < _saleId && _saleId <= currentId, "Sale does not exist!");
    _;
  }

  function createSale(
    address _tokenAddress,
    uint256[] memory _tokenIds,
    uint256[] memory _prices
  ) external {
    require(_tokenAddress != address(0), "Invalid token address");
    require(_tokenIds.length > 0, "Empty token list");
    require(_tokenIds.length == _prices.length, "Inconsistent length");
    require(saleIdOfAccount[_msgSender()] == 0, "Can only create 1 sale");

    Sale storage newSale = sales[++currentId];
    newSale.id = currentId;
    newSale.tokenAddress = _tokenAddress;
    newSale.tokenIds = _tokenIds;
    newSale.fundReceiver = _msgSender();
    newSale.status = SaleStatus.LIVE;

    managers[newSale.id] = _msgSender();
    saleIdOfAccount[_msgSender()] = newSale.id;

    for (uint256 i; i < _tokenIds.length; i++) {
      uint256 tokenId = _tokenIds[i];

      tokens[currentId][tokenId] = SaleToken(
        tokenId,
        _prices[i],
        TokenStatus.ENABLED
      );
      IERC721(_tokenAddress).safeTransferFrom(
        _msgSender(),
        address(this),
        tokenId
      );
    }

    emit Created(newSale.id, newSale);
  }

  // Update status of current sale tokens
  function updateTokens(uint256 _saleId, SaleToken[] memory _saleTokens)
    external
    saleExists(_saleId)
    onlyManager(_saleId)
  {
    require(_saleTokens.length > 0, "Empty token list");

    for (uint256 i; i < _saleTokens.length; i++) {
      SaleToken storage token = tokens[_saleId][_saleTokens[i].tokenId];
      require(token.tokenId == _saleTokens[i].tokenId, "invalid token id");
      require(
        _saleTokens[i].status != TokenStatus.SOLD,
        "Invalid token status"
      );

      token.status = _saleTokens[i].status;
      token.price = _saleTokens[i].price;
    }

    emit Updated(_saleId, getSale(_saleId));
  }

  // Add new token to Sale
  function addNewTokens(
    uint256 _saleId,
    uint256[] memory _tokenIds,
    uint256[] memory _prices
  ) external saleExists(_saleId) onlyManager(_saleId) {
    require(_tokenIds.length > 0, "Empty token list");
    require(_tokenIds.length == _prices.length, "Inconstent lenght");

    for (uint256 i; i < _tokenIds.length; i++) {
      SaleToken storage token = tokens[_saleId][_tokenIds[i]];
      require(token.tokenId == 0, "token id already added");

      token.tokenId = _tokenIds[i];
      token.price = _prices[i];
      token.status = TokenStatus.ENABLED;

      sales[_saleId].tokenIds.push(_tokenIds[i]);

      IERC721(sales[_saleId].tokenAddress).safeTransferFrom(
        _msgSender(),
        address(this),
        token.tokenId
      );
    }
  }

  function buy(uint256 _saleId, uint256 _tokenId)
    external
    payable
    saleExists(_saleId)
  {
    require(isReadyForSale(_saleId, _tokenId), "Not ready for sale");

    SaleToken storage token = tokens[_saleId][_tokenId];
    require(token.status == TokenStatus.ENABLED, "Not for sale");
    require(msg.value == token.price, "Incorrect buy amount");

    token.status = TokenStatus.SOLD;

    Sale memory sale = sales[_saleId];

    // Send NFT to buyer
    IERC721(sale.tokenAddress).safeTransferFrom(
      address(this),
      _msgSender(),
      _tokenId
    );

    // Send native token for token owner
    payable(sale.fundReceiver).transfer(msg.value);

    emit Bought(_saleId, _tokenId, msg.value);
  }

  function getSale(uint256 _saleId) public view returns (Sale memory) {
    return sales[_saleId];
  }

  function getSaleToken(uint256 _saleId, uint256 _tokenId)
    external
    view
    returns (SaleToken memory)
  {
    return tokens[_saleId][_tokenId];
  }

  function getOnSaleTokens(uint256 _saleId)
    external
    view
    returns (SaleToken[] memory)
  {
    Sale memory sale = getSale(_saleId);

    uint256 enabledAmount = 0;
    for (uint256 i; i < sale.tokenIds.length; i++) {
      if (isReadyForSale(_saleId, sale.tokenIds[i])) enabledAmount++;
    }

    SaleToken[] memory saleTokens = new SaleToken[](enabledAmount);
    uint256 counter = 0;
    for (uint256 i; i < sale.tokenIds.length; i++) {
      if (isReadyForSale(_saleId, sale.tokenIds[i])) {
        saleTokens[counter++] = tokens[_saleId][sale.tokenIds[i]];
      }
    }
    return saleTokens;
  }

  function getUnSoldTokens(uint256 _saleId)
    external
    view
    returns (SaleToken[] memory)
  {
    Sale memory sale = getSale(_saleId);

    uint256 unsoldAmount = 0;
    for (uint256 i; i < sale.tokenIds.length; i++) {
      if (!isTokenSold(_saleId, sale.tokenIds[i])) unsoldAmount++;
    }

    SaleToken[] memory saleTokens = new SaleToken[](unsoldAmount);
    uint256 counter = 0;
    for (uint256 i; i < sale.tokenIds.length; i++) {
      if (!isTokenSold(_saleId, sale.tokenIds[i])) {
        saleTokens[counter++] = tokens[_saleId][sale.tokenIds[i]];
      }
    }
    return saleTokens;
  }

  function isReadyForSale(uint256 _saleId, uint256 _tokenId)
    public
    view
    returns (bool)
  {
    return tokens[_saleId][_tokenId].status == TokenStatus.ENABLED;
  }

  function isTokenSold(uint256 _saleId, uint256 _tokenId)
    public
    view
    returns (bool)
  {
    return tokens[_saleId][_tokenId].status == TokenStatus.SOLD;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

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
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
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

//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Authorizable is Ownable {
  mapping(address => bool) private _controller;

  event SetController(address indexed account);
  event RemovedController(address indexed account);

  modifier onlyOwnerOrController() {
    require(_msgSender() == owner() || _controller[_msgSender()], "Caller is not owner/controller!");
    _;
  }

  function setController(address _account) external onlyOwnerOrController {
    require(_account != address(0), "A controller must not be address(0)");

    _controller[_account] = true;
    emit SetController(_account);
  }

  function removeController(address _account) external onlyOwnerOrController {
    require(_account != address(0), "A controller must not be address(0)");
    require(_controller[_account], "Given address is not a controller");

    _controller[_account] = false;
    emit RemovedController(_account);    
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