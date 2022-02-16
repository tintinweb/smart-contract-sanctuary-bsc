/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

pragma solidity >= 0.4.22 <0.9.0;

contract SoulTest {
    string thename;
    string theage;

    function tukarNama(string memory _thename) public {
        thename = _thename;
    }

    function tukarAge(string memory _theage) public {
        theage = _theage;
    }

    function ambilData(int data_apa) public view returns(string memory){
        if(data_apa == 2){
            return theage;
        }else if(data_apa == 1){
            return thename;
        }
        return "none";
    }

    function apaNamaDia() public view returns(string memory){
        return thename;
    }
}