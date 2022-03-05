/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

contract IPBlogV1 {
    struct Content {
        uint256 publishedOn; // timestamp
        address author;
    }
    mapping(bytes32 => Content) public detailsOf;
    string[] public allContents;
    mapping(address => string[]) public worksOf;
    address[] public allAuthors;

    event NewPost(address author, string cid, uint256 timestamp);
    event NewAuthor(address author);

    constructor() {}

    function publish(string memory cid) external {
        bytes32 cidHash = keccak256(abi.encode(cid));
        require(
            detailsOf[cidHash].author == address(0),
            "E0x01 cannot republish a content that is already published"
        );
        detailsOf[cidHash] = Content(block.timestamp, msg.sender);
        allContents.push(cid);
        if (worksOf[msg.sender].length == 0) {
            allAuthors.push(msg.sender);
            emit NewAuthor(msg.sender);
        }
        worksOf[msg.sender].push(cid);
        emit NewPost(msg.sender, cid, block.timestamp);
    }

    function getAllContents() external view returns (string[] memory) {
        return allContents;
    }

    function getAllAuthors() external view returns (address[] memory) {
        return allAuthors;
    }

    function getWorksOf(address author)
        external
        view
        returns (string[] memory)
    {
        return worksOf[author];
    }
}