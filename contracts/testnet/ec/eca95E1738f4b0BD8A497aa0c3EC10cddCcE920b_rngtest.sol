/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// File: contracts/interfaces/IMetatopiaRNG.sol


pragma solidity ^0.8.4;

interface IMetatopiaRNG {
    
    function oneOutOfTwo() external view returns (uint256);
    function oneOutOfTen() external view returns (uint256, uint256);
    function oneOutOfThree() external view returns (uint256);
    function readRandomNumberArray(uint256 _index) external view returns (uint256);
    // generates new random number.
    function requestRandomWords() external;
    
}
// File: contracts/RNGtest.sol


pragma solidity ^0.8.0;


contract rngtest {

    address MetatopiaRNGContract;
    IMetatopiaRNG public MetatopiaRNGInterface;
    

    constructor(address rng) {
        MetatopiaRNGContract = rng;
        MetatopiaRNGInterface = IMetatopiaRNG(MetatopiaRNGContract);
    }


    function test1() public {
        MetatopiaRNGInterface.requestRandomWords();
    }

    function followUpTest1() public view returns(uint256, uint256) {
        uint res1;
        uint res2;
        (res1, res2) = MetatopiaRNGInterface.oneOutOfTen();
        return(res1, res2);
    }

    function test2() public returns(uint256, uint256) {
        MetatopiaRNGInterface.requestRandomWords();
        uint res1;
        uint res2;
        (res1, res2) = MetatopiaRNGInterface.oneOutOfTen();
        return(res1, res2);
    }

    function test3() public returns(uint256, uint256) {
        MetatopiaRNGInterface.requestRandomWords();
        while (MetatopiaRNGInterface.readRandomNumberArray(0) <= 0 && MetatopiaRNGInterface.readRandomNumberArray(1) <= 0) {}
        uint res1;
        uint res2;
        (res1, res2) = MetatopiaRNGInterface.oneOutOfTen();
        return(res1, res2);

    }

}