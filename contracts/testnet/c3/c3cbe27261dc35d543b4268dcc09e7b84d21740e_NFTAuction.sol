/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
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

interface ERC20 {
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

interface ERC2981 {
    function royaltyInfo(uint256 tokenId, uint256 value) external view returns (address receiver, uint256 royaltyAmount);
}

/// @title Auction contract for NFT marketplace
/// @notice This contract can be used for NFT which will accept ETH as payment
contract NFTAuction is Initializable{

    // ERC20 citrus;
    ERC2981 royalty;
    address public owner;

    // Auction has to be unique for each NFT
    struct Auction {
        uint bidPeriod; // Bid active time
        uint auctionEndPeriod;
        uint minPrice; // Minimum price to bid
        uint tokenMinPrice;
        uint buyNowPrice; // Can be bought at any moment by providing this price
        uint tokenBuyNowPrice; // Citrus token price
        uint nftHighestBid;
        uint tokenHighestBid;
        address nftHighestBidder;
        address nftSeller;
    }

    mapping(address => mapping(uint256 => Auction)) public nftContractAuctions;
    mapping(address => uint256) failedTransferCredits;

    // Count for bids and sales
    uint public nftOnSale;

    // Commission percentage and address
    uint commission;
    address commissionAddress;

    // Default value if not specified by the seller
    uint defaultBidPeriod; // To be set in constructor

    // EVENTS
    event NFTAuctionCreated(address nftContractAddress, uint tokenId, address nftSeller, uint minPrice, uint buyNowPrice, uint bidPeriod);
    event SaleCreated(address nftContractAddress, uint tokenId, address nftSeller, uint buyNowPrice);
    event BidMade(address nftContractAddress, uint tokenId, address bidder, uint ethAmount);
    event AuctionPeriodUpdated(address nftContractAddress, uint tokenId, uint auctionEndPeriod);
    event NFTTransferredAndSellerPaid(address nftContractAddress, uint tokenId, address nftSeller, uint highestBid, address highestBidder);
    event AuctionSettled(address nftContractAddress, uint tokenId, address auctionSettler);
    event AuctionWithdrawn(address nftContractAddress, uint tokenId, address nftOwner);
    event BidWithdrawn(address nftContractAddress, uint tokenId, address highestBidder);
    event MinPriceUpdated(address nftContractAddress, uint tokenId, uint newMinPrice);
    event BuyNowPriceUpdated(address nftContractAddress, uint tokenId, uint newBuyNowPrice);
    event HighestBidTaken(address nftContractAddress, uint tokenId);
    event SaleWithdrawn(address nftContractAddress, uint tokenId, address nftOwner);


    function initialize() public virtual  initializer {
        defaultBidPeriod = 86400; //1 day
        commissionAddress = msg.sender;
        commission = 2;
        commissionAddress = msg.sender;
        royalty = ERC2981(0x206a95De33B51B4c649A5f34bfb6491d38dC6589);
        owner = msg.sender;
    }

    // CHANGE OWNERSHIP OF CONTRACT
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Cannot transfer to zero address");
        owner = newOwner;
    }

    /**
        MODIFIERS
     */
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier isAuctionNotStartedByOwner(address nftContractAddress, uint tokenId) {
        require(nftContractAuctions[nftContractAddress][tokenId].nftSeller != msg.sender, "Auction already started by owner");
        if (nftContractAuctions[nftContractAddress][tokenId].nftSeller != address(0)){
            require(msg.sender == IERC721(nftContractAddress).ownerOf(tokenId), "Seller does not own NFT");
        }
        _;
    }

    modifier auctionOngoing(address nftContractAddress, uint tokenId) {
        require(isAuctionOngoing(nftContractAddress, tokenId), "Auction has ended");
        _;
    }

    modifier priceGreaterThanZero(uint price) {
        require(price > 0, "Price has to be greater than 0");
        _;
    }

    // Minimum price should be 80% of the buy price
    modifier minPriceDoesNotExceedLimit(uint buyNowPrice, uint minPrice) {
        require(buyNowPrice == 0 || getPortionOfBid(buyNowPrice, 80) >= minPrice, "MinPrice > 80% of BuyNowPrice");
        _;
    }

