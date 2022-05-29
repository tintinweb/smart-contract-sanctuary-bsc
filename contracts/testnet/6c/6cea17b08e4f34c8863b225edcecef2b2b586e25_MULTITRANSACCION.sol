/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

// SPDX-License-Identifier: mit

pragma solidity ^0.8.0;

contract MULTITRANSACCION {

    function pagos(address persona1, address persona2) external payable {
        uint256 pago = msg.value / 2;


        payable(persona1).transfer(pago);
        payable(persona2).transfer(pago);
    }

}