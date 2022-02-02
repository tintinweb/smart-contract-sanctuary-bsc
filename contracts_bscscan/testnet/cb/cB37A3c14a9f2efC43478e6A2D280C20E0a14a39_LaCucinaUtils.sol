/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract LaCucinaUtils {
   function isContracts(address[] memory accounts) external view returns (bool[] memory result) {
        bool[] memory resultData = new bool[](accounts.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            bool res= isContract(accounts[i]);
           resultData[i] = res;
        }
        result = resultData;
    }

    function isContract(address account) public view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}