    modifier notNftSeller(address nftContractAddress, uint tokenId) {
        require(msg.sender != nftContractAuctions[nftContractAddress][tokenId].nftSeller, "Owner cannot buy their own NFT");
        _;
    }

    modifier onlyNftSeller(address nftContractAddress, uint tokenId) {
        require(msg.sender == nftContractAuctions[nftContractAddress][tokenId].nftSeller, "Only NFT seller");
        _;
    }

    modifier bidAmountMeetsRequirement(address nftContractAddress, uint tokenId, uint amount) {
        require(doesBidMeetsRequirement(nftContractAddress, tokenId, amount), "Not enough funds to bid");
        _;
    }

    modifier minimumBidNotMade(address nftContractAddress, uint tokenId) {
        require( !isMinimumBidMade(nftContractAddress, tokenId), "Auction has a valid bid");
        _;
    }

    modifier isAuctionOver(address nftContractAddress, uint tokenId) {
        require( !isAuctionOngoing(nftContractAddress, tokenId), "Auction is not over yet");
        _;
    }

    modifier notZeroAddress(address _address) {
        require(_address != address(0), "Cannot specify zero address");
        _;
    }
    /**
        MODIFIERS END
     */

    
    /**
        Contracts update functions
     */
    
    // function updateCitrusContract(address _citrus) external onlyOwner {
    //     citrus = ERC20(_citrus);
    // }

    function updateRoyaltyContract(address _royalty) external onlyOwner {
        royalty = ERC2981(_royalty);
    }
    /**
        Contracts update functions end
     */

    // Auction Check Function 
    function isAuctionOngoing(address nftContractAddress, uint tokenId) internal view returns(bool) {
        uint auctionEndTimestamp = nftContractAuctions[nftContractAddress][tokenId].auctionEndPeriod;
        return(auctionEndTimestamp == 0 || block.timestamp < auctionEndTimestamp);
    }

    // Check if a bid is made
    function isBidMade(address nftContractAddress, uint tokenId) internal view returns(bool) {
        return(nftContractAuctions[nftContractAddress][tokenId].nftHighestBid > 0);
    }

    // If minPrice is set by seller, check that the highest bid meets or exceeds that price
    function isMinimumBidMade(address nftContractAddress, uint tokenId) internal view returns(bool) {
        uint minPrice = nftContractAuctions[nftContractAddress][tokenId].minPrice;
        return minPrice > 0 && (nftContractAuctions[nftContractAddress][tokenId].nftHighestBid > minPrice);
    }

    // If buyNowPrice is set by seller, check if highest bid meets that price
    function isBuyNowPriceMet(address nftContractAddress, uint tokenId) internal view returns(bool) {
        uint buyNowPrice = nftContractAuctions[nftContractAddress][tokenId].buyNowPrice;
        return buyNowPrice > 0 && (nftContractAuctions[nftContractAddress][tokenId].nftHighestBid >= buyNowPrice);
    }

    // Get the percentage of the total bid for fees calculation
    function getPortionOfBid(uint totalBid, uint percentage) internal pure returns(uint) {
        return (totalBid * percentage) / 100;
    }

    /**
     * Check that a bid is applicable for the purchase of NFT
     * If sale is made, bid needs to meet buyNowPrice
     * 
     */
    function doesBidMeetsRequirement(address nftContractAddress, uint tokenId, uint amount) internal view returns(bool) {
        uint prevHighestBid = nftContractAuctions[nftContractAddress][tokenId].nftHighestBid;
        return amount > prevHighestBid;
    }

    // Get auction bid period of NFT
    function getAuctionBidPeriod(address nftContractAddress, uint tokenId) internal view returns(uint) {
        uint auctionBidPeriod = nftContractAuctions[nftContractAddress][tokenId].bidPeriod;

        if(auctionBidPeriod == 0) {
            return defaultBidPeriod;
        } 
        else{
            return auctionBidPeriod;
        }
    }

