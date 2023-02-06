/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

// File: 67_In_Game/interfaces/IToken.sol


pragma solidity 0.8.17;

// Author: Francesco Sullo <[email protected]>

interface IToken {
  function symbol() external view returns (string memory);

  function burn(uint256 amount) external;

  function balanceOf(address account) external view returns (uint256);

  function transfer(address to, uint256 amount) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool);

  function mint(address to, uint256 amount) external;
}
// File: 67_In_Game/interfaces/IAttributable.sol


pragma solidity ^0.8.4;

// Author:
// Francesco Sullo <[email protected]>
// Taken from https://github.com/ndujaLabs/attributable
//import "hardhat/console.sol";

/**
   @title IAttributable Cross-player On-chain Attributes
    Version: 0.0.1
   ERC165 interfaceId is 0xc79cd306
   */
interface IAttributable {
  /**
     @dev Emitted when the attributes for an id and a player is set.
          The function must be called by the owner of the asset to authorize a player to set
          attributes on it. The rules for that are left to the asset.

          This event is important because allows a marketplace to know that there are
          dynamic attributes set on the NFT by a specific contract (the player) so that
          the marketplace can query the player to get the attributes of the NFT in within
          the game.
   */
  event AttributesInitializedFor(uint256 indexed _id, address indexed _player);

  /**
     @dev It returns the on-chain attributes of a specific id
       This function is called by the player, which is able to decode the uint and
       transform them in whatever is necessary for the game.
     @param _id The id of the token for whom to query the on-chain attributes
     @param _player The address of the player's contract
     @param _index The index in the array of attributes
     @return The encoded attributes of the token
   */
  function attributesOf(
    uint256 _id,
    address _player,
    uint256 _index
  ) external view returns (uint256);

  /**
     @notice Authorize a player initializing the attributes of a token to a non zero value
     @dev It must be called by the owner of the nft

       To avoid that nft owners give themselves arbitrary values, they must not
       be able to set up the values, but only to create the array that later
       will be filled by the player.

       Since by default the value in the array would be zero, the initial value
       must be a non-zero value. This way the player can see if the data are initialized
       checking that the attributesOf a certain id is != 0.

       The function must emit the AttributesInitializedFor event

     @param _id The id of the token for whom to authorize the player
     @param _player The address of the player contract
   */
  function initializeAttributesFor(uint256 _id, address _player) external;

  /**
     @notice Sets the attributes of a token after the initialization
     @dev It modifies attributes by id for a specific player. It must
       be called by the player's contract, after an NFT has been initialized.

       The owner of the NFT must not be able to update the attributes.

       It must revert if the asset is not initialized for that player (the msg.sender).

     @param _id The id of the token for whom to change the attributes
     @param _index The index of the array where the attribute is updated
     @param _attributes The encoded attributes
   */
  function updateAttributes(
    uint256 _id,
    uint256 _index,
    uint256 _attributes
  ) external;
}
// File: 67_In_Game/interfaces/ILockable.sol


pragma solidity ^0.8.4;

// Author:
// Francesco Sullo <[email protected]>
// Taken from https://github.com/ndujaLabs/lockable

// ERC165 interface id is 0xd8e4c296
interface ILockable {
  event LockerSet(address locker);
  event LockerRemoved(address locker);
  event ForcefullyUnlocked(uint256 tokenId);
  event Locked(uint256 tokendId);
  event Unlocked(uint256 tokendId);

  // tells if a token is locked
  function locked(uint256 tokenID) external view returns (bool);

  // tells the address of the contract which is locking a token
  function lockerOf(uint256 tokenID) external view returns (address);

  // tells if a contract is a locker
  function isLocker(address _locker) external view returns (bool);

  // set a locker, if the actor that is locking it is a contract, it
  // should be approved
  // It should emit a LockerSet event
  function setLocker(address pool) external;

  // remove a locker
  // It should emit a LockerRemoved event
  function removeLocker(address pool) external;

  // tells if an NFT has any locks on it
  // The function is called internally and externally
  function hasLocks(address owner) external view returns (bool);

  // locks an NFT
  // It should emit a Locked event
  function lock(uint256 tokenID) external;

  // unlocks an NFT
  // It should emit a Unlocked event
  function unlock(uint256 tokenID) external;

  // unlock an NFT if the locker is removed
  // This is an emergency function called by the token owner or a DAO
  // It should emit a ForcefullyUnlocked event
  function unlockIfRemovedLocker(uint256 tokenID) external;
}
// File: 67_In_Game/interfaces/IAsset.sol


pragma solidity 0.8.17;

// Author: Francesco Sullo <[email protected]>



interface IAsset is ILockable, IAttributable {
  struct FarmAttributes {
    uint8 level;
    uint8 farmState;
    uint32 currentHP;
    uint32 weedReserves;
  }

  struct TurfAttributes {
    uint8 level;
  }
}
// File: 67_In_Game/interfaces/IUserSimplified.sol


pragma solidity 0.8.17;

interface IUserSimplified {
  event Staked(address indexed user, uint16 indexed mainIndex);
  event Unstaked(address indexed user, uint16 indexed mainIndex);

  struct Stake {
    uint16 tokenId;
    uint32 lockedAt;
    uint32 unlockedAt;
  }

  struct Deposit {
    /*
    The depositId is commented because it would break the
    upgradeability. Next time we do a full re-deployment in testnet
    we can make the id explicit.
    */
    // uint32 depositId;
    uint8 tokenType;
    uint256 amount;
    uint32 depositedAt;
  }

