/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

/*  
 * VRF Multiplexer Usage Example
 * 
 * This is an example to showcase what the CodeCraftrs VRF Multiplexer is capable of. 
 * Feel free to use parts of this code to learn how to use it or even use it inside your contract.
 * 
 * Written by: MrGreenCrypto
 * Co-Founder of CodeCraftrs.com
 * 
 * SPDX-License-Identifier: None
 */
pragma solidity 0.8.17;

// use this to get a random number from this contract
interface ICCVRFMULTI{
    function getRandomNumbersForMultipleFunctions(uint256 requestID, uint256 functionNumber, uint256 howManyNumbers) external payable;
}

contract CodeCraftrsVRFMultiplexerExample {
    ICCVRFMULTI public multiRandomnessSupplier = ICCVRFMULTI(0x6776027E3Ea8c547abf32340a15a3e0f12345678);    
    uint256 public nonce;
    uint256 public vrfCost = 0.002 ether;

    uint256[] public randomnessDump1;
    uint256[] public randomnessDump2;
    uint256[] public randomnessDump3;
    uint256[] public randomnessDump4;
    uint256[] public randomnessDump5;
    uint256[] public randomnessDump6;
    uint256[] public randomnessDump7;
    uint256[] public randomnessDump8;
    uint256[] public randomnessDump9;
    uint256[] public randomnessDump10;

    event RandomnessReceivedOnFunction1(uint256[] randomNumbersReceived);
    event RandomnessReceivedOnFunction2(uint256[] randomNumbersReceived);
    event RandomnessReceivedOnFunction3(uint256[] randomNumbersReceived);
    event RandomnessReceivedOnFunction4(uint256[] randomNumbersReceived);
    event RandomnessReceivedOnFunction5(uint256[] randomNumbersReceived);
    event RandomnessReceivedOnFunction6(uint256[] randomNumbersReceived);
    event RandomnessReceivedOnFunction7(uint256[] randomNumbersReceived);
    event RandomnessReceivedOnFunction8(uint256[] randomNumbersReceived);
    event RandomnessReceivedOnFunction9(uint256[] randomNumbersReceived);
    event RandomnessReceivedOnFunction10(uint256[] randomNumbersReceived);


    modifier onlyVRF() {if(msg.sender != address(multiRandomnessSupplier)) return; _;}

    constructor() {}
    receive() external payable {}
    
    function getRandomness(uint256 functionNumber, uint256 howManyNumbers) external payable {
        multiRandomnessSupplier.getRandomNumbersForMultipleFunctions{value: 0.002 ether}(nonce, functionNumber, howManyNumbers);
        nonce++;
    }

    function supplyRandomness1(uint256, uint256[] memory randomNumbers) external onlyVRF {
        for(uint i = 0; i<randomNumbers.length; i++){
            randomnessDump1.push(randomNumbers[i]);
        }
        emit RandomnessReceivedOnFunction1(randomNumbers);
    }

    function supplyRandomness2(uint256, uint256[] memory randomNumbers) external onlyVRF {
        for(uint i = 0; i<randomNumbers.length; i++){
            randomnessDump2.push(randomNumbers[i]);
        }
        emit RandomnessReceivedOnFunction2(randomNumbers);
    }
    function supplyRandomness3(uint256, uint256[] memory randomNumbers) external onlyVRF {
        for(uint i = 0; i<randomNumbers.length; i++){
            randomnessDump3.push(randomNumbers[i]);
        }
        emit RandomnessReceivedOnFunction3(randomNumbers);
    }
    
    function supplyRandomness4(uint256, uint256[] memory randomNumbers) external onlyVRF {
        for(uint i = 0; i<randomNumbers.length; i++){
            randomnessDump4.push(randomNumbers[i]);
        }
        emit RandomnessReceivedOnFunction4(randomNumbers);
    }

    function supplyRandomness5(uint256, uint256[] memory randomNumbers) external onlyVRF {
        for(uint i = 0; i<randomNumbers.length; i++){
            randomnessDump5.push(randomNumbers[i]);
        }
        emit RandomnessReceivedOnFunction5(randomNumbers);
    }

    function supplyRandomness6(uint256, uint256[] memory randomNumbers) external onlyVRF {
        for(uint i = 0; i<randomNumbers.length; i++){
            randomnessDump6.push(randomNumbers[i]);
        }
        emit RandomnessReceivedOnFunction6(randomNumbers);
    }

    function supplyRandomness7(uint256, uint256[] memory randomNumbers) external onlyVRF {
        for(uint i = 0; i<randomNumbers.length; i++){
            randomnessDump7.push(randomNumbers[i]);
        }
        emit RandomnessReceivedOnFunction7(randomNumbers);
    }

    function supplyRandomness8(uint256, uint256[] memory randomNumbers) external onlyVRF {
        for(uint i = 0; i<randomNumbers.length; i++){
            randomnessDump8.push(randomNumbers[i]);
        }
        emit RandomnessReceivedOnFunction8(randomNumbers);
    }

    function supplyRandomness9(uint256, uint256[] memory randomNumbers) external onlyVRF {
        for(uint i = 0; i<randomNumbers.length; i++){
            randomnessDump9.push(randomNumbers[i]);
        }
        emit RandomnessReceivedOnFunction9(randomNumbers);
    }

    function supplyRandomness10(uint256, uint256[] memory randomNumbers) external onlyVRF {
        for(uint i = 0; i<randomNumbers.length; i++){
            randomnessDump10.push(randomNumbers[i]);
        }
        emit RandomnessReceivedOnFunction10(randomNumbers);
    }
}