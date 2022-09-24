/**
 *Submitted for verification at BscScan.com on 2022-09-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract pool2 {

    address OWNER = 0x075D29D70FF3d5AD1a2569bba6F581CBf2be7Cee; //Aqui va la address owner
    address payable OWNERpay;
    IERC20 usdt = IERC20(address(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd));  //USDT in BSC testnet

    //Obtener el balance del contrato
    function getContractBalance() public view returns (uint) {
        return usdt.balanceOf(address(this));
    }

    function approveUsdt(address _spender, uint256 _amount) public {
        require(msg.sender == OWNER , "You are not the Owner of contract");
        usdt.approve(_spender, _amount);
    }

    //Retiro de dinero
    function withdrawAll(address payable _to ,uint _withdrawalAmount, uint _percentage) external {
        require(msg.sender == OWNER , "You are not the Owner of contract");
        uint royaltyAmount = _withdrawalAmount / 100 * _percentage;   //setear porcentaje de comision
        _withdrawalAmount = _withdrawalAmount - royaltyAmount;

        //royalty
        OWNERpay = payable (OWNER);
        usdt.transferFrom(address(this), OWNERpay, royaltyAmount);

        usdt.transferFrom(address(this), _to, _withdrawalAmount);
    }

}