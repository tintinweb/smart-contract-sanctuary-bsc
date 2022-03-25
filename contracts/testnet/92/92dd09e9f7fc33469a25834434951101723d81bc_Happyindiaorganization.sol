/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.16;

contract Happyindiaorganization {
    // Keep track of total number of images in contract
    uint256 public imageCount = 0;

    // Data structure to store images data
    struct Image {
        uint256 id;
        string hash;
        string description;
        uint256 donationAmount;
        address payable author;
    }

    mapping(uint256 => Image) public images;

    // Event emitted when image is created
    event ImageCreated(
        uint256 id,
        string hash,
        string description,
        uint256 donationAmount,
        address payable author
    );

    // Event emitted when an there is a donation
    event DonateImage(
        uint256 id,
        string hash,
        string description,
        uint256 donationAmount,
        address payable author
    );

    // Create an Image
    function uploadImage(string memory _imgHash, string memory _description)
        public
    {
        require(bytes(_imgHash).length > 0);
        require(bytes(_description).length > 0);
        require(msg.sender != address(0x0));
        imageCount++;
        images[imageCount] = Image(
            imageCount,
            _imgHash,
            _description,
            0,
            msg.sender
        );
        emit ImageCreated(
            imageCount,
            _imgHash,
            _description,
            0,
            msg.sender
        );
    }

    //donateImageOwner is a public payable function that accepts the id of the image
    function donateImageOwner(uint256 _id) public payable {
        require(_id > 0 && _id <= imageCount);

        Image memory _image = images[_id];
        address payable _author = _image.author;
        address(_author).transfer(msg.value);
        _image.donationAmount = _image.donationAmount + msg.value;
        images[_id] = _image;

        emit DonateImage(
            _id,
            _image.hash,
            _image.description,
            _image.donationAmount,
            _author
        );
    }
}