    /**
        AUCTIONS
     */
    // Transfer NFT to Auction Contract
    function transferNftToAuctionContract(address nftContractAddress, uint tokenId) internal {
        address nftSeller = nftContractAuctions[nftContractAddress][tokenId].nftSeller;

        if(IERC721(nftContractAddress).ownerOf(tokenId) == nftSeller) {
            IERC721(nftContractAddress).transferFrom(nftSeller, address(this), tokenId);
            require(IERC721(nftContractAddress).ownerOf(tokenId) == address(this), "NFT Transfer Failed");
        }
        else{
            require(IERC721(nftContractAddress).ownerOf(tokenId) == address(this), "Seller doesn't own NFT");
        }
    }

    // Setting up auction
    function setupAuction(address nftContractAddress, uint tokenId, uint _minPrice, uint _buyNowPrice, uint _tokenMinPrice, uint _tokenBuyNowPrice) internal minPriceDoesNotExceedLimit(_buyNowPrice, _minPrice) {
        Auction storage auctions = nftContractAuctions[nftContractAddress][tokenId];

        auctions.minPrice = _minPrice;
        auctions.buyNowPrice = _buyNowPrice;
        auctions.nftSeller = msg.sender;
        auctions.tokenMinPrice = _tokenMinPrice;
        auctions.tokenBuyNowPrice = _tokenBuyNowPrice;

        transferNftToAuctionContract(nftContractAddress, tokenId);
    }

    // Setting up new auction for NFT
    function setupNewNftAuction(address nftContractAddress, uint tokenId, uint _minPrice, uint _buyNowPrice, uint _tokenMinPrice, uint _tokenBuyNowPrice) internal {
        setupAuction(nftContractAddress, tokenId, _minPrice, _buyNowPrice, _tokenMinPrice, _tokenBuyNowPrice);
        emit NFTAuctionCreated(nftContractAddress, tokenId, msg.sender, _minPrice, _buyNowPrice, getAuctionBidPeriod(nftContractAddress, tokenId));
    }

    // Create default auction using default bid period time
    function createDefaultAuction(address nftContractAddress, uint tokenId, uint _minPrice, uint _buyNowPrice, uint _tokenMinPrice, uint _tokenBuyNowPrice) external isAuctionNotStartedByOwner(nftContractAddress, tokenId) priceGreaterThanZero(_minPrice) {
        Auction storage auctions = nftContractAuctions[nftContractAddress][tokenId];
        // uint endTime = auctions.auctionEndPeriod;

        
        setupNewNftAuction(
            nftContractAddress,
            tokenId,
            _minPrice,
            _buyNowPrice,
            _tokenMinPrice,
            _tokenBuyNowPrice
        );

        // increment total sale number
        nftOnSale++;
    }

    function createNewNftAuction(address nftContractAddress, uint tokenId, uint _minPrice, uint _buyNowPrice, uint bidPeriod, uint _tokenMinPrice, uint _tokenBuyNowPrice) external isAuctionNotStartedByOwner(nftContractAddress, tokenId) priceGreaterThanZero(_minPrice) {
        Auction storage auctions = nftContractAuctions[nftContractAddress][tokenId];

        auctions.bidPeriod = bidPeriod;
        setupNewNftAuction(
            nftContractAddress,
            tokenId,
            _minPrice,
            _buyNowPrice,
            _tokenMinPrice,
            _tokenBuyNowPrice
        );

        // increment total sale number
        nftOnSale++;
    }
    /**
        AUCTIONS END
    */

    /**
        SALES
    */
    function setupSale(address nftContractAddress, uint tokenId, uint _buyNowPrice, uint citrusPrice, uint saleTime) internal {
        Auction storage auctions = nftContractAuctions[nftContractAddress][tokenId];

        auctions.buyNowPrice = _buyNowPrice;
        auctions.nftSeller = msg.sender;
        auctions.tokenBuyNowPrice = citrusPrice;
        auctions.auctionEndPeriod = saleTime;

        IERC721(nftContractAddress).transferFrom(msg.sender, address(this), tokenId);
    }

