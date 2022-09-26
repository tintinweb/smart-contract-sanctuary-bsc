/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

/*  
 * VRF Multiplexer
 * 
 * Useful if you need randomness for several parts of your contract.
 * 
 *
 *
 * How to use this?
 *
 * 1. Add the interface ICCVRFMULTI to your contract
 *
 * 2. Implement any or all of the functions supplyRandomnessX (X being a number from 1 to 10)
 *
 * 3. Get your random number by calling ICCVRFMULTI(0x6776027E3Ea8c547abf32340a15a3e0f12345678).requestRandomness(N,X,R){value: 0.002 ether};
 *    N = requestID (also sometimes called a nonce(number only used once)): 
 *       Use this to identify which of your requests is being answered currently. 
 *       Make sure to always increment that number after you use it.
 *    
 *    X = which of your functions should we use to deliver the random numbers?
 *       Just to make that 100% clear, here's an example: 
 *          X = 7 will use the function supplyRandomness7 in your contract when delivering the random number(s))
 *    
 *    R = how many random numbers do you want this time? 
 *       You can theoretically get any qty of random numbers, but be aware that the gas we use to deliver it is limited.)
 *
 * 4. This contract will get the cryptographically secure random number(s) from our server and call your function supplyRandomnessX.
 *
 * 5. If you're not sure about how to use this or you just don't want to, send a message to @mrgreencrypto on telegram. I'm always happy to help.
 * 
 * 
 *
 * Written by: MrGreenCrypto
 * Co-Founder of CodeCraftrs.com
 * 
 * SPDX-License-Identifier: None
 */
pragma solidity 0.8.17;

// implement these functions (no need to use all of them, but make sure you include the ones you request, otherwise all hell may break loose)
interface IVRF{
    function supplyRandomness1(uint256 requestID, uint256[] memory randomNumbers) external;
    function supplyRandomness2(uint256 requestID, uint256[] memory randomNumbers) external;
    function supplyRandomness3(uint256 requestID, uint256[] memory randomNumbers) external;
    function supplyRandomness4(uint256 requestID, uint256[] memory randomNumbers) external;
    function supplyRandomness5(uint256 requestID, uint256[] memory randomNumbers) external;
    function supplyRandomness6(uint256 requestID, uint256[] memory randomNumbers) external;
    function supplyRandomness7(uint256 requestID, uint256[] memory randomNumbers) external;
    function supplyRandomness8(uint256 requestID, uint256[] memory randomNumbers) external;
    function supplyRandomness9(uint256 requestID, uint256[] memory randomNumbers) external;
    function supplyRandomness10(uint256 requestID, uint256[] memory randomNumbers) external;
}

interface ICCVRF{
    function requestRandomness(uint256 requestID, uint256 howManyNumbers) external payable;
}

// use this to get a random number from this contract
interface ICCVRFMULTI{
    function requestRandomness(uint256 requestID, uint256 functionNumber, uint256 howManyNumbers) external payable;
}

contract CodeCraftrsVRFMultiplexer {
    ICCVRF public randomnessSupplier = ICCVRF(0xC0de0aB6E25cc34FB26dE4617313ca559f78C0dE);
    uint256 public nonce;
    uint256 public vrfCost = 0.002 ether;
    mapping(uint256 => uint256) public functionOfNonce;
    mapping(uint256 => uint256) public requestIdOfNonce;
    mapping(uint256 => address) public whoGetsRandomNumber;

    modifier onlyVRF() {if(msg.sender != address(randomnessSupplier)) return; _;}

    constructor() {}
    receive() external payable {}
    
    function getRandomNumbersForMultipleFunctions(uint256 requestID, uint256 functionNumber, uint256 howManyNumbers) external payable{
        require(msg.value >= vrfCost, "Randomness has a price!");
        functionOfNonce[nonce] = functionNumber;
        requestIdOfNonce[nonce] = requestID;
        whoGetsRandomNumber[nonce] = msg.sender;
        randomnessSupplier.requestRandomness{value: address(this).balance}(nonce, howManyNumbers);
        nonce++;
    }

    function supplyRandomness(uint256 requestID, uint256[] memory randomNumbers) external onlyVRF{
        uint256 functionToCall = functionOfNonce[requestID];
        if      (functionToCall == 1) IVRF(whoGetsRandomNumber[requestID]).supplyRandomness1(requestIdOfNonce[requestID], randomNumbers);
        else if (functionToCall == 2) IVRF(whoGetsRandomNumber[requestID]).supplyRandomness2(requestIdOfNonce[requestID], randomNumbers);
        else if (functionToCall == 3) IVRF(whoGetsRandomNumber[requestID]).supplyRandomness3(requestIdOfNonce[requestID], randomNumbers);
        else if (functionToCall == 4) IVRF(whoGetsRandomNumber[requestID]).supplyRandomness4(requestIdOfNonce[requestID], randomNumbers);
        else if (functionToCall == 5) IVRF(whoGetsRandomNumber[requestID]).supplyRandomness5(requestIdOfNonce[requestID], randomNumbers);
        else if (functionToCall == 6) IVRF(whoGetsRandomNumber[requestID]).supplyRandomness6(requestIdOfNonce[requestID], randomNumbers);
        else if (functionToCall == 7) IVRF(whoGetsRandomNumber[requestID]).supplyRandomness7(requestIdOfNonce[requestID], randomNumbers);
        else if (functionToCall == 8) IVRF(whoGetsRandomNumber[requestID]).supplyRandomness8(requestIdOfNonce[requestID], randomNumbers);
        else if (functionToCall == 9) IVRF(whoGetsRandomNumber[requestID]).supplyRandomness9(requestIdOfNonce[requestID], randomNumbers);
        else if (functionToCall == 10) IVRF(whoGetsRandomNumber[requestID]).supplyRandomness10(requestIdOfNonce[requestID], randomNumbers);
    }
}