// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IBEP20.sol";
import "./interfaces/IERC721.sol";
import "./interfaces/AggregatorV3Interface.sol";

contract ShitNFTMarket is Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    IBEP20 public stcToken;
    IERC721 public stcNFT;
    AggregatorV3Interface internal priceFeed;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address payable devAddr;
    uint256 public tokenMintFeeUsd = 69; // $6.9 * 10
    uint256 public bnbMintFeeUsd = 10; // $10
    uint256 public bnbListingFee = 1; // $1
    uint256 public sellingFee = 42; // 4.2% = 4.2 * 10
    uint256 public tokenFee = 690;
    uint256 public bnbFee = 0.01 ether;

    struct NFT {
        address owner;
        uint256 price;
        uint256 sellingMethod; // 0 -> BNB, 1 -> Token.
        bool buyable;
    }
    mapping(uint256 => NFT) public nftHolders;

    event MINT_NFT(uint256 nftId, address minter);
    event SELL_NFT(uint256 nftId, address seller, uint256 price);
    event BUY_NFT(uint256 nftId, address buyer, uint256 amount);

    modifier onlyNFTOwner(uint256 nftId) {
        require(stcNFT.ownerOf(nftId) == msg.sender, "NFT: Not a owner.");
        _;
    }

    constructor(
        address _tokenAddr,
        address nftAddr,
        address _priceFeed,
        address payable _devAddr
    ) {
        stcToken = IBEP20(_tokenAddr);
        stcNFT = IERC721(nftAddr);
        priceFeed = AggregatorV3Interface(_priceFeed);
        tokenFee = tokenFee * (10**stcToken.decimals());
        devAddr = _devAddr;
    }

    function mintNFT(address to, string memory uri) public payable {
        uint256 reqBnbFee = usdToBnb(
            bnbMintFeeUsd.mul(10**priceFeed.decimals())
        );
        require(msg.value >= reqBnbFee, "Insufficient BNB");
        stcToken.transferFrom(msg.sender, DEAD, tokenFee);
        payable(devAddr).transfer(msg.value);

        uint256 tokenId = stcNFT.mint(to, uri);
        nftHolders[tokenId].owner = msg.sender;

        emit MINT_NFT(tokenId, msg.sender);
    }

    function sellNFT(
        uint256 _nftId,
        uint256 _price,
        uint256 _method
    ) public payable onlyNFTOwner(_nftId) {
        uint256 reqBnbFee = usdToBnb(
            bnbListingFee.mul(10**priceFeed.decimals())
        );
        require(msg.value >= reqBnbFee, "Insufficient BNB");
        require(
            !nftHolders[_nftId].buyable,
            "NFT: Already available for buying."
        );
        require(_method < 2, "NFT: Invalid method");
        payable(devAddr).transfer(msg.value);
        // stcToken.transferFrom(msg.sender, owner(), tokenFee);

        nftHolders[_nftId].price = _price;
        nftHolders[_nftId].sellingMethod = _method;
        nftHolders[_nftId].buyable = true;

        emit SELL_NFT(_nftId, msg.sender, _price);
    }

    function buyNFT(uint256 _nftId, uint256 _tokenAmount) public payable {
        require(nftHolders[_nftId].buyable, "NFT: Not available for buying.");
        if (nftHolders[_nftId].sellingMethod == 0) {
            require(
                msg.value >= nftHolders[_nftId].price,
                "NFT: Insufficient Amount."
            );
            uint256 _fee = msg.value.mul(sellingFee).div(100 * 10); // multipling with 10 for calculate 4.2 fee.
            devAddr.transfer(_fee);
            payable(nftHolders[_nftId].owner).transfer(msg.value.sub(_fee));
            emit BUY_NFT(_nftId, msg.sender, msg.value);
        } else {
            require(
                _tokenAmount >= nftHolders[_nftId].price,
                "NFT: Insufficient Amount."
            );
            stcToken.transferFrom(
                msg.sender,
                nftHolders[_nftId].owner,
                _tokenAmount
            );
            emit BUY_NFT(_nftId, msg.sender, _tokenAmount);
        }

        stcNFT.safeTransferFrom(nftHolders[_nftId].owner, msg.sender, _nftId);
        stcNFT.updateNFTOwners(nftHolders[_nftId].owner, msg.sender, _nftId);
        nftHolders[_nftId].buyable = false;
    }

    function getNFTData(uint256 _nftId)
        public
        view
        returns (
            address owner,
            uint256 price,
            uint256 sellingMethod,
            string memory tokenUri,
            bool isListed
        )
    {
        return (
            nftHolders[_nftId].owner,
            nftHolders[_nftId].price,
            nftHolders[_nftId].sellingMethod, // 0 -> BNB, 1 -> Token.
            stcNFT.tokenURI(_nftId),
            nftHolders[_nftId].buyable
        );
    }

    function updatePrice(uint256 _nftId, uint256 _price)
        public
        onlyNFTOwner(_nftId)
    {
        nftHolders[_nftId].price = _price;
    }

    function usdToBnb(uint256 usdAmount) public view returns (uint256) {
        return (usdAmount.mul(1e18)).div(getLatestPrice());
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    function updateFee(uint256 _bnbFee, uint256 _tokenFee) public onlyOwner {
        bnbFee = _bnbFee;
        tokenFee = _tokenFee;
    }

    function updatePriceFeed(address _priceFeed) public onlyOwner {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function updateDevelopmentAddr(address payable _addr) public onlyOwner {
        devAddr = _addr;
    }

    function updateToken(address _tokenAddr) public onlyOwner {
        stcToken = IBEP20(_tokenAddr);
    }

    function updateNft(address _nftAddr) public onlyOwner {
        stcNFT = IERC721(_nftAddr);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 {
    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function updateNFTOwners(
        address owner,
        address to,
        uint256 tokenId
    ) external;

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
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Gives mint new NFT to address.
     */
    function mint(address to, string memory uri) external returns (uint256);

    /**
     * @dev Gives NFT URI.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    /**
     * @dev Gives Last minted id.
     */
    function getLastNftId() external view returns (uint256);

    /**
     * @dev Returns the account approved for `tokenId` token.
     */
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
 * @dev Required interface of an ERC20 compliant contract.
 */
interface IBEP20 {
    function decimals() external view returns (uint8);

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

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

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