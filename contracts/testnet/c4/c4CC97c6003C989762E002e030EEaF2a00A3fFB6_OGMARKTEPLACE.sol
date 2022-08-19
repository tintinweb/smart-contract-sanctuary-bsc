// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "./OGnft.sol";

interface IBEP20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}


interface IOGNft is IBEP721 {
    function mint(address to) external returns (uint256);

    function burn(uint256 tokenId) external;
}

contract OGMARKTEPLACE {
    IBEP20 public OGToken;
    uint256 public constant percentDivider = 100_000;
    uint256 public fee_percentage = 2_500;
    uint256 public wallet1fee = 50_000;
    uint256 public wallet2fee = 50_000;
    address public wallet1;
    address public wallet2;
    address  owner;

    modifier onlyOwner {
        require((msg.sender) == owner);
        _;
    }

    struct Ask {
        bool exists;
        address seller;
        uint256 price;
        address to;
        bool eth;
    }

    struct Bid {
        bool exists;
        address buyer;
        uint256 price;
        bool eth;
        address topbider;
        uint256 bidendtime;
        uint256 lastbid;
    }

    struct Price {
        uint256 ethprice;
        uint256 tokenprice;
    }

    struct escrowrecord {
        uint256 tokenamount;
        uint256 ethamount;
    }


    mapping(address => uint256) public tokenPoolCount;
    mapping(address => Price) public tokenPrice;
    mapping(address => Price) public priceInc;
    mapping(address => mapping(address => uint256)) public isWhitelisted;
    mapping(address => mapping(address => bool)) public minterClaimed;
    mapping(uint256 => Ask) public asks;
    mapping(uint256 => Bid) public bids;
    mapping(address => escrowrecord) public escrow;
    address [] public tokenlist;
    mapping(address => bool) public tokenexits;
    bool tokenminting = false;

    string public constant REVERT_NOT_OWNER_OF_TOKEN_ID =
        "Marketplace::not an owner of token ID";
    string public constant REVERT_NOT_A_CREATOR_OF_BID =
        "Marketplace::not a creator of the bid";
    string public constant REVERT_NOT_A_CREATOR_OF_ASK =
        "Marketplace::not a creator of the ask";
    string public constant REVERT_ASK_DOES_NOT_EXIST =
        "Marketplace::ask does not exist";
    string public constant REVERT_CANT_ACCEPT_OWN_ASK =
        "Marketplace::cant accept own ask";
    string public constant REVERT_ASK_IS_RESERVED =
        "Marketplace::ask is reserved";
    string public constant REVERT_ASK_INSUFFICIENT_VALUE =
        "Marketplace::ask price higher than sent value";

    event CreateAsk(uint256 indexed tokenID, uint256 price, address indexed to);
    event CancelAsk(uint256 indexed tokenID);
    event AcceptAsk(uint256 indexed tokenID, uint256 price, address indexed to);

    event CreateBid(uint256 indexed tokenID, uint256 price);
    event CancelBid(uint256 indexed tokenID);
    event AcceptBid(uint256 indexed tokenID, uint256 price);

    enum paymentmethod{
        ETH,
        TOKEN,
        BOTH
    }
    paymentmethod payment  = paymentmethod.BOTH;
  

    constructor() {
        OGToken = IBEP20(0xb6505d8cA5C111ac10aD83327D166048BCE61C59);
        owner = msg.sender;
        wallet1 = msg.sender;
        wallet2 = msg.sender;
    }

    function createAsk(
        address token,
        uint256 tokenID,
        uint256 price,
        address to,
        bool _eth
    ) external {
        require(
            IOGNft(token).ownerOf(tokenID) == msg.sender,
            REVERT_NOT_OWNER_OF_TOKEN_ID
        );
        IOGNft(token).transferFrom(msg.sender, address(this), tokenID);

        asks[tokenID] = Ask({
            exists: true,
            seller: msg.sender,
            price: price,
            to: to,
            eth: _eth
        });

        emit CreateAsk({tokenID: tokenID, price: price, to: to});
    }
    function gettokenlistlength() public view returns (uint256) {
        return tokenlist.length;
    }

    function getlatesttoken() public view returns (address) {
        return tokenlist[tokenlist.length - 1];
    }
    function setwalletsfee(uint256 _wallet1fee, uint256 _wallet2fee) external {
        require(_wallet1fee+_wallet2fee == percentDivider, "fee must be 100%");
        require(msg.sender == owner, "caller is not owner");
        wallet1fee = _wallet1fee;
        wallet2fee = _wallet2fee;
    }
    function setwalletaddress(address _wallet1address, address _wallet2address) external {
        require(msg.sender == owner, "caller is not owner");
        wallet1 = _wallet1address;
        wallet2 = _wallet2address;
    }
    function setfeepercentage(uint256 _feepercentage) external {
        require(fee_percentage < percentDivider/4, "fee must be less than 25%");
        require(msg.sender == owner, "caller is not owner");
        fee_percentage = _feepercentage;
    }
    function createBid(
        address token,
        uint256 tokenID,
        uint256 price,
        bool _eth,
        uint256 _time
    ) external {
        require(tokenexits[token], "Marketplace::token not exists");
        require(
            IOGNft(token).ownerOf(tokenID) == msg.sender,
            REVERT_NOT_OWNER_OF_TOKEN_ID
        );
        IOGNft(token).transferFrom(msg.sender, address(this), tokenID);

        bids[tokenID] = Bid({
            exists: true,
            buyer: msg.sender,
            price: price,
            eth: _eth,
            topbider: address(0),
            bidendtime: _time,
            lastbid: price
        });

        emit CreateBid({tokenID: tokenID, price: price});
    }

    function cancelAsk(address token,uint256 tokenID) external {
        require(tokenexits[token], "Marketplace::token not exists");
        require(
            asks[tokenID].seller == msg.sender,
            REVERT_NOT_A_CREATOR_OF_ASK
        );
        IOGNft(token).transferFrom(address(this), msg.sender, tokenID);
        delete asks[tokenID];

        emit CancelAsk({tokenID: tokenID});
    }

    function cancelBid(address token,uint256 tokenID) external {
        require(bids[tokenID].buyer == msg.sender, REVERT_NOT_A_CREATOR_OF_BID);
        IOGNft(token).transferFrom(address(this), msg.sender, tokenID);

        delete bids[tokenID];

        emit CancelBid({tokenID: tokenID});
    }

    function acceptAsk(address token,uint256 tokenID) external payable {
        uint256 totalPrice = 0;

        require(asks[tokenID].exists, REVERT_ASK_DOES_NOT_EXIST);
        require(asks[tokenID].seller != msg.sender, REVERT_CANT_ACCEPT_OWN_ASK);
        if (asks[tokenID].to != address(0)) {
            require(asks[tokenID].to == msg.sender, REVERT_ASK_IS_RESERVED);
        }

        totalPrice += asks[tokenID].price;

        if (asks[tokenID].eth) {
            escrow[asks[tokenID].seller].ethamount += _takeFee(
                asks[tokenID].price
            );
            escrow[wallet1].ethamount += (((asks[tokenID].price - _takeFee(asks[tokenID].price)) * wallet1fee)/percentDivider);
            escrow[wallet2].ethamount += (((asks[tokenID].price - _takeFee(asks[tokenID].price)) * wallet2fee)/percentDivider);
        } else {
            escrow[asks[tokenID].seller].tokenamount += _takeFee(
                asks[tokenID].price
            );
            escrow[wallet1].tokenamount += (((asks[tokenID].price - _takeFee    (asks[tokenID].price))*wallet1fee)/percentDivider);
            escrow[wallet2].tokenamount += (((asks[tokenID].price - _takeFee (asks[tokenID].price))*wallet2fee)/percentDivider);
        }

        emit AcceptAsk({
            tokenID: tokenID,
            price: asks[tokenID].price,
            to: asks[tokenID].to
        });
        IOGNft(token).transferFrom(address(this), msg.sender, tokenID);
        delete asks[tokenID];
        delete bids[tokenID];

        if (asks[tokenID].eth) {
            require(totalPrice == msg.value, REVERT_ASK_INSUFFICIENT_VALUE);
        } else {
            OGToken.transferFrom(
                msg.sender,
                address(this),
                asks[tokenID].price
            );
        }
    }

    function acceptBid(uint256 tokenID, uint256 amount) external payable {
        require(bids[tokenID].exists, "bid does not exist");
        require(bids[tokenID].buyer != msg.sender, "cant accept own bid");
        require(block.timestamp < bids[tokenID].bidendtime, "bid expired");

        if (bids[tokenID].eth) {
            require(
                msg.value >= bids[tokenID].lastbid,
                "bid price need to be higher than sent value"
            );
            if (bids[tokenID].topbider != address(0)) {
                escrow[bids[tokenID].topbider].ethamount += bids[tokenID]
                    .lastbid;
            }

            bids[tokenID].lastbid = msg.value;
        } else {
            require(
                amount >= bids[tokenID].lastbid,
                "bid price need to be higher than sent value"
            );
            OGToken.transferFrom(msg.sender, address(this), amount);
            if (bids[tokenID].topbider != address(0)) {
                escrow[bids[tokenID].topbider].tokenamount += bids[tokenID]
                    .lastbid;
            }
            bids[tokenID].lastbid = amount;
        }
        bids[tokenID].topbider = msg.sender;
    }

    function claimbid(address token,uint256 tokenID) external {
            require(block.timestamp > bids[tokenID].bidendtime, "bid expired");
        if (bids[tokenID].topbider == address(0)) {
            require(
                bids[tokenID].buyer == msg.sender,
                "onlybidowner can claim bid"
            );
            IOGNft(token).transferFrom(address(this), msg.sender, tokenID);
        } else {
            require(
                bids[tokenID].topbider == msg.sender,
                "onlybidowner can claim bid"
            );
            if (bids[tokenID].eth) {
                escrow[bids[tokenID].buyer].tokenamount += _takeFee(
                    bids[tokenID].lastbid
                );
                escrow[wallet1].tokenamount += (((bids[tokenID].lastbid-_takeFee(bids[tokenID].lastbid))*wallet1fee)/percentDivider);
                escrow[wallet2].tokenamount += (((bids[tokenID].lastbid-_takeFee(bids[tokenID].lastbid))*wallet2fee)/percentDivider);
            } else {
                escrow[bids[tokenID].buyer].ethamount += _takeFee(
                    bids[tokenID].lastbid
                );
                escrow[wallet1].ethamount += (((bids[tokenID].lastbid-_takeFee(bids[tokenID].lastbid))*wallet1fee)/percentDivider);
                escrow[wallet2].ethamount += (((bids[tokenID].lastbid-_takeFee(bids[tokenID].lastbid))*wallet2fee)/percentDivider);
            }
            IOGNft(token).transferFrom(address(this), msg.sender, tokenID);
        }

        delete bids[tokenID];
    }

    function withdraw(bool _eth) external {
        if (_eth) {
            uint256 amount = escrow[msg.sender].ethamount;
            escrow[msg.sender].ethamount = 0;
            payable(msg.sender).transfer(amount);
        } else {
            uint256 amount = escrow[msg.sender].tokenamount;
            escrow[msg.sender].tokenamount = 0;
            OGToken.transferFrom(address(this), msg.sender, amount);
        }
    }

    function _takeFee(uint256 totalPrice) internal virtual returns (uint256) {
        return totalPrice - ((totalPrice * fee_percentage) / percentDivider);
    }
    function setpaymentMethod(paymentmethod variable) public {
        require(msg.sender == owner, "only owner can set payment method");
        payment = variable;
    }
    function buyNFT(address token, bool eth) public payable {
        if(payment == paymentmethod.ETH) {
            require(eth == true, "only ETH payment is allowed");
        }else if(payment == paymentmethod.TOKEN){
            require(eth == false , "only TOKEN payment is allowed");
        }
        IOGNft(token).mint(msg.sender);
        
        tokenPoolCount[token]--;
        if (!eth) {
            IBEP20(OGToken).transferFrom(
                msg.sender,
                address(this),
                tokenPrice[token].tokenprice
            );
        } else {
            require(msg.value == tokenPrice[token].ethprice, "wrong price");
            payable(owner).transfer(msg.value);
        }
        tokenPrice[token].ethprice += priceInc[token].ethprice;
        tokenPrice[token].tokenprice += priceInc[token].tokenprice;
    }

    function claimNFT(address token) public {
        require(isWhitelisted[token][msg.sender] > 0, "Not whitelisted");
        for (uint256 i = 0; i < isWhitelisted[token][msg.sender]; i++) {
            IOGNft(token).mint(msg.sender);
            tokenPoolCount[token]--;
            isWhitelisted[token][msg.sender]--;
        }
    }

    function transferBatch(
        address token,
        address receiver,
        uint256 [] memory ids
    ) public {
        for (uint256 i = 0; i < ids.length; i++) {
            IOGNft(token).safeTransferFrom(msg.sender, receiver, ids[i]); 
        }
    }

    function whitelistUsers(
        address token,
        address[] memory users,
        uint256[] memory quantitty
    ) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            isWhitelisted[token][users[i]] = quantitty[i];
        }
    }

    function setPriceIncrement(
        address token,
        uint256 ethamount,
        uint256 tokenamount
    ) external onlyOwner {
        priceInc[token].ethprice = ethamount;
        priceInc[token].tokenprice = tokenamount;
    }

    function addNewToken(
        string memory _uri,
        string memory _name,
        string memory _symbol,
        uint256 max,
        uint256 tokenprice,
        uint256 ethprice,
        uint256 ethinc,
        uint256 tokeninc
    ) external onlyOwner {
        IBEP721 newToken = new OGNFT(
        _name,
        _symbol,
        _uri,
        owner
        );
        tokenlist.push(address(newToken));
        tokenexits[address(newToken)] = true;

        require(
            tokenPrice[address(newToken)].ethprice == 0 && tokenPrice[address(newToken)].ethprice == 0,
            "Already listed"
        );
        tokenPoolCount[address(newToken)] = max;
        tokenPrice[address(newToken)].ethprice = ethprice;
        tokenPrice[address(newToken)].tokenprice = tokenprice;
        priceInc[address(newToken)].ethprice = ethinc;
        priceInc[address(newToken)].tokenprice = tokeninc;
    }

    function changeOGToken(IBEP20 token) external onlyOwner {
        OGToken = token;
    }

    function changeowner(address _owner) public onlyOwner {
        require(owner != _owner, "cant change owner to same address");
        require(_owner != address(0), "cant change owner to address(0)");
        owner = _owner;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IBEP721Receiver {
    function onBEP721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IBEP165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IBEP721 is IBEP165 {
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

interface IBEP721Metadata is IBEP721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

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

abstract contract BEP165 is IBEP165 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IBEP165).interfaceId;
    }
}