    function createSale(address nftContractAddress, uint tokenId, uint _buyNowPrice, uint citrusPrice, uint saleTime) external isAuctionNotStartedByOwner(nftContractAddress, tokenId) priceGreaterThanZero(_buyNowPrice) {
        Auction storage auctions = nftContractAuctions[nftContractAddress][tokenId];
        uint endTime = auctions.auctionEndPeriod;

        setupSale(nftContractAddress,tokenId,_buyNowPrice, citrusPrice, saleTime);
        emit SaleCreated(nftContractAddress, tokenId, msg.sender, _buyNowPrice);

        // increment total sale number
        nftOnSale++;
    }

    function withdrawSale(address nftContractAddress, uint tokenId) external onlyNftSeller(nftContractAddress, tokenId) {
        Auction storage auctions = nftContractAuctions[nftContractAddress][tokenId];
        
        auctions.buyNowPrice = 0;
        auctions.nftSeller = address(0);
        auctions.tokenBuyNowPrice = 0;
        auctions.auctionEndPeriod = 0;

        IERC721(nftContractAddress).transferFrom(address(this), msg.sender, tokenId);

        emit SaleWithdrawn(nftContractAddress, tokenId, msg.sender);
    }

    function updateBuyNowPriceOfSale(address nftContractAddress, uint tokenId, uint _buyNowPrice) external onlyNftSeller(nftContractAddress, tokenId) {
        Auction storage auctions = nftContractAuctions[nftContractAddress][tokenId];

        require(block.timestamp < auctions.auctionEndPeriod, "Sale has ended");
        auctions.buyNowPrice = _buyNowPrice;
    }

    function buyNow(address nftContractAddress, uint tokenId) external payable notNftSeller(nftContractAddress, tokenId) returns(bool) {
        Auction storage auctions = nftContractAuctions[nftContractAddress][tokenId];
        uint buyNowPrice = auctions.buyNowPrice;
        address seller = auctions.nftSeller;
        auctions.nftHighestBidder = msg.sender;

        require(msg.value == buyNowPrice, "Price not met for instant sale");

        // Calculating commision
        uint comm = msg.value * 2/100;
        uint sellerPayout = msg.value - comm;

        // Checking royalties
        (address royaltyRecipient, uint royaltyAmount) = royalty.royaltyInfo(tokenId, msg.value);
        
        if(royaltyAmount != 0) {
            payable(royaltyRecipient).transfer(royaltyAmount);
            sellerPayout = sellerPayout - royaltyAmount;
        }

        // Reset buyNowPrice
        auctions.buyNowPrice = 0;

        // Transferring commission
        payable(commissionAddress).transfer(comm);

        IERC721(nftContractAddress).transferFrom(address(this), msg.sender, tokenId);

        // Sending funds to recipient
        (bool sent, ) = payable(seller).call{value: sellerPayout}("");
        
        // In case of failure
        if(!sent) {
            failedTransferCredits[seller] += sellerPayout;
        }
        
        // decrease total sale number
        nftOnSale--;

        return true;
    }

    function buyNowWithCitrus(address nftContractAddress, uint tokenId, uint tokenAmount, address tokenAddress) external notNftSeller(nftContractAddress, tokenId) returns(bool) {
        require(tokenAddress != address(0), "Invalid token Address");

        Auction storage auctions = nftContractAuctions[nftContractAddress][tokenId];
        uint buyNowPrice = auctions.tokenBuyNowPrice;
        auctions.nftHighestBidder = msg.sender;

        // Check that it is on sale
        require(buyNowPrice != 0, "Cannot buy with citrus");
        require(tokenAmount == buyNowPrice, "Price not met for instant sale");

        // Calculating commision
        uint comm = tokenAmount * 2/100;
        uint sellerPayout = tokenAmount - comm;

        // Checking royalties
        (address royaltyRecipient, uint royaltyAmount) = royalty.royaltyInfo(tokenId, tokenAmount);
        
        if(royaltyAmount != 0) {
            ERC20(tokenAddress).transferFrom(msg.sender, royaltyRecipient, royaltyAmount);
            sellerPayout = sellerPayout - royaltyAmount;
        }

        // Reset buyNowPrice
        auctions.buyNowPrice = 0;
        auctions.tokenBuyNowPrice = 0;

        // Transferring tokens
        ERC20(tokenAddress).transferFrom(msg.sender, auctions.nftSeller, sellerPayout);

        ERC20(tokenAddress).transferFrom(msg.sender, commissionAddress, comm);

        IERC721(nftContractAddress).transferFrom(address(this), msg.sender, tokenId);
        
        // decrease total sale number
        nftOnSale--;

        return true;
    }

