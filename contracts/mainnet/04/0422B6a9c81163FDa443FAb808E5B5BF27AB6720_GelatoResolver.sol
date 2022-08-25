// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ICLInterface {
    function performUpkeep(bytes calldata performData) external;

    function checkUpkeep(bytes calldata checkData)
        external
        view
        returns (bool upkeepNeeded, bytes memory performData);
}

contract GelatoResolver {
    function checker(ICLInterface _clc, bytes calldata checkData)
        external
        view
        returns (bool canExec, bytes memory execData)
    {
        bytes memory performData;

        (canExec, performData) = _clc.checkUpkeep(checkData);

        execData = abi.encodeWithSelector(
            ICLInterface.performUpkeep.selector,
            performData
        );
    }
}