  struct DepositInfo {
    address user;
    uint16 index;
  }

  /**
   @dev Data structure representing token holder using a pool
  */
  struct User {
    // this is increased during deposits and decreased when used
    uint256 seedAmount;
    uint256 budAmount;
    mapping(uint8 => Stake[]) stakes;
    Deposit[] deposits;
  }
}
// File: 67_In_Game/interfaces/IGamePool.sol


pragma solidity 0.8.17;

// Author: Francesco Sullo <[email protected]>
// (c) 2022+ SuperPower Labs Inc.



interface IGamePool is IUserSimplified {
  event Harvested(address user, uint256 amount, uint64 opId);
  event NewDepositAndPay(uint64 depositId, address user, address otherUser);
  event NewDeposit(uint64 depositId, address user, uint8 tokenType, uint256 amount);
  /**
      @dev to have a quick vision of the TVL
    */
  struct Conf {
    uint16 turfAmount;
    uint16 farmAmount;
    uint16 burningPoints;
  }

  /**
  @dev Used to recover a Deposit by tokenType and tokenId
  */
  struct TokenData {
    address owner;
    uint16 depositIndex;
  }

  function setConf(uint16 burningPoints) external;

  /**
      @dev Stakes an asset
      @param tokenType The type of the asset (Turf, Farm...)
      @param tokenId The id of the NFT to be staked
     */
  function stakeAsset(uint8 tokenType, uint16 tokenId) external;

  /**
      @dev Unstakes an asset
      @param tokenType The type of the asset (Turf, Farm...)
      @param tokenId The id of the NFT to be unstaked
      @param currentDepositId The id of the current deposit
      @param signature0 The signature of validator0 approving the transaction
      @param signature1 The signature of validator1 approving the transaction
     */
  function unstakeAsset(
    uint8 tokenType,
    uint16 tokenId,
    uint16 currentDepositId,
    uint256 randomNonce,
    bytes calldata signature0,
    bytes calldata signature1
  ) external;

  /**
      @dev Get a deposit by its unique ID. We do not use the index, because
        the user can have many deposits and during the unstake we will reorganize
        the order of the array in order to optimize space. So, the only value that
        remains constant is the id of the deposit.
      @param user The address of the user
      @param tokenType The type of the token
      @param tokenId The id of the token
      @return the deposit's index
    */
  function getStakeIndexByTokenId(
    address user,
    uint8 tokenType,
    uint256 tokenId,
    bool onlyActive
  ) external view returns (uint256, bool);

  /**
    @dev Get a deposit by its index. This should be public and callable inside
      the contract, as long as the index does not change.
    @param user The address of the user
    @param tokenType The type of the token
    @param index The index of the deposit
    @return the deposit
    */
  function getStakeByIndex(
    address user,
    uint8 tokenType,
    uint256 index
  ) external view returns (Stake memory);

  function getUserDeposits(address user) external view returns (Deposit[] memory);

  /**
      @dev returns the number of active deposits
      @return the number of active deposits
    */
  function getNumberOfStakes(address user, uint8 tokenType) external view returns (uint256);

  /**
    @dev Get a user conf
    @param user The address of the user
    @return the user primary parameters
    */
  function getUserStakes(address user, uint8 tokenType) external view returns (Stake[] memory);

  function depositSeed(
    uint256 amount,
    uint64 depositId,
    uint256 randomNonce,
    bytes calldata signature0
  ) external;

  function depositBud(
    uint256 amount,
    uint64 depositId,
    uint256 randomNonce,
    bytes calldata signature0
  ) external;

  function depositSeedAndPayOtherUser(
    uint256 amount,
    uint64 depositId,
    uint8 nftTokenType,
    address recipient,
    uint256 randomNonce,
    bytes calldata signature0
  ) external;

  function depositByIndex(address user, uint256 index) external view returns (Deposit memory);

  function numberOfDeposits(address user) external view returns (uint256);

  function depositById(uint64 depositId) external view returns (Deposit memory);

  function depositByIdAndUser(uint64 depositId) external view returns (Deposit memory, address);

  function harvest(
    uint256 amount,
    uint256 deadline,
    uint256 randomNonce,
    uint64 opId,
    bytes calldata signature0,
    bytes calldata signature1
  ) external;

  function withdrawFT(
    uint8 tokenType,
    uint256 amount,
    address beneficiary
  ) external;

  function initializeTurf(uint256 turfId) external;

  function updateTurfAttributes(
    uint256 tokenId,
    IAsset.TurfAttributes calldata attributes,
    uint256 randomNonce,
    bytes calldata signature0,
    bytes calldata signature1
  ) external;

  function getTurfAttributes(uint256 turfId) external view returns (IAsset.TurfAttributes memory);

  function initializeFarm(uint256 farmId) external;

  function updateFarmAttributes(
    uint256 tokenId,
    IAsset.FarmAttributes calldata attributes,
    uint256 randomNonce,
    bytes calldata signature0,
    bytes calldata signature1
  ) external;

  function getFarmAttributes(uint256 farmId) external view returns (IAsset.FarmAttributes memory);

  function hashHarvesting(
    address user,
    uint256 amount,
    uint256 deadline,
    uint256 randomNonce,
    uint64 opId
  ) external view returns (bytes32);

  function hashDeposit(
    address user,
    uint256 amount,
    uint256 depositId,
    uint256 randomNonce
  ) external view returns (bytes32);

