/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

/***
 * 
 * 
 *    ▄████████  ▄█   ▄█        ▄█       ▄██   ▄      ▄████████    ▄█    █▄       ▄████████    ▄████████    ▄███████▄
 *   ███    ███ ███  ███       ███       ███   ██▄   ███    ███   ███    ███     ███    ███   ███    ███   ███    ███
 *   ███    █▀  ███▌ ███       ███       ███▄▄▄███   ███    █▀    ███    ███     ███    █▀    ███    █▀    ███    ███
 *   ███        ███▌ ███       ███       ▀▀▀▀▀▀███   ███         ▄███▄▄▄▄███▄▄  ▄███▄▄▄      ▄███▄▄▄       ███    ███
 * ▀███████████ ███▌ ███       ███       ▄██   ███ ▀███████████ ▀▀███▀▀▀▀███▀  ▀▀███▀▀▀     ▀▀███▀▀▀     ▀█████████▀
 *          ███ ███  ███       ███       ███   ███          ███   ███    ███     ███    █▄    ███    █▄    ███
 *    ▄█    ███ ███  ███▌    ▄ ███▌    ▄ ███   ███    ▄█    ███   ███    ███     ███    ███   ███    ███   ███
 *  ▄████████▀  █▀   █████▄▄██ █████▄▄██  ▀█████▀   ▄████████▀    ███    █▀      ██████████   ██████████  ▄████▀
 *                   ▀         ▀
 *
 * https://sillysheep.io
 * MIT License
 * ===========
 *
 * Copyright (c) 2022 sillysheep
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/// File: @chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

// File: @chainlink/contracts/src/v0.8/VRFRequestIDBase.sol


pragma solidity ^0.8.0;

contract VRFRequestIDBase {
  /**
   * @notice returns the seed which is actually input to the VRF coordinator
   *
   * @dev To prevent repetition of VRF output due to repetition of the
   * @dev user-supplied seed, that seed is combined in a hash with the
   * @dev user-specific nonce, and the address of the consuming contract. The
   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in
   * @dev the final seed, but the nonce does protect against repetition in
   * @dev requests which are included in a single block.
   *
   * @param _userSeed VRF seed input provided by user
   * @param _requester Address of the requesting contract
   * @param _nonce User-specific nonce at the time of the request
   */
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  ) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  /**
   * @notice Returns the id for this request
   * @param _keyHash The serviceAgreement ID to be used for this request
   * @param _vRFInputSeed The seed to be passed directly to the VRF
   * @return The id for this request
   *
   * @dev Note that _vRFInputSeed is not the seed passed by the consuming
   * @dev contract, but the one generated by makeVRFInputSeed
   */
  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

// File: contracts/chainlink/VRFConsumerBaseUpgradableV2.sol

pragma solidity ^0.8.0;


abstract contract VRFConsumerBaseUpgradableV2 {
    
    address private vrfCoordinator;
    // Flag of initialize data
    bool private initialized;

    // replaced constructor with initializer <--
    function vrfInitialize(address _vrfCoordinator) public {
        require(!initialized, "vrfInitialize: Already initialized!");
        vrfCoordinator = _vrfCoordinator;
        
        initialized = true;
    }


  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    require(msg.sender == vrfCoordinator, "OnlyCoordinatorCanFulfill");
    fulfillRandomWords(requestId, randomWords);
  }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: @openzeppelin/contracts/utils/cryptography/MerkleProof.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

// File: contracts/interface/IPlayerBook.sol

pragma solidity ^0.8.0;


interface IPlayerBook {

    function settleReward( address from,uint256 amount ) external returns (uint256);
    function bindRefer( address from,string calldata  affCode )  external returns (bool);
    function hasRefer(address from) external returns(bool);
    
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

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

// File: contracts/interface/ISheep.sol

pragma solidity ^0.8.0;


interface ISheep is IERC721 {

    struct SheepInfo {
        uint256 level;
        uint256 earnSpeed;
        bool bellwether;
        uint256 rechargeTimes;
    }
    
    function increaseLives(uint256 _sheepId) external;

    function getSheepInfo(uint256 _sheepId)
        external view returns(SheepInfo memory info);
    
