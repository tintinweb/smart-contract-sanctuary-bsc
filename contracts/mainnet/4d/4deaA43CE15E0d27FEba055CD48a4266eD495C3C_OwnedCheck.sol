// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IPYE {
    function getOwnedBalance(address) external view returns(uint256);
}

contract OwnedCheck {

    function getTotalPendingReward(IPYE token, address[] calldata users, uint256[] calldata tiers) external view returns(
        address[] memory _users, 
        uint256[] memory _balance,
        uint256 numTier1,
        uint256 numTier2,
        uint256 numTier3,
        uint256 numTier4,
        uint256 _contracts
    ) {
        require(tiers.length == 4);
        uint256 length = users.length;
        _users = users;
        _balance = new uint256[](length);
        for(uint i = 0; i < users.length; i++) {
            uint32 size;
            address _addr;
            assembly {
                size := extcodesize(_addr)
            }
            if(size > 0){
                _balance[i] = 0;
                _contracts++;
                continue;
            }
            uint256 owned = token.getOwnedBalance(users[i]);
            _balance[i] = owned;
            if(owned < tiers[1]) {
                numTier1++;
            } else if(owned < tiers[2]) {
                numTier2++;
            } else if(owned < tiers[3]) {
                numTier3++;
            } else {
                numTier4++;
            }
        }
    }
}