    /**
        SALES END
     */

    /**
        BID FUNCTIONS
     */
    function _makeBid(address nftContractAddress, uint tokenId) internal notNftSeller(nftContractAddress, tokenId) bidAmountMeetsRequirement(nftContractAddress, tokenId, msg.value) {
        reversePreviousBidAndUpdateHighestBid(nftContractAddress, tokenId);
        emit BidMade(nftContractAddress, tokenId, msg.sender, msg.value);

        updateOngoingAuction(nftContractAddress, tokenId);
    }

    function _makeBidWithToken(address nftContractAddress, uint tokenId, address tokenAddress, uint tokenAmount) internal notNftSeller(nftContractAddress, tokenId) bidAmountMeetsRequirement(nftContractAddress, tokenId, tokenAmount) {
        reversePreviousBidAndUpdateHighestBidToken(nftContractAddress, tokenId, tokenAddress, tokenAmount);
    }

    function makeBid(address nftContractAddress, uint tokenId) external payable auctionOngoing(nftContractAddress, tokenId) {
        _makeBid(nftContractAddress, tokenId);
    }

    function makeBidWithToken(address nftContractAddress, uint tokenId, address tokenAddress, uint tokenAmount) external auctionOngoing(nftContractAddress, tokenId) {
        ERC20(tokenAddress).transferFrom(msg.sender, address(this), tokenAmount);
        _makeBidWithToken(nftContractAddress, tokenId, tokenAddress, tokenAmount);
    }

    /**
        BID FUNCTIONS END
     */

    /**
        UPDATE AUCTION
     */
    function updateOngoingAuction(address nftContractAddress, uint tokenId) internal {
        if( isBuyNowPriceMet(nftContractAddress, tokenId)){
            // transferNftToAuctionContract(nftContractAddress, tokenId);
            transferNftAndPaySeller(nftContractAddress, tokenId);
        }

        // minPrice not set
        // if( isMinimumBidMade(nftContractAddress, tokenId)){
        //     transferNftToAuctionContract(nftContractAddress, tokenId);
        //     updateAuctionEnd(nftContractAddress, tokenId);
        // }
    }

    function updateAuctionEnd(address nftContractAddress, uint tokenId) internal {
        // auction end should be now + bidEndPeriod
        uint auctionEndPeriod = nftContractAuctions[nftContractAddress][tokenId].auctionEndPeriod;
        auctionEndPeriod = getAuctionBidPeriod(nftContractAddress, tokenId) + block.timestamp;
        emit AuctionPeriodUpdated(nftContractAddress, tokenId, auctionEndPeriod);
    }
    /**
        UPDATE AUCTION END
     */

    /**
        RESET FUNCTIONS
     */
    // Reset all auction related parameters for an NFT
    // This removes an NFT as an item up for sale
    function  resetAuction(address nftContractAddress, uint tokenId) internal {
        Auction storage auctions = nftContractAuctions[nftContractAddress][tokenId];
        auctions.auctionEndPeriod = 0;
        auctions.bidPeriod = 0;
        auctions.buyNowPrice = 0;
        auctions.minPrice = 0;
        auctions.nftHighestBid = 0;
        auctions.tokenMinPrice = 0;
        auctions.tokenHighestBid = 0;
        auctions.tokenBuyNowPrice = 0;
        auctions.nftHighestBidder = address(0);
        auctions.nftSeller = address(0);
    }

    // This removes an NFT as having no active bids
    function resetBids(address nftContractAddress, uint tokenId) internal {
        Auction storage auctions = nftContractAuctions[nftContractAddress][tokenId];
        auctions.nftHighestBidder = address(0);
        auctions.nftHighestBid = 0;
    }
    /**
        RESET FUNCTIONS END
     */

