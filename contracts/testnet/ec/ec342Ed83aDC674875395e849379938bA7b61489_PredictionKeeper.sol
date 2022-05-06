// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink-0.4.0/contracts/src/v0.8/KeeperCompatible.sol";
import "./interfaces/IPrediction.sol";

contract PredictionKeeper is KeeperCompatibleInterface {
    address public PredictionContract = 0xd88142186c79A16eA643fCb4eBa7dDF6f108390a;

    constructor() {
        
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        bool genesisStartOnce = IPrediction(PredictionContract).genesisStartOnce();
        bool genesisLockOnce = IPrediction(PredictionContract).genesisLockOnce();
        bool paused = IPrediction(PredictionContract).paused();
        uint256 currentEpoch = IPrediction(PredictionContract).currentEpoch();
        uint256 bufferSeconds = IPrediction(PredictionContract).bufferSeconds();
        (, , uint256 lockTimestamp, ) = IPrediction(PredictionContract).currentEpochRoundInfo();
        if (paused) {
            upkeepNeeded = false;
        } else {
            if (!genesisStartOnce) {
                upkeepNeeded = true;
            } else if (!genesisLockOnce) {
                // Too early for locking of round, skip current job (also means previous lockRound was successful)
                if (lockTimestamp == 0 || block.timestamp < lockTimestamp) {
                    upkeepNeeded = false;
                } else if (lockTimestamp != 0 && block.timestamp > (lockTimestamp + bufferSeconds)) {
                    // Too late to lock round, need to pause
                    upkeepNeeded = true;
                } else {
                    //run genesisLockRound
                    upkeepNeeded = true;
                }
            } else {
                if (block.timestamp > lockTimestamp) {
                    // Too early for end/lock/start of round, skip current job
                    if (lockTimestamp == 0 || block.timestamp < lockTimestamp) {
                        upkeepNeeded = false;
                    } else if (lockTimestamp != 0 && block.timestamp > (lockTimestamp + bufferSeconds)) {
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

    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        bool genesisStartOnce = IPrediction(PredictionContract).genesisStartOnce();
        bool genesisLockOnce = IPrediction(PredictionContract).genesisLockOnce();
        bool paused = IPrediction(PredictionContract).paused();
        uint256 currentEpoch = IPrediction(PredictionContract).currentEpoch();
        uint256 bufferSeconds = IPrediction(PredictionContract).bufferSeconds();
        (, , uint256 lockTimestamp, ) = IPrediction(PredictionContract).currentEpochRoundInfo();
        if (paused) {
            // unpause operation
        } else {
            if (!genesisStartOnce) {
                IPrediction(PredictionContract).genesisStartRound();
            } else if (!genesisLockOnce) {
                // Too early for locking of round, skip current job (also means previous lockRound was successful)
                if (lockTimestamp == 0 || block.timestamp < lockTimestamp) {} else if (
                    lockTimestamp != 0 && block.timestamp > (lockTimestamp + bufferSeconds)
                ) {
                    // Too late to lock round, need to pause
                    IPrediction(PredictionContract).pause();
                } else {
                    //run genesisLockRound
                    IPrediction(PredictionContract).genesisLockRound();
                }
            } else {
                if (block.timestamp > lockTimestamp) {
                    // Too early for end/lock/start of round, skip current job
                    if (lockTimestamp == 0 || block.timestamp < lockTimestamp) {} else if (
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KeeperBase.sol";
import "./interfaces/KeeperCompatibleInterface.sol";

abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPrediction {
    function rounds(uint256 epoch)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        );
    function currentEpochRoundInfo()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function genesisStartOnce() external view returns (bool);

    function genesisLockOnce() external view returns (bool);

    function paused() external view returns (bool);

    function currentEpoch() external view returns (uint256);

    function bufferSeconds() external view returns (uint256);

    function intervalSeconds() external view returns (uint256);

    function genesisStartRound() external;

    function pause() external;

    function genesisLockRound() external;

    function executeRound() external;





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