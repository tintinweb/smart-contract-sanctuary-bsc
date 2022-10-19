/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract ERC721{ 


    // event Transfer();
    // event Approval();
    // event ApprovalForAll();

    // function balanceOf();
    // function ownerOf();
    // function safeTransferFrom();
    // function safeTransferFrom();
    // function transferFrom();
    // function approve();
    // function setApprovalForAll();
    // function getApproved();
    // function isApprovedForAll();



    mapping(address => uint256) internal _balances;
    mapping(uint256 => address) internal _owners;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => address) private _tokenApprovals;

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    // ! Returns the number of nft's assigned to an owner.
    function balanceOf(address owner) public view returns(uint256){
        require(owner != address(0));
        return _balances[owner];
    }
    // ! Finds the owner of an nft.
    function ownerOf(uint256 _tokenId) public view returns (address){
        address owner = _owners[_tokenId];
        require(owner != address(0), 'Address is zero');
        return owner;
    }

    // ! Enables or disables an operator to manage all of msg.senders assets.
    function setApprovalForAll(address _operator, bool _approved) external{
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    // ! Checks if an address is an operator for another address
    function isApprovedForAll(address _owner, address _operator) public view returns (bool){
        return _operatorApprovals[_owner][_operator];
    }
    
    // ! Updates an approved addres for an nft
    function approve(address to,uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner || isApprovedForAll(owner,msg.sender), "Msg.sender is not the owner or an approved operator");
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
        
    }

    // ! Gets the approved address for a single nft 
    function getApproved(uint256 tokenId) public view returns(address) {
        require(_owners[tokenId] != address(0), "Token ID does not exist");
        return _tokenApprovals[tokenId];
    }

    // ! Transfers ownership of an nft
    function transferFrom(address _from,address _to,uint256 _tokenId) public {
        address owner = ownerOf(_tokenId);
        require(
            msg.sender == owner ||
            getApproved(_tokenId) == msg.sender ||
            isApprovedForAll(owner,msg.sender),
            "Msg.sender is not the owner or approved for transfer"
        );
        require(owner == _from, "From address is not the owner");
        require(_to != address(0), "Address is zero");
        require(_owners[_tokenId] != address(0), "TokenID does not exist");

        approve(address(0),_tokenId);

        _balances[_from] -=1;
        _balances[_to] += 1;
        _owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    // Checks if onERC721Received is implemented WHEN sending to smart contracts
    function safeTransferFrom(address from, address to , uint256 tokenId, bytes memory _data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(), "Receiver not impleemented");
    }

    function safeTransferFrom(address from,address to, uint256 tokenId) public {
        safeTransferFrom(from,to,tokenId, "");

    }

    // ! Oversimplified
    function _checkOnERC721Received()private pure returns(bool){
        return true;
    }
    
        // EIP165 : Query if a contract implements another interface
    function supportsInterface(bytes4 interfaceId) public pure virtual returns(bool) {
        return interfaceId == 0x80ac58cd;
    }    

}

contract EmoMinter is ERC721{

    string public name; // ERC721Metadata
    string public symbol; // ERC721Metadata
    uint256 public tokenCount; 

    mapping (uint256 => string) private _tokenURIs;

    //mapping (address => uint0)


    constructor(string memory _name, string memory _symbol){
        name = _name;
        symbol = _symbol;
    }
    
    // ! returns a URL that points to the Metadata
    function tokenURI(uint256 tokenId) public view returns (string memory){
        require(_owners[tokenId] != address(0), "TokenId does not exist");
        return _tokenURIs[tokenId];
    }


    // ! Creates a new nfts inside our Collection
    function mint(string memory _tokenURI) public {

        tokenCount += 1; // tokenId
        _balances[msg.sender] += 1;
        _owners[tokenCount] = msg.sender;
        _tokenURIs[tokenCount]= _tokenURI;

        emit Transfer(address(0),msg.sender,tokenCount);
    }

    function supportsInterface(bytes4 interfaceId) public pure override returns(bool){

        return interfaceId == 0x80ac58cd || interfaceId == 0x5b5e139f;
    }

}