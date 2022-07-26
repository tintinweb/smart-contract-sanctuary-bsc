// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ERC1155Presale.sol";

contract CreaturesPresale is ERC1155Presale {

    constructor(
        address _presaleERC1155,
        address payable _receiverOfEarnings
    ) ERC1155Presale(_presaleERC1155, _receiverOfEarnings) {
        prices[1] = 1 * 10 ** 18;
        prices[2] = 1 * 10 ** 18;
        prices[3] = 1 * 10 ** 18;
        prices[4] = 1 * 10 ** 18;
        prices[5] = 1 * 10 ** 18;
        prices[6] = 1 * 10 ** 18;
        prices[7] = 1 * 10 ** 18;
        prices[8] = 1 * 10 ** 18;
        prices[9] = 1 * 10 ** 18;
        prices[10] = 1 * 10 ** 18;
        prices[11] = 1 * 10 ** 18;
        prices[12] = 1 * 10 ** 18;
        prices[13] = 1 * 10 ** 18;
        prices[14] = 1 * 10 ** 18;

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



interface IMintableERC1155 {
    function mint(address account, uint256 id, uint256 amount, bytes memory data) external;
}

contract ERC1155Presale is ReentrancyGuard, Ownable {

    /**
     * @dev token_id => price mapping
     */
    mapping(uint256 => uint256) public prices;

    IMintableERC1155 public presaleERC1155;

    address payable public receiverOfEarnings;

    bool public paused;

    event PriceChange(uint256 tokenId, uint256 oldPrice, uint256 newPrice);
    event BoughtWithBNB(address buyer, uint256 tokenId, uint256 amount, uint256 price);

    /**
     * @dev Throws is the presale is paused
     */
    modifier notPaused() {
        require(!paused, "Presale is paused");
        _;
    }

    /**
     * @dev Throws is presale is NOT paused
     */
    modifier isPaused() {
        require(paused, "Presale is not paused");
        _;
    }

    /**
     * @param _presaleERC1155 address of the erc1155 to be purchased through presale
     * @param _receiverOfEarnings address of the wallet to be allowed to withdraw the proceeds
     */
    constructor(
        address _presaleERC1155,
        address payable _receiverOfEarnings
    ) {
        require(
            _receiverOfEarnings != address(0),
            "Receiver wallet cannot be 0"
        );
        receiverOfEarnings = _receiverOfEarnings;
        presaleERC1155 = IMintableERC1155(_presaleERC1155);
        paused = true; //@dev start as paused
    }

    /**
     * @notice Sets the address allowed to withdraw the proceeds from presale
     * @param _receiverOfEarnings address of the reveiver
     */
    function setReceiverOfEarnings(address payable _receiverOfEarnings)
        external
        onlyOwner
    {
        require(
            _receiverOfEarnings != receiverOfEarnings,
            "Receiver already configured"
        );
        require(_receiverOfEarnings != address(0), "Receiver cannot be 0");
        receiverOfEarnings = _receiverOfEarnings;
    }

    /**
     * @notice Sets new price for the presale token
     * @param _tokenId tokenId for which new price will be set
     * @param _price new price of the presale token
     */
    function setPrice(uint256 _tokenId, uint256 _price) external onlyOwner {
        uint256 price = prices[_tokenId];
        require(_price != price, "New price cannot be same");
        uint256 _oldPrice = price;
        prices[_tokenId] = _price;
        emit PriceChange(_tokenId, _oldPrice, _price);
    }

    /**
     * @notice Allows purchase of presale tokens using BNB
     * @param _tokenId tokenId to be bought
     * @param _amount amount of tokens to be bought
     */
    function buyNFTWithBNB(uint256 _tokenId, uint256 _amount)
        public
        payable
        notPaused
        nonReentrant
    {
        uint256 price = prices[_tokenId] * _amount;
        require(msg.value == price, "Incorrect BNB sent");
        presaleERC1155.mint(msg.sender, _tokenId, _amount, "0x000");
        payable(receiverOfEarnings).transfer(msg.value);
        emit BoughtWithBNB(msg.sender, _tokenId, _amount, msg.value);
    }

    /**
     * @notice Pauses the presale
     */
    function pause() external onlyOwner notPaused {
        paused = true;
    }

    /**
     * @notice Unpauses the presale
     */
    function unpause() external onlyOwner isPaused {
        paused = false;
    }
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