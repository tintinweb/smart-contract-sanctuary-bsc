/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

// SPDX-License-Identifier: MIT


// TRDC Game   فكرة: حمزة بنالي Idea: Hamza Banaly
// برمجة: جعفر كريّم Programed by: Jaafar Krayem

pragma solidity ^0.8.13;

contract TRDCvault{
    function addBank (string memory _bankName,uint _bankPower, uint _bankVault) public{}
    function addThief (string memory _tName, uint _tPower) public{}
    function addCop (string memory _cName, uint _cPower) public{}
    function startTheGame(string memory guess) public{}
    function addWeapon (string memory _wName, uint _wPower, uint _wPrice) public{}
}
contract gameOperation{
    TRDCvault private trdcGame;
    mapping(address=> bool) public gameOperator;
    uint once;

    constructor(address _trdcGame){
        gameOperator[msg.sender] = true;
        trdcGame = TRDCvault(_trdcGame);
        once = 0;
    }
    
    modifier onlyOperator(){
        require(gameOperator[msg.sender] == true,"Only Operator!");
        _;
    }
    function changeContract(address _new) public onlyOperator{
        trdcGame = TRDCvault(_new);
        once = 0;
    }
    function addOprator(address _operator) external onlyOperator{
        require(gameOperator[_operator] != true,"Already!");
        gameOperator[_operator] = true;
    }
    function setTheGame() external onlyOperator{
        require(once == 0, "Function one time!");
        trdcGame.addBank("Bank of America", 3, 0);
        trdcGame.addBank("National Bank", 3, 0);
        trdcGame.addBank("China Bank", 1, 0);
        trdcGame.addBank("Bank Of Egypt", 2, 0);
        trdcGame.addBank("Bank of Madrid", 10000, 0);
        trdcGame.addBank("France Bank", 10000, 0);
        trdcGame.addBank("Bank Of Beirut", 10000, 0);
        trdcGame.addCop("AngelRubio", 1);
        trdcGame.addCop("LuisTamayo", 2);
        trdcGame.addThief("Elprofessor", 10);
        trdcGame.addThief("Rio", 2);
        trdcGame.addThief("Nairobi", 3);
        trdcGame.addThief("Tokyo", 6);
        trdcGame.addThief("Denver", 4);
        trdcGame.addThief("ArturoRoman", 0);
        trdcGame.addWeapon("Skorpion", 11, 2000);
        trdcGame.addWeapon("M1911", 5, 1000);
        trdcGame.addWeapon("G36C", 20, 3500);
        trdcGame.addWeapon("Mini Uzi", 7, 1500);
        trdcGame.startTheGame("Berlin");
        once++;
    }
}