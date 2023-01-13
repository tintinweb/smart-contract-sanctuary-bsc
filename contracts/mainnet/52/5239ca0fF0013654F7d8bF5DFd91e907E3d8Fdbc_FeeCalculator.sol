// SPDX-License-Identifier: MarrowLabs
pragma solidity ^0.8.9;

/**
 * @title FeeCalculator
 * @dev Contract that calculates fee for AngelDustRaffle and is meant to replaced, when changing fees and fee calculation mechanisms.
 */
contract FeeCalculator {
    /**
     * @dev Returns fee based on who is creator of the 'raffle'.
     * @param creator A creators address, can be used to give fee discounts.
     * @return fee A fee percentage, where 100% is 1000 and 1% is 10, so that fee can have one decimal.
     */
    function getFee(address creator) view external returns (uint16 fee) {
        return 50; // hardcoded for now at 5%
    }
}