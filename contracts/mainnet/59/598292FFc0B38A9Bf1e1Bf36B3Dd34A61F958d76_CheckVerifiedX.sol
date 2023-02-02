// SPDX-License-Identifier: UNLICENSED

import "./VersionId.sol";

pragma solidity 0.8.17;

contract CheckVerifiedX is VersionId {
    string constant public name = "CheckVerifiedX";
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

contract VersionId {
    uint256 constant public versionId = uint256(keccak256("1"));
}