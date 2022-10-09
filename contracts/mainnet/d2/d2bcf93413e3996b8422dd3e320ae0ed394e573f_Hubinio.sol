/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Hubinio {

    address public owner;
    address public tokenAddress;
    uint256 public timeBetweenClaims;
    uint256 public tokensPerClaim;

    IERC20 private _tokenContract;
    mapping(address => bool) private _bankers;
    mapping(address => uint256[]) private _prizeClaims;

    modifier onlyOwner() {
        require(msg.sender == owner, "can only be called by the contract owner");
        _;
    }

    constructor() {
        owner = 0xb0945503f9fefFa74787ebd29f2f2d3872c787cc;
        timeBetweenClaims = 1 days;
        tokensPerClaim = 100 * 10 ** 18;
        tokenAddress = 0xe33012187aF219072DfF81f54060fEBEd2A91337;
        _tokenContract = IERC20(tokenAddress);
        _bankers[0xEe7550674E949e99a1E4A7a42AF0A7F49E47323e] = true;
    }

    function canClaim(address who) external view returns (bool able, uint256 index) {  
        able = _prizeClaims[who].length == 0 || _prizeClaims[who][_prizeClaims[who].length - 1] < block.timestamp - timeBetweenClaims;
        index = _prizeClaims[who].length;
    }

    function claimReward(bytes memory signature) external {  
        bytes32 hashChallenge = hashPrefixed(keccak256(abi.encodePacked(msg.sender, _prizeClaims[msg.sender].length)));
        address signer = recoverSigner(hashChallenge, signature);
        require(_bankers[signer], "Not signed by a banker");

        _tokenContract.transfer(msg.sender, tokensPerClaim);
        _prizeClaims[msg.sender].push(block.timestamp);
    }

    // Private Functions
    function recoverSigner(bytes32 message, bytes memory sig) private pure returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    function hashPrefixed(bytes32 message) private pure returns (bytes32)
    {
        string memory prefix = "\x19Ethereum Signed Message:\n32";
        return keccak256(abi.encodePacked(prefix, message));
    }

    function splitSignature(bytes memory sig) private pure returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    // Set Time & Tokens
    function setTimeAndTokens(uint256 time, uint256 tokens) external onlyOwner {
        timeBetweenClaims = time;
        tokensPerClaim = tokens;
    }

    // Set Banker
    function setBanker(address who, bool enabled) external onlyOwner {
        _bankers[who] = enabled;
    }

    // Set Owner
    function setOwner(address who) external onlyOwner {
        require(who != address(0), "Cannot be zero address");
        owner = who;
    }

    function removeEth() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }
    
    function removeTokens(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(owner, balance);
    }
}