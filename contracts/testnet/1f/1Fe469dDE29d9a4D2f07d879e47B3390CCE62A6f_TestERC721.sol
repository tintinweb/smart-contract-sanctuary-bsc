// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./interfaces/IERC721.sol";
import "./interfaces/IERC721Enumerable.sol";
import "./interfaces/IERC721Metadata.sol";
import "./interfaces/IERC721Receiver.sol";
import "./utils/Address.sol";
import "./utils/Counters.sol";
import "./utils/Strings.sol";
import "./introspection/ERC165.sol";

contract TestERC721 is ERC165, IERC721, IERC721Enumerable, IERC721Metadata {
    using Address for address;
    using Counters for Counters.Counter;
    using Strings for uint;

    Counters.Counter internal _tokenIds;

    address public owner;
    string public override name;
    string public override symbol;
    string public baseURI;
    uint[] public allTokens;
    uint public maxSupply;

    mapping(uint256 => address) public owners;
    mapping(address => uint256) public balances;
    mapping(uint256 => address) public tokenApprovals;
    mapping(uint256 => uint256) public ownedTokensIndex;
    mapping(uint256 => uint256) public allTokensIndex;
    mapping(address => bool) public adminWhitelist;

    mapping(address => mapping(address => bool)) public operatorApprovals;
    mapping(address => mapping(uint256 => uint256)) public ownedTokens;

    event MintNft(address to, uint date, address nft, uint tokenId, string tokenURI);
    event OwnershipTransferred(address previousOwner, address newOwner);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
    }

    function renounceOwnership() public {
        _requireOwner();
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public {
        _requireOwner();
        require(newOwner != address(0), 'Ownable: new owner cannot be zero address - renounce contract instead');
        _transferOwnership(newOwner);
    }

    function setMaxSupply(uint256 _maxSupply) public {
        _requireOwner();
        maxSupply = _maxSupply;
    }

    function setTokenURI(string memory _newTokenURI) public {
        _requireOwner();
        require(bytes(baseURI).length == 0, 'TokenURI is already set');
        baseURI = _newTokenURI;
    }

    function whitelistAdmin(address _admin, bool _isAdmin) public {
        _requireOwner();
        adminWhitelist[_admin] = _isAdmin;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(exists(_tokenId) || _tokenId <= maxSupply || maxSupply == 0, "ERC721Metadata: URI query for nonexistent token");
        return baseURI;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return allTokens.length;
    }

    function exists(uint256 _tokenId) internal view virtual returns (bool) {
        return owners[_tokenId] != address(0);
    }

    function getApproved(uint256 _tokenId) public view virtual override returns (address) {
        require(exists(_tokenId), "ERC721: approved query for nonexistent token");
        return tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view virtual override returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return _interfaceId == type(IERC721).interfaceId || 
               _interfaceId == type(IERC721Metadata).interfaceId || 
               _interfaceId == type(IERC721Enumerable).interfaceId ||
               super.supportsInterface(_interfaceId);
    }

    function balanceOf(address _owner) public view virtual override returns (uint256) {
        require(_owner != address(0), "ERC721: balance query for the zero address");
        return balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view virtual override returns (address) {
        address tokenOwner = owners[_tokenId];
        require(tokenOwner != address(0), "ERC721: owner query for nonexistent token");
        return tokenOwner;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view virtual override returns (uint256) {
        require(_index < balanceOf(_owner), "ERC721Enumerable: owner index out of bounds");
        return ownedTokens[_owner][_index];
    }

    function tokenByIndex(uint256 _index) public view virtual override returns (uint256) {
        require(_index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return allTokens[_index];
    }

    function approve(address _to, uint256 _tokenId) public virtual override {
        address tokenOwner = ownerOf(_tokenId);
        require(_to != tokenOwner, "ERC721: approval to current owner");
        require(msg.sender == tokenOwner || isApprovedForAll(tokenOwner, msg.sender), "ERC721: approve caller is not owner nor approved for all");
        _approve(_to, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) public virtual override {
        _setApprovalForAll(msg.sender, _operator, _approved);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public virtual override {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public virtual override {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(_from, _to, _tokenId, _data);
    }

    function reviveRug(address _to) public returns(uint) {
        return mint(_to);
    }

    function mint(address _to) public returns (uint) {
        require(bytes(baseURI).length > 0, 'tokenURI is not set');
        require(adminWhitelist[msg.sender], 'must be called by whitelisted address');
        require(maxSupply == 0 || totalSupply() < maxSupply, 'maximum mints reached');
        require(_to != address(0), "ERC721: mint to the zero address");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        
        require(!exists(newItemId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), _to, newItemId);
        balances[_to] += 1;
        owners[newItemId] = _to;
        emit Transfer(address(0), _to, newItemId);

        require(_checkOnERC721Received(address(0), _to, newItemId, ""), "ERC721: transfer to non ERC721Receiver implementer");

        emit MintNft(_to, block.timestamp, address(this), newItemId, tokenURI(newItemId));        
        return newItemId;
    }

    function _safeTransfer(address _from, address _to, uint256 _tokenId, bytes memory _data) internal virtual {
        _transfer(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _isApprovedOrOwner(address _spender, uint256 _tokenId) internal view virtual returns (bool) {
        require(exists(_tokenId), "ERC721: operator query for nonexistent token");
        address tokenOwner = ownerOf(_tokenId);
        return (_spender == tokenOwner || getApproved(_tokenId) == _spender || isApprovedForAll(tokenOwner, _spender));
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal virtual {
        require(ownerOf(_tokenId) == _from, "ERC721: transfer from incorrect owner");
        require(_to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(_from, _to, _tokenId);
        _approve(address(0), _tokenId);
        balances[_from] -= 1;
        balances[_to] += 1;
        owners[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function _approve(address _to, uint256 _tokenId) internal virtual {
        tokenApprovals[_tokenId] = _to;
        emit Approval(ownerOf(_tokenId), _to, _tokenId);
    }

    function _setApprovalForAll(address _owner, address _operator, bool _approved) internal virtual {
        require(_owner != _operator, "ERC721: approve to caller");
        operatorApprovals[_owner][_operator] = _approved;
        emit ApprovalForAll(_owner, _operator, _approved);
    }

    function _checkOnERC721Received(address _from, address _to, uint256 _tokenId, bytes memory _data) internal returns (bool) {
        if (_to.isContract()) {
            try IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) returns (bytes4 retval) {
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

    function _beforeTokenTransfer(address _from, address _to, uint256 _tokenId) internal virtual {
        if (_from == address(0)) {
            _addTokenToAllTokensEnumeration(_tokenId);
        } else if (_from != _to) {
            _removeTokenFromOwnerEnumeration(_from, _tokenId);
        }

        if (_to == address(0)) {
            _removeTokenFromAllTokensEnumeration(_tokenId);
        } else if (_to != _from) {
            _addTokenToOwnerEnumeration(_to, _tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address _to, uint256 _tokenId) private {
        uint256 length = balanceOf(_to);
        ownedTokens[_to][length] = _tokenId;
        ownedTokensIndex[_tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 _tokenId) private {
        allTokensIndex[_tokenId] = allTokens.length;
        allTokens.push(_tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address _from, uint256 _tokenId) private {
        uint256 lastTokenIndex = balanceOf(_from) - 1;
        uint256 tokenIndex = ownedTokensIndex[_tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = ownedTokens[_from][lastTokenIndex];
            ownedTokens[_from][tokenIndex] = lastTokenId;
            ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        delete ownedTokensIndex[_tokenId];
        delete ownedTokens[_from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 _tokenId) private {
        uint256 lastTokenIndex = allTokens.length - 1;
        uint256 tokenIndex = allTokensIndex[_tokenId];
        uint256 lastTokenId = allTokens[lastTokenIndex];
        allTokens[tokenIndex] = lastTokenId;
        allTokensIndex[lastTokenId] = tokenIndex;
        delete allTokensIndex[_tokenId];
        allTokens.pop();
    }

    function _requireOwner() private view {
        require(msg.sender == owner, 'Ownable: caller is not contract owner');
    }

    function _transferOwnership(address newOwner) private {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, owner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./IERC165.sol";

interface IERC721 is IERC165 {
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function approve(address _to, uint256 _tokenId) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external;
    event Transfer(address _from, address _to, uint256 _tokenId);
    event Approval(address _owner, address _approved, uint256 _tokenId);
    event ApprovalForAll(address _owner, address _operator, bool _approved);

    function mint(address _to) external returns (uint);
    function reviveRug(address _to) external returns(uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./IERC721.sol";

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./IERC721.sol";

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./IERC165.sol";

interface IERC721Receiver is IERC165 {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

library Counters {
    struct Counter {
        uint value;
    }
    
    function current(Counter storage counter) internal view returns (uint) {
        return counter.value;
    }
    
    function increment(Counter storage counter) internal {
        unchecked { counter.value++; }
    }
    
    function decrement(Counter storage counter) internal {
        require (counter.value > 0, 'Counter: underflow');
        unchecked { counter.value--; }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }

        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../interfaces/IERC165.sol";

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC165 {
    function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}