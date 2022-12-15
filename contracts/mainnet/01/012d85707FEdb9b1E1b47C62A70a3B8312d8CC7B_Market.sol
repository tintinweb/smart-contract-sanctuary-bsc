/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// File contracts/interfaces/IForti.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IForti {
    struct Forti {
        uint256 categoryId;
        uint256 tokenId;
        string name;
        string category;
        uint8 rank;
        uint8 maxRank;
        uint8 rarity;
        uint256 power;
        uint256 hp;
        uint256 speed;
        uint256 armor;
        uint256 specialAbilityPower;
        uint256 bulletSpeed;
        uint256 lastSalePrice;
        bool isForSale;
        uint256 battleCounter;
    }

    event NewForti(
        uint256 tokenId,
        uint256[] indexIds,
        address minter,
        Forti forti
    );
    event BurnForti(uint256 tokenId, uint256[] indexIds, address caller);
    event Migrate(address user, Forti[] migratedFortis);
    event BasePrice(string fortiName, uint256 basePrice);
    event Transfer(
        address from,
        address to,
        uint256 categoryId,
        uint256 indexId
    );

    function mintForti(
        uint256 supply,
        address minter,
        Forti memory newForti
    ) external;

    function burnForti(uint256 _tokenId, uint256 _supply) external;

    function getUserFortis(
        address _address
    ) external view returns (Forti[] memory);

    function getFortiById(
        uint256 categoryId,
        uint256 indexId
    ) external view returns (Forti memory);
}

// File contracts/interfaces/IMarket.sol

pragma solidity ^0.8.0;

interface IMarket {
    struct MarketItem {
        uint256 tokenId;
        uint256 nftId; // ERC1155 copy Id
        uint256 price;
        address nftContract;
        // address buyer;
        address seller;
    }

    struct OwnerSale {
        uint256 itemId;
        uint256 tokenId;
        uint256 quantity;
    }

    struct Bid {
        address bidder;
        uint256 bid;
        uint256 fee;
    }

    struct Auction {
        uint256 tokenId;
        uint256 nftId;
        uint256 start;
        uint256 end;
        uint256 startingPrice;
        uint256 reservePrice;
        uint256 buyNowPrice;
        address seller;
        address nftContract;
        bool isLocked;
        Bid highestBid;
    }

    // =========== Market Events ===========
    event ListItem(
        uint256 indexed tokenId,
        uint256 indexed index,
        uint256 indexed price,
        address seller
    );
    event BatchSale(uint256 indexed tokenId, uint256[] indexIds, uint256 price);
    event BatchCancelSale(uint256 indexed tokenId, uint256[] indexIds);
    event Buy(
        uint256 indexed tokenId,
        uint256 indexed index,
        uint256 indexed price,
        address buyer,
        address seller
    );
    event NewAuction(
        uint256 indexed tokenId,
        uint256 indexed nftId,
        uint256 indexed startingPrice,
        address nftContract
    );
    event CancelSale(
        uint256 indexed tokenId,
        uint256 indexed index,
        address indexed seller
    );
    event MakeBid(
        uint256 tokenId,
        uint256 nftId,
        uint256 bid,
        address bidder,
        address seller,
        address nftContract
    );
    event CancelBid(
        uint256 tokenId,
        uint256 nftId,
        address bidder,
        address nftContract
    );
    event FeeChange(uint256 oldFee, uint256 newFee);

    // =========== Community Sale Functionns ===========
    function listItem(
        uint256 _tokenId,
        uint256 _index,
        uint256 _price,
        address _nftContract
    ) external;

    function makeSale(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) external;

    function cancelSale(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) external;

    // =========== Community Auction Functions ===========
    function createAuction(
        uint256 _tokenId,
        uint256 _index,
        uint256 _endTime,
        uint256 _startingPrice,
        uint256 _reservePrice,
        uint256 _buyNowPrice,
        address _nftContract
    ) external;

    function makeBid(
        uint256 _tokenId,
        uint256 _index,
        uint256 _bid,
        address _nftContract
    ) external;

