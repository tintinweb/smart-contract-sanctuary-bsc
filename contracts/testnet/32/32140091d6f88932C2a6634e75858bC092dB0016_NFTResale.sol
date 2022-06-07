// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
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

    function mint(address _to, uint256 _amount, string memory _uri) external;

    function tokensOwned(address holder) external returns (uint256[] memory);

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

    function contractSafeTransferFrom(
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
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

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
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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

contract NFTResale is Ownable, ReentrancyGuard {
    address marketplaceContract;
    address public platformLazyNFT;
    bool runInitialize;
    event SaleCreated(
        uint indexed tokenID,
        address nftContract,
        address seller,
        uint256 buyNowPrice
    );

    mapping(address => mapping(uint256 => Sale)) public nftContractSale;
    mapping(address => mapping(uint256 => Royalty)) public nftRoyalty;
    mapping(address => mapping(uint256 => Proposal)) public buyProposal;

    struct Sale {
        address nftSeller;
        address ERC20Token;
        uint32 ownerPercentage;
        uint32 platformPercentage;
        uint256 buyNowPrice;
    }

    struct Royalty {
        address royaltyOwner;
        uint256 royaltyPercentage;
        bool activated;
    }

    struct Proposal {
        address buyer;
        uint256 price;
    }

    modifier priceGreaterThanZero(uint256 _price) {
        require(_price > 0, "Price cannot be 0");
        _;
    }
    
    // One time set NFT token contract
    function initialize(
        address _platformLazyNFT
    ) public onlyOwner {
        require(runInitialize == false, "NFT contract already set");
        platformLazyNFT = _platformLazyNFT;
        runInitialize = true;
    }

    function _isERC20Auction(address _auctionERC20Token)
        internal
        pure
        returns (bool)
    {
        return _auctionERC20Token != address(0);
    }
    /*
     * NFTs in a batch must contain between 2 and 100 NFTs
     */
    modifier batchWithinLimits(uint256 _batchTokenIdsLength) {
        require(
            _batchTokenIdsLength > 1 && _batchTokenIdsLength <= 10000,
            "Number of NFTs not applicable"
        );
        _;
    }

    modifier onlyMarketplace(){
        require(msg.sender == marketplaceContract, "Only Marketplace function");
        _;
    }

    function setPlatformLazy(address _platformLazyNFT) public onlyOwner{
        platformLazyNFT= _platformLazyNFT;
    }

    function setRoyaltyData(
        uint256 _tokenId,
        uint256 _royaltyPercentage,
        address _royaltyOwner
    ) external {
        require(msg.sender == platformLazyNFT, "Only run on redeem");
        Royalty storage _royalty = nftRoyalty[platformLazyNFT][_tokenId];
        _royalty.royaltyOwner = _royaltyOwner;
        _royalty.royaltyPercentage = _royaltyPercentage;
        _royalty.activated = true;
    }

    function setRoyaltyDataMarketplace(
        uint256 _tokenId,
        uint256 _royaltyPercentage,
        address _royaltyOwner
    ) external onlyMarketplace{
        Royalty storage _royalty = nftRoyalty[platformLazyNFT][_tokenId];
        _royalty.royaltyOwner = _royaltyOwner;
        _royalty.royaltyPercentage = _royaltyPercentage;
        _royalty.activated = true;
    }

    function setRoyaltyDataByOwner(
        uint256[] memory _tokenId,
        uint256[] memory _royaltyPercentage,
        address[] memory _royaltyOwner
    ) public onlyOwner{
        require(_tokenId.length == _royaltyPercentage.length);
        uint256 length= _tokenId.length;
        for(uint256 i= 0; i<length; i++){
            Royalty storage _royalty = nftRoyalty[platformLazyNFT][_tokenId[i]];
            _royalty.royaltyOwner = _royaltyOwner[i];
            _royalty.royaltyPercentage = _royaltyPercentage[i];
            _royalty.activated = true;
        }
    }

    function _setupSale(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint32 _ownerPercentage,
        uint32 _platformPercentage,
        uint256 _buyNowPrice,
        uint32 _royaltyPercentage
    ) internal {
        if (_erc20Token != address(0)) {
            nftContractSale[_nftContractAddress][_tokenId]
                .ERC20Token = _erc20Token;
        }
        nftContractSale[_nftContractAddress][_tokenId]
            .buyNowPrice = _buyNowPrice;
        nftContractSale[_nftContractAddress][_tokenId].nftSeller = msg.sender;
        nftContractSale[_nftContractAddress][_tokenId]
            .ownerPercentage = _ownerPercentage;
        nftContractSale[_nftContractAddress][_tokenId]
            .platformPercentage = _platformPercentage;

        if (
            nftRoyalty[_nftContractAddress][_tokenId].royaltyOwner == address(0)
        ) {
            nftRoyalty[_nftContractAddress][_tokenId].royaltyOwner = msg.sender;
            nftRoyalty[_nftContractAddress][_tokenId]
                .royaltyPercentage = _royaltyPercentage;
        }
    }

    function createResale(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint32 _ownerPercentage,
        uint32 _platformPercentage,
        uint256 _buyNowPrice,
        uint32 _royaltyPercentage
    ) external priceGreaterThanZero(_buyNowPrice) {
        // If it's our own platform NFT
        if (
            _nftContractAddress == platformLazyNFT
        ) {
            IERC721(_nftContractAddress).contractSafeTransferFrom(
                msg.sender,
                address(this),
                _tokenId
            );
            _setupSale(
                _nftContractAddress,
                _tokenId,
                _erc20Token,
                _ownerPercentage,
                _platformPercentage,
                _buyNowPrice,
                _royaltyPercentage
            );
            emit SaleCreated(_tokenId, _nftContractAddress, msg.sender, _buyNowPrice);
        }
        // if it's not our own platform NFT
        else {
            IERC721(_nftContractAddress).safeTransferFrom(
                msg.sender,
                address(this),
                _tokenId
            );
            _setupSale(
                _nftContractAddress,
                _tokenId,
                _erc20Token,
                _ownerPercentage,
                _platformPercentage,
                _buyNowPrice,
                _royaltyPercentage
            );
            emit SaleCreated(_tokenId, _nftContractAddress, msg.sender, _buyNowPrice);
        }
    }

    function createBatchResale(
        address _nftContractAddress,
        address _erc20Token,
        uint256[] memory _tokenId,
        uint256[] memory _buyNowPrice,
        uint32 _ownerPercentage,
        uint32 _platformPercentage,
        uint32 _royaltyPercentage
    ) external batchWithinLimits(_tokenId.length) {
        require(_tokenId.length == _buyNowPrice.length);
        for (uint i = 0; i < _tokenId.length; i++) {
            IERC721(_nftContractAddress).contractSafeTransferFrom(
                msg.sender,
                address(this),
                _tokenId[i]
            );
            _setupSale(
                _nftContractAddress,
                _tokenId[i],
                _erc20Token,
                _ownerPercentage,
                _platformPercentage,
                _buyNowPrice[i],
                _royaltyPercentage
            );
        }
    }

    function buyNFT(address _nftContractAddress, uint256 _tokenId)
        public
        payable
        nonReentrant
    {
        address seller = nftContractSale[_nftContractAddress][_tokenId]
            .nftSeller;
        require(msg.sender != seller, "Seller cannot buy own NFT");
        uint256 buyNowPrice = nftContractSale[_nftContractAddress][_tokenId]
            .buyNowPrice;
        uint32 platformPercentage = nftContractSale[_nftContractAddress][
            _tokenId
        ].platformPercentage;
        uint256 platformFees = (buyNowPrice * (platformPercentage)) / (10000);
        uint256 totalPayable = buyNowPrice + platformFees;

        if (nftRoyalty[_nftContractAddress][_tokenId].activated) {
            uint _royaltyPercentage = nftRoyalty[_nftContractAddress][_tokenId]
                .royaltyPercentage;
            uint royaltyAmount = (buyNowPrice * (_royaltyPercentage)) / (10000);
            totalPayable += royaltyAmount;
        }
        address erc20Token = nftContractSale[_nftContractAddress][_tokenId]
            .ERC20Token;
        if (_isERC20Auction(erc20Token)) {
            require(
                IERC20(erc20Token).balanceOf(msg.sender) >= totalPayable,
                "Must be greater than NFT cost"
            );
        } else {
            require(msg.value >= totalPayable, "Must be greater than NFT cost");
        }
        _buyNFT(_nftContractAddress, _tokenId);
    }

    function _buyNFT(address _nftContractAddress, uint256 _tokenId) internal {
        address seller = nftContractSale[_nftContractAddress][_tokenId]
            .nftSeller;
        address erc20Token = nftContractSale[_nftContractAddress][_tokenId]
            .ERC20Token;

        uint256 _ownerPercentage = nftContractSale[_nftContractAddress][
            _tokenId
        ].ownerPercentage;

        uint256 platformPercentage = nftContractSale[_nftContractAddress][
            _tokenId
        ].platformPercentage;
        if (_isERC20Auction(erc20Token)) {
            // if sale is ERC20
            uint totalAmount = nftContractSale[_nftContractAddress][_tokenId]
                .buyNowPrice;
            // 1. Cut platform fees from the buyer
            uint256 platformFees = (totalAmount * (platformPercentage)) /
                (10000);
            // 2. Cut ownerAmount from Seller
            uint256 ownerAmount = (totalAmount * (_ownerPercentage)) / (10000);
            uint royaltyAmount;
            // Reset Sale Data
            _resetSale(_nftContractAddress, _tokenId);
            if (nftRoyalty[_nftContractAddress][_tokenId].activated) {
                address royaltyOwner = nftRoyalty[_nftContractAddress][_tokenId]
                    .royaltyOwner;
                uint _royaltyPercentage = nftRoyalty[_nftContractAddress][
                    _tokenId
                ].royaltyPercentage;
                // 3. Cut Royaltypercentage
                royaltyAmount = (totalAmount * (_royaltyPercentage)) / (10000);
                IERC20(erc20Token).transferFrom(
                    msg.sender,
                    royaltyOwner,
                    royaltyAmount
                );
            } else {
                nftRoyalty[_nftContractAddress][_tokenId].activated = true;
            }
            totalAmount -= ownerAmount; // this is what seller gets
            address owner = owner();
            uint256 adminFees= platformFees+ ownerAmount;
            IERC20(erc20Token).transferFrom(msg.sender, owner, adminFees);
            IERC20(erc20Token).transferFrom(msg.sender, seller, totalAmount);
        } else {
            uint totalAmount = msg.value;
            uint buyNowPrice = nftContractSale[_nftContractAddress][_tokenId]
                .buyNowPrice;
            // 1. Cut platform fees from the buyer
            uint256 platformFees = (buyNowPrice * (platformPercentage)) /
                (10000);
            totalAmount -= platformFees;
            // 2. Cut ownerAmount from Seller
            uint256 ownerAmount = (buyNowPrice * (_ownerPercentage)) / (10000);
            totalAmount -= ownerAmount;
            // Reset Sale Data
            _resetSale(_nftContractAddress, _tokenId);
            uint royaltyAmount;
            if (nftRoyalty[_nftContractAddress][_tokenId].activated == true) {
                address royaltyOwner = nftRoyalty[_nftContractAddress][_tokenId]
                    .royaltyOwner;
                uint _royaltyPercentage = nftRoyalty[_nftContractAddress][
                    _tokenId
                ].royaltyPercentage;
                // 3. Cut Royaltypercentage
                royaltyAmount = (buyNowPrice * (_royaltyPercentage)) / (10000);
                totalAmount -= royaltyAmount;
                payable(royaltyOwner).transfer(royaltyAmount);
            } else {
                nftRoyalty[_nftContractAddress][_tokenId].activated = true;
            }
            address owner = owner();
            uint256 adminFees = ownerAmount + platformFees;
            payable(owner).transfer(adminFees);
            (bool success, ) = payable(seller).call{value: totalAmount}("");
            if (!success) {
                revert();
            }
        }
        IERC721(_nftContractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );
    }

    function acceptBuyProposal(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _proposedPrice,
        address _proposingBuyer
    ) public {
        require(
            (msg.sender ==
                nftContractSale[_nftContractAddress][_tokenId].nftSeller),
            "Only Seller function"
        );
        buyProposal[_nftContractAddress][_tokenId].buyer = _proposingBuyer;
        buyProposal[_nftContractAddress][_tokenId].price = _proposedPrice;
    }

    function buyFromProposal(address _nftContractAddress, uint256 _tokenId)
        external
        payable
        nonReentrant
    {
        address seller = nftContractSale[_nftContractAddress][_tokenId]
            .nftSeller;
        uint32 platformPercentage = nftContractSale[_nftContractAddress][
            _tokenId
        ].platformPercentage;

        require(
            msg.sender == buyProposal[_nftContractAddress][_tokenId].buyer,
            "Invalid Buyer"
        );
        require(msg.sender != seller, "Seller cannot buy own NFT");
        uint256 buyNowPrice = buyProposal[_nftContractAddress][_tokenId].price;
        uint256 platformFees = (buyNowPrice * (platformPercentage)) / (10000);
        uint256 totalPayable = buyNowPrice + platformFees;
        uint royaltyAmount;
        if (nftRoyalty[_nftContractAddress][_tokenId].activated) {
            uint _royaltyPercentage = nftRoyalty[_nftContractAddress][_tokenId]
                .royaltyPercentage;
            royaltyAmount = (buyNowPrice * (_royaltyPercentage)) / (10000);
            totalPayable += royaltyAmount;
        }
        address erc20Token = nftContractSale[_nftContractAddress][_tokenId]
            .ERC20Token;
        if (_isERC20Auction(erc20Token)) {
            require(
                IERC20(erc20Token).balanceOf(msg.sender) >= totalPayable,
                "Not enough balance"
            );
        }
        else{
            require(msg.value >= totalPayable, "Not enough balance");
        }
        _buyFromProposal(_nftContractAddress, _tokenId);
    }

    function _buyFromProposal(address _nftContractAddress, uint256 _tokenId) internal{
        address seller = nftContractSale[_nftContractAddress][_tokenId]
            .nftSeller;
        address erc20Token = nftContractSale[_nftContractAddress][_tokenId]
            .ERC20Token;
        uint256 _ownerPercentage = nftContractSale[_nftContractAddress][
            _tokenId
        ].ownerPercentage;
        uint256 platformPercentage = nftContractSale[_nftContractAddress][
            _tokenId
        ].platformPercentage;
        if (_isERC20Auction(erc20Token)) {
            // if sale is ERC20
            uint totalAmount = buyProposal[_nftContractAddress][_tokenId]
                .price;
            uint256 platformFees = (totalAmount * (platformPercentage)) /
                (10000);
            // 2. Cut ownerAmount from Seller
            uint256 ownerAmount = (totalAmount * (_ownerPercentage)) / (10000);
            uint royaltyAmount;
            // Reset Sale Data
            _resetSale(_nftContractAddress, _tokenId);
            if (nftRoyalty[_nftContractAddress][_tokenId].activated) {
                address royaltyOwner = nftRoyalty[_nftContractAddress][_tokenId]
                    .royaltyOwner;
                uint _royaltyPercentage = nftRoyalty[_nftContractAddress][
                    _tokenId
                ].royaltyPercentage;
                // 3. Cut Royaltypercentage
                royaltyAmount = (totalAmount * (_royaltyPercentage)) / (10000);
                IERC20(erc20Token).transferFrom(
                    msg.sender,
                    royaltyOwner,
                    royaltyAmount
                );
            } else {
                nftRoyalty[_nftContractAddress][_tokenId].activated = true;
            }
            totalAmount -= ownerAmount; // this is what seller gets
            address owner = owner();
            uint256 adminFees= platformFees+ ownerAmount;
            IERC20(erc20Token).transferFrom(msg.sender, owner, adminFees);
            IERC20(erc20Token).transferFrom(msg.sender, seller, totalAmount);
        } else {
            uint totalAmount = msg.value;
            uint buyNowPrice = nftContractSale[_nftContractAddress][_tokenId]
                .buyNowPrice;
            // 1. Cut platform fees from the buyer
            uint256 platformFees = (buyNowPrice * (platformPercentage)) /
                (10000);
            totalAmount -= platformFees;
            // 2. Cut ownerAmount from Seller
            uint256 ownerAmount = (buyNowPrice * (_ownerPercentage)) / (10000);
            totalAmount -= ownerAmount;
            // Reset Sale Data
            _resetSale(_nftContractAddress, _tokenId);
            uint royaltyAmount;
            if (nftRoyalty[_nftContractAddress][_tokenId].activated == true) {
                address royaltyOwner = nftRoyalty[_nftContractAddress][_tokenId]
                    .royaltyOwner;
                uint _royaltyPercentage = nftRoyalty[_nftContractAddress][
                    _tokenId
                ].royaltyPercentage;
                // 3. Cut Royaltypercentage
                royaltyAmount = (buyNowPrice * (_royaltyPercentage)) / (10000);
                totalAmount -= royaltyAmount;
                payable(royaltyOwner).transfer(royaltyAmount);
            } else {
                nftRoyalty[_nftContractAddress][_tokenId].activated = true;
            }
            address owner = owner();
            uint256 adminFees = ownerAmount + platformFees;
            payable(owner).transfer(adminFees);
            (bool success, ) = payable(seller).call{value: totalAmount}("");
            if (!success) {
                revert();
            }
        }
        IERC721(_nftContractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );
    }

    function _resetSale(address _nftContractAddress, uint256 _tokenId)
        internal
    {
        delete nftContractSale[_nftContractAddress][_tokenId];
    }

    function setMarketplaceContract(address _marketplace) public onlyOwner{
        marketplaceContract= _marketplace;
    }


    function withdrawSale(address _nftContractAddress, uint256 _tokenId)
        external
        nonReentrant
    {
        address nftSeller = nftContractSale[_nftContractAddress][_tokenId]
            .nftSeller;
        require(
            nftSeller == msg.sender,
            "Only the owner can call this function"
        );
        // reset sale
        _resetSale(_nftContractAddress, _tokenId);
        // transfer the NFT back to the Seller
        IERC721(_nftContractAddress).safeTransferFrom(
            address(this),
            nftSeller,
            _tokenId
        );
    }

    function changeSale(
        address _nftContractAddress,
        uint256 _tokenId,
        uint _buyNowPrice,
        uint _royaltyPercentage
    ) public {
        require(
            msg.sender ==
                nftContractSale[_nftContractAddress][_tokenId].nftSeller,
            "Only Seller allowed"
        );
        nftContractSale[_nftContractAddress][_tokenId]
            .buyNowPrice = _buyNowPrice;
        if (!nftRoyalty[_nftContractAddress][_tokenId].activated) {
            nftRoyalty[_nftContractAddress][_tokenId]
                .royaltyPercentage = _royaltyPercentage;
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
}