/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Election {
    // Model a Candidate
    struct Blog {
        address author;
        string title;
        string content;
        uint256 votersCount;
    }

    address public owner;
    mapping(uint256 => Blog) public blogs;
    uint256 public blogCount;
    mapping(uint256 => mapping(address => bool)) public voteState;


    constructor() {
        owner = msg.sender;
    }

    function addBlog(string memory _title, string memory _content) public {
        blogCount++;
        blogs[blogCount] = Blog(msg.sender, _title, _content, 0);
    }

    function voteBlog(uint256 _index) public {
        require(_index > 0, "Blog id cannot be under zero!!!");
        require(_index <= blogCount);
        require(msg.sender != blogs[_index].author);

        blogs[_index].votersCount++;
        voteState[_index][msg.sender] = true;
    }
}