/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

pragma solidity ^0.8.13;
   
   contract MatheMatic { 
    uint256 private altikat1; 
    uint256 private altikat2; 
    uint256 private altikat3; 
    uint256 private altikat4; 
    uint256 private altikat5; 
    uint256 private altikat6; 
    uint256 private altikat7;
    uint256 private altikat8; 
    uint256 private altikat9; 
    uint256 private altikat10; 

    // setter 1
    function carpim1(uint _sayi) public {
        altikat1 = _sayi * 6;
    }

    function carpim2(uint _sayi) public {
        altikat2 = _sayi * 6;
    }

    // getter 1
    function getAltikat1() public view returns (uint256) {
        return altikat1;
    }

    function getAltikat2() public view returns (uint256) {
        return altikat2;
    }
   
   

    //setter 2
   function carpim3(uint _sayi)public {
       altikat3 = _sayi * 6;
   }
   function carpim4(uint _sayi)public {
       altikat4 = _sayi * 6;
   }
    
    //getter 2
    function getAltikat3()public view returns (uint256) {
        return altikat3;
    }
    function getaltikat4()public view returns (uint256) {
        return altikat4;
    }

    //setter 3
    function carpim5(uint _sayi) public {
        altikat5 = _sayi * 6;
    }
    function carpim6(uint _sayi) public {
        altikat6 = _sayi * 6;
    }    

    //getter 3
    function getaltikat5()public view returns (uint256) {
        return altikat5;
    }  
    function getaltikat6()public view returns (uint256) {
        return altikat6;
    } 

   
    //setter 4
    function carpim7(uint _sayi) public {
        altikat7 = _sayi * 6;
    }   
    function carpim8(uint _sayi)public {
        altikat8 = _sayi * 6;
    }

    //getter 4
    function getaltikat7()public view returns (uint256) {
        return altikat7;
    }  
    function getaltikat8()public view returns (uint256) {
        return altikat8;
    } 
   
   
    //setter 5 
    function carpim9(uint _sayi)public {
        altikat9 = _sayi * 6;
    }
    function carpim10(uint _sayi)public {
        altikat10 = _sayi * 6;
    }

    //getter 5 
    function getaltikat9()public view returns(uint256) {
        return altikat9;
    }
    function getaltikat10()public view returns(uint256) {
        return altikat10;
    }
}