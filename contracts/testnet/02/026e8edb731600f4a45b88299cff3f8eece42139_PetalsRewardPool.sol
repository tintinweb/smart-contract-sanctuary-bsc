/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ERC20 {
    function transfer(address to, uint value) external returns (bool);
}

contract PetalsRewardPool {
    address public OWNER;
    address public VALIDATOR;
    ERC20 public TOKEN;
    mapping(string => address) public CLAIMED;

    bytes32 private DOMAIN_SEPARATOR;
    bytes32 private PERMIT_TYPE_HASH;

    event Claim(string indexed orderId, address indexed userAddress, uint256 amount, address sender);

    constructor(address validator, ERC20 token) {
        OWNER = msg.sender;
        VALIDATOR = validator;
        TOKEN = token;
        uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("PetalsRewardPool")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
        PERMIT_TYPE_HASH = keccak256("Permit(string orderId,address userAddress,uint256 amount)");
    }

    function updateValidator(address validator) public {
        require(OWNER == msg.sender, "NOT_OWNER");
        VALIDATOR = validator;
    }

    function claim(string memory orderId, address userAddress, uint256 amount, uint8 v, bytes32 r, bytes32 s) public {
        _chaimCheckAndRecord(orderId, userAddress, amount, v, r, s);
        TOKEN.transfer(userAddress, amount);
    }

    function batchClaim(string[] memory orderId, address userAddress, uint256[] memory amount, uint8[] memory v, bytes32[] memory r, bytes32[] memory s) public {
        uint256 sum = 0;
        for (uint8 i = 0; i < orderId.length; ++i) {
            _chaimCheckAndRecord(orderId[i], userAddress, amount[i], v[i], r[i], s[i]);
            sum += amount[i];
        }
        TOKEN.transfer(userAddress, sum);
    }

    function _chaimCheckAndRecord(string memory orderId, address userAddress, uint256 amount, uint8 v, bytes32 r, bytes32 s) private {
        require(CLAIMED[orderId] == address(0), "ALREADY_CLAIMED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPE_HASH, keccak256(bytes(orderId)), userAddress, amount))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress == VALIDATOR, "INVALID_SIGNATURE");
        CLAIMED[orderId] = userAddress;
        emit Claim(orderId, userAddress, amount, msg.sender);
    }

    function withdraw(uint256 amount) public {
        require(OWNER == msg.sender, "NOT_OWNER");
        TOKEN.transfer(OWNER, amount);
    }
}