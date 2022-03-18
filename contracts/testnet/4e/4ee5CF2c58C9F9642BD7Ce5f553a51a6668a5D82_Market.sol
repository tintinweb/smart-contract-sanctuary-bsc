/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// IERC165
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// ERC165
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// IERC721
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

// IERC721Receiver
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// IERC721Metadata
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// Address
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
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

// Context
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// Strings
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

// ERC721
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
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

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
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
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
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
        //solhint-disable-next-line max-line-length
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
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
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
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

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
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
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
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
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
}

// ERC721URIStorage
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    mapping(uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// Counters
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

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// BscNFT
contract BscNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    constructor() ERC721("BinanceSmartChainNFT", "BFT") {}

    mapping(string => bool) private existsURI; // tokenURI => true or false
    mapping(uint256 => address[]) private ownerHistory; // tokenId => ownerHistory
    mapping(address => uint256[]) private myTokenList; // some account => tokenIds owned by the account
    mapping(uint256 => uint256) private salesList; // tokenId => price

    address private Marketaddress; // Market address

    // approve the Market address
    function setApproveAddress(address _Marketaddress) public {
        Marketaddress = _Marketaddress;
    }

    function setApprove(uint256 _tokenId) private {
        approve(Marketaddress, _tokenId);
    }

    // create token
    function createToken(string memory _tokenURI, address minter) public returns (uint256){
        require(!existsURI[_tokenURI], "The URI already exsists");
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _safeMint(minter, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);

        ownerHistory[newTokenId].push(minter);
        myTokenList[minter].push(newTokenId);
        existsURI[_tokenURI] = true;

        return newTokenId;
    }

    // edit myTokenList and ownerHistory
    function editList(uint256 _tokenId, address _buyer) public {
        address seller = ownerOf(_tokenId);
        uint256 len = myTokenList[seller].length;

        for (uint i = 0; i < len; i++) {
            if (myTokenList[seller][i] == _tokenId) {
                myTokenList[seller][i] = myTokenList[seller][len-1];
            }
        }
        myTokenList[seller].pop();
        
        ownerHistory[_tokenId].push(_buyer);
        myTokenList[_buyer].push(_tokenId);
    }

    // send the token from seller to buyer
    function sendToken(uint256 _tokenId, address _buyer) public {
        address seller = ownerOf(_tokenId);
        safeTransferFrom(seller, _buyer, _tokenId);
        delete salesList[_tokenId];
    }
    
    // put the token on sales list
    function salesToken(uint256 _tokenId, uint256 _price, address owner) public {
        require(_tokenId > 0 && _tokenId <= getCount(), "Does not exists the tokenId");
        require(owner == ownerOf(_tokenId), "You are not owner of the token");
        // require(salesList[_tokenId] == 0, "The token already exists in salesList");
        require(_price > 0, "The price is higher than zero");

        // setApprove(_tokenId);
        _setApprovalForAll(owner,msg.sender,true);
        // salesList[_tokenId] = _price;
        salesList[_tokenId] = _price * 10 ** 18; // bnb to wei
    }

    function cancleSalesToken(uint256 _tokenId) public {
        delete salesList[_tokenId];
    }

    // get list of token on sale
    function getSalesList(uint256 _tokenId) public view returns(uint256, uint256, string memory, address) {
        require(_tokenId > 0 && _tokenId <= getCount(), "Does not exists the tokenId");
        require(salesList[_tokenId] > 0, "Does not sales the token");

        return (
            _tokenId,
            salesList[_tokenId],
            tokenURI(_tokenId),
            ownerOf(_tokenId)
        );
    }

    // get token price
    function getTokenPrice(uint256 _tokenId) public view returns(uint256) {
        require(_tokenId > 0 && _tokenId <= getCount(), "Does not exists the tokenId");
        require(salesList[_tokenId] > 0, "Does not sales the token");
        return salesList[_tokenId];
    }

    // token Counter
    function getCount() public view returns(uint256) {
        return _tokenIds.current();
    }

    // owner history of the token
    function getOwnerHistory(uint256 _tokenId) public view returns(address[] memory) {
        require(_tokenId > 0 && _tokenId <= getCount(), "Does not exists the tokenId");
        return ownerHistory[_tokenId];
    }

    // my token list
    function getMyTokenList(address _account) public view returns(uint256[] memory) {
        return myTokenList[_account];
    }

    // get contract balance
    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }
}

