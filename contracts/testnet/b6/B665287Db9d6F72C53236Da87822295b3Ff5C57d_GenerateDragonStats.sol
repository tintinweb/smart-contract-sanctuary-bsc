/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IRandom {
    function randModulus(uint _mod) external returns (uint result);
}

contract GenerateDragonStats {
    IRandom randomNumber;
    uint decimalStat = 10**3;
    enum Species {Wyvern, Hydra, Salamander}

    function setRandomNumber(address _randomNumber) external {
        randomNumber = IRandom(_randomNumber);
    }
    constructor(address _randomContract){
        randomNumber = IRandom(_randomContract);
    }

    function generateCommonStat(Species _species) external returns(uint damage, uint hp, uint speed){
        if (_species == Species.Wyvern) {
            damage = 200*decimalStat;
            hp = (500 + randomNumber.randModulus(251))*decimalStat;
            speed = 10*decimalStat;
        } else if (_species == Species.Hydra) {
            damage = (100 + randomNumber.randModulus(51))*decimalStat;
            hp = 1000*decimalStat;
            speed = 10*decimalStat;
        } else {
            damage = 100*decimalStat;
            hp = 500*decimalStat;
            speed = (20 + randomNumber.randModulus(11))*decimalStat;
        }
    }

    function generateEpicStat(Species _species) external returns(uint damage, uint hp, uint speed){
        if (_species == Species.Wyvern) {
            damage = 225*decimalStat;
            hp = (750 + randomNumber.randModulus(251))*decimalStat;
            speed = 20*decimalStat;
        } else if (_species == Species.Hydra) {
            damage = (150 + randomNumber.randModulus(51))*decimalStat;
            hp = 1125*decimalStat;
            speed = 20*decimalStat;
        } else {
            damage = 150*decimalStat;
            hp = 750*decimalStat;
            speed = (30 + randomNumber.randModulus(11))*decimalStat;
        }
    }

    function generateLegendaryStat(Species _species) external returns(uint damage, uint hp, uint speed){
        if (_species == Species.Wyvern) {
                damage = 267*decimalStat;
                hp = (1000 + randomNumber.randModulus(251))*decimalStat;
                speed = 30*decimalStat;
        } else if (_species == Species.Hydra) {
            damage = (200 + randomNumber.randModulus(51))*decimalStat;
            hp = 1333*decimalStat;
            speed = 30*decimalStat;
        } else {
            damage = 200*decimalStat;
            hp = 1000*decimalStat;
            speed = (40 + randomNumber.randModulus(11))*decimalStat;
        }
    }

    function generateImmortalStat(Species _species) external returns(uint damage, uint hp, uint speed){
        if (_species == Species.Wyvern) {
                damage = 375*decimalStat;
                hp = (1500 + randomNumber.randModulus(301))*decimalStat;
                speed = 40*decimalStat;
        } else if (_species == Species.Hydra) {
            damage = (300 + randomNumber.randModulus(61))*decimalStat;
            hp = 1875*decimalStat;
            speed = 40*decimalStat;
        } else {
            damage = 300*decimalStat;
            hp = 1500*decimalStat;
            speed = (50 + randomNumber.randModulus(11))*decimalStat;
        }
    }

}