  function hashDepositAndPay(
    address user,
    uint256 amount,
    uint64 depositId,
    uint8 nftTokenType,
    address recipient,
    uint256 randomNonce
  ) external view returns (bytes32);

  function hashFarmAttributes(
    uint256 tokenId,
    IAsset.FarmAttributes calldata attributes,
    uint256 randomNonce
  ) external view returns (bytes32);

  function hashTurfAttributes(
    uint256 tokenId,
    IAsset.TurfAttributes calldata attributes,
    uint256 randomNonce
  ) external view returns (bytes32);
}
// File: 67_In_Game/utils/Constants.sol


pragma solidity 0.8.17;

// Author: Francesco Sullo <[email protected]>
// (c) 2022+ SuperPower Labs Inc.

contract Constants {
  uint8 public constant TURF = 1;
  uint8 public constant FARM = 2;
  uint8 public constant CHARACTER = 3;
  uint8 public constant SEED = 4;
  uint8 public constant BUD = 5;
}
// File: @openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: 67_In_Game/utils/ERC721Receiver.sol


pragma solidity ^0.8.4;


contract ERC721Receiver is IERC721ReceiverUpgradeable {
  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) public pure override returns (bytes4) {
    return this.onERC721Received.selector;
  }
}
// File: @openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/proxy/beacon/IBeaconUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// File: @openzeppelin/contracts-upgradeable/interfaces/draft-IERC1822Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol


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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;






/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;




/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate the implementation's compatibility when performing an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: 67_In_Game/utils/UUPSUpgradableTemplate.sol


pragma solidity ^0.8.4;

// Author: Francesco Sullo <[email protected]>
// https://github.com/sullof/soliutils
// Testing for this code is in the original repo.




