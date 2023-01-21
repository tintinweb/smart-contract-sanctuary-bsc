/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

enum Module {
    RESOLVER,
    TIME,
    PROXY,
    SINGLE_EXEC
}

struct ModuleData {
    Module[] modules;
    bytes[] args;
}

interface IOps {
    function createTask(
        address execAddress,
        bytes calldata execDataOrSelector,
        ModuleData calldata moduleData,
        address feeToken
    ) external returns (bytes32 taskId);

    function cancelTask(bytes32 taskId) external;

    function getFeeDetails() external view returns (uint256, address);

    function gelato() external view returns (address payable);

    function taskTreasury() external view returns (ITaskTreasuryUpgradable);
}

interface ITaskTreasuryUpgradable {
    function depositFunds(
        address receiver,
        address token,
        uint256 amount
    ) external payable;

    function withdrawFunds(
        address payable receiver,
        address token,
        uint256 amount
    ) external;
}

contract GelatoConsumer {

    bytes32 public stateVariable = 0x1000000000000000000000000000000000000000000000000000000000000001;

    IOps immutable gelatoAutomationAddress;
    address immutable gelatoTaskOwner;

    error InsufficientBalance(uint);

    constructor(address gelatoOps) {
        gelatoAutomationAddress = IOps(gelatoOps);
        gelatoTaskOwner = msg.sender;
    }

    receive() external payable {}

    function withdraw() public {
        require(msg.sender == gelatoTaskOwner);
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }

    function gelatoChecker() public view returns(bool canExec, bytes memory payload) {
        canExec = stateVariable == 0x2000000000000000000000000000000000000000000000000000000000000002;
        payload = abi.encodeWithSelector(
            this.gelatoCallTarget.selector,
            bytes32(0x1000000000000000000000000000000000000000000000000000000000000001)
        );
    }

    function gelatoCallTarget(bytes memory newState) public {
      
        // parse arguments
        bytes32 argument;
        assembly {
            argument := or(
                shl( 32, mload(add(newState, 32))), 
                shr(224, mload(add(newState, 64)))
            )
        }

        // change contract state based on parse arguments
        if(stateVariable == 0x2000000000000000000000000000000000000000000000000000000000000002) {
            stateVariable = argument;
        }

        // refund gelato task owner

        (uint256 fee,) = gelatoAutomationAddress.getFeeDetails();

        if(fee > address(this).balance) revert InsufficientBalance(fee);

        if(fee != 0) {
            ITaskTreasuryUpgradable(
                gelatoAutomationAddress.taskTreasury()
            ).depositFunds{
                value: fee
            }(
                gelatoTaskOwner,
                // indicating we are depositing native gas token
                0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,
                fee
            );
        }
    }

    function manuallyChangeStateAndMakeExecutable() public {
        stateVariable = 0x2000000000000000000000000000000000000000000000000000000000000002;
    }

}