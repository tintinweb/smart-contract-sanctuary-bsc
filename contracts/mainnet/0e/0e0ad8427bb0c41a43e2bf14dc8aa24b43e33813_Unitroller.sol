// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./ControllerStorage.sol";

contract Unitroller is UnitrollerAdminStorage {
    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);
    event NewImplementation(address oldImplementation, address newImplementation);

    /// @notice Delegate call to Controller implementation
    /// @notice calldata cannot be empty
    fallback() external payable {
        _delegate();
    }

    /// @notice Revert if calldata is empty
    receive() external payable {
        revert();
    }

    function _delegate() internal {
        (bool success, ) = controllerImplementation.delegatecall(msg.data);

        assembly {
              let free_mem_ptr := mload(0x40)
              returndatacopy(free_mem_ptr, 0, returndatasize())

              switch success
              case 0 { revert(free_mem_ptr, returndatasize()) }
              default { return(free_mem_ptr, returndatasize()) }
        }
    }

    /* ========== ADMIN FUNCTIONS ========== */

    function _setPendingImplementation(address newPendingImplementation) external onlyOwner {
        address oldPendingImplementation = pendingControllerImplementation;

        pendingControllerImplementation = newPendingImplementation;

        emit NewPendingImplementation(oldPendingImplementation, pendingControllerImplementation);
    }

    function _acceptImplementation() external {
        require(pendingControllerImplementation != address(0), "Controller: no pending implementation");
        require(_msgSender() == pendingControllerImplementation, "Controller: !pending implementation");

        address oldImplementation = controllerImplementation;
        address oldPendingImplementation = pendingControllerImplementation;

        controllerImplementation = pendingControllerImplementation;
        pendingControllerImplementation = address(0);

        emit NewImplementation(oldImplementation, controllerImplementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingControllerImplementation);
    }
}