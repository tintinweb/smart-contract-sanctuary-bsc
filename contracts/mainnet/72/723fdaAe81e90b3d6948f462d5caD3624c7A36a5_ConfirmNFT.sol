/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
 

 
  interface ERC721 {  
  event Transfer(address indexed _from,address indexed _to,uint256 indexed _tokenId);
  event Approval(address indexed _owner,address indexed _approved,uint256 indexed _tokenId);
  event ApprovalForAll(address indexed _owner,address indexed _operator,bool _approved);
  function safeTransferFrom(address _from,address _to,uint256 _tokenId,bytes calldata _data) external;
  function safeTransferFrom(address _from,address _to,uint256 _tokenId) external;
  function transferFrom(address _from,address _to,uint256 _tokenId) external;

  function approve(address _approved,uint256 _tokenId) external;
    
  function setApprovalForAll(address _operator,bool _approved) external;

  function balanceOf(address _owner) external view returns (uint256);

  function ownerOf(uint256 _tokenId) external view returns (address);

  function getApproved(uint256 _tokenId) external view returns (address);

  function mint(address _to,uint256 _tokenId,address  _uri) external;
    function tokenURI(uint256 _tokenId) external view returns(address  _uri);

  function isApprovedForAll(address _owner,address _operator) external view returns (bool);


  
}
    
 

    
 
    contract Base {
 
         ERC721 constant  internal  NFT = ERC721(0xc9A71c52ae85117FA51c67c3c9f71Ac8bC50E2eb);
 
        address public _owner;
 
        address public _blackHole;

        modifier onlyOwner() {
            require(msg.sender == _owner, "1111"); _;
        }
        modifier isZeroAddr(address addr) {
            require(addr != address(0), "0000"); _; 
        }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }


    function set_blackHole(address newaddress) public onlyOwner {
         _blackHole = newaddress;
    }

    receive() external payable {}  
}
contract ConfirmNFT is Base{
   
     
  function bulkDeposit( uint256[] calldata requestId) external     {
    require(requestId.length > 0, "Deposit requestIdS cannot be empty");
      for (uint256 i = 0; i < requestId.length; ++i) {
       uint256   ID = requestId[i];
       NFT.safeTransferFrom(msg.sender, _blackHole, ID);
    }

 
  }
    
}