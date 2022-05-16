/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

interface EllipsisOracle {
    function get_virtual_price() external view returns (uint256);
}

interface EllipsisOracleLpToken {
    function get_virtual_price_from_lp_token(address _token) external view returns (uint256);
}

contract CurveOracle {
    address ellipsisContractAddr = 0x160CAed03795365F3A589f10C379FfA7d75d4E76;
    address mockEllipsisOracleAddr = 0x727351F57dFc1723a2aE8c175A906FB60480fEAc;
    address mockEllipsisOracleLpTokenAddr = 0xB588f4B56942c2dD6F4380Ed33cF61D11f486873;

    function getVirtualPrice() public view returns (uint256) {
        return EllipsisOracle(mockEllipsisOracleAddr).get_virtual_price();
    }

    function getVirtualPriceFromLpToken(address _token) public view returns (uint256) {
        return EllipsisOracleLpToken(mockEllipsisOracleLpTokenAddr).get_virtual_price_from_lp_token(_token);
    }
}