/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Account {
    struct Info {
        bytes32 nickname;
        bytes32 pubkey;
        uint256 createdAt;
        uint128 isPubkeySet;
        uint128 websiteProtocol; //0 https  1 ipfs 2 ipns 3 hyper
        string website;
        string avatar;
        string introduction;
    }

    mapping(address => Info) infoMap;
    mapping(bytes32 => address) addrMap;

    event nicknameConfigured(address indexed _from, bytes32 nickname);
    event pubkeyConfigured(address indexed _from, bytes32 pubkey);
    event infoUpdated(address indexed _from);

    modifier nickNameOnlyOnce() {
        require(
            infoMap[msg.sender].createdAt == 0,
            "Account: The nickname cannot be modified."
        );
        _;
    }

    modifier pubkeyOnlyOnce() {
        require(
            infoMap[msg.sender].isPubkeySet == 0,
            "Account: The public key cannot be modified."
        );
        _;
    }

    function registerNickName(
        bytes32 nickname,
        uint128 websiteProtocol,
        string memory website,
        string memory avatar,
        string memory introduction
    ) public nickNameOnlyOnce {
        infoMap[msg.sender].createdAt = block.timestamp;
        infoMap[msg.sender].nickname = nickname;

        infoMap[msg.sender].websiteProtocol = websiteProtocol;
        infoMap[msg.sender].website = website;
        infoMap[msg.sender].avatar = avatar;
        infoMap[msg.sender].introduction = introduction;

        addrMap[nickname] = msg.sender;
        emit nicknameConfigured(msg.sender, nickname);
    }

    function updateInfo(
        uint128 websiteProtocol,
        string memory website,
        string memory avatar,
        string memory introduction
    ) public {
        infoMap[msg.sender].websiteProtocol = websiteProtocol;
        infoMap[msg.sender].website = website;
        infoMap[msg.sender].avatar = avatar;
        infoMap[msg.sender].introduction = introduction;
        emit infoUpdated(msg.sender);
    }

    function setPubkey(bytes32 pubkey) public pubkeyOnlyOnce {
        infoMap[msg.sender].isPubkeySet = 1;
        infoMap[msg.sender].pubkey = pubkey;
        emit pubkeyConfigured(msg.sender, pubkey);
    }

    function findAddressByNickname(bytes32 nickname)
        public
        view
        returns (address)
    {
        return addrMap[nickname];
    }

    function findInfoByAddress(address addr) public view returns (Info memory) {
        return infoMap[addr];
    }
}