/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

pragma solidity ^0.6.0;

contract MyContract{

    // arrays
    // uint[] public uintArray = [1,2,3];
    // string[] public stringArray = [ "jash","may", "june"];
    // string[] public values ;
    // uint[][] public array2D = [ [1,2,3] , [4,5,6]];

    // function addValue(string memory _value) public{
    //     values.push(_value);
    // }

    // function valueCount() public view returns(uint){
    //     return values.length;
    // }

    //mapping in solidity
    // mapping(uint=> string) public names;
    // mapping(uint=>Book) public books;
    // mapping(address=> mapping(uint=>Book)) public myBooks;

    // struct Book{
    //     string title;
    //     string author;
    //     }

    // constructor() public{
    //     names[1]= "adma";
    //     names[2]= "jash";
    //     names[3]= "zio";

    // }

    // function addBook(uint _id ,  string memory _title , string memory _author) public{
    //     books[_id] = Book(_title , _author);


    // }

    // function addMyBook( uint _id , string memory _title , string memory _author) public{
    //     myBooks[msg.sender][_id]= Book(_title , _author);
    // }


   // Solidity Loops etc
//    uint [] public numbers = [1,2,3,4,5,6,7,8,9,0];

//    address public owner;
//    constructor() public{
//        owner = msg.sender;
//    }
//    function CountEvenNumbers() public view  returns(uint){
//        uint count= 0;
//         for ( uint i=0 ; i< numbers.length ;  i++){
//             if(isEvenNumbers(numbers[i])) {
//                 count++;
//             }
//         }
//         return count;


//    }


//    function isEvenNumbers(uint _number) public view returns(bool){

//        if ( _number%2==0){
//            return true;
//        }
//        else{
//            return false;
//        }
//    }

//    function IsOwner() public view returns(bool){
//        return(msg.sender==owner);
//    }



    enum Statuses { Vacant, Occupied }
    Statuses currentStatus;
    address payable public owner;

    event Occupy(address _occupant, uint _value);

    constructor() public {
        owner = msg.sender;
        currentStatus = Statuses.Vacant;
    }

    modifier onlyWhileVacant {
        require(currentStatus == Statuses.Vacant, "Currently occupied.");
        _;
    }

    modifier costs(uint _amount) {
        require(msg.value >= _amount, "Not enough Ether provided.");
        _;
    }

    receive() external payable onlyWhileVacant costs(2 ether) {
        currentStatus = Statuses.Occupied;
        owner.transfer(msg.value);
        emit Occupy(msg.sender, msg.value);
    }

}