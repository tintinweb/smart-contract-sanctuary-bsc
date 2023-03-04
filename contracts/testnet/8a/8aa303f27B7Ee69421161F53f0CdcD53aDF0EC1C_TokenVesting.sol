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
import "../core/dependencies/openzeppelin/contracts/SafeMath.sol";
import "./IMultiFeeDistribution.sol";

contract TokenVesting {
    using SafeMath for uint256;

    uint256 public startTime;
    uint256 public duration;
    uint256 public immutable maxMintableTokens;
    uint256 public mintedTokens;
    IMultiFeeDistribution public minter;
    address public owner;

    struct Vest {
        uint256 total;
        uint256 claimed;
    }

    mapping(address => Vest) public vests;

    constructor(
        IMultiFeeDistribution _minter,
        uint256 _maxMintable,
        address[] memory _receivers,
        uint256[] memory _amounts,
        uint256 _vestingDuration
    ) {
        require(_receivers.length == _amounts.length);
        minter = _minter;
        uint256 mintable;
        for (uint256 i = 0; i < _receivers.length; i++) {
            require(vests[_receivers[i]].total == 0);
            mintable = mintable.add(_amounts[i]);
            vests[_receivers[i]].total = _amounts[i];
        }
        require(mintable == _maxMintable);
        maxMintableTokens = mintable;
        duration = _vestingDuration;
        owner = msg.sender;
    }

    function start() external {
        require(msg.sender == owner);
        require(startTime == 0);
        startTime = block.timestamp;
    }

    function claimable(address _claimer) external view returns (uint256) {
        if (startTime == 0) return 0;
        Vest storage v = vests[_claimer];
        uint256 elapsedTime = block.timestamp.sub(startTime);
        if (elapsedTime > duration) elapsedTime = duration;
        uint256 claimable = v.total.mul(elapsedTime).div(duration);
        return claimable.sub(v.claimed);
    }

    function claim(address _receiver) external {
        require(startTime != 0);
        Vest storage v = vests[msg.sender];
        uint256 elapsedTime = block.timestamp.sub(startTime);
        if (elapsedTime > duration) elapsedTime = duration;
        uint256 claimable = v.total.mul(elapsedTime).div(duration);
        if (claimable > v.claimed) {
            uint256 amount = claimable.sub(v.claimed);
            mintedTokens = mintedTokens.add(amount);
            require(mintedTokens <= maxMintableTokens);
            minter.mint(_receiver, amount, false);
            v.claimed = claimable;
        }
    }
}