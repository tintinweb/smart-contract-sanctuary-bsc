/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BridgeAssistB {
    address public owner;
    IBEP20 public TKN;

    modifier restricted() {
        require(msg.sender == owner, "This function is restricted to owner");
        _;
    }

    event BridgeAssistUpload(address indexed sender, uint256 amount, string target);
    event Dispense(address indexed sender, uint256 amount);
    event TransferOwnership(address indexed previousOwner, address indexed newOwner);

    function upload(uint256 amount, string memory target) public returns (bool success) {
        TKN.transferFrom(msg.sender, address(this), amount);
        emit BridgeAssistUpload(msg.sender, amount, target);
        return true;
    }

    function dispense(address recipient, uint256 _amount) public restricted returns (bool success) {
        TKN.transfer(recipient, _amount);
        emit Dispense(recipient, _amount);
        return true;
    }

    function transferOwnership(address _newOwner) public restricted {
        require(_newOwner != address(0), "Invalid address: should not be 0x0");
        emit TransferOwnership(owner, _newOwner);
        owner = _newOwner;
    }

    function infoBundle(address user)
        external
        view
        returns (
            IBEP20 token,
            uint256 all,
            uint256 bal
        )
    {
        return (TKN, TKN.allowance(user, address(this)), TKN.balanceOf(user));
    }

    constructor(IBEP20 _TKN) {
        TKN = _TKN;
        owner = msg.sender;
    }
}