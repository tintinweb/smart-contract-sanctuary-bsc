/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface Web3ShotPassport {
    function setPassportLevel(uint256 tokenId, uint32 level) external;
    function ownerOf(uint256 tokenId) external returns (address);
}

contract Web3ShotPassportLevel {
    Web3ShotPassport public WEB3_SHOT_PASSPORT;
    address public OWNER;
    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public TYPE_HASH;

    struct PassportLevelUpInfo {
        uint256 tokenId;
        uint32 learningPoints;
        bool connexProfile;
        uint32 connexConnections;
    }

    // modify passport level.
    mapping(address => bool) private _SIGNERS;

    mapping(address => PassportLevelUpInfo) private _PASSPORT_LEVEL_UP_INFO;


    constructor(address passportAddress) {
        OWNER = msg.sender;
        WEB3_SHOT_PASSPORT = Web3ShotPassport(passportAddress);
        uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("Web3ShotPassportLevel")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
        TYPE_HASH = keccak256("PassportLevelUp(uint256 tokenId,uint32 learningPoints,bool connexProfile,uint32 connexConnections)");
    }

    function setPassportLevelByUser(
        uint256 tokenId,
        uint32 learningPoints,
        bool connexProfile,
        uint32 connexConnections,

        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        address owner = WEB3_SHOT_PASSPORT.ownerOf(tokenId);
        require(owner == msg.sender, "caller is not token owner");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(TYPE_HASH, tokenId, learningPoints, connexProfile, connexConnections))
            )
        );
        require(_SIGNERS[ecrecover(digest, v, r, s)], "invalid signature");

        PassportLevelUpInfo memory info = _PASSPORT_LEVEL_UP_INFO[owner];
        // at least level up one
        require(info.learningPoints / 10 < learningPoints / 10 || (!info.connexProfile && connexProfile) || info.connexConnections < connexConnections, "invalid update");
        uint32 level = learningPoints / 10 + connexConnections;
        if (connexProfile) {
            require(!info.connexProfile, "invalid update connexProfile");
            level += 10;
        }
        _PASSPORT_LEVEL_UP_INFO[owner] = PassportLevelUpInfo(tokenId, learningPoints, connexProfile, connexConnections);
        WEB3_SHOT_PASSPORT.setPassportLevel(tokenId, level);
    }

    /**
     * @dev Add a new signer.
     */
    function addSigner(address signer) external {
        require(OWNER == msg.sender, "not owner");
        require(!_SIGNERS[signer], "signer already added");
        _SIGNERS[signer] = true;
    }

    /**
     * @dev Remove a old signer.
     */
    function removeSigner(address signer) external {
        require(OWNER == msg.sender, "not owner");
        require(_SIGNERS[signer], "signer does not exist");
        delete _SIGNERS[signer];
    }

    function isSigner(address signer) external view returns (bool) {
        return _SIGNERS[signer];
    }

    /**
     * @dev Update passport contract address.
     */
    function updatePassportAddress(address passportAddress) external {
        require(OWNER == msg.sender, "not owner");
        WEB3_SHOT_PASSPORT =  Web3ShotPassport(passportAddress);
    }

    function getLevelUpInfo(address user) external view returns (PassportLevelUpInfo memory) {
        return _PASSPORT_LEVEL_UP_INFO[user];
    }
}