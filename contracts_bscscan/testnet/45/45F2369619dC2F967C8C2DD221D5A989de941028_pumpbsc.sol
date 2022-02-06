/**
 *Submitted for verification at BscScan.com on 2022-02-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


    interface IERC20  {
    function transfer(address _to, uint256 _value) external returns (bool);
    
    // don't need to define other functions, only using `transfer()` in this case
    }

contract pumpbsc {

    address _admin;
    uint _count;

    struct _adsSlot {
        address _tokenAddress;
        address _owner;
    }

    struct _adsbyOwner {
        address _owner;
        address _tokenAddress;
        uint _round;
        uint _position;
    }



    mapping (uint => _adsbyOwner) _adsbyOwners;
    mapping (uint => uint ) _priceOfPosition; // Positoin => price (USD)

    event BuyAds(address indexed owner,address tokenaddress, uint indexed round, uint position);

    mapping ( address => uint) _tokenRound; // Token => Round
    mapping ( uint => mapping (uint => _adsSlot)) _pumpAds; // round => Position => [ads slot]
    mapping (address => uint) _ownerCount; // Owner => count


    constructor () public payable {
        _admin = msg.sender;
        _count = 0;
        _priceOfPosition[1] = 200;
        _priceOfPosition[2] = 150;
        _priceOfPosition[3] = 100;
 
    }
    function modifyPrice(uint _position, uint _price) public returns (bool)
    {
        require(msg.sender == _admin, "You don't have a  permission");
        _priceOfPosition[_position] = _price;
        return true;
    }

    function getPrice(uint _position) public view returns (uint price) {
        return _priceOfPosition[_position];
    }

    function countAds() public view returns (uint count){
        return _count;
    }
    function getAdsbyOwners (address owner) public view returns (_adsbyOwner[] memory)
    {
        _adsbyOwner[] memory id = new _adsbyOwner[](_count);
        
        for (uint i = 0; i < _count; i++) {
            if(_adsbyOwners[i]._owner == owner){
                _adsbyOwner memory people = _adsbyOwners[i];
                id[i] = people;
            }

      }
      return id;

    }



    function buyAds(address _address, uint _round , uint _position) public payable {
        require(_position > 0 && _position <= 3, "Invalid position");
        require(_pumpAds[_round][1]._tokenAddress != _address , "Already purchase");
        require(_pumpAds[_round][2]._tokenAddress != _address , "Already purchase");
        require(_pumpAds[_round][3]._tokenAddress != _address , "Already purchase");
        require(_pumpAds[_round][_position]._tokenAddress == address(0), "This slot already purchase");

        require(msg.value == _priceOfPosition[_position], "Invalid amount");
        // IERC20 busd = IERC20(address(0xe9e7cea3dedca5984780bafc599bd69add087d56));
        // busd.transfer(_admin, _priceOfPosition[_position]);

        // (bool sent, bytes memory data) = _admin.call{value: _priceOfPosition[_position]*10**9}("");
        // require(sent, "Failed to send Ether");
        payable(_admin).transfer(_priceOfPosition[_position]);
        // payable(_admin).transfer(_priceOfPosition[_position]*10);

        _pumpAds[_round][_position]._tokenAddress = _address;
        _pumpAds[_round][_position]._owner = msg.sender;
        _tokenRound[_address] = _round;

        _adsbyOwners[_count] = _adsbyOwner(msg.sender,_address,_round,_position);
        _ownerCount[msg.sender] +=1;
        _count +=1;

        emit BuyAds(msg.sender,_address,_round,_position);
    }

    function readAds(uint _round, uint _position) public view returns (address token, address owner) {
        address tokenAddress = _pumpAds[_round][_position]._tokenAddress;
        address owner =  _pumpAds[_round][_position]._owner;

        return (tokenAddress, owner);

    }

    function countByOwner(address _owner) public view returns (uint count) {
        return _ownerCount[_owner];
    }
}