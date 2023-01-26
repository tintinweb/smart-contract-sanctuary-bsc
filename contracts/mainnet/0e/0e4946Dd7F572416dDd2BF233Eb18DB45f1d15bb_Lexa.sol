/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

pragma solidity 0.8.15;

interface BeanFlip {
    function rand() external view returns (uint256);
}

contract Lexa {
    BeanFlip private beanFlip =
        BeanFlip(0xe6E2F000E1c142A4A6F359222071b994F8642192);

    uint256 public lastEnsured;
    uint256 public lastRand;

    function ensureOutcome(uint256 outcome) external {
        uint256 rand = beanFlip.rand();
        lastRand = rand % 2;
        lastEnsured = outcome;
        require(rand % 2 == outcome, "You lose!");
    }
}