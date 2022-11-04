// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Provides a flexible and updatable auth pattern which is completely separate from application logic.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Auth.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
abstract contract Auth {
    event OwnershipTransferred(address indexed user, address indexed newOwner);

    event AuthorityUpdated(address indexed user, Authority indexed newAuthority);

    address public owner;

    Authority public authority;

    constructor(address _owner, Authority _authority) {
        owner = _owner;
        authority = _authority;

        emit OwnershipTransferred(msg.sender, _owner);
        emit AuthorityUpdated(msg.sender, _authority);
    }

    modifier requiresAuth() virtual {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }

    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {
        Authority auth = authority; // Memoizing authority saves us a warm SLOAD, around 100 gas.

        // Checking if the caller is the owner only after calling the authority saves gas in most cases, but be
        // aware that this makes protected functions uncallable even to the owner if the authority is out of order.
        return (address(auth) != address(0) && auth.canCall(user, address(this), functionSig)) || user == owner;
    }

    function setAuthority(Authority newAuthority) public virtual {
        // We check if the caller is the owner first because we want to ensure they can
        // always swap out the authority even if it's reverting or using up a lot of gas.
        require(msg.sender == owner || authority.canCall(msg.sender, address(this), msg.sig));

        authority = newAuthority;

        emit AuthorityUpdated(msg.sender, newAuthority);
    }

    function transferOwnership(address newOwner) public virtual requiresAuth {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

/// @notice A generic interface for a contract which provides authorization data to an Auth instance.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Auth.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
interface Authority {
    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Auth, Authority} from "solmate/auth/Auth.sol";

interface IAutofarmFeesController {
  function forwardFees(address earnedAddress, uint256 minAUTOOut) external;
}

interface IStratX4 {
  function earn(address earnedAddress, uint256 minAmountOut)
    external
    returns (uint256 profit, uint256 earnedAmount, uint256 feeCollected);
  function collectFees(address earnedAddress) external returns (uint256 amount);
  function setFeeRate(uint256 _feeRate) external;
}

contract Keeper is Auth {
  address public immutable feesController;

  constructor(address _feesController, Authority _authority)
    Auth(address(0), _authority)
  {
    feesController = _feesController;
  }

  function batchEarn(
    address[] calldata strats,
    address[] calldata earnedAddresses,
    uint256[] calldata minAmountsOut
  )
    external
    requiresAuth
    returns (
      uint256[] memory profits,
      uint256[] memory earnedAmounts,
      uint256[] memory feesCollected
    )
  {
    require(
      strats.length == earnedAddresses.length, "Input arrays length mismatch"
    );
    require(
      strats.length == minAmountsOut.length, "Input arrays length mismatch"
    );

    profits = new uint256[](strats.length);

    for (uint256 i; i < strats.length;) {
      try IStratX4(strats[i]).earn(earnedAddresses[i], minAmountsOut[i])
      returns (uint256 profit, uint256 earnedAmount, uint256 feeCollected) {
        profits[i] = profit;
        earnedAmounts[i] = earnedAmount;
        feesCollected[i] = feeCollected;
      } catch {}

      unchecked {
        i++;
      }
    }
  }

  function batchCollectFees(
    address[] calldata strats,
    address[] calldata earnedAddresses
  ) external requiresAuth returns (uint256[] memory amounts) {
    require(strats.length == earnedAddresses.length);

    amounts = new uint256[](strats.length);

    for (uint256 i; i < strats.length;) {
      try IStratX4(strats[i]).collectFees(earnedAddresses[i]) returns (
        uint256 amount
      ) {
        amounts[i] = amount;
      } catch {}

      unchecked {
        i++;
      }
    }
  }

  function batchSetFeeRate(
    address[] calldata strats,
    uint256[] calldata feeRates
  ) external requiresAuth {
    require(strats.length == feeRates.length);

    for (uint256 i; i < strats.length;) {
      try IStratX4(strats[i]).setFeeRate(feeRates[i]) {} catch {}

      unchecked {
        i++;
      }
    }
  }

  function batchForwardFees(
    address[] calldata earnedAddresses,
    uint256[] calldata minAmountsOut
  ) external requiresAuth {
    require(earnedAddresses.length == minAmountsOut.length);

    for (uint256 i; i < earnedAddresses.length;) {
      try IAutofarmFeesController(feesController).forwardFees(
        earnedAddresses[i], minAmountsOut[i]
      ) {} catch {}

      unchecked {
        i++;
      }
    }
  }
}