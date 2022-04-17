//SPDX-License-Identifier: MIT
//@FernandoArielRodriguez
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";
import "./FerParkToken.sol";

contract FerPark {
    // initial declarations ---------------------------------------------------------------------------------
    // instanciate token we create
    FerParkToken private token;
    // FerParkAddress
    // This address is marked as payable to receive token payments
    address payable public owner;

    constructor() public {
        token = new FerParkToken(10000);
        owner = msg.sender;
    }

    // data structure to storage the park clients
    struct client {
        // balance of parkToken
        uint tokens_buyed;
        // attractions played on the park
        string[] atractions_played;
    }

    // register of clients
    // this will return a client struct for a given address
    mapping(address => client) public Clients; 

    // gestion de tokens ---------------------------------------------------------------------------------

    // function to give a price to the token
    function PriceFerParkToken(uint ammount) internal pure returns(uint){
        // conversion ferParkTokens to eth, 1 ferPark = 1 ether
        return  ammount * (0.01 ether);
    }

    // function to buy ferParkTokens
    function buyTokens(uint ammountToBuy) public payable {
        //stablish ferParkTokenPrice
        uint cost = PriceFerParkToken(ammountToBuy);
        // obtention of the ammount of ferParkTokens available
        uint balance = balanceOf();
        // require the user got the ether to buy the tokens
        require(msg.value >= cost, "You dont have enough ETH balance to aquire FerPrakTokens");
        require(ammountToBuy <= balance, "Token balance too low, buy less ammount of tokens");
        // Diference from the value send and the value needed
        uint returnValue = msg.value - cost;
        // ferPark returns the ether (if was more than the needed), this transfer take place
        // from the msg sender from the contract
        msg.sender.transfer(returnValue);
        // transfer the ammount to the token
        token.transfer(msg.sender, ammountToBuy);
        // storage the ammount of buyed ferParkTokens using Clients struct
        Clients[msg.sender].tokens_buyed += ammountToBuy;
    }

    //function that show the balance of the ferParkToken
    function balanceOf() public view returns(uint){
        return token.balanceOf(address(this));
    }

    // function that return the number of tokens of a client
    function myTokenBalance() public view returns(uint){
        // we use the balanceOf function of the ferParkToken(ERC20)
        return token.balanceOf(msg.sender);
    }

    // function that allows create more tokens
    function generateTokens(uint ammountToGenerate) public onlyParkAdministrator(msg.sender) {
        token.increaseTotalSupply(ammountToGenerate);
    }

    // modifier to control the operations made only by the administrator of the park
    modifier onlyParkAdministrator(address parkAdministrator) {
        require(parkAdministrator == owner, "You dont have permissions to generate more tokens");
        _;
    }

    // manage ferPark ---------------------------------------------------------------------------------

    //events
    event rideAtraction(string, uint, address);
    event newAtraction(string, uint);
    event unsubscribeAtraction(string);

    // data structure for the atraction
    struct Atraction {
        string name;
        uint price;
        bool isFunctional; 
    }

    //mapping to relation the name of an atraction with the Atraction struct
    mapping(string => Atraction) public MappingAtractions;

    // array to storage the name of the atractions
    string[] Atractions;

    // mapping to relate a client address with his historial of ride atractions
    mapping(address => string[]) AtractionsHistory; 

    // StarWars => 2 FerTokens
    // ToyStory => 2 FerTokens
    // Tron => 5 FerTokens

    // function to create new atractions
    function addAtraction(string memory nameAtraction, uint price) public onlyParkAdministrator(msg.sender){
        // creation of a new atraction
        MappingAtractions[nameAtraction] = Atraction(nameAtraction, price, true);
        // Storage on array the name of the atraction(Atractions)
        Atractions.push(nameAtraction);
        // emit the event for the new atraction, this will register the name and the price for the atraction
        emit newAtraction(nameAtraction, price);
    }

    // function to ride an atraction and pay with FerParkTokens
    function rideOneAtraction(string memory nameAtraction) public {
        //price of the atraction
        uint atractionValue = MappingAtractions[nameAtraction].price;
        // verify the balance of ferParkToken of the user
        require(atractionValue <= myTokenBalance(), "You dont have enough balane");
        // the client pay the atraction in tokens
        // in order to have correctly the msg.sender , i create a new function on 
        // ERC20 contract interface that allow us to change the msg.sender to the client
        token.transferFerPark(msg.sender, address(this), atractionValue);
        // storage the ride on the historial of activities of the client;
        AtractionsHistory[msg.sender].push(nameAtraction);
        // emit the event to enjoy the atraction
        emit rideAtraction(nameAtraction, atractionValue ,msg.sender);
    }

    // see the complete client historial
    function historial() public view returns(string[] memory){
        return AtractionsHistory[msg.sender];
    }

    // function to return the eth for the ferParkTokens
    function returnTokens(uint tokenAmount) public payable {
        // verify number of tokens to return to be positive
        require(tokenAmount > 0, "You must have tokens to retrieve for money");
        // verify te client has the tokens
        require(tokenAmount <= myTokenBalance(), "You dont have tokens to retrieve"); 
        // the client return the tokens
        token.transferFerPark(msg.sender, address(this), tokenAmount);
        // ether devolution to the client
        msg.sender.transfer(PriceFerParkToken(tokenAmount));
    }
}