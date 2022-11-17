// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./AtlantisPriceOracleStorage.sol";

contract AtlantisPriceOracleProxy is AtlantisPriceOracleAdminStorage {
    /**
     * @notice Emitted when pendingAtlantisPriceOracleImplementation is changed
     */
    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);

    /**
     * @notice Emitted when pendingAtlantisPriceOracleImplementation is accepted, which means Community Vault implementation is updated
     */
    event NewImplementation(address oldImplementation, address newImplementation);

    /**
     * @notice Emitted when pendingAdmin is changed
     */
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    /**
     * @notice Emitted when pendingAdmin is accepted, which means admin is updated
     */
    event NewAdmin(address oldAdmin, address newAdmin);

    constructor() {
        // Set admin to caller
        admin = msg.sender;
    }

    /*** Admin Functions ***/
    function _setPendingImplementation(address newPendingImplementation) external {
        // Reverts if the caller is not admin
        require(msg.sender == admin, "only admin");

        address oldPendingImplementation = pendingAtlantisPriceOracleImplementation;
        pendingAtlantisPriceOracleImplementation = newPendingImplementation;

        emit NewPendingImplementation(oldPendingImplementation, pendingAtlantisPriceOracleImplementation);
    }

    /**
     * @notice Accepts new implementation of AtlantisPriceOracle. msg.sender must be pendingImplementation
     * @dev Admin function for new implementation to accept it's role as implementation
     */
    function _acceptImplementation() external {
        // Reverts if the caller is not pending atlantis price oracle implementation
        require(msg.sender == pendingAtlantisPriceOracleImplementation, "only pending implementation");

        // Save current values for inclusion in log
        address oldImplementation = implementation;
        address oldPendingImplementation = pendingAtlantisPriceOracleImplementation;

        implementation = pendingAtlantisPriceOracleImplementation;
        pendingAtlantisPriceOracleImplementation = address(0);

        emit NewImplementation(oldImplementation, implementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingAtlantisPriceOracleImplementation);
    }

    /**
     * @notice Begins transfer of admin rights. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
     * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
     * @param newPendingAdmin New pending admin.
     */
    function _setPendingAdmin(address newPendingAdmin) external {
        // Reverts if the caller is not admin
        require(msg.sender == admin, "only admin");

        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;

        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;

        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    /**
     * @notice Accepts transfer of admin rights. msg.sender must be pendingAdmin
     * @dev Admin function for pending admin to accept role and update admin
     */
    function _acceptAdmin() external {
        // Reverts if the caller is not pending admin
        require(msg.sender == pendingAdmin, "only pending admin");

        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        // Store admin with value pendingAdmin
        admin = pendingAdmin;

        // Clear the pending value
        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

    /**
     * @dev Delegates execution to an implementation contract.
     * It returns to the external caller whatever the implementation returns
     * or forwards reverts.
     */
    fallback() external payable {
        // delegate all other functions to current implementation
        (bool success, ) = implementation.delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())

            switch success
            case 0 {
                revert(free_mem_ptr, returndatasize())
            }
            default {
                return(free_mem_ptr, returndatasize())
            }
        }
    }

    receive() external payable {
        // custom function code
    }
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "@binance-oracle/binance-oracle-starter/contracts/interfaces/AggregatorV2V3Interface.sol";

contract AtlantisPriceOracleAdminStorage {
    /**
    * @notice Administrator for this contract
    */
    address public admin;

    /**
    * @notice Pending administrator for this contract
    */
    address public pendingAdmin;

    /**
    * @notice Active brains of Atlantis Binance Oracle
    */
    address public implementation;

    /**
    * @notice Pending brains of Atlantis Binance Oracle
    */
    address public pendingAtlantisPriceOracleImplementation;
}

contract AtlantisPriceOracleStorage is AtlantisPriceOracleAdminStorage {
    mapping(bytes32 => AggregatorV2V3Interface) internal feeds;
    mapping(address => uint) internal prices;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AggregatorInterface.sol";
import "./AggregatorV3Interface.sol";

interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface {}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

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