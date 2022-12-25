/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Persssist {
    string public name = "Persssist";
    uint256 public fileCount = 0;
    
    // this mapping behaves as a "catalog"
    // of files uploaded to the storage, we declare
    // it as public in order to access it directly from the Frontend
    mapping(uint256 => File) public files;

    struct File {
        uint256 fileId;
        string filePath;
        uint256 fileSize;
        string fileType;
        string fileName;
        address payable uploader;
    }

    event FileUploaded(
        uint256 fileId,
        string filePath,
        uint256 fileSize,
        string fileType,
        string fileName,
        address payable uploader
    );
    
    // we upload the file metadata
    // to the smart contract files
    // mapping in order to persist
    // the information.
    function uploadFile(
        string memory _filePath,
        uint256 _fileSize,
        string memory _fileType,
        string memory _fileName
    ) public {
        require(bytes(_filePath).length > 0);
        require(bytes(_fileType).length > 0);
        require(bytes(_fileName).length > 0);
        require(msg.sender != address(0));
        require(_fileSize > 0);
        
        // since solidity mappings
        // do not have a lenght attribute
        // the simplest way to control the amount 
        // of files is using a counter
        fileCount++;

        files[fileCount] = File(
            fileCount,
            _filePath,
            _fileSize,
            _fileType,
            _fileName,
            payable(msg.sender)
        );
        
        // From the frontend application
        // we can listen the events emitted from
        // the smart contract in order to update the UI.
        emit FileUploaded(
            fileCount,
            _filePath,
            _fileSize,
            _fileType,
            _fileName,
            payable(msg.sender)
        );
    }
}