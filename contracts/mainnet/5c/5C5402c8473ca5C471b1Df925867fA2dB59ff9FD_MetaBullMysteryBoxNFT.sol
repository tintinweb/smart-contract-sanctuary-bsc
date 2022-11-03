/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;


interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
    function transferFrom(address from,address to,uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data) external;
}
interface IERC721MetaBull is IERC165 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
    function transferFrom(address from,address to,uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data) external;
    function mintNFTTo(uint256 degree,address to) external;
}

interface IERC721Receiver {
    function onERC721Received(address operator,address from,uint256 tokenId,bytes calldata data) view external returns (bytes4);
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
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
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeERC20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
}
library Counters {
    struct Counter {
        uint256 _value;
    }
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }
    function increment(Counter storage counter) internal {
        unchecked {counter._value += 1;}
    }
}

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract ERC721 is Context,ERC165, IERC721, IERC721Metadata,IERC721Receiver,Ownable {
    using Address for address;
    using Strings for uint256;

    string private _name;
    string private _symbol;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
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
        require(_exists(tokenId), "FBXNFT: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),"ERC721: approve caller is not owner nor approved for all");
        _approve(to, tokenId);
    }
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");
        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    function transferFrom(address from,address to,uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(address from,address to,uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }
    function _safeTransfer(address from,address to,uint256 tokenId,bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }
    function _safeMint(address to,uint256 tokenId,bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data),"ERC721: transfer to non ERC721Receiver implementer");
    }
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);
        _approve(address(0), tokenId);
        _balances[owner] -= 1;
        delete _owners[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }
    function _transfer(address from,address to,uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenId);
        _approve(address(0), tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(address from,address to,uint256 tokenId,bytes memory _data) private view returns (bool) {
        if (to.isContract()){
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval){
              return retval == IERC721Receiver.onERC721Received.selector;
            }
            catch (bytes memory reason){
                if (reason.length == 0){
                  revert("ERC721: transfer to non ERC721Receiver implementer");
                }
                else{
                  assembly {revert(add(32, reason), mload(reason))}
                }
            }
        } else {
            return true;
        }
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    function _beforeTokenTransfer(address from,address to,uint256 tokenId) internal virtual {}
}

abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;
    uint256[] private _allTokens;
    mapping(uint256 => uint256) private _allTokensIndex;

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }
    function tokenOfOwner(address owner) public view returns (uint256[] memory) {
        uint256 num = ERC721.balanceOf(owner);
        uint256[] memory Token_list = new uint256[](uint256(num));
        for(uint256 i=0; i<num; ++i) {
            Token_list[i] =_ownedTokens[owner][i];
        }
        return Token_list;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }
    function _beforeTokenTransfer(address from,address to,uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];
        uint256 lastTokenId = _allTokens[lastTokenIndex];
        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
    function onERC721Received(address,address,uint256,bytes memory) public view virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
         return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }
}

abstract contract RandomNum {
    using SafeMath for uint256;
    uint256 internal _maxNum;
    mapping(uint256 => bool) private _bUse;
    mapping(uint256 => uint256) private _useNum;
    uint256 private _randkey1;
    uint256 private _randkey2;
    uint256 private _randkey3;
    uint256 private _randkey;
    uint256 private _randkey4;

    constructor (uint256 maxNum) {
        _maxNum = maxNum;
        _randkey = maxNum;
    }
    /* ========== write ========== */
    function _randomCal(address add,uint256[] memory numArr,uint256 maxNum) internal returns (uint256) {
        require(maxNum>0, "randomNum: maxNum 0!");
        _randkey = uint256(keccak256(abi.encodePacked(add,_randkey,maxNum,numArr)));
        uint256 randNum0 =  _randkey % maxNum +1;
        return randNum0;
    }
    function _cal_NoRepeat(address add,uint256[] memory numArr) internal returns (uint256) {
        require(_maxNum>0, "randomNum: maxNum 0!");
        _randkey = uint256(keccak256(abi.encodePacked(add,_randkey,_maxNum,numArr)));
        uint256 randNum0 =  _randkey % _maxNum +1;

        if(_bUse[randNum0]){
            uint256 randNum2 = _useNum[randNum0];
            if(_bUse[_maxNum]){
                _useNum[randNum0]=_useNum[_maxNum];
            }
            else{
                _useNum[randNum0]=_maxNum;
            }
            _bUse[randNum0]=true;
            randNum0 = randNum2;
        }else{
            _bUse[randNum0]=true;
            if(_bUse[_maxNum]){
                _useNum[randNum0]=_useNum[_maxNum];
            }
            else{
                _useNum[randNum0]=_maxNum;
            }
        }
        _maxNum = _maxNum.sub(1);
        return randNum0;
    }
}