    /**
        UPDATE BIDS
     */
    // Functions to reverse bids and update bid parameters
    // Ensures that contract only holds the highest bids
    function updateHighestBid(address nftContractAddress, uint tokenId) internal {
        nftContractAuctions[nftContractAddress][tokenId].nftHighestBid = msg.value;
        nftContractAuctions[nftContractAddress][tokenId].nftHighestBidder = msg.sender;
    }

    function updateHighestBidToken(address nftContractAddress, uint tokenId, uint tokenAmount) internal {
        nftContractAuctions[nftContractAddress][tokenId].nftHighestBid = tokenAmount;
        nftContractAuctions[nftContractAddress][tokenId].nftHighestBidder = msg.sender;   
    }

    function reverseAndResetPreviousBid(address nftContractAddress, uint tokenId) internal {
        address nftHighestBidder = nftContractAuctions[nftContractAddress][tokenId].nftHighestBidder;

        uint nftHighestBid = nftContractAuctions[nftContractAddress][tokenId].nftHighestBid;
        resetBids(nftContractAddress, tokenId);

        payout(nftHighestBidder, nftHighestBid);
    }

    function reversePreviousBidAndUpdateHighestBid(address nftContractAddress, uint tokenId) internal {
        address prevNftHighestBidder = nftContractAuctions[nftContractAddress][tokenId].nftHighestBidder;

        uint prevNftHighestBid = nftContractAuctions[nftContractAddress][tokenId].nftHighestBid;
        updateHighestBid(nftContractAddress, tokenId);

        if(prevNftHighestBidder != address(0)){
            payout(prevNftHighestBidder, prevNftHighestBid);
        }
    }

    function reversePreviousBidAndUpdateHighestBidToken(address nftContractAddress, uint tokenId, address tokenAddress, uint tokenAmount) internal {
        address prevNftHighestBidder = nftContractAuctions[nftContractAddress][tokenId].nftHighestBidder;

        uint prevNftHighestBid = nftContractAuctions[nftContractAddress][tokenId].tokenHighestBid;
        updateHighestBidToken(nftContractAddress, tokenId, tokenAmount);

        if(prevNftHighestBidder != address(0)) {
            tokenPayout(prevNftHighestBidder, tokenAddress, prevNftHighestBid);
        }
    }
    /**
        UPDATE BIDS
     */

    /** 
        TRANSFER NFT AND PAY SELLER
     */
    function transferNftAndPaySeller(address nftContractAddress, uint tokenId) internal {
        Auction storage auctions = nftContractAuctions[nftContractAddress][tokenId];
        address _nftSeller = auctions.nftSeller;
        address _highestBidder = auctions.nftHighestBidder;
        uint _highestBid = auctions.nftHighestBid;
        
        payFeesAndSeller(tokenId, _nftSeller, _highestBid);

        resetBids(nftContractAddress, tokenId);


        IERC721(nftContractAddress).transferFrom(address(this), _highestBidder, tokenId);

        resetAuction(nftContractAddress, tokenId);

        emit NFTTransferredAndSellerPaid(nftContractAddress, tokenId, _nftSeller, _highestBid, _highestBidder);
    }

    function transferNftAndPaySellerToken(address nftContractAddress, uint tokenId, address tokenAddress) internal {
        Auction storage auctions = nftContractAuctions[nftContractAddress][tokenId];
        address _nftSeller = auctions.nftSeller;
        address _highestBidder = auctions.nftHighestBidder;
        uint _highestBid = auctions.tokenHighestBid;
        
        payFeesAndSellerToken(tokenId, _nftSeller, _highestBid, tokenAddress);

        resetBids(nftContractAddress, tokenId);


        IERC721(nftContractAddress).transferFrom(address(this), _highestBidder, tokenId);

        resetAuction(nftContractAddress, tokenId);

        emit NFTTransferredAndSellerPaid(nftContractAddress, tokenId, _nftSeller, _highestBid, _highestBidder);
    }

