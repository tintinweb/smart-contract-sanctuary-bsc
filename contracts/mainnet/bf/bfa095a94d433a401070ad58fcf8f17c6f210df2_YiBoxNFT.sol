/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.5;

contract Context {
    constructor () internal { }
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

contract IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function safe8(uint256 a) internal pure returns(uint8) {
        require(a < 0x0100, "C4002:uint8: number overflow");
        return uint8(a);
    }

    function safe16(uint256 a) internal pure returns(uint16) {
        require(a < 0x010000, "C4002:uint16: number overflow");
        return uint16(a);
    }

    function safe32(uint256 a) internal pure returns(uint32) {
        require(a < 0x0100000000, "C4002:uint32: number overflow");
        return uint32(a);
    }

    function safe64(uint256 a) internal pure returns(uint64) {
        require(a < 0x010000000000000000, "C4002:uint64: number overflow");
        return uint64(a);
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library Counters {
    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

contract ERC721 is Context, ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned token
    mapping (address => Counters.Counter) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current().safe32();
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {
        require(to != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][to] = approved;
        emit ApprovalForAll(_msgSender(), to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransferFrom(from, to, tokenId, _data);
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    // function _safeMint(address to, uint256 tokenId) internal {
    //     _safeMint(to, tokenId, "");
    // }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _transferFromInternal(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = to.call(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ));
        if (!success) {
            if (returndata.length > 0) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("ERC721: transfer to non ERC721Receiver implementer");
            }
        } else {
            bytes4 retval = abi.decode(returndata, (bytes4));
            return (retval == _ERC721_RECEIVED);
        }
    }

    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}

contract ERC721Enumerable is Context, ERC165, ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;
    address[] private _allOwners;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    /**
     * @dev Constructor function.
     */
    constructor () public {
        // register the supported interface to conform to ERC721Enumerable via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function getAllOwners() external view returns (address[] memory _owners) {
        _owners = _allOwners;
    }

    function getAllTokens() external view returns (uint256[] memory _tokens) {
        _tokens = _allTokens;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {
        return _allTokens.length.safe32();
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {
        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _transferFromInternal(address from, address to, uint256 tokenId) internal {
        super._transferFromInternal(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal {
        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        // Since tokenId will be deleted, we can clear its slot in _ownedTokensIndex to trigger a gas refund
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
        return _ownedTokens[owner];
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length.safe32();
        _ownedTokens[to].push(tokenId);
        bool find = false;
        for (uint i = 0; i < _allOwners.length; i++) {
            if (_allOwners[i] == to) {
                find = true;
                break;
            }
        }
        if (find == false) {
            _allOwners.push(to);
        }
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        _ownedTokens[from].length--;
    }
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        uint256 lastTokenIndex = _allTokens.length.sub(1).safe32();
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
contract IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    // function tokenURI(uint256 tokenId) external view returns (string memory);
    function tokenBase(uint256 tokenId) external view returns (uint256 _level, uint256 _quality,uint256 _hashrate, uint256 _status, uint256 _type);
}

contract ERC721Metadata is Context, ERC165, ERC721, IERC721Metadata {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Base URI
    string private _baseURI;
/*
    struct TokenBase {
        // string strURI;
        uint16 u16Level;
        // uint8  u8Quality;  //1,2,3 = no level ,
        uint32 u32Hashrate;
        uint8  status;     //1 = 未解锁,  2 出售中，3 已解锁，4 挖矿中，5 出售中 6 待出租中 7 出租中 8 未挖矿
        // uint16 ttype;       
        // uint256 price;

    }

    // Optional mapping for token URIs
    mapping(uint32 => TokenBase) internal _tokenBases;
    mapping(uint32 => uint16[]) internal Levels;
    mapping(uint32 => uint64[]) internal UpTimes;
    mapping(uint32 => uint32[]) internal HashRates;

*/
    mapping(uint256 => uint256) internal _tokenBases;
    mapping(uint256 => uint256[]) internal LevelInfo;
    uint256[] internal _ownerOfToken;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /**
     * @dev Constructor function
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }
    
    function getLevelInfo(uint256 tokenId, uint256 idx) internal view returns (uint256 Levels, uint256 UpTimes, uint256 HashRates) {
        require(idx < LevelInfo[tokenId].length, "LevelInfo out range");

        Levels = (LevelInfo[tokenId][idx] >> 128) % 0x100000000;
        UpTimes = (LevelInfo[tokenId][idx] >> 64) % 0x10000000000000000;
        HashRates = (LevelInfo[tokenId][idx] >> 32) % 0x100000000;
    }

    function getLevelInfos(uint256 tokenId) internal view returns (uint256[] memory Levels, uint256[] memory UpTimes, uint256[] memory HashRates) {
        uint size = LevelInfo[tokenId].length;
        Levels = new uint256[](size);
        UpTimes = new uint256[](size);
        HashRates = new uint256[](size);

        for (uint i = 0; i < size; i++) {
            Levels[i] = (LevelInfo[tokenId][i] >> 128) % 0x100000000;
            UpTimes[i] = (LevelInfo[tokenId][i] >> 64) % 0x10000000000000000;
            HashRates[i] = (LevelInfo[tokenId][i] >> 32) % 0x100000000;
        }
    }

    function setLevelInfo(uint256 tokenId, uint256 idx, uint256 Levels, uint256 UpTimes, uint256 HashRates) internal {
        if (idx >= LevelInfo[tokenId].length) {
            LevelInfo[tokenId].push((HashRates << 32) + (UpTimes << 64) + (Levels << 128));
        } else {
            (uint256 _lv, uint256 _ut, uint256 _hr) = getLevelInfo(tokenId, idx);
            if (Levels == 0) {
                Levels = _lv;
            }

            if (UpTimes == 0) {
                UpTimes = _ut;
            }

            if (HashRates == 0) {
                HashRates = _hr;
            }
            LevelInfo[tokenId][idx] = (HashRates << 32) + (UpTimes << 64) + (Levels << 128);
        }
        
    }

    function getBaseInfo(uint256 _base) internal pure returns (uint256 _lv, uint256 _qu, uint256 _ha, uint256 _st, uint256 _ty) {
        _lv = (_base >> 64) % 0x10000;
        _qu = (_base >> 48) % 0x10000;
        _ha = (_base >> 32) % 0x10000;
        _st = (_base >> 16) % 0x10000;
        _ty = _base % 0x10000;
    }

    function setBaseInfo(uint256 tokenID, uint256 _level, uint256 _quality,uint256 _hashrate, uint256 _status, uint256 _type) internal {
        uint256 _base = _tokenBases[tokenID];
        (uint256 _lv, uint256 _qu, uint256 _ha, uint256 _st, uint256 _ty) = getBaseInfo(_base);
        if (_level == 0) {
            _level = _lv;
        }

        if (_quality == 0) {
            _quality = _qu;
        }

        if (_hashrate == 0) {
            _hashrate = _ha;
        }

        if (_status == 0) {
            _status = _st;
        }

        if (_type == 0) {
            _type = _ty;
        }

        _tokenBases[tokenID] = _type + (_status << 16) + (_hashrate << 32) + (_quality << 48) + (_level << 64);
    }

    function tokenBase(uint256 tokenId) external view returns (uint256 _level, uint256 _quality,uint256 _hashrate, uint256 _status, uint256 _type) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        (_level,_quality,_hashrate,_status,_type) = getBaseInfo(_tokenBases[tokenId]);
    }

    function _setTokenBase(uint256 tokenId, uint256 _level, uint256 _quality,uint256 _hashrate, uint256 _status, uint256 _type) internal {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        setBaseInfo(tokenId, _level,  _quality, _hashrate,  _status,  _type);
        bool isfind = false;
        for (uint _i = 0; _i < _ownerOfToken.length; _i++) {
            if (_ownerOfToken[_i] == tokenId) {
                isfind = true;
                break;
            }
        }
        if (!isfind) {
            _ownerOfToken.push(tokenId);
        }
    }

    function getHashrateTotal() external view returns (uint256 hTotal) {
        for (uint i=0; i < _ownerOfToken.length; i++) {
            (,,uint256 _hs,uint256 _st,) = this.tokenBase(_ownerOfToken[i]);
            if (_st == 4 || _st == 6 || _st == 7) {
                    hTotal += _hs;
            }
        }
    }

    function _upLevel(uint256 tokenId) internal {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        (uint256 _lv,,,,) = this.tokenBase(tokenId);
        _lv++;
        setBaseInfo(tokenId, _lv, 0, 0, 0, 0);
    }

    function _setHashrate(uint256 tokenId, uint256 _hashrate) internal {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        setBaseInfo(tokenId, 0, 0, _hashrate, 0, 0);
    }

    function _setStatus(uint256 tokenId, uint256 _status) internal {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        setBaseInfo(tokenId, 0, 0, 0, _status, 0);
    }

    function _setBaseURI(string memory baseURI) internal {
        _baseURI = baseURI;
    }

    function baseURI() external view returns (string memory) {
        return _baseURI;
    }

    function removeAtTokenID(uint256 _tokenID) private {
        bool isFind = false;
        uint index = 0;
        for (index = 0 ; index < _ownerOfToken.length; index++) {
            if (_tokenID == _ownerOfToken[index]) {
                isFind = true;
                break;
            }
        }

        if (!isFind) {
            return;
        }

        if (index >= _ownerOfToken.length) return;
    
        for (uint i = index; i < _ownerOfToken.length-1; i++) {
            _ownerOfToken[i] = _ownerOfToken[i+1];
        }
    
        delete _ownerOfToken[_ownerOfToken.length-1];
        _ownerOfToken.length--;
    }

    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        // Clear metadata (if any)
        if (_tokenBases[tokenId] != 0) {
            delete _tokenBases[tokenId];
        }

        if (LevelInfo[tokenId].length != 0) {
            delete LevelInfo[tokenId];
        }

        removeAtTokenID(tokenId);
    }
}

contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {
    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
        // solhint-disable-previous-line no-empty-blocks
    }
}

contract Governance {

    address public _governance;

    constructor() public {
        _governance = tx.origin;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance)  public  onlyGovernance
    {
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }
}

library MathwalletUtil {
    function uintToString(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}

contract YiBoxNFT is ERC721Full, Governance {
    // for minters
    mapping(address => bool) public _minters;

    constructor() public ERC721Full("YiBoxHero", "YBH") {
        _minters[msg.sender] = true;
        _setBaseURI("https://nft.yibox.io/showcase/?id=");
    }

    function setURIPrefix(string memory baseURI) internal {
        _setBaseURI(baseURI);
    }

    function getLevelsByToken(uint256 _token) external view returns (uint256[] memory Levels, uint256[] memory UpTimes, uint256[] memory HashRates) {
        require(_exists(_token), "can't find token");
        uint256 len = LevelInfo[_token].length;
        if ( len == 0 ) {
            Levels = new uint256[](1);
            UpTimes = new uint256[](1);
            HashRates = new uint256[](1);
        } else {
            Levels = new uint256[](len);
            UpTimes = new uint256[](len);
            HashRates = new uint256[](len);

            for (uint256 i = 0; i < len; i++) {
                (Levels[i], UpTimes[i], HashRates[i]) = getLevelInfo(_token, i);
            }
        }
        
    }

    // tokenId 起点 是 1
    function mint(address to, uint256 tokenId, uint256 _quality, uint256 _hashrate,uint256 ttype) external returns(uint256 _tokenId) {
        require(_minters[msg.sender], "!minter");
        _tokenId = ((_quality) * 10 ** 15) + (ttype * (10 ** 10)) + tokenId;
        _mint(to, _tokenId);
        _setTokenBase(_tokenId, 1,_quality,_hashrate,4,ttype);
        // setLevelInfo(_tokenId, 99999, 1, now, _hashrate);
        // levelInfo[tokenId].push(LevelInfo(1,now, _hashrate));
    }

    function getTokenBase(uint256 tokenId) public view returns (uint256 _tokenBase) {
        require(_minters[msg.sender], "!minter");
        _tokenBase = _tokenBases[tokenId];
    }

    function modifyTokenBase(uint256 tokenId, uint256 tokenBase) public {
        require(_minters[msg.sender], "!minter");
        _tokenBases[tokenId] = tokenBase;
    }

    // function mintBatch(address to,uint256 num) external  {
    //     for (uint i = 0; i < num; i++) {
    //         this.mint(to, 4523452 + i, 4, i % 30 + 10, i % 72);
    //     }
    // }
/*
    function mint(address to, uint256 tokenId) external returns (bool) {
        require(_minters[msg.sender], "!minter");
        _mint(to, tokenId);
        _setTokenBase(tokenId, 0,0,0,1,0);
        // levelInfo[tokenId].push(LevelInfo(1,now, _hashrate));
        return true;
    }

    function safeMint(address to, uint256 tokenId) public returns (bool) {
        require(_minters[msg.sender], "!minter");
        _safeMint(to, tokenId);
        _setTokenBase(tokenId, MathwalletUtil.uintToString(tokenId),0,0,0,1,0);
        // levelInfo[tokenId].push(LevelInfo(1,now, _hashrate));
        return true;
    }
   

    function safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public returns (bool) {
        require(_minters[msg.sender], "!minter");
        _safeMint(to, tokenId, _data);
        _setTokenBase(tokenId,0,0,0,1,0);
        // levelInfo[tokenId].push(LevelInfo(1,now, _hashrate));
        return true;
    }
 */
    function upLevel(uint256 tokenId, uint256 _hashrate) external {
        require(_minters[msg.sender], "!minter");

        (uint256 _level,,uint256 _hr,,) = this.tokenBase(tokenId);
        setLevelInfo(tokenId, 99999, _level, now, _hr);
        _level++;
        setBaseInfo(tokenId, _level, 0, _hashrate, 0, 0);
        // _upLevel(tokenId);
        // _setHashrate(tokenId, _hashrate);
    }
/*
    function openBox(uint32 tokenId, uint8 _quality, uint32 _hashrate, uint16 _type) external {
        require(_minters[msg.sender], "!minter");
        require(_exists(tokenId), "can't find tokenId");
        _setTokenBase(tokenId,1,_quality,_hashrate,4, _type);
        Levels[tokenId].push(1);
        UpTimes[tokenId].push(now);
        HashRates[tokenId].push(_hashrate);
    }

*/
    function setStatus(address _s, uint256 tokenId, uint256 _status) public {
        require(_minters[msg.sender], "!minter");
        require(ownerOf(tokenId) == _s, "not owner");
        _setStatus(tokenId, _status);
    }

    function addMinter(address minter) public onlyGovernance {
        _minters[minter] = true;
    }

    function removeMinter(address minter) public onlyGovernance {
        _minters[minter] = false;
    }
/*
    function burn(uint32 tokenId) external {
        //solhint-disable-next-line max-line-length
        require(_minters[msg.sender], "!minter");
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "caller is not owner nor approved"
        );
        _burn(tokenId);
    }
*/
    function burnIn(uint256 tokenId) external {
        //solhint-disable-next-line max-line-length
        require(_minters[msg.sender], "!minter");
        _burn(tokenId);
    }

    function getHashrateByAddress(address _target) external view returns (uint256 pTotal) {
        uint256[] memory _tokens = _tokensOfOwner(_target);
        for (uint i=0; i < _tokens.length; i++) {
            (,,uint256 _hs,uint256 _st,) = this.tokenBase(_tokens[i]);
            if (_st == 4 || _st == 6 || _st == 7) {
                    pTotal += _hs;
            }
        }
    }

    function transferFromInternal(address from, address to, uint256 tokenId) external {
        require(_minters[msg.sender], "!minter");
        _transferFromInternal(from, to, tokenId);
    }

    // function setPrice(address _owner, uint256 _tokens, uint256 _price) external {
    //     require(ownerOf(_tokens) == _owner, "owner error");
    //     _tokenBases[_tokens].price = _price;
    // }

    function getTokensByStatus(address _owner, uint256 _status) external view returns (uint256[] memory tokens) {
        uint256[] memory _tokens = _tokensOfOwner(_owner);
        uint sum = 0;
        
        for (uint i=0; i < _tokens.length; i++) {
            (,,,uint256 _st,) = this.tokenBase(_tokens[i]);
            if (_st == _status) {
                // xxx.push(11);
                sum++;
            }
        }
        tokens = new uint256[](sum);
        uint _xx = 0;
        for (uint i=0; i < _tokens.length; i++) {
            (,,,uint256 _st,) = this.tokenBase(_tokens[i]);
            if (_st == _status) {
                // tokens.push(11);
                tokens[_xx] = _tokens[i];
                _xx++;
                if (_xx >= sum) {
                    break;
                }
            }
        }
    }

    function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        return _tokensOfOwner(owner);
    }

    function allocTest(uint256 start, uint256 _num, address _tar) external onlyGovernance returns (uint256[] memory) {
        uint256[] memory a = new uint256[](_num);
        for (uint16 i = 0; i < _num; i++) {
            this.mint(_tar, start + i, 3, 30, i);
            a[i] = start + i;
        }
        return a;
    }

}