contract Market {
    address private BFTaddress; // BscNFT address

    /// platform 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

    /// creater 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

    /// student 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db

    // newOwner 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB

    mapping(uint256 => uint256) public subscriptionPrice; // tokenId => subscription price

    //To be revised later
    mapping(string => uint256) public distributionRatio; // distribution ratio;

    mapping(address => mapping(uint256 => uint256)) subscriptionHistory; // address => tokenId => date of purchase ticket

    event mintNewToken(uint256 tokenId);

    constructor(address _BFTaddress) {
        BFTaddress = _BFTaddress; // BscNFT address
        setApproveAddress(address(this)); // set the Market address to approve
        //distributionRatio initialization
        distributionRatio["creater"] = 10;
        distributionRatio["owner"] = 80;
        distributionRatio["seller"] = 90;
        distributionRatio["broker"] = 10;
    }

    // set the Market address to approve
    function setApproveAddress(address _Marketaddress) private {
        BscNFT _BFT = BscNFT(BFTaddress);
        _BFT.setApproveAddress(_Marketaddress);
    }

    // Mint NFT  --clear
    function mintCourse(
        address _minter,
        string memory _tokenURI
    ) public {
        BscNFT _BFT = BscNFT(BFTaddress);
        uint256 newTokenId = _BFT.createToken(_tokenURI, _minter);
        emit mintNewToken(newTokenId);
    }

    //  Sell NFT --clear
    // 이게 ownership
    function sellNFT(uint256 tokenId, uint256 price) public {
        require(price > 0, "Price must be greater than zero.");
        BscNFT _BFT = BscNFT(BFTaddress);
        require(
            tokenId > 0 && tokenId <= _BFT.getCount(),
            "Does not exists the tokenId"
        );
        address owner = _BFT.ownerOf(tokenId);
        require(msg.sender == owner, "You are not Owner, only Owner can sell");
        _BFT.salesToken(tokenId, price, msg.sender);
    }

    // reset subscription price
    function sellCourse(uint256 tokenId, uint256 price) public {
        require(price > 0, "Price must be greater than zero.");
        BscNFT _BFT = BscNFT(BFTaddress);
        require(
            tokenId > 0 && tokenId <= _BFT.getCount(),
            "Does not exists the tokenId"
        );
        address owner = _BFT.ownerOf(tokenId);
        require(msg.sender == owner, "You are not Owner");
        subscriptionPrice[tokenId] = price * 10**18;
    }

    function stopNFT(uint256 tokenId) public {
        BscNFT _BFT = BscNFT(BFTaddress);
        require(
            tokenId > 0 && tokenId <= _BFT.getCount(),
            "Does not exists the tokenId"
        );
        address owner = _BFT.ownerOf(tokenId);
        require(msg.sender == owner, "You are not Owner");
        _BFT.cancleSalesToken(tokenId);
    }

    function stopCourse(uint256 tokenId) public {
        BscNFT _BFT = BscNFT(BFTaddress);
        require(
            tokenId > 0 && tokenId <= _BFT.getCount(),
            "Does not exists the tokenId"
        );
        address owner = _BFT.ownerOf(tokenId);
        require(msg.sender == owner, "You are not Owner");
        delete  subscriptionPrice[tokenId];
    }

    


    //  buy NFT --clear
    function buyNFT(uint256 tokenId) public payable {
        BscNFT _BFT = BscNFT(BFTaddress);
        address seller = _BFT.ownerOf(tokenId);
        uint256 price = _BFT.getTokenPrice(tokenId);
        require(
            tokenId > 0 && tokenId <= _BFT.getCount(),
            "Does not exists the tokenId"
        );
        require(msg.sender != seller, "You are Seller, Seller cannot puchase");
        require(price > 0, "Does not sales the token");
        require(msg.value == price, "Incorrected amount");

        // edit myTokenList and ownerhistory
        _BFT.editList(tokenId, msg.sender);

        // payment od price
        // payable(seller).call{value: msg.value}(""); // return type is bool

        payable(seller).transfer(
            (msg.value * distributionRatio["seller"]) / 100
        );
        // transfer the token from seller to buyer
        _BFT.sendToken(tokenId, msg.sender);
    }

    // subscribe Course --clear
    function subscribeCourse(uint256 tokenId) public payable {
        BscNFT _BFT = BscNFT(BFTaddress);
        address owner = _BFT.ownerOf(tokenId);
        address creater = _BFT.getOwnerHistory(tokenId)[0];
        uint256 price = subscriptionPrice[tokenId];

        require(
            tokenId > 0 && tokenId <= _BFT.getCount(),
            "Does not exists the tokenId"
        );
        require(msg.sender != owner, "You are Seller, Seller cannot subscribe");
        require(price > 0, "Does not sales the token");
        require(msg.value == price, "Incorrected amount");

        payable(owner).transfer((msg.value * distributionRatio["owner"]) / 100);
        payable(creater).transfer(
            (msg.value * distributionRatio["creater"]) / 100
        );
        uint256 time = block.timestamp;
        subscriptionHistory[msg.sender][tokenId] = time;
    }

    function getSubscriptionPrice(uint256 tokenId)
        public
        view
        returns (uint256)
    {
        return subscriptionPrice[tokenId];
    }

    function getSubscriptionHistory(uint256 tokenId)
        public
        view
        returns (uint256)
    {
        return subscriptionHistory[msg.sender][tokenId];
    }

    // withdrawal

    // get contract balance
    function getMarketBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // fee controller
}