    function payFeesAndSellerToken(uint tokenId, address _nftSeller, uint _highestBid, address tokenAddress) internal {
        // Marketplace fee calculation
        uint feesPaid;
        uint fee = (_highestBid * commission) / 100;
        feesPaid += fee;

        // Checking royalties
        (address royaltyRecipient, uint royaltyAmount) = royalty.royaltyInfo(tokenId, _highestBid);
        
        if(royaltyAmount != 0) {
            ERC20(tokenAddress).transfer(royaltyRecipient, royaltyAmount);
        }
        
        // Pay fees
        ERC20(tokenAddress).transfer(commissionAddress, feesPaid);
        // Pay seller
        tokenPayout(_nftSeller, tokenAddress, (_highestBid - (feesPaid + royaltyAmount)));
        payout(_nftSeller, (_highestBid - (feesPaid + royaltyAmount)));
    }


    // Pay fees, seller
    function payFeesAndSeller(uint tokenId, address _nftSeller, uint _highestBid) internal {
        // Marketplace fee calculation
        uint feesPaid;
        uint fee = (_highestBid * commission) / 100;
        feesPaid += fee;

        // Checking royalties
        (address royaltyRecipient, uint royaltyAmount) = royalty.royaltyInfo(tokenId, _highestBid);
        
        if(royaltyAmount != 0) {
            payable(royaltyRecipient).transfer(royaltyAmount);
        }
        
        // Pay fees
        payout(commissionAddress, feesPaid);
        // Pay seller
        payout(_nftSeller, (_highestBid - (feesPaid + royaltyAmount)));
    }

    function payout(address recipient, uint amount) internal {
        // Sending funds to recipient
        (bool sent, ) = payable(recipient).call{value: amount}("");
        
        // In case of failure
        if(!sent) {
            failedTransferCredits[recipient] += amount;
        }
    }

    function tokenPayout(address recipient, address tokenAddress, uint tokenAmount) internal {
        require(ERC20(tokenAddress).balanceOf(address(this)) >= tokenAmount, "Insufficient token on contract");
        ERC20(tokenAddress).transfer(recipient, tokenAmount);
    }
    /** 
        TRANSFER NFT AND PAY SELLER END
     */


    /**
        SETTLE AND WITHDRAW
     */
    function settleAuction(address nftContractAddress, uint tokenId) external onlyNftSeller(nftContractAddress, tokenId) isAuctionOver(nftContractAddress, tokenId) {
        transferNftAndPaySeller(nftContractAddress, tokenId);
        emit AuctionSettled(nftContractAddress, tokenId, msg.sender);

        // decrement total sale number
        nftOnSale--;
    }

    function settleAuctionToken(address nftContractAddress, uint tokenId, address tokenAddress) external onlyNftSeller(nftContractAddress, tokenId) isAuctionOver(nftContractAddress, tokenId) {
        transferNftAndPaySellerToken(nftContractAddress, tokenId, tokenAddress);
        emit AuctionSettled(nftContractAddress, tokenId, msg.sender);

        // decrement total sale number
        nftOnSale--;
    }

    function withdrawAuction(address nftContractAddress, uint tokenId) external onlyNftSeller(nftContractAddress, tokenId) {
        address seller = nftContractAuctions[nftContractAddress][tokenId].nftSeller;

        IERC721(nftContractAddress).transferFrom(address(this), seller, tokenId);
        resetAuction(nftContractAddress, tokenId);
        emit AuctionWithdrawn(nftContractAddress, tokenId, msg.sender);

        // decrement total sale number
        nftOnSale--;
    }

    function withdrawBid(address nftContractAddress, uint tokenId) external {
        address nftHighestBidder = nftContractAuctions[nftContractAddress][tokenId].nftHighestBidder;
        require(nftHighestBidder == msg.sender, "Cannot withdraw");

        uint highestBid = nftContractAuctions[nftContractAddress][tokenId].nftHighestBid;
        resetBids(nftContractAddress, tokenId);

        payout(nftHighestBidder, highestBid);
        emit BidWithdrawn(nftContractAddress, tokenId, nftHighestBidder);
    }

