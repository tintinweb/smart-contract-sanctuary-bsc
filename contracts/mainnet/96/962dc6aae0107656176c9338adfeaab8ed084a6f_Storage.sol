/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.5;

contract Storage {
    struct File {
        uint256 id;
        string ipfsHash;
        uint256 size;
        string tipe;
        string name;
        string description;
        uint256 uploadTime;
        address uploader;
    }

    File[] public files;

    uint256 public fileIndex = 0;

    event FileUploaded(
        uint256 id,
        string ipfsHash,
        uint256 size,
        string tipe,
        string name,
        string description,
        uint256 uploadTime,
        address indexed uploader
    );

    event FileDeleted(uint256 id, uint256 deleteTime, address indexed deleter);

    event FileUpdated(
        uint256 id,
        string name,
        string description,
        uint256 updatedTime,
        address indexed updater
    );

    function uploadFile(
        string memory _ipfsHash,
        uint256 _size,
        string memory _tipe,
        string memory _name,
        string memory _description
    ) external {
        require(msg.sender != address(0));
        require(_size > 0);
        require(bytes(_name).length > 0);
        require(bytes(_ipfsHash).length > 0);
        require(bytes(_tipe).length > 0);
        require(bytes(_description).length > 0);

        fileIndex++;

        File memory newFile = File(
            fileIndex,
            _ipfsHash,
            _size,
            _tipe,
            _name,
            _description,
            block.timestamp,
            msg.sender
        );

        files.push(newFile);

        emit FileUploaded(
            fileIndex,
            _ipfsHash,
            _size,
            _tipe,
            _name,
            _description,
            block.timestamp,
            msg.sender
        );
    }

    function updateFile(uint256 _id, string memory _description) external {
        require(msg.sender != address(0));
        require(bytes(_description).length > 0);

        uint256 i = findFile(_id);

        if (files[i].uploader != msg.sender)
            revert("You can not update files that is not yours");

        files[i].description = _description;

        emit FileUpdated(
            _id,
            files[i].name,
            _description,
            block.timestamp,
            msg.sender
        );
    }

    function deleteFile(uint256 _id) external {
        require(msg.sender != address(0));

        uint256 i = findFile(_id);
        uint256 totalFileCount = files.length;

        if (files[i].uploader != msg.sender)
            revert("You can not delete files that is not yours");

        files[i] = files[totalFileCount - 1];
        delete files[totalFileCount - 1];
        files.pop();

        emit FileDeleted(_id, block.timestamp, msg.sender);
    }

    function getTotalFile() external view returns (uint256 length) {
        return files.length;
    }

    function fileExist(uint256 _id) external view returns (bool success) {
        for (uint256 i = 0; i < files.length; i++) {
            if (files[i].id == _id) {
                return true;
            }
        }

        return false;
    }

    function findFile(uint256 _id) internal view returns (uint256) {
        for (uint256 i = 0; i < files.length; i++) {
            if (files[i].id == _id) {
                return i;
            }
        }

        revert("This file does not exist");
    }
}