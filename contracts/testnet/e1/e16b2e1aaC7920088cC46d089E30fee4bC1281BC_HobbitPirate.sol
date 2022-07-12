// SPDX-License-Identifier: none

import "./interface/IBEP20.sol";
import "./interface/IERC721Metadata.sol";
import "./interface/IERC721Receiver.sol";

import "./library/Address.sol";
import "./library/Strings.sol";
import "./library/Counters.sol";
import "./library/hexStringToBytes.sol";

import "./abstract/ERC165.sol";
import "./abstract/Ownable.sol";

pragma solidity ^0.8.0;

contract HobbitPirate is Ownable, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;
    using Counters for Counters.Counter;

    uint256 private _maxSupply;

    Counters.Counter private _genExist;
    Counters.Counter private _totalSupply;
    Counters.Counter private _nftExistId;

    string private _name;
    string private _symbol;
    string private _baseURI;

    nftSaleInfo private saleInfo;

    mapping(uint256 => nftInfo) private _nftGen;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    struct nftInfo{
        uint256 gen;
        rariryLevel rarity;
    }

    struct nftSaleInfo{
        uint256 price;
        address payment;
        address oracle;
    }

    enum rariryLevel{
        common,
        uncommon,
        rare,
        epic,
        legend
    }

    constructor(
        uint256 price_,
        uint256 maxSupply_,
        address payment_,
        address oracle_,
        address owner_,
        string memory name_,
        string memory symbol_,
        string memory uri_
    ) {
        payment_.functionStaticCall(
            abi.encodeWithSelector(
                IBEP20.decimals.selector,
                0,
                "HobbitPirate: This address is not token"
            )
        );
        oracle_.functionStaticCall(
            abi.encodeWithSelector(
                bytes4(hexStringToBytes.convert("48758697")),
                0,
                "HobbitPirate: This address is not nftOracle"
            )
        );

        _genExist.increment;

        _maxSupply = maxSupply_;
        saleInfo = nftSaleInfo(
            price_,
            payment_,
            oracle_
        );

        _name = name_;
        _symbol = symbol_;
        _setBaseURI(uri_);

        transferOwnership(owner_);
    }

    function resetSale(
        uint256 price_,
        uint256 saleSupply_,
        address payment_,
        address oracle_
    ) public virtual onlyOwner {
        payment_.functionStaticCall(
            abi.encodeWithSelector(
                IBEP20.decimals.selector,
                "HobbitPirate: This address is not token"
            )
        );
        oracle_.functionStaticCall(
            abi.encodeWithSelector(
                bytes4(hexStringToBytes.convert("48758697")),
                0,
                "HobbitPirate: This address is not nftOracle"
            )
        );

        require(
            oracle_ != saleInfo.oracle,
            "HobbitPirate: Please provide new nftOracle address"
        );

        _genExist.increment;

        _maxSupply += saleSupply_;
        saleInfo = nftSaleInfo(
            price_,
            payment_,
            oracle_
        );
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "HobbitPirate: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "HobbitPirate: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply.current();
    }

    function maxSupply() public view virtual returns (uint256) {
        return _maxSupply;
    }
    
    function rarityInfo(uint256 tokenId) public view virtual returns (nftInfo memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return _nftGen[tokenId];
    }

    function salesInfo() public view virtual returns (
        uint256,
        uint256,
        address
    ) {
        return(
            _genExist.current(),
            saleInfo.price,
            saleInfo.payment
        );
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory base = baseURI();
        return bytes(base).length > 0 ? string(abi.encodePacked(base, tokenId.toString())) : "";
    }

    function baseURI() internal view virtual returns (string memory) {
        return _baseURI;
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = HobbitPirate.ownerOf(tokenId);
        require(to != owner, "HobbitPirate: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "HobbitPirate: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "HobbitPirate: approved query for nonexistent token");

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
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "HobbitPirate: transfer caller is not owner nor approved");

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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "HobbitPirate: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_exists(tokenId), "HobbitPirate: operator query for nonexistent token");
        require(_isApprovedOrOwner(_msgSender(), tokenId), "HobbitPirate: caller is not owner nor approved");
        _burn(tokenId);
        _totalSupply.decrement;
        _maxSupply -= 1;
        _nftGen[tokenId] = nftInfo(
            0,
            rariryLevel.common
        );
    }

    function buyNft() public virtual {
        IBEP20(saleInfo.payment).transferFrom(
            _msgSender(),
            owner(),
            saleInfo.price
        );

        _nftExistId.increment;

        rariryLevel rarity = rariryLevel(
            uint256(
                bytes32(
                    saleInfo.oracle.functionStaticCall(
                        abi.encodeWithSelector(
                            bytes4(hexStringToBytes.convert("48758697")),
                            _nftExistId.current(),
                            "HobbitPirate: This address is not nftOracle"
                        )
                    )
                )
            )
        );

        _safeMint(
            _msgSender(),
            _nftExistId.current()
        );
        _nftGen[_nftExistId.current()] = nftInfo(
            _genExist.current(),
            rarity
        );

        _totalSupply.increment;
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "HobbitPirate: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "HobbitPirate: operator query for nonexistent token");
        address owner = HobbitPirate.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
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
            "HobbitPirate: transfer to non ERC721Receiver implementer"
        );
    }

    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "HobbitPirate: mint to the zero address");
        require(!_exists(tokenId), "HobbitPirate: token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = HobbitPirate.ownerOf(tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(HobbitPirate.ownerOf(tokenId) == from, "HobbitPirate: transfer from incorrect owner");
        require(to != address(0), "HobbitPirate: transfer to the zero address");

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(HobbitPirate.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "HobbitPirate: approve to caller");
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
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("HobbitPirate: transfer to non ERC721Receiver implementer");
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

    function lastExistId() public view returns(uint256){
        return _nftExistId.current();
    }
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(
        address account
    ) external view returns (uint256);
    function burn(
        uint256 amount
    ) external returns (bool);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);
    function approve(
        address spender,
        uint256 amount
    ) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
    
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: none

import "./IERC721.sol";

pragma solidity ^0.8.0;

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.1;

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
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

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

library hexStringToBytes{
    function fromHexChar(uint8 c) private pure returns (uint8) {
        if (bytes1(c) >= bytes1('0') && bytes1(c) <= bytes1('9')) {
            return c - uint8(bytes1('0'));
        }
        if (bytes1(c) >= bytes1('a') && bytes1(c) <= bytes1('f')) {
            return 10 + c - uint8(bytes1('a'));
        }
        if (bytes1(c) >= bytes1('A') && bytes1(c) <= bytes1('F')) {
            return 10 + c - uint8(bytes1('A'));
        }
        revert("fail");
    }

    function convert(string memory s) internal pure returns (bytes memory) {
        bytes memory ss = bytes(s);
        require(ss.length%2 == 0); // length must be even
        bytes memory r = new bytes(ss.length/2);
        for (uint i=0; i<ss.length/2; ++i) {
            r[i] = bytes1(fromHexChar(uint8(ss[2*i])) * 16 +
                        fromHexChar(uint8(ss[2*i+1])));
        }
        return r;
    }
}

// SPDX-License-Identifier: none

import "../interface/IERC165.sol";

pragma solidity ^0.8.0;

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

import "./Context.sol";

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

// SPDX-License-Identifier: none

import "./IERC165.sol";

pragma solidity ^0.8.0;

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

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
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}