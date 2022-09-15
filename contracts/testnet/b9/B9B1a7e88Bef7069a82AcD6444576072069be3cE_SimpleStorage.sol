// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage {
    bytes32 public constant ADMIN = keccak256("ADMIN");
    bytes32 public constant CLIENT = keccak256("CLIENT");
    bytes32 public constant MARKETER = keccak256("MARKETER");

    mapping(address => bytes32) ownerRole;

    function setRole(bytes32 _role) public {
        ownerRole[msg.sender] = _role;
    }

    function getRole(address _address) public view returns (bytes32) {
        return ownerRole[_address];
    }

    function getRoleWithSignature(
        uint8 v,
        bytes32 r,
        bytes32 s,
        address _address,
        uint256 _chainId
    ) public view returns (bytes32) {
        bytes32 eip712DomainHash = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("SimpleStorage")),
                keccak256(bytes("1")),
                _chainId,
                address(this)
            )
        );

        bytes32 hashStruct = keccak256(
            abi.encode(keccak256("getRole(address)"), _address)
        );

        bytes32 hash = keccak256(
            abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct)
        );
        address signer = ecrecover(hash, v, r, s);
        require(signer == msg.sender, "You are not signer");
        require(signer != address(0), "ECDSA: invalid signature");

        return getRole(signer);
    }

    function getAddressWithSignature(
        uint8 v,
        bytes32 r,
        bytes32 s,
        address _address,
        uint256 _chainId
    ) public view returns (address) {
        bytes32 eip712DomainHash = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("SimpleStorage")),
                keccak256(bytes("1")),
                _chainId,
                address(this)
            )
        );

        bytes32 hashStruct = keccak256(
            abi.encode(keccak256("getRole(address _address)"), _address)
        );

        bytes32 hash = keccak256(
            abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct)
        );
        address signer = ecrecover(hash, v, r, s);
        return signer;
    }
}