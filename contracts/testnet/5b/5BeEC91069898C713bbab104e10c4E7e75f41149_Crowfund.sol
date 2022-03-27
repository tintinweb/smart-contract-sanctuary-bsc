/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// File: contracts/4-fund5.sol



pragma solidity >=0.7.0 <0.9.1;

//ejemplo de un crowdfund (juntar plata para algo)
contract Crowfund {
    // variables (q uso en el contructor)
    string public id;
    string public name;
    string public description;
    address payable public author;
       

    //variables ....q no uso en el costructor
    //string public state = "Opened"; 0 open 1 close
    string private message;

    uint256 public state = 0; // 0 open 1 close
    uint256 public funds; // ingreso de dinero
    uint256 public fundraisingGoal; // valor objetivo del fondo
    uint256 public fundRestante; // valor que falta para llegar al objetivo

    // evento para saber quien aporto y cuanto queda para llegar al objetivo
    // event ChangeFound(address editor, uint256 fundRestante);
    event ChangeFound(uint256 fundRestante);

    // evento para saber quien aporto y cuanto queda para llegar al objetivo
    // event ChangeFound(address editor, uint256 fundRestante);
    event ChangeState(uint256 state);

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
        fundRestante = _fundraisingGoal;
        author = payable(msg.sender);
        /*
        id = "1";
        name = "guilleo";
        description = "description";
        fundraisingGoal = 1000000000;
        fundRestante = fundraisingGoal;
        author = payable(msg.sender);
*/
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

    // funcion para Cambiar el valor a juntar    
    function changefundraisingGoalProjectx2() public payable onlyOwner {
        require(state == 0, "Proyect is closed.");
        
        fundraisingGoal = fundraisingGoal * 2;
        fundRestante = fundraisingGoal - funds;
        emit ChangeFound(fundraisingGoal);
    }

    // funcion para Cambiar el valor a juntar    
    function changefundraisingGoalProjectx3() public payable onlyOwner {
        require(state == 0, "Proyect is closed.");
        
        fundraisingGoal = fundraisingGoal * 3;
        fundRestante = fundraisingGoal - funds;
        emit ChangeFound(fundraisingGoal);

    }    

    // funcion para setear un mensaje....y recaudar en el SC
    function setMessage(string memory newMessage) public payable {
        require(msg.value == 3 ether);
        message = newMessage;
    }    

    // funcion para aportar
    //function fundProject() public payable notOwner {
    function fundProject() public payable notOwner {
        require(state == 0, "Proyect is closed.");
        require(msg.value > 0, "Not mouse acepted.");
        require((funds + msg.value) <= fundraisingGoal, "Overfound! ");
        author.transfer(msg.value); // usar el call en su lugar
        funds += msg.value;
        fundRestante -= msg.value;
        emit ChangeFound(fundraisingGoal);
    }

    // funcion para cambiar el estado del proyecto
    //function changeProjectState(string calldata newState) public onlyOwner {
    function changeProjectState(uint256 newState) public onlyOwner {
        require(newState == 0 || newState == 1, "Value not defined");
        require(newState != state, "State must be different");
        state = newState;
        emit ChangeState(state);
    }
}