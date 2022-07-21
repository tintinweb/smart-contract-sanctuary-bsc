// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "./interfaces/IPrediction.sol";

contract PredictionKeeperETHUSD is KeeperCompatibleInterface, Ownable, Pausable {
    address public PredictionContract = 0xf329bDF8403A61D2d1E1d55Ae1110fE3dc30439C;
    address public register;

    uint256 public constant MaxAheadTime = 30;
    uint256 public aheadTimeForCheckUpkeep = 6;
    uint256 public aheadTimeForPerformUpkeep = 6;

    event NewRegister(address indexed register);
    event NewPredictionContract(address indexed predictionContract);
    event NewAheadTimeForCheckUpkeep(uint256 time);
    event NewAheadTimeForPerformUpkeep(uint256 time);

    constructor() {}

    modifier onlyRegister() {
        require(msg.sender == register || register == address(0), "Not register");
        _;
    }

    //The logic is consistent with the following performUpkeep function, in order to make the code logic clearer.
    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory) {
        if (!paused()) {
            bool genesisStartOnce = IPrediction(PredictionContract).genesisStartOnce();
            bool genesisLockOnce = IPrediction(PredictionContract).genesisLockOnce();
            bool paused = IPrediction(PredictionContract).paused();
            uint256 currentEpoch = IPrediction(PredictionContract).currentEpoch();
            uint256 bufferSeconds = IPrediction(PredictionContract).bufferSeconds();
            IPrediction.Round memory round = IPrediction(PredictionContract).rounds(currentEpoch);
            uint256 lockTimestamp = round.lockTimestamp;

            if (paused) {
                //need to unpause
                upkeepNeeded = true;
            } else {
                if (!genesisStartOnce) {
                    upkeepNeeded = true;
                } else if (!genesisLockOnce) {
                    // Too early for locking of round, skip current job (also means previous lockRound was successful)
                    if (lockTimestamp == 0 || block.timestamp + aheadTimeForCheckUpkeep < lockTimestamp) {} else if (
                        lockTimestamp != 0 && block.timestamp > (lockTimestamp + bufferSeconds)
                    ) {
                        // Too late to lock round, need to pause
                        upkeepNeeded = true;
                    } else {
                        //run genesisLockRound
                        upkeepNeeded = true;
                    }
                } else {
                    if (block.timestamp + aheadTimeForCheckUpkeep > lockTimestamp) {
                        // Too early for end/lock/start of round, skip current job
                        if (
                            lockTimestamp == 0 || block.timestamp + aheadTimeForCheckUpkeep < lockTimestamp
                        ) {} else if (lockTimestamp != 0 && block.timestamp > (lockTimestamp + bufferSeconds)) {
                            // Too late to end round, need to pause
                            upkeepNeeded = true;
                        } else {
                            //run executeRound
                            upkeepNeeded = true;
                        }
                    }
                }
            }
        }
    }

    function performUpkeep(bytes calldata) external override onlyRegister whenNotPaused {
        require(PredictionContract != address(0), "PredictionContract Not Set!");
        bool genesisStartOnce = IPrediction(PredictionContract).genesisStartOnce();
        bool genesisLockOnce = IPrediction(PredictionContract).genesisLockOnce();
        bool paused = IPrediction(PredictionContract).paused();
        uint256 currentEpoch = IPrediction(PredictionContract).currentEpoch();
        uint256 bufferSeconds = IPrediction(PredictionContract).bufferSeconds();
        IPrediction.Round memory round = IPrediction(PredictionContract).rounds(currentEpoch);
        uint256 lockTimestamp = round.lockTimestamp;
        if (paused) {
            // unpause operation
            IPrediction(PredictionContract).unpause();
        } else {
            if (!genesisStartOnce) {
                IPrediction(PredictionContract).genesisStartRound();
            } else if (!genesisLockOnce) {
                // Too early for locking of round, skip current job (also means previous lockRound was successful)
                if (lockTimestamp == 0 || block.timestamp + aheadTimeForPerformUpkeep < lockTimestamp) {} else if (
                    lockTimestamp != 0 && block.timestamp > (lockTimestamp + bufferSeconds)
                ) {
                    // Too late to lock round, need to pause
                    IPrediction(PredictionContract).pause();
                } else {
                    //run genesisLockRound
                    IPrediction(PredictionContract).genesisLockRound();
                }
            } else {
                if (block.timestamp + aheadTimeForPerformUpkeep > lockTimestamp) {
                    // Too early for end/lock/start of round, skip current job
                    if (lockTimestamp == 0 || block.timestamp + aheadTimeForPerformUpkeep < lockTimestamp) {} else if (
                        lockTimestamp != 0 && block.timestamp > (lockTimestamp + bufferSeconds)
                    ) {
                        // Too late to end round, need to pause
                        IPrediction(PredictionContract).pause();
                    } else {
                        //run executeRound
                        IPrediction(PredictionContract).executeRound();
                    }
                }
            }
        }
    }

    function setRegister(address _register) external onlyOwner {
        //When register is address(0), anyone can execute performUpkeep function
        register = _register;
        emit NewRegister(_register);
    }

    function setPredictionContract(address _predictionContract) external onlyOwner {
        require(_predictionContract != address(0), "Cannot be zero address");
        PredictionContract = _predictionContract;
        emit NewPredictionContract(_predictionContract);
    }

    function setAheadTimeForCheckUpkeep(uint256 _time) external onlyOwner {
        require(_time <= MaxAheadTime, "aheadTimeForCheckUpkeep cannot be more than MaxAheadTime");
        aheadTimeForCheckUpkeep = _time;
        emit NewAheadTimeForCheckUpkeep(_time);
    }

    function setAheadTimeForPerformUpkeep(uint256 _time) external onlyOwner {
        require(_time <= MaxAheadTime, "aheadTimeForPerformUpkeep cannot be more than MaxAheadTime");
        aheadTimeForPerformUpkeep = _time;
        emit NewAheadTimeForPerformUpkeep(_time);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KeeperBase.sol";
import "./interfaces/KeeperCompatibleInterface.sol";

abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPrediction {

    struct Round {
        uint256 epoch;
        uint256 startTimestamp;
        uint256 lockTimestamp;
        uint256 closeTimestamp;
        int256 lockPrice;
        int256 closePrice;
        uint256 lockOracleId;
        uint256 closeOracleId;
        uint256 totalAmount;
        uint256 bullAmount;
        uint256 bearAmount;
        uint256 rewardBaseCalAmount;
        uint256 rewardAmount;
        bool oracleCalled;
    }

    function rounds(uint256 epoch)
        external
        view
        returns (Round memory);
    function genesisStartOnce() external view returns (bool);

    function genesisLockOnce() external view returns (bool);

    function paused() external view returns (bool);

    function currentEpoch() external view returns (uint256);

    function bufferSeconds() external view returns (uint256);

    function intervalSeconds() external view returns (uint256);

    function genesisStartRound() external;

    function pause() external;
    function unpause() external;

    function genesisLockRound() external;

    function executeRound() external;

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
pragma solidity ^0.8.0;

contract KeeperBase {

  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}