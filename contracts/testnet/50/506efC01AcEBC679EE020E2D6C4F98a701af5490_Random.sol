/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// File: contracts/Random.sol


pragma solidity ^0.8.7;

interface RandomGenerationInterface {
    function requestRandomWords() external;
    function topUpSubscription(uint256 _amount) external;
    function addConsumer(address _consumerAddress) external;
    function removeConsumer(address _consumerAddress) external;
    function cancelSubscription(address _receivingWallet) external;
    function setOdinAddress(address _newAddress) external;
    function getRandomWords() external view returns (uint256);
    function withdraw(uint256 _amount, address _to) external;
}

contract Random {
    RandomGenerationInterface public randomGenerator;
    address public randomAddress = 0xa22D82Ff72CaBd272Dfb1574C307012cDA91Ab0C;
    uint256 public randomNumber;

    function getRandom() public returns(uint256) {
        randomGenerator = RandomGenerationInterface(randomAddress);
        randomGenerator.requestRandomWords();
        randomNumber = randomGenerator.getRandomWords();
        return randomNumber;
    }
}