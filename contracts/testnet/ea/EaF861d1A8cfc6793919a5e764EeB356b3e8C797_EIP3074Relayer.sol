/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Example implementation of an EIP-3074 relayer invoker contract.
 *
 * Allows a sponsor to send a transaction on behalf of a sponsoree. Assumes 
 * the sponsorsee has already paid for the transaction (pre-deposit, fiat, etc). 
 */
contract EIP3074Relayer {
    // Replay protection
    mapping(address => uint256) public nonces;
    
    // This struct is only provided to make this example be valid Solidity.
    // Native Solidity support could expose a type similar to this struct, with additional
    // functions like Transaction.send{value: _, gas: _}()
    struct Transaction {
        address sponsee;
        uint256 nextra;
        address to;
        uint256 mingas;
        uint256 value;
        bytes data;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
    
    /**
     * @dev Relays an array of sponsored transactions.
     *
     * Accepts a payment transaction and a list of transactions to be sponsored.
     */
    function relay(Transaction memory sponsoredTx) external {

        // Load the next nonce for the sponsee and check the replay protection 
        address sponsee = sponsoredTx.sponsee;
        uint256 nonce = nonces[sponsee];
        nonces[sponsee] += 1;
        
        // Signature is checked later for nextra, but it should be the nonce we expect. 
        require(sponsoredTx.nextra == uint256(keccak256(abi.encode(nonce, 0))), "incorrect nextra");

        // Throws if the minimum gas or signature check fails 
        (bool success, bool calleeSuccess, bytes memory returnedData) = EIP3074(sponsoredTx);
        
        // Do not update replay protection if the call failed due to opcode checks. 
        // ReturnedData should contain the error message (Some extra work to do; but this can work to return .call() errors). 
        require(success, string(returnedData));
        
        // No need to check success for true/false. It is OK for the user to send failed transactions. We are still paid.
    }
    
    /**
     * @dev Example of how to implement the new OPCODE in solidity. 
     * 
     * Example of execution is when the opcode checks pass (success), but the internal transaction (successCallee) fails.
     */
    function EIP3074(Transaction memory sponsoredTx) internal returns (bool, bool, bytes memory) {
        
        // Enforce minimum gas by the sponsee 
        if(sponsoredTx.mingas > gasleft()) {
            return (false, false, "OPCODE Error: Minimum gas required by the sponsee transaction was not allocated.");
        }
        
        // Form and check signature
        bytes32 h = keccak256(abi.encode(address(this), block.chainid, sponsoredTx.nextra, sponsoredTx.mingas, sponsoredTx.to, sponsoredTx.data, sponsoredTx.value));
        address signer = ecrecover(h, sponsoredTx.v, sponsoredTx.r, sponsoredTx.s); 
        if(sponsoredTx.sponsee != signer) {
            return (false, false, "OPCODE Error: Sponsee specified did not sign this transaction.");
        } 
        
        
        // msg.sender = signer
        // call(to, data, value, mingas); 
        
        // EXAMPLE SCENARIO: The .call() has failed! 
        // So we need to return a failure to the immediate caller. 
        bytes memory returnedData = ""; // Data from the .call(). 
        
        // Success - opcode checks passed, 
        // CalleeSuccess - failed internal transaction
        return (true, false, returnedData);
    }
}