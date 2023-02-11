/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

pragma solidity 0.8.15;

interface JunaToken {
    function transfer(address _to, uint _amount) external;
    function transferFrom(address _from, address _to, uint _amount) external;
}

contract RelayJunaRecipient {
    address _trustedJunaForwarder;

    constructor(address _forwarder) {
        _trustedJunaForwarder = _forwarder;
    }

    function isTrustedForwarder(address forwarder) public virtual view returns(bool) {
        return forwarder == _trustedJunaForwarder;
    }

    function _msgSender() internal view virtual returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly { sender := shr(96, calldataload(sub(calldatasize(), 20))) }
        } else {
            return msg.sender;
        }
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length-20];
        } else {
            return msg.data;
        }
    }
}

contract JunaSimple is RelayJunaRecipient {
    address public JUNA = 0x0302A7391d1A5B6e42E68aCA687A415CE16675BB; 
    uint public amountJuna;
    address[] public members;
    bytes4 public nextAction;
    
    constructor(
        address[] memory _members,
        address[] memory legalGates,
        uint[] memory legalGatesRewards,
        uint _amountJuna,
        string memory nameSoftware
    ) RelayJunaRecipient(0xAae55eaC69720FF3BB4ce732c51D4BB3Aeb65286) {
        amountJuna = _amountJuna;
        members = _members;
        nextAction = 0x2ccb3dda;
    }

    function depositJuna() public {
        JunaToken(JUNA).transferFrom(_msgSender(), address(this), amountJuna);
        setAction(0x6cee6d77);
    }

    function approveAction() public {
        setAction(0x8a5d815e);
    }

    function transferMoney() public {
        setAction(0x8a5d815e);
    }

    function finishContract() public {
        JunaToken(JUNA).transfer(members[1], amountJuna);
        setAction(0x00000000);
    }

    function _msgSender() internal view override(RelayJunaRecipient)
      returns (address sender) {
      sender = RelayJunaRecipient._msgSender();
    }

    function _msgData() internal view override(RelayJunaRecipient)
        returns (bytes calldata) {
        return RelayJunaRecipient._msgData();
    }

    function setAction(bytes4 _nextAction) public {
        nextAction = _nextAction;
    }
}