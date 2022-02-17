// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.5;

import "./SafeERC20.sol";

import "./Ownable.sol";

interface ITreasury {
    function deposit(
        uint256 _amount,
        address _token,
        uint256 _profit
    ) external returns (uint256);
}

contract BondDepositoryHelper is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public WALT;
    address public BUSD;
    address public treasury;
  
    constructor(
        address _walt,
        address _busd,
        address _treasury
    ) {
        require(_walt != address(0));
        WALT = _walt;
        require(_busd != address(0));
        BUSD = _busd;
        require(_treasury != address(0));
        treasury = _treasury;
    }

    function deposit(uint256 _amount) public onlyOwner() { 
        IERC20(BUSD).safeTransferFrom(msg.sender, address(this), _amount);
        IERC20(BUSD).approve(treasury, _amount);
        uint256 amount = ITreasury(treasury).deposit(_amount, BUSD, 0);
        IERC20(WALT).safeTransfer(msg.sender, amount);
    }
}