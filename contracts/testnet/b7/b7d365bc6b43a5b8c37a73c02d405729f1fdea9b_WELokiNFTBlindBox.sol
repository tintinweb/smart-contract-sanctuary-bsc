/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// Sources flattened with hardhat v2.9.0 https://hardhat.org

// File @openzeppelin/contracts/security/[email protected]

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/security/[email protected]

// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

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


// File contracts/WELokiNFTBlindBox/IERC721Mintable.sol

pragma solidity 0.8.9;

// for IERC721Mintable
interface IERC721Mintable {
    // Admin use only
    function safeMint(address to, uint256 id, bytes memory data) external;
    // Admin use only
    function safeMint(address to, uint256 id) external;
    // Admin use only
    function mint(address to, uint256 id) external;
}


// File contracts/WELokiNFTBlindBox/WELokiNFTBlindBox.sol

pragma solidity 0.8.9;




/**
* @title WELokiNFTBlindBox
* @dev A contract that sell WELokiNFTBlindBox
* only whitelisted users can buy
* only one blindbox can buy per user
* sale time is between start and end time can buy
* use BNB price
*/
contract WELokiNFTBlindBox is ReentrancyGuard, Ownable, Pausable {
    enum EAccountState {
        NotInWhitelist,
        InWhitelistNotBuy,
        InWhitelistHasBuy
    }
    
    struct BlindBoxViewInfo {
        uint32 totalCount;
        uint32 soldCount;
        uint256 price;
    }

    event BlindBoxOpened(
        address indexed _payer,
        uint256 _tokenId,
        uint256 _price
    );

    event PriceChanged(
        uint256 _price
    );

    event SellRoundParamChanged(
        uint64 _startSellTime,
        uint64 _endSellTime,
        uint32 _startTokenId,
        uint32 _endTokenId,
        bool _resetNextTokenId
    );

    event WhitelistAdded(
        address[] _accounts
    );

    event WhitelistRemoved(
        address[] _accounts
    );

    address payable public toWallet;
    IERC721Mintable public lokiNFT;
    uint64 public startSellTime;
    uint64 public endSellTime;
    uint32 public startTokenId;
    uint32 public endTokenId;
    uint256 public price;
    uint32 public nextTokenId;

    mapping(address => uint8) public accountInfoMapping;

    constructor(address payable _toWallet, address _lokiNFT, uint256 _price) {
        toWallet = _toWallet;
        lokiNFT = IERC721Mintable(_lokiNFT);
        price = _price;
    }

    modifier whenCanBuy(address _account) {
        require(!hasBuy(_account), "WELokiNFTBlindBox: You have already bought this blind box.");
        require(inWhitelist(_account), "WELokiNFTBlindBox: You are not in the whitelist.");
        _;
    }

    modifier whenNotSoldOut() {
        require(getLeftCount() > 0, "WELokiNFTBlindBox: This blind box is sold out.");
        _;
    }

    modifier whenInSaleTime() {
        require(startSellTime > 0 && block.timestamp >= startSellTime, "WELokiNFTBlindBox: This blind box is not start sell.");
        require(block.timestamp <= endSellTime, "WELokiNFTBlindBox: This blind box is end sell.");
        _;
    }
    
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function modifyPrice(uint256 _price) public onlyOwner {
        price = _price;
        emit PriceChanged(price);
    }

    function modifySellRoundParam(
        uint64 _startSellTime,
        uint64 _endSellTime,
        uint32 _startTokenId,
        uint32 _endTokenId,
        bool _resetNextTokenId
    ) public onlyOwner {
        startSellTime = _startSellTime;
        endSellTime = _endSellTime;
        startTokenId = _startTokenId;
        endTokenId = _endTokenId;
        if (_resetNextTokenId) {
            nextTokenId = startTokenId;
        }
        emit SellRoundParamChanged(startSellTime, endSellTime, startTokenId, endTokenId, _resetNextTokenId);
    }

    function addWhitelist(address[] memory _accounts) public onlyOwner {
        for (uint inx = 0; inx < _accounts.length; inx++) {
            require(accountInfoMapping[_accounts[inx]] == uint8(EAccountState.NotInWhitelist), "WELokiNFTBlindBox: This account is already in the whitelist.");
            accountInfoMapping[_accounts[inx]] = uint8(EAccountState.InWhitelistNotBuy);
        }
        emit WhitelistAdded(_accounts);
    }

    function removeWhitelist(address[] memory _accounts) public onlyOwner {
        for (uint inx = 0; inx < _accounts.length; inx++) {
            require(accountInfoMapping[_accounts[inx]] == uint8(EAccountState.InWhitelistNotBuy), "WELokiNFTBlindBox: This account is not in the whitelist.");
            accountInfoMapping[_accounts[inx]] = uint8(EAccountState.NotInWhitelist);
        }
        emit WhitelistRemoved(_accounts);
    }

    function inWhitelist(address _account) public view returns (bool) {
        return accountInfoMapping[_account] == uint8(EAccountState.InWhitelistNotBuy) ||
            accountInfoMapping[_account] == uint8(EAccountState.InWhitelistHasBuy);
    }

    function hasBuy(address _account) public view returns (bool) {
        return accountInfoMapping[_account] == uint8(EAccountState.InWhitelistHasBuy);
    }

    function canBuy(address _account) public view returns (bool) {
        return accountInfoMapping[_account] == uint8(EAccountState.InWhitelistNotBuy);
    }

    function getSoldCount() public view returns (uint32) {
        return nextTokenId - startTokenId;
    }

    function getTotalCount() public view returns (uint32) {
        return endTokenId - startTokenId + 1;
    }

    function getLeftCount() public view returns (uint32) {
        return endTokenId - nextTokenId + 1;
    }

    // return all blind box view info
    function getBlindBoxViewInfo() public view returns (BlindBoxViewInfo memory) {
        return BlindBoxViewInfo(
            getTotalCount(),
            getSoldCount(),
            price
        );
    }

    function buy() payable external whenNotPaused whenInSaleTime whenNotSoldOut whenCanBuy(msg.sender) nonReentrant {
        require(msg.value >= price, "WELokiNFTBlindBox: You need to pay at least the price.");
        accountInfoMapping[msg.sender] = uint8(EAccountState.InWhitelistHasBuy);
        uint tokenId = nextTokenId;
        nextTokenId++;
        lokiNFT.safeMint(msg.sender, tokenId);
        toWallet.transfer(msg.value);
        emit BlindBoxOpened(msg.sender, tokenId, price);
    }
}