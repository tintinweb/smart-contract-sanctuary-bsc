/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

contract sandobox {

struct HouseOrder {
    string Buyer;
    string Type;
    string Bedrooms;
    uint256 Year;
    uint256 Acres;
}

struct CarOrder {
    string Buyer;
    string Make;
    string Model;
    uint256 Year;
    uint256 Mileage;
}

mapping (address => HouseOrder) Houseorders;
mapping (address => CarOrder) Carorders;


function setHouse (address _address, string memory _buyer, string memory _type, string memory _bedrooms, uint256 _year, uint256 _acres) public {

    HouseOrder storage houseorder = Houseorders[_address];
    houseorder.Buyer = _buyer;
    houseorder.Type = _type;
    houseorder.Bedrooms = _bedrooms;
    houseorder.Year = _year;
    houseorder.Acres = _acres;

}

function getHouse (address _address) public view returns (string memory, string memory, string memory, uint256,uint256) {

    return (Houseorders[_address].Buyer, Houseorders[_address].Type, Houseorders[_address].Bedrooms, Houseorders[_address].Year,Houseorders[_address].Acres);
}



function setCar (address _address, string memory _buyer, string memory _make, string memory _model, uint256 _year, uint256 _mileage) public {

    CarOrder storage carorder = Carorders[_address];
    carorder.Buyer = _buyer;
    carorder.Make = _make;
    carorder.Model = _model;
    carorder.Year = _year;
    carorder.Mileage = _mileage;

}

function getCar (address _address) public view returns (string memory, string memory, string memory, uint256,uint256) {

    return (Carorders[_address].Buyer, Carorders[_address].Make, Carorders[_address].Model, Carorders[_address].Year,Carorders[_address].Mileage);
}






}