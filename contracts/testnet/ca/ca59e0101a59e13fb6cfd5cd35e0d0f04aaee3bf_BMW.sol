/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

pragma solidity 0.8.0;

contract Car {
    int public tyres;
    int public numberPlate;
    string internal str;
    address public user1;

    function change() public {
        numberPlate = 1024;
    }
}

contract BMW is Car {

    uint[10] public arr;

    function changeSTR() external {
        str = "hello";
    }

    function readSTR() external view returns(string memory) {
        return str; 
    }

    function pushData(uint _data, uint _index) public {
        uint num =10;
        arr[_index] = _data;
        arr[_index +1] = num;
    }
}