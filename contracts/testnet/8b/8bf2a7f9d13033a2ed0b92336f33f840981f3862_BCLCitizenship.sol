/**
 *Submitted for verification at BscScan.com on 2022-07-18
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
interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);
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

abstract contract ERC165 is IERC165 {

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;

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
            _msgSender() == owner || _operatorApprovals[owner][_msgSender()],
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }



    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
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


    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
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

contract BCLCitizenship is ERC721, Ownable{
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    Counters.Counter private tokenId;
    mapping(uint256 => address) private creator;
    mapping(address => bool) private register;
    event onMint(uint256 TokenId, string URI, address creator);
    event onCollectionMint(uint256 collections, uint256 totalIDs, string URI, uint256 royalty);

    constructor(address _tokenaddress) ERC721("BCL-Citizenship", "BCl-CZ"){
        tokenaddress = IERC20(_tokenaddress);
    }
    address[] private registerlist;


    // --------------USER INFO-------------------------

    struct User{
        uint256 total_block;
        uint256 total_citizenship;
        uint256 total_asset;
        uint256 Role;
        uint256 total_country;
        uint256 total_valley;
        address owner;
    }
    address public NFTaddress;
    address public LANDaddress;
    IERC20 tokenaddress;
    uint256 public registerfee = 5*10**18;
    mapping(address => User) public user;
    mapping(address => bool) public isregister;
    
    event registeruser(address user,uint256 timestamp);

    function RegisterUser()public returns(bool){
        require(!isregister[msg.sender],"user not register in BCL");
        // require(tokenaddress.transferFrom(_msgSender(),address(this),registerfee),"not appove BCL ");
        user[msg.sender] = User({total_block : 0,
                                total_citizenship : 0,
                                total_asset : 0,
                                Role : 1,
                                total_country : 0,
                                total_valley : 0,
                                owner : msg.sender
                                });
        // tokenaddress.transfer(owner(),registerfee);
        tokenId.increment();
        uint256 id = tokenId.current();
        _uri[id] = "citizenship";
        creator[id] = _msgSender();
        _mint(_msgSender(), id);
        emit onMint(id, _uri[id], _msgSender());
        isregister[msg.sender] = true;
        emit registeruser(msg.sender,block.timestamp);
        return true;
    }
    function burn(uint256 tokenid)public onlyOwner returns(bool){
        require(_exists(tokenid),"tokenid not exists");
        require(getApproved(tokenid) == _msgSender(),"is not approved");
        _burn(tokenid);
        delete creator[tokenid];
        isregister[msg.sender] = false;
        // findindex(_msgSender());
        return true;
    }
    function checkregister(address _a)public view returns(bool){
        return isregister[_a];
    }
    function changeregisterfee(uint256 _a)public onlyOwner returns(bool){
        registerfee = _a;
        return true;
    }
    // user role 
    // 1 :- user
    // 2 :- Ddeveloper
    // 3 :- Etherprice
    // 4 :- childenterprice
    
    function userRole(address _address) public view returns(uint256){
        require(checkregister(_address) ,"user not register");
        return user[_address].Role;
    }

    function userdata(address _address) public view returns(User memory){
        return user[_address];
    }

    function ChangeUserRole(address _a,uint256 _role)public returns(bool){
        require(checkregister(_a) ,"user not register");
        require(owner() == msg.sender || NFTaddress == msg.sender,"is not owner"); // Role Change Only owner 
        user[_a].Role = _role;
        return true;
    }
    function ChangeTotalBlock(address _a,uint256 _total_block,string memory _type)public  returns(bool){
        require(checkregister(_a) ,"user not register");
        require(LANDaddress == msg.sender,"is not owner"); //Block number change only land contract
        if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("SUM"))){
            user[_a].total_block = user[_a].total_block.add(_total_block);
            return true;
        }else if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("SUB"))){
            user[_a].total_block = user[_a].total_block.sub(_total_block);
            return true;
        }
        return false;
        
    }
    function ChangeTotalCitizenship(address _a,uint256 _citizenship,string memory _type)public returns(bool){
        require(checkregister(_a) ,"user not register");
        require(LANDaddress == msg.sender,"is not land contarct");
        if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("SUM"))){
            user[_a].total_citizenship = user[_a].total_citizenship.add(_citizenship);
            return true;
        }else if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("SUB"))){
            user[_a].total_citizenship = user[_a].total_citizenship.sub(_citizenship);
            return true;
        }
        return false;
    }
    function ChangeTotalAsset(address _a,uint256 _total_asset,string memory _type)public returns(bool){
        require(checkregister(_a) ,"user not register");
        require(NFTaddress == msg.sender,"is not owner");
        if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("SUM"))){
            user[_a].total_asset = user[_a].total_asset.add(_total_asset);
            return true;
        }else if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("SUB"))){
            user[_a].total_asset = user[_a].total_asset.sub(_total_asset);
            return true;
        }
        return false;
        
    }
    function ChangeTotalCountry(address _a,uint256 _country,string memory _type)public returns(bool){
        require(checkregister(_a) ,"user not register");
        require(LANDaddress == msg.sender,"is not owner");
        if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("SUM"))){
            user[_a].total_country = user[_a].total_country.add(_country);
            return true;
        }else if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("SUB"))){
            user[_a].total_country = user[_a].total_country.sub(_country);
            return true;
        }
        return false;
    }
    function ChangeTotalValley(address _a,uint256 _valley,string memory _type)public returns(bool){
        require(checkregister(_a) ,"user not register");
        require(LANDaddress == msg.sender,"is not owner");
        if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("SUM"))){
            user[_a].total_valley = user[_a].total_valley.add(_valley);
            return true;
        }else if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("SUB"))){
            user[_a].total_valley = user[_a].total_valley.sub(_valley);
            return true;
        }
        return false;

    }
    function changeLandAddress(address _landaddress) public onlyOwner returns(bool){
        LANDaddress = _landaddress;
        return true;
    }
    
    function changeNftAddress(address _nftaddress) public onlyOwner returns(bool){
        NFTaddress = _nftaddress;
        return true;
    }
    function changeTokenaddress(address _address)public onlyOwner returns(bool){
        tokenaddress = IERC20(_address);
        return true;
    }
}