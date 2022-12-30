/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

pragma solidity 0.5.9;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Transfer to null address is not allowed");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

}


contract Beneficiary is Ownable {

    address payable public beneficiary;

    constructor() public  {
        beneficiary = msg.sender;
    }

    function setBeneficiary(address payable _beneficiary) public onlyOwner {
        beneficiary = _beneficiary;
    }

    function withdrawal(uint256 value) public onlyOwner {
        if (value > address(this).balance) {
            revert("Insufficient balance");
        }

        beneficiaryPayout(value);
    }

    function withdrawalAll() public onlyOwner {
        beneficiaryPayout(address(this).balance);
    }

    function beneficiaryPayout(uint256 value) internal {
        beneficiary.transfer(value);
        emit BeneficiaryPayout(value);
    }

    event BeneficiaryPayout(uint256 value);
}



contract Manageable is Beneficiary {

    uint256 DECIMALS = 10e8;

    bool maintenance = false;

    mapping(address => bool) public managers;

    modifier onlyManager() {

        require(managers[msg.sender] || msg.sender == address(this), "Only managers allowed");
        _;
    }

    modifier notOnMaintenance() {
        require(!maintenance);
        _;
    }

    bool saleOpen = false;

    modifier onlyOnSale() {
        require(saleOpen);
        _;
    }

    constructor() public {
        managers[msg.sender] = true;
    }

    function setMaintenanceStatus(bool _status) public onlyManager {
        maintenance = _status;
        emit Maintenance(_status);
    }

    function setManager(address _manager) public onlyOwner {
        managers[_manager] = true;
    }

    function deleteManager(address _manager) public onlyOwner {
        delete managers[_manager];
    }

    function _addressToPayable(address _address) internal pure returns (address payable) {
        return address(uint160(_address));
    }

    event Maintenance(bool status);

    event FailedPayout(address to, uint256 value);

}

pragma solidity 0.5.9;

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721 {
    function name() external view returns (string memory _name);

    function symbol() external view returns (string memory _symbol);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    function approve(address _approved, uint256 _tokenId) external;

    function setApprovalForAll(address _operator, bool _approved) external;

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    function getApproved(uint256 _tokenId) external view returns (address);

    function balanceOf(address _owner) external view returns (uint256);

    function tokenURI(uint256 _tokenId) external view returns (string memory);

    function baseTokenURI() external view returns (string memory);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;


    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);


}

interface IERC721Receiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}

contract LockableToken is Manageable {
    mapping(uint256 => bool) public locks;

    modifier onlyNotLocked(uint256 _tokenId) {
        require(!locks[_tokenId]);
        _;
    }

    function isLocked(uint256 _tokenId) public view returns (bool) {
        return locks[_tokenId];
    }

    function lockToken(uint256 _tokenId) public onlyManager {
        locks[_tokenId] = true;
    }

    function unlockToken(uint256 _tokenId) public onlyManager {
        locks[_tokenId] = false;
    }

    function _lockToken(uint256 _tokenId) internal {
        locks[_tokenId] = true;
    }

    function _unlockToken(uint256 _tokenId) internal {
        locks[_tokenId] = false;
    }

}

library Strings {
    // via https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol
    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {
        return strConcat(_a, _b, "", "", "");
    }

    function uint2str(uint i) internal pure returns (string memory) {
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0) {
            bstr[k--] = byte(uint8(48 + i % 10));
            i /= 10;
        }
        return string(bstr);
    }

    function bytes32ToString(bytes32 x) internal pure returns (string memory) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    function bytesToUInt(bytes32 b) internal pure returns (uint256){
        uint256 number;
        for(uint i=0;i<b.length;i++){
            number = number + uint256(uint8(b[i]))*(2**(8*(b.length-(i+1))));
        }
        return number;
    }

}

