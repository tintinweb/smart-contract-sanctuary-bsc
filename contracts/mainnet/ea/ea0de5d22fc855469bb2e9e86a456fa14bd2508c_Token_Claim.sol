/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// https://biteye.info
// BUSD claim for MetaDock event

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20{
    function transfer(address, uint256) external;
    function balanceOf(address) external view returns (uint256);
}

contract VerifySignature {

    function getEthSignedMessageHash(address _to, uint _amount) public pure returns (bytes32){
        return keccak256( abi.encodePacked("\x19Ethereum Signed Message:\n52", _to, _amount) );
    }

    function verify(address _signer, address _to, uint _amount, bytes memory signature) public pure returns (bool) {
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(_to, _amount);
        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
        bytes32 r; bytes32 s; uint8 v;
        require(_signature.length == 65, "invalid signature length");
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

}

contract Token_Claim is VerifySignature {
    IERC20 constant TOKEN = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //BUSD
    address immutable public SIGNER;
    address constant OWNER = 0x84F0Aa29864FfD6490FC98d1E2Dfa31A94569Cbc;
    address constant PAUSER = 0xF0765a9eF92813e5a7aB1C23B179F4dBcf117bA2;
    mapping(address=>bool) public hasClaimed;
    bool public paused;

    constructor(address signer){
        SIGNER = signer;
    }

    modifier whenNotPaused{
        require(!paused, "paused");
        _;
    }

    modifier onlyOwner {
        require(msg.sender==OWNER, "not owner");
        _;
    }

    function sendToken(address to, uint256 amount, bytes calldata signature) whenNotPaused external{
        require(!hasClaimed[to], "has claimed");
        hasClaimed[to] = true;
        require(verify(SIGNER, to, amount, signature), "wrong signature");
        TOKEN.transfer(to, amount);
    }

    function setPause(bool _paused) onlyOwner external{
        paused = _paused;
    }

    function emergencyPause() external{
        require(msg.sender == PAUSER, "only pauser");
        paused = true;
    }

    function withdrawToken() onlyOwner external{
        uint256 balance = TOKEN.balanceOf(address(this));
        TOKEN.transfer(OWNER, balance);
    }

    function proxyCall(address target, bytes calldata call, uint256 value) onlyOwner external{
        (bool success, bytes memory retval) = target.call{value:value}(call);
        require(success, string(retval));
    }
    
}