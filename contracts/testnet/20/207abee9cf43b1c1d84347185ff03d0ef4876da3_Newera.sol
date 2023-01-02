/**
 *Submitted for verification at BscScan.com on 2023-01-01
*/

pragma solidity ^0.6.0;

contract Newera {
    string public name = "Newera";
    string public symbol = "NEW";
    uint8 public decimals = 18;
    uint256 public totalSupply = 100000000000;

    mapping(address => uint256) public balanceOf;
    address public owner;
    mapping(address => bool) public locked; // Nueva variable para bloquear tokens
    address payable public fundAccount; // Nueva variable para la cuenta de fondos

    constructor() public {
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
        locked[owner] = false; // El propietario no está bloqueado
        fundAccount = msg.sender; // El propietario es dueño de la cuenta de fondos
    }

    function buyTokens(uint256 _value) public payable {
        require(_value > 0, "Invalid value");
        require(msg.value >= _value * 1 ether, "Insufficient funds"); // Se asume que el precio de cada token es 1 ether

        balanceOf[msg.sender] += _value;
        balanceOf[fundAccount] += msg.value; // Los fondos se envían a la cuenta de fondos
        locked[msg.sender] = true; // Los tokens adquiridos se bloquean
    }

    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value && _value > 0, "Insufficient balance or invalid value");
        require(!locked[msg.sender], "Sender's tokens are locked and cannot be transferred"); // Verifica si los tokens están bloqueados
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }

    function unlockTokens(address _account) public {
        require(msg.sender == owner, "Only the owner can unlock tokens"); // Solo el propietario puede desbloquear tokens
        locked[_account] = false;
    }
}