/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface CryptoCarouselReferralProgram {
    function getLevels() external view returns (uint256);
    function getPercent(uint256 _level) external view returns(uint256);
}

interface CryptoCarouselWeeklyLottery {
    function getPlayers() external view returns(address[] memory, uint256[] memory);
    function addCount(address _address, uint256 _count) external;
    function pay() external payable; 
}

interface CryptoCarouselReferrals {
    function newPlayer(address _address, address _ref) external;
    function getRefByLevel(address _address, uint256 _level) external returns(address);
    function addHistoryRef(address _to, address _from, uint256 _level, uint256 _count) external;
}

contract CryptoCarouselBitSpin{
    address owner;
    uint256 MINPRICE;
    address public weeklyLotteryContract;
    address public referralProgramContract;
    address public referralsContract;
    CryptoCarouselWeeklyLottery weeklyLottery;
    CryptoCarouselReferralProgram referralProgram;
    CryptoCarouselReferrals referrals;
    uint256 countHistory;
    uint256 countSpin;
    mapping(uint256 => historyItem) public history;
    struct historyItem{
        address _address;
        uint256 inSum;
        uint256 outSum;
        uint256[9] spin;
        uint256 res;
    }
    mapping(uint256 => uint256) winX;
    mapping(address => uint256) address2countGame;

    constructor(){
        owner = msg.sender;
        MINPRICE = 50000000000000000;
        winX[1] = 5;
        winX[2] = 10;
        winX[3] = 20;
        winX[4] = 30;
        winX[5] = 40;
        winX[6] = 50;
        winX[7] = 100;
        winX[8] = 200;
        winX[9] = 500;
        winX[10] = 1000;
        winX[11] = 2000;
        winX[12] = 4000;
        winX[13] = 10000;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Function is OnlyOwner");
        _;
    }

    function setMinPrice(uint256 _price) onlyOwner public{
        MINPRICE = _price;
    }

    function setWeeklyLotteryContract(address _address) onlyOwner public{
        weeklyLotteryContract = _address;
        weeklyLottery = CryptoCarouselWeeklyLottery(_address);
    }

    function setReferralProgramContract(address _address) onlyOwner public{
        referralProgramContract = _address;
        referralProgram = CryptoCarouselReferralProgram(_address);
    }

    function setReferralsContract(address _address) onlyOwner public{
        referralsContract = _address;
        referrals = CryptoCarouselReferrals(_address);
    }

    function setContracts(address _address_Lottery, address _address_RefferalProgram, address _address_Referrals) onlyOwner public{
        weeklyLotteryContract = _address_Lottery;
        weeklyLottery = CryptoCarouselWeeklyLottery(_address_Lottery);
        referralProgramContract = _address_RefferalProgram;
        referralProgram = CryptoCarouselReferralProgram(_address_RefferalProgram);
        referralsContract = _address_Referrals;
        referrals = CryptoCarouselReferrals(_address_Referrals);
    }

    function startGame(address _ref) payable public{
        require(msg.value >= MINPRICE, "Not enough money");
        uint256 balance = msg.value;
        referrals.newPlayer(msg.sender, _ref);
        weeklyLottery.addCount(msg.sender, msg.value);
        weeklyLottery.pay{value:balance * 10 / 100}();
        payable(owner).transfer(balance / 100);
        for(uint256 i = 1; i <= referralProgram.getLevels(); i++){
            pay(balance * referralProgram.getPercent(i) / 100, referrals.getRefByLevel(msg.sender,i));
            payable(referrals.getRefByLevel(msg.sender,i)).transfer(balance * referralProgram.getPercent(i) / 100);
            referrals.addHistoryRef(referrals.getRefByLevel(msg.sender,i), msg.sender, i, balance * referralProgram.getPercent(i) / 100);
        }
        uint256 countGame = balance / MINPRICE;
        uint256 res;
        uint256[9] memory spin;
        uint256 sum = 0;
        for(uint256 i = 0; i < countGame; i++){
            (res, spin) = getWin();
            if(res > 0)
                sum = getMoney(res);
            history[countHistory] = historyItem(msg.sender, balance, sum, spin, res);
            countHistory++;
        }
        address2countGame[msg.sender] += countGame;
    }


    function startGame() payable public{
        startGame(owner);
    }

    function random(uint256 max, uint256 salt) private view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp * salt, block.difficulty, msg.sender))) % max;
    }

    function getMoney(uint256 _count) private returns(uint256){
        uint256 sum;
        if(_count > 13)
            _count = 13;
        sum = winX[_count] * MINPRICE;
        if(sum > address(this).balance / 2)
            sum = address(this).balance / 2;
        pay(sum, msg.sender);
        return sum;
    }

    function pay(uint _count, address _address) private{
        payable(_address).transfer(_count);
    }

    function getSpinHistory(uint256 _count) public view returns(uint256[9] memory){
        return history[_count].spin;
    }

    function getLastSpin(uint256 _count, address _address) public view returns(uint256[9][] memory, uint256[] memory){
        require(_count > 0, "Count is don't correct");
        uint256[9][] memory spins = new uint256[9][](_count);
        uint256[] memory res = new uint256[](_count);
        uint256 c = 0;
        for(uint256 i = countHistory-1; i >= 0; i--){
            if(history[i]._address == _address){
                spins[c] = history[i].spin;
                res[c] = history[i].res;
                c++;
            }
            if(c == _count || c == address2countGame[_address])
                break;
        }
        return (spins, res);
    }

    function getLastWinSpin(uint256 _count) public view returns(address[] memory, uint256[9][] memory, uint256[] memory){
        require(_count > 0, "Count is don't correct");
        uint256[9][] memory spins = new uint256[9][](_count);
        uint256[] memory res = new uint256[](_count);
        address[] memory addresses = new address[](_count);
        uint256 c = 0;
        for(uint256 i = countHistory-1; i >= 0; i--){
            if(history[i].res > 0){
                spins[c] = history[i].spin;
                res[c] = history[i].res;
                addresses[c] = history[i]._address;
                c++;
            }
            if(c == _count)
                break;
        }
        return (addresses, spins, res);
    }

    function getSpin() private returns(uint256[9] memory){
        uint256[9] memory res;
        for(uint256 i = 0; i < 9; i++){
                res[i] = random(7,countSpin);
                countSpin++;
        }
        return res;
    }

    function getWin() private returns(uint256, uint256[9] memory){
        uint256[9] memory spin = getSpin();
        uint256 res = 0;
        if((spin[0]==spin[1]) && (spin[1]==spin[2]))
            res++;
        if((spin[3]==spin[4]) && (spin[4]==spin[5]))
            res++;
        if((spin[6]==spin[7]) && (spin[7]==spin[8]))
            res++;
        
        if((spin[0]==spin[3]) && (spin[3]==spin[6]))
            res++;
        if((spin[1]==spin[4]) && (spin[4]==spin[7]))
            res++;
        if((spin[2]==spin[5]) && (spin[5]==spin[8]))
            res++;

        if((spin[0]==spin[4]) && (spin[4]==spin[8]))
            res++;
        if((spin[2]==spin[4]) && (spin[4]==spin[6]))
            res++;

        if((spin[0] == spin[1]) && (spin[1] == spin[2]) && (spin[2]== spin[3]) && (spin[3] == spin[4]) && (spin[4]== spin[5]))
            res += 3;
        if((spin[3] == spin[4]) && (spin[4] == spin[5]) && (spin[5]== spin[6]) && (spin[6] == spin[7]) && (spin[7]== spin[8]))
            res += 3;
        if((spin[0] == spin[1]) && (spin[1] == spin[2]) && (spin[2]== spin[6]) && (spin[6] == spin[7]) && (spin[7]== spin[8]))
            res += 3;

        if((spin[0] == spin[3]) && (spin[3] == spin[6]) && (spin[6]== spin[1]) && (spin[1] == spin[4]) && (spin[4]== spin[7]))
            res += 3;
        if((spin[1] == spin[4]) && (spin[4] == spin[7]) && (spin[7]== spin[2]) && (spin[2] == spin[5]) && (spin[5]== spin[8]))
            res += 3;
        if((spin[0] == spin[3]) && (spin[3] == spin[6]) && (spin[6]== spin[2]) && (spin[2] == spin[5]) && (spin[5]== spin[8]))
            res += 3;

        return (res, spin);
    }

}