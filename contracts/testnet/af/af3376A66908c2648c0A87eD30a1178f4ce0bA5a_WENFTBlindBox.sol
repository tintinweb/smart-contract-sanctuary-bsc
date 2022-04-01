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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

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
pragma solidity 0.8.9;

// for IWENFTMintable
interface IWENFTMintable {
    // Admin use only
    function safeMint(address to, uint256 id, bytes calldata data) external;
    // Admin use only
    function safeMint(address to, uint256 id) external;
    function safeMintBatch(address to, uint256[] calldata ids, bytes calldata _data) external;
    function safeMintBatch(address[] calldata accounts, uint256[] calldata ids, bytes calldata _data) external;
    // Admin use only
    function mint(address to, uint256 id) external;
    function mintBatch(address to, uint256[] calldata ids) external;
    function mintBatch(address[] calldata accounts, uint256[] calldata ids) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./IWENFTMintable.sol";

/**
* @title WENFTBlindBox
* @dev A contract that sell WENFTBlindBox
* only whitelisted users can buy
* only one blindbox can buy per user
* sale time is between start and end time can buy
* use BNB price
*/
contract WENFTBlindBox is ReentrancyGuard, Ownable, Pausable {

    struct BlindBoxInfo {
        uint32 startTokenId;
        uint32 nextTokenId;
        uint32 endTokenId;
        uint256 price;
    }

    struct BlindBoxViewItem {
        uint32 totalCount;
        uint32 soldCount;
        uint256 price;
    }

    struct BlindBoxViewInfo {
        BlindBoxViewItem[] items;
        bool userInWhiteList;
        uint32 userAlreadyCount;
        uint32 maxEachUserBuyCount;
        uint64 startSellTime;
        uint64 endSellTime;
    }

    event BlindBoxOpened(
        address indexed _payer,
        uint8 _boxId,
        uint256 _tokenId,
        uint256 _price
    );

    event SellRoundParamChanged(
        uint64 _startSellTime,
        uint64 _endSellTime,
        uint32[] _startTokenIds,
        uint32[] _endTokenIds,
        bool _resetNextTokenId
    );

    event WhitelistAdded(
        address[] _accounts
    );

    event WhitelistRemoved(
        address[] _accounts
    );

    address payable public toWallet;
    IWENFTMintable public weNFT;
    uint64 public startSellTime;
    uint64 public endSellTime;
    BlindBoxInfo[] public blindBoxInfos;
    mapping(address => bool) public whitelistMapping;
    mapping(address => uint32) userAlreadyBuyCount;
    uint32 public maxEachUserBuyCount;


    constructor(address payable _toWallet, address _weNFT) {
        toWallet = _toWallet;
        weNFT = IWENFTMintable(_weNFT);
        modifyMaxEachUserBuyCount(5);
        // setupBlindBoxInfo(0, 1, 1651, 90000000000000000);
        // setupBlindBoxInfo(1, 1652, 2060, 460000000000000000);
        // setupBlindBoxInfo(2, 2061, 2500, 700000000000000000);
    }
    
    function setupBlindBoxInfo(uint8 _boxId, uint32 _startTokenId, uint32 _endTokenId, uint256 _price) private {
        BlindBoxInfo storage boxInfo = blindBoxInfos[_boxId];
        boxInfo.startTokenId = _startTokenId;
        boxInfo.nextTokenId = _startTokenId;
        boxInfo.endTokenId = _endTokenId;
        boxInfo.price = _price;
    }
    
    modifier whenBoxIdIsValid(uint8 boxId) {
        require(boxId < blindBoxInfos.length, "WENFTBlindBox: boxId is invalid.");
        _;
    }

    modifier whenCanBuy(address _account) {
        require(inWhitelist(_account), "WENFTBlindBox: You are not in the whitelist.");
        require(userAlreadyBuyCount[_account] < maxEachUserBuyCount, "WENFTBlindBox: You reach buy limit.");
        
        _;
    }

    modifier whenNotSoldOut(uint8 _boxId) {
        require(getLeftCount(_boxId) > 0, "WENFTBlindBox: This blind box is sold out.");
        _;
    }

    modifier whenInSaleTime() {
        require(startSellTime > 0 && block.timestamp >= startSellTime, "WENFTBlindBox: This blind box is not start sell.");
        require(block.timestamp <= endSellTime, "WENFTBlindBox: This blind box is end sell.");
        _;
    }
    
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function modifyMaxEachUserBuyCount(uint32 _maxEachUserBuyCount) public onlyOwner {
        require(_maxEachUserBuyCount > 0, "WENFTBlindBox: Max buy count must be greater than 0.");
        maxEachUserBuyCount = _maxEachUserBuyCount;
    }

    function modifyPrice(uint256[] calldata _prices) public onlyOwner {
        require(blindBoxInfos.length == _prices.length, "WENFTBlindBox: The length of price array is not equal to blind box infos length.");
        for (uint inx = 0; inx < blindBoxInfos.length; inx++) {
            blindBoxInfos[inx].price = _prices[inx];
        }
    }

    function modifyAllBlindBoxInfo(BlindBoxInfo[] calldata _infos) public onlyOwner {
        delete blindBoxInfos;
        for (uint inx = 0; inx < _infos.length; inx++) {
            BlindBoxInfo storage boxInfo = blindBoxInfos[inx];
            boxInfo.startTokenId = _infos[inx].startTokenId;
            boxInfo.nextTokenId = _infos[inx].nextTokenId;
            boxInfo.endTokenId = _infos[inx].endTokenId;
            boxInfo.price = _infos[inx].price;
        }
    }
    
    function modifySellTimeParam(
        uint64 _startSellTime,
        uint64 _endSellTime
    ) public onlyOwner {
        startSellTime = _startSellTime;
        endSellTime = _endSellTime;
    }

    function modifySellRoundParam(
        uint64 _startSellTime,
        uint64 _endSellTime,
        uint32[] calldata _startTokenIds,
        uint32[] calldata _endTokenIds,
        bool _resetNextTokenId
    ) public onlyOwner {
        require(_startSellTime > 0 && _endSellTime > 0, "WENFTBlindBox: Start sell time and end sell time must be greater than 0.");
        require(_startSellTime <= _endSellTime, "WENFTBlindBox: Start sell time must be less than end sell time.");
        require(_startTokenIds.length == _endTokenIds.length, "WENFTBlindBox: The length of startTokenIds and endTokenIds is not equal.");
        require(_startTokenIds.length == blindBoxInfos.length, "WENFTBlindBox: The length of startTokenIds and blindBoxInfos is not equal.");
        startSellTime = _startSellTime;
        endSellTime = _endSellTime;
        for (uint inx = 0; inx < blindBoxInfos.length; inx++) {
            blindBoxInfos[inx].startTokenId = _startTokenIds[inx];
            blindBoxInfos[inx].endTokenId = _endTokenIds[inx];
            if (_resetNextTokenId) {
                blindBoxInfos[inx].nextTokenId = _startTokenIds[inx];
            }
        }

        emit SellRoundParamChanged(startSellTime, endSellTime, _startTokenIds, _endTokenIds, _resetNextTokenId);
    }

    function addWhitelist(address[] memory _accounts) public onlyOwner {
        for (uint inx = 0; inx < _accounts.length; inx++) {
            require(!inWhitelist(_accounts[inx]), "WENFTBlindBox: This account is already in the whitelist.");
            whitelistMapping[_accounts[inx]] = true;
        }
        emit WhitelistAdded(_accounts);
    }

    function removeWhitelist(address[] memory _accounts) public onlyOwner {
        for (uint inx = 0; inx < _accounts.length; inx++) {
            require(inWhitelist(_accounts[inx]), "WENFTBlindBox: This account is not in the whitelist.");
            whitelistMapping[_accounts[inx]] = false;
        }
        emit WhitelistRemoved(_accounts);
    }

    function blindBoxInfosLength() public view returns (uint8) {
        return uint8(blindBoxInfos.length);
    }

    function inWhitelist(address _account) public view returns (bool) {
        return whitelistMapping[_account];
    }

    function getSoldCount(uint8 _boxId) public view whenBoxIdIsValid(_boxId) returns (uint32) {
        return blindBoxInfos[_boxId].nextTokenId - blindBoxInfos[_boxId].startTokenId;
    }

    function getTotalCount(uint8 _boxId) public view whenBoxIdIsValid(_boxId) returns (uint32) {
        return blindBoxInfos[_boxId].endTokenId - blindBoxInfos[_boxId].startTokenId + 1;
    }

    function getLeftCount(uint8 _boxId) public view whenBoxIdIsValid(_boxId) returns (uint32) {
        return blindBoxInfos[_boxId].endTokenId - blindBoxInfos[_boxId].nextTokenId + 1;
    }

    // return all blind box view info
    function getBlindBoxViewInfo(address account) public view returns (BlindBoxViewInfo memory) {
        BlindBoxViewItem[] memory items = new BlindBoxViewItem[](blindBoxInfos.length);
        for (uint inx = 0; inx < blindBoxInfos.length; inx++) {
            items[inx] = BlindBoxViewItem(
                getTotalCount(uint8(inx)),
                getSoldCount(uint8(inx)),
                blindBoxInfos[inx].price
            );
        }
        return BlindBoxViewInfo(
            items,
            inWhitelist(account),
            userAlreadyBuyCount[account],
            maxEachUserBuyCount,
            startSellTime,
            endSellTime
        );
    }

    function buy(uint8 _boxId) payable external
            whenNotPaused
            whenInSaleTime
            whenNotSoldOut(_boxId)
            whenCanBuy(msg.sender)
            nonReentrant {
        BlindBoxInfo storage info = blindBoxInfos[_boxId];
        require(msg.value == info.price, "WENFTBlindBox: You need to pay at least the price.");
        userAlreadyBuyCount[msg.sender]++;
        uint tokenId = info.nextTokenId;
        info.nextTokenId++;
        weNFT.safeMint(msg.sender, tokenId);
        toWallet.transfer(msg.value);
        emit BlindBoxOpened(msg.sender, _boxId, tokenId, info.price);
    }
}