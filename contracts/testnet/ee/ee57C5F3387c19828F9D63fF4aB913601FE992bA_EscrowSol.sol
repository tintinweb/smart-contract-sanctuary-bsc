// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title EscrowSol
 * @dev Manages fund transfers between two parties
 */
contract EscrowSol {
    // Wallet address of the payer
    address public funder;
    // Wallet address of the intended beneficiary
    address public beneficiary;

    /// Lockup a certain crypto value.
    /// @param counterpart the address of the intended beneficiary
    /// @dev lockup crypto for the counterpart
    function fund(address counterpart) public payable {
        beneficiary = counterpart;
        funder = msg.sender;
    }

    /// Release all locked funds.
    /// @dev The deal is done, let only the payer release fund.
    function release() public payable {
        if (msg.sender==funder){
            // Transfer all the funds to the beneficiary
            payable(beneficiary).transfer(address(this).balance);
        }
    }

    /// Return the locked value.
    /// @dev anyone should be able to see the actually locked crpto value .
    /// @return the crypto value
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}