contract BEP721 is Context, BEP165, IBEP721, IBEP721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(BEP165, IBEP165)
        returns (bool)
    {
        return
            interfaceId == type(IBEP721).interfaceId ||
            interfaceId == type(IBEP721Metadata).interfaceId ||
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
            "BEP721: balance query for the zero address"
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
            "BEP721: owner query for nonexistent token"
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
            "BEP721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = BEP721.ownerOf(tokenId);
        require(to != owner, "BEP721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "BEP721: approve caller is not owner nor approved for all"
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
            "BEP721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(operator != _msgSender(), "BEP721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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
            "BEP721: transfer caller is not owner nor approved"
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
            "BEP721: transfer caller is not owner nor approved"
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
            _checkOnBEP721Received(from, to, tokenId, _data),
            "BEP721: transfer to non BEP721Receiver implementer"
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
            "BEP721: operator query for nonexistent token"
        );
        address owner = BEP721.ownerOf(tokenId);
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
            _checkOnBEP721Received(address(0), to, tokenId, _data),
            "BEP721: transfer to non BEP721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "BEP721: mint to the zero address");
        require(!_exists(tokenId), "BEP721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = BEP721.ownerOf(tokenId);

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
        require(
            BEP721.ownerOf(tokenId) == from,
            "BEP721: transfer of token that is not own"
        );
        require(to != address(0), "BEP721: transfer to the zero address");

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
        emit Approval(BEP721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnBEP721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IBEP721Receiver(to).onBEP721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IBEP721Receiver.onBEP721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "BEP721: transfer to non BEP721Receiver implementer"
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
}

interface IBEP721Enumerable is IBEP721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}

abstract contract BEP721Enumerable is BEP721, IBEP721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IBEP165, BEP721)
        returns (bool)
    {
        return
            interfaceId == type(IBEP721Enumerable).interfaceId ||
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
            index < BEP721.balanceOf(owner),
            "BEP721Enumerable: owner index out of bounds"
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
            index < BEP721Enumerable.totalSupply(),
            "BEP721Enumerable: global index out of bounds"
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
        uint256 length = BEP721.balanceOf(to);
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
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = BEP721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

abstract contract BEP721URIStorage is BEP721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "BEP721URIStorage: URI query for nonexistent token"
        );

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

    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(tokenId),
            "BEP721URIStorage: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _burnTokenURI(uint256 tokenId) internal virtual {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
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

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

contract OGNFT is BEP721, BEP721Enumerable, BEP721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    string uri ;

    address public minter;
    address public admin;

    modifier onlyMinter() {
        require(minter == _msgSender(), "caller is not the minter");
        _;
    }

    constructor(string memory _name, string memory _symbol, string memory _uri,address user) BEP721(_name, _symbol) {
        uri = _uri;
        minter = msg.sender;
        admin = user;
        
    }

    function mint(address to)
        public
        onlyMinter
        returns (uint256)
    {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(BEP721, BEP721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function burn(uint256 tokenId) public onlyMinter {
        super._burnTokenURI(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(BEP721, BEP721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(BEP721, BEP721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function changeOGMinter(address _minter) external  {
        require(msg.sender == admin);
        minter = _minter;
    }
}