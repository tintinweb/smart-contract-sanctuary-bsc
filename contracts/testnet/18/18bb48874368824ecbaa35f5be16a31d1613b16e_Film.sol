/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

interface IFilm {
    function getId() external view returns (uint256);
    function getPrice() external view returns (uint256);
    function setDiscount(string calldata uid, uint256 price) external returns (bool);
    function getDiscount(string calldata uid) external view returns (uint256);
    function setBooking(address buyer, string calldata cluster, string calldata cinema, string calldata room, string calldata position, uint256 timestamp) external returns (bool);
    function getBooking(string calldata room, string calldata position, uint256 timestamp) external view returns (address);
    event Booked(address indexed buyer, string cluster, string cinema, string room, string position, uint256 timestamp);
}

contract Film is IFilm{

    uint256 _id;
    uint256 _price; //VND
    uint8 _decimals;
    mapping (string => mapping(string => mapping(uint256 => address))) _booking; // room -> position -> timestamp
    mapping (string => uint256) _discount; //uid_discount ~ VND < price

    constructor(uint256 id, uint256 price){
        _id = id;
        _price = price;
        _decimals = 0;
    }

    function getId() public override view returns (uint256) {
        return _id;
    }

    function getPrice() public override view returns (uint256) {
        return _price;
    }

    function setDiscount(string calldata uid, uint256 price) public override returns (bool){
        _discount[uid] = price;
        return true;
    }

    function getDiscount(string calldata uid) public override view returns (uint256) {
        return _discount[uid];
    }

    function setBooking(address buyer, string calldata cluster, string calldata cinema, string calldata room, string calldata position, uint256 timestamp) public override returns (bool){
        _booking[room][position][timestamp] = buyer;
        emit Booked(buyer, cluster, cinema, room, position, timestamp);
        return true;
    }

    function getBooking(string calldata room, string calldata position, uint256 timestamp) public override view returns (address){
        return _booking[room][position][timestamp];
    }
}