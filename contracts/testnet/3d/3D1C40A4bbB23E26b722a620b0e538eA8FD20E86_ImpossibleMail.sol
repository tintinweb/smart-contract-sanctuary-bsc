// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract ImpossibleMail {
    struct Mail {
        address sender;
        address recipient;
        uint256 timestamp;
        string title;
        string body;
        bool isEncrypted;
    }

    mapping(address => Mail[]) public recipientMailBox;
    mapping(address => Mail[]) public senderMailLog;

    constructor() {}

    /**
     * @dev Store value in variable
     * @param recipients list of addresses that will receive the mail
     * @param title the title of the mail
     * @param body the body of the mail
     * @param isEncrypted whether or not the title and body is encrypted
     */
    function sendMail(
        address[] memory recipients,
        string memory title,
        string memory body,
        bool isEncrypted
    ) public {
        for (uint8 i = 0; i < recipients.length; i++) {
            Mail memory mail = Mail({
                sender: msg.sender,
                recipient: recipients[i],
                timestamp: block.timestamp,
                title: title,
                body: body,
                isEncrypted: isEncrypted
            });

            recipientMailBox[recipients[i]].push(mail);
            senderMailLog[msg.sender].push(mail);
        }
    }

    function getMailBox(address recipient) public view returns (Mail[] memory) {
        return recipientMailBox[recipient];
    }

    function getMailLog(address sender) public view returns (Mail[] memory) {
        return senderMailLog[sender];
    }
}