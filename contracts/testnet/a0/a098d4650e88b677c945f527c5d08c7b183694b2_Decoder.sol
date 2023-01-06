/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Decoder {
    /**
     * @dev event DecodeData created on new bet apeared
     * owner - message sender
     * betID - bet ID
     * conditionIDs - condition ids
     * outcomeIDs - outcome ids
     * coefficients - coefficients
     * amount - bet amount in payment tokens
     * affiliate_ - bet affiliate
     */
    event DecodeData(
        bytes32[] conditionIDs,
        bytes32[] outcomeIDs,
        uint256[] coefficients,
        uint256 amount,
        address affiliate_
    );
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
    }

    function decode(
        bytes calldata data
    ) external {
        (
            bytes32[] memory conditionIDs,
            bytes32[] memory outcomeIDs,
            uint256[] memory coefficients,
            uint256 amount,
            address affiliate_
        ) = abi.decode(
                data,
                (bytes32[], bytes32[], uint256[], uint256, address)
            );

        emit DecodeData(
            conditionIDs,
            outcomeIDs,
            coefficients,
            amount,
            affiliate_
        );
    }
}