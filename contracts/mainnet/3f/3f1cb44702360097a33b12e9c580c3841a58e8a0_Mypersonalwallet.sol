/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// La finalidad de este SC es:
// Que el SC siempre holdee una cantidad mínima de 0.02 MATIC.
// poder injectar dinero al SC, cualquier user y cualquier cantidad, con la funcion (ClientToSc).
// poder enviar dinero a cualquier direccion, solo el owner, con la funcion (ScToClient).
// poder retirar todo el dinero quedando siempre un remanente de 0.02 ether, solo el owner, Con la funcion (withdraw).
// poder retirar todos los fondos y cerrar el SC, solo el owner, con la funcion (close)
// poder pedir que nos devuelva el balance en tiempo real, solo el owner. ( en la consola de remix si devuelve el balance pero en matic Scan no) así que tendré que dejarla pública de momento.

contract Mypersonalwallet {
    address payable owner = payable(msg.sender);

    // modificador que obliga a que solo el propietario puede operar
    modifier onlyOwner() {
        require(owner == msg.sender,"No estas autorizado");
        _;
    }    

    // comprueba que se ingrese un mínimo de 0.02 ether en el SC y que el dato de entrada en value y en deploy coincidan de lo contrario devuelve error
    constructor(uint inject) payable {
        require (msg.value == inject,"Writing error");
        if (msg.value >= 0.02 ether) {
        } else { revert("como minimo debe haber 0.02 ether para las fees en el SC");
        }  
    }

    // para ingresar activos al SC
    function ClientToSc() external payable {
        require (msg.value > 0, "valor incorrecto");
    }

    // para realizar pagos
    function ScToClient(address to, uint amount) external onlyOwner {
        if (amount < getBalance() - 0.02 ether) {  
        } else {
            revert("fondos insuficientes");
        }
        address payable _to = payable(to);
        _to.transfer(amount);
    }

    // para poder retirar activos con la particularidad de que siempre tenga un remanente de 0.02 ethers.
    function sCToOwner(uint _amount) external onlyOwner {     
        uint amount = getBalance() - 0.02 ether;
        require (amount >= _amount, "Saldo insuficiente"); 
        if (amount >= 0.02 ether) {
        } else {  
           revert("saldo insuficiente, siempre deben quedar 0.02 MATIC en la caja");
        }
        owner.transfer(_amount);
    }

    // retirar todos los fondos y terminar el contrato.
    function close() external onlyOwner {
        selfdestruct(owner);
    }

    // Devuelve el balance en tiempo real del SC
    function getBalance() public view returns (uint) {
        uint balance = address(this).balance;
        return balance;
    }
}