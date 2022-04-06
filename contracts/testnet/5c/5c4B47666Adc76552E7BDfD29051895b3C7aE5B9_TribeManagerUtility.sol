// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../../../Interfaces/ITribeManager.sol";
import "./TribeNFTEntityLib.sol";

contract TribeManagerUtility is Ownable {
    ITribeManager public tribeMananger;

    constructor(address _tribeManager) {
        tribeMananger = ITribeManager(_tribeManager);
    }

    function updateTribeManager(address _tribeManager) external onlyOwner {
        tribeMananger = ITribeManager(_tribeManager);
    }

    function getUserDailyEmission(
        address _account,
        TribeNFTEntityLib.TribeType _type
    ) external view returns (uint256) {
        uint256 emission = tribeMananger.emissionsPerSec(_type);
        TribeNFTEntityLib.TribeNFTEntity[] memory tribes = tribeMananger
            .getTribesByAccount(_account);
        uint256 totalStakedValue = 0;
        for (uint256 i = 0; i < tribes.length; i++) {
            if (tribes[i].tribeType == _type) {
                totalStakedValue += tribes[i].tribeValue;
            }
        }

        return
            tribeMananger.totalValueLocked(_type) > 0 ? 
            (emission * 86400 * totalStakedValue) /
            tribeMananger.totalValueLocked(_type) : 0;
    }

    function getUserPendingRewards(
        address _account,
        TribeNFTEntityLib.TribeType _type
    ) public view returns (uint256) {
        TribeNFTEntityLib.TribeNFTEntity[] memory tribes = tribeMananger
            .getTribesByAccount(_account);
        uint256 pendingRewards = 0;
        for (uint256 i = 0; i < tribes.length; i++) {
            TribeNFTEntityLib.TribeNFTEntity memory tribe = tribes[i];
            if (tribe.tribeType == _type) {
                pendingRewards += tribeMananger.calculateReward(tribe);
            }
        }
        return pendingRewards;
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

pragma solidity ^0.8.0;

import "../Boardroom/PlanetNFT/helpers/TribeNFTEntityLib.sol";

interface ITribeManager {
  function creationMinPrices(TribeNFTEntityLib.TribeType _type) external view returns (uint256);
  function totalValueLocked(TribeNFTEntityLib.TribeType _type) external view returns (uint256);
  function emissionsPerSec(TribeNFTEntityLib.TribeType _type) external view returns (uint256);
  function totalTribes() external view returns (uint256);
  function createTribeNFT(TribeNFTEntityLib.TribeType _type, string memory _name, uint256 _value) external returns (uint256);
  function isOwnerOfTribes(address account) external view returns (bool);
  function getUserPendingRewards(address _account, TribeNFTEntityLib.TribeType _type) external view returns (uint256);
  function getTribeIdsOf(address account) external view returns (uint256[] memory);
  function getTribesByAccount(address _account) external view returns (TribeNFTEntityLib.TribeNFTEntity[] memory);
  function TVL(TribeNFTEntityLib.TribeType _tribeType) external view returns (uint256);
  function APR(TribeNFTEntityLib.TribeType _tribeType) external view returns (uint256);
  function calculateReward(TribeNFTEntityLib.TribeNFTEntity memory _tribe) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library TribeNFTEntityLib {
  	enum TribeType {
        Warrior,
        Sage
    }
  	struct TribeNFTEntity {
        uint256 id;
        string name;
        TribeType tribeType;
        uint256 creationTime;
        uint256 lastProcessingTimestamp;
        uint256 tribeValue;
        uint256 totalClaimed;
		    uint16 level;
        bool exists;
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