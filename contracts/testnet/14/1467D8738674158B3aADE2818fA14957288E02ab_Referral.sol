// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
contract Referral {
    mapping(address => address) public sponsor;
    mapping(address => address[]) public ref;
    event Referee (
        address sponsor,
        address user,
        uint blockTime
    );
    function referee(address user, address _sponsor) external {
        require(user != _sponsor && sponsor[_sponsor] != user);
        if(sponsor[user] == address(0) && _sponsor != address(0)){
            sponsor[user] = _sponsor;
            ref[_sponsor].push(user);
            emit Referee(_sponsor, user, block.timestamp);
        }
    }
    function getSponsor(address user) external view returns(address){
        return sponsor[user];
    }
    function getRef(address user) external view returns(address[] memory) {
        return ref[user];
    }
}