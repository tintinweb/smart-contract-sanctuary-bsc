/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

//SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

contract DeadContract {

    function destroy(address payable _account) external {
        selfdestruct(_account);
    }

}