    function withdrawBidToken(address nftContractAddress, uint tokenId, address tokenAddress) external {
        address nftHighestBidder = nftContractAuctions[nftContractAddress][tokenId].nftHighestBidder;
        require(nftHighestBidder == msg.sender, "Cannot withdraw");

        uint highestBid = nftContractAuctions[nftContractAddress][tokenId].nftHighestBid;
        resetBids(nftContractAddress, tokenId);

        tokenPayout(nftHighestBidder, tokenAddress, highestBid);
        emit BidWithdrawn(nftContractAddress, tokenId, nftHighestBidder);
    }
    /**
        SETTLE AND WITHDRAW END
     */
    
    /**
        UPDATE AUCTION
     */
    function updateMinimumPrice(address nftContractAddress, uint tokenId, uint newMinPrice) 
        external
        onlyNftSeller(nftContractAddress, tokenId)
        minimumBidNotMade(nftContractAddress, tokenId)
        priceGreaterThanZero(newMinPrice)
        minPriceDoesNotExceedLimit(nftContractAuctions[nftContractAddress][tokenId].buyNowPrice, newMinPrice)
        {
        nftContractAuctions[nftContractAddress][tokenId].minPrice = newMinPrice;

        emit MinPriceUpdated(nftContractAddress, tokenId, newMinPrice);

        if(isMinimumBidMade(nftContractAddress, tokenId)){
            transferNftToAuctionContract(nftContractAddress, tokenId);
            updateAuctionEnd(nftContractAddress, tokenId);
        }
    }

    function updateBuyNowPrice(address nftContractAddress, uint tokenId, uint newBuyNowPrice)
        external
        onlyNftSeller(nftContractAddress, tokenId)
        priceGreaterThanZero(newBuyNowPrice)
        minPriceDoesNotExceedLimit(newBuyNowPrice, nftContractAuctions[nftContractAddress][tokenId].minPrice)
        {
        nftContractAuctions[nftContractAddress][tokenId].buyNowPrice = newBuyNowPrice;

        emit BuyNowPriceUpdated(nftContractAddress, tokenId, newBuyNowPrice);

        if(isBuyNowPriceMet(nftContractAddress, tokenId)){
            transferNftToAuctionContract(nftContractAddress, tokenId);
            transferNftAndPaySeller(nftContractAddress, tokenId);
        }
    }

    // NFT seller can end the auction by accepting the current highest bid
    function takeHighestBid(address nftContractAddress, uint tokenId) external onlyNftSeller(nftContractAddress, tokenId) {
        require(isBidMade(nftContractAddress, tokenId), "Cannot payout 0 bid");
        transferNftToAuctionContract(nftContractAddress, tokenId);
        transferNftAndPaySeller(nftContractAddress, tokenId);

        // decrement total sale number
        nftOnSale--;

        emit HighestBidTaken(nftContractAddress, tokenId);
    }

    function takeHighestBidToken(address nftContractAddress, uint tokenId, address tokenAddress) external onlyNftSeller(nftContractAddress, tokenId) {
        require(isBidMade(nftContractAddress, tokenId), "Cannot payout 0 bid");
        transferNftToAuctionContract(nftContractAddress, tokenId);
        transferNftAndPaySellerToken(nftContractAddress, tokenId, tokenAddress);

        // decrement total sale number
        nftOnSale--;

        emit HighestBidTaken(nftContractAddress, tokenId);
    }

    // Query the owner of NFT deposited for auction
    function ownerOfNft(address nftContractAddress, uint tokenId) external view returns(address) {
        address nftSeller = nftContractAuctions[nftContractAddress][tokenId].nftSeller;
        require(nftSeller != address(0), "NFT not deposited");
        
        return nftSeller;
    }

    // This allows user to claim their bid amount, if the transfer of a bid has failed
    function withdrawFailedCredits() external {
        uint amount = failedTransferCredits[msg.sender];

        require(amount != 0, "No credits to withdraw");

        failedTransferCredits[msg.sender] = 0;

        (bool successfulWithdraw, ) = payable(msg.sender).call{value: amount}("");
        require(successfulWithdraw, "Withdraw failed");
    }
    /**
        UPDATE AUCTION END
     */
}