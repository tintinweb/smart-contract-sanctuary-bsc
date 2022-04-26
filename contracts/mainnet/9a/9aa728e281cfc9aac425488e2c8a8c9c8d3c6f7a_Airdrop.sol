/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: Unlicense

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function balanceOf(address account) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);
}

contract Airdrop {

    constructor() {}

    function bulkAirDrop(IERC20 _token, address[] memory _to, uint256[] memory _value) public {
        require(_to.length == _value.length, "Recievers and amounts are not the same");
        require(_token.allowance(msg.sender, address(this)) > sumOfAllValues(_value), "Allowance given to contract is not correct");
        for (uint256 i = 0 ; i < _to.length ; i++) {
            _token.transferFrom(msg.sender, _to[i], _value[i]);
        }
    }

    function sumOfAllValues(uint256[] memory _value) public pure returns(uint256) {
        uint256 sum = 0;
        for (uint256 i = 0 ; i < _value.length ; i++) {
            sum += _value[i];
        }

        return sum;
    }
}