    function cancelBid(
        uint256 tokenId,
        uint256 _index,
        address _nftContract
    ) external;

    function buyNowAuction(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) external;

    function cancelAuction(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) external;

    function settleAuction(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) external;

    // =========== View Functions ===========
    function viewMarketItem(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) external view returns (MarketItem memory _marketItem);
}

// File contracts/interfaces/IInfinityCard.sol

pragma solidity ^0.8.0;

interface IInfinityCard {
    struct Knox {
        uint256 categoryId;
        uint256 tokenId;
        string name;
        string model;
        string series;
        uint8 rank;
        uint8 maxRank;
        uint8 rarity;
        uint256 attribute;
        uint256 lastSalePrice;
        uint256 ownershipCounter;
        bool isForSale;
    }

    event NewKnox(
        uint256 tokenId,
        uint256[] indexIds,
        address minter,
        Knox knox
    );
    event BurnForti(uint256 tokenId, uint256 supply, address caller);
    event Migrate(address user, Knox[] migratedFortis);
    event BasePrice(string fortiName, uint256 basePrice);
    event Transfer(
        address from,
        address to,
        uint256 categoryId,
        uint256 indexId
    );

    function getTokenName(
        string memory nftName
    ) external view returns (uint256);
}

// File contracts/interfaces/ISale.sol

pragma solidity ^0.8.0;

interface ISale {
    function setTokenForSale(
        uint256 _categoryId,
        uint256 _indexId,
        uint256 _salePrice,
        address _owner,
        bool _isAuction
    ) external returns (bool, string memory);

    function setBasePrice(string calldata _name, uint256 _price) external;

    function makeSale(
        uint256 _categoryId,
        uint256 _indexId,
        uint256 _amount,
        address _buyer,
        bool _isAuction
    ) external returns (bool);

    function cancelSale(
        uint256 _categoryId,
        uint256 _indexId,
        address _seller,
        bool _isAuction
    ) external returns (bool);

    function getBasePrice(
        string memory nftName
    ) external view returns (uint256);

    function getTokenId() external view returns (uint256);

    function getIndexId(uint256 tokenId) external view returns (uint256);

    // function getTotalIdsOnSale(uint256 tokenId) external view returns(uint256[] memory);

    // Added
    function getUserTokensOnSale(
        address user,
        uint256 categoryId
    ) external view returns (uint256[] memory);

    function getUserTokensOnAuction(
        address user,
        uint256 categoryId
    ) external view returns (uint256[] memory);
}

// File @openzeppelin/contracts/utils/[email protected]

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

// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File @openzeppelin/contracts/utils/introspection/[email protected]

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

// File @openzeppelin/contracts/token/ERC1155/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

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
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

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
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

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
    function balanceOf(
        address account,
        uint256 id
    ) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

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
    function isApprovedForAll(
        address account,
        address operator
    ) external view returns (bool);

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
}

// File @openzeppelin/contracts/token/ERC20/[email protected]

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

// File @openzeppelin/contracts/security/[email protected]

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

// File contracts/Market.sol

pragma solidity ^0.8.0;

// import "./interfaces/IWeapon.sol";
// import "./interfaces/IAccessory.sol";

