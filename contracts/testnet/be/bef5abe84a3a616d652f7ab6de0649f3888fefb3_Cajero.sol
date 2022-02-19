/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6 <0.9.0;

contract Cajero {

    address public owner;
    uint256 public resellerShare;
    mapping(address => uint256) public direccionAGanancias;

    constructor() {
        owner = msg.sender;
        resellerShare = 150000000000000000;
    }

    function comprarClaveReferido(address referido) public payable returns (bool) {
        uint256 pagado = (msg.value * resellerShare)/(10 ** 18);
        uint256 ganancias = (msg.value * ((10 ** 18)-resellerShare))/(10 ** 18);
        Enviar(referido, pagado);
        Enviar(owner, ganancias);
        direccionAGanancias[referido] += pagado;

        return true;
    }

function comprarClave() public payable returns (bool) {
        Enviar(owner, msg.value);
        return true;
    }

    function Enviar(address recipiente, uint256 cantidad) internal {
        payable(recipiente).transfer(cantidad);
    }

    function retirarNaboletas() payable public {
        require(msg.sender == owner );
        payable(msg.sender).transfer(address(this).balance);
    }

    function cambiarDueno(address newOwner) public {
        require(msg.sender == owner);
        owner = newOwner;
    }

    function cambiarParteRevendedores(uint256 nuevoCorte) public {
        require(msg.sender == owner);
        resellerShare = nuevoCorte * (10 ** 16);
    }
}