/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// SPDX-License-Identifier: none

pragma solidity 0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value);
}

contract MultiSender is Context {
    function transferToken(IERC20 token, address[] memory addresses, uint256[] memory amounts) external {
        //first approve token
        uint amount;
        for (uint256 i = 0; i < amounts.length; i++)
            amount = amount + amounts[i];

        IERC20(token).transferFrom(_msgSender(), address(this), amount);
        for (uint256 i = 0; i < amounts.length; i++) {
            IERC20(token).transfer(addresses[i], amounts[i]);
        }
    }

    function transferETH(address payable[] memory addresses, uint256[] memory amounts) external payable {
        uint256 amount;    
        for (uint i=0; i < amounts.length; i++) {
            amount += amounts[i];
        }
        require(addresses.length == amounts.length, "Number of Addresses does not equal amounts.");
        require(amount == msg.value, "Number of Addresses does not equal amounts.");

        for (uint256 i = 0; i < amounts.length; i++) {
            addresses[i].transfer(amounts[i]);
        }
    }
}