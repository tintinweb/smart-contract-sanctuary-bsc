/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

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


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

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

// File: contracts/marketplace.sol


pragma solidity ^0.8.7;



contract Marketplace {
    address TOKEN;

    constructor(address _token) {
        TOKEN = _token;
    }

    struct Token_list {
        uint256 id;
        uint256 price;
        address paymentToken;
        address Owner;
        bool forSale;
        bool Sold;
    }
    //  Token_list[] public GetTokens;

    mapping(uint256 => Token_list) public Sale;

    function CreateSale(
        uint256 _id,
        uint256 _price,
        address _paymentToken
    ) public {
        Token_list storage nftInfo = Sale[_id];
        require(!nftInfo.forSale, "Already on sale!");
        require(IERC721(TOKEN).ownerOf(_id) == msg.sender);

        Token_list memory ls = Token_list(
            _id,
            _price,
            _paymentToken,
            msg.sender,
            true,
            false
        );

        Sale[_id] = ls;

        // GetTokens.push(ls);

        IERC721(TOKEN).transferFrom(msg.sender, address(this), _id);
    }

    function buyNFTOnSale(uint256 _Id, uint256 _tokens) public payable {
        Token_list storage nftInfo = Sale[_Id];

        require(_tokens >= Sale[_Id].price, "Please enter the valid price");
        require(Sale[_Id].forSale == true, "NFT not for sale");
        require(Sale[_Id].Sold == false, "NFT already sold");

        // address(0) native

        if (nftInfo.paymentToken == address(0)) {
            // address payable buyer = payable(msg.sender);
            payable(nftInfo.Owner).transfer(msg.value);
            IERC721(TOKEN).transferFrom(address(this), msg.sender, nftInfo.id);
            // nftInfo.Owner = buyer;
            nftInfo.forSale = false;
            nftInfo.Sold = true;
        } else {
            IERC20 _paymentToken = IERC20(nftInfo.paymentToken);
            _paymentToken.transferFrom(msg.sender, nftInfo.Owner, _tokens);

            IERC721(TOKEN).transferFrom(address(this), msg.sender, nftInfo.id);

            nftInfo.forSale = false;
            nftInfo.Sold = true;
        }
    }

    struct Auction_list {
        uint256 NFT_id;
        uint256 price;
        address paymentToken;
        uint256 Currentbid;
        address Owner;
        bool forSale;
        bool Sold;
        uint256 endAuction;
        address payable HighestBidder;
    }
    mapping(uint256 => Auction_list) public Auction;

    function CreateAuction(
        uint256 _NFT_id,
        uint256 _endAuction,
        uint256 _price,
        address paymentToken
    ) public {
        Auction_list memory AC = Auction_list(
            _NFT_id,
            _price,
            paymentToken,
            0,
            msg.sender,
            true,
            false,
            block.timestamp + _endAuction,
            payable(address(0))
        );

        Auction[_NFT_id] = AC;

        IERC721(TOKEN).transferFrom(msg.sender, address(this), _NFT_id);
    }

    function bid(uint256 _NftId, uint256 bidamount) public payable {
        Auction_list storage nftInfo = Auction[_NftId];

        require(
            bidamount > nftInfo.Currentbid && bidamount > nftInfo.price,
            "bid is less"
        );
        require(nftInfo.forSale == true, "NFT not for sale");
        require(nftInfo.Sold == false, "NFT already sold");
        require(
            nftInfo.endAuction > block.timestamp,
            "The auction is already ended"
        );
        if (nftInfo.paymentToken == address(0)) {
            if (nftInfo.HighestBidder != address(0)){
            payable(nftInfo.HighestBidder).transfer(nftInfo.Currentbid);
            }
        } else {
            if (nftInfo.HighestBidder != address(0)) {
                IERC20 _paymentToken = IERC20(nftInfo.paymentToken);
                _paymentToken.transfer(
                    nftInfo.HighestBidder,
                    nftInfo.Currentbid
                );
            }
        }

        if (nftInfo.paymentToken == address(0)) {
            bidamount = msg.value;
        } else {
            IERC20 _paymentToken = IERC20(nftInfo.paymentToken);
            _paymentToken.transferFrom(msg.sender, address(this), bidamount);
        }

        nftInfo.HighestBidder = payable(msg.sender);
        nftInfo.Currentbid = bidamount;
    }

    function finalizeAuc(uint256 NftId) public {
        Auction_list storage nftInfo = Auction[NftId];
        require(nftInfo.Owner == msg.sender);
        if (nftInfo.paymentToken == address(0)) {
            payable(nftInfo.Owner).transfer(nftInfo.Currentbid);
        } else {
            IERC20 _paymentToken = IERC20(nftInfo.paymentToken);
            _paymentToken.transfer(nftInfo.Owner, nftInfo.Currentbid);
        }

        IERC721(TOKEN).transferFrom(
            address(this),
            nftInfo.HighestBidder,
            nftInfo.NFT_id
        );

        nftInfo.Owner = nftInfo.HighestBidder;

        nftInfo.forSale = false;
        nftInfo.Sold= true;
        
    }

    function CancleSale(uint256 _Id) public {
        Auction_list storage AucInfo = Auction[_Id];
        Token_list storage nftInfo = Sale[_Id];

        if (nftInfo.forSale == true) {
            IERC721(TOKEN).transferFrom(address(this), msg.sender, nftInfo.id);
            nftInfo.forSale = false;
        }
        if (AucInfo.forSale == true) {
            IERC721(TOKEN).transferFrom(
                address(this),
                msg.sender,
                Auction[_Id].NFT_id
            );
            if (AucInfo.paymentToken == address(0)) {
                payable(AucInfo.HighestBidder).transfer(AucInfo.Currentbid);
                AucInfo.forSale = false;
            } else {
                IERC20 _paymentToken = IERC20(AucInfo.paymentToken);
                _paymentToken.transfer(
                    AucInfo.HighestBidder,
                    AucInfo.Currentbid
                );
                AucInfo.forSale = false;
            }
        }
    }
}