/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function decimals() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

contract CocoMine {
    IERC20 _coco;
    address private _owner;

    constructor(address co){
        _coco = IERC20(co);
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function withdrawCoCo(uint256 amount, address account) public onlyOwner {
        require(amount > 0, "Amount error");
        _coco.transfer(account, amount);
    }
}