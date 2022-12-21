/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ERC20 {
    function transfer(address to, uint value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Web3ShotQuiz {
    address public OWNER;
    address public ADMIN;
    // Infos
    ERC20 public TOKEN;
    bytes32 public MERKLE_ROOT;
    bytes32 public PREV_MERKLE_ROOT;
    uint64 public GEM_TOTAL;
    uint64 public GEM_USED;
    uint256 public TOKEN_CLAIMED;
    uint32 public UNIQUE_USER;

    mapping(address => uint32) private USER_GEM_CLAIMED;

    struct Info {
        ERC20 token;
        bytes32 merkleRoot;
        uint64 gemTotal;
        uint64 gemUsed;
        uint256 tokenClaimed;
        uint32 uniqueUser;
    }

    event Claim(address indexed sender, uint32 gem, uint32 sum, uint256 token);

    constructor(address admin, ERC20 token) {
        OWNER = msg.sender;
        ADMIN = admin;
        TOKEN = token;
    }

    function updateAdmin(address admin) public {
        require(OWNER == msg.sender, "NOT_OWNER");
        ADMIN = admin;
    }

    function updateToken(ERC20 token) public {
        require(OWNER == msg.sender, "NOT_OWNER");
        TOKEN = token;
    }

    function withdraw(uint256 amount) public {
        require(OWNER == msg.sender, "NOT_OWNER");
        TOKEN.transfer(OWNER, amount);
    }

    function updateClaimData(bytes32 root, uint64 total) public {
        require(OWNER == msg.sender || ADMIN == msg.sender, "NOT_ADMIN");
        PREV_MERKLE_ROOT = MERKLE_ROOT;
        MERKLE_ROOT = root;
        GEM_TOTAL = total;
    }

    function claim(uint32 gem, uint32 sum, bytes32 dataHash, bytes32[] memory proof) public {
        bytes32 computedHash = keccak256(abi.encodePacked(sum, msg.sender, dataHash));
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        // check prev merkle root to ensure users' transactions won't fail after merkle root being updated.
        require((computedHash == MERKLE_ROOT || computedHash == PREV_MERKLE_ROOT), "INVALID_PROOF");
        uint32 gemClaimed = USER_GEM_CLAIMED[msg.sender];
        require(gemClaimed + gem <= sum, "NOT_ENOUGH_GEM");
        uint256 token = exchangeRate() * uint256(gem);
        require(token > 0, "INVALID_CLAIM");
        TOKEN.transfer(msg.sender, token);
        USER_GEM_CLAIMED[msg.sender] = gemClaimed + gem;
        GEM_USED += uint64(gem);
        TOKEN_CLAIMED += token;
        if (gemClaimed == 0) {
            UNIQUE_USER++;
        }
        emit Claim(msg.sender, gem, sum, token);
    }

    function exchangeRate() public view returns (uint256) {
        return TOKEN.balanceOf(address(this)) / uint256(GEM_TOTAL - GEM_USED);
    }

    function userGemClaimed(address user) public view returns (uint256) {
        return USER_GEM_CLAIMED[user];
    }

    function info() public view returns (Info memory) {
        return Info(TOKEN, MERKLE_ROOT, GEM_TOTAL,GEM_USED, TOKEN_CLAIMED, UNIQUE_USER);
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}