contract MetaBullMysteryBoxNFT is RandomNum,ERC721Enumerable,ReentrancyGuard  {
    using Strings for uint256;
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    Counters.Counter private _tokenIds;
    string private _baseURIextended="https://www.forthbox.io/";
    string private _imageAdress = "https://static.forthbox.io/image/nft/MetaBull-Mystery-Box.png";

    address public fundAdress = 0xB5d638b5a268Ef377E19D8675F0d2C0ae8eE04a8;

    uint256 public buyPrice = 77*10**18;
    IERC20 public usdcToken;
    IERC721MetaBull public nftToken;

    bool public bStart = false;

    IPancakePair public fbxUsdtLp;
    IPancakePair public bnbUsdtLp;
    uint256 public ithProjectNum = 0;
    mapping(uint256 => mapping(address => uint256)) private _AddressRandomNumArr; 
    mapping(uint256 => uint256) public _MintNum; 
    uint256 public maxMintNum = 500;
    uint256 public maxBuyNum = 10;
    uint256[] private _randomNumArr;
    uint256 private maxMinBullNum = 10000;
    uint256 private nowMinBullNum = 0;
    mapping(address => string) private _AddrLastGiftBullName; 
    constructor () ERC721("MetaBull Mystery Box", "MMB")RandomNum(500) {
        fbxUsdtLp = IPancakePair(0x9f07679EA7011DA476ED03968558742E518BCA38);
        bnbUsdtLp = IPancakePair(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE);

        usdcToken = IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
        nftToken=IERC721MetaBull(0x95cbF549f2b03a7cbB8825c92645891165B41D7D);
    }

    //---view---//
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }
    function bExistsID(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }
    function getPropertiesByTokenIds(uint256[] calldata tokenIdArr) external view returns(uint256[] memory){
        for(uint256 i=0; i<tokenIdArr.length; ++i) {
            require(_exists(tokenIdArr[i]), "ERC721: Existent ID");
        }
        uint256[] memory tPropertyArr = new uint256[](uint256(2*tokenIdArr.length));
        uint256 ith=0;
        for(uint256 i=0; i<tokenIdArr.length; ++i) {
            tPropertyArr[ith] = tokenIdArr[i]; ith++;
            tPropertyArr[ith] = 0; ith++;
        }
        return tPropertyArr;
    }
    function tokenURI(uint256 tokenId) public view virtual override(ERC721) returns (string memory){
        require(_exists(tokenId), "FBXNFT: URI query for nonexistent token");
        string memory base = _baseURI();
        string memory imageAdress = _imageAdress;
        string memory json = string(abi.encodePacked(
                '{"name":"MetaBull Mystery Box",',
                '"description":"MetaBull Mystery Box",',
                '"image":"',imageAdress, '",',
                '"base":"',base, '",',
                '"id":"',Strings.toString(tokenId), '"}'
                ));          
        return json;
    }
    function getParameters(address account) public view returns (uint256[] memory){
        uint256[] memory paraList = new uint256[](uint256(4));
        paraList[0]= totalSupply();
        paraList[1]= maxMintNum - _MintNum[ithProjectNum];
        paraList[2]= _AddressRandomNumArr[ithProjectNum][account];
        paraList[3]= maxBuyNum.sub(_AddressRandomNumArr[ithProjectNum][account]);
        return paraList;
    }

    function randomNumInfo(uint256 ith) external view returns (uint256) {
        require(ith < _randomNumArr.length, "MetaBullMysteryBoxNFT: exist num!");
        return _randomNumArr[ith];
    }
    function randomNumInfos(uint256 fromIth,uint256 toIth) external view returns (
        uint256[] memory numArr
    ) {
        require(toIth < _randomNumArr.length, "MetaBullMysteryBoxNFT: exist num!");
        require(fromIth <= toIth, "MetaBullMysteryBoxNFT: exist num!");
        numArr = new uint256[](toIth-fromIth+1);
        uint256 i=0;
        for(uint256 ith=fromIth; ith<=toIth; ith++) {
            numArr[i] = _randomNumArr[ith];
            i = i+1;
        }
        return numArr;
    }
    function isWhiteContract(address account) public view returns (bool) {
        if(account.isContract()) return false;
        if(tx.origin == msg.sender) return true;
        return false;
    }
    function getAddrLastGiftBullName(address account) public view returns (string memory str) {
        str = _AddrLastGiftBullName[account];
        return str;
    }
    //---write---//
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
        return;
    }
    function burnNFT(uint256 tokenId) public returns (uint256) {
        require(_msgSender() == ownerOf(tokenId),"MetaBullMysteryBoxNFT: Only the owner of this Token could Burn It!");
        _burn(tokenId);
        return tokenId;
    }

    function transNFT(address _to,uint256 tokenId) public returns (uint256) {
        require(_msgSender() == ownerOf(tokenId),"MetaBullMysteryBoxNFT: Only the owner of this Token could transfer It!");
        _safeTransfer(_msgSender(),_to,tokenId,"");
        return tokenId;
    }
    function TransferNFTs(address[] calldata _tos, uint256[] calldata tokenIds) external returns (bool){
        require(_tos.length > 0);
        for(uint256 i=0; i < _tos.length ; i++){
            transNFT(_tos[i], tokenIds[i]);
        }
        return true;
    }
    function randomNumCal(address add, uint256 maxNum) internal returns (uint256) {
        uint256[] memory numArr = new uint256[](3);
        numArr[0]= block.timestamp;
        numArr[1]= fbxUsdtLp.price0CumulativeLast();
        numArr[2]= bnbUsdtLp.price0CumulativeLast();
        return _randomCal(add,numArr,maxNum);
    }

    function buyNFT() public nonReentrant returns (bool) {
        require(bStart, "MetaBullMysteryBoxNFT: not start!");
        require(_AddressRandomNumArr[ithProjectNum][_msgSender()]<maxBuyNum, "MetaBullMysteryBoxNFT: only can gift 10 times!");
        require(_MintNum[ithProjectNum]<maxMintNum, "MetaBullMysteryBoxNFT: already sell out!");
        require(isWhiteContract(_msgSender()), "MetaBullMysteryBoxNFT: Contract not in white list!");

        _MintNum[ithProjectNum] = _MintNum[ithProjectNum]+1;

        usdcToken.safeTransferFrom(_msgSender(), fundAdress, buyPrice);
        _AddressRandomNumArr[ithProjectNum][_msgSender()] = _AddressRandomNumArr[ithProjectNum][_msgSender()].add(1);
        _mintNFT(_msgSender());
        return true;
    }
    function randGift(uint256 tokenId) public nonReentrant returns (bool) {
        require(_msgSender() == ownerOf(tokenId),"MetaBullMysteryBoxNFT: Only the owner of this Token could transfer It!");
        require(isWhiteContract(_msgSender()), "MetaBullMysteryBoxNFT: Contract not in white list!");
        require(nowMinBullNum+4<=maxMinBullNum, "MetaBullMysteryBoxNFT: max Min Bull Num!");
       _burn(tokenId);
       
        uint256 ith = randomNumCal(_msgSender(),100);
        _randomNumArr.push(ith);
        uint256 begin = 1;
        if(ith<=30) {
            begin = 5;
            _AddrLastGiftBullName[_msgSender()]="Planet series";
        }
        if(ith>30 && ith<=60) {
            begin = 9;
            _AddrLastGiftBullName[_msgSender()]="Stellar series";
        }

        if(ith>60 && ith<=80) {
            begin = 1;
            _AddrLastGiftBullName[_msgSender()]="Comet series";
        }

        if(ith>80) {
            begin = 13;
            _AddrLastGiftBullName[_msgSender()]="Galaxy series";
        }       
        nowMinBullNum+=4;
        for(uint256 i=0; i < 4 ; i++){
          nftToken.mintNFTTo(i+begin,_msgSender());
        }
        return true;
    }

    //---write onlyOwner---//
    function start(bool tStart,uint256 tmaxBuyNum,uint256 tIthProjectNum,uint256 tMaxMintNum) external onlyOwner{
        bStart= tStart;
        maxBuyNum = tmaxBuyNum;
        ithProjectNum = tIthProjectNum;
        maxMintNum = tMaxMintNum;
    }
    function setMaxMinNum(uint256 tMaxMinBullNum) external onlyOwner{
        maxMinBullNum = tMaxMinBullNum;
    }
    function setTokens(address tusdcToken,address tnftToken,
            address tFundAdress,
            uint256 tbuyPrice
    ) external onlyOwner{
        usdcToken = IERC20(tusdcToken);
        nftToken = IERC721MetaBull(tnftToken);
        fundAdress=tFundAdress;
        buyPrice=tbuyPrice;
    }
    function _mintNFT(address to) internal returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(to, newItemId);
        return newItemId;
    }
    function setImageAdress(string memory tImageAdress) external onlyOwner {
        _imageAdress = tImageAdress;
    }
    function mintNFTsTo(uint256 num,address to) public onlyOwner{
        require(num>0, "FBXBullNFT: num zero!");
        require(num<=1000, "FBXBullNFT: num exceed 1000!");
        for(uint256 i=0; i<num; ++i) {
            _mintNFT(to);
        }
        return;
    }
}