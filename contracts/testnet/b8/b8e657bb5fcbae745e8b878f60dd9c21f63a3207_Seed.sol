/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Seed {
    // Event emitted when a new seed phrase is stored
    event SeedPhraseStored(address indexed owner, uint256[] tokenIds);

    // Event emitted when a seed phrase is decrypted
    event SeedPhraseDecrypted(address indexed owner);

    // Address of the contract owner
    address owner;

    // Mapping of token IDs to encryption keys
    mapping(uint256 => bytes32) private keys;

    // List of approved wallet addresses
    address[] private approvedWallets;

    // Mapping of approved wallet addresses to their index in the approvedWallets array
    mapping(address => uint256) private approvedWalletsIndices;

    // Modifier that restricts access to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    // Constructor function that sets the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Function that allows the contract owner to add an approved wallet address
    function addApprovedWallet(address wallet) public onlyOwner {
        require(approvedWallets.length < 3, "You cannot add more than 3 approved wallets");
        require(approvedWalletsIndices[wallet] == 0, "Wallet address is already approved");
        approvedWallets.push(wallet);
        approvedWalletsIndices[wallet] = approvedWallets.length;
    }

    // Function that allows the contract owner to remove an approved wallet address
    function removeApprovedWallet(address wallet) public onlyOwner {
        require(approvedWalletsIndices[wallet] > 0, "Wallet address is not approved");
        uint256 index = approvedWalletsIndices[wallet] - 1;
        approvedWallets[index] = approvedWallets[approvedWallets.length - 1];
        approvedWallets.pop();
        approvedWalletsIndices[wallet] = 0;
    }

    // Function that allows a user to store their seed phrase on NFTs
    function storeSeedPhrase(uint256[] memory tokenIds, bytes memory encryptedSeedPhrase) public {
        require(tokenIds.length >= 3 && tokenIds.length <= 15, "You must specify between 3 and 15 token IDs");
        require(approvedWalletsIndices[msg.sender] > 0, "You are not an approved wallet");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            keys[tokenIds[i]] = keccak256(abi.encodePacked(encryptedSeedPhrase, i));
        }
        emit SeedPhraseStored(msg.sender, tokenIds);
    }

    // Function that allows a user to decrypt their seed phrase
    function decryptSeedPhrase(uint256[] memory tokenIds, bytes memory signature) public returns (bytes memory) {
        require(tokenIds.length >= 3 && tokenIds.length <= 15, "You must specify between 3 and 15 token IDs");
        require(approvedWalletsIndices[msg.sender] > 0, "You are not an approved wallet");
        bytes32 hash = keccak256(signature);
        bool validSignature = false;
        for (uint256 i = 0; i < approvedWallets.length; i++) {
            if (hash == keccak256(abi.encodePacked(approvedWallets[i]))) {
                validSignature = true;
                break;
            }
        }
        require(validSignature, "The signature provided is not valid");
            bytes32[] memory keyShares = new bytes32[](tokenIds.length);
    for (uint256 i = 0; i < tokenIds.length; i++) {
        keyShares[i] = keys[tokenIds[i]];
    }

    bytes memory seedPhrase = combineKeyShares(keyShares);
    emit SeedPhraseDecrypted(msg.sender);
    return seedPhrase;
}

// Internal function that combines the key shares using Shamir's Secret Sharing
function combineKeyShares(bytes32[] memory keyShares) internal pure returns (bytes memory) {
    require(keyShares.length >= 3, "You must specify at least 3 key shares");

    uint256[] memory indices = new uint256[](keyShares.length);
    bytes32[] memory values = new bytes32[](keyShares.length);

    for (uint256 i = 0; i < keyShares.length; i++) {
        indices[i] = i + 1;
        values[i] = keyShares[i];
    }

    bytes memory seedPhrase = abi.encodePacked(bytes32(0));
    uint256 threshold = 3;
    uint256 count = indices.length;
    uint256[] memory scratch = new uint256[](count);

    for (uint256 i = 0; i < count; i++) {
        uint256 x = indices[i];
        uint256 y = uint256(values[i]);
        require(x > 0, "Invalid index");
        for (uint256 j = 0; j < count; j++) {
            if (i == j) continue;
            uint256 newBase = indices[j] * x % 257;
            y = y * uint256(values[j]) % 257;
            scratch[j] = newBase;
        }
        uint256 numerator = 1;
        uint256 denominator = 1;
        for (uint256 j = 0; j < count; j++) {
            if (i == j) continue;
            numerator = numerator * scratch[j] % 257;
            denominator = denominator * (scratch[j] + x) % 257;
        }
        uint256 inverse = inverseMod(denominator, 257);
        uint256 coefficient = numerator * inverse % 257;
        uint256 term = coefficient * y % 257;
        seedPhrase = abi.encodePacked(seedPhrase, bytes32(term));
    }

    return seedPhrase;
}

// Internal function that calculates the inverse modulo n using the extended Euclidean algorithm
function inverseMod(uint256 a, uint256 n) internal pure returns (uint256) {
    int256 t = 0;
    int256 newT = 1;
    uint256 r = n;
    uint256 newR = a;

    while (newR != 0) {
        uint256 quotient = r / newR;
        (t, newT) = (newT, int256(t) - int256(quotient) * int256(newT));
        (r, newR) = (newR, r - quotient * newR);
    }

    if (r > 1) {
        revert("Inverse does not exist");
    }

    if (t < 0) {
        t += int256(n);
    }

    return uint256(t);
}
}