/**
 *Submitted for verification at BscScan.com on 2022-08-02
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
    function ChangeTotalBlock(address _a,uint256 _total_block,string memory _type)external  returns(bool);
    function ChangeTotalCitizenship(address _a,uint256 _citizenship,string memory _type)external returns(bool);
    function checkUserStatus(address _user) external view returns(bool);
    function createcountry(string memory _name,address _owner,address _countryAddress) external returns(bool);
}
interface nftcontract {
    function BurnToken(uint256 _tokenId,address user) external returns(bool);
}
interface Deploymentcontract{
    function CountryContract(address _owner,address citizensship,string memory _name) external returns(address);
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
    mapping(uint256 => bool) internal iscitizenship;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    struct UserallTokenid{
        uint256[] ids;
    }
    mapping(address=>UserallTokenid)private useridlist; 

    function UserAllTokenid(address _a)public view returns(uint256[] memory){
        return useridlist[_a].ids;
    }
    
    function findindex(uint256 _u,address _address)private returns(bool){
        uint256 l;
        for(uint i=0;i<useridlist[_address].ids.length;i++){
            if(useridlist[_address].ids[i]==_u){
                l = i;
            }
        }
        if(l == 0 && useridlist[_address].ids[l]==_u){
            useridlist[_address].ids.pop();
            return true;
        }
        else if(l != 0 && useridlist[_address].ids[l]==_u){
            for(uint i = l; i < useridlist[_address].ids.length-1; i++){
                useridlist[_address].ids[i] = useridlist[_address].ids[i+1];      
            }
            useridlist[_address].ids.pop();
            return true;
        }
        else{
            return false;
        }
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
        require(!iscitizenship[tokenId],"citizenship not transfer ");
        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
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


contract BCLLand is ERC721, Ownable{
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter public tokenId;
    address public Admin;
    mapping(uint256 => address) public creator;
    mapping(address => bool) public isAdmin;

    event onMint(uint256 TokenId, string URI, address creator,int256 xaxis,int256 yaxis,bool isstatus);
    event onCollectionMint(uint256 collections, uint256 totalIDs, string URI, uint256 royalty);
    IERC20 public tokenaddress;
    address public citizencontract;
    address public Depolymentaddress;
    address public nftaddress;

    constructor(address _tokenaddress,address _citizencontract)
        ERC721("BCL-Land", "BCL-LAND"){
            tokenaddress = IERC20(_tokenaddress);
            Admin = _msgSender();
            citizencontract = (_citizencontract);
    }

    uint256 public country_mint_fee = 225312500000000000000000 ;
    uint256 public valleymint = 36050000000000000000000 ;
    string[] public  total_country_name;

    struct Country{
        string name;
        bool isactivate;
        address owner;
        uint256 countryID;
        address countryAddress;
        uint256 buycoutryFee;
        uint256 mintedblock;
        bool mintend;
        
    }
    mapping(uint256 => uint256) public revoketime;
    mapping(uint256 => bool) public iscountry;
    mapping(uint256 => string) public countryname;
    mapping(uint256 => Country) private countryInfo;
    mapping(string => uint256) public countrynameofstring;
    mapping(string => bool) public isminted;
    mapping(string => bool) public countrycitizenship;

    uint256 public totalcountry;
    
    struct blockinfo{
        uint256 tokenid;
        int256 x;
        int256 y;
        string s3img;
        string jsoncid;
        string _type;
        bool isSellAble;
        uint256 contryId;
    }

    mapping(uint256 => blockinfo) public BlockInfo;
    mapping(int256 => mapping(int256 => uint256)) public _id; // x_y_tokenid
    mapping(uint256 => string) public palnCID;
    event countryContrctMint(address User,address CountryCotractAddress,string name,uint256 countryid,uint256 revokedate);
    function checkTokenIdstatus(uint256 _tokenid) public view returns(bool){
        return BlockInfo[_tokenid].isSellAble;
    }

    uint256 public revokeday;
    event changeRevokeTime(uint256 oldtime,uint256 newtime);
    function changerevoketime(uint256 day) public onlyOwner returns(bool){
        uint256 oldtime = revokeday;
        revokeday = day;
        emit changeRevokeTime( oldtime, revokeday);
        return true;
    }
    function onlyvalidUser(address user)public view returns(bool){
        require(Citizenship(citizencontract).checkregister(user),"is not blockchain.land Citizenship ");
        require(Citizenship(citizencontract).checkUserStatus(user)," user is block");
        return true;
    }
    function changeSupportAddress(address saddress) public onlyOwner returns(bool){
        support = saddress;
        return true;
    }
    address public support;

    function CreateCountry(uint256 _tokenID,string memory _name,uint256 totalblock,string memory _plan_cid,bool iscountrystatus) public returns(bool){
        // require(verify(support,msg.sender,totalblock,xylist,_nonce,signature),"user not verifyr");
        onlyvalidUser(msg.sender);
        // uint256 mintblock = totalblock;
        string memory planid = _plan_cid;
        string memory newname = string(abi.encodePacked("BCL_",_name));

        require(nftcontract(nftaddress).BurnToken(_tokenID,_msgSender()),"is not burn tokenid");
        require(!isminted[newname],"country is minted");

        // bytes memory payload = abi.encodeWithSignature("CountryContract(address,address,string)",msg.sender,citizencontract,newname);
        // (bool success,bytes memory result ) = address(Depolymentaddress).call(payload);
        // address _countryAddress = abi.decode(result, (address));
        // require(success,"new contact not deploy");
        address _countryAddress = Deploymentcontract(Depolymentaddress).CountryContract(msg.sender,citizencontract,newname);
        require(_countryAddress != address(0x0),"not call new contract deplyment");

        uint256 amount;
        if(_msgSender() != owner()){
            if (iscountrystatus){
                require(tokenaddress.transferFrom(_msgSender(),address(this),country_mint_fee),"not appove BCL ");
                amount = country_mint_fee;
                
            }
            else{
                require(tokenaddress.transferFrom(_msgSender(),address(this),valleymint),"not appove BCL ");
                amount = valleymint;
                
            }
            tokenaddress.burn(amount);
        }

        totalcountry = totalcountry.add(1);

        countryInfo[totalcountry] = Country({name : newname,
                                            isactivate : true,
                                            owner : msg.sender,
                                            countryID : totalcountry,
                                            countryAddress : _countryAddress,
                                            buycoutryFee : amount,
                                            mintedblock : totalblock,
                                            mintend : true
                                            });
        countrynameofstring[newname] = totalcountry;
        total_country_name.push(newname);
        
        

        iscountry[totalcountry] = true;
        isminted[newname] = true;
        revoketime[totalcountry] = block.timestamp + (1 days * revokeday) ;
        emit countryContrctMint(msg.sender,_countryAddress, newname,totalcountry,revoketime[totalcountry]);
        
        // bytes memory payload1 = abi.encodeWithSignature("createcountry(string,address,address)",newname,msg.sender,_countryAddress);
        // (bool success1,bytes memory result1 ) = address(citizencontract).call(payload1);
        // bool d = abi.decode(result1, (bool));
        // require(success1 && d,"createcountry in citizencontract not call");

        bool s = Citizenship(citizencontract).createcountry(newname,msg.sender,_countryAddress);
        require(s,"is not call citizencontract");
        
        countryFunction(_countryAddress, countryInfo[totalcountry].name, planid);
        return true;
    }

    function countryFunction(address _countryAddress,string memory name,string memory _plan_cid) internal {
        bytes memory payload2 = abi.encodeWithSignature("mintcountry(string,address,string,bool)",name, address(tokenaddress), _plan_cid,false);
        (bool success2,bytes memory result2) = address(_countryAddress).call(payload2);
        bool d2 = abi.decode(result2, (bool));
        require(success2 && d2,"tokentransfer not call");
    }
    function extraMintBlock(uint256 _countryID,int[] memory x,int[] memory y,bool[] memory _isstatus)public returns(bool){
        onlyvalidUser(msg.sender);
        require(iscountry[_countryID],"change country name");
        require(countryInfo[_countryID].mintend,"all block is minted");
        require(countryInfo[_countryID].mintedblock != 0,"block mint is zero");
        require(countryInfo[_countryID].mintedblock >= x.length,"is more then total Minted Block");
        string memory _name = countryname[_countryID];
        require(x.length == y.length && x.length <= 100,"x and y is not same");
        require(countryInfo[_countryID].owner == msg.sender,"is not country owner");
        
        for(uint256 i=0;i<x.length;i++){
            require(_id[x[i]][y[i]] == 0,"x and y are minted");
            tokenId.increment();
            uint256 id = tokenId.current();

            BlockInfo[id].x = x[i];
            BlockInfo[id].y = y[i];
            BlockInfo[id].tokenid = id;
            BlockInfo[id].contryId = _countryID;
            BlockInfo[id].isSellAble = _isstatus[i];

            _id[x[i]][y[i]] = id;
            creator[id] = _msgSender();
            _mint(_msgSender(), id);
            emit onMint(id, "", msg.sender,x[i],y[i],_isstatus[i]);
        }
        countryInfo[_countryID].mintedblock = countryInfo[_countryID].mintedblock.sub(x.length);
        if(countryInfo[_countryID].mintedblock == 0){
            countryInfo[_countryID].mintend = false;
        }
        // changeExtraBlock(uint256 _totalBlock)
        bytes memory payload = abi.encodeWithSignature("changeExtraBlock(uint256)",x.length);
        (bool success,bytes memory result ) = address(countryInfo[_countryID].countryAddress).call(payload);
        bool d = abi.decode(result, (bool));
        require(success && d,"tokentransfer not call");

        Citizenship(citizencontract).ChangeTotalBlock(_msgSender(),x.length,"SUM");
        // countryInfo[_name].ownerAssin = countryInfo[_name].ownerAssin.add(x.length);
        emit extracpuntrymint(msg.sender,_countryID,_name,x.length);
        return true;
    }
    
    function GetTotalCountry()public view returns(string[] memory){
        return total_country_name;
    }
    function ismintingCountry(string memory _name)public view returns(bool){
        return isminted[_name];
    }
    function countryAllMint(uint256 _countryID)public view returns(bool){
        return countryInfo[_countryID].mintend;
    }
    function getcontryInfo(uint256 _countryId)public view returns(Country memory){
        return countryInfo[_countryId];
    }
    event changecountrymintfee(uint256 Oldamount,uint256 newamount);
    function change_country_mint_fee(uint256 _amount) public onlyOwner returns(bool){
        uint256 Oldamount = country_mint_fee;
        country_mint_fee = _amount;
        emit changecountrymintfee( Oldamount,country_mint_fee);
        return true;
    }
    event changevalleymintfee(uint256 Oldamount,uint256 newamount);
    function change_valleymint_fee(uint256 _amount) public onlyOwner returns(bool){
        uint256 Oldamount = country_mint_fee;
        valleymint = _amount;
        emit changevalleymintfee( Oldamount,valleymint);
        return true;
    }
    event newcpuntrymint(address user,uint256 countrycount,string name,uint256 assignblock);
    event extracpuntrymint(address user,uint256 countrycount,string name,uint256 assignblock);
    event newvalleymint(address user,string _name,uint256 totalblock);
    
    function checkstatus(int256 x,int256 y)public view returns(bool){
        if(_id[x][y] == 0){
            return true;
        }
        return false;
    }
    event ChangeBlockInfo(uint256 tokenid,string img,string cidjson,string blocktype);
    function changeBlockInfo(uint256 _tokenId, string memory _s3img,string memory _jsoncid,string memory _Type) public returns(bool){
        onlyvalidUser(msg.sender);
        require(creator[_tokenId] == _msgSender(),"Not TokenId Owner");
        uint256 countryid = BlockInfo[_tokenId].contryId;
        require(!countryInfo[countryid].mintend,"All blocks are not minted");
        BlockInfo[_tokenId].s3img = _s3img;
        BlockInfo[_tokenId].jsoncid = _jsoncid;
        BlockInfo[_tokenId]._type = _Type;
        emit ChangeBlockInfo(_tokenId,_s3img,_jsoncid,_Type);
        return true;
    }
    event LockCountry(string countryname,bool status);
    function LockTheCountry(uint256 _countryId,bool _status) public onlyOwner returns(bool){
        countryInfo[_countryId].isactivate = _status;
        // call the country contract function
        bytes memory payload = abi.encodeWithSignature("LockTheCountry(bool)",_status);
        (bool success,bytes memory result ) = address(countryInfo[_countryId].countryAddress).call(payload);
        bool d = abi.decode(result, (bool));
        require(success && d,"tokentransfer not call");
        // call citizenship contarct
        bytes memory payload1 = abi.encodeWithSignature("LockTheCountry(bool)",_status);
        (bool success1,bytes memory result1 ) = address(citizencontract).call(payload1);
        bool d1 = abi.decode(result1, (bool));
        require(success1 && d1,"tokentransfer not call");
        emit LockCountry(countryInfo[_countryId].name,_status);
        return true;
    }
    
    function transferFrom(address from,address to,uint256 _tokenid) public override {
        // check user is not block in citizenship contarctcheck 
        uint256 country = BlockInfo[_tokenid].contryId;
        require(countryInfo[country].isactivate && country != 0,"lock the Country");
        // require(countryInfo[country].countryAddress == msg.sender,"is only call countryAddress");
        require(ownerOf(_tokenid) == msg.sender,"is only call countryAddress");
        
        super.transferFrom(from,to,_tokenid);
        if (countryInfo[country].countryAddress == to){
            onlyvalidUser(from);
            Citizenship(citizencontract).ChangeTotalBlock(from,1,"SUB");
            
        }else if(countryInfo[country].countryAddress == from){
            onlyvalidUser(to);
            Citizenship(citizencontract).ChangeTotalBlock(to,1,"SUM");
            
        }else if(to != countryInfo[country].countryAddress && countryInfo[country].countryAddress != from){
            onlyvalidUser(from);
            onlyvalidUser(to);
            Citizenship(citizencontract).ChangeTotalBlock(from,1,"SUB");
            Citizenship(citizencontract).ChangeTotalBlock(to,1,"SUM");
            
        }
    }
    function safeTransferFrom(address from,address to,uint256 _tokenId) public override {
        safeTransferFrom(from, to, _tokenId, "");
    }
    function safeTransferFrom(address from,address to,uint256 _tokenId,bytes memory data) public override {
        // check user is not block in citizenship contarct
        uint256 country = BlockInfo[_tokenId].contryId;
        require(countryInfo[country].isactivate && country != 0,"lock the Country");
        // require(countryInfo[country].countryAddress == msg.sender,"is only call countryAddress");
        require(ownerOf(_tokenId) == msg.sender,"is only call countryAddress");

        super.safeTransferFrom(from, to, _tokenId, data);

        if (countryInfo[country].countryAddress == to){
            onlyvalidUser(from);
            Citizenship(citizencontract).ChangeTotalBlock(from,1,"SUB");
            
        }else if(countryInfo[country].countryAddress == from){
            onlyvalidUser(to);
            Citizenship(citizencontract).ChangeTotalBlock(to,1,"SUM");
            
        }else if(to != countryInfo[country].countryAddress && countryInfo[country].countryAddress != from){
            onlyvalidUser(from);
            onlyvalidUser(to);
            Citizenship(citizencontract).ChangeTotalBlock(from,1,"SUB");
            Citizenship(citizencontract).ChangeTotalBlock(to,1,"SUM");
        }
    }
    event CountryCitizenShip(address user,address countryaddress,uint256 amount,address tokenaddress,uint256 cititokenid);
    
    function countryCitizenShip(string memory _countryname,address _user)public returns(bool){
        onlyvalidUser(_user);
        uint256 _countryId = countrynameofstring[_countryname];
        require(countryInfo[_countryId].countryAddress == msg.sender,"is not call countryContract");
        require(iscountry[_countryId],"country not mint at time");
        
        // string memory name = countryInfo[_countryId].name;
        require(!countrycitizenship[_countryname],"is already buy citizenship");

        countrycitizenship[countryname[_countryId]] = true;

        tokenId.increment();
        uint256 id = tokenId.current();
        _uri[id] = string(abi.encodePacked(_countryname, "_citizenship"));
        creator[id] = _user;
        _mint(_user, id);
        iscitizenship[id] = true;
        emit onMint(id, _uri[id], _user,0,0,false);
        emit CountryCitizenShip(_user, countryInfo[_countryId].countryAddress, 0, address(0x0), id);
        Citizenship(citizencontract).ChangeTotalCitizenship(_user,1,"SUM");
        return true;
        
    }
    event BlockCountryCitizenship(address user,bool status,string countryname);
    function blockCountryCitizenship(string memory _countryname,address _user,bool status)public returns(bool){
        onlyvalidUser(_user);
        uint256 _countryId = countrynameofstring[_countryname];
        require(countryInfo[_countryId].countryAddress == msg.sender || owner() == msg.sender,"is not call countryContract");
        require(iscountry[_countryId],"Country not mint at time");
        countrycitizenship[countryname[_countryId]] = status;
        emit BlockCountryCitizenship(_user, status, countryInfo[_countryId].name);
        return true;
    }

    function RevokBlock(uint256[] memory _tokenId) public returns(bool){
        require(owner() == msg.sender,"is not call owner");
        for(uint256 i=0;i<_tokenId.length;i++){
            require(_exists(_tokenId[i]), "ERC721: token not exixts");
            require(revoketime[BlockInfo[_tokenId[i]].contryId] < block.timestamp,"is not revoketime now");
            Citizenship(citizencontract).ChangeTotalBlock(ownerOf(_tokenId[i]),1,"SUB");
            _id[BlockInfo[_tokenId[i]].x][BlockInfo[_tokenId[i]].y] = 0;
            delete BlockInfo[_tokenId[i]];
            _burn(_tokenId[i]);
        }
        return true;
    }

    event Changetokenaddress(address oldaddress,address newaddress);
    function changetokenaddress(address _taddress) public onlyOwner returns(bool){
        address oldaddress = address(tokenaddress);
        tokenaddress = IERC20(_taddress);
        emit Changetokenaddress(oldaddress,_taddress);
        return true;
    }
    event changeDepolymentAddress(address newaddress,address oldaddress);
    function changeDepolymentaddress(address _Depolymentaddress) public onlyOwner returns(bool){
        address oldaddress = Depolymentaddress;
        Depolymentaddress = _Depolymentaddress;
        emit changeDepolymentAddress(Depolymentaddress, oldaddress);
        return true;
    }
    event changeNFTAddress(address newaddress,address oldaddress);
    function changenftaddress(address _nftaddress)public onlyOwner returns(bool){
        address oldaddress = nftaddress;
        nftaddress = _nftaddress;
        emit changeNFTAddress( nftaddress,oldaddress);
        return true;
    }
    function GetTokenIdData(int256 x,int256 y)public view returns(uint256,blockinfo memory,Country memory){
        uint256 _tokenid = _id[x][y];
        return (_tokenid,BlockInfo[_tokenid],countryInfo[BlockInfo[_tokenid].contryId]);
    }
    function getMessageHash(
        address useraddress,
        uint _amount,
        string memory xylist,
        uint _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(useraddress, _amount,xylist, _nonce));
    }
    function verify(
        address _signer,
        address useraddress,
        uint _amount,
        string memory xylist,
        uint _nonce,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(useraddress, _amount,xylist, _nonce);
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        private
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        private
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        // implicitly return (r, s, v)
    }
}