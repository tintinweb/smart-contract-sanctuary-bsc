/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.0;

contract BallotTest {

    // uint256 a = 1;
    struct UserDetail {
        uint96 nonce;
        uint96 checkPointer;
        uint256 fixedDonation;
        uint256 activeDonation;
    }

    mapping(uint256 => UserDetail) public _userDetail;

    function donationInfo()
        external
        returns (bool active)
    {
        require(msg.sender == address(0));
        UserDetail storage user = _userDetail[0];
        user.nonce++;
        return true;
    }
}