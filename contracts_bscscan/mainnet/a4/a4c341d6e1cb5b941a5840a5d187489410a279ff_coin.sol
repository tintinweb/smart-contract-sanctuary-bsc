/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

pragma solidity >=0.4.99 <0.7.0;

// bonjour tout le monde ! 
// check mon premier smart contract

contract coin {
    // le mot-clé "public" rend ces variables 
    //facilement accessible de l'exterieur.
    address public minter;
    mapping (address => uint) public balances;

    // les events autorisent les clients legers à réagir
    // aux changement efficacement.
    event sent(address from, address to, uint amount);

    // C'est le constructor, code qui n'est exécuté 
    // qu'à la création du contrat.
    constructor() public {
        minter = msg.sender;
    }

    function mint (address receiver, uint amount) public {
        assert(msg.sender == minter);
        assert(amount < 1e60);
        balances[receiver] += amount;
    }

    function send(address receiver, uint amount) public {
        require(amount <= balances[msg.sender], "Insufficient balance.");
        balances[msg.sender] -=amount;
        balances[receiver] += amount;
        emit sent(msg.sender, receiver, amount);
    }
}