contract ERC721 is Manageable, LockableToken, IERC721, IERC165 {
    using Strings for string;

    mapping(address => uint256) public balances;
    mapping(uint256 => address) public approved;
    mapping(address => mapping(address => bool)) private operators;
    mapping(uint256 => address) private tokenOwner;

    uint256 public totalSupply = 0;

    string private _tokenURI = "";

    string private tokenName = '';
    string private tokenSymbol = '';

    modifier onlyTokenOwner(uint256 _tokenId) {
        require(msg.sender == tokenOwner[_tokenId]);
        _;
    }

    function setName(string memory _name) public onlyManager {
        tokenName = _name;
    }

    function setSymbol(string memory _symbol) public onlyManager {
        tokenSymbol = _symbol;
    }

    function name() external view returns (string memory _name) {
        return tokenName;
    }

    function symbol() external view returns (string memory _symbol) {
        return tokenSymbol;
    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool) {
        return interfaceID == 0x5b5e139f || interfaceID == 0x80ac58cd;
    }

    function setBaseTokenURI(string memory _newTokenURI) public onlyManager {
        _tokenURI = _newTokenURI;
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        return tokenOwner[_tokenId];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public onlyNotLocked(_tokenId) {
        require(_to != address(0));
        require(_isApprovedOrOwner(msg.sender, _tokenId));

        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) public onlyNotLocked(_tokenId) {
        address owner = ownerOf(_tokenId);
        require(_approved != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        approved[_tokenId] = _approved;

        emit Approval(owner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) public {
        require(_operator != msg.sender);

        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operators[_owner][_operator];
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        return approved[_tokenId];
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }


    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function transfer(address _from, address _to, uint256 _tokenId) public onlyTokenOwner(_tokenId) onlyNotLocked(_tokenId) {
        require(_to != address(0));
        _transfer(_from, _to, _tokenId);
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from);

        delete approved[_tokenId];

        if (_from != address(0)) {
            balances[_from]--;
        } else {
            totalSupply++;
        }

        if (_to != address(0)) {
            balances[_to]++;
        }

        tokenOwner[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function _mint(uint256 _tokenId, address _owner) internal {
        _transfer(address(0), _owner, _tokenId);
    }

    function _burn(uint256 _tokenId) internal {
        _transfer(ownerOf(_tokenId), address(0), _tokenId);
    }


    function baseTokenURI() public view returns (string memory) {
        return _tokenURI;
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        return Strings.strConcat(
            baseTokenURI(),
            Strings.uint2str(_tokenId)
        );
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable {
        require(_isApprovedOrOwner(msg.sender, _tokenId));
        require(_to != address(0));

        IERC721Receiver receiver = IERC721Receiver(_to);

        _transfer(_from, _to, _tokenId);

        require(receiver.onERC721Received(msg.sender, _from, _tokenId, data) == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require(_isApprovedOrOwner(msg.sender, _tokenId));
        require(_to != address(0));

        IERC721Receiver receiver = IERC721Receiver(_to);

        _transfer(_from, _to, _tokenId);

        require(receiver.onERC721Received(msg.sender, _from, _tokenId, "") == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
    }

    function burn(uint256 _tokenId) public onlyManager {
        _burn(_tokenId);
    }


    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
}


contract Land is Manageable, ERC721 {

    struct Token {
        int64 x;
        int64 y;
        uint8 building;
        uint8 level;
        uint8 buildingType;
    }

    mapping(int => mapping(int => uint16)) public map;
    mapping(int => mapping(int => uint)) public buyPrice;
    mapping(int => mapping(int => uint256)) public mapReverse;

    Token[] public tokens;

    constructor() public {
        setSymbol("MCPL");
        setName("MCP Land");
        setBaseTokenURI("https://mcp3d.com/bnb/api/land/");
        tokens.push(Token(0, 0, 0, 0, 0));
    }

    function mint(address _owner, int64 _x, int64 _y) public onlyManager returns (uint256 _tokenId) {
        tokens.push(Token(_x, _y, 0, 0, 0));
        mapReverse[_x][_y] = tokens.length - 1;
        _mint(mapReverse[_x][_y], _owner);
        return tokens.length - 1;
    }

    function batchBuyPrice(
        int64[] memory _x,
        int64[] memory _y,
        uint[] memory _buyPrice
    ) public onlyManager {
        for(uint i = 0; i < _x.length; i++) {
            buyPrice[_x[i]][_y[i]] = _buyPrice[i];
        }
    }

    function batchMint(
        address[] memory _owner,
        int64[] memory _x,
        int64[] memory _y,
        uint8[] memory _building,
        uint8[] memory _buildingType,
        uint8[] memory _level,
        uint16[] memory _regionId,
        uint[] memory _buyPrices
    ) public onlyManager {
        for(uint i = 0; i < _owner.length; i++) {
            if(mapReverse[_x[i]][_y[i]] > 0) {
                continue;
            }
            tokens.push(Token(_x[i], _y[i], _building[i], _level[i], _buildingType[i]));
            mapReverse[_x[i]][_y[i]] = tokens.length - 1;
            map[_x[i]][_y[i]] = _regionId[i];
            buyPrice[_x[i]][_y[i]] = _buyPrices[i];
            _mint(mapReverse[_x[i]][_y[i]], _owner[i]);
        }
    }

    function batchMintHugeBuildings(
        address[] memory _owner,
        int64[] memory _x,
        int64[] memory _y,
        uint8[] memory _building,
        uint8[] memory _buildingType,
        uint8[] memory _type,
        uint16[] memory _regionId
    ) public onlyManager {
        for(uint i = 0; i < _owner.length; i++) {
            if(mapReverse[_x[i]][_y[i]] > 0) {
                continue;
            }

            if(_type[i] == 1) {
                tokens.push(Token(_x[i], _y[i], _building[i], 6, _buildingType[i]));

                mapReverse[_x[i]][_y[i]] = tokens.length - 1;
                map[_x[i]][_y[i]] = _regionId[i];

                mapReverse[_x[i] - 1][_y[i]] = tokens.length - 1;
                map[_x[i] - 1][_y[i]] = _regionId[i];

            } else if(_type[i] == 2) {
                tokens.push(Token(_x[i], _y[i], _building[i], 6, _buildingType[i]));

                mapReverse[_x[i]][_y[i]] = tokens.length - 1;
                map[_x[i]][_y[i]] = _regionId[i];

                mapReverse[_x[i]][_y[i] - 1] = tokens.length - 1;
                map[_x[i]][_y[i] - 1] = _regionId[i];

            } else if(_type[i] == 3) {
                tokens.push(Token(_x[i], _y[i], _building[i], 7, _buildingType[i]));

                mapReverse[_x[i]][_y[i]] = tokens.length - 1;
                map[_x[i]][_y[i]] = _regionId[i];


                mapReverse[_x[i]][_y[i] - 1] = tokens.length - 1;
                map[_x[i]][_y[i] - 1] = _regionId[i];

                mapReverse[_x[i] - 1][_y[i]] = tokens.length - 1;
                map[_x[i] - 1][_y[i]] = _regionId[i];

                mapReverse[_x[i] - 1][_y[i] - 1] = tokens.length - 1;
                map[_x[i] - 1][_y[i] - 1] = _regionId[i];

            }
            _mint(tokens.length - 1, _owner[i]);
        }
    }

    function burn(uint _tokenId) public onlyManager {
        _burn(_tokenId);
        delete mapReverse[tokens[_tokenId].x][tokens[_tokenId].y];
        delete tokens[_tokenId];
    }

    function ownerOfXY(int _x, int _y) public view returns (address) {
        return ownerOf(mapReverse[_x][_y]);
    }

    function setRegion(int64 _x, int64 _y, uint16 _region) public onlyManager {
        map[_x][_y] = _region;
    }

    function setCell(int64 _x, int64 _y, uint8 _building, uint8 _level, uint8 _typeId) public onlyManager returns (uint)  {
        require(mapReverse[_x][_y] > 0);

        Token storage _token = tokens[mapReverse[_x][_y]];

        _token.building = _building;
        _token.level = _level;
        _token.buildingType = _typeId;

        return mapReverse[_x][_y];
    }

    function setToken(uint _tokenId, uint8 _building, uint8 _level, uint8 _typeId) public onlyManager {
        Token storage _token = tokens[_tokenId];

        _token.building = _building;
        _token.level = _level;
        _token.buildingType = _typeId;
    }

    function setToken(int64 _x, int64 _y, uint _tokenId) public onlyManager {
        tokens[_tokenId] = Token(_x, _y, 0, 0, 0);
        mapReverse[_x][_y] = _tokenId;
    }

    function setBuyPrice(int64 _x, int64 _y, uint _buyPrice) public onlyManager {
        buyPrice[_x][_y] = _buyPrice;
    }

    function getCell(int64 _x, int64 _y) public view
    returns (
        uint8 buildingId,
        uint8 buildingLevel,
        uint8 buildingTypeId,
        uint16 regionId,
        uint tokenId
    ) {
        uint _tokenId = mapReverse[_x][_y];
        uint16 _regionId = map[_x][_y];
        return (tokens[_tokenId].building, tokens[_tokenId].level, tokens[_tokenId].buildingType, _regionId, _tokenId) ;
    }

    function getCellByToken(uint256 _tokenId) public view
    returns (
        uint8 buildingId,
        uint8 buildingLevel,
        uint8 buildingTypeId,
        uint16 regionId,
        uint tokenId
    ) {
        return getCell(tokens[_tokenId].x, tokens[_tokenId].y);
    }

    function getRegionId(int64 _x, int64 _y) public view returns (uint16 regionId) {
        return map[_x][_y];
    }

    function getRegionId(uint _tokenId) public view returns (uint16 regionId) {
        return map[tokens[_tokenId].x][tokens[_tokenId].y];
    }

    function getTokens(int64 _x, int64 _y, int _radius) public view returns (uint256[] memory tokenIds, uint256[] memory buyPrices, address payable[] memory owners) {
        tokenIds = new uint256[]((uint(_radius) * 2 + 1) ** 2 - 1);
        buyPrices = new uint256[]((uint(_radius) * 2 + 1) ** 2 - 1);
        owners = new address payable[]((uint(_radius) * 2 + 1) ** 2 - 1);
        uint i = 0;
        for (int xi = _x - _radius; xi <= _x + _radius; xi++) {
            for (int yi = _y - _radius; yi <= _y + _radius; yi++) {
                if (_x == xi && _y == yi) {
                    continue;
                }

                if (buyPrice[xi][yi] > 0) {
                    tokenIds[i] = mapReverse[xi][yi];
                    buyPrices[i] = buyPrice[xi][yi];
                    owners[i] = _addressToPayable(ownerOfXY(xi, yi));
                    i++;
                }
            }
        }
    }

    function buyLand(int64 _x, int64 _y, uint256 _buyPrice, address _owner) public onlyManager {
        require(map[_x][_y] > 0);
        mint(_owner, _x, _y);
        buyPrice[_x][_y] = _buyPrice;
    }

    function mergeCells(int64[] memory _x, int64[] memory _y, address _owner) public onlyManager returns (uint _baseTokenId) {
        int64[2] memory _max = [_x[0], _y[0]];

        for(uint i = 0; i < _x.length; i++) {
            require(ownerOfXY(_x[i], _y[i]) == _owner);
            require(tokens[mapReverse[_x[i]][_y[i]]].building == tokens[mapReverse[_x[0]][_y[0]]].building);
            require(tokens[mapReverse[_x[i]][_y[i]]].level == tokens[mapReverse[_x[0]][_y[0]]].level);
            if(_x[i] > _max[0]) {
                _max[0] = _x[i];
            }

            if(_y[i] > _max[1]) {
                _max[1] = _y[i];
            }
        }

        _baseTokenId = mapReverse[_max[0]][_max[1]];

        for(uint i = 0; i < _x.length; i++) {
            if(_baseTokenId != mapReverse[_x[i]][_y[i]]) {
                if(ownerOf(mapReverse[_x[i]][_y[i]]) != address(0)) {
                    _burn(mapReverse[_x[i]][_y[i]]);
                }
                mapReverse[_x[i]][_y[i]] = _baseTokenId;
            }
        }
    }

    function unmergeToken(uint _tokenId) public onlyManager {
        int64 _x = tokens[_tokenId].x;
        int64 _y = tokens[_tokenId].y;
        address _owner = ownerOf(_tokenId);

        while(true) {
            if(mapReverse[_x][_y] != _tokenId) {
                _x = tokens[_tokenId].x;
                _y--;
            }

            if(mapReverse[_x][_y] != _tokenId) {
                break;
            }

            if(_x != tokens[_tokenId].x || _y != tokens[_tokenId].y) {
                mint(_owner, _x, _y);
            }

            _x--;
        }
    }
}