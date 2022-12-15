/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

pragma solidity ^0.5.0;

// Contractul smart token
contract SmartToken {
    // Numele token-ului
    string public name;
    // Simbolul token-ului
    string public symbol;
    // Numărul total de token-uri emise
    uint256 public totalSupply;
    // Câți token-uri deține fiecare adresă
    mapping(address => uint256) public balanceOf;
    // Transferul token-urilor dintre adrese
    function transfer(address _to, uint256 _value) public {
        // Verifică dacă există suficienți token-uri pentru transfer
        require(balanceOf[msg.sender] >= _value && _value > 0);
        // Actualizează balanța adreselor implicate în transfer
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }
}