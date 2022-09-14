pragma solidity ^0.5.16;

import "./Unimplemented.sol";

interface IMockDebtCache {
    function updateCachedSynthDebts(bytes32[] calldata currencyKeys) external;
}

contract MockDebtCache is Unimplemented, IMockDebtCache {
    function updateCachedSynthDebts(bytes32[] calldata currencyKeys) external { // unprotected
    }
}

pragma solidity ^0.5.16;

contract Unimplemented {
    function() external {
        revert("Unimplemented");
    }
}