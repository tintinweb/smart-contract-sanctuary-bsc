/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value)external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function burn(uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface Citizenship {
    function checkregister(address _a) external view returns(bool);
    function checkminter(address _a) external view returns(bool);
    function ChangeTotalAsset(address _a,uint256 _total_asset,string memory _type) external returns(bool);
    function ChangeUserRole(address _a,uint256 _role) external returns(bool);
    function userRole(address _address) external view returns(uint256);
}
interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);

     function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

abstract contract ERC165 is IERC165 {

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    string private _name;
    string private _symbol;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(uint256 => string) internal _uri;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    struct UserallTokenid{
        uint256[] ids;
    }
    

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return _uri[tokenId];
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
        
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];
        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        // require(findindex(tokenId,from),"not update tokeid array");
        // useridlist[to].ids.push(tokenId);
        
        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Block is ERC721, Ownable{
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private tokenId;
    address private Admin;
    mapping(uint256 => uint256) private royalty;
    mapping(uint256 => address) private creator;

    mapping(address => bool) private isMinter;
    mapping(address => bool) private isAdmin;

    event onMint(uint256 TokenId, string URI, address creator);
    event onCollectionMint(uint256 collections, uint256 totalIDs, string URI, uint256 royalty);
    address public tokenaddress;
    Citizenship public citizencontract;
    address public nftmarketpalce;
    constructor(string memory name_, string memory symbol_,address _tokenaddress,address _citizencontract,address _nftmarketpalce) ERC721(name_, symbol_){
        isMinter[_msgSender()] = true;
        tokenaddress = _tokenaddress;
        nftmarketpalce = _nftmarketpalce;
        Admin = _msgSender();
        citizencontract = Citizenship(_citizencontract);

    }

    modifier onlyMinter(address _minter) {
        require(isMinter[_minter]);
        _;
    }
    function addAdmin(address _admin) public onlyOwner returns(bool){
        require(_admin != address(0x0), "Admin address set to zero");
        isAdmin[_admin] = true;
        isMinter[_admin] = true;
        // citizencontract.ChangeUserRole(_admin,r);
        return true;
    }

    function addMinter(address _minter) public returns(bool){
        require(isAdmin[_msgSender()] || _msgSender() == owner(), "NFT: Not Admin");
        isMinter[_minter] = true;
        require(citizencontract.ChangeUserRole(_minter,3));
        return true;
    }

    function AddDeveloper(address[] memory _address) public returns(bool){
        require(_msgSender() == owner(), "NFT: Not Owner");
        for(uint256 i=0;i<_address.length;i++){
            require(citizencontract.checkregister(_address[i]),"is not blockchain.land Citizenship ");
            require(citizencontract.ChangeUserRole(_address[i],2));
        }
        return true;
    }
    struct addresslist{
        address[] childAddress;
    }
    mapping(address => addresslist) private DeveleperChildList;

    function AddChildAdderss(address[] memory _list) public returns(bool){
        require(citizencontract.userRole(_msgSender()) == 2,"Caller not developer");
        for(uint256 i=0;i<_list.length;i++){
            require(citizencontract.checkregister(_list[i]),"is not blockchain.land Citizenship ");
            DeveleperChildList[_msgSender()].childAddress.push(_list[i]);
        }
        return true;
    }

    function GetChildernList(address _a) public view returns(address[] memory){
        return DeveleperChildList[_a].childAddress;
    }

    function chnageRole(address[] memory _minter,uint256[] memory _r) public returns(bool){
        require(_msgSender() == owner(), "NFT: Not Owner");
        require(_minter.length == _r.length,"not same data in address and role list");
        for(uint256 i=0;i<_minter.length;i++){
            require(citizencontract.checkregister(_minter[i]),"is not blockchain.land Citizenship ");
            require(citizencontract.ChangeUserRole(_minter[i],_r[i]));
        }
        return true;
    }

    mapping(string=>uint256)private nftvalue;
    mapping(string=>address)private nftaddress;
    mapping(string=>bool)public validcid;
    mapping(string=>uint256) public petanIdRoylty;
    mapping(string=>uint256) public buypetanbnb;
    mapping(string=>uint256) public buypetantoken;

    function mint(string memory petanId,string memory uri,uint256 _tokenamount) public returns(bool){
        require(citizencontract.checkregister(_msgSender()),"is not blockchain.land Citizenship ");
        require(validcid[uri],"invaild cid url");
        address _nftcreater = nftaddress[uri];
        require(_nftcreater != address(0x0),"cid is not Appove");
        require(buypetantoken[petanId] <= _tokenamount,"Not Minimum Amount");

        require(IERC20(tokenaddress).balanceOf(_msgSender()) >= _tokenamount,"not sufficent balance");
        require(IERC20(tokenaddress).transferFrom(msg.sender,address(this),_tokenamount) ,"token not transfer !!!");

        uint256 adminfee = (_tokenamount.mul(10)).div(100);
        uint256 owneramout = _tokenamount.sub(adminfee);
        IERC20(tokenaddress).transfer(_nftcreater,owneramout);
        IERC20(tokenaddress).transfer(Admin,adminfee);

        tokenId.increment();
        uint256 id = tokenId.current();

        _uri[id] = uri;
        creator[id] = _nftcreater;
        royalty[id] = petanIdRoylty[petanId];
        
        _mint(_msgSender(), id);
        emit onMint(id, uri, msg.sender);
        citizencontract.ChangeTotalAsset(_msgSender(),1,"SUM");
        return true;
    }

    function mint(string memory petanId,string memory _cid) public payable returns(bool){
        require(citizencontract.checkregister(_msgSender()),"is not blockchain.land Citizenship ");
        require(validcid[petanId],"invaild cid url");
        address _nftcreater = nftaddress[petanId];
        require(_nftcreater != address(0x0),"cid is not Appove");

        require(msg.value > 0,"not sufficent balance");
        require(buypetanbnb[petanId] <= msg.value,"Not Minimum Amount");
        uint256 _tokenamount = msg.value;
        uint256 adminfee = (_tokenamount.mul(20)).div(100);
        uint256 owneramout = _tokenamount.sub(adminfee);
        payable(_nftcreater).transfer(owneramout);
        payable(Admin).transfer(adminfee);

        tokenId.increment();
        uint256 id = tokenId.current();

        _uri[id] = _cid;
        creator[id] = _nftcreater;
        royalty[id] = petanIdRoylty[petanId];
        _mint(_msgSender(), id);

        emit onMint(id, _cid, msg.sender);
        citizencontract.ChangeTotalAsset(_msgSender(),1,"SUM");
        return true;
    }


    // user role 
    // 1 :- user
    // 2 :- Developer
    // 3 :- Enterprice
    // 4 :- childenterprice

    function devlopermint(string memory cid_,uint256 _royalty,uint256 _bnb,uint256 _token)public returns(bool){
        require(citizencontract.checkregister(_msgSender()),"is not blockchain.land Citizenship ");
        require(citizencontract.userRole(_msgSender()) == 3 || citizencontract.userRole(_msgSender()) == 4 ,"is not minter or childAddress");
        require(isMinter[_msgSender()],"not minter !!!");
        require(_royalty <= 500,"Royalty should be less than 5%");

        tokenId.increment();
        uint256 id = tokenId.current();

        _uri[id] = cid_;
        royalty[id] = _royalty;
        creator[id] = _msgSender() ;

        _mint(_msgSender(), id);
        emit onMint(id, cid_, msg.sender);

        validcid[cid_] = true;
        nftaddress[cid_] = _msgSender();
        petanIdRoylty[cid_] = _royalty;
        buypetanbnb[cid_] = _bnb;
        buypetantoken[cid_] = _token;
        citizencontract.ChangeTotalAsset(_msgSender(),1,"SUM");
        return true;
    }
    function batchMint(string memory uri, uint256 _royalty,uint256 _value) public returns(uint256[] memory, string memory){
        require(citizencontract.checkregister(_msgSender()),"is not blockchain.land Citizenship ");
        require(citizencontract.userRole(_msgSender()) == 3 || citizencontract.userRole(_msgSender()) == 4 ,"is not minter or childAddress");
        require(isMinter[_msgSender()], "NFT: Not Minter");
        require(_value <= 100, "NFT: maximum 100 batch mint is allowed");
        require(_royalty <= 500,"Royalty should be less than 5%");
        uint256[] memory idlist = new uint256[](_value);

        for(uint256 j = 0; j < _value; j++){
            tokenId.increment();
            uint256 id = tokenId.current();
            _uri[id] = uri;
            royalty[id] = _royalty;
            creator[id] = _msgSender();

            idlist[j] = id;
            _mint(_msgSender(), id);
            emit onMint(id, uri, msg.sender);
            citizencontract.ChangeTotalAsset(_msgSender(),1,"SUM");
        }
        nftaddress[uri] = _msgSender();
        validcid[uri] = true;
        petanIdRoylty[uri] = _royalty;


        return (idlist, uri);
    }

    function royaltyOf(uint256 _tokenId) public view returns(uint256){
        return royalty[_tokenId];
    }

    function creatorOf(uint256 _tokenId) public view returns(address){
        return creator[_tokenId];
    }

    function totalSupply() public view returns(uint256){
        return tokenId.current();
    }
    function changeMarketpalce(address _address) public onlyOwner returns(bool){
        nftmarketpalce = _address;
        return true;
    }
    function changetokenaddress(address _taddress) public onlyOwner returns(bool){
        tokenaddress = _taddress;
        return true;
    }

    function changeCitizenShip(address _Caddress) public onlyOwner returns(bool){
        citizencontract = Citizenship(_Caddress);
        return true;
    }
    function transferFrom(address from,address to,uint256 _tokenid) public override {
        // require(_isApprovedOrOwner(_msgSender(), _tokenid), "ERC721: transfer caller is not owner nor approved");
        super.transferFrom(from, to, _tokenid);
        if (to == nftmarketpalce){
            citizencontract.ChangeTotalAsset(from,1,"SUB");
        }
        else if(from == nftmarketpalce){
            citizencontract.ChangeTotalAsset(to,1,"SUM");
        }else{
            citizencontract.ChangeTotalAsset(from,1,"SUB");
            citizencontract.ChangeTotalAsset(to,1,"SUM");
        }
    }

    function safeTransferFrom(address from,address to,uint256 _tokenId) public override {
        super.safeTransferFrom(from, to, _tokenId, "");
        if (to == nftmarketpalce){
            citizencontract.ChangeTotalAsset(from,1,"SUB");
        }else if(from == nftmarketpalce){
            citizencontract.ChangeTotalAsset(to,1,"SUM");
        }else{
            citizencontract.ChangeTotalAsset(from,1,"SUB");
            citizencontract.ChangeTotalAsset(to,1,"SUM");
        }
    }
    // function safeTransferFrom(address from,address to,uint256 _tokenId,bytes memory data) public override {
    //     super._safeTransfer(from, to, _tokenId, data);
        
    // }

}

// contract Main is Block{
//     constructor(string memory name_, string memory symbol_,address _tokenaddress,address _citizencontract,address _nftmarketpalce)
//     Block(name_,symbol_,_tokenaddress,_citizencontract,_nftmarketpalce){}
    
// }