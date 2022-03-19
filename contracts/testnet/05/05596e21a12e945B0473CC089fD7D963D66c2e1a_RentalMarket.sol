// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./IRentalMarket.sol";
import "../lib/SafeBEP20.sol";
import "../nft/ERC721.sol";
import "../token/IBEP20.sol";
import "../utils/ReentrancyGuard.sol";
import "../utils/Pausable.sol";
import "./RentalStorage.sol";

contract RentalMarket is IRentalMarket, Ownable, ReentrancyGuard, Pausable {
    using SafeBEP20 for IBEP20;

    RentalStorage private _marketStorage;

    ERC721 private _erc721;

    constructor(ERC721 erc721, RentalStorage marketStorage) {
        _erc721 = erc721;
        _marketStorage = marketStorage;
    }

    function setTokenAddress(ERC721 _newNFT) external onlyOwner {
        require(address(_newNFT) != address(0), "RentalMarket: NFT address(0)");
        _erc721 = _newNFT;
    }

    function setMarketStorage(RentalStorage newMarketStorage)
        external
        onlyOwner
    {
        require(
            address(newMarketStorage) != address(0),
            "RentalMarket: setMarketStorage query for the zero address"
        );
        _marketStorage = newMarketStorage;
    }

    function listing(
        uint256 tokenId,
        address currency,
        uint256 rentalPrice,
        uint256 timeAllowedRent
    ) external whenNotPaused {
        require(
            _erc721.ownerOf(tokenId) == _msgSender(),
            "RentalMarket: listing caller is not owner"
        );
        require(0 <= rentalPrice, "RentalMarket: price not match");
        require(
            !_marketStorage.existed(tokenId),
            "RentalMarket: listing query for already listing token"
        );
        require(
            !_erc721.isLocked(tokenId),
            "RentalMarket: listing query for locked token"
        );
        _marketStorage.addItem(
            tokenId,
            _msgSender(),
            currency,
            rentalPrice,
            timeAllowedRent
        );
        _erc721.lock(tokenId, block.timestamp + timeAllowedRent);
        emit Listing(
            _msgSender(),
            tokenId,
            currency,
            rentalPrice,
            timeAllowedRent,
            block.timestamp
        );
    }

    function updateListing(
        uint256 tokenId,
        address currency,
        uint256 rentalPrice,
        uint256 timeAllowedRent
    ) external whenNotPaused {
        require(
            _erc721.ownerOf(tokenId) == _msgSender(),
            "RentalMarket: updateListing caller is not owner"
        );
        require(
            !_marketStorage.rented(tokenId),
            "RentalMarket: updateListing query for have been rented token"
        );
        require(0 <= rentalPrice, "RentalMarket: price mismatch");
        _marketStorage.updateItem(
            tokenId,
            _msgSender(),
            currency,
            rentalPrice,
            timeAllowedRent
        );
        _erc721.lock(tokenId, block.timestamp + timeAllowedRent);
        emit UpdateListing(
            _msgSender(),
            tokenId,
            currency,
            rentalPrice,
            timeAllowedRent,
            block.timestamp
        );
    }

    function unListing(uint256 tokenId) external whenNotPaused {
        require(
            _erc721.ownerOf(tokenId) == _msgSender(),
            "RentalMarket: unListing caller is not owner"
        );
        require(
            _marketStorage.existed(tokenId),
            "RentalMarket: unListing query for none listing token"
        );
        require(
            !_marketStorage.rented(tokenId),
            "RentalMarket: unListing query for have been rented token"
        );
        _erc721.unlock(tokenId);
        _marketStorage.deleteItem(tokenId);
        emit UnListing(_msgSender(), tokenId, block.timestamp);
    }

    function rent(uint256 tokenId, uint256 timeRent)
        external
        payable
        whenNotPaused
        nonReentrant
    {
        require(
            _marketStorage.existed(tokenId),
            "RentalMarket: rent query for not rented token"
        );
        require(
            !_marketStorage.rented(tokenId),
            "RentalMarket: rent query for have been rented token"
        );
        require(
            _erc721.ownerOf(tokenId) != _msgSender(),
            "RentalMarket: rent caller is renter"
        );
        address owner;
        address currency;
        uint256 price;
        uint256 timeAllowedRent;
        uint256 startTimeListing;
        (
            ,
            owner,
            ,
            currency,
            price,
            timeAllowedRent,
            ,
            ,
            startTimeListing
        ) = _marketStorage.getItem(tokenId);
        if (timeAllowedRent > 0) {
            require(
                timeAllowedRent + startTimeListing - block.timestamp > timeRent,
                "RentalMarket: rent query for not enough rental time"
            );
        }
        _rent(tokenId, timeRent, owner, currency, price);
    }

    function _rent(
        uint256 tokenId,
        uint256 timeRent,
        address owner,
        address currency,
        uint256 price
    ) internal {
        uint256 feeAmount;
        uint256 sellerAmount;
        address feeOwner;
        (feeAmount, sellerAmount, feeOwner) = _calculateFee(
            tokenId,
            price,
            timeRent,
            owner,
            currency
        );
        uint256 id = _erc721.clone(
            _msgSender(),
            tokenId,
            timeRent + block.timestamp
        );
        _marketStorage.updateRentItem(tokenId, id, _msgSender(), timeRent);
        emit Rented(
            _msgSender(),
            tokenId,
            currency,
            price,
            feeAmount,
            sellerAmount,
            timeRent,
            block.timestamp
        );
    }

    function rentExtension(uint256 tokenId, uint256 timeRent)
        external
        payable
        whenNotPaused
        nonReentrant
    {
        uint256 childId;
        address owner;
        address renter;
        address currency;
        uint256 price;
        uint256 timeAllowedRent;
        uint256 startTimeListing;
        (
            childId,
            owner,
            renter,
            currency,
            price,
            timeAllowedRent,
            ,
            ,
            startTimeListing
        ) = _marketStorage.getItem(tokenId);
        require(
            renter == _msgSender(),
            "RentalMarket: rent caller is not renter"
        );
        if (timeAllowedRent > 0) {
            require(
                timeAllowedRent + startTimeListing - block.timestamp > timeRent,
                "RentalMarket: NFT not enough rental time"
            );
        }
        _rentExtension(tokenId, childId, timeRent, owner, currency, price);
    }

    function _rentExtension(
        uint256 tokenId,
        uint256 childId,
        uint256 timeRent,
        address owner,
        address currency,
        uint256 price
    ) internal {
        uint256 feeAmount;
        uint256 sellerAmount;
        address feeOwner;
        (feeAmount, sellerAmount, feeOwner) = _calculateFee(
            tokenId,
            price,
            timeRent,
            owner,
            currency
        );
        _erc721.changeTimeLife(childId, block.timestamp + timeRent);
        _marketStorage.updateTotalTimeRent(tokenId, timeRent);
        emit RentedExtent(
            _msgSender(),
            tokenId,
            price,
            feeAmount,
            sellerAmount,
            timeRent,
            block.timestamp
        );
    }

    function returnItem(uint256 tokenId) external whenNotPaused {
        address renter;
        uint256 childId;
        (childId, , renter, , , , , , ) = _marketStorage.getItem(tokenId);
        require(
            renter == _msgSender(),
            "RentalMarket: You do not rent this NFT"
        );
        _erc721.burn(childId);
        _marketStorage.updateReturnItem(tokenId);
        emit ReturnItem(_msgSender(), tokenId, block.timestamp);
    }

    function batchReturnItem(uint256[] memory tokenIds)
        external
        whenNotPaused
        onlyOwner
    {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 startTimeRent;
            uint256 totalTimeRent;
            uint256 childId;
            address renter;
            address owner;
            (
                childId,
                owner,
                renter,
                ,
                ,
                ,
                totalTimeRent,
                startTimeRent,

            ) = _marketStorage.getItem(tokenIds[i]);
            if (startTimeRent + totalTimeRent <= block.timestamp) {
                _erc721.burn(childId);
                _marketStorage.updateReturnItem(tokenIds[i]);
                emit ReturnItem(renter, tokenIds[i], block.timestamp);
            }
        }
    }

    function _calculateFee(
        uint256 tokenId,
        uint256 price,
        uint256 timeRent,
        address owner,
        address currency
    )
        internal
        returns (
            uint256,
            uint256,
            address
        )
    {
        uint256 _amount = (price * timeRent) / 3600;
        uint256 treeCount;
        (, , , , , treeCount, , , ) = _erc721.getInfo(tokenId);
        uint256 commission;
        uint256 fee;
        address feeOwner;
        (fee, commission, feeOwner) = _marketStorage.getFeeMarket(
            treeCount + 1
        );
        uint256 feeAmount = (fee * _amount) / commission;
        uint256 sellerAmount = _amount - feeAmount;
        IBEP20(currency).safeTransferFrom(_msgSender(), owner, sellerAmount);
        IBEP20(currency).safeTransferFrom(_msgSender(), feeOwner, feeAmount);
        return (feeAmount, sellerAmount, feeOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

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
     * by making the `nonReentrant` function external, and making it call a
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
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
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Context.sol";

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

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
pragma solidity 0.8.9;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBEP20 {
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../utils/Ownable.sol";

contract RentalStorage is Ownable {
    mapping(uint256 => Item) private _items;

    mapping(uint256 => uint256) private _fees;

    mapping(address => bool) private _whileLists;

    address private _feeOwner;

    uint256 private _commission;

    uint256 private _maxFee;

    uint256 private _maxNumRentFee;

    struct Item {
        uint256 childId;
        address owner;
        address renter;
        address currency;
        uint256 price;
        uint256 timeAllowedRent;
        uint256 totalTimeRent;
        uint256 startTimeRent;
        uint256 startTimeListing;
    }

    constructor() {
        _feeOwner = owner();
        _commission = 10000;
        _maxFee = 5000;
        _maxNumRentFee = 5;
    }

    modifier onlyWhileList() {
        require(_whileLists[_msgSender()], "RentalStorage: only while list");
        _;
    }

    function setWhileList(address _user, bool _isWhileList) external onlyOwner {
        _whileLists[_user] = _isWhileList;
    }

    function setFeeOwner(address feeOwner) external onlyOwner {
        require(
            address(feeOwner) != address(0),
            "RentalStorage: setFeeOwner query for the zero address"
        );
        _feeOwner = feeOwner;
    }

    function setMaxFee(uint256 fee, uint256 maxNumRentFee) external onlyOwner {
        _maxFee = fee;
        _maxNumRentFee = maxNumRentFee;
    }

    function setCommission(uint256 commission) external onlyOwner {
        require(commission != 0, "RentalStorage: setCommission mismatch");
        _commission = commission;
    }

    function setFeeMarket(uint256[] memory numRents, uint256[] memory fees)
        external
        onlyOwner
    {
        require(
            numRents.length == fees.length,
            "RentalStorage: numRents and fees length mismatch"
        );
        for (uint256 i = 0; i < numRents.length; i++) {
            _fees[numRents[i]] = fees[i];
        }
    }

    function getFeeMarket(uint256 numRent)
        public
        view
        returns (
            uint256,
            uint256,
            address
        )
    {
        if (numRent >= _maxNumRentFee) {
            return (_maxFee, _commission, _feeOwner);
        }
        return (_fees[numRent], _commission, _feeOwner);
    }

    function addItem(
        uint256 tokenId,
        address owner,
        address currency,
        uint256 price,
        uint256 timeAllowedRent
    ) external onlyWhileList {
        _items[tokenId] = Item(
            0,
            owner,
            address(0),
            currency,
            price,
            timeAllowedRent,
            0,
            0,
            block.timestamp
        );
    }

    function updateItem(
        uint256 tokenId,
        address owner,
        address currency,
        uint256 price,
        uint256 timeAllowedRent
    ) external onlyWhileList {
        _items[tokenId] = Item(
            0,
            owner,
            address(0),
            currency,
            price,
            timeAllowedRent,
            0,
            0,
            block.timestamp
        );
    }

    function deleteItem(uint256 tokenId) external onlyWhileList {
        delete _items[tokenId];
    }

    function deleteItems(uint256[] memory tokenIds) external onlyWhileList {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            delete _items[tokenIds[i]];
        }
    }

    function getItem(uint256 tokenId)
        public
        view
        returns (
            uint256,
            address,
            address,
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        Item memory item = _items[tokenId];
        return (
            item.childId,
            item.owner,
            item.renter,
            item.currency,
            item.price,
            item.timeAllowedRent,
            item.totalTimeRent,
            item.startTimeRent,
            item.startTimeListing
        );
    }

    function existed(uint256 tokenId) public view returns (bool) {
        return _items[tokenId].owner != address(0);
    }

    function rented(uint256 tokenId) public view returns (bool) {
        return _items[tokenId].renter != address(0);
    }

    function renterOf(uint256 tokenId) public view returns (address) {
        return _items[tokenId].renter;
    }

    function childTokenOf(uint256 tokenId) public view returns (uint256) {
        return _items[tokenId].childId;
    }

    function updateRentItem(
        uint256 tokenId,
        uint256 childId,
        address renter,
        uint256 timeRent
    ) external onlyWhileList {
        Item memory item = _items[tokenId];
        _items[tokenId] = Item(
            childId,
            item.owner,
            renter,
            item.currency,
            item.price,
            item.timeAllowedRent,
            timeRent,
            block.timestamp,
            item.startTimeListing
        );
    }

    function updateReturnItem(uint256 tokenId) external onlyWhileList {
        Item memory item = _items[tokenId];
        _items[tokenId] = Item(
            0,
            item.owner,
            address(0),
            item.currency,
            item.price,
            item.timeAllowedRent,
            0,
            0,
            item.startTimeListing
        );
    }

    function updateTotalTimeRent(uint256 tokenId, uint256 timeRent)
        external
        onlyWhileList
    {
        Item memory item = _items[tokenId];
        _items[tokenId] = Item(
            item.childId,
            item.owner,
            item.renter,
            item.currency,
            item.price,
            item.timeAllowedRent,
            item.totalTimeRent + timeRent,
            item.startTimeRent,
            item.startTimeListing
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IRentalMarket {
    event Listing(
        address indexed owner,
        uint256 tokenId,
        address currency,
        uint256 rentalPrice,
        uint256 timeAllowedRent,
        uint256 timestamp
    );

    event UpdateListing(
        address indexed owner,
        uint256 tokenId,
        address currency,
        uint256 rentalPrice,
        uint256 timeAllowedRent,
        uint256 timestamp
    );

    event UnListing(address indexed owner, uint256 tokenId, uint256 timestamp);

    event Rented(
        address indexed owner,
        uint256 tokenId,
        address currency,
        uint256 rentalPrice,
        uint256 feeAmount,
        uint256 sellerAmount,
        uint256 timeRented,
        uint256 timestamp
    );

    event RentedExtent(
        address indexed owner,
        uint256 tokenId,
        uint256 rentalPrice,
        uint256 feeAmount,
        uint256 sellerAmount,
        uint256 timeRented,
        uint256 timestamp
    );

    event ReturnItem(
        address indexed renter,
        uint256 tokenId,
        uint256 timestamp
    );

    function listing(
        uint256 tokenId,
        address currency,
        uint256 rentalPrice,
        uint256 timeAllowedRent
    ) external;

    function updateListing(
        uint256 tokenId,
        address currency,
        uint256 rentalPrice,
        uint256 timeAllowedRent
    ) external;

    function unListing(uint256 tokenId) external;

    function rent(uint256 tokenId, uint256 timeRent) external payable;

    function rentExtension(uint256 tokenId, uint256 timeRent) external payable;

    function returnItem(uint256 tokenId) external;

    function batchReturnItem(uint256[] memory tokenIds) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./IERC165.sol";

interface IERCX {
    /**
     * @dev Emitted when `tokenId` token is locked.
     */
    event Lock(uint256 indexed tokenId, uint256 timeLock, uint256 timestamp);

    /**
     * @dev Emitted when `tokenId` token is unlocked.
     */
    event UnLock(uint256 indexed tokenId, uint256 timestamp);

    /**
     * @dev Emitted when `tokenId` token is change time life.
     */
    event ChangeTimeLife(
        uint256 indexed tokenId,
        uint256 timeLife,
        uint256 timestamp
    );

    /**
     * @dev Returns whether `tokenId` locked.
     *
     * See {lock}
     */
    function isLocked(uint256 tokenId) external view returns (bool);

    /**
     * @dev Change time life of token
     *
     * Requirements:
     *
     * - The executor must be on the allowed list
     * - `tokenId` must exist.
     *
     * Emits a {ChangeTimeLife} event.
     *
     * See {setWhileList}
     */
    function changeTimeLife(uint256 tokenId, uint256 timeLife) external;

    /**
     * @dev Lock `tokenId` token.
     *
     * Requirements:
     *
     * - The executor must be on the allowed list
     * - `tokenId` must exist.
     *
     * Emits a {Lock} event.
     *
     * See {setWhileList}
     */
    function lock(uint256 tokenId, uint256 timeLock) external;

    /**
     * @dev Unlock `tokenId` token.
     *
     * Requirements:
     *
     * - The executor must be on the allowed list
     * - `tokenId` must exist.
     *
     * Emits a {UnLock} event.
     *
     * See {setWhileList}
     */
    function unlock(uint256 tokenId) external;

    /**
     * @dev Safely mints `tokenId` and transfers it to `caller`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeMint(
        uint256 data,
        uint256 groupId,
        uint256 typeId,
        uint256 parentId,
        uint256 timeLife
    ) external returns (uint256);

    /**
     * @dev Mints `tokenId` and transfers it to `caller`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function mint(
        uint256 data,
        uint256 groupId,
        uint256 typeId,
        uint256 parentId,
        uint256 timeLife
    ) external returns (uint256);

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeMintTo(
        address to,
        uint256 data,
        uint256 groupId,
        uint256 typeId,
        uint256 parentId,
        uint256 timeLife
    ) external returns (uint256);

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function mintTo(
        address to,
        uint256 data,
        uint256 groupId,
        uint256 typeId,
        uint256 parentId,
        uint256 timeLife
    ) external returns (uint256);

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function batchSafeMint(
        uint256[] memory dataset,
        uint256[] memory groupIds,
        uint256[] memory typeIds,
        uint256[] memory parentIds,
        uint256[] memory timeLife
    ) external;

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function batchMint(
        uint256[] memory dataset,
        uint256[] memory groupIds,
        uint256[] memory typeIds,
        uint256[] memory parentIds,
        uint256[] memory timeLife
    ) external;

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function burn(uint256 tokenId) external;

    /**
     * @dev Returns the information of the `tokenId` token.
     */
    function getInfo(uint256 tokenId)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function exists(uint256 tokenId) external view returns (bool);

    /**
     * @dev Returns whether `tokenId` expired.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`) or time life expired.
     */
    function expired(uint256 tokenId) external view returns (bool);

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
    function safeTransferFromLockedToken(
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
    function transferFromLockedToken(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Mints `tokenId` from parent token and transfers it to `caller`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function clone(
        address to,
        uint256 parentId,
        uint256 timeLife
    ) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./IERC721.sol";

interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./IERC165.sol";

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

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
pragma solidity 0.8.9;

import "../utils/Ownable.sol";

contract ERCAccessControl is Ownable {
    event ChangeMinter(address indexed account, bool privileged);
    event ChangeDestroyer(address indexed account, bool privileged);
    event ChangeLocker(address indexed account, bool privileged);
    /**
     * @dev Emitted when change while list
     */
    event UpdateWhileList(address indexed operator, bool approved);

    mapping(address => bool) private _minters;
    mapping(address => bool) private _destroyer;
    // Mapping from address operator to permission lock token
    mapping(address => bool) private _locker;
    bool private _isPublicMint;
    bool private _isPublicDestroy;

    /**
     * @dev Initializes the contract.
     */
    constructor() {
        changeMinter(_msgSender(), true);
        changeDestroyer(_msgSender(), true);
    }

    modifier onlyMinter() {
        require(
            isMinter(_msgSender()),
            "ERCAccessControl: caller is not Minter"
        );
        _;
    }

    modifier onlyDestroyer() {
        require(
            isDestroyer(_msgSender()),
            "ERCAccessControl: caller is not Destroyer"
        );
        _;
    }

    modifier onlyLocker() {
        require(
            _locker[_msgSender()],
            "ERCAccessControl: caller is not Locker"
        );
        _;
    }

    /**
     * @dev Update the list of addresses with the right to execute lock token
     *
     * Emits a {UpdateWhileList} event.
     */
    function changeLocker(address operator, bool privileged)
        external
        onlyOwner
    {
        _locker[operator] = privileged;
        emit ChangeLocker(operator, privileged);
    }

    function setPublicMint(bool isMint) public virtual onlyOwner {
        _isPublicMint = isMint;
    }

    function setPublicDestroy(bool isDestroy) public virtual onlyOwner {
        _isPublicDestroy = isDestroy;
    }

    function isMinter(address account) public view returns (bool) {
        return _isPublicMint || _minters[account];
    }

    function isPublicDestroy() public view returns (bool) {
        return _isPublicDestroy;
    }

    function isPublicMint() public view returns (bool) {
        return _isPublicMint;
    }

    function changeMinter(address operator, bool privileged)
        public
        virtual
        onlyOwner
    {
        _minters[operator] = privileged;
        emit ChangeMinter(operator, privileged);
    }

    function isDestroyer(address account) public view returns (bool) {
        return _isPublicDestroy || _destroyer[account];
    }

    function changeDestroyer(address operator, bool privileged)
        public
        virtual
        onlyOwner
    {
        _destroyer[operator] = privileged;
        emit ChangeDestroyer(operator, privileged);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../utils/Context.sol";
import "./IERC721.sol";
import "./ERC165.sol";
import "./IERC721Metadata.sol";
import "../lib/Address.sol";
import "../lib/Strings.sol";
import "../utils/Context.sol";
import "./IERCX.sol";
import "../lib/Counters.sol";
import "./ERCAccessControl.sol";
import "./IERC721Receiver.sol";

contract ERC721 is
    Context,
    ERC165,
    IERC721,
    IERC721Metadata,
    IERCX,
    ERCAccessControl
{
    using Address for address;
    using Strings for uint256;
    using Counters for Counters.Counter;

    struct TokenInfo {
        uint256 data;
        uint256 groupId;
        uint256 typeId;
        uint256 parentId;
        uint256 rootId;
        uint256 treeCount;
        uint256 mintAt;
    }

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Generate tokenId
    Counters.Counter private _tokenId;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Mapping from token ID to locked time
    mapping(uint256 => uint256) private _locked;

    // Mapping from token ID to token info
    mapping(uint256 => TokenInfo) private _infos;

    // Mapping from token ID to token info
    mapping(uint256 => uint256) private _timeLife;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        require(!_expired(tokenId), "ERC721: owner query for expired token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        require(
            !_expired(tokenId),
            "ERC721Metadata: URI query for expired token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERCX-isLocked}.
     */
    function isLocked(uint256 tokenId)
        external
        view
        virtual
        override
        returns (bool)
    {
        require(
            _exists(tokenId),
            "IERCX: isLocked query for nonexistent token"
        );

        require(!_expired(tokenId), "IERCX: isLocked query for expired token");
        return _isLocked(tokenId);
    }

    /**
     * @dev See {IERCX-lock}.
     */
    function lock(uint256 tokenId, uint256 timeLock)
        external
        virtual
        override
        onlyLocker
    {
        require(_exists(tokenId), "IERCX: lock query for nonexistent token");
        require(!_expired(tokenId), "IERCX: lock query for expired token");
        require(
            timeLock == 0 || timeLock > block.timestamp,
            "IERCX: time lock more than current time"
        );
        _locked[tokenId] = timeLock;
        emit Lock(tokenId, timeLock, block.timestamp);
    }

    /**
     * @dev See {IERCX-unlock}.
     */
    function unlock(uint256 tokenId) external virtual override onlyLocker {
        require(_exists(tokenId), "IERCX: unlock query for nonexistent token");
        delete _locked[tokenId];
        emit UnLock(tokenId, block.timestamp);
    }

    /**
     * @dev See {IERCX-unlock}.
     */
    function changeTimeLife(uint256 tokenId, uint256 timeLife)
        external
        virtual
        override
        onlyLocker
    {
        require(
            _exists(tokenId),
            "IERCX: changeTimeLife query for nonexistent token"
        );
        require(
            !_expired(tokenId),
            "IERCX: changeTimeLife query for expired token"
        );
        require(
            timeLife > block.timestamp,
            "IERCX: time life less than current time"
        );
        _timeLife[tokenId] = timeLife;
    }

    /**
     * @dev See {IERCX-getInfo}.
     */
    function getInfo(uint256 tokenId)
        external
        view
        virtual
        override
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        TokenInfo memory tokenInfo = _infos[tokenId];
        uint256 lockedTime = _locked[tokenId];
        uint256 timeLife = _timeLife[tokenId];
        return (
            tokenInfo.data,
            tokenInfo.groupId,
            tokenInfo.typeId,
            tokenInfo.parentId,
            tokenInfo.rootId,
            tokenInfo.treeCount,
            tokenInfo.mintAt,
            lockedTime,
            timeLife
        );
    }

    /**
     * @dev See {IERCX-exists}.
     */
    function exists(uint256 tokenId)
        external
        view
        virtual
        override
        returns (bool)
    {
        return _exists(tokenId);
    }

    /**
     * @dev See {IERCX-expired}.
     */
    function expired(uint256 tokenId)
        external
        view
        virtual
        override
        returns (bool)
    {
        require(_exists(tokenId), "IERCX: expired query for nonexistent token");
        return _expired(tokenId);
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        require(!_expired(tokenId), "IERCX: approved query for expired token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev See {IERCX-safeMint}.
     */
    function safeMint(
        uint256 data,
        uint256 groupId,
        uint256 typeId,
        uint256 parentId,
        uint256 timeLife
    ) external virtual override onlyMinter returns (uint256) {
        uint256 id = _mint(data, groupId, typeId, parentId, timeLife);
        _safeMint(_msgSender(), id);
        return id;
    }

    /**
     * @dev See {IERCX-mint}.
     */
    function mint(
        uint256 data,
        uint256 groupId,
        uint256 typeId,
        uint256 parentId,
        uint256 timeLife
    ) external virtual override onlyMinter returns (uint256) {
        uint256 id = _mint(data, groupId, typeId, parentId, timeLife);
        _mint(_msgSender(), id);
        return id;
    }

    /**
     * @dev See {IERCX-safeMintTo}.
     */
    function safeMintTo(
        address to,
        uint256 data,
        uint256 groupId,
        uint256 typeId,
        uint256 parentId,
        uint256 timeLife
    ) external virtual override onlyMinter returns (uint256) {
        uint256 id = _mint(data, groupId, typeId, parentId, timeLife);
        _safeMint(to, id);
        return id;
    }

    /**
     * @dev See {IERCX-mintTo}.
     */
    function mintTo(
        address to,
        uint256 data,
        uint256 groupId,
        uint256 typeId,
        uint256 parentId,
        uint256 timeLife
    ) external virtual override onlyMinter returns (uint256) {
        uint256 id = _mint(data, groupId, typeId, parentId, timeLife);
        _mint(to, id);
        return id;
    }

    /**
     * @dev See {IERCX-batchSafeMint}.
     */
    function batchSafeMint(
        uint256[] memory dataset,
        uint256[] memory groupIds,
        uint256[] memory typeIds,
        uint256[] memory parentIds,
        uint256[] memory timeLife
    ) external virtual onlyMinter {
        require(
            dataset.length == groupIds.length,
            "IERCX: dataset and groupIds length mismatch"
        );
        require(
            dataset.length == typeIds.length,
            "IERCX: dataset and typeIds length mismatch"
        );
        require(
            dataset.length == parentIds.length,
            "IERCX: dataset and parentIds length mismatch"
        );
        require(
            dataset.length == parentIds.length,
            "IERCX: dataset and timeLife length mismatch"
        );
        for (uint256 i = 0; i < dataset.length; ++i) {
            _safeMint(
                _msgSender(),
                _mint(
                    dataset[i],
                    groupIds[i],
                    typeIds[i],
                    parentIds[i],
                    timeLife[i]
                )
            );
        }
    }

    /**
     * @dev See {IERCX-batchMint}.
     */
    function batchMint(
        uint256[] memory dataset,
        uint256[] memory groupIds,
        uint256[] memory typeIds,
        uint256[] memory parentIds,
        uint256[] memory timeLife
    ) external virtual onlyMinter {
        require(
            dataset.length == groupIds.length,
            "IERCX: dataset and groupIds length mismatch"
        );
        require(
            dataset.length == typeIds.length,
            "IERCX: dataset and typeIds length mismatch"
        );
        require(
            dataset.length == parentIds.length,
            "IERCX: dataset and parentIds length mismatch"
        );
        require(
            dataset.length == parentIds.length,
            "IERCX: dataset and timeLife length mismatch"
        );
        for (uint256 i = 0; i < dataset.length; ++i) {
            _mint(
                _msgSender(),
                _mint(
                    dataset[i],
                    groupIds[i],
                    typeIds[i],
                    parentIds[i],
                    timeLife[i]
                )
            );
        }
    }

    /**
     * @dev See {IERCX-safeMintTo}.
     */
    function burn(uint256 tokenId) external virtual override onlyDestroyer {
        _burn(tokenId);
    }

    /**
     * @dev See {IERCX-safeTransferFromLockedToken}.
     */
    function safeTransferFromLockedToken(
        address from,
        address to,
        uint256 tokenId
    ) external virtual override onlyLocker {
        delete _locked[tokenId];
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, "");
    }

    /**
     * @dev See {IERCX-transferFromLockedToken}.
     */
    function transferFromLockedToken(
        address from,
        address to,
        uint256 tokenId
    ) external virtual override onlyLocker {
        delete _locked[tokenId];
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERCX-clone}.
     */
    function clone(
        address to,
        uint256 parentId,
        uint256 timeLife
    ) external virtual override onlyMinter returns (uint256) {
        uint256 id = _mint(parentId, timeLife);
        _mint(to, id);
        return id;
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev See {IERCX-isLocked}.
     */
    function _isLocked(uint256 tokenId) internal view returns (bool) {
        return _locked[tokenId] != 0 && _locked[tokenId] > block.timestamp;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        require(!_isLocked(tokenId), "IERCX: burn query for locked token");
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];
        delete _locked[tokenId];
        delete _infos[tokenId];
        delete _timeLife[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(
            ERC721.ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );
        require(to != address(0), "ERC721: transfer to the zero address");
        require(!_isLocked(tokenId), "IERCX: transfer query for locked token");
        require(!_expired(tokenId), "IERCX: transfer query for expired token");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _mint(
        uint256 data,
        uint256 groupId,
        uint256 typeId,
        uint256 parentId,
        uint256 timeLife
    ) private returns (uint256) {
        _tokenId.increment();
        uint256 _id = _tokenId.current();
        if (parentId > 0) {
            require(
                _exists(parentId),
                "ERC721: mint child token for nonexistent token"
            );
            require(
                !_expired(parentId),
                "IERCX: mint child token for expired token"
            );
            TokenInfo memory _parentInfo = _infos[parentId];
            if (_parentInfo.parentId == 0) {
                _infos[_id] = TokenInfo(
                    data,
                    groupId,
                    typeId,
                    parentId,
                    parentId,
                    1,
                    block.timestamp
                );
            } else {
                _infos[_id] = TokenInfo(
                    data,
                    groupId,
                    typeId,
                    parentId,
                    _parentInfo.rootId,
                    _parentInfo.treeCount + 1,
                    block.timestamp
                );
            }
        } else {
            _infos[_id] = TokenInfo(
                data,
                groupId,
                typeId,
                0,
                0,
                0,
                block.timestamp
            );
        }
        if (timeLife != 0) {
            _timeLife[_id] = timeLife;
        }
        return _id;
    }

    function _mint(uint256 parentId, uint256 timeLife)
        private
        returns (uint256)
    {
        _tokenId.increment();
        uint256 _id = _tokenId.current();
        require(
            _exists(parentId),
            "ERC721: mint child token for nonexistent token"
        );
        require(
            !_expired(parentId),
            "IERCX: mint child token for expired token"
        );
        TokenInfo memory _parentInfo = _infos[parentId];
        _infos[_id] = TokenInfo(
            _parentInfo.data,
            _parentInfo.groupId,
            _parentInfo.typeId,
            parentId,
            _parentInfo.rootId,
            _parentInfo.treeCount + 1,
            block.timestamp
        );
        _timeLife[_id] = timeLife;
        return _id;
    }

    /**
     * @dev See {IERCX-expired}.
     */
    function _expired(uint256 tokenId) internal view returns (bool) {
        return _timeLife[tokenId] != 0 && _timeLife[tokenId] <= block.timestamp;
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./IERC165.sol";

abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../token/IBEP20.sol";
import "./Address.sol";

library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory out = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (out.length > 0) {
            require(
                abi.decode(out, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

library Address {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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