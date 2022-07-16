// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

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
interface IERC165Upgradeable {
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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Shop is Initializable, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    IERC20Upgradeable public ninoToken;
    IERC20Upgradeable public mataToken;

    address public addressNinoReceiver;
    address public addressMataReceiver;

    mapping(uint256 => Package) public packageNinoIds;
    mapping(uint256 => Package) public packageMataIds;

    mapping(address => mapping(uint256 => DateBuy)) public ninoBuyers; // address => (packageId => number bought)
    mapping(address => mapping(uint256 => DateBuy)) public mataBuyers;
    mapping(address => mapping(uint256 => uint256)) public packageNinoLimit;
    mapping(address => mapping(uint256 => uint256)) public packageMataLimit;

    IERC20Upgradeable public busd;
    address public busdReceiver;
    mapping(uint256 => Package) public gemPackageNinoIds;
    mapping(uint256 => Package) public gemPackageBusdIds;
    mapping(address => mapping(uint256 => DateBuy)) public gemNinoBuyers;
    mapping(address => mapping(uint256 => DateBuy)) public gemBusdBuyers;
    mapping(address => mapping(uint256 => uint256)) public gemPackageNinoLimit;
    mapping(address => mapping(uint256 => uint256)) public gemPackageBusdLimit;

    event BuyWithNino(address indexed buyer, uint256 packageId, uint256 quantity, uint256 price);
    event BuyWithMata(address indexed buyer, uint256 packageId, uint256 quantity, uint256 price);
    event NonFungibleTokenRecovery(address indexed token, uint256 tokenId);
    event TokenRecovery(address indexed token, uint256 amount);
    event BuyGemWithNino(address indexed buyer, uint256 packageId, uint256 quantity, uint256 price);
    event BuyGemWithBusd(address indexed buyer, uint256 packageId, uint256 quantity, uint256 price);

    struct DateBuy {
        uint256 number;
        uint256 dateLastBuy; // timestamp = so ngay * 24*60*60 + so h * 60 *60 + so phut *60
        // dateLastBuy (so thu tu ngay so voi 1/1/1970) bang phan nguyen cua timeStamp / 24 / 60/60
    }

    struct Package {
        uint256 price;
        uint256 limit;
        uint256 limitTotal;
    }

    function initialize(
        address _ninoToken,
        address _mataToken,
        address _busd
    ) public initializer {
        __Ownable_init_unchained();
        __Pausable_init();
        __ReentrancyGuard_init_unchained();

        addressNinoReceiver = owner();
        addressMataReceiver = owner();
        busdReceiver = owner();

        ninoToken = IERC20Upgradeable(_ninoToken);
        mataToken = IERC20Upgradeable(_mataToken);
        busd = IERC20Upgradeable(_busd);
    }

    function setPause() external onlyOwner {
        _pause();
    }

    function unsetPause() external onlyOwner {
        _unpause();
    }

    function setNinoAddress(address _address) external onlyOwner {
        ninoToken = IERC20Upgradeable(_address);
    }

    function setMataAddress(address _address) external onlyOwner {
        mataToken = IERC20Upgradeable(_address);
    }

    function setBusdAddress(address _address) external onlyOwner {
        busd = IERC20Upgradeable(_address);
    }

    function setNinoReceiver(address _add) external onlyOwner {
        addressNinoReceiver = _add;
    }

    function setMataReceiver(address _add) external onlyOwner {
        addressMataReceiver = _add;
    }

    function setBusdReceiver(address _add) external onlyOwner {
        busdReceiver = _add;
    }

