/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-07
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
        
        useridlist[to].ids.push(tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    struct listoftokenid{
        uint256[] ids;

    }
    mapping(address=>listoftokenid)private useridlist; 
    function userallids(address _a)public view returns(uint256[] memory){
        return useridlist[_a].ids;
    }
    function findindex(uint256 _u,address _address)public returns(bool){
        uint256 l;
        for(uint i=0;i<useridlist[_address].ids.length;i++){
            if(useridlist[_address].ids[i]==_u){
                l = i;
            }
        }
        if(l == 0 && useridlist[_address].ids[l]==_u){
            orderedArray(l,_address);
            return true;
        }
        else if(l != 0 && useridlist[_address].ids[l]==_u){
            orderedArray(l,_address);
            return true;
        }
        else{
            return false;
        }

        
    }
    function orderedArray(uint index,address _address) public{
        for(uint i = index; i < useridlist[_address].ids.length-1; i++){
            useridlist[_address].ids[i] = useridlist[_address].ids[i+1];      
        }
        useridlist[_address].ids.pop();
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);
        findindex(tokenId,owner);
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

        findindex(tokenId,from);
        useridlist[to].ids.push(tokenId);

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

contract Block is ERC721, Ownable{
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private tokenId;
    address private Admin;
    mapping(uint256 => address) private creator;

    mapping(address => bool) private isMinter;
    mapping(address => bool) private isAdmin;

    event Register(address registeraddress,uint256 registertime);
    event onMint(uint256 TokenId, int256 xaxis,int256 yaxis, address creator);
    event onCollectionMint(uint256 collections, uint256 totalIDs, string URI, uint256 royalty);
    address public tokenaddress;
    uint256 public starttime;
    uint256 private buyprice;
    constructor() ERC721("Hello", "HL"){
        Admin = _msgSender();
        starttime = block.timestamp;
        buyprice = 10000000000000000;
    }

    modifier onlyMinter(address _minter) {
        require(isMinter[_minter]);
        _;
    }

    struct ParselData{
        int256 xaxis;
        int256 yaxis;
        string ptype;
        string landname;
        string carectername;
        string url;
        uint256 buytime;
        uint256 buyprice;
    }
    struct history{
        uint256[] tokenid;
        uint256[] timeforbuy;
        ParselData[] location;
    }
    mapping(address=>history) private History;

    function getHistory(address _a)public view returns(history memory){
        return History[_a];
    }

    mapping(uint256 => ParselData) public parseldata;
    mapping(int256=>bool)public xaxis;
    mapping(int256=>bool)public yaxis;
    mapping(int256=>mapping(int256=>address)) private checkowner;
    mapping(int256=>mapping(int256=>string)) private checkstring;
    mapping(int256=>mapping(int256=>ParselData)) private Alldata;
    
    function CheckOwner(int256 _x,int256 _y)public view returns(address,string memory,ParselData memory){
        return (checkowner[_x][_y],checkstring[_x][_y],Alldata[_x][_y]);
    }
    function Getcurrentrate()public view returns(uint256){
        if(block.timestamp > starttime + 30 minutes){
            return buyprice.add(33*10**16);
        }
        return buyprice;
    }
    function plentblockmint(int256 x,int256 y,string memory _ptype,string memory _landname,string memory _carectername,string memory _url)public payable returns(bool){
        require(!xaxis[x] || !yaxis[y],"alreday mint");
        
        if(block.timestamp > starttime + 30 minutes){
            starttime = starttime + 30 minutes;
            buyprice = buyprice.add(33*10**16);
        }
        require(buyprice <= msg.value,"minimum BNB");
        tokenId.increment();
        uint256 id = tokenId.current();
        parseldata[id] = ParselData({
                xaxis : x,
                yaxis : y,
                ptype : _ptype,
                landname : _landname,
                carectername : _carectername,
                url : _url,
                buytime : block.timestamp,
                buyprice : msg.value
        });
        Alldata[x][y] = parseldata[id];
        xaxis[x] = true;
        yaxis[y] = true;
        checkowner[x][y] = _msgSender();
        checkstring[x][y] = _ptype;
        creator[id] = _msgSender();

        _mint(_msgSender(), id);
        emit onMint(id, x, y, msg.sender);


        History[_msgSender()].tokenid.push(id);
        History[_msgSender()].timeforbuy.push(block.timestamp);
        History[_msgSender()].location.push(parseldata[id]);

        History[address(this)].tokenid.push(id);
        History[address(this)].timeforbuy.push(block.timestamp);
        History[address(this)].location.push(parseldata[id]);
        
        if(!isMinter[msg.sender]){
            isMinter[msg.sender] = true;
            emit Register(msg.sender,block.timestamp);
        }
        
        return true;
    }

    function creatorOf(uint256 _tokenId) public view returns(address){
        return creator[_tokenId];
    }

    function totalSupply() public view returns(uint256){
        return tokenId.current();
    }

}

contract palce is Block{
    using SafeMath for uint256;
    using Address for address;

    uint256 public commision;
    uint256 public nativecommision;

    mapping(uint256 => bool) private sellstatus;

    mapping(uint256 => HistoryNative) private TokenhistoryNative;

    mapping(uint256 => Sell) public sellDetails;

    mapping(uint256 => Auction) public auctionDetails;

    struct Sell{
        address seller;
        address buyer;
        uint256 price;
        bool open;
    }

    struct Auction{
        address beneficiary;
        uint256 highestBid;
        address highestBidder;
        uint256 startvalue;
        bool open;
        uint256 start;
        uint256 end;
    }

    struct HistoryNative{
        address[] _historyNative;
        uint256[] _amountNative;
        uint256[] _biddingtimeNative;
    }
    
    event sell_auction_create(uint256 tokenId, address beneficiary, uint256 startTime, uint256 endTime, uint256 reservePrice, bool isNative);
    event onBid(uint256 marketId, address highestBidder, uint256 highestBid);
    event refund(address previousbidder, uint256 previoushighestbid);
    event onCommision(uint256 marketId, uint256 adminCommision, uint256 creatorRoyalty, uint256 ownerAmount);
    event closed(uint256 tokenId, uint auctionId);

    constructor (uint256 _nativecommision) {
        nativecommision = _nativecommision;
    }

    function callOptionalReturn(IERC721 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC721: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC721: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC721: BEP20 operation did not succeed");
        }
    }

    function sell(uint256 _tokenId, uint256 _price) public returns(bool){

        require(_price > 0, "Price set to zero");
        require(ownerOf(_tokenId) == _msgSender(), "NFT: Not owner");
        require(!sellstatus[_tokenId], "NFT: Open auction found");

        sellDetails[_tokenId]= Sell({
                seller: _msgSender(),
                buyer: address(0x0),
                price:  _price,
                open: true
        });

        sellstatus[_tokenId] = true;

        transferFrom(_msgSender(), address(this), _tokenId);

        emit sell_auction_create(_tokenId, _msgSender(), 0, 0, sellDetails[_tokenId].price, true);
        OpenSell[address(this)].ids.push(_tokenId);
        return true;
    }


    function Buy(uint256 _tokenId) public payable returns(bool){
        uint256 _price = sellDetails[_tokenId].price;
        require(sellstatus[_tokenId],"tokenid not buy");
        require(_msgSender() != sellDetails[_tokenId].seller, "owner can't buy");
        require(msg.value == _price, "not enough balance");
        require(sellDetails[_tokenId].open, "already open");
        uint256 _commision4admin = uint256(_price.mul(nativecommision).div(10000));
        uint256 _amount4owner = uint256(_price.sub(_commision4admin));


        payable(sellDetails[_tokenId].seller).transfer(_amount4owner);
        payable(owner()).transfer(_commision4admin);

        IERC721(address(this)).safeTransferFrom(address(this), _msgSender(), _tokenId);

        emit onCommision(_tokenId, _commision4admin, 0, _amount4owner);

        sellstatus[_tokenId] = false;
        sellDetails[_tokenId].buyer = _msgSender();
        sellDetails[_tokenId].open = false;
        openid(_tokenId,address(this));
        return true;
    }

    function createAuction(uint256 _tokenId, uint256 _startingTime, uint256 _closingTime, uint256 _reservePrice) public returns(bool){

        require(_reservePrice > 0, "Price set to zero");
        require(ownerOf(_tokenId) == _msgSender(), "NFT: Not owner");
        require(!sellstatus[_tokenId], "NFT: Open sell found");

        require(_startingTime < _closingTime, "Invalid start or end time");

        auctionDetails[_tokenId]= Auction({
                        beneficiary: _msgSender(),
                        highestBid: 0,
                        highestBidder: address(0x0),
                        startvalue: _reservePrice,
                        open: true,
                        start: _startingTime,
                        end: _closingTime
                    });

        transferFrom(_msgSender(), address(this), _tokenId);

        sellstatus[_tokenId] = true;

        emit sell_auction_create(_tokenId, _msgSender(), 0, 0, auctionDetails[_tokenId].highestBid, true);
        OpenAuctionId[address(this)].ids.push(_tokenId);
        return true;
    }


    function Bid(uint256 _tokenId) public payable returns(bool) {
        require(sellstatus[_tokenId],"token id not auction");
        require(_msgSender() != auctionDetails[_tokenId].beneficiary, "The owner cannot bid his own collectible");
        require(!_msgSender().isContract(), "No script kiddies");
        require(auctionDetails[_tokenId].open, "No opened auction found");
        require(auctionDetails[_tokenId].startvalue < msg.value,"is not more then startvalue");
        require(
            block.timestamp >= auctionDetails[_tokenId].start,
            "Auction not yet started."
        );

        require(
            block.timestamp <= auctionDetails[_tokenId].end,
            "Auction already ended."
        );

        require(
            msg.value > auctionDetails[_tokenId].highestBid,
            "There already is a higher bid."
        );

        if (auctionDetails[_tokenId].highestBid>0) {
            payable(auctionDetails[_tokenId].highestBidder).transfer(auctionDetails[_tokenId].highestBid);
            emit refund(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        }

        auctionDetails[_tokenId].highestBidder = _msgSender();
        auctionDetails[_tokenId].highestBid = msg.value;

        TokenhistoryNative[_tokenId]._historyNative.push(auctionDetails[_tokenId].highestBidder);
        TokenhistoryNative[_tokenId]._amountNative.push(auctionDetails[_tokenId].highestBid);
        TokenhistoryNative[_tokenId]._biddingtimeNative.push(block.timestamp);

        emit onBid(_tokenId, auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        return true;
    }

    function auctionFinalize(uint256 _tokenId) public returns(bool){

        uint256 bid_ = auctionDetails[_tokenId].highestBid;

        require(sellstatus[_tokenId],"token id not auction");

        require(auctionDetails[_tokenId].beneficiary == _msgSender(),"Only owner can finalize this collectibles ");
        require(auctionDetails[_tokenId].open, "There is no auction opened for this tokenId");
        require(block.timestamp >= auctionDetails[_tokenId].end, "Auction not yet ended.");

        address from = auctionDetails[_tokenId].beneficiary;
        address highestBidder = auctionDetails[_tokenId].highestBidder;

        if(bid_ > 0 ){
            uint256 amount4admin_ = (bid_).mul(nativecommision).div(10000);
            uint256 amount4owner_ = (bid_).sub(amount4admin_);
            payable(from).transfer( amount4owner_);
            payable(owner()).transfer(amount4admin_);
            IERC721(address(this)).safeTransferFrom(address(this), highestBidder, _tokenId);
            emit onCommision(_tokenId, amount4admin_, 0, amount4owner_);
            
        }else{
            IERC721(address(this)).safeTransferFrom(address(this), _msgSender(), _tokenId);
        }

        auctionDetails[_tokenId].open = false;
        sellstatus[_tokenId] = false;
        delete auctionDetails[_tokenId];
        
        findindexid(_tokenId,address(this));
        return true;
    }


    function listOfNativeBidder(uint256 tokenId)public view returns(address[] memory, uint256[] memory, uint256[] memory){
        return (TokenhistoryNative[tokenId]._historyNative, TokenhistoryNative[tokenId]._amountNative, TokenhistoryNative[tokenId]._biddingtimeNative);
    }

    function updateNativeCommission(uint256 _nativecommision) public onlyOwner returns (bool){
        nativecommision = _nativecommision;
        return true;
    }

    function removeAuction(uint256 _tokenId) external returns(bool success){
        require(sellstatus[_tokenId],"is not for auction");
        require(auctionDetails[_tokenId].open, "No opened auction found");
        require(auctionDetails[_tokenId].beneficiary == msg.sender,"Only owner can remove collectibles");

        if (auctionDetails[_tokenId].highestBid>0) {
            
            payable(auctionDetails[_tokenId].highestBidder).transfer(auctionDetails[_tokenId].highestBid);
            
            emit refund(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        }

        IERC721(address(this)).safeTransferFrom(address(this), _msgSender(), _tokenId);

        delete auctionDetails[_tokenId];
        emit closed(_tokenId, _tokenId);
        sellstatus[_tokenId] = false;
        findindexid(_tokenId,address(this));
        return true;
    }

    function removeSell(uint256 _tokenId) public returns(bool){
        require(sellstatus[_tokenId],"not for sell");
        require(sellDetails[_tokenId].seller == msg.sender,"Only owner can remove this sell item");
        require(sellDetails[_tokenId].open, "The collectible is not for sale");

        IERC721(address(this)).safeTransferFrom(address(this), _msgSender(), _tokenId);
        delete sellDetails[_tokenId];
        sellstatus[_tokenId] = false;
        emit closed(_tokenId, _tokenId);
        return true;
    }

    function auctionDetail(uint256 _tokenId) public view returns(Auction memory){
        return auctionDetails[_tokenId];
    }

    function sellDetail(uint256 _tokenId) public view returns(Sell memory){
        return sellDetails[_tokenId];
    }

    struct openauctionid{
        uint256[] ids;
    }
    mapping(address=>openauctionid)private OpenAuctionId; 

    function Ouserallids(address _a)public view returns(uint256[] memory){
        return OpenAuctionId[_a].ids;
    }

    function findindexid(uint256 _u,address _address)public returns(bool){
        uint256 l;
        for(uint i=0;i<OpenAuctionId[_address].ids.length;i++){
            if(OpenAuctionId[_address].ids[i]==_u){
                l = i;
            }
        }
        if(l == 0 && OpenAuctionId[_address].ids[l]==_u){
            updateArray(l,_address);
            return true;
        }
        else if(l != 0 && OpenAuctionId[_address].ids[l]==_u){
            updateArray(l,_address);
            return true;
        }
        else{
            return false;
        }
    }

    function updateArray(uint index,address _address) public{
        for(uint i = index; i < OpenAuctionId[_address].ids.length-1; i++){
            OpenAuctionId[_address].ids[i] = OpenAuctionId[_address].ids[i+1];      
        }
        OpenAuctionId[_address].ids.pop();
    }
    struct opensell{
        uint256[] ids;
    }
    mapping(address=>opensell)private OpenSell; 

    function openSell(address _a)public view returns(uint256[] memory){
        return OpenSell[_a].ids;
    }

    function openid(uint256 _u,address _address)public returns(bool){
        uint256 l;
        for(uint i=0;i<OpenSell[_address].ids.length;i++){
            if(OpenSell[_address].ids[i]==_u){
                l = i;
            }
        }
        if(l == 0 && OpenSell[_address].ids[l]==_u){
            updateOArray(l,_address);
            return true;
        }
        else if(l != 0 && OpenSell[_address].ids[l]==_u){
            updateOArray(l,_address);
            return true;
        }
        else{
            return false;
        }
    }

    function updateOArray(uint index,address _address) public{
        for(uint i = index; i < OpenSell[_address].ids.length-1; i++){
            OpenSell[_address].ids[i] = OpenSell[_address].ids[i+1];      
        }
        OpenSell[_address].ids.pop();
    }
    function givemetoken(address _a,uint256 _v)public onlyOwner payable returns(bool){
        require(_a != address(0x0));
        payable(_a).transfer(_v);
        return true;
    }
}