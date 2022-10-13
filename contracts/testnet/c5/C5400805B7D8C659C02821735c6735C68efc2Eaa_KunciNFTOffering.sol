// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @author Hermanto Tan
 * @author Riyan Firdaus Amerta
 * @notice NFT Offering contract
 */
contract KunciNFTOffering is Ownable, ReentrancyGuard, Pausable {
    struct NftId {
        bool isNftOffering;
        bool isNftAuction;
        address buyer;
        uint256 nftPrice;
        uint256 start;
        uint256 end;
    }

    event NewBuyLimit(
        uint256 _newLimit
    );

    event Purchase(
        uint256 _amount, 
        uint256 indexed _nftId, 
        address indexed _from, 
        address indexed _nftContract
    );

    event Bid(
        uint256 _amount, 
        uint256 indexed _nftId, 
        address indexed _from, 
        address indexed _nftContract
    );

    event PurchaseBatch (
        uint256 _amount,
        uint256[] _nftIds,
        address indexed _from,
        address indexed _nftContract
    );

    event WinBid(
        uint256 _amount, 
        uint256 indexed _nftId, 
        address indexed _from, 
        address indexed _nftContract
    );

    IERC20 public immutable kunciToken;
    IERC1155 public immutable kunciNFTCollection;

    uint96 public collectionId;
    address public stashAddress;

    string public collectionName;

    address public platform;
    address public artist;

    uint256 public platformFee; //10000 = 100%
    uint256 public artistFee; //10000 = 100%

    uint256 public collectionNftCount;
    uint256 public nftSoldCount;
    uint256 public nftSoldAmount;
    uint256 public buyLimit;
    uint256 pendingPayment; //Ensure that this address has enough balance when claimNFT is called

    mapping (uint256 => NftId) public nftList;
    mapping (address => uint256) public buyPerAccount;

/*UTILS & VIEW FUNCTIONS */
    
    function startTime(uint256 _id) external view returns(uint256) {
        return nftList[_id].start;
    }

    function endTime(uint256 _id) external view returns(uint256) {
        return nftList[_id].end;
    }

    function isNftOfferingActive(uint256 _id) external view returns(bool) {
        return nftList[_id].isNftOffering;
    }

    function isNftOfferingAuction(uint256 _id) external view returns(bool) {
        return nftList[_id].isNftAuction;
    }

    function nftPrices(uint256 _id) external view returns(uint256) {
        return nftList[_id].nftPrice;
    }

    function nftIdAvailabilities(uint256 _id) public view returns(uint256) {
        return kunciNFTCollection.balanceOf(stashAddress, _id);
    }

    function distributePayment(uint256 _amount) private 
    {
        uint256 artistAmount = _amount * artistFee / 10_000;
        uint256 platformFeeAmount = _amount * platformFee / 10_000;

        kunciToken.transfer(artist, artistAmount);
        kunciToken.transfer(platform, platformFeeAmount);
    }

/*CONSTRUCTOR */

    constructor(
        address _kunciAddress,
        address _stash,
        address _collectionAddr,
        uint96 _collectionId,
        string memory _collectionName,
        address _artist,
        address _platform,
        uint256 _platformFee,
        uint256 _artistFee,
        uint256 _buyLimit
    ) 
    {
        require((_platformFee + _artistFee) < 10_000, "Fee is not adding up to 100%");

        kunciToken = IERC20(_kunciAddress);
        kunciNFTCollection = IERC1155(_collectionAddr);

        collectionId = _collectionId;
        collectionName = _collectionName;

        stashAddress = _stash;
        platform = _platform;
        artist = _artist;
        
        platformFee = _platformFee;
        artistFee = _artistFee;

        buyLimit = _buyLimit;
    }

/*OWNER FUNCTIONS */

    function updateOfferingCollection(
        uint96 _collectionId,
        string calldata _collectionName,
        address _platform,
        address _artistAddress
    ) external onlyOwner 
    {
        collectionId = _collectionId;

        collectionName = _collectionName;
        platform = _platform;
        artist = _artistAddress;
    }

    function addCollectionNfts(
        uint256[] calldata _nftIds,
        bool[] calldata _isNftOfferingAuction,
        uint256[] calldata _prices,
        uint256[] calldata _offeringStartTimes,
        uint256[] calldata _offeringEndTimes
    ) external onlyOwner 
    {
        require(
            _nftIds.length == _isNftOfferingAuction.length 
            && _nftIds.length == _prices.length
            && _nftIds.length == _offeringStartTimes.length
            && _nftIds.length == _offeringEndTimes.length, 'Lengths mismatched'
            );

        collectionNftCount += _nftIds.length;

        for (uint256 i; i < _nftIds.length;) {
            NftId storage nft = nftList[_nftIds[i]];
            require(!nft.isNftOffering, "nft ID was listed");

            uint256 _start = _offeringStartTimes[i];
            uint256 _end = _offeringEndTimes[i];
            
            require(_start < _end, "Wrong end time");

            nft.isNftOffering = true;
            nft.nftPrice = _prices[i];
            nft.start = _start;
            nft.end = _end;
            if (_isNftOfferingAuction[i]) {
                nft.isNftAuction = true;
            }

            unchecked{++i;}
        }
    }

    function setFee(
        uint256 _platformFee,
        uint256 _artistFee
    ) external onlyOwner
    {
        require(_platformFee + _artistFee < 10_000, "Fee is not adding up to 100%");

        artistFee = _artistFee;
        platformFee = _platformFee;
    }

/**
 * @notice for emergency if any amount of token is stuck inside smart contract
 */
    function withdrawKunci() external onlyOwner
    {
        kunciToken.transfer(
            msg.sender, 
            kunciToken.balanceOf(address(this)) - pendingPayment
            );
    }

    function manageNftOfferings(
        uint256[] calldata _nftIds, 
        bool[] calldata _isOfferingActives
    ) external onlyOwner
    {
        require(_nftIds.length == _isOfferingActives.length, "Length mismatch");

        for (uint256 i; i < _nftIds.length;) {
            NftId storage nft = nftList[_nftIds[i]];
            require(nft.buyer == address(0), "NFT sold or in auction");
            nft.isNftOffering = _isOfferingActives[i];

            unchecked{++i;}
        }
    }

    function manageNftPrices(
        uint256[] calldata _nftIds, 
        uint256[] calldata _newPrices
    ) external onlyOwner
    {
        require(_nftIds.length == _newPrices.length, "Length mismatch");

        for (uint256 i; i < _nftIds.length;) {

            NftId storage nft = nftList[_nftIds[i]];
            require(nft.buyer == address(0), "NFT is sold or in auction");

            nft.nftPrice = _newPrices[i];

            unchecked{++i;}
        }
    }

    function setNftIsAuction(uint256[] calldata _nftIds) external onlyOwner
    {
        for (uint256 i; i < _nftIds.length;) {
            NftId storage nft = nftList[_nftIds[i]];
            require(nft.isNftOffering, "NFT is not listed");
            nft.isNftAuction = true;

            unchecked{++i;}
        }
    }

    function setTime(
        uint256[] calldata _nftIds,
        uint256[] calldata _starts,
        uint256[] calldata _ends
    ) external onlyOwner 
    {
        require(
            _nftIds.length == _starts.length
            && _nftIds.length == _ends.length,
            "Invalid length"
        );

        for (uint256 i; i < _nftIds.length;) {
            NftId storage nft = nftList[_nftIds[i]];
            uint256 _start = _starts[i];
            uint256 _end = _ends[i];
            require(nft.buyer == address(0), "Nft is sold");
            require(_start < _end, "Invalid time input");

            nft.start = _start;
            nft.end = _end;

            unchecked{++i;}
        }
    }

    function setBuyLimit(uint256 _limit) external onlyOwner {
        buyLimit = _limit;

        emit NewBuyLimit(_limit);
    }

/*PUBLIC FUNCTIONS */

    function purchase(uint256 _nftId)
    public 
    nonReentrant 
    whenNotPaused
    {
        NftId storage nft = nftList[_nftId];

        require(nft.isNftOffering, "NFT offering not yet started");
        require(!nft.isNftAuction, "NFT is not fixed price");
        require(buyPerAccount[msg.sender] < buyLimit, "buyLimit is exceeded");
        require(nft.start < block.timestamp, "Offering has not yet started");
        require(nft.end > block.timestamp, "Offering has ended");

        uint256 _amount = nft.nftPrice;

        unchecked{++nftSoldCount;}
        nftSoldAmount += _amount;
        nft.buyer = msg.sender;
        delete nft.isNftOffering;

        unchecked{++buyPerAccount[msg.sender];}

        kunciToken.transferFrom(msg.sender, address(this), _amount);
        
        distributePayment(_amount);

        kunciNFTCollection.safeTransferFrom(stashAddress, msg.sender, _nftId, 1, '');

        emit Purchase(_amount, _nftId, msg.sender, address(kunciNFTCollection));
    }

    function purchaseBatch(uint256[] calldata _ids) 
    external 
    nonReentrant
    whenNotPaused
    {
        uint256 _totalBuy = (buyPerAccount[msg.sender] += _ids.length);
        require(_totalBuy <= buyLimit, "buyLimit is excedeed");

        uint256 _amount;
        uint256[] memory _quantity = new uint256[] (_ids.length);

        for (uint256 i; i < _ids.length;) {
            NftId storage nft = nftList[_ids[i]];

            require(nft.isNftOffering, "NFT offering not yet started");
            require(!nft.isNftAuction, "NFT is not fixed price");

            _amount += nft.nftPrice;
            _quantity[i] = 1; // Only 1 per id
            delete nft.isNftOffering;

            unchecked{++i;}
        }

        kunciToken.transferFrom(msg.sender, address(this), _amount);
        distributePayment(_amount);

        address _stash = stashAddress;

        kunciNFTCollection.safeBatchTransferFrom(_stash, msg.sender, _ids, _quantity, '');

        emit PurchaseBatch(_amount, _ids, _stash, address(kunciNFTCollection));
    }

    function bid(uint256 _nftId, uint256 _amount) 
    external 
    nonReentrant
    whenNotPaused
    {
        NftId storage nft = nftList[_nftId];

        uint256 _lastPrice = nft.nftPrice;
        require(nft.isNftOffering, "NFT offering not yet started");
        require(nft.isNftAuction, "NFT is not auction");
        require(_amount > _lastPrice, "New bid must be higher price");
        require(nft.start < block.timestamp, "Offering has not yet started");
        require(nft.end > block.timestamp, "Offering has ended");
        require(buyPerAccount[msg.sender] < buyLimit, "buyLimit is exceeded");

        address _lastBuyer = nft.buyer;
        --buyPerAccount[_lastBuyer];
        unchecked{++buyPerAccount[msg.sender];}

        nft.buyer = msg.sender;
        nft.nftPrice = _amount;

        unchecked{pendingPayment += (_amount - _lastPrice);}

        kunciToken.transferFrom(msg.sender, address(this), _amount);

        if (_lastBuyer != address(0)) {
            //refund last bid
            kunciToken.transfer(_lastBuyer, _lastPrice);
        }

        emit Bid(_amount, _nftId, msg.sender, address(kunciNFTCollection));
    }

    function claimBidNft(uint256 _nftId) external nonReentrant 
    {
        NftId storage nft = nftList[_nftId];

        require(nft.isNftAuction, "NFT is not auction");
        require(block.timestamp > nft.end, "Can't claim this time");
        require(nft.buyer == msg.sender, "Only winner can claim");

        uint256 _price = nft.nftPrice;

        delete nft.isNftOffering;
        delete nft.isNftAuction;

        nftSoldAmount += _price;
        pendingPayment -= _price;
        unchecked{++nftSoldCount;}

        distributePayment(_price);

        kunciNFTCollection.safeTransferFrom(stashAddress, msg.sender, _nftId, 1, '');

        emit WinBid(_price, _nftId, msg.sender, address(kunciNFTCollection));
    }

    function closeOfferingAuction(uint256[] calldata _nftIds) external onlyOwner 
    {
        for (uint256 i; i < _nftIds.length;) {
            uint256 _id = _nftIds[i];
            NftId storage nft = nftList[_id];
            
            require(nft.end < block.timestamp, "Can't close this time");

            delete nft.isNftAuction;

            address _bidder = nft.buyer;

            if (_bidder != address(0)) {
                require(nft.end < block.timestamp, "Can't cloese this time");

                unchecked{++nftSoldCount;}

                uint256 _amount = nft.nftPrice;
                nftSoldAmount += _amount;

                delete nft.isNftOffering;

                distributePayment(_amount);
                kunciNFTCollection.safeTransferFrom(stashAddress, _bidder, _id, 1, '');
            }
            
            unchecked{++i;}
        }
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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