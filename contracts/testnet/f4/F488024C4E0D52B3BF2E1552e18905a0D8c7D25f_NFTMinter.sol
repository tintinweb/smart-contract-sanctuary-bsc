//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./Context.sol";
import "./BEP165.sol";
import "./IBEP721.sol";
import "./IBEP721Metadata.sol";
import "./IBEP721Enumerable.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./EnumerableSet.sol";
import "./EnumerableMap.sol";
import "./Strings.sol";
import "./IBEP721Receiver.sol";
contract NFTMinter is Context,BEP165,IBEP721,IBEP721Metadata,IBEP721Enumerable
{
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;
    // Equals to `bytes4(keccak256("onBEP721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IBEP721Receiver(0).onBEP721Received.selector`
    bytes4 private constant _BEP721_RECEIVED = 0x150b7a02;
    // Mapping from holder address to their (enumerable) set of owned tokens
    mapping(address => EnumerableSet.UintSet) private _holderTokens;
    // Enumerable mapping from token ids to their owners
    EnumerableMap.UintToAddressMap private _tokenOwners;
    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    // Token name
    string private _name;
    // Token symbol
    string private _symbol;
    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;
    // Base URI
    string private _baseURI;
    bytes4 private constant _INTERFACE_ID_BEP721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_BEP721_METADATA = 0x5b5e139f;
    bytes4 private constant _INTERFACE_ID_BEP721_ENUMERABLE = 0x780e9d63;
    constructor(string memory name_, string memory symbol_,string memory baseURI_ ) {
        _name = name_;
        _symbol = symbol_;

        _baseURI = baseURI_ ;
        // register the supported interfaces to conform to BEP721 via BEP165
        _registerInterface(_INTERFACE_ID_BEP721);
        _registerInterface(_INTERFACE_ID_BEP721_METADATA);
        _registerInterface(_INTERFACE_ID_BEP721_ENUMERABLE);
    }
    function balanceOf(address owner)public view virtual override returns (uint256){
        require(owner != address(0),"BEP721: balance query for the zero address");
        return _holderTokens[owner].length();
    }
    function ownerOf(uint256 tokenId)public view virtual override returns (address){
        return _tokenOwners.get(tokenId,"BEP721: owner query for nonexistent token");
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function tokenURI(uint256 tokenId)public view virtual override returns (string memory){
        require(_exists(tokenId),"BEP721Metadata: URI query for nonexistent token");
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();
        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, tokenId.toString()));
    }
    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }
    function tokenOfOwnerByIndex(address owner, uint256 index)public view virtual override returns (uint256){
        return _holderTokens[owner].at(index);
    }
    function totalSupply() public view virtual override returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
        return _tokenOwners.length();
    }
    function tokenByIndex(uint256 index) public view virtual override returns (uint256){
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = NFTMinter.ownerOf(tokenId);
        require(to != owner, "BEP721: approval to current owner");
        require(_msgSender() == owner || NFTMinter.isApprovedForAll(owner, _msgSender()),"BEP721: approve caller is not owner nor approved for all");
        _approve(to, tokenId);
    }
    function getApproved(uint256 tokenId)public view virtual override returns (address){
        require(_exists(tokenId),"BEP721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }
    function setApprovalForAll(address operator, bool approved)public virtual override{
        require(operator != _msgSender(), "BEP721: approve to caller");
        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }
    function isApprovedForAll(address owner, address operator)public view virtual override returns (bool){
        return _operatorApprovals[owner][operator];
    }
    function transferFrom(address from,address to,uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId),"BEP721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(address from,address to,uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId),"BEP721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }
    function _safeTransfer(address from,address to,uint256 tokenId,bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnBEP721Received(from, to, tokenId, _data),"BEP721: transfer to non BEP721Receiver implementer");
    }
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _tokenOwners.contains(tokenId);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId)internal view virtual returns (bool){
        require(_exists(tokenId),"BEP721: operator query for nonexistent token");
        address owner = NFTMinter.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || NFTMinter.isApprovedForAll(owner, spender));
    }
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }
    function _safeMint(address to,uint256 tokenId,bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnBEP721Received(address(0), to, tokenId, _data),"BEP721: transfer to non BEP721Receiver implementer");
    }
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "BEP721: mint to the zero address");
        require(!_exists(tokenId), "BEP721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        _holderTokens[to].add(tokenId);
        _tokenOwners.set(tokenId, to);
        emit Transfer(address(0), to, tokenId);
    }
    function _burn(uint256 tokenId) internal virtual {
        address owner = NFTMinter.ownerOf(tokenId); // internal owner
        _beforeTokenTransfer(owner, address(0), tokenId);
        // Clear approvals
        _approve(address(0), tokenId);
        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0)
         {
            delete _tokenURIs[tokenId];
        }
        _holderTokens[owner].remove(tokenId);
        _tokenOwners.remove(tokenId);
        emit Transfer(owner, address(0), tokenId);
    }
    function _transfer(address from,address to,uint256 tokenId) internal virtual {
        require(NFTMinter.ownerOf(tokenId) == from,"BEP721: transfer of token that is not own"); // internal owner
        require(to != address(0), "BEP721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenId);
        // Clear approvals from the previous owner
        _approve(address(0), tokenId);
        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);
        _tokenOwners.set(tokenId, to);
        emit Transfer(from, to, tokenId);
    }
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual{
        require(_exists(tokenId),"BEP721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }
    function _checkOnBEP721Received(address from,address to,uint256 tokenId,bytes memory _data) private returns (bool) {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(
            abi.encodeWithSelector(IBEP721Receiver(to).onBEP721Received.selector,_msgSender(),from,
                tokenId,_data),"BEP721: transfer to non BEP721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _BEP721_RECEIVED);
    }
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(NFTMinter.ownerOf(tokenId), to, tokenId); // internal owner
    }
    function _beforeTokenTransfer(address from,address to,uint256 tokenId) internal virtual {}
}