/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;


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


interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}


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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

contract MarketplaceContract is IERC721Receiver, Ownable, ReentrancyGuard {

    using Counters for Counters.Counter;
    Counters.Counter public _itemIds;
    Counters.Counter public _itemsSold;
    address payable holder;

    address private nftVaultAddress = 0xfee1eDA9075244bdD34cf54516F04AE5803a4eC8;


    uint256 public listingFees = 0.0025 ether;
    IERC721 nft;

    struct MarketItem {
        uint256 itemId;
        uint256 tokenId;
        address payable seller;
        address payable holder;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) public idToMarketItem;

    event MarketItemCreated(
        uint256 itemId,
        uint256 indexed tokenId,
        address seller,
        address holder,
        uint256 price,
        bool sold
    );

    constructor(IERC721 _nft) {
        nft = _nft;
        holder = payable(msg.sender);
    }

    function listNft(uint256 tokenId, uint256 price) external payable nonReentrant {
        require(price > 0, "NftMarketResell: price < 0");
        require(msg.value == listingFees, "NftMarketResell: msg.value < listingFee");

        _itemIds.increment();
        uint256 newItemId = _itemIds.current();

        idToMarketItem[newItemId] = MarketItem({
            itemId: newItemId,
            tokenId: tokenId,
            price: price,
            seller: payable(msg.sender),
            holder: payable(address(this)),
            sold: false
        });

        nft.transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(newItemId, tokenId, msg.sender, address(this), price, false);
    }

    function buyNFT(uint256 itemId) external payable nonReentrant {
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        uint256 price = idToMarketItem[itemId].price;

        require(tokenId != 0, "invalid token id");
        require(msg.value == price, "NftMarketResell: msg.value < price");

        address seller = idToMarketItem[itemId].seller;

        payable(seller).transfer(msg.value);
        nft.transferFrom(address(this), msg.sender, tokenId);

        idToMarketItem[itemId].holder = payable(msg.sender);
        idToMarketItem[itemId].sold = true; // delete from market

        _itemsSold.increment();
        payable(holder).transfer(listingFees);
    }

    function cancelSale(uint256 tokenId) external nonReentrant {
        require(idToMarketItem[tokenId].seller == msg.sender, "This NFT is not yours");
        nft.transferFrom(address(this), msg.sender, tokenId);
        idToMarketItem[tokenId].sold = true;
    }

    function getAvailableNfts() public view returns (MarketItem[] memory) {
        uint256 itemIds = _itemIds.current();
        uint256 itemsSold = _itemsSold.current();

        uint256 totalItems = itemIds - itemsSold;
        MarketItem[] memory marketItems = new MarketItem[](totalItems);

        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= itemIds; i++) {
            if (idToMarketItem[i].holder == address(this)) {
                marketItems[currentIndex] = idToMarketItem[i];
                currentIndex++;
            }
        }
        return marketItems;
    }

    function getMyNfts(address ownerAddres) public view returns (MarketItem[] memory) {
        uint256 itemIds = _itemIds.current();

        uint256 itemsCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= itemIds; i++) {
            if (idToMarketItem[i].holder == ownerAddres) {
                itemsCount +=1;
            }
        }

        MarketItem[] memory mynfts = new MarketItem[](itemsCount);

        for (uint256 i = 1; i <= itemIds; i++) {
            if (idToMarketItem[i].holder == ownerAddres) {

                MarketItem storage currentItem = idToMarketItem[i];
                mynfts[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return mynfts;
    }

    function getMyMarketNfts(address ownerAddress) public view returns (MarketItem[] memory) {
        uint256 itemsSold = _itemsSold.current();
        uint256 itemIds = _itemIds.current();

        uint256 itemsCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= itemsSold; i++) {
            if (idToMarketItem[i].seller == ownerAddress) {
                itemsCount +=1;
            }
        }

        MarketItem[] memory mynfts = new MarketItem[](itemsCount);

        for (uint256 i = 1; i <= itemIds; i++) {
            if (idToMarketItem[i].holder == ownerAddress) {

                MarketItem storage currentItem = idToMarketItem[i];
                mynfts[currentIndex] = currentItem;
                currentIndex +=1;
            }
        }
        return mynfts;
    }

    function onERC721Received(address, address from, uint256, bytes calldata) external pure override returns (bytes4) {
        require(from == address(0x0), "Cannot send nfts to Vault directly");
        return IERC721Receiver.onERC721Received.selector;
    }

    function setListingFees(uint256 _listingFees) external onlyOwner {
        listingFees = _listingFees;
    }

    function setNftVaultAddress(address _nftVaultAddress) external onlyOwner {
        nftVaultAddress = _nftVaultAddress;
    }

    function setHolder(address payable _holder) external onlyOwner {
        holder = _holder;
    }


    function transferNftBridge(uint256 _tokenId) external {

        uint256 itemIds = _itemIds.current();
        uint256 itemsSold = _itemsSold.current();
        uint256 totalItems = itemIds - itemsSold;

        for (uint256 i = 0; i < totalItems; i++){
            if(idToMarketItem[i].holder == msg.sender){
                nft.transferFrom(address(this), nftVaultAddress, _tokenId);
            } 
        }
    }

    // function transferNftBridge(uint256 _tokenId) external {
    //     uint itemCount = _itemIds;
    //     for (uint256 i = 0; i < itemCount; i++){
    //         if(idToMarketItem[i].holder == msg.sender){
    //             nft.transferFrom(address(this), nftVaultAddress, _tokenId);
    //         } 
    //     }
    // }

    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}