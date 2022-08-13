// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./interfaces/IGlowNft.sol";
import "./interfaces/ISaleDistributor.sol";

/**
 * @notice NFTSale contract
 */

contract NftSale is Ownable, ReentrancyGuard {
    // nft address
    address public nft;
    // when users buy, BNB is sent to this to distribute
    address public saleDistributor;

    uint256 public teamNftCount = 200; // 1~200
    uint256 public saleNftCount = 500; // 201~700
    uint256 public saleNftId = 200;
    uint256 public maxNftId = 10000;
    uint256 public teamMintId = 1;

    // first 500 NFTs are sold in this price
    uint256 public primarySalePrice;
    // the REST are sold in this price
    uint256 public secondarySalePrice;

    uint256 public saleStartTime;

    mapping(address => uint256[]) public userTokenIds;

    event NftPrimaryMinted(address user, uint256 tokenId, uint256 price);
    event NftSecondaryMinted(address user, uint256 tokenId, uint256 price);

    /**
     * @notice constructor
     *
     * @param _nft Nft address
     * @param _distributor Sale Distributor address
     * @param _startTime unix timestamp of sale start time
     */
    constructor(
        address _nft,
        address _distributor,
        uint256 _startTime
    ) {
        require(_nft != address(0), "Invalid nft");
        require(_distributor != address(0), "Invalid distributor");
        require(_startTime > block.timestamp, "Invalid startTime");

        nft = _nft;
        saleDistributor = _distributor;
        saleStartTime = _startTime;
    }

    /**
     * @notice setNft address, can be called by owner, only before sale starts
     *
     * @param _nft nft address
     */
    function setNft(address _nft) external onlyOwner {
        require(block.timestamp < saleStartTime, "Can't change");
        require(_nft != address(0), "Invalid nft");
        nft = _nft;
    }

    /**
     * @notice setSaleDistributor address, can be called by owner
     *
     * @param _distributor setSaleDistributor address
     */
    function setSaleDistributor(address _distributor) external onlyOwner {
        require(_distributor != address(0), "Invalid distributor");
        saleDistributor = _distributor;
    }

    /**
     * @notice setStartTime, can be called by owner, only before sale starts
     *
     * @param _startTime new start timestamp
     */
    function setStartTime(uint256 _startTime) external onlyOwner {
        require(block.timestamp < saleStartTime, "Can't change");
        require(_startTime > block.timestamp, "Invalid startTime");
        saleStartTime = _startTime;
    }

    /**
     * @notice setPrices, can be called by owner
     *
     * @param _primary primarySalePrice
     * @param _secondary secondarySalePrice
     */
    function setPrices(uint256 _primary, uint256 _secondary) external onlyOwner {
        primarySalePrice = _primary;
        secondarySalePrice = _secondary;
    }

    /**
     * @notice mintNfts
     *
     * @param count nft count
     */
    function mintNfts(uint256 count) external payable nonReentrant {
        uint256 totalPrice;
        uint256 mintedCount;

        for (uint256 index = 0; index < count && saleNftId <= maxNftId; index++) {
            IGlowNft(nft).safeMint(msg.sender, 1);

            if (saleNftId <= teamNftCount + saleNftCount) {
                totalPrice += primarySalePrice;
                mintedCount++;
                emit NftPrimaryMinted(msg.sender, 1, primarySalePrice);
                userTokenIds[msg.sender].push(saleNftId);
            } else {
                totalPrice += secondarySalePrice;
                mintedCount++;
                emit NftSecondaryMinted(msg.sender, 1, secondarySalePrice);
                userTokenIds[msg.sender].push(saleNftId);
            }

            saleNftId++;
        }

        require(msg.value >= totalPrice, "Insufficient BNB");

        if (msg.value > totalPrice) {
            // refund
            msg.sender.call{ value: msg.value - totalPrice }("");
        }

        ISaleDistributor(saleDistributor).distribute{ value: totalPrice }(msg.sender);
    }

    function getUserTokenCount(address user) external view returns (uint256) {
        return userTokenIds[user].length;
    }

    function getUserTokenIds(address user) external view returns (uint256[] memory ids) {
        uint256 count = userTokenIds[user].length;
        ids = new uint256[](count);

        for (uint256 index = 0; index < count; index++) {
            ids[index] = userTokenIds[user][index];
        }
    }

    function getUserTokenSubIds(
        address user,
        uint256 start,
        uint256 end
    ) external view returns (uint256[] memory ids) {
        uint256 count = userTokenIds[user].length;

        uint256 realEnd = end;
        if (count < realEnd) {
            realEnd = count;
        }
        require(start < realEnd, "Invalid");
        count = realEnd - start;

        ids = new uint256[](count);

        for (uint256 index = 0; index < count; index++) {
            ids[index] = userTokenIds[user][start + index];
        }
    }
}

// SPDX-License-Identifier: MIT

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
    constructor () {
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

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

    constructor () {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IGlowNft {
    function safeMint(address to, uint256 quantity) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ISaleDistributor {
    function distribute(address buyer) external payable;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}