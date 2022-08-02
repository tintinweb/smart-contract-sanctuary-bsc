/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// File: IService.sol



pragma solidity >=0.8.4 <0.9.0;

interface IService {
    function platformAddress() external view returns (address);

    function platformFeeRate() external view returns (uint96);

    function royaltyOf(address collection, uint256 salePrice) external view returns (address, uint256);

    function kothOf(address collection, uint256 tokenId, uint256 salePrice) external view returns (address, uint256);

    function gammaLockOf(address collection, uint256 tokenId) external view returns (uint256);

    event Lock(address indexed collection, uint256 indexed tokenId, uint256 amount, address account);

    event Unlock(address indexed collection, uint256 indexed tokenId, address account);
}

// File: Context.sol



pragma solidity >=0.8.4 <0.9.0;

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

// File: Ownable.sol



pragma solidity >=0.8.4 <0.9.0;


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
contract Ownable is Context {
    address _owner;

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
    function owner() public view returns (address) {
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
    function renounceOwnership() external onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: IERC165.sol



pragma solidity >=0.8.4 <0.9.0;

/**
 * @dev Interface of the ERC165 standard as defined in the EIP.
 */
interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
     * @return `true` if the contract implements `interfaceID` and
     * `interfaceId` is not 0xffffffff, `false` otherwise
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: IERC721.sol



pragma solidity >=0.8.4 <0.9.0;


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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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

// File: IERC20.sol



pragma solidity >=0.8.4 <0.9.0;

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

// File: IERC20Metadata.sol



pragma solidity >=0.8.4 <0.9.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: Service.sol



pragma solidity >=0.8.4 <0.9.0;






contract Service is Ownable, IService {
    // ----- STRUCTS ----- //
    struct RoyaltyInfo {
        address owner;
        uint96 rate;
    }

    struct KotHInfo {
        address owner;
        uint256 price;
    }

    // ----- STATE VARIABLES ----- //
    mapping(address => RoyaltyInfo) _royalties;
    mapping(address => mapping(uint256 => KotHInfo)) _koths;
    mapping(address => mapping(uint256 => uint256)) _gammaLocks;
    mapping(address => bool) _isKotH;
    mapping(address => uint96) _kothRates;

    IERC20 _gammaToken;
    uint8 _gammaDecimals;
    uint96 constant _denominator = 10000;
    address _platformAddress;
    uint96 _platformFeeRate = 250;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    // ----- CONSTRUCTOR ----- //
    constructor(address token) {
        _gammaToken = IERC20(token);
        _platformAddress = _msgSender();
        _gammaDecimals = IERC20Metadata(token).decimals();
    }

    // ----- VIEW FUNCTIONS ----- //
    function gammaLockOf(address collection, uint256 tokenId) external view override returns (uint256) {
        return _gammaLocks[collection][tokenId];
    }

    function royaltyOf(address collection, uint256 salePrice) external view override returns (address, uint256) {
        address owner = _royalties[collection].owner;
        uint256 royalty = salePrice * _royalties[collection].rate / _denominator;

        return (owner, royalty);
    }

    function kothOf(address collection, uint256 tokenId, uint256 salePrice) external view override returns (address, uint256) {
        address owner = _koths[collection][tokenId].owner;
        uint256 koth = salePrice * _kothRates[collection] / _denominator;
        if(owner == address(0))
            owner = _royalties[collection].owner;

        return (owner, koth);
    }

    function platformAddress() external view override returns (address) {
        return _platformAddress;
    }

    function platformFeeRate() external view override returns (uint96) {
        return _platformFeeRate;
    }

    // ----- MUTATION FUNCTIONS ----- //
    function lockGamma(address collection, uint256 tokenId, uint256 amount) external {
        require(amount > 0, "Service: amount is zero");
        require(_gammaToken.transferFrom(_msgSender(), address(this), amount), "Service: failed to transfer tokens for lock");

        _gammaLocks[collection][tokenId] += amount;
        emit Lock(collection, tokenId, amount, _msgSender());
    }

    function unlockGamma(address collection, uint256 tokenId) external {
        require(_gammaToken.transfer(_msgSender(), _gammaLocks[collection][tokenId]), "Service: failed to transfer tokens for unlock");
        require(IERC721(collection).ownerOf(tokenId) == _msgSender(), "Service: caller is not the token owner");

        IERC721(collection).safeTransferFrom(_msgSender(), DEAD, tokenId);
        _gammaLocks[collection][tokenId] = 0;
        emit Unlock(collection, tokenId, _msgSender());
    }

    function setRoyalty(address collection, address royaltyOwner, uint96 feeNumerator) external {
        require(IOwnable(collection).owner() == _msgSender(), "Service: caller is not the collection owner");
        require(feeNumerator + _kothRates[collection] <= 1000, "Service: royalty and koth is above max");

        RoyaltyInfo memory royalty;
        royalty.owner = royaltyOwner;
        royalty.rate = feeNumerator;

        _royalties[collection] = royalty;
    }

    function enableKotH(address collection, uint96 feeNumerator) external {
        require(!_isKotH[collection], "Service: KotH is already enabled");
        require(IOwnable(collection).owner() == _msgSender(), "Service: caller is not the collection owner");
        require(feeNumerator + _royalties[collection].rate >= 100 && feeNumerator + _royalties[collection].rate <= 1000, "Service: invalid fee value");

        _isKotH[collection] = true;
        _kothRates[collection] = feeNumerator;
    }

    function setKotH(address collection, uint96 feeNumerator) external {
        require(_isKotH[collection], "Service: KotH is disabled");
        require(IOwnable(collection).owner() == _msgSender(), "Service: caller is not the collection owner");
        require(feeNumerator + _royalties[collection].rate >= 100 && feeNumerator + _royalties[collection].rate <= 1000, "Service: invalid fee value");

        _kothRates[collection] = feeNumerator;
    }

    function takeKotH(address collection, uint256 tokenId, uint256 price) external {
        require(_isKotH[collection], "Service: KotH is disabled");
        require(price >= _koths[collection][tokenId].price * 110 / 100 && price >= _gammaDecimals, "Service: price is below the min requirement");

        KotHInfo memory koth = _koths[collection][tokenId];
        address collectionOwner = IOwnable(collection).owner();
        address oldOwner = koth.owner;
        uint256 oldPrice = koth.price;
        uint256 payment = oldPrice * 105 / 100;
        uint256 fee = (price - payment) / 2;

        if(oldOwner != address(0))
            require(_gammaToken.transferFrom(_msgSender(), oldOwner, payment), "Service: failed to transfer tokens for KotH");
        require(_gammaToken.transferFrom(_msgSender(), _platformAddress, fee), "Service: failed to transfer tokens for service fee");
        require(_gammaToken.transferFrom(_msgSender(), collectionOwner, fee), "Service: failed to transfer tokens for owner fee");

        koth.owner = _msgSender();
        koth.price = price;
        _koths[collection][tokenId] = koth;
    }
}

interface IOwnable {
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() external view returns (address);
}