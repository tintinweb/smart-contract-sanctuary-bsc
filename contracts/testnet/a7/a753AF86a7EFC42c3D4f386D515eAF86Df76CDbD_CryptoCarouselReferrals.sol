/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface CryptoCarouselReferralProgram {
    function getLevels() external pure returns (uint256);
    function getPercent(uint256 _level) external pure returns(uint256);
}

contract CryptoCarouselReferrals{

    address immutable owner;
    uint256 countAll;
    mapping(address=>uint256) address2id;
    mapping(uint256=>address) id2address;
    mapping(address=>address) address2refAddress;
    mapping(address=>bool) allow;

    uint256 countHistory;
    struct historyItem{
        address to;
        address from;
        uint256 level;
        uint256 count;
    }
    mapping(uint256=>historyItem) history;
    mapping(address=>uint256) address2countHistory;

    CryptoCarouselReferralProgram referralProgram;
    address referralProgramContract;

    constructor(){
        owner = msg.sender;
        id2address[0] = owner;
        countAll = 1;
        countHistory = 0;
        //referralProgram = new CryptoCarouselReferralProgram();
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Function is OnlyOwner");
        _;
    }

    function unsafe_inc(uint256 x) private pure returns (uint256) {
        unchecked { return x + 1; }
    }

    function setAllow(address _address, bool flag) public onlyOwner{
        allow[_address] = flag;
    }

    function setReferralProgramContract(address _address) onlyOwner public{
        referralProgramContract = _address;
        referralProgram = CryptoCarouselReferralProgram(_address);
    }

    function registration(address _address) private returns(uint256){
        if(_address==owner)
            return 0;
        if(address2id[_address]==0){
            uint256 _countAll = countAll;
            address2id[_address] = _countAll;
            id2address[_countAll] = _address;
            countAll = unsafe_inc(countAll);
            return _countAll;
        }else{
            return address2id[_address];
        }
    }

    function newPlayer(address _address) public{
        newPlayer(_address, owner);
    }

    function newPlayer(address _address, address _ref) public{
        address ref = _ref;
        if(_address == ref)
           ref = owner;
        if(address2id[_address] == 0){
            registration(_address);
            registration(ref);
            address2refAddress[_address] = ref;
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
        for(uint256 i = 0; i < _level; i = unsafe_inc(i)){
            temp = address2refAddress[temp];
        }
        if(temp == address(0x00))
            temp = owner;
        return temp;
    }

    function addHistoryRef(address _to, address _from, uint256 _level, uint256 _count) public{
        require(allow[msg.sender]==true, "Permission denied");
        history[countHistory] = historyItem(_to, _from, _level, _count);
        countHistory = unsafe_inc(countHistory);
    }

    function getHistory(address _address) public view returns(address[] memory, uint256[] memory, uint256[] memory){
        address[] memory _from = new address[](address2countHistory[_address]);
        uint256[] memory _level = new uint256[](address2countHistory[_address]);
        uint256[] memory _countes = new uint256[](address2countHistory[_address]);
        uint256 i = 0;
        for(uint256 j = 0; j < countHistory; j++){
            if(history[j].to == _address){
                _from[i] = history[j].from;
                _level[i] = history[j].level;
                _countes[i] = history[j].count;
                i++;
            }
        }
        return (_from, _level, _countes);
    }
}