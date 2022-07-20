// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract WorkshopFeedback {
    mapping (address => uint) feedbacks;

    event Feedback(uint pazimys, string feedback);

    function writeFeedback(uint pazimys, string memory feedback) public {
        require(feedbacks[msg.sender] == 0, "WorkshopFeedback: This wallet has already written a feedback");
        require(pazimys >= 0 && pazimys <= 10, "WorkshopFeedback: Pazimys should be between 0 and 10");

        feedbacks[msg.sender] = pazimys;
        emit Feedback(pazimys, feedback);
    }
}