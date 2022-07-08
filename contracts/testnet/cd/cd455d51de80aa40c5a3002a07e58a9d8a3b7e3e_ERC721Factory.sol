//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "nftBasic.sol";



interface Imint{
    
   function mint(string memory _tokenURI, address _toAddress) external returns (uint);
   function transferOwnership(address newOwner) external ;
}

contract ERC721Factory {
    
    address payable public contract_owner ; 
    address[] public NFTS;
    address admin;
    
    event NewNFT(address indexed _address, address indexed _creator);
    

    constructor(address _admin){

        contract_owner=payable (msg.sender);
        admin=_admin;
    }


    function createToken (string memory _tokenName, string memory _tokenSymbol,string memory _tokenURI) public payable returns(address,uint){

        (address _depCont,uint _tokenId) = _createNFT(_tokenName, _tokenSymbol,_tokenURI);

        return (_depCont,_tokenId);
    }


    function _createNFT(string memory _tokenName, string memory _tokenSymbol,string memory _tokenURI ) internal returns(address,uint) {

        pocketERC721 deployed = new pocketERC721(_tokenName,_tokenSymbol,admin);
        Imint(address(deployed)).transferOwnership(contract_owner); 
        uint _mint = Imint(address(deployed)).mint(_tokenURI,msg.sender); // mint
        
        NFTS.push(address(deployed));
        
        emit NewNFT(address(deployed), msg.sender);

        return (address(deployed),_mint);
    }
    


    
}