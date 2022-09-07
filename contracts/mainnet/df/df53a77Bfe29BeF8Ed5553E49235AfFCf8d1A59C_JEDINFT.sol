// SPDX-License-Identifier: MIT

pragma solidity 0.7.4;

abstract contract Context {
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function getOwner() external view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Strings {
    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c,
        string memory _d,
        string memory _e
    ) internal pure returns (string memory) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(
            _ba.length + _bb.length + _bc.length + _bd.length + _be.length
        );
        bytes memory babcde = bytes(abcde);
        uint256 k = 0;
        for (uint256 i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (uint256 i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (uint256 i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (uint256 i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (uint256 i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c,
        string memory _d
    ) internal pure returns (string memory) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c
    ) internal pure returns (string memory) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b)
        internal
        pure
        returns (string memory)
    {
        return strConcat(_a, _b, "", "", "");
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath#mul: OVERFLOW");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath#div: DIVISION_BY_ZERO");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath#sub: UNDERFLOW");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath#add: OVERFLOW");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath#mod: DIVISION_BY_ZERO");
        return a % b;
    }
}

interface IBEP165 {
    function supportsInterface(bytes4 _interfaceId)
        external
        view
        returns (bool);
}

interface IBEP1155TokenReceiver {
    function onBEP1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _amount,
        bytes calldata _data
    ) external returns (bytes4);

    function onBEP1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        bytes calldata _data
    ) external returns (bytes4);

    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract BEP1155Tradable is IBEP165, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using Strings for string;

    struct NFTAttribute {
        uint256 pd; // Power Damage
        uint256 pk; // Power Kinetics
        uint256 ps; // Power Speed
        uint256 pc; // Power Conversion
        uint256 ph; // Power Healing
        uint256 pave; // Power Average
    }

    bytes4 internal constant BEP1155_RECEIVED_VALUE = 0xf23a6e61;
    bytes4 internal constant BEP1155_BATCH_RECEIVED_VALUE = 0xbc197c81;
    bytes4 private constant INTERFACE_SIGNATURE_BEP165 = 0x01ffc9a7;
    bytes4 private constant INTERFACE_SIGNATURE_BEP1155 = 0xd9b67a26;

    mapping(address => mapping(uint256 => uint256)) internal balances;
    mapping(address => uint256) internal powers;

    mapping(uint256 => NFTAttribute) public settings;

    mapping(address => mapping(address => bool)) internal operators;

    string internal baseMetadataURI;

    address proxyRegistryAddress;
    uint256 private _currentTokenID = 0;
    mapping(uint256 => address) public creators;
    mapping(uint256 => uint256) private tokenSupply;
    mapping(uint256 => uint256) private tokenMaxSupply;
    mapping(uint256 => uint256) private tokenPrice;
    mapping(address => bool) public isPool;

    string public name;
    string public symbol;

    modifier onlyLendingPool() {
        require(isPool[msg.sender], "!lending pool");
        _;
    }

    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _amount
    );
    event TransferBatch(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _amounts
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );
    event URI(string _uri, uint256 indexed _id);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _newBaseMetadataURI
    ) {
        name = _name;
        symbol = _symbol;
        baseMetadataURI = _newBaseMetadataURI;
    }

    function setProxyRegistryAddress(address _proxyRegistryAddress)
        external
        onlyOwner
    {
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    function setBaseMetadataURI(string memory _newBaseMetadataURI)
        external
        onlyOwner
    {
        _setBaseMetadataURI(_newBaseMetadataURI);
    }

    function addLendingPool(address pool) external onlyOwner {
        isPool[pool] = true;
    }

    function delLendingPool(address pool) external onlyOwner {
        delete (isPool[pool]);
    }

    function create(
        uint256 _maxSupply,
        uint256 _price,
        uint256 pd, // Power Damage
        uint256 pk, // Power Kinetics
        uint256 ps, // Power Speed
        uint256 pc, // Power Conversion
        uint256 ph // Power Healing
    ) external onlyOwner returns (uint256 tokenId) {
        uint256 _id = _getNextTokenID();
        _incrementTokenTypeId();
        creators[_id] = msg.sender;
        tokenPrice[_id] = _price;
        tokenMaxSupply[_id] = _maxSupply;
        NFTAttribute storage n = settings[_id];
        n.pd = pd;
        n.pk = pk;
        n.ps = ps;
        n.pc = pc;
        n.ph = ph;
        n.pave = (n.pd.add(n.pk).add(n.ps).add(n.pc).add(n.ph)).div(5);
        return _id;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) external {
        require(
            (msg.sender == _from) || isApprovedForAll(_from, msg.sender),
            "BEP1155#safeTransferFrom: INVALID_OPERATOR"
        );
        require(
            _to != address(0),
            "BEP1155#safeTransferFrom: INVALID_RECIPIENT"
        );

        _safeTransferFrom(_from, _to, _id, _amount);
        _callonBEP1155Received(_from, _to, _id, _amount, _data);
    }

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) external {
        require(
            (msg.sender == _from) || isApprovedForAll(_from, msg.sender),
            "BEP1155#safeBatchTransferFrom: INVALID_OPERATOR"
        );
        require(
            _to != address(0),
            "BEP1155#safeBatchTransferFrom: INVALID_RECIPIENT"
        );

        _safeBatchTransferFrom(_from, _to, _ids, _amounts);
        _callonBEP1155BatchReceived(_from, _to, _ids, _amounts, _data);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function mintTo(address _to, uint256 _tokenId)
        external
        onlyLendingPool
        returns (uint256 _tokenPrice)
    {
        uint256 tokenId = _tokenId;
        uint256 tSupply = tokenSupply[tokenId];
        require(tSupply < tokenMaxSupply[tokenId], "Max supply reached");

        _mint(_to, tokenId, 1, "0x0");

        emit TransferSingle(msg.sender, address(0x0), _to, tokenId, 1);
        tokenSupply[tokenId] = tSupply.add(1);
        return tokenPrice[tokenId];
    }

    function mint(uint256 _tokenId)
        external
        onlyOwner
        returns (uint256 _tokenPrice)
    {
        uint256 tokenId = _tokenId;
        uint256 tSupply = tokenSupply[tokenId];
        require(tSupply < tokenMaxSupply[tokenId], "Max supply reached");

        _mint(msg.sender, tokenId, 1, "0x0");

        emit TransferSingle(msg.sender, address(0x0), msg.sender, tokenId, 1);
        tokenSupply[tokenId] = tSupply.add(1);
        return tokenPrice[tokenId];
    }

    function burn(
        address _from,
        uint256 _id,
        uint256 _amount
    ) external {
        require(
            msg.sender == _from || isApprovedForAll(_from, msg.sender),
            "BEP1155#burn: INVALID_OPERATOR"
        );

        _burn(_from, _id, _amount);

        emit TransferSingle(msg.sender, _from, address(0x0), _id, _amount);
    }

    function balanceOf(address _owner, uint256 _id)
        external
        view
        returns (uint256)
    {
        return balances[_owner][_id];
    }

    function balanceOfBatch(address[] memory _owners, uint256[] memory _ids)
        external
        view
        returns (uint256[] memory)
    {
        require(
            _owners.length == _ids.length,
            "BEP1155#balanceOfBatch: INVALID_ARRAY_LENGTH"
        );

        uint256[] memory batchBalances = new uint256[](_owners.length);

        for (uint256 i = 0; i < _owners.length; i++) {
            batchBalances[i] = balances[_owners[i]][_ids[i]];
        }

        return batchBalances;
    }

    function supportsInterface(bytes4 _interfaceID)
        external
        pure
        override
        returns (bool)
    {
        if (
            _interfaceID == INTERFACE_SIGNATURE_BEP165 ||
            _interfaceID == INTERFACE_SIGNATURE_BEP1155
        ) {
            return true;
        }
        return false;
    }

    function uri(uint256 _id) external view returns (string memory) {
        require(_exists(_id), "BEP1155Tradable#uri: NONEXISTENT_TOKEN");
        return Strings.strConcat(baseMetadataURI, Strings.uint2str(_id));
    }

    function contractURI() external view returns (string memory) {
        return Strings.strConcat(baseMetadataURI, "contractURI");
    }

    function totalSupply(uint256 _id) external view returns (uint256) {
        return tokenSupply[_id];
    }

    function maxSupply(uint256 _id) external view returns (uint256) {
        return tokenMaxSupply[_id];
    }

    function price(uint256 _id) external view returns (uint256) {
        return tokenPrice[_id];
    }

    function powerOf(address account) public view returns (uint256) {
        return powers[account];
    }

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        returns (bool isOperator)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(_owner)) == _operator) {
            return true;
        }

        return operators[_owner][_operator];
    }

    function isExist(uint256 _id) external view returns (bool) {
        return _exists(_id);
    }

    function totalExist() external view returns (uint256) {
        return _currentTokenID;
    }

    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount
    ) internal {
        balances[_from][_id] = balances[_from][_id].sub(_amount); // Subtract amount
        powers[_from] = powers[_from].mul(_amount.add(1)).sub(
            settings[_id].pave.mul(_amount)
        );

        balances[_to][_id] = balances[_to][_id].add(_amount); // Add amount
        powers[_to] = (powers[_to].add(settings[_id].pave.mul(_amount))).div(
            _amount.add(1)
        );

        emit TransferSingle(msg.sender, _from, _to, _id, _amount);
    }

    function _callonBEP1155Received(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) internal {
        if (_to.isContract()) {
            bytes4 retval = IBEP1155TokenReceiver(_to).onBEP1155Received(
                msg.sender,
                _from,
                _id,
                _amount,
                _data
            );
            require(
                retval == BEP1155_RECEIVED_VALUE,
                "BEP1155#_callonBEP1155Received: INVALID_ON_RECEIVE_MESSAGE"
            );
        }
    }

    function _safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts
    ) internal {
        require(
            _ids.length == _amounts.length,
            "BEP1155#_safeBatchTransferFrom: INVALID_ARRAYS_LENGTH"
        );

        uint256 nTransfer = _ids.length;

        for (uint256 i = 0; i < nTransfer; i++) {
            balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(
                _amounts[i]
            );
            powers[_from] = powers[_from].mul(_amounts[i].add(1)).sub(
                settings[_ids[i]].pave.mul(_amounts[i])
            );
            balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_amounts[i]);
            powers[_to] = (
                powers[_to].add(settings[_ids[i]].pave.mul(_amounts[i]))
            ).div(_amounts[i].add(1));
        }

        emit TransferBatch(msg.sender, _from, _to, _ids, _amounts);
    }

    function _callonBEP1155BatchReceived(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) internal {
        if (_to.isContract()) {
            bytes4 retval = IBEP1155TokenReceiver(_to).onBEP1155BatchReceived(
                msg.sender,
                _from,
                _ids,
                _amounts,
                _data
            );
            require(
                retval == BEP1155_BATCH_RECEIVED_VALUE,
                "BEP1155#_callonBEP1155BatchReceived: INVALID_ON_RECEIVE_MESSAGE"
            );
        }
    }

    function _logURIs(uint256[] memory _tokenIDs) internal {
        string memory baseURL = baseMetadataURI;
        string memory tokenURL;

        for (uint256 i = 0; i < _tokenIDs.length; i++) {
            tokenURL = string(
                abi.encodePacked(
                    baseURL,
                    Strings.uint2str(_tokenIDs[i]),
                    ".json"
                )
            );
            emit URI(tokenURL, _tokenIDs[i]);
        }
    }

    function _logURIs(uint256[] memory _tokenIDs, string[] memory _URIs)
        internal
    {
        require(
            _tokenIDs.length == _URIs.length,
            "BEP1155Metadata#_logURIs: INVALID_ARRAYS_LENGTH"
        );
        for (uint256 i = 0; i < _tokenIDs.length; i++) {
            emit URI(_URIs[i], _tokenIDs[i]);
        }
    }

    function _setBaseMetadataURI(string memory _newBaseMetadataURI) internal {
        baseMetadataURI = _newBaseMetadataURI;
    }

    function _mint(
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) internal {
        balances[_to][_id] = balances[_to][_id].add(_amount);
        powers[_to] = (powers[_to].add(settings[_id].pave.mul(_amount))).div(
            _amount.add(1)
        );

        emit TransferSingle(msg.sender, address(0x0), _to, _id, _amount);

        _callonBEP1155Received(address(0x0), _to, _id, _amount, _data);
    }

    function _batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) internal {
        require(
            _ids.length == _amounts.length,
            "BEP1155MintBurn#batchMint: INVALID_ARRAYS_LENGTH"
        );

        uint256 nMint = _ids.length;

        for (uint256 i = 0; i < nMint; i++) {
            balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_amounts[i]);
            powers[_to] = (
                powers[_to].add(settings[_ids[i]].pave.mul(_amounts[i]))
            ).div(_amounts[i].add(1));
        }

        emit TransferBatch(msg.sender, address(0x0), _to, _ids, _amounts);

        _callonBEP1155BatchReceived(address(0x0), _to, _ids, _amounts, _data);
    }

    function _burn(
        address _from,
        uint256 _id,
        uint256 _amount
    ) internal {
        balances[_from][_id] = balances[_from][_id].sub(_amount);
        powers[_from] = powers[_from].mul(_amount.add(1)).sub(
            settings[_id].pave.mul(_amount)
        );

        emit TransferSingle(msg.sender, _from, address(0x0), _id, _amount);
    }

    function _batchBurn(
        address _from,
        uint256[] memory _ids,
        uint256[] memory _amounts
    ) internal {
        require(
            _ids.length == _amounts.length,
            "BEP1155MintBurn#batchBurn: INVALID_ARRAYS_LENGTH"
        );

        uint256 nBurn = _ids.length;

        for (uint256 i = 0; i < nBurn; i++) {
            balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(
                _amounts[i]
            );
            powers[_from] = powers[_from].mul(_amounts[i].add(1)).sub(
                settings[_ids[i]].pave.mul(_amounts[i])
            );
        }

        emit TransferBatch(msg.sender, _from, address(0x0), _ids, _amounts);
    }

    function _exists(uint256 _id) internal view returns (bool) {
        return creators[_id] != address(0);
    }

    function _getNextTokenID() private view returns (uint256) {
        return _currentTokenID.add(1);
    }

    function _incrementTokenTypeId() private {
        _currentTokenID++;
    }
}

contract JEDINFT is BEP1155Tradable {
    using Strings for string;
    using Address for address;

    constructor(address master)
        Ownable()
        BEP1155Tradable(
            "$JEDINFT Token",
            "$JEDINFT",
            "ipfs://QmYq7fYTxBajdLeqvt2L2sfgDWfNCwkjAuoLUyvb9U3AdL/"
        )
    {
        _transferOwnership(master);
    }
}