contract Market is IMarket, Ownable, ReentrancyGuard {
    uint256 private fee = 400;
    uint256 private constant PERCENTAGE_DENOMINATOR = 10000;
    address private adminWallet;

    IForti private fortiContract;
    // IInfinityCard private knoxContract;
    // IAccessory private accessoryContract;
    // IWeapon private weaponContract;
    IERC20 private bfkToken;

    mapping(address => mapping(uint256 => mapping(uint256 => bool))) itemIdOnSale;
    mapping(address => mapping(uint256 => mapping(uint256 => MarketItem)))
        public nftMarketItems;
    mapping(address => mapping(uint256 => mapping(uint256 => Auction)))
        private nftAuctionItems;
    mapping(address => mapping(uint256 => uint256)) private nftSaleSupply;

    mapping(address => uint256) private itemIds;
    mapping(address => uint256) private auctionIds;

    constructor(
        address _adminWallet,
        address _tokenContract,
        address _fortiContract
    ) {
        require(_adminWallet != address(0), "Invalid admin address!");
        require(_tokenContract != address(0), "Invalid token address!");
        require(
            _fortiContract != address(0) && _fortiContract.code.length > 0,
            "Invalid Forti address!"
        );

        adminWallet = _adminWallet;
        bfkToken = IERC20(_tokenContract);
        fortiContract = IForti(_fortiContract);
    }

    function isValidContract(address _nftContract) private view returns (bool) {
        require(
            _nftContract == address(fortiContract),
            // || _nftContract == address(knoxContract),
            // _nftContract == address(weaponContract) ||
            // _nftContract == address(accessoryContract),
            "Market: Invalid NFT Contract!"
        );
        return true;
    }

    function isItemForSale(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) private view returns (bool) {
        require(
            itemIdOnSale[_nftContract][_tokenId][_index],
            "Market: Item not for sale!"
        );
        return true;
    }

    function setFeePercentage(uint256 _newFee) external onlyOwner {
        require(_newFee > 0 && _newFee <= 1000, "Market: Max fee limit is 4%!");
        require(_newFee != fee, "Market: Fee already set!");

        emit FeeChange(fee, _newFee);
        fee = _newFee;
    }

    function setAdminAddress(address _adminWallet) external onlyOwner {
        require(
            _adminWallet != adminWallet,
            "Market: Address already added" 
        );
        adminWallet = _adminWallet;
    }

    /// @dev Community sale functions starts from here
    /// @notice Owner of the item can lists the token for Community sale
    function listItem(
        uint256 _tokenId,
        uint256 _index,
        uint256 _price,
        address _nftContract
    ) external override nonReentrant {
        require(isValidContract(_nftContract));
        require(
            !itemIdOnSale[_nftContract][_tokenId][_index] ||
                _removeEndedAuction(_tokenId, _index, _nftContract),
            "Market: Already listed on sale!"
        );
        require(_price != 0, "Market: Invalid price!");

        address _seller = msg.sender;
        (bool _isListed, string memory _message) = ISale(_nftContract)
            .setTokenForSale(_tokenId, _index, _price, _seller, false);
        if (!_isListed) revert(_message);

        itemIds[_nftContract]++;
        if (_seller == owner()) nftSaleSupply[_nftContract][_tokenId]++;

        nftMarketItems[_nftContract][_tokenId][_index] = MarketItem({
            tokenId: _tokenId,
            nftId: _index,
            price: _price,
            nftContract: _nftContract,
            // buyer: address(0),
            seller: _seller
        });

        itemIdOnSale[_nftContract][_tokenId][_index] = true;

        emit ListItem(_tokenId, _index, _price, _seller);
    }

    /**
        @notice This function is for testing
        */
    function batchSale(
        uint256 _categoryId,
        uint256 _supply,
        uint256 _price,
        address _nftContract
    ) external onlyOwner nonReentrant {
        address _seller = msg.sender;
        require(
            _supply > 0 &&
                _supply <=
                (IERC1155(_nftContract).balanceOf(_seller, _categoryId) -
                    nftSaleSupply[_nftContract][_categoryId]),
            "Market: Invalid supply!"
        );
        require(_price != 0, "Market: Invalid price!");

        bool _flag = true;
        uint256 _counter;
        uint256[] memory _indexIds = new uint256[](_supply);

        uint256 _end = ISale(_nftContract).getIndexId(_categoryId);
        while (_flag) {
            for (uint256 _index = 1; _index <= _end; _index++) {
                if (itemIdOnSale[_nftContract][_categoryId][_index]) {
                    _removeEndedAuction(_categoryId, _index, _nftContract);
                }

                (bool _isSetOnSale, string memory errorMsg) = ISale(
                    _nftContract
                ).setTokenForSale(_categoryId, _index, _price, _seller, false);
                require(
                    !(keccak256(
                        abi.encodePacked(
                            "Market: Price should not be less than the base price!"
                        )
                    ) == keccak256(abi.encodePacked(errorMsg))),
                    errorMsg
                );
                if (_isSetOnSale) {
                    _supply--;
                    itemIds[_nftContract]++;
                    nftSaleSupply[_nftContract][_categoryId]++;
                    nftMarketItems[_nftContract][_categoryId][
                        _index
                    ] = MarketItem({
                        tokenId: _categoryId,
                        nftId: _index,
                        price: _price,
                        nftContract: _nftContract,
                        // buyer: address(0),
                        seller: _seller
                    });
                    itemIdOnSale[_nftContract][_categoryId][_index] = true;
                    _indexIds[_counter++] = _index;
                }
                if (_supply == 0 || _index == _end) {
                    _flag = false;
                    break;
                }
            }
        }

        emit BatchSale(_categoryId, _indexIds, _price);
    }

    /// @notice Users can buy the NFT which is listed in the Community sale.
    function makeSale(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) external override nonReentrant {
        MarketItem memory _marketItem = nftMarketItems[_nftContract][_tokenId][
            _index
        ];
        address _caller = msg.sender;
        require(isValidContract(_nftContract));
        require(isItemForSale(_tokenId, _index, _nftContract));
        require(
            ISale(_nftContract).makeSale(
                _tokenId,
                _index,
                _marketItem.price,
                _caller,
                false
            ),
            "Market: Error while selling NFT!"
        );

        uint256 _price = _marketItem.price;
        address _seller = _marketItem.seller;

        if (_seller == owner()) nftSaleSupply[_nftContract][_tokenId]--;
        // _marketItem.buyer = _caller;
        itemIdOnSale[_nftContract][_tokenId][_index] = false;
        _distributeAmount(_caller, _marketItem.seller, _price);
        itemIds[_nftContract]--;
        delete nftMarketItems[_nftContract][_tokenId][_index];

        emit Buy(_tokenId, _index, _price, _caller, _seller);
    }

    /// @notice Owner can remove the NFT from the sale
    function cancelSale(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) external override nonReentrant {
        address _seller = msg.sender;
        require(isValidContract(_nftContract));
        require(isItemForSale(_tokenId, _index, _nftContract));
        require(
            nftMarketItems[_nftContract][_tokenId][_index].seller != address(0),
            "Market: Item not for sale!"
        );
        require(
            ISale(_nftContract).cancelSale(_tokenId, _index, _seller, false)
        );

        if (_seller == owner()) {
            nftSaleSupply[_nftContract][_tokenId]--;
        }
        itemIds[_nftContract]--;
        itemIdOnSale[_nftContract][_tokenId][_index] = false;
        delete nftMarketItems[_nftContract][_tokenId][_index];

        emit CancelSale(_tokenId, _index, _seller);
    }

    /// @notice Owner can able to cancel multiple NFTs from sale
    function batchCancelSale(
        uint256 _tokenId,
        uint256 _supply,
        address _nftContract
    ) external onlyOwner {
        uint256[] memory _totalIdsOnSale = ISale(_nftContract)
            .getUserTokensOnSale(msg.sender, _tokenId);
        require(
            _supply != 0 && _totalIdsOnSale.length >= _supply,
            "Insufficent supply for cancel sale!"
        );

        uint256 _index = 0;
        uint256[] memory _idsCancelledFromSale = new uint256[](_supply);

        while (_index < _supply) {
            require(
                ISale(_nftContract).cancelSale(
                    _tokenId,
                    _totalIdsOnSale[_index],
                    msg.sender,
                    false
                ),
                "Error while cancelling the sale!"
            );
            itemIdOnSale[_nftContract][_tokenId][
                _totalIdsOnSale[_index]
            ] = false;
            delete nftMarketItems[_nftContract][_tokenId][
                _totalIdsOnSale[_index]
            ];
            _idsCancelledFromSale[_index] = _totalIdsOnSale[_index];
            _index++;
        }

        nftSaleSupply[_nftContract][_tokenId] -= _supply;
        itemIds[_nftContract] -= _supply;

        emit BatchCancelSale(_tokenId, _idsCancelledFromSale);
    }

    /// @dev Community Auction function starts from here
    /// @notice Owner put an NFT on the community auction
    function createAuction(
        uint256 _tokenId,
        uint256 _index,
        uint256 _endTime,
        uint256 _startingPrice,
        uint256 _reservePrice,
        uint256 _buyNowPrice,
        address _nftContract
    ) external override nonReentrant {
        require(isValidContract(_nftContract));
        require(
            !itemIdOnSale[_nftContract][_tokenId][_index] ||
                _removeEndedAuction(_tokenId, _index, _nftContract),
            "Market: Already on sale!"
        );
        require(_endTime > block.timestamp, "Market: Invalid end time!");
        require(
            (_startingPrice != 0) &&
                (_reservePrice >= _startingPrice) &&
                (_buyNowPrice > _reservePrice),
            "Market: Invalid pricing!"
        );

        address _seller = msg.sender;
        (bool _isListed, string memory _message) = ISale(_nftContract)
            .setTokenForSale(_tokenId, _index, _startingPrice, _seller, true);
        if (!_isListed) revert(_message);

        auctionIds[_nftContract]++;
        if (_seller == owner()) nftSaleSupply[_nftContract][_tokenId]++;

        nftAuctionItems[_nftContract][_tokenId][_index] = Auction({
            tokenId: _tokenId,
            nftId: _index,
            start: block.timestamp,
            end: _endTime,
            startingPrice: _startingPrice,
            reservePrice: _reservePrice,
            buyNowPrice: _buyNowPrice,
            seller: _seller,
            highestBid: Bid(address(0), 0, 0),
            nftContract: _nftContract,
            isLocked: false
        });
        itemIdOnSale[_nftContract][_tokenId][_index] = true;

        emit NewAuction(_tokenId, _index, _startingPrice, _nftContract);
    }

    /// @notice Bidders can make a bid on an NFT which is listed on the community auction
    function makeBid(
        uint256 _tokenId,
        uint256 _index,
        uint256 _bid,
        address _nftContract
    ) external override {
        Auction storage _auction = nftAuctionItems[_nftContract][_tokenId][
            _index
        ];
        address _bidder = msg.sender;
        address _seller = _auction.seller;
        require(isValidContract(_nftContract));
        require(isItemForSale(_tokenId, _index, _nftContract));
        require(
            block.timestamp >= _auction.start && block.timestamp < _auction.end,
            "Market: Auction Unavailable!"
        );
        require(!_auction.isLocked, "Market: Auction locked!");
        require(
            _bid >= _auction.startingPrice && _bid > _auction.highestBid.bid,
            "Market: Make higher bid!"
        );

        /// @dev Transfering extra 4% fee from the bidder
        uint256 _feeAmount;
        if (_auction.highestBid.bid > 0) {
            _feeAmount =
                (_auction.highestBid.bid * _auction.highestBid.fee) /
                PERCENTAGE_DENOMINATOR;
            _transferTokens(
                address(0),
                _auction.highestBid.bidder,
                _auction.highestBid.bid + _feeAmount
            );
        }

        _feeAmount = (_bid * fee) / PERCENTAGE_DENOMINATOR;
        _transferTokens(_bidder, address(this), _bid + _feeAmount);

        _auction.highestBid.bidder = _bidder;
        _auction.highestBid.bid = _bid;
        _auction.highestBid.fee = fee;

        emit MakeBid(_tokenId, _index, _bid, _bidder, _seller, _nftContract);
    }

    /// @notice Bidder can cancel the bid and take the amount back with fee
    function cancelBid(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) external override {
        Auction storage _auction = nftAuctionItems[_nftContract][_tokenId][
            _index
        ];
        require(isValidContract(_nftContract));
        require(isItemForSale(_tokenId, _index, _nftContract));
        require(
            block.timestamp <
                nftAuctionItems[_nftContract][_tokenId][_index].end ||
                (nftAuctionItems[_nftContract][_tokenId][_index]
                    .highestBid
                    .bid !=
                    0 &&
                    nftAuctionItems[_nftContract][_tokenId][_index]
                        .highestBid
                        .bid <
                    nftAuctionItems[_nftContract][_tokenId][_index]
                        .reservePrice),
            "Market: Auction unavailable!"
        );
        require(
            nftAuctionItems[_nftContract][_tokenId][_index].highestBid.bidder ==
                msg.sender,
            "Market: Invalid bidder!"
        );
        require(
            !nftAuctionItems[_nftContract][_tokenId][_index].isLocked,
            "Market: Auction Locked!"
        );
        address _bidder = msg.sender;

        /// @dev Transfering Bid amount + extra 4% fee to the bidder
        uint256 _feeAmount = (_auction.highestBid.bid *
            _auction.highestBid.fee) / PERCENTAGE_DENOMINATOR;
        _transferTokens(
            address(0),
            _bidder,
            _auction.highestBid.bid + _feeAmount
        );
        delete _auction.highestBid;

        emit CancelBid(_tokenId, _index, _bidder, _nftContract);
    }

    /// @notice Bidders can pay the buy now price and NFT will be tranferred to the bidder
    function buyNowAuction(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) external override nonReentrant {
        Auction memory _auction = nftAuctionItems[_nftContract][_tokenId][
            _index
        ];
        address _buyer = msg.sender;
        require(isValidContract(_nftContract));
        require(isItemForSale(_tokenId, _index, _nftContract));
        require(block.timestamp < _auction.end, "Market: Auction ended!");
        require(
            _auction.highestBid.bid <= _auction.buyNowPrice,
            "Market: Buy Now disabled!"
        );

        ISale(_nftContract).makeSale(
            _tokenId,
            _index,
            _auction.buyNowPrice,
            _buyer,
            true
        );
        itemIdOnSale[_nftContract][_tokenId][_index] = false;
        auctionIds[_nftContract]--;
        if (_auction.seller == owner()) nftSaleSupply[_nftContract][_tokenId]--;

        if (_auction.highestBid.bid != 0) {
            uint256 _feeAmount = (_auction.highestBid.bid *
                _auction.highestBid.fee) / PERCENTAGE_DENOMINATOR;
            _transferTokens(
                address(0),
                _auction.highestBid.bidder,
                _auction.highestBid.bid + _feeAmount
            );
        }

        _distributeAmount(_buyer, _auction.seller, _auction.buyNowPrice);

        uint256 _price = _auction.buyNowPrice;
        address _seller = _auction.seller;
        delete nftAuctionItems[_nftContract][_tokenId][_index];

        emit Buy(_tokenId, _index, _price, _buyer, _seller);
    }

    /// @notice Highest bidder can claim the NFT after auction ends
    function settleAuction(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) external override nonReentrant {
        require(isValidContract(_nftContract));
        require(
            nftAuctionItems[_nftContract][_tokenId][_index].seller !=
                address(0),
            "Market: NFT not on auction"
        );
        require(
            nftAuctionItems[_nftContract][_tokenId][_index].highestBid.bidder ==
                msg.sender,
            "Market: Unauthorized access!"
        );
        require(
            block.timestamp >=
                nftAuctionItems[_nftContract][_tokenId][_index].end,
            "Market: Auction not ended!"
        );

        uint256 _highestBid;
        address _highestBidder;
        Auction memory _auction = nftAuctionItems[_nftContract][_tokenId][
            _index
        ];

        if (_auction.highestBid.bid < _auction.reservePrice) {
            uint256 _feeAmount = (_auction.highestBid.bid *
                _auction.highestBid.fee) / PERCENTAGE_DENOMINATOR;
            _transferTokens(
                address(0),
                _auction.highestBid.bidder,
                _auction.highestBid.bid + _feeAmount
            );
            _highestBid = 0;
            _highestBidder = address(0);
        } else {
            ISale(_nftContract).makeSale(
                _tokenId,
                _index,
                _auction.highestBid.bid,
                _auction.highestBid.bidder,
                true
            );
            _highestBid = _auction.highestBid.bid;
            _highestBidder = _auction.highestBid.bidder;
            _distributeAmount(address(0), _highestBidder, _highestBid);
        }

        itemIdOnSale[_nftContract][_tokenId][_index] = false;
        auctionIds[_nftContract]--;
        address _seller = _auction.seller;
        if (_seller == owner()) nftSaleSupply[_nftContract][_tokenId]--;

        delete nftAuctionItems[_nftContract][_tokenId][_index];

        emit Buy(_tokenId, _index, _highestBid, _highestBidder, _seller);
    }

    /// @notice Auction creater can cancel the auction from this function
    function cancelAuction(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) external override nonReentrant {
        Auction memory _auction = nftAuctionItems[_nftContract][_tokenId][
            _index
        ];
        address _seller = msg.sender;
        require(isValidContract(_nftContract));
        require(isItemForSale(_tokenId, _index, _nftContract));
        require(block.timestamp < _auction.end, "Market: Auction unavailable!");
        require(
            ISale(_nftContract).cancelSale(_tokenId, _index, _seller, true),
            "Market: Error while cancelling Auction!"
        );

        if (_auction.highestBid.bid > 0) {
            uint256 _feeAmount = (_auction.highestBid.bid *
                _auction.highestBid.fee) / PERCENTAGE_DENOMINATOR;
            _transferTokens(
                address(0),
                _auction.highestBid.bidder,
                _auction.highestBid.bid + _feeAmount
            );
        }

        itemIdOnSale[_nftContract][_tokenId][_index] = false;
        auctionIds[_nftContract]--;
        if (_auction.seller == owner()) nftSaleSupply[_nftContract][_tokenId]--;

        delete nftAuctionItems[_nftContract][_tokenId][_index];

        emit CancelSale(_tokenId, _index, _seller);
    }

    /// @notice This function returns all the NFTs which are currently listed on auction
    function getActiveAuctions(
        address _nftContract
    ) external view returns (Auction[] memory auction) {
        uint256 _tokenId = ISale(_nftContract).getTokenId();
        return _getActiveAuctions(_tokenId, _nftContract);
    }

    /// @notice This function returns all the NFTs which are currently listed on sale
    function fetchMarketItems(
        address _nftContract
    ) external view returns (MarketItem[] memory _marketItem) {
        uint256 _tokenId = ISale(_nftContract).getTokenId();
        return _fetchMarketItems(_tokenId, _nftContract);
    }

    /// @notice Return the details on NFT which is listed on sale
    function viewMarketItem(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) external view override returns (MarketItem memory _marketItem) {
        require(isValidContract(_nftContract));
        require(isItemForSale(_tokenId, _index, _nftContract));
        _marketItem = nftMarketItems[_nftContract][_tokenId][_index];
    }

    /// @notice Return the details on NFT which is listed on auction
    function viewAuctionItem(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) external view returns (Auction memory _auctionItem) {
        _auctionItem = nftAuctionItems[_nftContract][_tokenId][_index];
    }

    function _distributeAmount(
        address _from,
        address _seller,
        uint256 _totalAmount
    ) private {
        uint256 totalBuyingAmount = _totalAmount +
            ((_totalAmount * fee) / PERCENTAGE_DENOMINATOR);
        if (_from != address(0)) {
            _transferTokens(_from, address(this), totalBuyingAmount);
        }
        uint256 _feeAmount;
        uint256 _sellerShare;

        if (_seller == owner()) {
            /// @dev 104% Total, 4% + 50% goes to Admin wallet, 50% goes to Seller Wallet
            _feeAmount = (_totalAmount * fee) / PERCENTAGE_DENOMINATOR; // 4% to _feeAmount from 100%
            _sellerShare = (totalBuyingAmount - _feeAmount) / 2; // (104% - 4%) => (100%/2) => 50%
            _feeAmount += _sellerShare; // 50% + 4% => 54%
        } else {
            _feeAmount = ((_totalAmount * fee) / PERCENTAGE_DENOMINATOR) * 2; // 4% of 100% fee => 4 * 2 => 8%
            _sellerShare = totalBuyingAmount - _feeAmount; // 104% - 8% => 96% -> Seller and 8% fee to admin
        }

        _transferTokens(address(0), adminWallet, _feeAmount);
        _transferTokens(address(0), _seller, _sellerShare);
    }

    function _transferTokens(
        address _from,
        address _to,
        uint256 _amount
    ) private {
        if (_from == address(0)) {
            require(
                bfkToken.transfer(_to, _amount),
                "ERC20 operation did not succeed"
            );
        } else {
            require(
                bfkToken.transferFrom(_from, _to, _amount),
                "ERC20 operation did not succeed"
            );
        }
    }

    function _getActiveAuctions(
        uint256 _tokenId,
        address _nftContract
    ) private view returns (Auction[] memory) {
        Auction[] memory auction = new Auction[](auctionIds[_nftContract]);
        if (auction.length == 0) return auction;
        uint256 _counter = 0;

        for (uint256 _outer = 1; _outer <= _tokenId; _outer++) {
            uint256 supply = ISale(_nftContract).getIndexId(_outer);

            for (uint256 _inner = 1; _inner <= supply; _inner++) {
                if (
                    itemIdOnSale[_nftContract][_outer][_inner] &&
                    nftAuctionItems[_nftContract][_outer][_inner].nftContract !=
                    address(0)
                ) {
                    auction[_counter] = nftAuctionItems[_nftContract][_outer][
                        _inner
                    ];
                    _counter++;
                }
            }
        }
        return auction;
    }

    function _fetchMarketItems(
        uint256 _tokenId,
        address _nftContract
    ) private view returns (MarketItem[] memory) {
        MarketItem[] memory _marketItem = new MarketItem[](
            itemIds[_nftContract]
        );

        if (_marketItem.length == 0) return _marketItem;

        uint256 _counter = 0;

        for (uint256 _outer = 1; _outer <= _tokenId; _outer++) {
            uint256 _supply = ISale(_nftContract).getIndexId(_outer);

            for (uint256 _inner = 1; _inner <= _supply; _inner++) {
                if (
                    itemIdOnSale[_nftContract][_outer][_inner] &&
                    nftMarketItems[_nftContract][_outer][_inner].nftContract !=
                    address(0)
                ) {
                    _marketItem[_counter] = nftMarketItems[_nftContract][
                        _outer
                    ][_inner];
                    _counter++;
                }
            }
        }

        return _marketItem;
    }

    function _removeEndedAuction(
        uint256 _tokenId,
        uint256 _index,
        address _nftContract
    ) private returns (bool) {
        Auction memory _existingAuction = nftAuctionItems[_nftContract][
            _tokenId
        ][_index];

        if (
            (_existingAuction.end != 0 &&
                _existingAuction.end < block.timestamp) &&
            (_existingAuction.highestBid.bidder == address(0) ||
                _existingAuction.highestBid.bid < _existingAuction.reservePrice)
        ) {
            ISale(_nftContract).cancelSale(_tokenId, _index, msg.sender, true);
            if (_existingAuction.highestBid.bid > 0) {
                _transferTokens(
                    address(0),
                    _existingAuction.highestBid.bidder,
                    _existingAuction.highestBid.bid
                );
            }
            if (_existingAuction.seller == owner())
                nftSaleSupply[_nftContract][_tokenId]--;
            itemIdOnSale[_nftContract][_tokenId][_index] = false;
            auctionIds[_nftContract]--;
            delete nftAuctionItems[_nftContract][_tokenId][_index];
            return true;
        }
        return false;
    }
}