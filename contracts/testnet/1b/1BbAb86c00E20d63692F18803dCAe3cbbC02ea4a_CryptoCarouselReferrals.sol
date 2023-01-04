/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface CryptoCarouselReferralProgram {
    function getLevels() external view returns (uint256);
    function getPercent(uint256 _level) external view returns(uint256);
}

contract CryptoCarouselReferrals{

    address owner;
    uint256 countAll;
    mapping(address=>uint256) address2id;
    mapping(uint256=>address) id2address;
    mapping(uint256=>uint256) id2refId;

    CryptoCarouselReferralProgram referralProgram;
    address referralProgramContract;

    constructor(){
        owner = msg.sender;
        id2address[0] = owner;
        countAll = 1;
        //referralProgram = new CryptoCarouselReferralProgram();
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Function is OnlyOwner");
        _;
    }

    function setReferralProgramContract(address _address) onlyOwner public{
        referralProgramContract = _address;
        referralProgram = CryptoCarouselReferralProgram(_address);
    }

    function registration(address _address) private returns(uint256){
        if(_address==owner)
            return 0;
        if(address2id[_address]==0){
            address2id[_address] = countAll;
            id2address[countAll] = _address;
            countAll++;
            return countAll-1;
        }else{
            return address2id[_address];
        }
    }

    function newPlayer(address _address) public{
        newPlayer(_address, owner);
    }

    function newPlayer(address _address, address _ref) public{
        if(address2id[_address] == 0){
            uint256 id = registration(_address);
            uint256 id_ref = 0;
            if(_ref != _address)
                id_ref = registration(_ref);
            id2refId[id] = id_ref;
        }
    }

    function getCountAll() public view returns(uint256){
        return countAll;
    }

    function getPlayerId(address _address) public view returns(uint256){
        return address2id[_address];
    }

    function getRefByLevel(address _address, uint256 _level) public view returns(address){
        require(_level > 0 && _level <= referralProgram.getLevels(), "Incorrect level");
        address temp = _address;
        for(uint256 i = 0; i < _level; i++){
            temp = id2address[id2refId[address2id[temp]]];
        }
        return temp;
    }
}