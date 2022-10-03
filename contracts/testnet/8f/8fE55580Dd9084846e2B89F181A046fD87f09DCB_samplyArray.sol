/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

pragma solidity ^0.6.0;

contract samplyArray {
    
    uint[] public myArray; //this is a dynamic array of type uint
    
//Arrays have built in functions that allow you to add, update and delete information.

//Push – adds an element to the end of the array
//Pop – removes the last element of the array
//Length – gets the length of the array. As an example how many items are in the array
//delete – allows you to delete an item at a specific location in the array

 //this will add i to the end of myArray
    function pushistoAdd(uint i) public {
        myArray.push(i); 
    }
    

    //returns the value in the specified position of the array
    function getIteminArray(uint index) public view returns (uint) {
        myArray[index]; 
    }

    
    //this will update an item in the array
    function updatethearray(uint locationinarray, uint valuetochangeto) public {
        myArray[locationinarray] = valuetochangeto;
    } 
    
    
    //this is to delete an item stored at a specific index in the array.  
    //Once you delete the item the value in the array is set back to 0 for a uint.
    function remove(uint index) public {
        delete myArray[index];  
    }
}