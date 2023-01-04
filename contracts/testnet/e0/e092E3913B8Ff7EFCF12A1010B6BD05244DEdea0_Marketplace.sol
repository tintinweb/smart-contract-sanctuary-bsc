/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

interface IDatabase {
    function isVerified(address account) external view returns (bool);
    function isAuthorized(address account) external view returns (bool);
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

/**
    Facilitates Buying and Selling of NFTs between two independent parties
 */
contract Marketplace {

    // Verification And Authorization Database
    IDatabase public immutable Database;

    // Bidding Currency
    address public biddingCurrency;

    // Allowed Currencies
    mapping ( address => bool ) public allowedCurrencies;

    // Company Royalty
    uint256 public company_royalty_percentage = 2500;
    uint256 public constant ROYALTY_DENOM = 10**5;

    // Address to receive royalties
    address public royaltyReceiver;

    // Bid Structure
    struct Bid {
        uint256 bid;
        uint256 expiration;
        address initiator;
        address currency;
        uint32 index;
    }

    // Market Item
    struct MarketItem {
        uint256 ask;
        address currency;
        uint256 expiration;
        address initiator;
        Bid[] bids;
        mapping ( address => uint256 ) userBids;
    }

    // NFT => tokenID => MarketItem
    mapping ( address => mapping ( uint256 => MarketItem )) private marketItems;

    // Modifiers
    modifier ensureExpiration(uint timestamp) {
        require(
            timestamp >= block.timestamp,
            'EXPIRED'
        );
        _;
    }
    modifier ensureApproval(address nft, uint tokenId, address owner) {
        require(
            isOwner(nft, tokenId, owner),
            'Not Owner'
        );
        require(
            _isApproved(nft, tokenId),
            'Not Approved For Sale'
        );
        _;
    }

    modifier onlyOwner() {
        require(
            Database.isAuthorized(msg.sender),
            'Not Authorized'
        );
        _;
    }

    constructor(address DB, address biddingCurrency_, address royaltyReceiver_) {
        
        // set Database
        Database = IDatabase(DB);

        // set royalty receiver
        royaltyReceiver = royaltyReceiver_;

        // set and allow bidding currency and native (address(0))
        biddingCurrency = biddingCurrency_;
        allowedCurrencies[address(0)] = true;
        allowedCurrencies[biddingCurrency_] = true;
    }

    ///////////////////////////////////////////
    ////////    PUBLIC FUNCTIONS    ///////////
    ///////////////////////////////////////////


    /**
        Puts up Token ID `tokenId` Of the collection associated with `nft` for sale
        @param nft - NFT Collection To Be Listed
        @param tokenId - Token ID To List
        @param _ask - Minimum Quantity of tokens to receive in return for NFT
        @param expiration - Maximum Time Stamp Where Ask Can Be Bought
     */
    function ask(address nft, uint tokenId, uint256 _ask, address currency, uint256 expiration) external ensureApproval(nft, tokenId, msg.sender) ensureExpiration(expiration) {
        require(
            _ask > 0,
            'Zero Ask'
        );
        require(
            allowedCurrencies[currency],
            'Currency Not Allowed'
        );
        
        marketItems[nft][tokenId].ask = _ask;
        marketItems[nft][tokenId].currency = currency;
        marketItems[nft][tokenId].expiration = expiration;
        marketItems[nft][tokenId].initiator = msg.sender;
    }

    /**
        Updates The Asking Price Of A Currently Listed NFT
        @param nft - NFT Collection To Be Listed
        @param tokenId - Token ID To List
        @param _ask - Minimum Quantity of tokens to receive in return for NFT
     */
    function updateAsk(address nft, uint tokenId, uint256 _ask) external ensureApproval(nft, tokenId, msg.sender) {
        require(
            _ask > 0,
            'Zero Ask'
        );
        require(
            marketItems[nft][tokenId].ask > 0,
            'No Ask'
        );

        marketItems[nft][tokenId].ask = _ask;
    }

    /**
        Updates The Expiration Date Of NFT Listing
        @param nft - NFT Collection To Be Listed
        @param tokenId - Token ID To List
        @param expiration - Maximum Time Stamp Where Ask Can Be Bought
     */
    function updateExpiration(address nft, uint tokenId, uint256 expiration) external ensureApproval(nft, tokenId, msg.sender) ensureExpiration(expiration) {
        require(
            marketItems[nft][tokenId].ask > 0,
            'No Ask'
        );
        marketItems[nft][tokenId].expiration = expiration;
    }

    /**
        De-Lists Token ID `tokenId` Of the collection associated with `nft`
        @param nft - NFT Collection To Be De-Listed
        @param tokenId - Token ID To De-List
     */
    function delist(address nft, uint256 tokenId) external ensureApproval(nft, tokenId, msg.sender) {
        delete marketItems[nft][tokenId].ask;
        delete marketItems[nft][tokenId].currency;
        delete marketItems[nft][tokenId].expiration;
        delete marketItems[nft][tokenId].initiator;
        delete marketItems[nft][tokenId].bids;
    }

    /**
        Accepts A Bid At Index `bidID`
        Transfers NFT To Bid Initiator

        @param nft - NFT Collection To Collect Bid
        @param tokenId - Token ID To Accept Bid
        @param bidID - Index of Bid In Bid Array
        @param minBid - Minimum Bid To Accept, prevents front running Accepts by raising bids
     */
    function acceptBid(address nft, uint tokenId, uint256 bidID, uint minBid) external ensureApproval(nft, tokenId, msg.sender) ensureExpiration(marketItems[nft][tokenId].bids[bidID].expiration) {
        require(
            bidID < marketItems[nft][tokenId].bids.length,
            'Invalid Bid'
        );

        // Fetch Bid And Initiator Of Bid
        uint256 _bid = marketItems[nft][tokenId].bids[bidID].bid;
        address initiator = marketItems[nft][tokenId].bids[bidID].initiator;
        address currency = marketItems[nft][tokenId].bids[bidID].currency;
        require(
            initiator != address(0) &&
            _bid > 0,
            'Zero Input'
        );
        require(
            minBid <= _bid,
            'Bid Has Been Lowered or Canceled'
        );

        // clear marketItem data
        _removeAskData(nft, tokenId);

        // remove user's bid
        _removeBidData(nft, tokenId, initiator);

        // send token to nft owner
        _executeTokenTransaction(currency, address(this), msg.sender, _bid);

        // transfer NFT from owner to bidder
        _NFTTransaction(nft, msg.sender, initiator, tokenId);
    }

    /**
        Buys The Token ID `tokenId` From The
        Collection Associated With `nft`
        @param nft - NFT Collection To Purchase From
        @param tokenId - Token ID To Purchase
        @param maxAsk - maximum Ask price allowed, prevents front running Buys by raising asks
     */
    function buy(address nft, uint tokenId, uint256 maxAsk) external payable ensureApproval(nft, tokenId, marketItems[nft][tokenId].initiator) ensureExpiration(marketItems[nft][tokenId].expiration) {

        // set data
        address initiator = marketItems[nft][tokenId].initiator;
        uint256 _ask = marketItems[nft][tokenId].ask;
        address _currency = marketItems[nft][tokenId].currency;

        if (_currency == address(0)) {
            require(
                msg.value >= _ask,
                'Incorrect Value Sent'
            );
        }

        // ensure ask has been set
        require(
            _ask > 0 && initiator != address(0),
            'No Ask'
        );
        require(
            _ask <= maxAsk,
            'Ask Adjusted'
        );
        
        // fetch NFT owner
        address owner = IERC721(nft).ownerOf(tokenId);
        require(
            owner != address(0),
            'Zero Address'
        );
        require(
            owner == initiator,
            'Ownership Has Been Transferred'
        );

        // clear marketItem data
        _removeAskData(nft, tokenId);

        // send currency to owner
        _executeTokenTransaction(_currency, msg.sender, initiator, _ask);

        // transfer NFT from owner to buyer
        _NFTTransaction(nft, owner, msg.sender, tokenId);
    }

    /**
        Places a bid on a specific `tokenId` belonging
        To the collection associated with `nft`
        Bid must be greater than the previous highest bid
        @param nft - NFT Collection to bid on
        @param tokenId - specific NFT to bid on
        @param _bid - bid in currency token
        @param expiration - timestamp when bid expires, must be greater than current timestamp
     */
    function bid(address nft, uint256 tokenId, uint256 _bid, uint256 expiration) external ensureExpiration(expiration) {
        require(
            _bid > 0,
            'Zero Bid'
        );

        // Must Call ChangeBid If Bid Exists
        require(
            hasPlacedBid(msg.sender, nft, tokenId) == false,
            'Sender Has Already Bid'
        );

        // length of bid array
        uint32 length = uint32(marketItems[nft][tokenId].bids.length);
        if (length > 0) {
            require(
                _bid > marketItems[nft][tokenId].bids[length - 1].bid,
                'Bid Must Exceed Previous Bid'
            );
        }

        // push new bid
        marketItems[nft][tokenId].userBids[msg.sender] = length;
        marketItems[nft][tokenId].bids.push(Bid({
            bid: _bid,
            expiration: expiration,
            initiator: msg.sender,
            currency: biddingCurrency,
            index: length
        }));

        // transfer in currency and store in case bid is accepted
        _sendFrom(biddingCurrency, msg.sender, address(this), _bid);
    }

    /**
        Changes An Active Bid To A New Bid Amount And Expiration
        Requirements
            - `msg.sender` must have already bid on `tokenId` associated with `nft` 
            - new bid cannot be 0, instead user can call cancelBid()
            - new bid must be greater than the current bid
        @param nft - NFT Collection to bid on
        @param tokenId - specific NFT to bid on
        @param newBid - bid in currency token
        @param newExpiration - timestamp when bid expires, must be greater than current timestamp
     */
    function changeBid(address nft, uint256 tokenId, uint256 newBid, uint256 newExpiration) external ensureExpiration(newExpiration) {

        // require data is reasonable
        require(
            hasPlacedBid(msg.sender, nft, tokenId),
            'No Bid To Change'
        );

        // bid Index
        uint index = marketItems[nft][tokenId].userBids[msg.sender];
        require(
            marketItems[nft][tokenId].bids[index].currency == biddingCurrency,
            'Cancel Bid, Currency has changed'
        );

        // fetch data
        uint oldBid = marketItems[nft][tokenId].bids[index].bid;
        require(
            oldBid < newBid,
            'New Bid Must Be Greater Than Old Bid'
        );

        // update data
        marketItems[nft][tokenId].bids[index].bid = newBid;
        marketItems[nft][tokenId].bids[index].expiration = newExpiration;

        // transfer in more tokens
        _sendFrom(biddingCurrency, msg.sender, address(this), newBid - oldBid);
    }

    /**
        Removes An Active Bid, Refunding token Stored In Contract For Initiator
        Requirements
            - `msg.sender` must have already bid on `tokenId` associated with `nft` 
        @param nft - NFT Collection to remove the bid for
        @param tokenId - tokenId in collection `NFT` to remove bid for
     */
    function cancelBid(address nft, uint256 tokenId) external {

        require(
            hasPlacedBid(msg.sender, nft, tokenId),
            'No Bid To Cancel'
        );

        // bid Index
        uint index = marketItems[nft][tokenId].userBids[msg.sender];

        // bid currency used
        address currency = marketItems[nft][tokenId].bids[index].currency;

        // token to return to sender
        uint256 toSend = marketItems[nft][tokenId].bids[index].bid;

        // remove bid from list
        _removeBidData(nft, tokenId, msg.sender);

        // refund token to sender
        _send(currency, msg.sender, toSend);
    }

    receive() external payable {}

    ///////////////////////////////////////////
    ////////   INTERNAL FUNCTIONS   ///////////
    ///////////////////////////////////////////


    /**
        Clears Ask Data Associated With `nft` and `tokenId`
        @param nft - NFT Collection To Clear Ask Data For
        @param tokenId - tokenId To Clear Ask Data For
     */
    function _removeAskData(address nft, uint256 tokenId) internal {
        delete marketItems[nft][tokenId].ask;
        delete marketItems[nft][tokenId].expiration;
        delete marketItems[nft][tokenId].initiator;
    }

    /**
        Clears Bid Data Associated With `user`, `nft`, and `tokenId`
        @param nft - NFT Collection To Clear Ask Data For
        @param tokenId - tokenId To Clear Ask Data For
        @param user - User who's bid is being removed
     */
    function _removeBidData(address nft, uint256 tokenId, address user) internal {

        // bid ID
        uint256 bidID = marketItems[nft][tokenId].userBids[user];
        require(
            marketItems[nft][tokenId].bids[bidID].initiator == user,
            'User Did Not Place Bid'
        );

        // length of bids
        uint bidLength = marketItems[nft][tokenId].bids.length;

        // if length <= 1, reset the entire bids array
        if (bidLength <= 1) {
            delete marketItems[nft][tokenId].bids;
            delete marketItems[nft][tokenId].userBids[user];
            return;
        }

        // last user who has bid
        address lastBidder = marketItems[nft][tokenId].bids[bidLength - 1].initiator;
        
        // set last user bid ID to be the removed bidID
        marketItems[nft][tokenId].userBids[lastBidder] = bidID;

        // set removed element of bid array to be last element
        marketItems[nft][tokenId].bids[bidID] = marketItems[nft][tokenId].bids[bidLength - 1];

        // pop last bid off the array
        marketItems[nft][tokenId].bids.pop();

        // delete user's bid index
        delete marketItems[nft][tokenId].userBids[user];
    }

    /**
        Handles A Token Transaction On An NFT
        Takes All Royalties And Ensures `amount` of `token` Are Sent
        From `from` To `to`
        @param token - The currency used in the transaction
        @param from - owner of the `token`
        @param to - recipient of the `token`
        @param amount - amount of `token` to transact
     */
    function _executeTokenTransaction(address token, address from, address to, uint256 amount) internal {
        if (from != address(this) && token != address(0)) {
            require(
                IERC20(token).balanceOf(from) >= amount,
                'IB'
            );
            require(
                IERC20(token).allowance(from, address(this)) >= amount,
                'IA'
            );
        }
        uint royalties = _takeRoyalty(token, from, amount);
        _sendFrom(token, from, to, amount - royalties);
    }

    /**
        Takes The Royalty Associated with `nft`
        Sends Royalty To Associated Addresses
        @param token - currency to trade
        @param from - NFT buyer
        @param amount - size of the transaction in KEYS
     */
    function _takeRoyalty(address token, address from, uint256 amount) internal returns (uint256) {

        // calculate token royalty
        uint ownerRoyalty = ( amount * company_royalty_percentage ) / ROYALTY_DENOM;
        _sendFrom(token, from, royaltyReceiver, ownerRoyalty);

        // return royalties collected
        return ownerRoyalty;
    }

    /**
        Sends `token` From Contract To Recipient
        @param token - currency to transfer, address(0) for native
        @param to - Recipient of token
        @param amount - amount of `token` to transact
     */
    function _send(address token, address to, uint256 amount) internal {
        if (amount == 0) {
            return;
        }
        if (token == address(0)) {
            payable(to).transfer(amount);
        } else {
            TransferHelper.safeTransfer(token, to, amount);
        }
    }

    /**
        Sends Token From `from` To `to`
        @param token - currency to transact
        @param from - Sender of `token`
        @param to - Recipient of `token`
        @param amount - amount of `token` to transact
     */
    function _sendFrom(address token, address from, address to, uint256 amount) internal {
        if (amount == 0) {
            return;
        }
        if (from == address(this)) {
            _send(token, to, amount);
        } else {
            if (token == address(0)) {
                payable(to).transfer(amount);
            } else {
                TransferHelper.safeTransferFrom(token, from, to, amount);
            }
        }
    }

    /**
        Facilitates an NFT safeTransferFrom
        Ensures the Transaction was successful by validating ownership
        @param nft - NFT to transact
        @param from - Owner of NFT
        @param to - recipient of NFT
        @param tokenId - token id to transact
     */
    function _NFTTransaction(address nft, address from, address to, uint tokenId) internal {

        // transfer from `from` to `to`
        IERC721(nft).safeTransferFrom(
            from,
            to,
            tokenId
        );

        // ensure msg.sender owns nft
        require(
            isOwner(nft, tokenId, to),
            'Not NFT Owner'
        );
    }

    /**
     * @dev Returns whether `address(this)` is allowed to manage `tokenId`.
     */
    function _isApproved(address NFT, uint256 tokenId) internal view returns (bool) {
        address _owner = IERC721(NFT).ownerOf(tokenId);
        return (IERC721(NFT).getApproved(tokenId) == address(this) || IERC721(NFT).isApprovedForAll(_owner, address(this)));
    }

    /**
        Validates Ownership of an NFT
     */
    function isOwner(address NFT, uint tokenId, address owner) internal view returns (bool) {
        return IERC721(NFT).ownerOf(tokenId) == owner;
    }


    ///////////////////////////////////////////
    /////////    OWNER FUNCTIONS    ///////////
    ///////////////////////////////////////////


    /**
        Sets The Royalty Recipient For Owner
        @param receiver - new royalty recipient, cannot be address(0)
     */
    function setRoyaltyReceiver(address receiver) external onlyOwner {
        require(
            receiver != address(0),
            'Zero Address'
        );
        royaltyReceiver = receiver;
    }

    function setBiddingCurrency(address newCurrency) external onlyOwner {
        biddingCurrency = newCurrency;
    }

    function allowCurrency(address currency, bool isAllowed) external onlyOwner {
        allowedCurrencies[currency] = isAllowed;
    }

    function setCompanyRoyaltyPercentage(uint256 newPercent) external onlyOwner {
        require(
            newPercent <= ROYALTY_DENOM / 2,
            'Percentage Too High'
        );
        company_royalty_percentage = newPercent;
    }

    ///////////////////////////////////////////
    /////////    READ FUNCTIONS    ////////////
    ///////////////////////////////////////////

    function isListingValid(address nft, uint256 tokenId) public view returns (bool) {
        return 
            isOwner(nft, tokenId, marketItems[nft][tokenId].initiator) && 
            marketItems[nft][tokenId].ask > 0 &&
            marketItems[nft][tokenId].initiator != address(0);
    }

    function getAsk(address nft, uint256 tokenId) external view returns (uint256) {
        return marketItems[nft][tokenId].ask;
    }

    function getAskData(address nft, uint256 tokenId) public view returns (uint256, uint256, address) {
        return ( marketItems[nft][tokenId].ask, marketItems[nft][tokenId].expiration, marketItems[nft][tokenId].initiator);
    }

    function getBatchAskData(address nft, uint256[] calldata tokenIds) external view returns (uint256[] memory, uint256[] memory, address[] memory) {

        // return list of asks, expirations, and initiators
        uint nAsks = tokenIds.length;
        uint256[] memory asks = new uint256[](nAsks);
        uint256[] memory expirations = new uint256[](nAsks);
        address[] memory initiators = new address[](nAsks);

        for (uint i = 0; i < nAsks;) {
            (
                asks[i],
                expirations[i],
                initiators[i]
            ) = getAskData(nft, tokenIds[i]);
            unchecked { ++i; }
        }

        return ( asks, expirations, initiators );
    }

    function getBatchAskDataWithValidityCheck(address nft, uint256[] calldata tokenIds) external view returns (uint256[] memory, uint256[] memory, address[] memory, bool[] memory) {

        // return list of asks, expirations, and initiators
        uint nAsks = tokenIds.length;
        uint256[] memory asks = new uint256[](nAsks);
        uint256[] memory expirations = new uint256[](nAsks);
        address[] memory initiators = new address[](nAsks);
        bool[] memory isValid = new bool[](nAsks);

        for (uint i = 0; i < nAsks;) {
            (
                asks[i],
                expirations[i],
                initiators[i]
            ) = getAskData(nft, tokenIds[i]);
            isValid[i] = isListingValid(nft, tokenIds[i]);
            unchecked { ++i; }
        }

        return ( asks, expirations, initiators, isValid );
    }

    function getBids(address nft, uint256 tokenId) external view returns (uint256[] memory, uint256[] memory, address[] memory) {

        // return list of bids, expirations, and initiators
        uint nBids = marketItems[nft][tokenId].bids.length;
        uint256[] memory bids = new uint256[](nBids);
        uint256[] memory expirations = new uint256[](nBids);
        address[] memory initiators = new address[](nBids);

        for (uint i = 0; i < nBids;) {
            bids[i] = marketItems[nft][tokenId].bids[i].bid;
            expirations[i] = marketItems[nft][tokenId].bids[i].expiration;
            initiators[i] = marketItems[nft][tokenId].bids[i].initiator;
            unchecked { ++i; }
        }
        return (bids, expirations, initiators);
    }

    function hasPlacedBid(address user, address nft, uint256 tokenId) public view returns (bool) {
        uint bidIndex = marketItems[nft][tokenId].userBids[user];
        if (bidIndex >= marketItems[nft][tokenId].bids.length) {
            return false;
        }
        return marketItems[nft][tokenId].bids[bidIndex].initiator == user;
    }

    function getUserBid(address user, address nft, uint256 tokenId) external view returns (uint256 userBid) {
        (userBid,) = getUserBidAndExpiration(user, nft, tokenId);
    }

    function getUserBidAndExpiration(address user, address nft, uint256 tokenId) public view returns (uint256, uint256) {
        if (hasPlacedBid(user, nft, tokenId) == false) {
            return (0,0);
        }
        uint index = marketItems[nft][tokenId].userBids[user];
        return ( marketItems[nft][tokenId].bids[index].bid, marketItems[nft][tokenId].bids[index].expiration);
    }
}