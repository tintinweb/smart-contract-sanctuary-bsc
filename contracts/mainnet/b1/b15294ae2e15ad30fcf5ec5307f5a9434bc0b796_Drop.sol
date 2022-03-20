/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Drop {
    mapping(address => bool) public _roler;

	constructor() {
        _roler[_msgSender()] = true;
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function setRoler(address addr, bool val) public {
        require(_roler[_msgSender()]);
        _roler[addr] = val;
    }

    function drop(address con, uint256 val, address[] memory users) public {
        require(_roler[_msgSender()] && val > 0 && users.length > 0);

        for(uint j = 0; j < users.length; j++) {
            IERC20(con).transferFrom(_msgSender(), users[j], val);
        }
    }

}