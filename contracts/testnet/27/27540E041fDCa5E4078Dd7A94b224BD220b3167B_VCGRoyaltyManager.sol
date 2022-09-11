// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IRoyaltyManager.sol";
import "./interfaces/IVCGNFT.sol";

contract VCGRoyaltyManager is IRoyaltyManager, Ownable {
    using SafeMath for uint256;

    address public marketplace;
    address public vcgNFT1155;
    address public vcgNFT721;

    uint256 immutable MAX_ROYALTY = 2000; // 20%

    constructor(address _marketplace) {
        setupMarketPlace(_marketplace);
    }

    modifier onlyCollectionOwner(address collectionAddress) {
        require(
            msg.sender == Ownable(collectionAddress).owner(),
            "VCGRoyaltyManager: not collection owner"
        );
        _;
    }

    modifier onlyMarketPlace() {
        require(
            msg.sender == marketplace,
            "VCGRoyaltyManager: not marketplace contract"
        );
        _;
    }

    modifier maxRoyalty(uint256 royalty) {
        require(royalty <= MAX_ROYALTY, "VCGRoyaltyManager: max royalty 20%");
        _;
    }

    mapping(address => CollectionInfo) collectionsInfo; // collection  => collectionInfo
    mapping(address => mapping(uint => CollectionInfo)) mainCollectionsInfo; // collection  => collectionInfo
    mapping(address => mapping(address => uint256)) collectionsRoyalty; // collection => ERC address => amount royalties
    mapping(address => mapping(uint => mapping(address => uint))) collectionVCGRoyalties; // collection => tokenId => ERC address => amount

    function setInfo(
        address collectionAddress,
        uint256 royalty,
        address taker
    ) public onlyCollectionOwner(collectionAddress) maxRoyalty(royalty) {
        collectionsInfo[collectionAddress] = CollectionInfo(royalty, taker);
    }

    function setInfoVCG(
        address collectionAddress,
        uint256 royalty,
        uint tokenId
    ) public maxRoyalty(royalty) {
        require(
            collectionAddress == vcgNFT1155 || collectionAddress == vcgNFT721,
            "VCGRoyaltyManager: not vcg main nft token"
        );
        address creator = IVCGNFT(collectionAddress).getCreator(tokenId);
        require(creator == msg.sender, "VCGRoyaltyManager: not token creator");
        mainCollectionsInfo[collectionAddress][tokenId] = CollectionInfo(
            royalty,
            creator
        );
    }

    function getCollectionRoyaltyInfo(address collectionAddress)
        external
        view
        returns (CollectionInfo memory)
    {
        return collectionsInfo[collectionAddress];
    }

    function getMainCollectionRoyaltyInfo(address collectionAddress, uint nftId)
        external
        view
        returns (CollectionInfo memory)
    {
        return mainCollectionsInfo[collectionAddress][nftId];
    }

    function addRoyalty(
        address collectionAddress,
        uint256 sellAmount,
        address _token,
        uint _nftId
    ) external onlyMarketPlace returns (uint256 royaltyFee) {
        if (collectionAddress == vcgNFT1155 || collectionAddress == vcgNFT721) {
            royaltyFee = sellAmount.div(10000).mul(
                mainCollectionsInfo[collectionAddress][_nftId].collectionRoyalty
            );

            collectionVCGRoyalties[collectionAddress][_nftId][
                _token
            ] = collectionVCGRoyalties[collectionAddress][_nftId][_token].add(
                royaltyFee
            );
        } else {
            royaltyFee = sellAmount.div(10000).mul(
                collectionsInfo[collectionAddress].collectionRoyalty
            );

            collectionsRoyalty[collectionAddress][_token] = collectionsRoyalty[
                collectionAddress
            ][_token].add(royaltyFee);
        }
    }

    function withdrawRoyalty(
        address collectionAddress,
        address _token,
        uint256 _nftId
    ) external onlyMarketPlace returns (uint256 totalRoyalty) {
        if (collectionAddress == vcgNFT1155 || collectionAddress == vcgNFT721) {
            totalRoyalty = collectionVCGRoyalties[collectionAddress][_nftId][
                _token
            ];
            require(totalRoyalty > 0, "VCGRoyaltyManager: royalty 0");

            collectionVCGRoyalties[collectionAddress][_nftId][_token] = 0;
        } else {
            totalRoyalty = collectionsRoyalty[collectionAddress][_token];
            require(totalRoyalty > 0, "VCGRoyaltyManager: royalty 0");

            collectionsRoyalty[collectionAddress][_token] = 0;
        }
    }

    function setupMarketPlace(address _marketplace) public onlyOwner {
        marketplace = _marketplace;
    }

    function setupVCGToken(address _vcgNFT1155, address _vcgNFT721)
        public
        onlyOwner
    {
        vcgNFT1155 = _vcgNFT1155;
        vcgNFT721 = _vcgNFT721;
    }

    function checkVCGNFT(address _collection) public view returns (bool) {
        return _collection == vcgNFT1155 || _collection == vcgNFT721;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRoyaltyManager {
    struct CollectionInfo {
        uint256 collectionRoyalty;
        address collectionTaker;
    }

    function getCollectionRoyaltyInfo(address collectionAddress)
        external
        view
        returns (CollectionInfo memory);

    function getMainCollectionRoyaltyInfo(address collectionAddress, uint nftId)
        external
        view
        returns (CollectionInfo memory);

    function addRoyalty(
        address collectionAddress,
        uint256 sellAmount,
        address _token,
        uint _nftId
    ) external returns (uint256);

    function withdrawRoyalty(
        address collectionAddress,
        address _token,
        uint256 _nftId
    ) external returns (uint256);

    function checkVCGNFT(address _collection) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IVCGNFT {
    function getCreator(uint256 _tokenId) external view returns (address);
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