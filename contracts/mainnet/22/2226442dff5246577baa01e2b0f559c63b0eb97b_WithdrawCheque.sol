/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract WithdrawCheque {

    address public manager = msg.sender;
    
    mapping(uint => bool) usedNonces;

    function claimPayment(uint amount, uint nonce, string memory secureKey, 
                                        address receiveHere, bytes memory signature) external{

        // This recreates the message that was signed on the client.
        bytes32 hashedMessage = prefixed(keccak256(abi.encodePacked(secureKey, amount, nonce, 
                                                             address(this))));
        
        require(!usedNonces[nonce], 'nonce already used');
        usedNonces[nonce] = true;

        require(recoverSigner(hashedMessage, signature) == manager, 'not signed by manager');
        address recipient = address(receiveHere);
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Withdraw Error. Contract Balance may not be upto amount to be withdrawn");
    }

    //allow contract to recieve ether from EOA or other contract
    receive () payable external  {}

    modifier onlyManger(){
        require(manager == msg.sender, 'manager only');
        _;
    }

    function setManager(address addy) onlyManger external{
        manager = addy;
    }

    function emergency() onlyManger external {
        payable(msg.sender).transfer(address(this).balance);
    }

    function emergencyTokens(address _token, uint amount) onlyManger external{
        IERC20(_token).transfer(msg.sender, amount);
    }

    //signature method
    function splitSignature(bytes memory sig) internal pure returns(uint8, bytes32, bytes32){
        require(sig.length == 65, 'invalid signature length');
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly{
            //first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            //second 32 bytes
            s := mload(add(sig, 64))
            //final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig) private pure returns (address){
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    //build a prefixed hash to mimic the behavior of eth_sign
    function prefixed(bytes32 hash) internal pure returns (bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
        
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}