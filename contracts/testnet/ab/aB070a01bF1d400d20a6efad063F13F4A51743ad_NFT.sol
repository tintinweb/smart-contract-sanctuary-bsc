/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721Receiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
}

contract NFT {
    struct EnumerableSet{
        uint256[] values;
        mapping(uint256 => uint256) indexes; 
    }
    
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    
    string public name;
    string public symbol;
    string public _uri;
    address public owner;
    uint256 public totalSupply;
    mapping(address => EnumerableSet) private _tokenOfOwner;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    mapping(address => bool) public isMinter;
    
    constructor(string memory _name, string memory _symbol, string memory uri){
        name = _name;
        symbol = _symbol;
        _uri = uri;
        owner = msg.sender;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner, "NFT:onlyOwner");
        _;
    }
    
    function supportsInterface(bytes4 id) external pure returns (bool){
        return id == 0x01ffc9a7 || id == 0x80ac58cd || id == 0x5b5e139f || id == 0x780e9d63;
    }
    
    function _toString(uint256 n) internal pure returns(string memory){
        if(n == 0) return "0";
        unchecked{
            uint256 d = 1;
            uint256 r = 10;
            while(n >= r){
                d++;
                if(d == 78) break;
                r *= 10;
            }
            bytes memory s = new bytes(d);
            for(uint256 i = d; i > 0; i--){
                if(d < 78) r /= 10;
                s[d - i] = bytes1(uint8(n / r));
                n %= r;
            }
            return string(s);
        }
    }
    
    function tokenURI(uint256 _tokenId) external view returns (string memory){
        return string(abi.encodePacked(_uri, _toString(_tokenId)));
    }
    
    function _setOwner(address _owner) external onlyOwner{
        owner = _owner;
    }
    
    function _setURI(string memory uri) external onlyOwner{
        _uri = uri;
    }
    
    function _setMinter(address minter, bool enable) external onlyOwner{
        isMinter[minter] = enable;
    }
    
    function tokenByIndex(uint256 _index) external pure returns (uint256){
        return _index;
    }
    
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256){
        return _tokenOfOwner[_owner].values[_index];
    }
    
    function balanceOf(address _owner) external view returns (uint256){
        return _tokenOfOwner[_owner].values.length;
    }
    
    function setApprovalForAll(address _operator, bool _approved) external{
        isApprovedForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }
    
    function approve(address _approved, uint256 _tokenId) external{
        address _owner = ownerOf[_tokenId];
        require(msg.sender == _owner || isApprovedForAll[_owner][msg.sender], "NFT:notOwnerOrApproved");
        getApproved[_tokenId] = _approved;
        emit Approval(_owner, _approved, _tokenId);
    }
    
    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
        require(_to != address(0), "NFT:zeroAddress");
        if(_from != address(0)){
            uint256 index = _tokenOfOwner[_from].indexes[_tokenId] - 1;
            uint256 last = _tokenOfOwner[_from].values.length - 1;
            if(index != _tokenOfOwner[_from].values.length){
                _tokenOfOwner[_from].values[index] = _tokenOfOwner[_from].values[last];
            }
            _tokenOfOwner[_from].values.pop();
            delete _tokenOfOwner[_from].indexes[_tokenId];
            if(getApproved[_tokenId] != address(0)){
                delete getApproved[_tokenId];
            }
        }
        _tokenOfOwner[_to].values.push(_tokenId);
        _tokenOfOwner[_to].indexes[_tokenId] = _tokenOfOwner[_to].values.length;
        ownerOf[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }
    function transferFrom(address _from, address _to, uint256 _tokenId) public{
        require(ownerOf[_tokenId] == _from, "NFT:notOwner");
        require(msg.sender == _from || isApprovedForAll[_from][msg.sender] || getApproved[_tokenId] == msg.sender, "NFT:notOwnerOrApproved");
        _transferFrom(_from, _to, _tokenId);
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public{
        transferFrom(_from, _to, _tokenId);
        if(_to.code.length > 0){
            require(IERC721Receiver.onERC721Received.selector == IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, data), "NFT:notERC721Receiver");
        }
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external{
        safeTransferFrom(_from, _to, _tokenId, "0x");
    }
    
    function mint(address _to, uint256 quantity) external{
        require(isMinter[msg.sender], "NFT:notMinter");
        require(quantity > 0, "NFT:zeroQuantity");
        for(uint256 i = 0; i < quantity; i++){
            _transferFrom(address(0), _to, totalSupply+i);
        }
        totalSupply += quantity;
    }
}