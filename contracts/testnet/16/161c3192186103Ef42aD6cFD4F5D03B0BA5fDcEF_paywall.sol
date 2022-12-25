/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

// SPDX-License-Identifier: None

pragma solidity 0.8.17;

contract paywall {

    // group data
    struct Group {
        // group paywall status
        bool active;
        // group invite link
        string link;
        // paywall price
        uint256 price;
        // group owner address
        address groupOwner;
        // mapping user ID to boolean value
        // representing user subscription status
        mapping(string => bool) member;
    }

    // mapping: chatTag => chatID
    mapping (string => string) private chatID;
    // mapping: chatID => Group
    mapping (string => Group) private group;

    // group constructor
    function initializeGroup(
        string calldata _chatTag, 
        string calldata _chatID, 
        string calldata _link, 
        uint256 _price
        ) public {

        // check if chat tag is available
        require(group[chatID[_chatTag]].active == false, "* Chat tag unavailable *");
        // map chat tag to corresponding chat ID
        chatID[_chatTag] = _chatID;
        // map chat ID to group
        Group storage newGroup = group[_chatID];
            // initialize group data
            newGroup.active = true;
            newGroup.link = _link;
            newGroup.price = _price;
            newGroup.groupOwner = msg.sender;
    }

    function subscribe(
        string calldata _chatTag, 
        string calldata _userID
        ) payable public {

        // check if chat tag is valid
        require(group[chatID[_chatTag]].active == true, "* Invalid chat tag *");
        // check if amount is correct
        require(msg.value == group[chatID[_chatTag]].price, "* Invalid amount *");
        // check user subscription status
        require(group[chatID[_chatTag]].member[_userID] == false, "* Already subscribed *");
        // pay group owner
        (bool sent,) = group[chatID[_chatTag]].groupOwner.call{value: group[chatID[_chatTag]].price}("");
        require(sent, "* Failed to transfer funds *");
        // update user subscription status
        group[chatID[_chatTag]].member[_userID] = true;
    }

    // group owner can change invite link
    function changeLink(
        string calldata _chatTag,
        string calldata _newLink
    ) public {
        // check if chat tag is valid
        require(group[chatID[_chatTag]].active == true, "* Invalid chat tag *");
        // check if caller is group owner
        require(msg.sender == group[chatID[_chatTag]].groupOwner, "* Caller is not group owner *");
        // set new link
        group[chatID[_chatTag]].link = _newLink;
    }

    // group owner can change subscription price
    function changePrice(
        string calldata _chatTag,
        uint256 _newPrice
    ) public {
        // check if chat tag is valid
        require(group[chatID[_chatTag]].active == true, "* Invalid chat tag *");
        // check if caller is group owner
        require(msg.sender == group[chatID[_chatTag]].groupOwner, "* Caller is not group owner *");
        // set new link
        group[chatID[_chatTag]].price = _newPrice;
    }

    // retrieve group invite link
    function getLink(
        string calldata _chatTag
        ) public view returns(string memory) {
            
        return group[chatID[_chatTag]].link;
    }

    // retrieve group subscription price
    function getPrice(
        string calldata _chatTag
        ) public view returns(uint256) {
            
        return group[chatID[_chatTag]].price;
    }
    
    // retrieve subsciption status of user
    function getSubStatus(
        string calldata _chatID, 
        string calldata _userID
        ) public view returns(bool) {

        return group[_chatID].member[_userID];
    }

    // retrieve status of chat tag
    function isChatTagActive(
        string calldata _chatTag
        ) public view returns(bool) {
            
        return group[chatID[_chatTag]].active;
    }

    // retrieve status of chat tag
    function isChatIdActive(
        string calldata _chatID
        ) public view returns(bool) {
            
        return group[_chatID].active;
    }
}