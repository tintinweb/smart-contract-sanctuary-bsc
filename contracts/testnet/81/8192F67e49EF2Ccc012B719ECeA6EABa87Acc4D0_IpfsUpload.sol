/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract IpfsUpload {
  // Declare variables for the IPFS API and the file hash

  mapping(address => string[]) public files;


  // Function to send a file to IPFS and retrieve the file's hash
  function sendFile(address owner, string memory filehash) public {
    files[owner].push(filehash);
  }

  // Function to retrieve the file's hash from the IPFS network
  function getFiles(address owner) public view returns (string[] memory) {
    return files[owner];
  }

  function removeFile(address owner, uint256 fileId) public {
      delete files[owner][fileId];
  }
}