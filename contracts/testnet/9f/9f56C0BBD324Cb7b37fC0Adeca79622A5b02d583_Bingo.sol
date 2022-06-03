/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract Bingo{

    uint256 public balanceContrat;
    uint256 public numCard = 0;
    mapping(uint256=>address) public cards;
    mapping(address=>uint256) public countCarsByAddress;
    bool public isReceiver;

    event cardId(uint256 cardId); 
    
    function buyCard() public payable returns (uint256){
       //require(false);
       if(msg.value > 0){
        uint256 _num = numCard;
        cards[numCard]=msg.sender;
        numCard+=1;
        uint _numCardsAddress = getCardsByAddress(msg.sender);
        _numCardsAddress++;
        setCardsByAddress(msg.sender, _numCardsAddress);
        emit cardId(_numCardsAddress);
        return _numCardsAddress;
       }else{
           require(false);
           return 0;
       }
    }
    
    function getCardsByAddress(address _addres) public view returns (uint256) {
        return countCarsByAddress[_addres];
    }

    function setCardsByAddress(address _addres,uint256 _amount) public  {
      
        countCarsByAddress[msg.sender] = _amount;

    }
    function sendMoneyToWinner(address payable _to,uint256 amount) public {
        payable(_to).transfer(amount *10 ** 18);
       
    }

    function sendMoneyToWinnerInWeu(address payable _to,uint256 amount) public {
        payable(_to).transfer(amount *10 ** 18);
       
    }

    function getBalance()public view returns (uint256){
       return address(this).balance / (10**18);
    }
    
    receive() external payable{
        isReceiver = true;
    }
}