// SPDX-License-Identifier: ISC
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract Marketplace is Ownable {
    // Structures
    struct SellOrder {
        uint basePrice; // if 0, auction is disabled
        uint start;
        uint end;
        uint directSalePrice; // if 0, direct sale is disabled
        address paymentToken;
        bool claimed;
    }

    struct Bid {
        address bidder;
        uint price;
        uint timestamp;
    }

    // Events
    event NewSellOrder(uint indexed tokenId, uint indexed basePrice, address indexed paymentToken);
    event SellOrderChanged(uint indexed tokenId, uint indexed basePrice, address indexed paymentToken);
    event NewBid(address indexed who, uint indexed tokenId, uint indexed price);

    // Maps
    // address(0) represents the native token (BNB)
    mapping (address => bool) public isPaymentTokenWhitelisted; // token address => is whitelisted
    mapping (uint => SellOrder) public sellOrders; // token id => sell order
    mapping (uint => Bid[]) public bids; // token id => bids
    mapping (address => uint) public totalValueSold; // payment token => total value sold

    // NFT collection that will be sold
    IERC721 public nft;

    // if true, add one minute to the end of a sell if the bid is placed one minute or less before its end
    bool public shouldExtendEnd;

    // If true, if a bid price exceeds the direct sale price, it automatically buys the item insted of keep bidding.
    // Otherwise it disables the direct sale
    bool public shouldStopBidding;

    // address that will receive unsold items
    address public recoverAddress;

    // minimum change in price from the previous bid
    uint public minPriceIncrease;

    // Array with all whitelisted payment tokens
    address[] private whitelistedPaymentTokens;

    // fees denominator
    uint public feePrecision = 1e5;

    // addresses that will receive part of the generated tokens throgh sales
    address[] private withdrawAddresses;
    uint public withdrawAddressesCounter;

    /**
     * @notice Constructor
     * @param _nft Address of COC NFT
     * @param _recoverAddress Address that will receive unsold NFTs
     * @param _minBidPriceIncrease Minimum price increase from previous bid
     * @param _shouldExtendEnd If true, enable sale extension in case of a bid race
     * @param _shouldStopBidding If true, if a bid price exceeds the direct sale price,
            it automatically buys the item instead of keep bidding. Otherwise it disables
            the direct sale
     */
    constructor (address _nft, address _recoverAddress, uint _minBidPriceIncrease, bool _shouldExtendEnd,
        bool _shouldStopBidding) {
        nft = IERC721(_nft);

        require(_minBidPriceIncrease > 0, "Marketplace: min bid price must be greater than 0");

        recoverAddress = _recoverAddress;
        minPriceIncrease = _minBidPriceIncrease;
        shouldExtendEnd = _shouldExtendEnd;
        shouldStopBidding = _shouldStopBidding;

        // Whitelist BNB
        isPaymentTokenWhitelisted[address(0)] = true;
    }

    /**
     * @notice Buy a NFT directly
     * @param _tokenId Token ID of the item to buy
     */
    function buy(uint _tokenId) external payable {
        require (nft.ownerOf(_tokenId) == address(this), "Marketplace: item not in sale");

        SellOrder storage sellOrder = sellOrders[_tokenId];

        // Check if auction is enabled
        require (sellOrder.directSalePrice > 0 && ! sellOrder.claimed, "Marketplace: buy directly disabled");

        // Takes funds from the caller
        processPaymentFrom(sellOrder.paymentToken, msg.sender, sellOrder.directSalePrice);

        // Transfer the NFT
        nft.transferFrom(address(this), msg.sender, _tokenId);

        // Close the sale
        sellOrder.claimed = true;

        // Update statistics
        totalValueSold[sellOrder.paymentToken] += sellOrder.directSalePrice;
    }

    /**
     * @notice Make a bid
     * @param _tokenId Token ID of the item
     * @param _price Price of the bid
     */
    function bid(uint _tokenId, uint _price) external payable {
        require (nft.ownerOf(_tokenId) == address(this), "Marketplace: item not in sale");

        SellOrder storage sellOrder = sellOrders[_tokenId];

        // Check if auction is enabled
        require (sellOrder.basePrice > 0 && ! sellOrder.claimed, "Marketplace: auction disabled");

        // Check time constraints
        require (block.timestamp >= sellOrder.start, "Marketplace: auction not started yet");
        require (block.timestamp <= sellOrder.end, "Marketplace: auction already finished");

        // If there is at least one bid, check that the price is greater
        uint bidsLength = bids[_tokenId].length;
        if (bidsLength > 0) {
            Bid memory lastBid = bids[_tokenId][bidsLength - 1];
            require (_price >= lastBid.price + minPriceIncrease, "Marketplace: price too low");

            // Refund previous bidder
            processPaymentTo(sellOrder.paymentToken, lastBid.bidder, lastBid.price);
        } else {
            require (_price >= sellOrder.basePrice, "Marketplace: price below base price");
        }

        // Takes funds from the new one
        processPaymentFrom(sellOrder.paymentToken, msg.sender, _price);

        // Add the new bid
        Bid memory newBid = Bid({
            bidder: msg.sender,
            price: _price,
            timestamp: block.timestamp
        });

        bids[_tokenId].push(newBid);

        // Check if the price is greater than direct sale price
        if (_price >= sellOrder.directSalePrice && sellOrder.directSalePrice != 0) {
            // Buys the item
            if (shouldStopBidding) {
                // Transfer the NFT
                nft.transferFrom(address(this), msg.sender, _tokenId);

                // TODO: Apply marketplace fee

                // Close the sale
                sellOrder.claimed = true;

                // Update statistics
                totalValueSold[sellOrder.paymentToken] += _price;
            }

            // Disable direct sale
            else {
                sellOrder.directSalePrice = 0;
            }
        }

        // If expected, add one minute to the sellOrder.end if the bid is placed one minute or less before sellOrder.end
        uint secondsBeforeEnd = sellOrder.end - block.timestamp;
        if (secondsBeforeEnd <= 60 && shouldExtendEnd) {
            sellOrder.end += 60;
        }

        emit NewBid(msg.sender, _tokenId, _price);
    }

    /**
     * @notice Claim an item when the sale ends
     * @param _tokenId Token ID to claim
     */
    function claim(uint _tokenId) external {
        SellOrder storage sellOrder = sellOrders[_tokenId];
        require (! sellOrder.claimed, "Marketplace: token already claimed");
        require (block.timestamp > sellOrder.end, "Marketplace: sell not ended");

        uint bidsLength = bids[_tokenId].length;
        Bid memory lastBid = bids[_tokenId][bidsLength - 1];

        // Check if the caller can claim the NFT
        require (lastBid.bidder == msg.sender, "Marketplace: not last bidder");

        // Transfer the NFT
        nft.transferFrom(address(this), msg.sender, _tokenId);

        // TODO: Apply marketplace fee

        // Update the sell order
        sellOrder.claimed = true;

        // Update statistics
        totalValueSold[sellOrder.paymentToken] += lastBid.price;
    }

    /**
     * @notice Returns all the bids of a token
     * @param _tokenId Token ID of the item
     */
    function getBids(uint _tokenId) external view returns (Bid[] memory) {
        return bids[_tokenId];
    }

    /**
     * @notice Returns all whitelisted payment tokens
     */
    function getWhitelistedPaymentTokens() external view returns (address[] memory) {
        return whitelistedPaymentTokens;
    }

    /**
     * @notice Returns all the address that will receive part of the revenues
     */
    function getWithdrawAddresses() external view returns (address[] memory) {
        return withdrawAddresses;
    }

    // PRIVILEGED FUNCTIONS

    /**
     * @notice Sell an item
     * @param _tokenId Token ID of the item
     * @param _basePrice Base price for the token
     * @param _directSalePrice Price in case of direct sale. If 0, direct sale is disabled
     * @param _paymentToken Payment token that will be used for this sale. Native BNB is represented by address(0)
     * @param _start Start of the sale
     * @param _end End of the sale
     */
    function sell(uint _tokenId, uint _basePrice, uint _directSalePrice, address _paymentToken, uint _start, uint _end) public onlyOwner {
        require (isPaymentTokenWhitelisted[_paymentToken], "Marketplace: invalid payment token");
        require (nft.ownerOf(_tokenId) == msg.sender, "Marketplace: not NFT owner");
        require (block.timestamp < _start, "Marketplace: invalid start");
        require (_start < _end, "Marketplace: invalid timestamps");
        require(_basePrice > 0 || _directSalePrice > 0, "Marketplace: at least one of _basePrice or _directSalePrice must be set");
        require(_directSalePrice == 0 || _basePrice < _directSalePrice , "Marketplace: _directSalePrice must be greater than _basePrice");

        // Takes the NFT from the owner
        nft.transferFrom(msg.sender, address(this), _tokenId);

        SellOrder storage sellOrder = sellOrders[_tokenId];
        sellOrder.basePrice = _basePrice;
        sellOrder.start = _start;
        sellOrder.end = _end;
        sellOrder.directSalePrice = _directSalePrice;
        sellOrder.paymentToken = _paymentToken;
        sellOrder.claimed = false;

        emit NewSellOrder(_tokenId, _basePrice, _paymentToken);
    }

    /**
     * @notice Change a sell order
     * @param _tokenId Token ID of the item
     * @param _basePrice Base price for the token
     * @param _directSalePrice Price in case of direct sale. If 0, direct sale is disabled
     * @param _paymentToken Payment token that will be used for this sale. Native BNB is represented by address(0)
     * @param _start Start of the sale
     * @param _end End of the sale
     */
    function changeSellOrder(uint _tokenId, uint _basePrice, uint _directSalePrice, address _paymentToken, uint _start, uint _end) external onlyOwner {
        SellOrder storage sellOrder = sellOrders[_tokenId];

        require (! sellOrder.claimed, "Marketplace: item already claimed");
        require (isPaymentTokenWhitelisted[_paymentToken], "Marketplace: invalid payment token");
        require (block.timestamp < _start && block.timestamp < sellOrder.start, "Marketplace: invalid start");
        require (_start < _end, "Marketplace: invalid timestamps");

        sellOrder.basePrice = _basePrice;
        sellOrder.start = _start;
        sellOrder.end = _end;
        sellOrder.directSalePrice = _directSalePrice;
        sellOrder.paymentToken = _paymentToken;

        emit SellOrderChanged(_tokenId, _basePrice, _paymentToken);
    }

    /**
     * @notice Sell multiple items
     * @param _tokenIds Token ID of the items
     * @param _basePrices Base prices for each token
     * @param _paymentTokens Payment token that will be used for each sale. Native BNB is represented by address(0)
     * @param _starts Start of each sale
     * @param _ends End of each sale
     */
    function sellBatch(uint[] memory _tokenIds, uint[] memory _basePrices, uint[] memory _directSalePrices,
        address[] memory _paymentTokens, uint[] memory _starts, uint[] memory _ends) external onlyOwner {

        // Check array lengths
        require (_tokenIds.length == _basePrices.length && _basePrices.length == _paymentTokens.length && _paymentTokens.length == _directSalePrices.length
            && _directSalePrices.length == _starts.length && _starts.length == _ends.length, "Marketplace: inconsistent array lengths");

        for (uint i = 0; i < _tokenIds.length; i++) {
            sell(_tokenIds[i], _basePrices[i], _directSalePrices[i], _paymentTokens[i], _starts[i], _ends[i]);
        }
    }

    /**
     * @notice Recover unsold items
     */
    function recover(uint _tokenId) external onlyOwner {
        SellOrder storage sellOrder = sellOrders[_tokenId];
        require (block.timestamp > sellOrder.end, "Marketplace: sell not ended");
        require (bids[_tokenId].length == 0, "Marketplace: item has bids");
        require (nft.ownerOf(_tokenId) == address(this), "Marketplace: token already recover");

        // Transfer the NFT
        nft.transferFrom(address(this), recoverAddress, _tokenId);
    }

    /**
     * @notice Add a new address to the withdraw list. From now on this address will
            receive part of the generated revenues
     * @param _address Address to add
     */
    function addAddressToWithdrawList(address _address) external onlyOwner {
        require (_address != address(0), "Marketplace: invalid address");

        bool filled = false;
        for (uint i = 0; i < withdrawAddresses.length && !filled; i++) {
            if (withdrawAddresses[i] == address(0)) {
                withdrawAddresses[i] = _address;
                filled = true;
            }
        }

        if (!filled) {
            withdrawAddresses.push(_address);
        }

        withdrawAddressesCounter += 1;
    }

    /**
     * @notice Add a new address to the withdraw list. From now on this address will
            receive part of the generated revenues
     * @param _index Index of the address to remove
     */
    function removeAddressFromWithdrawList(uint _index) external onlyOwner {
        require (_index < withdrawAddresses.length, "Marketplace: invalid index");

        uint lastIndex = withdrawAddresses.length - 1;

        withdrawAddresses[_index] = withdrawAddresses[lastIndex];
        delete withdrawAddresses[lastIndex];

        withdrawAddressesCounter -= 1;
    }

    /**
     * @notice Withdraw payment tokens received
     */
    function withdraw(address _paymentToken) external onlyOwner {
        uint balance;
        if (_paymentToken == address(0)) {
            balance = address(this).balance;
        } else {
            balance = IERC20(_paymentToken).balanceOf(address(this));
        }

        uint amount = balance / withdrawAddressesCounter;
        for (uint i = 0; i < withdrawAddresses.length; i++) {
            if ( withdrawAddresses[i] != address(0)) {
                processPaymentTo(_paymentToken, withdrawAddresses[i], amount);
            }
        }
    }

    /**
     * @notice Set if a payment token is whitelisted or not
     * @param _token Address of the payment token
     */
    function whitelistPaymentToken(address _token) external onlyOwner {
        require (! isPaymentTokenWhitelisted[_token], "Marketplace: token already whitelisted");

        isPaymentTokenWhitelisted[_token] = true;
        whitelistedPaymentTokens.push(_token);
    }

    // INTERNAL FUNCTIONS
    // Takes funds from the bidder based on the payment token
    function processPaymentFrom(address _token, address _from, uint _amount) internal {
        // BNB
        if (_token == address(0)) {
            require (msg.value >= _amount, "Marketplace: not enough funds");
        }

        // Other tokens
        else {
            IERC20(_token).transferFrom(_from, address(this), _amount);
        }
    }

    // Refund a bidder if it gets outbidded
    function processPaymentTo(address _token, address _to, uint _amount) internal {
        // BNB
        if (_token == address(0)) {
            payable(_to).transfer(_amount);
        }

        // Other tokens
        else {
            IERC20(_token).transfer(_to, _amount);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.0;

import "../../interfaces/IERC2981.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the
 * fee is specified in basis points by default.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view virtual override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `tokenId` must be already minted.
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
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
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}