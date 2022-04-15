/**
* ENGA Federation QuorumStrategy.
* @author @Mehdikovic
* Date created: 2022.02.15
* Github: mehdikovic
* SPDX-License-Identifier: MIT
*/

pragma solidity ^0.8.0;

import "../interfaces/multisig/IQuorumStrategy.sol";

contract QuorumStrategy is IQuorumStrategy {
    function allQuorum(uint256 _coreCount, uint256 _councilCount) public override pure returns (uint256) {
         if (_coreCount > _councilCount)
            return coreQuorum(_coreCount, _councilCount);
        else
            return _councilCount + 1;
    }

    //solhint-disable-next-line
    function coreQuorum(uint256 _coreCount, uint256) public override pure returns (uint256) {
        return uint256(_coreCount / 2) + 1; // 5 / 2 + 1 = 3
    }

    //solhint-disable-next-line
    function councilQuorum(uint256, uint256 _councilCount) public override pure returns (uint256) {
        return (_councilCount / 4) + 2;
    }
}

/**
* QuorumStrategy Interface.
* @author @Mehdikovic
* Date created: 2022.02.15
* Github: mehdikovic
* SPDX-License-Identifier: MIT
*/

pragma solidity ^0.8.0;

interface IQuorumStrategy {
    function allQuorum(uint256 _coreCount, uint256 _councilCount) external pure returns (uint256);
    function coreQuorum(uint256 _coreCount, uint256 _councilCount) external pure returns (uint256);
    function councilQuorum(uint256 _coreCount, uint256 _councilCount) external pure returns (uint256);
}