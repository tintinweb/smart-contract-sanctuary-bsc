/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {return returndata;} else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";    

    function toString(uint value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint temp = value;
        uint digits;
        while (temp != 0) {
            digits++;temp /= 10;
        }
        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(value % 10)));value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        
        uint temp = value;
        uint length = 0;

        while (temp != 0) {
            length++;temp >>= 8;
        }
        
        return toHexString(value, length);
    }

    function toHexString(uint value, uint length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        
        return string(buffer);
    }
}

library Counters {
    struct Counter {
        uint _value;
    }

    function current(Counter storage counter) internal view returns (uint) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }

    function init(Counter storage counter, uint _initValue) internal {
        counter._value = _initValue;
    }

}

interface IERC165 {    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint balance);
    function ownerOf(uint tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint tokenId,bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint tokenId) external;
    function transferFrom(address from,address to,uint tokenId) external;
    function approve(address to, uint tokenId) external;
    function getApproved(uint tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(address operator,address from,uint tokenId,bytes calldata data) external returns (bytes4);
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint tokenId) external view returns (string memory);
}

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint);    
    function tokenOfOwnerByIndex(address owner, uint index) external view returns (uint tokenId);
    function tokenByIndex(uint index) external view returns (uint);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

contract ERC721 is ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint;
    string private _name;
    string private _symbol;
    mapping(uint => address) private _owners;
    mapping(address => uint) private _balances;
    mapping(uint => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC721Metadata).interfaceId || super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint tokenId) public view virtual override returns (address) {
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
    
    function tokenURI(uint tokenId) public view virtual override returns (string memory) {
        require(_tokenExists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
    
    function approve(address to, uint tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "ERC721: approve caller is not owner nor approved for all");

        _approve(to, tokenId);
    }
    
    function getApproved(uint tokenId) public view virtual override returns (address) {
        require(_tokenExists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }
    
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(msg.sender, operator, approved);
    }
    
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    
    function transferFrom(address from,address to,uint tokenId) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }
    
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }
    
    function _safeTransfer(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    
    function _tokenExists(uint tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }
    
    function _isApprovedOrOwner(address spender, uint tokenId) internal view virtual returns (bool) {
        require(_tokenExists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
    
    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_tokenExists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }
    
    function _burn(uint tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);
        _approve(address(0), tokenId);
        _balances[owner] -= 1;
        delete _owners[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenId);
        _approve(address(0), tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    
    function _approve(address to, uint tokenId) internal virtual {
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
        uint tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
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
        uint tokenId
    ) internal virtual {}
}

abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint => uint)) private _ownedTokens;
    mapping(uint => uint) private _ownedTokensIndex;
    uint[] internal _allTokens;
    mapping(uint => uint) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }
    function tokenOfOwnerByIndex(address owner, uint index) public view virtual override returns (uint) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }
    function totalSupply() public view virtual override returns (uint) {
        return _allTokens.length;
    }    
    function tokenByIndex(uint index) public view virtual override returns (uint) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint tokenId
    ) internal virtual override {
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

    function _addTokenToOwnerEnumeration(address to, uint tokenId) private {
        uint length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }
    
    function _addTokenToAllTokensEnumeration(uint tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }
    
    function _removeTokenFromOwnerEnumeration(address from, uint tokenId) private {
        uint lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint tokenIndex = _ownedTokensIndex[tokenId];
        if (tokenIndex != lastTokenIndex) {
            uint lastTokenId = _ownedTokens[from][lastTokenIndex];
            _ownedTokens[from][tokenIndex] = lastTokenId; 
            _ownedTokensIndex[lastTokenId] = tokenIndex; 
        }
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint tokenId) private {
        uint lastTokenIndex = _allTokens.length - 1;
        uint tokenIndex = _allTokensIndex[tokenId];
        uint lastTokenId = _allTokens[lastTokenIndex];
        _allTokens[tokenIndex] = lastTokenId; 
        _allTokensIndex[lastTokenId] = tokenIndex; 
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

abstract contract ERC721Burnable is ERC721 {
    function burn(uint tokenId) public virtual {        
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}


contract Ownable {
    address internal owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract Monster is ERC721Enumerable, ERC721Burnable, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    address public masterContract;

    uint public sn;//战宠SN
    uint public attribute;//战宠属性(1火、2水、3风、4土、5光、6暗)
    uint public level;//战宠级别

    mapping(uint => MonsterInfo) private _infos;

    //tokenId生成器
    Counters.Counter private tokenIdCounter;

    //TokenURI文件地址URL目录，如：https://xxxx.com/metadata/
    string private baseTokenURI;

    //战宠HP、其它属性随机范围值
    uint[][] private attrsRangeData;

    //宠物属性
    struct MonsterInfo {
        uint sn;
        uint attribute;//属性(1火、2水、3风、4土、5光、6暗)
        uint personality;//个性(1暴躁型、2坚固型、3慵懒型、4好动型、5助人型、6全能型)
        uint level;//级别(品质)
        uint HP;//生命值
        uint attack;//攻击
        uint pdef;//物理防御
        uint mdef;//魔法防御
        uint speed;//速度
        uint luck;//幸运值
        uint sacred;//神圣力
    }

    modifier onlyMasterContract() {
        require(masterContract == msg.sender, "Not the MasterContract Address");
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        uint sn_,
        uint attribute_,
        uint level_,
        uint initTokenId_,
        address masterContract_,
        string memory baseTokenURI_, 
        uint[][] memory attrsRangeData_
    ) ERC721(name_, symbol_) {
        sn = sn_;
        attribute = attribute_;
        level = level_;

        baseTokenURI = baseTokenURI_;
        masterContract = masterContract_;
        //战宠HP、其它属性随机范围值
        attrsRangeData = attrsRangeData_;

        //初始化TokenId起始序号
        tokenIdCounter.init(initTokenId_);
    }

    function setMasterContract(address masterContract_) external onlyOwner {
        masterContract = masterContract_;
    }

    function setParameter(string memory baseTokenURI_, uint[][] memory attrsRangeData_) external onlyOwner {
        baseTokenURI = baseTokenURI_;
        
        //战宠HP、其它属性随机范围值
        attrsRangeData = attrsRangeData_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    //生成指定范围的随机数比如:0-100
    function getRandomByRange(uint min, uint max) public view returns (uint) {
        uint random = (uint(keccak256(abi.encode(block.timestamp, block.difficulty, msg.sender))) % (max - min + 1)) + min;
        return random;
    }


    function randomMonsterAttrs(uint personality) private view returns (uint[] memory){
        uint[] memory range = attrsRangeData[personality - 1];

        uint[] memory attrs = new uint[](7);

        attrs[0] = getRandomByRange(range[0], range[1]);
        attrs[1] = getRandomByRange(range[2], range[3]);
        attrs[2] = getRandomByRange(range[4], range[5]);
        attrs[3] = getRandomByRange(range[6], range[7]);
        attrs[4] = getRandomByRange(range[8], range[9]);
        attrs[5] = getRandomByRange(range[10], range[11]);
        attrs[6] = getRandomByRange(range[12], range[13]);
       
        return attrs;
    }


    function mint(address to, uint personality) public onlyMasterContract virtual returns (uint) {
        uint tokenId = tokenIdCounter.current();

        _mint(to, tokenId);

        //随机生成战宠属性值
        uint[] memory attrs = randomMonsterAttrs(personality);

        //战宠属性
        MonsterInfo memory info = MonsterInfo({
            sn: sn,
            attribute: attribute,//属性(1火、2水、3风、4土、5光、6暗)
            personality: personality,//个性(1暴躁型、2坚固型、3慵懒型、4好动型、5助人型、6全能型)
            level: level,//级别(品质)
            HP: attrs[0],//生命值
            attack: attrs[1],//攻击
            pdef: attrs[2],//物理防御
            mdef: attrs[3],//魔法防御
            speed: attrs[4],//速度
            luck: attrs[5],//幸运值
            sacred: attrs[6]//神圣力
        });

        _infos[tokenId] = info;

        tokenIdCounter.increment();

        return tokenId;
    }

    function getSn() public view returns (uint) {
        return sn;
    }

    function getAttribute() public view returns (uint) {
        return attribute;
    }

    function getLevel() public view returns (uint) {
        return level;
    }

    function getInfo(uint tokenId) public view returns (uint[] memory) {
        MonsterInfo memory info = _infos[tokenId];
        uint[] memory attrs = new uint[](11);
        attrs[0] = info.sn;
        attrs[1] = info.attribute;//属性(1火、2水、3风、4土、5光、6暗)
        attrs[2] = info.personality;//个性(1暴躁型、2坚固型、3慵懒型、4好动型、5助人型、6全能型)
        attrs[3] = info.level;//级别(品质)
        attrs[4] = info.HP;//生命值
        attrs[5] = info.attack;//攻击
        attrs[6] = info.pdef;//物理防御
        attrs[7] = info.mdef;//魔法防御
        attrs[8] = info.speed;//速度
        attrs[9] = info.luck;//幸运值
        attrs[10] = info.sacred;//神圣力

        return attrs;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint tokenId
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function batchOwnerOf() public view returns(address[] memory) {
        uint _totalSupply = totalSupply();
        address[] memory _addr = new address[](_totalSupply);
        uint j;

        for (uint idx = 0; idx < _totalSupply; idx++) {
            _addr[j] = ownerOf(_allTokens[idx]);
            j++;
        }

        return _addr;
    }


    function batchTokenId() public view returns(uint[] memory) {
        uint _totalSupply = totalSupply();
        uint[] memory _tokens = new uint[](_totalSupply);
        uint j;

        for (uint idx = 0; idx < _totalSupply; idx++) {
            _tokens[j] = _allTokens[idx];
            j++;
        }

        return _tokens;
    }


    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_tokenExists(tokenId), "World : URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
    }


    //派发一个NFT战宠(测试方法)
    function mintTo(address to, uint personality) public onlyOwner virtual returns (uint) {
        uint tokenId = tokenIdCounter.current();
        _mint(to, tokenId);

        //随机生成战宠属性值
        uint[] memory attrs = randomMonsterAttrs(personality);

        //战宠属性
        MonsterInfo memory info = MonsterInfo({
            sn: sn,
            attribute: attribute,//属性(1火、2水、3风、4土、5光、6暗)
            personality: personality,//个性(1暴躁型、2坚固型、3慵懒型、4好动型、5助人型、6全能型)
            level: level,//级别(品质)
            HP: attrs[0],//生命值
            attack: attrs[1],//攻击
            pdef: attrs[2],//物理防御
            mdef: attrs[3],//魔法防御
            speed: attrs[4],//速度
            luck: attrs[5],//幸运值
            sacred: attrs[6]//神圣力
        });

        _infos[tokenId] = info;

        tokenIdCounter.increment();

        return tokenId;
    }

}