    function setPackageNinoId(
        uint256[] memory _ids,
        uint256[] memory _prices,
        uint256[] memory _limitsPerDay,
        uint256[] memory _limitsTotal
    ) external onlyOwner {
        require(_ids.length > 0 && _ids.length == _prices.length && _prices.length == _limitsPerDay.length && _prices.length == _limitsTotal.length, "Input invalid");
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 id = _ids[i];
            uint256 price = _prices[i];
            uint256 limitPerDay = _limitsPerDay[i];
            uint256 limitTotal = _limitsTotal[i];
            packageNinoIds[id] = Package(price, limitPerDay, limitTotal);
        }
    }

    function setPackageMataId(
        uint256[] memory _ids,
        uint256[] memory _prices,
        uint256[] memory _limitsPerDay,
        uint256[] memory _limitsTotal
    ) external onlyOwner {
        require(_ids.length > 0 && _ids.length == _prices.length && _prices.length == _limitsPerDay.length && _prices.length == _limitsTotal.length, "Input invalid");
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 id = _ids[i];
            uint256 price = _prices[i];
            uint256 limitPerDay = _limitsPerDay[i];
            uint256 limitTotal = _limitsTotal[i];
            packageMataIds[id] = Package(price, limitPerDay, limitTotal);
        }
    }

    function setGemPackageNinoIds(
        uint256[] memory _ids,
        uint256[] memory _prices,
        uint256[] memory _limitsPerDay,
        uint256[] memory _limitsTotal
    ) external onlyOwner {
        require(_ids.length > 0 && _ids.length == _prices.length && _prices.length == _limitsPerDay.length && _prices.length == _limitsTotal.length, "Input invalid");
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 id = _ids[i];
            uint256 price = _prices[i];
            uint256 limitPerDay = _limitsPerDay[i];
            uint256 limitTotal = _limitsTotal[i];
            gemPackageNinoIds[id] = Package(price, limitPerDay, limitTotal);
        }
    }

    function setGemPackageBusdIds(
        uint256[] memory _ids,
        uint256[] memory _prices,
        uint256[] memory _limitsPerDay,
        uint256[] memory _limitsTotal
    ) external onlyOwner {
        require(_ids.length > 0 && _ids.length == _prices.length && _prices.length == _limitsPerDay.length && _prices.length == _limitsTotal.length, "Input invalid");
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 id = _ids[i];
            uint256 price = _prices[i];
            uint256 limitPerDay = _limitsPerDay[i];
            uint256 limitTotal = _limitsTotal[i];
            gemPackageBusdIds[id] = Package(price, limitPerDay, limitTotal);
        }
    }

    function buyPackageNino(uint256 _id, uint256 _quantity) external whenNotPaused nonReentrant {
        Package memory package = packageNinoIds[_id];
        uint256 price = package.price;
        uint256 limitPerDay = package.limit;
        uint256 limitTotal = package.limitTotal;
        uint256 total = price * _quantity;

        require(ninoToken.allowance(msg.sender, address(this)) >= total, "Allow: amount allow invalid");
        require(ninoToken.balanceOf(msg.sender) >= total, "Insufficient balance");

        uint256 currentDate = getDateNumber(block.timestamp);
        DateBuy storage dateBuy = ninoBuyers[msg.sender][_id]; // dateBuy la ngay gan nhat no mua
        if (dateBuy.dateLastBuy != currentDate) {
            // neu ko phai ngay hien tai thi reset so luong mua ve 0, dateLastBuy ve ngay hien tai
            dateBuy.number = 0;
            dateBuy.dateLastBuy = currentDate;
        }
        // sau khi check o tren thi dateBuy la ngay hom nay user mua
        require(dateBuy.number + _quantity <= limitPerDay, "Over limitPerDay"); // check xem ngay hom nay no mua vuot gioi han chua
        if (limitTotal > 0) {
            require(packageNinoLimit[msg.sender][_id] + _quantity <= limitTotal, "Over limit");
            packageNinoLimit[msg.sender][_id] = packageNinoLimit[msg.sender][_id] + _quantity;
        }
        dateBuy.number = dateBuy.number + _quantity;

        ninoToken.transferFrom(msg.sender, addressNinoReceiver, total);

        emit BuyWithNino(msg.sender, _id, _quantity, total);
    }

    function buyPackageMata(uint256 _id, uint256 _quantity) external whenNotPaused nonReentrant {
        Package memory package = packageMataIds[_id];
        uint256 price = package.price;
        uint256 limitPerDay = package.limit;
        uint256 limitTotal = package.limitTotal;
        uint256 total = price * _quantity;

        require(mataToken.allowance(msg.sender, address(this)) >= total, "Allow: amount allow invalid");
        require(mataToken.balanceOf(msg.sender) >= total, "Insufficient balance");

        uint256 currentDate = getDateNumber(block.timestamp);
        DateBuy storage dateBuy = mataBuyers[msg.sender][_id];
        if (dateBuy.dateLastBuy != currentDate) {
            dateBuy.number = 0;
            dateBuy.dateLastBuy = currentDate;
        }

        require(dateBuy.number + _quantity <= limitPerDay, "Over limitPerDay");
        if (limitTotal > 0) {
            require(packageNinoLimit[msg.sender][_id] + _quantity <= limitTotal, "Over limit");
            packageNinoLimit[msg.sender][_id] = packageNinoLimit[msg.sender][_id] + _quantity;
        }
        dateBuy.number = dateBuy.number + _quantity;

        mataToken.transferFrom(msg.sender, addressMataReceiver, total);
        emit BuyWithMata(msg.sender, _id, _quantity, total);
    }

    function buyGemPackageNino(uint256 _id, uint256 _quantity) external whenNotPaused nonReentrant {
        Package memory package = gemPackageNinoIds[_id];
        uint256 price = package.price;
        uint256 limitPerDay = package.limit;
        uint256 limitTotal = package.limitTotal;
        uint256 total = price * _quantity;

        require(ninoToken.allowance(msg.sender, address(this)) >= total, "Allow: amount allow invalid");
        require(ninoToken.balanceOf(msg.sender) >= total, "Insufficient balance");

        uint256 currentDate = getDateNumber(block.timestamp);
        DateBuy storage dateBuy = gemNinoBuyers[msg.sender][_id];
        if (dateBuy.dateLastBuy != currentDate) {
            dateBuy.number = 0;
            dateBuy.dateLastBuy = currentDate;
        }
        require(dateBuy.number + _quantity <= limitPerDay, "Over limitPerDay");
        if (limitTotal > 0) {
            require(gemPackageNinoLimit[msg.sender][_id] + _quantity <= limitTotal, "Over limit");
            gemPackageNinoLimit[msg.sender][_id] = gemPackageNinoLimit[msg.sender][_id] + _quantity;
        }
        dateBuy.number = dateBuy.number + _quantity;

        ninoToken.transferFrom(msg.sender, addressNinoReceiver, total);

        emit BuyGemWithNino(msg.sender, _id, _quantity, total);
    }

    function buyGemPackageBusd(uint256 _id, uint256 _quantity) external whenNotPaused nonReentrant {
        Package memory package = gemPackageBusdIds[_id];
        uint256 price = package.price;
        uint256 limitPerDay = package.limit;
        uint256 limitTotal = package.limitTotal;
        uint256 total = price * _quantity;

        require(busd.allowance(msg.sender, address(this)) >= total, "Allow: amount allow invalid");
        require(busd.balanceOf(msg.sender) >= total, "Insufficient balance");

        uint256 currentDate = getDateNumber(block.timestamp);
        DateBuy storage dateBuy = gemBusdBuyers[msg.sender][_id];
        if (dateBuy.dateLastBuy != currentDate) {
            dateBuy.number = 0;
            dateBuy.dateLastBuy = currentDate;
        }
        require(dateBuy.number + _quantity <= limitPerDay, "Over limitPerDay");
        if (limitTotal > 0) {
            require(gemPackageBusdLimit[msg.sender][_id] + _quantity <= limitTotal, "Over limit");
            gemPackageBusdLimit[msg.sender][_id] = gemPackageBusdLimit[msg.sender][_id] + _quantity;
        }
        dateBuy.number = dateBuy.number + _quantity;

        busd.transferFrom(msg.sender, busdReceiver, total);

        emit BuyGemWithBusd(msg.sender, _id, _quantity, total);
    }

    function recoverNonFungibleToken(address _token, uint256[] memory _tokenIds) external onlyOwner {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];
            IERC721Upgradeable(_token).transferFrom(address(this), address(msg.sender), tokenId);
            emit NonFungibleTokenRecovery(_token, tokenId);
        }
    }

    function recoverToken(address _token) external onlyOwner {
        uint256 balance = IERC20Upgradeable(_token).balanceOf(address(this));
        require(balance != 0, "Operations: Cannot recover zero balance");

        IERC20Upgradeable(_token).transfer(address(msg.sender), balance);

        emit TokenRecovery(_token, balance);
    }

    function getDateNumber(uint256 _timeStamp) public pure returns (uint256) {
        return _timeStamp / 24 / 60 / 60;
    }

    function getNumberPackageNinoBoughtToday(address _address, uint256[] memory _ids) public view returns (uint256[] memory) {
        uint256 currentDate = getDateNumber(block.timestamp);
        uint256[] memory result = new uint256[](_ids.length);
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 index = _ids[i];
            DateBuy memory dateBuy = ninoBuyers[_address][index];
            if (dateBuy.dateLastBuy != currentDate) {
                result[i] = 0;
            } else {
                result[i] = dateBuy.number;
            }
        }
        return result;
    }

    function getNumberPackageMataBoughtToday(address _address, uint256[] memory _ids) public view returns (uint256[] memory) {
        uint256 currentDate = getDateNumber(block.timestamp);
        uint256[] memory result = new uint256[](_ids.length);
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 index = _ids[i];
            DateBuy memory dateBuy = mataBuyers[_address][index];
            if (dateBuy.dateLastBuy != currentDate) {
                result[i] = 0;
            } else {
                result[i] = dateBuy.number;
            }
        }
        return result;
    }

    function getLimitBuyPackageNino(uint256[] memory _packageIds) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_packageIds.length);
        for (uint256 i = 0; i < _packageIds.length; i++) {
            uint256 index = _packageIds[i];
            Package memory package = packageNinoIds[index];
            result[i] = package.limit;
        }

        return result;
    }

    function getLimitBuyPackageMata(uint256[] memory _packageIds) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_packageIds.length);
        for (uint256 i = 0; i < _packageIds.length; i++) {
            uint256 index = _packageIds[i];
            Package memory package = packageMataIds[index];
            result[i] = package.limit;
        }

        return result;
    }

    function getLimitTotalBuyPackageNino(uint256[] memory _packageIds) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_packageIds.length);
        for (uint256 i = 0; i < _packageIds.length; i++) {
            uint256 index = _packageIds[i];
            Package memory package = packageNinoIds[index];
            result[i] = package.limitTotal;
        }

        return result;
    }

    function getLimitTotalBuyPackageMata(uint256[] memory _packageIds) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_packageIds.length);
        for (uint256 i = 0; i < _packageIds.length; i++) {
            uint256 index = _packageIds[i];
            Package memory package = packageMataIds[index];
            result[i] = package.limitTotal;
        }

        return result;
    }

    function getNumberPackageLimitNinoBought(address _address, uint256[] memory _ids) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_ids.length);
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 index = _ids[i];
            result[i] = packageNinoLimit[_address][index];
        }
        return result;
    }

    function getNumberPackageLimitMataBought(address _address, uint256[] memory _ids) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_ids.length);
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 index = _ids[i];
            result[i] = packageMataLimit[_address][index];
        }
        return result;
    }
}