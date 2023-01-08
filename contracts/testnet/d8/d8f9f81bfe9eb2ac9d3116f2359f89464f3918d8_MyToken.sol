/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

pragma solidity ^0.7.0;

contract MyToken {
    // Nombre del token
    string public name;
    // Símbolo del token
    string public symbol;
    // Número de decimales del token
    uint8 public decimals;
    // Dirección del creador del token
    address public owner;
    // Liquidez total disponible
    uint public liquidity;
    // Precio del token en ether
    uint public price;

    constructor() public {
        name = "My Token";
        symbol = "MTK";
        decimals = 18;
        owner = msg.sender;
        liquidity = 0;
        price = 1 ether;
    }

    // Método para realizar compras
    function buy() public payable {
        require(msg.value == price, "Incorrect payment amount");
        require(msg.sender != owner, "The owner cannot buy their own token");
        liquidity += msg.value;
    }

    // Método para consultar la liquidez disponible
    function getLiquidity() public view returns (uint) {
        return liquidity;
    }
}