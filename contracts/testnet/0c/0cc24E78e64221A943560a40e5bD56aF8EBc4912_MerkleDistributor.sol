// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import './Context.sol';

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
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
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
    require(_owner == _msgSender(), 'Ownable: caller is not the owner');
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
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.10;

/// @title Optimized overflow and underflow safe math operations
/// @notice Contains methods for doing math operations that revert on overflow or underflow for minimal gas cost
library SafeMath {
  /// @notice Returns x + y, reverts if sum overflows uint256
  /// @param x The augend
  /// @param y The addend
  /// @return z The sum of x and y
  function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
    unchecked {
      require((z = x + y) >= x);
    }
  }

  /// @notice Returns x - y, reverts if underflows
  /// @param x The minuend
  /// @param y The subtrahend
  /// @return z The difference of x and y
  function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
    unchecked {
      require((z = x - y) <= x);
    }
  }

  /// @notice Returns x - y, reverts if underflows
  /// @param x The minuend
  /// @param y The subtrahend
  /// @param message The error msg
  /// @return z The difference of x and y
  function sub(
    uint256 x,
    uint256 y,
    string memory message
  ) internal pure returns (uint256 z) {
    unchecked {
      require((z = x - y) <= x, message);
    }
  }

  /// @notice Returns x * y, reverts if overflows
  /// @param x The multiplicand
  /// @param y The multiplier
  /// @return z The product of x and y
  function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
    unchecked {
      require(x == 0 || (z = x * y) / x == y);
    }
  }

  /// @notice Returns x / y, reverts if overflows - no specific check, solidity reverts on division by 0
  /// @param x The numerator
  /// @param y The denominator
  /// @return z The product of x and y
  function div(uint256 x, uint256 y) internal pure returns (uint256 z) {
    return x / y;
  }
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.10;

interface IMultiFeeDistribution {
    function addReward(address rewardsToken) external;

    function mint(address user, uint256 amount, bool withPenalty) external;
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.10;

import "./IMultiFeeDistribution.sol";
import "../core/dependencies/openzeppelin/contracts/Ownable.sol";
import "../core/dependencies/openzeppelin/contracts/SafeMath.sol";

contract MerkleDistributor is Ownable {
    using SafeMath for uint256;

    struct ClaimRecord {
        bytes32 merkleRoot;
        uint256 validUntil;
        uint256 total;
        uint256 claimed;
    }

    uint256 public immutable maxMintableTokens;
    uint256 public mintedTokens;
    uint256 public reservedTokens;
    uint256 public immutable startTime;
    uint256 public constant duration = 86400 * 365;
    uint256 public constant minDuration = 86400 * 7;

    IMultiFeeDistribution public rewardMinter;

    ClaimRecord[] public claims;

    event Claimed(
        address indexed account,
        uint256 indexed merkleIndex,
        uint256 index,
        uint256 amount,
        address receiver
    );

    // This is a packed array of booleans.
    mapping(uint256 => mapping(uint256 => uint256)) private claimedBitMap;

    constructor(
        IMultiFeeDistribution _rewardMinter,
        uint256 _maxMintable
    ) Ownable() {
        rewardMinter = _rewardMinter;
        maxMintableTokens = _maxMintable;
        startTime = block.timestamp;
    }

    function mintableBalance() public view returns (uint256) {
        uint elapsedTime = block.timestamp.sub(startTime);
        if (elapsedTime > duration) elapsedTime = duration;
        return
            maxMintableTokens
                .mul(elapsedTime)
                .div(duration)
                .sub(mintedTokens)
                .sub(reservedTokens);
    }

    function addClaimRecord(
        bytes32 _root,
        uint256 _duration,
        uint256 _total
    ) external onlyOwner {
        require(_duration >= minDuration);
        uint mintable = mintableBalance();
        require(mintable >= _total);

        claims.push(
            ClaimRecord({
                merkleRoot: _root,
                validUntil: block.timestamp + _duration,
                total: _total,
                claimed: 0
            })
        );
        reservedTokens = reservedTokens.add(_total);
    }

    function releaseExpiredClaimReserves(
        uint256[] calldata _claimIndexes
    ) external {
        for (uint256 i = 0; i < _claimIndexes.length; i++) {
            ClaimRecord storage c = claims[_claimIndexes[i]];
            require(
                block.timestamp > c.validUntil,
                "MerkleDistributor: Drop still active."
            );
            reservedTokens = reservedTokens.sub(c.total.sub(c.claimed));
            c.total = 0;
            c.claimed = 0;
        }
    }

    function isClaimed(
        uint256 _claimIndex,
        uint256 _index
    ) public view returns (bool) {
        uint256 claimedWordIndex = _index / 256;
        uint256 claimedBitIndex = _index % 256;
        uint256 claimedWord = claimedBitMap[_claimIndex][claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 _claimIndex, uint256 _index) private {
        uint256 claimedWordIndex = _index / 256;
        uint256 claimedBitIndex = _index % 256;
        claimedBitMap[_claimIndex][claimedWordIndex] =
            claimedBitMap[_claimIndex][claimedWordIndex] |
            (1 << claimedBitIndex);
    }

    function claim(
        uint256 _claimIndex,
        uint256 _index,
        uint256 _amount,
        address _receiver,
        bytes32[] calldata _merkleProof
    ) external {
        require(
            _claimIndex < claims.length,
            "MerkleDistributor: Invalid merkleIndex"
        );
        require(
            !isClaimed(_claimIndex, _index),
            "MerkleDistributor: Drop already claimed."
        );

        ClaimRecord storage c = claims[_claimIndex];
        require(
            c.validUntil > block.timestamp,
            "MerkleDistributor: Drop has expired."
        );

        c.claimed = c.claimed.add(_amount);
        require(
            c.total >= c.claimed,
            "MerkleDistributor: Exceeds allocated total for drop."
        );

        reservedTokens = reservedTokens.sub(_amount);
        mintedTokens = mintedTokens.add(_amount);

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(_index, msg.sender, _amount));
        require(
            verify(_merkleProof, c.merkleRoot, node),
            "MerkleDistributor: Invalid proof."
        );

        // Mark it claimed and send the token.
        _setClaimed(_claimIndex, _index);
        rewardMinter.mint(_receiver, _amount, true);

        emit Claimed(msg.sender, _claimIndex, _index, _amount, _receiver);
    }

    function verify(
        bytes32[] calldata _proof,
        bytes32 _root,
        bytes32 _leaf
    ) internal pure returns (bool) {
        bytes32 computedHash = _leaf;

        for (uint256 i = 0; i < _proof.length; i++) {
            bytes32 proofElement = _proof[i];

            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == _root;
    }
}