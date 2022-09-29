/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract pool2 {

    address OWNER = 0x075D29D70FF3d5AD1a2569bba6F581CBf2be7Cee; //  Aqui va la address owner
    address feeDirection = 0xB0499B31981CdB7722C36b4B3198ea033fe44579;//    Address de las comisiones
    IERC20 usdt = IERC20(address(0x55d398326f99059fF775485246999027B3197955));  //  USDT in main

    //  Obtener el balance del contrato
    function getContractBalance() public view returns (uint) {
        return usdt.balanceOf(address(this));
    }

    //  Aprobar capital a mover del contrato
    function approveUsdt(address _spender, uint256 _amount) public {
        require(msg.sender == OWNER , "You are not the Owner of contract");
        usdt.approve(_spender, _amount);
    }

    //  Retiro de dinero
    function withdrawAll(address payable _to ,uint _withdrawalAmount, uint _percentage) external {
        require(msg.sender == OWNER , "You are not the Owner of contract");
        uint royaltyAmount = _withdrawalAmount / 100 * _percentage;
        _withdrawalAmount = _withdrawalAmount - royaltyAmount;

        usdt.transferFrom(address(this), feeDirection, royaltyAmount);//    porcentaje de comisión
        usdt.transferFrom(address(this), _to, _withdrawalAmount);
    }

    //  Cambiar owner y address a donde van las comisiones
    function changeOwnerAndFee (address _owner, address _feeDirection) public {
        require(msg.sender == OWNER , "You are not the Owner of contract");
        OWNER = _owner;
        feeDirection = _feeDirection;
    }

}