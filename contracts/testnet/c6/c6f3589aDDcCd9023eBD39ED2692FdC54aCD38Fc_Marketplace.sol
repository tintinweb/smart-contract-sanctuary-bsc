pragma solidity ^0.8.9;



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

contract Marketplace {
    struct AuctionItem {
        uint256 id;
        address tokenAddress;
        uint256 tokenId;
        address payable seller;
        uint256 askingPrice;
        bool isSold;
    }

    IERC20 internal immutable BUSD =
        IERC20(address(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee));

    IERC20 internal immutable BloggerCoin =
        IERC20(address(0xDacD3d01D2D11D123e4d3BB5fd054a3e357962ff)); 
    
    IERC20 internal immutable USDT =
        IERC20(address(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd));
           
           
           
           

    AuctionItem[] public itemsForSaleBNB;
    AuctionItem[] public itemsForSaleBUSD;
    AuctionItem[] public itemsForSaleUSDT;
    AuctionItem[] public itemsForSaleBloggerCoin;

    mapping (address => mapping (uint256 => bool)) activeItems;

    event itemAdded(uint256 id, uint256 tokenId, address tokenAddress, uint256 askingPrice);
    event itemSold(uint256 id, address buyer, uint256 askingPrice);

    modifier OnlyItemOwner(address tokenAddress, uint256 tokenId){
        IERC721 tokenContract = IERC721(tokenAddress);
        require(tokenContract.ownerOf(tokenId) == msg.sender);
        _;
    }

    modifier HasTransferApproval(address tokenAddress, uint256 tokenId){
        IERC721 tokenContract = IERC721(tokenAddress);
        require(tokenContract.getApproved(tokenId) == address(this));
        _;
    }

    

    modifier ItemExistsBNB(uint256 id){
        require(id < itemsForSaleBNB.length && itemsForSaleBNB[id].id == id, "Could not find item");
        _;
    }

    modifier ItemExistsUSDT(uint256 id){
        require(id < itemsForSaleUSDT.length && itemsForSaleUSDT[id].id == id, "Could not find item");
        _;
    }

    modifier ItemExistsBUSD(uint256 id){
        require(id < itemsForSaleBUSD.length && itemsForSaleBUSD[id].id == id, "Could not find item");
        _;
    }

    modifier ItemExistsBloggerCoin(uint256 id){
        require(id < itemsForSaleBloggerCoin.length && itemsForSaleBloggerCoin[id].id == id, "Could not find item");
        _;
    }

    modifier IsForSaleBNB(uint256 id){
        require(itemsForSaleBNB[id].isSold == false, "Item is already sold!");
        _;
    }

    modifier IsForSaleUSDT(uint256 id){
        require(itemsForSaleUSDT[id].isSold == false, "Item is already sold!");
        _;
    }

    modifier IsForSaleBUSD(uint256 id){
        require(itemsForSaleBUSD[id].isSold == false, "Item is already sold!");
        _;
    }

    modifier IsForSaleBloggerCoin(uint256 id){
        require(itemsForSaleBloggerCoin[id].isSold == false, "Item is already sold!");
        _;
    }

    function sellItemBNB(uint256 tokenId, address tokenAddress, uint256 askingPrice) OnlyItemOwner(tokenAddress,tokenId) HasTransferApproval(tokenAddress,tokenId) external returns (uint256){
        require(activeItems[tokenAddress][tokenId] == false, "Item is already up for sale!");
        uint256 newItemId = itemsForSaleBNB.length;
        itemsForSaleBNB.push(AuctionItem(newItemId, tokenAddress, tokenId, payable(msg.sender), askingPrice, false));
        activeItems[tokenAddress][tokenId] = true;

        assert(itemsForSaleBNB[newItemId].id == newItemId);
        emit itemAdded(newItemId, tokenId, tokenAddress, askingPrice);
        return newItemId;
    }

    function sellItemBUSD(uint256 tokenId, address tokenAddress, uint256 askingPrice) OnlyItemOwner(tokenAddress,tokenId) HasTransferApproval(tokenAddress,tokenId) external returns (uint256){
        require(activeItems[tokenAddress][tokenId] == false, "Item is already up for sale!");
        uint256 newItemId = itemsForSaleBUSD.length;
        itemsForSaleBUSD.push(AuctionItem(newItemId, tokenAddress, tokenId, payable(msg.sender), askingPrice, false));
        activeItems[tokenAddress][tokenId] = true;

        assert(itemsForSaleBUSD[newItemId].id == newItemId);
        emit itemAdded(newItemId, tokenId, tokenAddress, askingPrice);
        return newItemId;
    }

    function sellItemUSDT(uint256 tokenId, address tokenAddress, uint256 askingPrice) OnlyItemOwner(tokenAddress,tokenId) HasTransferApproval(tokenAddress,tokenId) external returns (uint256){
        require(activeItems[tokenAddress][tokenId] == false, "Item is already up for sale!");
        uint256 newItemId = itemsForSaleUSDT.length;
        itemsForSaleUSDT.push(AuctionItem(newItemId, tokenAddress, tokenId, payable(msg.sender), askingPrice, false));
        activeItems[tokenAddress][tokenId] = true;

        assert(itemsForSaleUSDT[newItemId].id == newItemId);
        emit itemAdded(newItemId, tokenId, tokenAddress, askingPrice);
        return newItemId;
    }

    function sellItemBloggerCoin(uint256 tokenId, address tokenAddress, uint256 askingPrice) OnlyItemOwner(tokenAddress,tokenId) HasTransferApproval(tokenAddress,tokenId) external returns (uint256){
        require(activeItems[tokenAddress][tokenId] == false, "Item is already up for sale!");
        uint256 newItemId = itemsForSaleBloggerCoin.length;
        itemsForSaleBloggerCoin.push(AuctionItem(newItemId, tokenAddress, tokenId, payable(msg.sender), askingPrice, false));
        activeItems[tokenAddress][tokenId] = true;

        assert(itemsForSaleBloggerCoin[newItemId].id == newItemId);
        emit itemAdded(newItemId, tokenId, tokenAddress, askingPrice);
        return newItemId;
    }

    function buyItemBNB(uint256 id) payable external ItemExistsBNB(id) IsForSaleBNB(id) HasTransferApproval(itemsForSaleBNB[id].tokenAddress,itemsForSaleBNB[id].tokenId){
        require(msg.value >= itemsForSaleBNB[id].askingPrice, "Not enough funds sent");
        require(msg.sender != itemsForSaleBNB[id].seller);

        itemsForSaleBNB[id].isSold = true;
        activeItems[itemsForSaleBNB[id].tokenAddress][itemsForSaleBNB[id].tokenId] = false;
        IERC721(itemsForSaleBNB[id].tokenAddress).safeTransferFrom(itemsForSaleBNB[id].seller, msg.sender, itemsForSaleBNB[id].tokenId);
        itemsForSaleBNB[id].seller.transfer(msg.value);

        emit itemSold(id, msg.sender,itemsForSaleBNB[id].askingPrice);
    }

    function buyItemBUSD(uint256 id)  external ItemExistsBUSD(id) IsForSaleBUSD(id) HasTransferApproval(itemsForSaleBUSD[id].tokenAddress,itemsForSaleBUSD[id].tokenId){
        require(msg.sender != itemsForSaleBUSD[id].seller);

        uint256 amount = itemsForSaleBUSD[id].askingPrice * (10**18);
        

        itemsForSaleBUSD[id].isSold = true;
        activeItems[itemsForSaleBUSD[id].tokenAddress][itemsForSaleBUSD[id].tokenId] = false;
        IERC721(itemsForSaleBUSD[id].tokenAddress).safeTransferFrom(itemsForSaleBUSD[id].seller, msg.sender, itemsForSaleBUSD[id].tokenId);
        require(BUSD.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance.");
        require(BUSD.balanceOf(msg.sender) >= amount, "Insufficient balance.");
        BUSD.transferFrom(msg.sender, itemsForSaleBUSD[id].seller, amount);

        emit itemSold(id, msg.sender, amount);
    }

    function buyItemUSDT(uint256 id) external ItemExistsUSDT(id) IsForSaleUSDT(id) HasTransferApproval(itemsForSaleUSDT[id].tokenAddress,itemsForSaleUSDT[id].tokenId){
        require(msg.sender != itemsForSaleUSDT[id].seller);

        uint256 amount = itemsForSaleUSDT[id].askingPrice * (10**18);
        

        itemsForSaleUSDT[id].isSold = true;
        activeItems[itemsForSaleUSDT[id].tokenAddress][itemsForSaleUSDT[id].tokenId] = false;
        IERC721(itemsForSaleUSDT[id].tokenAddress).safeTransferFrom(itemsForSaleUSDT[id].seller, msg.sender, itemsForSaleUSDT[id].tokenId);
        require(USDT.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance.");
        require(USDT.balanceOf(msg.sender) >= amount, "Insufficient balance.");
        USDT.transferFrom(msg.sender, itemsForSaleUSDT[id].seller, amount);

        emit itemSold(id, msg.sender, amount);
    }

    function buyItemBloggerCoin(uint256 id) external ItemExistsBloggerCoin(id) IsForSaleBloggerCoin(id) HasTransferApproval(itemsForSaleBloggerCoin[id].tokenAddress,itemsForSaleBloggerCoin[id].tokenId){
        require(msg.sender != itemsForSaleBloggerCoin[id].seller);

        uint256 amount = itemsForSaleBloggerCoin[id].askingPrice * (10**18);
        

        itemsForSaleBloggerCoin[id].isSold = true;
        activeItems[itemsForSaleBloggerCoin[id].tokenAddress][itemsForSaleBloggerCoin[id].tokenId] = false;
        IERC721(itemsForSaleBloggerCoin[id].tokenAddress).safeTransferFrom(itemsForSaleBloggerCoin[id].seller, msg.sender, itemsForSaleBloggerCoin[id].tokenId);
        require(BloggerCoin.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance.");
        require(BloggerCoin.balanceOf(msg.sender) >= amount, "Insufficient balance.");
        BloggerCoin.transferFrom(msg.sender, itemsForSaleBloggerCoin[id].seller, amount);

        emit itemSold(id, msg.sender, amount);
    }
}