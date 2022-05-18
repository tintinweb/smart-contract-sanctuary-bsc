/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract LifeRaftRouterV1 {
    IERC20 public raftToken;
    IERC20 public tankToken;
    address private _owner;
    address private _burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint public conversionFee = 10;
    uint private _totalSupply;


    constructor(address _raftToken, address _tankToken) {
        raftToken = IERC20(_raftToken);
        tankToken = IERC20(_tankToken);
        _owner = msg.sender;
    }

    function getTankForRaft(uint _amount) external {
        uint burnFee = _amount / conversionFee;
        uint userReceives = _amount - burnFee;
        raftToken.transferFrom(msg.sender, address(this), _amount);
        raftToken.transfer(_burnAddress, _amount);
        tankToken.mint(address(this), userReceives);
        tankToken.transfer(msg.sender, userReceives);
    }

    function getRaftForTank(uint _amount) external {
        uint burnFee = _amount / conversionFee;
        uint userReceives = _amount - burnFee;
        tankToken.transferFrom(msg.sender, address(this), _amount);
        tankToken.transfer(_burnAddress, _amount);
        raftToken.mint(address(this), userReceives);
        raftToken.transfer(msg.sender, userReceives);
    }

    function changeConversionFee(uint _amount) external {
        require(msg.sender == _owner, "Only Protocol Owners May Perform This Change.");
        conversionFee = _amount;
    }


}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function mint(address to, uint256 value) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}