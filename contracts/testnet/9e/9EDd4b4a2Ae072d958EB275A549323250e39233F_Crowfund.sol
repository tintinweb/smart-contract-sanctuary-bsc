/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

//ejemplo de un crowdfund (juntar plata para algo)
contract Crowfund {
    // variables (q uso en el contructor)
    string public id;
    string public name;
    string public description;
    address payable public author;

    //variables ....q no uso en el costructor
    //string public state = "Opened"; 0 open 1 close
    uint256 public state = 0; // 0 open 1 close
    uint256 public funds;
    uint256 public fundraisingGoal;

    // evento para saber quien aporto y cuanto queda para llegar al objetivo
    event ChangeFound(address editor, uint256 fundRestante);

    // constructor (solo se ejecutal al momento del despliegue)
    constructor(
        string memory _id,
        string memory _name,
        string memory _description,
        uint256 _fundraisingGoal
    ) {
        id = _id;
        name = _name;
        description = _description;
        fundraisingGoal = _fundraisingGoal;
        author = payable(msg.sender);
    }

    // controlo q solo el dueño pueda cambiar el estado
    modifier onlyOwner() {
        require(
            msg.sender == author,
            "Only owner can change the project state."
        );
        //require(msg.sender == author , "Only owner can change the project state.");
        //la función es insertada en donde aparece este símbolo
        _;
    }

    // controlo q el dueño no pueda aportar
    modifier notOwner() {
        require(msg.sender != author, "Owner cannot add to the proyect.");
        //la función es insertada en donde aparece este símbolo
        _;
    }

    // funcion para aportar
    //function fundProject() public payable notOwner {
    function fundProject() public payable notOwner {
        require(state == 0, "Proyect is closed");
        require(msg.value > 0, "Not mouse acepted.");
        require((funds + msg.value) <= fundraisingGoal, "Overfound! ");
        author.transfer(msg.value); // usar el call en su lugar
        funds += msg.value;
        emit ChangeFound(msg.sender, fundraisingGoal - funds);
    }

    // funcion para cambiar el estado del proyecto
    //function changeProjectState(string calldata newState) public onlyOwner {
    function changeProjectState(uint256 newState) public onlyOwner {
        require(newState == 0 || newState == 1, "Value not defined");
        require(newState != state, "State must be different");
        state = newState;
    }
}