/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

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
    event Transfer(address indexed from, address indexed to, uint indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint tokenId) external view returns (address owner);

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
    function safeTransferFrom(address from, address to, uint tokenId) external;

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
    function transferFrom(address from, address to, uint tokenId) external;

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
    function approve(address to, uint tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint tokenId) external view returns (address operator);

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
    function safeTransferFrom(address from, address to, uint tokenId, bytes calldata data) external;
}

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
    function onERC721Received(address operator, address from, uint tokenId, bytes calldata data) external returns (bytes4);
}

interface IEpicHeroNFT is IERC721{
    function getHero(uint tokenId) external view returns (uint8 level, uint8 rarity);
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
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
     * by making the `nonReentrant` function external, and make it call a
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

abstract contract Auth {
    address owner;
    mapping (address => bool) private authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender)); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender)); _;
    }

    function authorize(address adr) public authorized {
        authorizations[adr] = true;
        emit Authorized(adr);
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
        emit Unauthorized(adr);
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
    event Authorized(address adr);
    event Unauthorized(address adr);
}

contract OfferSystemV2 is IERC721Receiver, Auth , ReentrancyGuard{
    using SafeMath for uint256;

    mapping(uint24 => mapping(address => uint256)) public tokensWithOffers;

    mapping(uint8 => uint256) public minPriceAtRarity;
    uint8 public minRarity = 1;

    uint public tradeFee = 500;
    uint public wbnbReflectRewardsFee = 500;

    address public wbnbReflectToken = 0xCE1b3e5087e8215876aF976032382dd338cF8401;
    address public wbnbReflectTracker = 0x4a1278683ca36d9A789e3516eCCe7E08d90906E2;

    address public feeWallet = 0xb7497Bb4dEC6b4Be62f77dBdEb90F4E179d8fcFe;
    address public tokenAddress = 0xCE1b3e5087e8215876aF976032382dd338cF8401;
    address public nftAddress = 0xDD581CAb6F7643AB11498a4B83a8bcDA9EACa29A;

    IERC20 private token;
    IEpicHeroNFT private nftContract;

    bool public isClosed = false;

    constructor() Auth(msg.sender) {
        token = IERC20(tokenAddress);
        nftContract = IEpicHeroNFT(nftAddress);

        setMinPriceAtRarity(0, 0);
        setMinPriceAtRarity(1, 1 * 10 ** 18);
        setMinPriceAtRarity(2, 2 * 10 ** 18);
        setMinPriceAtRarity(3, 3 * 10 ** 18);
        setMinPriceAtRarity(4, 4 * 10 ** 18);
        setMinPriceAtRarity(5, 5 * 10 ** 18);
        setMinPriceAtRarity(6, 6 * 10 ** 18);
        setMinPriceAtRarity(7, 7 * 10 ** 18);
    }

    function _commitTrade(address seller, uint256 price) internal {
        uint totalFee = (price * (tradeFee + wbnbReflectRewardsFee)) / 10000;

        require(token.transfer(seller, price - totalFee), "Token transfer failed.");

        if (tradeFee + wbnbReflectRewardsFee > 0) {
            uint tokenFee = (totalFee * tradeFee) / (tradeFee + wbnbReflectRewardsFee);

            if (tokenFee > 0) {
                require(token.transfer(feeWallet, tokenFee), "Fee transfer failed.");
            }

            uint rewardFee = totalFee - tokenFee;

            if (rewardFee > 0) {
                _sendWbnbReflects(rewardFee);
            }
        }
    }

    function openOffer(uint24 tokenId, uint256 offerValue) external nonReentrant {
        (, uint8 rarity) = nftContract.getHero(tokenId);
        uint256 minPrice = minPriceAtRarity[rarity];

        require(!isClosed, "Market closed");
        require(rarity >= minRarity, "!minRarity");
        require(offerValue >= minPrice,"!minPrice");

        address buyer = msg.sender;
        address seller = nftContract.ownerOf(tokenId);

        uint currentOffer = tokensWithOffers[tokenId][buyer];
        bool needRefund = offerValue < currentOffer;
        uint requiredValue = needRefund ? 0 : offerValue - currentOffer;

        require(buyer != seller, "Owner cannot offer");
        require(offerValue != currentOffer, "Same offer");

        if(requiredValue > 0){
            require(token.transferFrom(buyer, address(this), requiredValue), "Offer transfer failed.");
        }

        if (needRefund) {
            uint returnedValue = currentOffer - offerValue;

            require(token.transfer(buyer, returnedValue), "Return transfer failed.");
        }

        tokensWithOffers[tokenId][buyer] = offerValue;

        emit OfferOpened(tokenId, seller, buyer, offerValue);
    }

    function takeOffer(uint24 tokenId, address buyer, uint256 minValue) external nonReentrant {
        require(nftContract.ownerOf(tokenId) == msg.sender, "!Owner");

        uint256 offeredValue = tokensWithOffers[tokenId][buyer];
        address seller = msg.sender;

        require(!isClosed, "Market closed");
        require(buyer != seller, "Cannot buy your own Hero");
        require(offeredValue >= minValue, "Less than minValue");

        tokensWithOffers[tokenId][buyer] = 0;

        _commitTrade(seller, offeredValue);

        nftContract.safeTransferFrom(seller, buyer, tokenId);

        emit OfferTaken(tokenId, seller, buyer, offeredValue);
    }

    function cancelOffer(uint24 tokenId) external nonReentrant {
        address sender = msg.sender;
        uint offerValue = tokensWithOffers[tokenId][sender];

        require(offerValue > 0, "No offer found");

        tokensWithOffers[tokenId][sender] = 0;

        require(token.transfer(sender, offerValue), "Return transfer failed.");

        emit OfferCanceled(tokenId, sender);
    }

    function setTradeFee(uint newFee) public onlyOwner {
        require(newFee < 10000, "Invalid newFee");
        tradeFee = newFee;
    }

    function setMinRarity(uint8 rarity) public onlyOwner {
        minRarity = rarity;
    }

    function setMinPriceAtRarity(uint8 rarity, uint256 minPrice) public onlyOwner{
        minPriceAtRarity[ rarity ] = minPrice;
    }

    function setWbnbReflectToken(address _newContract) public onlyOwner {
        wbnbReflectToken = _newContract;
    }

    function setWbnbReflectTracker(address _newContract) public onlyOwner {
        wbnbReflectTracker = _newContract;
    }

    function setWbnbReflectRewardsFee(uint256 newFee) external onlyOwner {
        require(newFee < 10000, "Invalid newFee");
        wbnbReflectRewardsFee = newFee;
    }

    function setFeeWallet(address newAddress) external onlyOwner {
        feeWallet = newAddress;
    }

    function setTokenAddress(address newAddress) external onlyOwner {
        tokenAddress = newAddress;
        token = IERC20(tokenAddress);
    }
    
    function setCloseMarket(bool value) external onlyOwner {
        require(value != isClosed, "Same");
        isClosed = value;
    }

    function retrieveTokens(address _token, uint amount) external onlyOwner {
        uint balance = IERC20(_token).balanceOf(address(this));

        if(amount > balance){
            amount = balance;
        }

        require(IERC20(_token).transfer(msg.sender, amount), "Transfer failed");
    }

    function retrieveBNB(uint amount) external onlyOwner{
        uint balance = address(this).balance;

        if(amount > balance){
            amount = balance;
        }

        (bool success,) = payable(msg.sender).call{ value: amount }("");
        require(success, "Failed");
    }

    function onERC721Received(address, address, uint, bytes calldata) public pure override returns (bytes4) {
        return 0x150b7a02;
    }

    function _sendWbnbReflects(uint256 tokens) private {
        IERC20(wbnbReflectToken).transfer(address(wbnbReflectTracker), tokens);
        emit SendWbnbDividends(tokens);
    }

    event OfferOpened(uint indexed tokenId, address seller, address buyer, uint price);
    event OfferTaken(uint indexed tokenId, address seller, address buyer, uint price);
    event OfferCanceled(uint indexed tokenId, address sender);
    event SendWbnbDividends(uint256 amount);
}