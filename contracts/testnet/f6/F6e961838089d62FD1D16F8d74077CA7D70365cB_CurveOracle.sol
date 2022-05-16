/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

interface EllipsisOracle {
    function get_virtual_price() external view returns (uint256);
}

contract CurveOracle {
    address ellipsisContractAddr = 0x160CAed03795365F3A589f10C379FfA7d75d4E76;
    address mockContractAddr = 0x727351F57dFc1723a2aE8c175A906FB60480fEAc;

    function getVirtualPrice() public view returns (uint256) {
        return EllipsisOracle(mockContractAddr).get_virtual_price();
    }
}