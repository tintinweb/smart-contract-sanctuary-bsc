/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

pragma solidity 0.4.26;

contract Hourglass {
    function compound() public {}
    function myTokens() public view returns(uint256) {}
    function myDividends(bool) public view returns(uint256) {}
}

contract PriceFloor {
    Hourglass hourglassInterface;
    address public hourglassAddress;
    
    constructor(address _hourglass) public {
        hourglassAddress = _hourglass;
        hourglassInterface = Hourglass(_hourglass);
    }

    function makeItRain() public {
        hourglassInterface.compound();
    }
    
    function myTokens() public view returns(uint256) {
        return hourglassInterface.myTokens();
    }
    
    function myDividends() public view returns(uint256) {
        return hourglassInterface.myDividends(true);
    }
}