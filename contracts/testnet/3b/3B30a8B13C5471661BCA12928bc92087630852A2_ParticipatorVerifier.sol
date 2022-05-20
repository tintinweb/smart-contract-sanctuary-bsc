/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

pragma solidity 0.8.7;

contract ParticipatorVerifier {
    string  owner = "hello";

    function getHello() public   view returns(uint256) {
        return 125;
    }

    function readOwner() public view returns(string memory) {
        return owner;
    }

    function setOwner() public  {
        owner = "angelina jolie";
    }

    function setOwner(string memory _owner) public {
        owner = _owner;
    }
}