abstract contract UUPSUpgradableTemplate is Initializable, OwnableUpgradeable, UUPSUpgradeable {
  // solhint-disable-next-line
  function __UUPSUpgradableTemplate_init() internal initializer {
    __Ownable_init();
    __UUPSUpgradeable_init();
  }

  function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {}
}
// File: @openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol


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
interface IERC165Upgradeable {
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

// File: @openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: 67_In_Game/interfaces/IAttributablePlayer.sol


pragma solidity ^0.8.4;

// Author:
// Francesco Sullo <[email protected]>

/**
   @title IAttributablePlayer Player of an attributable asset
    Version: 0.0.2
   ERC165 interfaceId is 0x72261e7d
   */
interface IAttributablePlayer {
  /**
    @dev returns the attributes in a readable way
    @param _asset The address of the asset played by the game
    @param _id The id of the asset
    @return A string with type of the attribute, name and value

    The expected format is a string like `uint16 level:23;uin256 power:2543344` which
    can be easily converted by a marketplace in a JSON object.

    Here an example of implementation (using OpenZeppelin /utils/Strings.sol)

    function attributesOf(
      address _nft,
      uint256 tokenId
    ) external view override
    returns (string memory) {
      uint256 _attributes = IAttributable(_nft).attributesOf(tokenId, address(this), 0);
      if (_attributes != 0) {
        return
          string(
            abi.encodePacked(
              "uint8 version:",
              Strings.toString(uint8(_attributes)),
              ";uint8 level:",
              Strings.toString(uint16(_attributes >> 8)),
              ";uint32 stamina:",
              Strings.toString(uint32(_attributes >> 16)),
              ";address winner:",
              Strings.toHexString(uint160(_attributes >> 48), 20)
            )
          );
      } else {
        return "";
      }
    }

  */
  function attributesOf(address _asset, uint256 _id) external view returns (string memory);
}
// File: @openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;


/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;


/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// File: 67_In_Game/utils/Signable.sol


pragma solidity 0.8.17;

// Authors: Francesco Sullo <[email protected]>





contract Signable is Initializable, OwnableUpgradeable {
  using AddressUpgradeable for address;
  using ECDSAUpgradeable for bytes32;

  event ValidatorSet(uint256 id, address validator);

  mapping(uint256 => address) private _validators;

  // solhint-disable-next-line
  function __Signable_init() internal initializer {
    __Ownable_init();
  }

  function setValidator(uint256 id, address validator) external onlyOwner {
    require(validator != address(0), "Signable: address zero not allowed");
    _validators[id] = validator;
    emit ValidatorSet(id, validator);
  }

  function getValidator(uint256 id) external view returns (address) {
    return _validators[id];
  }

  function isValidator(address validator, uint256 maxId) external view returns (bool) {
    for (uint256 i = 0; i <= maxId; i++) {
      if (_validators[i] == validator) {
        return true;
      }
    }
    return false;
  }

  /** @dev how to use it:
    require(
      isSignedByValidator(0, encodeForSignature(to, tokenType, lockedFrom, lockedUntil, mainIndex, tokenAmountOrID), signature),
      "WormholeBridge: invalid signature"
    );
  */

  // this is called internally and externally by the web3 app to test a validation
  function isSignedByValidator(
    uint256 id,
    bytes32 hash,
    bytes memory signature
  ) public view returns (bool) {
    return _validators[id] != address(0) && _validators[id] == hash.recover(signature);
  }

  function isSignedByAValidator(
    uint256 id0,
    uint256 id1,
    bytes32 hash,
    bytes memory signature
  ) public view returns (bool) {
    return isSignedByValidator(id0, hash, signature) || isSignedByValidator(id1, hash, signature);
  }
}
// File: 67_In_Game/utils/SignableStakes.sol


pragma solidity 0.8.17;

// Authors: Francesco Sullo <[email protected]>


contract SignableStakes is Signable {
  // these functions are called internally, and externally by the app
  function hashUnstake(
    uint8 tokenType,
    uint16 tokenId,
    uint16 indexOrId,
    uint256 randomNonce
  ) public view returns (bytes32) {
    return
      keccak256(
        abi.encodePacked(
          "\x19\x01", // EIP-191
          block.chainid,
          tokenType,
          tokenId,
          indexOrId,
          randomNonce
        )
      );
  }
}
// File: @openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol


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
library SafeMathUpgradeable {
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

// File: 67_In_Game/GamePool.sol


pragma solidity 0.8.17;

// Author: Francesco Sullo <[email protected]>
// (c) 2022+ SuperPower Labs Inc.













//import "hardhat/console.sol";

contract GamePool is IGamePool, SignableStakes, Constants, UUPSUpgradableTemplate, IAttributablePlayer {
  using SafeMathUpgradeable for uint256;

  error turfNotERC721();
  error farmNotERC721();
  error seedNotSEED();
  error budNotBUD();
  error onlyOnTestnet();
  error turfAlreadyLocked();
  error farmAlreadyLocked();
  error invalidTokenType();
  error invalidPrimarySignature();
  error invalidSecondarySignature();
  error assetNotFound();
  error turfNotLocked();
  error farmNotLocked();
  error signatureAlreadyUsed();
  error invalidRecipient();
  error invalidNFT();
  error harvestingExpired();
  error amountNotAvailable();
  error unsupportedNFT();

  Conf public conf;
  mapping(address => User) internal _users;
  mapping(bytes32 => bool) private _usedSignatures;

  IAsset public turfToken;
  IAsset public farmToken;
  IToken public seedToken;
  IToken public budToken;

  mapping(uint8 => mapping(uint16 => TokenData)) internal _stakedByTokenId;

  mapping(uint64 => DepositInfo) private _depositsById;

  function _equalString(string memory a, string memory b) internal pure returns (bool) {
    return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
  }

  /// @notice Initializes the contract
  /// @dev it will revert if the TURF or FARM token is not ERC721
  ///      or if the seed or bud token symbols are not matching
  /// @param turf address of the TURF token
  /// @param farm address of the FARM token
  /// @param seed address of the SEED token
  /// @param bud address of the BUD token
  function initialize(
    address turf,
    address farm,
    address seed,
    address bud
  ) public initializer {
    __UUPSUpgradableTemplate_init();
    __Signable_init();
    if (!IERC165Upgradeable(turf).supportsInterface(type(IERC721Upgradeable).interfaceId)) revert turfNotERC721();
    if (!IERC165Upgradeable(farm).supportsInterface(type(IERC721Upgradeable).interfaceId)) revert farmNotERC721();
    turfToken = IAsset(turf);
    farmToken = IAsset(farm);
    seedToken = IToken(seed);
    if (!_equalString(seedToken.symbol(), "SEED")) revert seedNotSEED();
    budToken = IToken(bud);
    if (!_equalString(budToken.symbol(), "BUD")) revert budNotBUD();
    conf.burningPoints = 7000; // 70%
  }

  function setConf(uint16 burningPoints) external override onlyOwner {
    conf.burningPoints = burningPoints;
  }

  /// @notice Stakes a token of type TURF or FARM
  /// @dev it will revert if GamePool not approved to spend the token
  ///      and/or if GamePool is not an authorized locker
  /// @param tokenType uint for type of token, should be TURF or FARM
  /// @param tokenId uint for the tokenId of the token to stake
  function stakeAsset(uint8 tokenType, uint16 tokenId) external override {
    if (tokenType == TURF) {
      if (turfToken.locked(tokenId)) revert turfAlreadyLocked();
      conf.turfAmount++;
      turfToken.lock(tokenId);
    } else if (tokenType == FARM) {
      if (farmToken.locked(tokenId)) revert farmAlreadyLocked();
      conf.farmAmount++;
      farmToken.lock(tokenId);
    } else {
      revert unsupportedNFT();
    }
    Stake memory stake = Stake({tokenId: uint16(tokenId), lockedAt: uint32(block.timestamp), unlockedAt: 0});
    _users[_msgSender()].stakes[tokenType].push(stake);
  }

  /// @notice Unstakes a token of type TURF or FARM
  /// @dev This function revert with "signatureAlreadyUsed" in
  ///      _saveSignatureAsUsed if the signature was already used
  ///      It will revert if the token is not staked by the user
  ///      in V1, the signature0 is necessary because we cannot check inside this contract if the
  ///      staked asset is used somewhere. So, we let the game to decide that and guarantee
  ///      that the asset can be unstaked.
  /// @param tokenType uint for type of token, should be TURF or FARM
  /// @param tokenId tutokenId of the token to unstake
  /// @param stakeIndex index of the stake in the stakes array
  /// @param randomNonce random nonce
  /// @param signature0 single use signature from validator 0
  /// @param signature1 single use signature from validator 1
  function unstakeAsset(
    uint8 tokenType,
    uint16 tokenId,
    uint16 stakeIndex,
    uint256 randomNonce,
    bytes calldata signature0,
    bytes calldata signature1
  ) external override {
    if (tokenType != TURF && tokenType != FARM) revert invalidTokenType();
    if (!isSignedByAValidator(0, 2, hashUnstake(tokenType, tokenId, stakeIndex, randomNonce), signature0))
      revert invalidPrimarySignature();
    if (!isSignedByAValidator(1, 3, hashUnstake(tokenType, tokenId, stakeIndex, randomNonce), signature1))
      revert invalidSecondarySignature();
    _saveSignatureAsUsed(signature0);
    _saveSignatureAsUsed(signature1);
    (uint256 index, bool found) = getStakeIndexByTokenId(_msgSender(), tokenType, tokenId, true);
    if (!found) revert assetNotFound();
    _users[_msgSender()].stakes[tokenType][index].unlockedAt = uint32(block.timestamp);
    if (tokenType == TURF) {
      if (!turfToken.locked(tokenId)) revert turfNotLocked();
      conf.turfAmount--;
      turfToken.unlock(tokenId);
    } else {
      // shouldn't we explicitly check for else if tokenType == FARM?
      if (!farmToken.locked(tokenId)) revert farmNotLocked();
      conf.farmAmount--;
      farmToken.unlock(tokenId);
    }
  }

  /// @notice Returns the state of a stake
  /// @param _stake Stake struct to test
  /// @param _tokenId uint for the tokenId of the token
  /// @param _onlyActive boolean to restrict the search to active stakes
  /// @return true if the stake is the one we are looking for with a matching state
  ///         false if the stake is not the one we are looking for or if the state is not matching
  function _checkStakeState(
    Stake memory _stake,
    uint256 _tokenId,
    bool _onlyActive
  ) internal pure returns (bool) {
    bool state = uint16(_stake.tokenId) == _tokenId && _stake.lockedAt != 0 && (!_onlyActive || _stake.unlockedAt == 0);
    return state;
  }

  /// @notice Returns the index of the stake in the _user[].stakes array
  /// @param user address of the user
  /// @param tokenType uint for type of token
  /// @param tokenId uint for the tokenId of the token
  /// @param onlyActive boolean to restrict the search to active stakes
  /// @return index of the stake in the _user[].stakes array
  /// @return true if the stake was found, false is not
  function getStakeIndexByTokenId(
    address user,
    uint8 tokenType,
    uint256 tokenId,
    bool onlyActive
  ) public view override returns (uint256, bool) {
    for (uint256 i; i < _users[user].stakes[tokenType].length; i++) {
      Stake memory stake = _users[user].stakes[tokenType][i];
      if (_checkStakeState(stake, tokenId, onlyActive)) {
        return (i, true);
      }
    }
    return (0, false);
  }

  /// @notice Returns the stake of a token, returns an empty stake if not found
  /// @param user address of the user
  /// @param tokenType uint for type of token
  /// @param index index of the stake in the _sers[].stakes array
  function getStakeByIndex(
    address user,
    uint8 tokenType,
    uint256 index
  ) external view override returns (Stake memory) {
    if (_users[user].stakes[tokenType].length <= index) {
      Stake memory emptyStake;
      return emptyStake;
    } else {
      return _users[user].stakes[tokenType][index];
    }
  }

  /// @notice Returns the number of stakes for a user and for a token type
  /// @param user address of the user
  /// @param tokenType uint for type of token
  /// @return number of stakes for a user and for a token type
  function getNumberOfStakes(address user, uint8 tokenType) external view override returns (uint256) {
    return _users[user].stakes[tokenType].length;
  }

  /// @notice Returns the deposits for a user
  /// @param user address of the user
  /// @return array of Deposit structs
  function getUserDeposits(address user) external view override returns (Deposit[] memory) {
    return _users[user].deposits;
  }

  /// @notice Returns the amount of token staked by the user by type
  /// @param user address of the user
  /// @param tokenType uint8 for type of token
  /// @return amount of token staked by the user by type
  function getUserStakes(address user, uint8 tokenType) external view override returns (Stake[] memory) {
    return _users[user].stakes[tokenType];
  }

  /// @notice Marks a signature as used if not already used
  /// @dev This function revert with "signatureAlreadyUsed" if signature already used
  /// @param _signature bytes of the signature to mark as used
  function _saveSignatureAsUsed(bytes memory _signature) internal {
    bytes32 key = bytes32(keccak256(abi.encodePacked(_signature)));
    if (_usedSignatures[key]) revert signatureAlreadyUsed();
    _usedSignatures[key] = true;
  }

  /// @notice Deposits SEEDs to message sender
  /// @dev This function revert with "signatureAlreadyUsed" in
  ///      _saveSignatureAsUsed if the signature was already used
  /// @param amount uint256 for the amount of SEEDs to deposit
  /// @param depositId uint64 for the deposit id
  /// @param randomNonce uint256 for the random nonce
  /// @param signature0 bytes for the signature of the validator
  function depositSeed(
    uint256 amount,
    uint64 depositId,
    uint256 randomNonce,
    bytes calldata signature0
  ) external override {
    if (!isSignedByAValidator(0, 2, hashDeposit(_msgSender(), amount, depositId, randomNonce), signature0))
      revert invalidPrimarySignature();
    _saveSignatureAsUsed(signature0);
    _depositFT(SEED, amount, depositId, _msgSender());
  }

  /// @notice Deposits BUDs to message sender
  /// @param amount uint256 for the amount of BUDs to deposit
  /// @param depositId uint64 for the deposit id
  /// @param randomNonce uint256 for the random nonce
  /// @param signature0 bytes for the signature of the validator
  function depositBud(
    uint256 amount,
    uint64 depositId,
    uint256 randomNonce,
    bytes calldata signature0
  ) external override {
    if (!isSignedByAValidator(0, 2, hashDeposit(_msgSender(), amount, depositId, randomNonce), signature0))
      revert invalidPrimarySignature();
    _saveSignatureAsUsed(signature0);
    _depositFT(BUD, amount, depositId, _msgSender());
  }

  /// @notice Deposits SEEDs to message sender and pays another user
  /// @dev This function revert with "signatureAlreadyUsed" in
  ///      _saveSignatureAsUsed if the signature was already used
  /// @param amount uint256 for the amount of SEEDs to deposit
  /// @param depositId uint64 for the deposit id
  /// @param nftTokenType uint8 for the type of NFT
  /// @param recipient address for the recipient of the SEEDs
  /// @param randomNonce uint256 for the random nonce
  /// @param signature0 bytes for the signature of the validator
  function depositSeedAndPayOtherUser(
    uint256 amount,
    uint64 depositId,
    uint8 nftTokenType,
    address recipient,
    uint256 randomNonce,
    bytes calldata signature0
  ) external override {
    if (
      !isSignedByValidator(
        0,
        hashDepositAndPay(_msgSender(), amount, depositId, nftTokenType, recipient, randomNonce),
        signature0
      )
    ) revert invalidPrimarySignature();
    _saveSignatureAsUsed(signature0);
    if (recipient == address(0) || recipient == address(this)) revert invalidRecipient();
    uint256 percentage = nftTokenType == TURF ? 92 : nftTokenType == FARM ? 95 : 0;
    if (percentage == 0) revert invalidNFT();
    uint256 amountToOwner = amount.mul(percentage).div(100);
    seedToken.transferFrom(_msgSender(), recipient, amountToOwner);
    _depositFT(SEED, amount.sub(amountToOwner), depositId, _msgSender());
    emit NewDepositAndPay(depositId, _msgSender(), recipient);
  }

  /// @notice Deposits amount of token to user account
  /// @dev it will revert if spend not approved or if insufficient balance
  ///      appends a Deposit to the user's deposits array _users[].deposits
  /// @param tokenType type of token to deposit
  /// @param amount amount of token to deposit
  /// @param depositId the id of the deposit based on User.lastDepositId
  /// @param user the address of the user
  function _depositFT(
    uint8 tokenType,
    uint256 amount,
    uint64 depositId,
    address user
  ) internal {
    Deposit memory deposit = Deposit({tokenType: tokenType, amount: amount, depositedAt: uint32(block.timestamp)});
    _depositsById[depositId] = DepositInfo({index: uint16(_users[user].deposits.length), user: user});
    _users[user].deposits.push(deposit);
    if (tokenType == SEED) {
      seedToken.transferFrom(user, address(this), amount);
    } else {
      budToken.transferFrom(user, address(this), amount);
    }
    emit NewDeposit(depositId, user, tokenType, amount);
  }

  /// @notice Returns the deposit by index or an emoty deposit if index is out of bounds
  /// @param user address of the user
  /// @param index uint256 for the index of the deposit
  function depositByIndex(address user, uint256 index) public view override returns (Deposit memory) {
    if (_users[user].deposits.length <= index) {
      Deposit memory emptyDeposit;
      return emptyDeposit;
    } else {
      return _users[user].deposits[index];
    }
  }

  /// @notice Returns the number of deposits for user
  /// @param user address of the user
  /// @return uint256 for the number of deposits
  function numberOfDeposits(address user) external view override returns (uint256) {
    return _users[user].deposits.length;
  }

  /// @notice Returns the deposit by id
  /// @param depositId uint64 for the deposit id
  /// @return Deposit struct
  function depositById(uint64 depositId) external view override returns (Deposit memory) {
    DepositInfo memory info = _depositsById[depositId];
    return depositByIndex(info.user, uint256(info.index));
  }

  /// @notice Returns the deposit by id and user
  /// @param depositId uint64 for the deposit id
  /// @return Deposit struct
  /// @return address of the user
  function depositByIdAndUser(uint64 depositId) external view override returns (Deposit memory, address) {
    DepositInfo memory info = _depositsById[depositId];
    return (depositByIndex(info.user, uint256(info.index)), info.user);
  }

  /// @notice Harvests amount of BUDs
  /// @dev It will revert if the deadline has passed or if the signatures are invalid
  ///      This function revert with "signatureAlreadyUsed" in
  ///      _saveSignatureAsUsed if the signature was already used
  ///      Note: the current flow relies on the validator to validate transactions, if
  ///      validators are compromised, the system is compromised as well. This is not
  ///      a viable solution in the long term. The amount of harvestable tokens should
  ///      be derived from parameters on chain that cannot be forced or exploited.
  /// @param amount amount of BUDs to mint
  /// @param deadline timestamp after which the transaction will revert
  /// @param randomNonce random nonce to prevent replay attacks (used in signing)
  /// @param opId operation id to prevent replay attacks (used in signing)
  function harvest(
    uint256 amount,
    uint256 deadline,
    uint256 randomNonce,
    uint64 opId,
    bytes calldata signature0,
    bytes calldata signature1
  ) external override {
    if (deadline <= block.timestamp) revert harvestingExpired();
    if (!isSignedByAValidator(0, 2, hashHarvesting(_msgSender(), amount, deadline, randomNonce, opId), signature0))
      revert invalidPrimarySignature();
    if (!isSignedByAValidator(1, 3, hashHarvesting(_msgSender(), amount, deadline, randomNonce, opId), signature1))
      revert invalidSecondarySignature();
    _saveSignatureAsUsed(signature0);
    _saveSignatureAsUsed(signature1);
    budToken.mint(_msgSender(), amount);
    emit Harvested(_msgSender(), amount, opId);
  }

  // THIS IS NOT USED, can we remove it?
  // /// @notice Returns true if the signature has been used before
  // /// @param signature bytes for the signature
  // function isSignatureUsed(bytes calldata signature) external view returns (bool) {
  //   bytes32 key = bytes32(keccak256(abi.encodePacked(signature)));
  //   return _usedSignatures[key];
  // }

  /// @notice Withdraws an amount of funds in SEEDS or BUDS, or all of them if amount is 0
  /// @dev The token emits a Transfer event with the pool as the sender,
  ///      the beneficiary as the receiver and the (amount - burned) as the value
  ///      "burned" is calculated as amount * conf.burningPoints / 10000
  /// @param tokenType The type of token to withdraw
  /// @param amount The amount of tokens to withdraw
  /// @param beneficiary The address to which the tokens will be sent
  function withdrawFT(
    uint8 tokenType,
    uint256 amount,
    address beneficiary
  ) external override onlyOwner {
    uint256 balance;
    if (tokenType == SEED) {
      balance = seedToken.balanceOf(address(this));
    } else {
      balance = budToken.balanceOf(address(this));
    }
    if (balance < amount) revert amountNotAvailable();
    if (amount == 0) {
      amount = balance;
    }
    uint256 burned = amount.mul(conf.burningPoints).div(10000);
    if (tokenType == SEED) {
      seedToken.burn(burned);
      seedToken.transfer(beneficiary, amount.sub(burned));
    } else {
      budToken.burn(burned);
      budToken.transfer(beneficiary, amount.sub(burned));
    }
  }

  /// @notice Initializes the attributes of a turf token
  /// @dev This function will fail if the contract has not been
  ///      approved to spend the token.
  ///      For more details see IAttributable.sol
  /// @param turfId The id of the token
  function initializeTurf(uint256 turfId) external override onlyOwner {
    turfToken.initializeAttributesFor(turfId, address(this));
  }

  /// @notice Updates the attributes of a turf token
  /// @dev This function revert with "signatureAlreadyUsed" in
  ///      _saveSignatureAsUsed if the signature was already used
  ///      note:that if attributes.level is 0, the player de-authorizes itself
  ///      look at SuperpowerNFTBase.sol for more details
  /// @param tokenId The id of the token
  /// @param attributes The attributes to update
  /// @param randomNonce random nonce to prevent replay attacks (used in signing)
  /// @param signature0 signature of the first validator
  /// @param signature1 signature of the second validator
  function updateTurfAttributes(
    uint256 tokenId,
    IAsset.TurfAttributes calldata attributes,
    uint256 randomNonce,
    bytes calldata signature0,
    bytes calldata signature1
  ) external override {
    if (!isSignedByAValidator(0, 2, hashTurfAttributes(tokenId, attributes, randomNonce), signature0))
      revert invalidPrimarySignature();
    if (!isSignedByAValidator(1, 3, hashTurfAttributes(tokenId, attributes, randomNonce), signature1))
      revert invalidSecondarySignature();
    _saveSignatureAsUsed(signature0);
    _saveSignatureAsUsed(signature1);

    turfToken.updateAttributes(tokenId, 0, uint256(attributes.level));
  }

  /// @notice Returns the attributes of a turf token
  /// @param turfId The id of the token
  function getTurfAttributes(uint256 turfId) external view override returns (IAsset.TurfAttributes memory) {
    return IAsset.TurfAttributes({level: uint8(turfToken.attributesOf(turfId, address(this), 0))});
  }

  /// @notice Initializes the attributes of a farm
  /// @dev This function will fail if the contract has not been
  ///      approved to spend the token.
  /// @param farmId The id of the token
  function initializeFarm(uint256 farmId) external override onlyOwner {
    // This will fail if the the contract has not been approved
    // to spend the token
    farmToken.initializeAttributesFor(farmId, address(this));
  }

  /// @notice Updates the attributes of a farm token
  /// @dev This function revert with "signatureAlreadyUsed" in
  ///      _saveSignatureAsUsed if the signature was already used
  ///      note: that if attributes.level is 0, the player de-authorizes itself
  ///      look at SuperpowerNFTBase.sol for more details
  ///      look at iAsset.sol for details on the attributes encoding
  /// @param tokenId The id of the token
  /// @param attributes The attributes to update
  /// @param randomNonce random nonce to prevent replay attacks (used in signing)
  /// @param signature0 signature of the first validator
  /// @param signature1 signature of the second validator
  function updateFarmAttributes(
    uint256 tokenId,
    IAsset.FarmAttributes calldata attributes,
    uint256 randomNonce,
    bytes calldata signature0,
    bytes calldata signature1
  ) external {
    if (!isSignedByAValidator(0, 2, hashFarmAttributes(tokenId, attributes, randomNonce), signature0))
      revert invalidPrimarySignature();
    if (!isSignedByAValidator(1, 3, hashFarmAttributes(tokenId, attributes, randomNonce), signature1))
      revert invalidSecondarySignature();
    _saveSignatureAsUsed(signature0);
    _saveSignatureAsUsed(signature1);
    uint256 attributes2 = uint256(attributes.level) |
      (uint256(attributes.farmState) << 8) |
      (uint256(attributes.currentHP) << 16) |
      (uint256(attributes.weedReserves) << 48);
    farmToken.updateAttributes(tokenId, 0, attributes2);
  }

  /// @notice Returns the attributes of a farm
  /// @param farmId The id of the token
  /// @return The attributes of the farm
  function getFarmAttributes(uint256 farmId) external view returns (IAsset.FarmAttributes memory) {
    uint256 attributes = farmToken.attributesOf(farmId, address(this), 0);
    return
      IAsset.FarmAttributes({
        level: uint8(attributes),
        farmState: uint8(attributes >> 8),
        currentHP: uint32(attributes >> 16),
        weedReserves: uint32(attributes >> 48)
      });
  }

  /// @notice Returns the attributes of a token
  /// @dev Attributes encoding is specific to each token type
  /// @param _token The address of the token
  /// @param tokenId The id of the token
  /// @return string the attributes of the token encoded as a string
  function attributesOf(address _token, uint256 tokenId) external view override returns (string memory) {
    if (_token == address(turfToken)) {
      uint256 attributes = turfToken.attributesOf(tokenId, address(this), 0);
      if (attributes != 0) {
        return string(abi.encodePacked("uint8 level:", StringsUpgradeable.toString(uint8(attributes))));
      }
    } else if (_token == address(farmToken)) {
      uint256 attributes = farmToken.attributesOf(tokenId, address(this), 0);
      if (attributes != 0) {
        return
          string(
            abi.encodePacked(
              "uint8 level:",
              StringsUpgradeable.toString(uint8(attributes)),
              ";uint8 farmState:",
              StringsUpgradeable.toString(uint8(attributes >> 8)),
              ";uint32 currentHP:",
              StringsUpgradeable.toString(uint32(attributes >> 16)),
              ";uint32 weedReserves:",
              StringsUpgradeable.toString(uint32(attributes >> 48))
            )
          );
      }
    }
    return "";
  }

  /// @notice Returns a hash of the parameters adding chainId for security
  /// @param user The user address
  /// @param amount The amount of the deposit
  /// @param depositId The id of the deposit
  /// @param randomNonce random nonce
  /// @return bytes32 the hash of the parameters
  function hashDeposit(
    address user,
    uint256 amount,
    uint256 depositId,
    uint256 randomNonce
  ) public view returns (bytes32) {
    return
      keccak256(
        abi.encodePacked(
          "\x19\x01", // EIP-191
          block.chainid,
          user,
          amount,
          depositId,
          randomNonce
        )
      );
  }

  /// @notice Returns a hash of the parameters adding chainId for security
  /// @param user The user address
  /// @param amount The amount of the deposit
  /// @param depositId The id of the deposit
  /// @param nftTokenType The type of the NFT token
  /// @param recipient The recipient of the NFT token
  /// @param randomNonce random nonce
  /// @return bytes32 the hash of the parameters
  function hashDepositAndPay(
    address user,
    uint256 amount,
    uint64 depositId,
    uint8 nftTokenType,
    address recipient,
    uint256 randomNonce
  ) public view returns (bytes32) {
    return
      keccak256(
        abi.encodePacked(
          "\x19\x01", // EIP-191
          block.chainid,
          user,
          amount,
          depositId,
          nftTokenType,
          recipient,
          randomNonce
        )
      );
  }

  /// @notice Returns a hash of the parameters adding chainId for security
  /// @param user The user address
  /// @param amount The amount of the deposit
  /// @param deadline The deadline of the deposit
  /// @param randomNonce random nonce
  /// @param opId The id of the operation
  /// @return bytes32 the hash of the parameters
  function hashHarvesting(
    address user,
    uint256 amount,
    uint256 deadline,
    uint256 randomNonce,
    uint64 opId
  ) public view override returns (bytes32) {
    return
      keccak256(
        abi.encodePacked(
          "\x19\x01", // EIP-191
          block.chainid,
          user,
          amount,
          deadline,
          randomNonce,
          opId
        )
      );
  }

  /// @notice Returns a hash of the parameters adding chainId for security
  /// @param tokenId The id of the token
  /// @param attributes The attributes of the token
  /// @param randomNonce random nonce
  /// @return bytes32 the hash of the parameters
  function hashFarmAttributes(
    uint256 tokenId,
    IAsset.FarmAttributes calldata attributes,
    uint256 randomNonce
  ) public view override returns (bytes32) {
    return
      keccak256(
        abi.encodePacked(
          "\x19\x01", // EIP-191
          block.chainid,
          tokenId,
          attributes.level,
          attributes.farmState,
          attributes.currentHP,
          attributes.weedReserves,
          randomNonce
        )
      );
  }

  /// @notice Returns a hash of the parameters adding chainId for security
  /// @param tokenId The id of the token
  /// @param attributes The attributes of the token
  /// @param randomNonce random nonce
  /// @return bytes32 the hash of the parameters
  function hashTurfAttributes(
    uint256 tokenId,
    IAsset.TurfAttributes calldata attributes,
    uint256 randomNonce
  ) public view override returns (bytes32) {
    return
      keccak256(
        abi.encodePacked(
          "\x19\x01", // EIP-191
          block.chainid,
          tokenId,
          attributes.level,
          randomNonce
        )
      );
  }
}