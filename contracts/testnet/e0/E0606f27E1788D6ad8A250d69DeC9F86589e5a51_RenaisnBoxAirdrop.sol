// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ICard {
    function mintTo(address account_) external returns (uint256);

    function activateCard(
        address account,
        uint256 cardId,
        uint256 lv,
        string memory uuid
    ) external;
}

contract RenaisnBoxAirdrop {
    address public owner;
    address public immutable cardAddress;

    bool public isEnd = false;
    uint256 private airdropLv = 1;
    mapping(address => bool) public whiteList;
    mapping(address => bool) public isWhiteBuy;

    constructor(address cardAddr_) {
        owner = msg.sender;
        cardAddress = cardAddr_;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function setOwner(address newAddr_) external onlyOwner {
        owner = newAddr_;
    }

    function setEnd() external onlyOwner {
        isEnd = true;
    }

    function setAirdropLv(uint256 lv_) external onlyOwner {
        airdropLv = lv_;
    }

    function setWhiteList(address[] memory addrlist, bool _value)
        external
        onlyOwner
    {
        require(addrlist.length > 0, "addrlist error");
        for (uint256 i = 0; i < addrlist.length; i++) {
            whiteList[addrlist[i]] = _value;
        }
    }

    function receiveBox(string memory uuid) external returns (bool) {
        require(
            whiteList[msg.sender] && !isWhiteBuy[msg.sender],
            "caller is not allowed"
        );

        isWhiteBuy[msg.sender] = true;
        uint256 cardId = ICard(cardAddress).mintTo(msg.sender);
        ICard(cardAddress).activateCard(msg.sender, cardId, airdropLv, uuid);

        return true;
    }
}