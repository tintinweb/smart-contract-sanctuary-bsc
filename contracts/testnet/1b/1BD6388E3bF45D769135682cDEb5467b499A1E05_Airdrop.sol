// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Lockable.sol";
import "./Ownable.sol";
import "./ECDSA.sol";

contract Airdrop is Lockable, Ownable, ECDSA {

    address private signer;

    mapping(address => bool) mapClaimed;

    event claimed(address account, uint256 amount);

    constructor(address _auth) Ownable(_auth) {}

    function setSigner(address to) external onlyOwner {
        signer = to;
    }

    function getSigner() external view returns (address res) {
        res = signer;
    }

    function claimAirdrop(address token, uint256 amount, bytes memory signature) external lock {
        require(!mapClaimed[msg.sender], "u'd claimed");
        string memory message = string(abi.encodePacked(addressToString(msg.sender), addressToString(token), uint256ToString(amount)));
        require(_IsSignValid(message, signature), "signature verification error");
        require(ERC20(token).balanceOf(address(this)) >= amount, "insufficient balance");
        require(ERC20(token).transfer(msg.sender, amount), "claim error");
        mapClaimed[msg.sender] = true;
        emit claimed(msg.sender, amount);
    }

    function _IsSignValid(string memory message, bytes memory signature) private view returns(bool) {
        return signer == ECDSA.recover(
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n",
                    Strings.toString(bytes(message).length),
                    message
                )
            ),
            signature
        );
    }

    function refundToken(address token, uint256 amount, address to) external lock onlyOwner {
        require(ERC20(token).balanceOf(address(this)) >= amount, "insufficient balance");
        require(ERC20(token).transfer(to, amount), "claim error");
    }
}