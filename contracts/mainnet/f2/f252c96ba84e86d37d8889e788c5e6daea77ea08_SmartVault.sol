/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Owner {
    address private _owner;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnerSet(address(0), _owner);
    }

    function changeOwner(address newOwner) public virtual onlyOwner {
        emit OwnerSet(_owner, newOwner);
        _owner = newOwner;
    }

    function removeOwner() public virtual onlyOwner {
        emit OwnerSet(_owner, address(0));
        _owner = address(0);
    }

    function getOwner() external view returns (address) {
        return _owner;
    }
}

contract SmartVault is Owner {
    IERC20 public usdtToken;
    IERC20 public dorToken;

    function initialize(IERC20 _dorToken) public onlyOwner {
        usdtToken = IERC20(0x55d398326f99059fF775485246999027B3197955);
        dorToken = _dorToken;

        usdtToken.approve(address(dorToken), uint256(-1));
    }

    function approve() external {
        usdtToken.approve(address(dorToken), uint256(-1));
    }

    function transfer(uint256 amount) external {
        usdtToken.transfer(address(dorToken), amount);
    }

    function balance() external view returns(uint256) {
        return usdtToken.balanceOf(address(this));
    }
}