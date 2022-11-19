/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract PcBolt{

    string public Nev="576";

    uint public Raktaronlevogepek;

    uint public Megrendeltgepek;

    uint public Eladottgepek;

    constructor(){
        Raktaronlevogepek=10;
        Megrendeltgepek=0;
        Eladottgepek=0;
    }

    function Eladas() public {

        if(Raktaronlevogepek>0){
            Raktaronlevogepek--;
            Eladottgepek++;
        }

    }

    function Rendeles(uint mennyit) public {

        Megrendeltgepek+=mennyit;

    }

    function Megerkezes(uint mennyi) public {

        if(Megrendeltgepek>=mennyi){
            Megrendeltgepek-=mennyi;
        Raktaronlevogepek+=mennyi;
        }

    }



}