    function mint(
        address to,
        SheepInfo calldata _info)
        external returns(uint256);

    function burn(uint256 _sheepId) external;
}

// File: contracts/interface/ISheepProp.sol

pragma solidity ^0.8.0;


interface ISheepProp {

    struct PropInfo {
        uint256 propType; // 1, 2, 3
        uint256 rechargeTimes;
    }
    
    function increaseProp(uint256 _propId, uint256 times) external;

    function getPropInfo(uint256 _propId)
        external view returns(PropInfo memory info);
    
    function mint(
        address to,
        PropInfo calldata _info)
        external returns(uint256);

    function burn(uint256 _propId) external;
}

// File: contracts/opensell/SheepOpenSell.sol


pragma solidity ^0.8.0;

// import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";







contract SheepOpenSell is Ownable, VRFConsumerBaseUpgradableV2, ReentrancyGuard {
    using SafeMath for uint256;
    bool private initialized;
    uint private seed;

    VRFCoordinatorV2Interface vrfCoordinator;
    uint64 subscriptionId;
    bytes32 keyHash;
    uint32 callbackGasLimit;
    
    address public playerBook;

    // reqId -> type [1.gold sheep  2.bellwether 3.silver sheep]
    mapping(uint256 => uint256) public getTypeByReqId;

    mapping(uint256 => address) public buyerByReqId;
    mapping(uint256 => uint32) public amountByReqId;
    mapping(uint256 => bool) public mintByReqId;
    mapping(uint256 => uint256) public indexByReqId;

    ISheep public sheep;
    ISheepProp public prop;
    
    uint256 public sheepStartTime;
    uint256 public propStartTime;
    uint256 public bellwetherStartTime;
    uint256 public sheepUnitPrice;
    uint256 public sheepSellAmount;
    uint32 public sheepSingleMaxSell;
    uint256 public sheepIn;

    uint256[] public propTypeUnitPrice; // index:0 -> type1 price
    uint256 public propIn;
    
    // type -> amount
    mapping(uint256 => uint256) public propSellAmount;

    uint256 public bellwetherPrice;
    uint256 public bellwetherIn;

    // claimType => root [1. silver 2. gold]
    mapping (uint256 => bytes32) public merkleRoot;
    // bytes32 goldWhitelistRoot;
    // bytes32 silverWhitelistRoot;

    // sheepType -> address -> bool
    mapping(uint256 => mapping(address => bool)) public claimed;

    // sheepType -> address -> bool
    mapping(uint256 => mapping(address => bool)) public whitelists;

    mapping (address => bool) claimPool;

    event BuySheep(address indexed buyer, uint256 amount, uint256 value, uint256 requestId);
    event BuyBellwether(address indexed buyer, uint256 amount, uint256 value, uint256 requestId);
    
    event ClaimSheep(address indexed sender, uint256 sheepType, uint256 requestId);
    event ReceiveSheepResult(uint256 indexed requestId, address buyer, uint256 sheepId, uint256 level, bool bellwether);

    event Withdraw(address indexed devAddress, uint256 balance);
    event BuyProp(address indexed buyer, uint256 propType, uint256 propId);
    event GiveProp(address indexed receiver, uint256 propType, uint256 propId);
    event UpdatePropPrice(uint256[] typePrices);

    event UpdatePrice(uint256 sheepUnitPrice, uint256 bellwetherPrice);
    event UpdateStartTime(uint256 sheepStartTime, uint256 propStartTime, uint256 bellwetherStartTime);

    event UpdateSheepSingleMaxSell(uint32 sheepSingleMaxSell);
    event UpdateWhitelist(uint256 sheepType, bytes32 _whitelistRoot);

    event AddWhitelist(uint256 sheepType, address player);
    event UpdateClaimPool(address pool, bool tag);

    function initialize(
        address _owner,
        address _vrfCoordinator,
        uint64 _subscriptionId,
        bytes32 _keyHash,
        uint32 _callbackGasLimit
    ) external {
        require(!initialized, "initialize: Already initialized!");
        _transferOwnership(_owner);
        
        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        VRFConsumerBaseUpgradableV2.vrfInitialize(
            _vrfCoordinator
        );
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        callbackGasLimit = _callbackGasLimit;
        initialized = true;
    }

    function setStart(
        address _sheep,
        uint256 _sheepStartTime,
        uint256 _propStartTime,
        uint256 _sheepUnitPrice,
        uint256 _bellwetherPrice,
        address _prop,
        uint32 _sheepSingleMaxSell, 
        address _playerBook) external onlyOwner {
        sheep = ISheep(_sheep);
        sheepStartTime = _sheepStartTime;
        propStartTime = _propStartTime;
        sheepUnitPrice = _sheepUnitPrice;
        bellwetherPrice = _bellwetherPrice;
        prop = ISheepProp(_prop);
        sheepSingleMaxSell = _sheepSingleMaxSell;
        playerBook = _playerBook;
    }

    function buySheep(uint32 amount, string memory affCode) 
    external virtual payable nonReentrant returns(uint256) {
        require(amount <= sheepSingleMaxSell, "Up to 10 at a time!!!");
        require(block.timestamp >= sheepStartTime, "no start!!!");
        uint256 price = uint256(amount).mul(sheepUnitPrice);
        require(msg.value >= price, "Value is too low!!!");
        
        if (!IPlayerBook(playerBook).hasRefer(msg.sender)) {
            IPlayerBook(playerBook).bindRefer(msg.sender, affCode);
        }
        uint256 requestId = _getSheepRandomWords(amount, msg.sender, 1);
        sheepIn = sheepIn.add(price);
        sendPropNft(amount, msg.sender);
        emit BuySheep(msg.sender, amount, msg.value, requestId);
        return requestId;
    }

    function buyProp(uint256[] memory _propTypes, string memory affCode) external payable nonReentrant {
        require(block.timestamp >= propStartTime, "no start!!!");
        uint256 price = 0;
        for (uint256 i = 0; i < _propTypes.length; i++) {
            uint256 _propType = _propTypes[i];
            require(_propType > 0 && _propType < 4 ,"type error!!!");
            uint256 unitPrice = propTypeUnitPrice[_propType-1];
            price = price.add(unitPrice);
            ISheepProp.PropInfo memory info;
            info.propType = _propType;
            info.rechargeTimes = 2;
            uint256 propId = prop.mint(msg.sender, info);
            propSellAmount[_propType]++;
            propIn = propIn.add(price);
            emit BuyProp(msg.sender, _propType, propId);
        }
        require(msg.value >= price, "Value is too low!!!");
        if (!IPlayerBook(playerBook).hasRefer(msg.sender)) {
            IPlayerBook(playerBook).bindRefer(msg.sender, affCode);
        }
    }

    function buyBellwether(uint32 amount, string memory affCode) external payable nonReentrant returns(uint256){
        require(amount <= sheepSingleMaxSell, "Up to 10 at a time!!!");
        require(block.timestamp >= bellwetherStartTime, "no start!!!");
        uint256 price = uint256(amount).mul(bellwetherPrice);
        require(msg.value >= price, "Value is too low!!!");
        if (!IPlayerBook(playerBook).hasRefer(msg.sender)) {
            IPlayerBook(playerBook).bindRefer(msg.sender, affCode);
        }

        uint256 requestId = _getSheepRandomWords(amount, msg.sender, 2);
        
        bellwetherIn = bellwetherIn.add(price);
        emit BuyBellwether(msg.sender, amount, msg.value, requestId);
        return requestId;
    }

    // sheepType 1-> silver, 2-> gold
    function claimSheep(
        uint256 sheepType, 
        uint256 addressId, 
        bytes32[] memory merkleProof, 
        string memory affCode) external nonReentrant {
        require(sheepType == 1 || sheepType == 2, "type mismatch");
        require(!claimed[sheepType][msg.sender],"Already claimed!");

        if (!IPlayerBook(playerBook).hasRefer(msg.sender)) {
            IPlayerBook(playerBook).bindRefer(msg.sender, affCode);
        }
        
        bool canClaim = false;
        bytes32 node = keccak256(abi.encodePacked(addressId, msg.sender));
        bytes32 _merkleRoot = merkleRoot[sheepType];
        if (MerkleProof.verify(merkleProof, _merkleRoot, node)) {
            canClaim = true;
        } else if (whitelists[sheepType][msg.sender]){
            canClaim = true;
        }
        require(canClaim, "sender can not claim!!");
        claimed[sheepType][msg.sender] = true;

        uint256 requestId;
        if (sheepType == 2) {
            requestId = _getSheepRandomWords(1, msg.sender, 1);
        } else if (sheepType == 1) {
            requestId = 0;// _getSheepRandomWords(1, msg.sender, 3);
            seed = uint256(keccak256(
                abi.encodePacked(seed, msg.sender)));
            uint256[] memory randoms = new uint256[](1);
            randoms[0] = seed;
            handleSilverSheepResult(msg.sender, 1, requestId, randoms);
        }
        emit ClaimSheep(msg.sender, sheepType, requestId);
    }
    
    function getSheepRandomWords(
        uint32 amount,
        address receiver,
        uint256 getType
        ) public returns(uint256 requestId) {
        require(claimPool[msg.sender],"No permission!");
        requestId = _getSheepRandomWords(amount, receiver, getType);
    }

    function _getSheepRandomWords(
        uint32 amount,
        address receiver,
        uint256 getType
        ) internal returns(uint256 requestId) {
        requestId = vrfCoordinator.requestRandomWords(
                keyHash,
                subscriptionId,
                3,
                callbackGasLimit,
                amount
        );
        buyerByReqId[requestId] = receiver;
        amountByReqId[requestId] = amount;
        mintByReqId[requestId] = false;
        getTypeByReqId[requestId] = getType;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        mintByReqId[requestId] = true;

        address buyer = buyerByReqId[requestId];
        uint32 amount = amountByReqId[requestId];

        if (getTypeByReqId[requestId] == 1) {// gold sheep
            handleGoldSheepResult(buyer, amount, requestId, randomWords);
        } else if (getTypeByReqId[requestId] == 2){ // bellwether
            for (uint256 i = 0; i < amount; i++) {
                uint256 earnBaseSpeed = 102900+16500;
                uint256 random = randomWords[i];
                uint256 section = 10300;
                uint256 speed = random.mod(section);
                uint256 earnSpeed = earnBaseSpeed.add(speed);

                ISheep.SheepInfo memory sheepInfo;
                sheepInfo.level = 4;
                sheepInfo.earnSpeed = earnSpeed;
                sheepInfo.bellwether = true;
                sheepInfo.rechargeTimes = 1;
                uint256 sheepId = sheep.mint(buyer, sheepInfo);
                emit ReceiveSheepResult(requestId, buyer, sheepId, 4, true);
            }
        }else if  (getTypeByReqId[requestId] == 3){// silver sheep
            handleSilverSheepResult(buyer, amount, requestId, randomWords);
        }
    }

    function handleGoldSheepResult(
        address buyer,
        uint256 amount,
        uint256 requestId,
        uint256[] memory randomWords) internal {
        for (uint256 i = 0; i < amount; i++) {
            uint256 random = randomWords[i];
            uint256 levelSeed = random.mod(100000);
            uint256 earnBaseSpeed = 0;
            uint256 level = 3;
            uint256 earnSpeed = 0;
            uint256 section = 0;
            if (levelSeed < 60000) {
                level = 3;
                earnBaseSpeed = 102900;
                section = 16500;
                uint256 speed = random.mod(section);
                earnSpeed = earnBaseSpeed.add(speed);
            } else if (levelSeed < 85000) {
                level = 4;
                earnBaseSpeed = 102900+16500;
                section = 10300;
                uint256 speed = random.mod(section);
                earnSpeed = earnBaseSpeed.add(speed);
            } else if (levelSeed < 97800) {
                level = 5;
                earnBaseSpeed = 102900+16500+10300;
                section = 33900;
                uint256 speed = random.mod(section);
                earnSpeed = earnBaseSpeed.add(speed);
            } else if (levelSeed < 99800) {
                level = 6;
                earnBaseSpeed = 102900+16500+10300+33900;
                section = 129300;
                uint256 speed = random.mod(section);
                earnSpeed = earnBaseSpeed.add(speed);
            } else {
                level = 7;
                earnBaseSpeed = 102900+16500+10300+33900+129300;
                section = 315900;
                uint256 speed = random.mod(section);
                earnSpeed = earnBaseSpeed.add(speed);
            }

            ISheep.SheepInfo memory sheepInfo;
            sheepInfo.level = level;
            sheepInfo.earnSpeed = earnSpeed;
            sheepInfo.bellwether = false;
            sheepInfo.rechargeTimes = 1;
            uint256 sheepId = sheep.mint(buyer, sheepInfo);
            emit ReceiveSheepResult(requestId, buyer, sheepId, level, false);
        } 
    }

    function handleSilverSheepResult(
        address buyer,
        uint256 amount,
        uint256 requestId,
        uint256[] memory randomWords) internal {
        for (uint256 i = 0; i < amount; i++) {
            uint256 random = randomWords[i];
            uint256 levelSeed = random.mod(100000);
            uint256 level = 1;
            uint256 earnSpeed = 0;
            if (levelSeed < 70000) {
                level = 1;
                uint256 earnBaseSpeed = 96000;
                uint256 section = 4000;
                uint256 speed = random.mod(section);
                earnSpeed = earnBaseSpeed.add(speed);
                // [960, 960+40)
            } else {
                level = 2;
                uint256 earnBaseSpeed = 96000+4000;
                uint256 section = 2900;
                uint256 speed = random.mod(section);
                earnSpeed = earnBaseSpeed.add(speed);
                // [960+40, 960+40+103)
            } 
            ISheep.SheepInfo memory sheepInfo;
            sheepInfo.level = level;
            sheepInfo.earnSpeed = earnSpeed;
            sheepInfo.bellwether = false;
            sheepInfo.rechargeTimes = 1;
            uint256 sheepId = sheep.mint(buyer, sheepInfo);
            emit ReceiveSheepResult(requestId, buyer, sheepId, level, false);
        } 
    }

    function sendPropNft(uint256 amount, address buyer) internal {

        uint256 fullNumber = 0;
        uint256 halfNumber = 0;
        uint256 singleNumber = 0;
        if (sheepSellAmount < 1000) {
            fullNumber = amount;
            (fullNumber, halfNumber) = ladderAward(amount, 1000);
        } else if (1000 <= sheepSellAmount && sheepSellAmount < 2000) {
            halfNumber = amount;
            (halfNumber, singleNumber) =  ladderAward(amount, 2000);
        } else if (2000 <= sheepSellAmount && sheepSellAmount < 3000) {
            singleNumber = amount;
            (singleNumber, ) =  ladderAward(amount, 3000);
        }

        for (uint256 i = 0; i < fullNumber; i++) {
                giveFullAward(buyer);
        }

        for (uint256 i = 0; i < halfNumber; i++) {
                giveHalfAward(buyer);
        }

        for (uint256 i = 0; i < singleNumber; i++) {
                giveSingleAward(buyer);
        }

        sheepSellAmount = sheepSellAmount.add(amount);
    }

    function ladderAward(
        uint256 buyAmount, 
        uint256 ladder) 
        internal view returns(
        uint256 firstEchelon,
        uint256 secondEchelon){
        if (sheepSellAmount.add(buyAmount) > ladder) {
            secondEchelon = sheepSellAmount.add(buyAmount).sub(ladder);
            firstEchelon = buyAmount.sub(secondEchelon);
        }else{
            firstEchelon = buyAmount;
        }
    }

    function giveFullAward(address buyer) internal {
        giveHalfAward(buyer);
        giveSingleAward(buyer);
    }

    function giveHalfAward(address buyer) internal {

        uint256 prop1Id = prop.mint(buyer, propByType(1));
        emit GiveProp(buyer, 1, prop1Id);
        uint256 prop3Id = prop.mint(buyer, propByType(3));
        emit GiveProp(buyer, 3, prop3Id);
    }

    function giveSingleAward(address buyer) internal {
        
        uint256 propId = prop.mint(buyer, propByType(2));
        emit GiveProp(buyer, 2, propId);
    }

    function propByType(uint256 propType) internal pure returns(ISheepProp.PropInfo memory info) {
        info.propType = propType;
        info.rechargeTimes = 2;
    }

    function updatePropPrice(uint256[] memory typePrices) external onlyOwner {
        propTypeUnitPrice = typePrices;
        emit UpdatePropPrice(typePrices);
    }

    function updatePrice(uint256 _sheepUnitPrice , uint256 _bellwetherPrice) external onlyOwner {
        bellwetherPrice = _bellwetherPrice;
        sheepUnitPrice = _sheepUnitPrice;
        emit UpdatePrice(sheepUnitPrice, _bellwetherPrice);
    }

    function reSetStartTime(uint256 _sheepStartTime, uint256 _propStartTime, uint256 _bellwetherStartTime) external onlyOwner {
        sheepStartTime = _sheepStartTime;
        propStartTime = _propStartTime;
        bellwetherStartTime = _bellwetherStartTime;
        emit UpdateStartTime(_sheepStartTime, _propStartTime, _bellwetherStartTime);
    }

    function updateSheepSingleMaxSell(uint32 _sheepSingleMaxSell) external onlyOwner {
        sheepSingleMaxSell = _sheepSingleMaxSell;
        emit UpdateSheepSingleMaxSell(_sheepSingleMaxSell);
    }

    function updateWhitelist(
        uint256 _sheepType,
        bytes32 _whitelistRoot
    ) external onlyOwner {
        merkleRoot[_sheepType] = _whitelistRoot;
        emit UpdateWhitelist(_sheepType, _whitelistRoot);
    }

    function addWhitelist(uint256 sheepType, address player) external onlyOwner{
        whitelists[sheepType][player] = true;
        emit AddWhitelist(sheepType, player);
    }

    function updateClaimPool(address pool, bool tag) external onlyOwner{
        require(claimPool[pool] != tag, "pool has been set");
        claimPool[pool] = tag;
        emit UpdateClaimPool(pool, tag);
    }

    function withdraw(address payable devAddress) external onlyOwner {
        uint256 balance =  address(this).balance;
        devAddress.transfer(balance);
        emit Withdraw(devAddress, balance);
    }
    
    receive() payable external {}
}

// File: contracts/interface/IPlayerReward.sol

pragma solidity ^0.8.0;


interface IPlayerReward {
    
