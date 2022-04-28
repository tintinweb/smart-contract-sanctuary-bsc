/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC165{
    function supportInterface(bytes4 interfaceId) external view returns(bool);
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns(bytes4);
}

abstract contract ERC165 is IERC165{
    function supportInterface(bytes4 interfaceId) public view virtual override returns (bool){
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC721 is IERC165{
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approval, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from,address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operatos);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

contract ERC721CCTNFT is ERC165, IERC721{
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    uint public totalSold; 
    address payable public contractOwner;
    uint256 public nftCommonPrice;
    uint256 public nftEpicPrice;
    uint256 public nftLegendaryPrice;
    uint256 public canodromeCommonPrice;
    uint256 public canodromeLegendary;

    bool public test = true;

    constructor() payable {
        totalSold = 0;
        contractOwner = payable(msg.sender);
        nftCommonPrice =       1000000000000000;
        nftEpicPrice =         2000000000000000;
        nftLegendaryPrice =    4000000000000000;
        canodromeCommonPrice = 2000000000000000;
        canodromeLegendary =   4000000000000000;
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Not owner");
        _;
    }

    function supportInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool){
        return interfaceId == type(IERC165).interfaceId || super.supportInterface(interfaceId);
    }

    function changeOwner(address payable newOwner ) public onlyOwner returns(bool){
        require(msg.sender == contractOwner);
        contractOwner = newOwner;
        return true;
    }

    function withdraw() public onlyOwner returns(bool){
        require(msg.sender == contractOwner, "Not owner");
        // get the amount of Ether stored in this contract
        uint amount = address(this).balance;
        (bool success,) = contractOwner.call{value: amount}("");
        require(success, "Failed to send Ether");
        return true;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERROR: Non zero address" );
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address){
        address owner = _owners[tokenId];
        require(owner != address(0), "ERROR: token no exist");
        return owner;
    }

    function approve(address to, uint256 tokenId) public virtual override{
        address owner = ownerOf(tokenId);
        require(to != owner, "ERROR: Owner have permission");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "ERROR: You are not the owner or dont have permissions" );
        _approve(to, tokenId);
    }

    function _approve(address to, uint256 tokenId ) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns(address){
        require(_exist(tokenId),"ERROR: Token did no exist");
        return _tokenApprovals[tokenId];
    }  

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != msg.sender,"ERROR: Operator address muts by diferent");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator )public view virtual override returns(bool){
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from,address to,uint256 tokenId) public virtual override{
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERROR: You are not owner or you don have permissions");
        _transfer(from,to,tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId )internal virtual{
        require(ownerOf(tokenId) == from, "ERROR: Token id do not exist");
        require(to != address(0), "ERROR: No transfer to zero address" );

        _approve(address(0), tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override{
        safeTransferFrom(from,to,tokenId,"");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(msg.sender ,tokenId), "ERROR: you dont have permisions");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Reveiver(from, to ,tokenId, _data),"ERROR: ERC721Reveiver not implemented" );
    }
  

    function changeNftPrice(uint nftType, uint256 price) public  onlyOwner returns (bool) {
        require(nftType == 1 || nftType == 2 || nftType == 3 || nftType == 4 || nftType == 5,"ERROR: No valid index");
        if(nftType == 1) nftCommonPrice = price;
        if(nftType == 2) nftEpicPrice = price;
        if(nftType == 3) nftLegendaryPrice = price;
        if(nftType == 4) canodromeCommonPrice = price;
        if(nftType == 5) canodromeLegendary = price;
        return true;
    }

    function returnIndexToken() public view returns(uint){
        return totalSold+1;
    }

    function mint( uint nftType ) public virtual payable returns  (bool) {
        uint tokenId = totalSold+1;
        require(nftType == 1 || nftType == 2 || nftType == 3 || nftType == 4 || nftType == 5 ,"ERROR: no valid index");
        
        require(!_exist(tokenId), "ERC721 ERROR: token alredy minted");
        uint nftPrice;
       
        if(nftType == 5){
            nftPrice = canodromeLegendary;
        }
        if(nftType == 4) {
            nftPrice = canodromeCommonPrice;
        }
        if(nftType == 3) {
            nftPrice = nftLegendaryPrice;
        }
        if(nftType == 2) {
            nftPrice = nftEpicPrice;
        }
        if(nftType == 1) {
            nftPrice = nftCommonPrice;
        }

        require(msg.value == nftPrice,"ERROR: Incorrect Price");
        _balances[contractOwner] += 1;
        _owners[tokenId] = contractOwner;
        totalSold += 1;

        emit Transfer(address(0), contractOwner, tokenId);
        returnIndexToken();
        return true;
    }

    function onSale() public payable returns(bool){
        require(msg.value >0,"ERROR: Invalid value");
        return true;
    }

    function _checkOnERC721Reveiver(address from, address to, uint256 tokenId, bytes memory _data) private returns(bool){
        if(isContract(to)){
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns(bytes4 retval){
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch(bytes memory reason){
                if(reason.length == 0){
                    revert("ERC721: transfer ro non ERC721Receiver implementater");
                }else{
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else{
            return true;
        }
    }

    function isContract(address _addr) private view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function _exist(uint256 tokenId) internal view virtual returns (bool){
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns(bool){
        require(_exist(tokenId),"ERROR: token id not exist");
        address owner = ownerOf(tokenId);
        return ( spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function buyNft(address payable buyer) public payable returns(bool){
        require(msg.value > 0,"ERROR: Invalid value");
        (bool success,) = buyer.call{value:msg.value}("Insufficient balance");
        require(success, "Failed to send Ether");
        return true;
    }
}