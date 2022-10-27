// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IDIDAdaptor.sol";

interface IBABT {
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

interface IDCard {
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function exists(uint256 tokenId) external view returns (bool);
}

contract BABTAdaptor is IDIDAdaptor {
    bytes32 constant AccountType_Binance = keccak256("BABT");
    address public idcard;
    address public controller;
    address public babt;

    mapping(uint256 => uint256) public babtOf; // idcard => binance sbt
    mapping(uint256 => uint256) public idcardOf; // babt id => idcard

    event InitAdaptor(address idcard, address controller, address babt);
    event ConnectBABT(uint256 tokenId, uint256 babtId);
    event DisconnectBABT(uint256 tokenId, uint256 babtId);

    constructor(
        address idcard_,
        address controller_,
        address babt_
    ) {
        idcard = idcard_;
        controller = controller_;
        babt = babt_;
        emit InitAdaptor(idcard, controller, babt);
    }

    function connect(
        uint256 tokenId,
        address claimer,
        bytes32 accountType,
        bytes memory sign_info
    ) public override returns (bool) {
        require(msg.sender == controller);
        if (accountType == AccountType_Binance) {
            uint256 babtId = abi.decode(sign_info, (uint256));
            if (
                idcardOf[babtId] != 0 && IDCard(idcard).exists(idcardOf[babtId])
            ) {
                return false;
            }
            if (claimer != IBABT(babt).ownerOf(babtId)) {
                return false;
            }
            idcardOf[babtId] = tokenId;
            babtOf[tokenId] = babtId;
            emit ConnectBABT(tokenId, babtId);
            return true;
        }
        return false;
    }

    function disconnect(uint256 tokenId) external override returns (bool) {
        require(msg.sender == controller);
        uint256 babtId = babtOf[tokenId];
        idcardOf[babtId] = 0;
        babtOf[tokenId] = 0;
        emit DisconnectBABT(tokenId, babtId);
        return true;
    }

    function verifyAccount(uint256 tokenId)
        public
        view
        override
        returns (bool res)
    {
        try this.equalOwner(tokenId, babtOf[tokenId]) returns (bool equal) {
            res = equal;
        } catch {
            res = false;
        }
        return res;
    }

    function equalOwner(uint256 tokenId, uint256 babtId)
        public
        view
        returns (bool)
    {
        return (IDCard(idcard).ownerOf(tokenId) == IBABT(babt).ownerOf(babtId));
    }

    function getSignInfo(uint256 tokenId) external pure returns (bytes memory) {
        return abi.encode(tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface for DID adaptor.
 * DAO users can sign up with 3rd party DID protocols, eg Binance BABT, ENS, etc.
 */
interface IDIDAdaptor {
    function connect(
        uint256 tokenId,
        address claimer,
        bytes32 accountType,
        bytes memory sign_info
    ) external virtual returns (bool);

    function verifyAccount(uint256 tokenId)
        external
        view
        virtual
        returns (bool);

    function disconnect(uint256 tokenId) external virtual returns (bool);
}