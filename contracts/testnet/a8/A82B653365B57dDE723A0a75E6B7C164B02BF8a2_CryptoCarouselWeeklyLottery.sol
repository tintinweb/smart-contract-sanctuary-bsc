/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract CryptoCarouselWeeklyLottery{
    address owner;
    mapping(uint256=>uint256) percent;
    mapping(uint256=>uint256) id2countGames;
    mapping(address=>uint256) address2id;
    mapping(uint256=>address) id2address; 
    mapping(address=>bool) allow;
    uint256 countAll;
    uint public lastLottery;
    uint public timeLottery;

    constructor(){
        owner = msg.sender;
        percent[0] = 30;
        percent[1] = 24;
        percent[2] = 18;
        percent[3] = 7;
        percent[4] = 6;
        percent[5] = 5;
        percent[6] = 4;
        percent[7] = 3;
        percent[8] = 2;
        percent[9] = 1;
        id2address[0] = owner;
        countAll = 1;
        lastLottery = block.timestamp;
        timeLottery = 1 minutes;

    }

    modifier onlyOwner {
        require(msg.sender == owner, "Function is OnlyOwner");
        _;
    }

    function setAllow(address _address, bool flag) public onlyOwner{
        allow[_address] = flag;
    }

    function registration(address _address) private returns(uint256){
        if(_address == owner) return 0;
        if(address2id[_address] == 0){
            address2id[_address] = countAll;
            id2address[countAll] = _address;
            countAll++;
            return countAll - 1;
        }else{
            return address2id[_address];
        }
    }

    function addCount(address _address, uint256 _count) public{
        require(allow[msg.sender]==true, "Permission denied");
        id2countGames[registration(_address)] += _count;
    }

    function getPlayerStat(address _address) public view returns(uint256){
        return id2countGames[address2id[_address]];
    }

    function restartLottery() private{
        for(uint256 i = 0; i < countAll; i++){
            id2countGames[i] = 0;
        }
        lastLottery = lastLottery + timeLottery;
    }

    function getPlayers() public view returns(address[] memory, uint256[] memory){
        address[] memory _addresses = new address[](countAll);
        uint256[] memory _countes = new uint256[](countAll);
        for(uint256 i = 0; i < countAll; i++){
            _addresses[i] = id2address[i];
            _countes[i] = id2countGames[i];
        }
        return (_addresses, _countes);
    }

    function startLottery() public returns(bool){
        if(timeLottery + lastLottery > block.timestamp)
            return false;
        uint256[] memory res = new uint256[](countAll);
        res = sort();
        uint256 c = 10;
        if(countAll < c)
            c = countAll;
        uint256 balance = address(this).balance;
        for(uint256 i = 0; i < c; i++){
            payable(id2address[res[i]]).transfer(balance * percent[i] / 100);
        }
        restartLottery();
        return true;
    }

    function sort() internal returns (uint256[] memory) {
        uint256[] memory temp = new uint256[](countAll);
        for(uint256 i = 0; i < countAll; i++){
            temp[i] = i;
        }
        if (temp.length >= 2) {
            quickSort(temp, 0, temp.length - 1);
        }
        return temp;
    }

    function quickSort(
        uint256[] memory arr,
        uint256 left,
        uint256 right
    ) internal {
        uint256 i = left;
        uint256 j = right;
        if (i == j) return;
        uint256 pivot = arr[uint256(left + (right - left) / 2)];
        while (i <= j) {
            while (id2countGames[arr[uint256(i)]] > id2countGames[pivot]) 
              i++;
            while (id2countGames[pivot] > id2countGames[arr[uint256(j)]]) 
              j--;
            if (i <= j) {
                (arr[uint256(i)], arr[uint256(j)]) = (arr[uint256(j)],arr[uint256(i)]);
                i++;
                if(j > 0)
                    j--;
            }
        }
        if (left < j) quickSort(arr, left, j);
        if (i < right) quickSort(arr, i, right);
    }

    function getBalance() view public returns (uint256){
        return address(this).balance;
    }
}