    struct Player {
        address addr;
        bytes32 name;
        uint8 nameCount;
        uint256 laff;
        uint256 amount;
        uint256 rreward;
        uint256 allReward;
        uint256 lv1Count;
        uint256 lv2Count;
    }
    
    function settleReward(address from,uint256 amount ) external returns (uint256, address, uint256, address);
    function _pIDxAddr(address from) external view returns(uint256);
    function _plyr(uint256 playerId) external view returns(Player memory player);
    function _pools(address pool) external view returns(bool);
}

// File: contracts/referral/SheepOpenSellV2.sol


pragma solidity ^0.8.0;


contract SheepOpenSellV2 is SheepOpenSell {
    using SafeMath for uint256;
    
    address public playerReward;

    function addPlayerReward(address _playerReward) external onlyOwner {
        playerReward = _playerReward;
    }
    
    function buySheep(uint32 amount, string memory affCode) 
    external override payable nonReentrant returns(uint256) {
        require(amount <= sheepSingleMaxSell, "Up to 10 at a time!!!");
        require(block.timestamp >= sheepStartTime, "no start!!!");
        uint256 price = uint256(amount).mul(sheepUnitPrice);
        require(msg.value >= price, "Value is too low!!!");
        
        if (!IPlayerBook(playerBook).hasRefer(msg.sender)) {
            IPlayerBook(playerBook).bindRefer(msg.sender, affCode);
        }
        uint256 requestId = _getSheepRandomWords(amount, msg.sender, 1);
        sheepIn = sheepIn.add(price);
        sendPropNft(amount, msg.sender);
        emit BuySheep(msg.sender, amount, msg.value, requestId);

        (uint256 affReward, address laff,
        uint256 aff_affReward, address aff_aff) = IPlayerReward(playerReward).settleReward(msg.sender, price);

        payable(laff).transfer(affReward);
        payable(aff_aff).transfer(aff_affReward);
        
        return requestId;
    }

}