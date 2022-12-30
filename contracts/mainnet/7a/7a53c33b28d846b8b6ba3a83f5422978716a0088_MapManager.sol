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

contract BnbBank is Manageable {

    function transferToAddress(address payable _to, uint256 _value) external onlyManager {
        require(_value <= address(this).balance);

        if(!_to.send(_value)) {
            emit FailedPayout(_to, _value);
        }
    }

    function() external payable {

    }
}

contract Banks is Manageable {

    uint public DEFAULT_REGION_DISTRIBUTION_PERIOD = 60;
    uint public DEFAULT_GLOBAL_DISTRIBUTION_PERIOD = 365;
    uint public PERIOD = 1 days; //86400;
    uint public INITIAL_PERIOD = now / PERIOD;

    mapping(uint => uint8) public regionDistributionPeriod;
    uint public globalDistributionPeriod;

    constructor() public  {

    }

    function addToRegionBank(uint _value, uint _region, uint8 _incomeType) public onlyManager {
        emit RegionIncome(_region, _value, _period(), _incomeType);
    }

    function addToGlobalBank(uint _value, uint8 _incomeType) public onlyManager {
        emit GlobalIncome(_value, _period(), _incomeType);
    }

    function setRegionDistribution(uint8 _distribution, uint _region) public onlyManager {
        require(_distribution >= 30 && _distribution <= 90);
        regionDistributionPeriod[_region] = _distribution;
        emit RegionDistributionPeriod(_region, _distribution);
    }

    function setGlobalDistribution(uint _distribution) public onlyManager {
        require(_distribution >= 90 && _distribution <= 365);
        globalDistributionPeriod = _distribution;
        emit GlobalDistributionPeriod(_distribution);
    }


    function _period() internal view returns (uint) {
        return now / PERIOD;
    }

    function currentPeriod() public view returns (uint) {
        return _period();
    }

    function getRegionDistributionPeriod(uint[] memory _regions) public view returns (uint[] memory _regional) {
        _regional = new uint[](_regions.length);

        for (uint i = 0; i < _regions.length; i++) {
            _regional[i] = regionDistributionPeriod[_regions[i]] > 0 ? regionDistributionPeriod[_regions[i]] : DEFAULT_REGION_DISTRIBUTION_PERIOD;
        }
    }

    function getGlobalDistributionPeriod() public view returns (uint _global) {
        return globalDistributionPeriod > 0 ? globalDistributionPeriod : DEFAULT_GLOBAL_DISTRIBUTION_PERIOD;
    }

    event GlobalDistributionPeriod(uint _distribution);
    event RegionDistributionPeriod(uint _region, uint8 _distribution);
    event GlobalIncome(uint _value, uint _period, uint8 _incomeType);
    event RegionIncome(uint _region, uint _value, uint _period, uint8 _incomeType);
}



contract Region is Manageable, ERC721 {

    Banks public BanksContract;

    struct RegionStruct {
        uint8 landPlotPrice;
        uint8 energyTax;
        uint8 productionTax;
        uint8 citizensTax;
        uint8 commercialTax;
        uint8 distributionPeriod;
        uint8 insuranceCommission;
    }

    uint8[2] public distributionPeriodLimit = [30, 90];
    uint8[2] public insuranceCommissionLimit = [1, 15];
    uint16[2] public productionMinMax = [100, 300];
    uint16[2] public constructionMinMax = [100, 400];


    mapping(uint256 => RegionStruct) public regions;
    mapping(uint256 => uint8[5]) public constructionTaxes;
    mapping(uint256 => uint256) public lastChange;
    uint256 changeCooldown = 30 days;

    constructor(

    ) public {
        setSymbol("MCPR");
        setName("MCP Region");
        setBaseTokenURI("https://mcp3d.com/bnb/api/region/");
    }

    function setChangeCooldown(uint256 _changeCooldown) public onlyManager {
        changeCooldown = _changeCooldown;
    }

    function setLastChange(uint256 _tokenId, uint256 _newCooldown) public onlyManager {
        lastChange[_tokenId] = _newCooldown;
    }

    function setBanksContract(address payable _banks) public onlyManager {
        BanksContract = Banks(_banks);
    }

    function setCooldown(uint256 _cooldown) public onlyManager {
        changeCooldown = _cooldown;
    }

    function mint(address _owner, uint256 _tokenId) public onlyManager returns (uint256) {
        _mint(_tokenId, _owner);
        regions[_tokenId] = RegionStruct(50, 50, 50, 50, 50, 60, 5);

        uint8[5] memory constructionTax;
        constructionTax = [uint8(50), 50, 50, 50, 50];
        constructionTaxes[_tokenId] = constructionTax;

        return _tokenId;
    }

    function setTaxes(
        uint256 _tokenId,
        uint8 landPlotPrice,
        uint8[5] memory constructionTax,
        uint8 energyTax,
        uint8 productionTax,
        uint8 citizensTax,
        uint8 commercialTax,
        uint8 distributionPeriod,
        uint8 insuranceCommission) public onlyTokenOwner(_tokenId)
    {
        require(lastChange[_tokenId] + changeCooldown <= now, 'st2');

        require(landPlotPrice >= 0 && landPlotPrice <= 100, 'st3');
        _setTaxes(_tokenId, landPlotPrice, constructionTax, energyTax, productionTax, citizensTax, commercialTax, distributionPeriod, insuranceCommission);
    }

    function adminSetTaxes(uint256 _tokenId,
        uint8 landPlotPrice,
        uint8[5] memory constructionTax,
        uint8 energyTax,
        uint8 productionTax,
        uint8 citizensTax,
        uint8 commercialTax,
        uint8 distributionPeriod,
        uint8 insuranceCommission) public onlyManager
    {
        _setTaxes(_tokenId, landPlotPrice, constructionTax, energyTax, productionTax, citizensTax, commercialTax, distributionPeriod, insuranceCommission);
    }


    function _setTaxes(
        uint256 _tokenId,
        uint8 landPlotPrice,
        uint8[5] memory constructionTax,
        uint8 energyTax,
        uint8 productionTax,
        uint8 citizensTax,
        uint8 commercialTax,
        uint8 distributionPeriod,
        uint8 insuranceCommission) internal
    {
        uint16 constructionSum = 0;
        for (uint i = 0; i < 5; i++) {
            require(constructionTax[i] >= 0 && constructionTax[i] <= 100, 'st4');
            constructionSum += constructionTax[i];
        }
        require(energyTax >= 0 && energyTax <= 100, 'st5');
        require(productionTax >= 0 && productionTax <= 100, 'st6');
        require(citizensTax >= 0 && citizensTax <= 100, 'st7');
        require(commercialTax >= 0 && commercialTax <= 100, 'st8');
        require(distributionPeriod >= distributionPeriodLimit[0] && distributionPeriod <= distributionPeriodLimit[1], 'st9');
        require(insuranceCommission >= insuranceCommissionLimit[0] && insuranceCommission <= insuranceCommissionLimit[1], 'st10');

        uint16 productionSum = uint16(energyTax) + uint16(productionTax) + uint16(citizensTax) + uint16(commercialTax);

        require(constructionSum >= constructionMinMax[0] && constructionSum <= constructionMinMax[1], 'st11');
        require(productionSum >= productionMinMax[0] && productionSum <= productionMinMax[1], 'st12');

        regions[_tokenId].landPlotPrice = landPlotPrice;
        regions[_tokenId].energyTax = energyTax;
        regions[_tokenId].productionTax = productionTax;
        regions[_tokenId].citizensTax = citizensTax;
        regions[_tokenId].commercialTax = commercialTax;
        regions[_tokenId].distributionPeriod = distributionPeriod;
        regions[_tokenId].insuranceCommission = insuranceCommission;

        constructionTaxes[_tokenId] = constructionTax;

        BanksContract.setRegionDistribution(distributionPeriod, _tokenId);

        lastChange[_tokenId] = now;

        emit RegionTaxesChanged(_tokenId);
    }

    function getConstructionTaxesByType(uint256 _tokenId, uint8 _typeId) public view returns (uint8) {
        if (_typeId == 1) {
            return constructionTaxes[_tokenId][2];
        }

        if (_typeId == 7 || _typeId == 5) {
            return constructionTaxes[_tokenId][1];
        }

        if (_typeId == 4 || _typeId == 6) {
            return constructionTaxes[_tokenId][3];
        }

        if (_typeId == 3) {
            return constructionTaxes[_tokenId][0];
        }

        if (_typeId == 8) {
            return constructionTaxes[_tokenId][4];
        }

        return 0;
    }

    function getConstructionTaxes(uint256 _tokenId) public view returns (uint8[5] memory) {
        return constructionTaxes[_tokenId];
    }

    function getInsuranceCommission(uint256 _tokenId) public view returns (uint8) {
        return regions[_tokenId].insuranceCommission;
    }

    function getAllTaxes(uint256 _tokenId) public view returns (uint8[7] memory) {
        return [
        regions[_tokenId].landPlotPrice, regions[_tokenId].energyTax, regions[_tokenId].productionTax,
        regions[_tokenId].citizensTax, regions[_tokenId].commercialTax, regions[_tokenId].distributionPeriod,
        regions[_tokenId].insuranceCommission
        ];
    }

    event RegionTaxesChanged(uint256 _tokenId);
}



contract UserBalance is Manageable {

    BnbBank bnbBankContract;

    mapping (address => uint256) public userBalance;

    constructor(address payable _bnbBank) public {
        bnbBankContract = BnbBank(_bnbBank);
    }

    function setBnbBank(address payable _bnbBank) public onlyManager {
        bnbBankContract = BnbBank(_bnbBank);
    }

    function addBalance(address user, uint256 value, uint8 transactionType, uint8 _incomeType) external onlyManager returns (uint256) {
        return _addBalance(user, value, transactionType, _incomeType);
    }

    function decBalance(address user, uint256 value, uint8 transactionType) public onlyManager returns (uint256) {
        return _decBalance(user, value, transactionType);
    }

    function _decBalance(address _user, uint _value, uint8 _transactionType) internal returns (uint){
        require(userBalance[_user] >= _value, "Insufficient balance");
        userBalance[_user] -= _value;

        emit DecBalance(_user, _value, _transactionType);
        return userBalance[_user];
    }

    function _addBalance(address _user, uint _value, uint8 _transactionType, uint8 _incomeType) internal returns (uint){
        userBalance[_user] += _value;
        emit AddBalance(_user, _value, _transactionType, _incomeType);
        return userBalance[_user];
    }


    function getBalance(address user) public view returns (uint256) {
        return userBalance[user];
    }

    function userWithdrawal() public {
        require(false);
    }

    function store() external payable {
        address(bnbBankContract).transfer(msg.value);
    }

    function beneficiaryTransfer(uint _value) public onlyManager {
        if(_value > 0) {
            bnbBankContract.transferToAddress(beneficiary, _value);
            emit BeneficiaryPayout(_value);
        }
    }

    event UserWithdrawalDone(address user, uint256 value);

    event AddBalance(address user, uint256 value, uint8 transactionType, uint8 _incomeType);
    event DecBalance(address user, uint256 value, uint8 transactionType);

    function () external payable {
    }

}

contract Buildings is Manageable {
    struct BuildingLimits {
        uint8 maxCitizen;
        uint8 minCitizen;
        uint8 maxCar;
        uint8 maxAppliance;
        uint8 maxHelicopters;
    }

    struct Fees {
        uint256 fedFee;
        uint256 distFee;
    }

    struct Requirements {
        uint8 resourceId; //water/sand...
        uint256 amount;
    }

    mapping(uint8 => uint8) public buildingTypes; // buildingId => typeId
    uint256[7] public buildingPrices; // price[lvl1, lvl2, ...]
    mapping(uint8 => mapping(uint8 => Requirements[])) public buildingResourcesRequirements; // buildingTypeId => level => [Requirements, ...]


    mapping(uint8 => uint256) public resourcesFees; // typeOfResource => Fee
    mapping(uint8 => mapping(uint8 => Requirements[])) public resourcesProductionRequirements; // typeOfResource => level => [Requirements, ...]

    uint256 public appliancesFee;
    mapping(uint8 => Requirements[]) public appliancesProductionRequirements; // level => [Requirements, ...]

    mapping(uint8 => Requirements[]) public citizensProductionRequirements; // level => [Requirements, ...]
    Requirements[] public officeCollectRequirements; // [Requirements, ...]
    Requirements[] public municipalCollectRequirements; // [Requirements, ...]

    mapping(uint16 => BuildingLimits[8]) public buildingLimits; // typeId => BuildingLimits[1..7lvl]

    uint256 public staminaRestoreFee;
    uint256 staminaRestorePrice;

    uint256[8] public residentialFees;
    mapping(uint8 => uint8[2]) public residentialPercents; // level => [min, max]

    mapping(uint8 => uint16[10]) public buildingCarTypes; // buildingId => carTypeId

    function addBuildingPrices(uint256[7] memory price) public onlyManager {
        buildingPrices = price;
    }

    function setResourcesRequirements(
        uint8[] memory typeIds, uint8[] memory levels, uint8[] memory resTypeIds, uint256[] memory resAmounts
    ) public onlyManager {
        uint8 lastTypeId = 0;
        for (uint256 i = 0; i < typeIds.length; i ++) {
            if (lastTypeId != typeIds[i]) {
                delete buildingResourcesRequirements[typeIds[i]][levels[i]];
                lastTypeId = typeIds[i];
            }

            buildingResourcesRequirements[typeIds[i]][levels[i]].push(
                Requirements(
                    uint8(resTypeIds[i]),
                    resAmounts[i]
                )
            );
        }
    }

    function getResourcesRequirements(uint8 typeId, uint8 level)
    public view returns (uint8[] memory reqTypes, uint256[] memory reqAmounts) {
        if (buildingResourcesRequirements[typeId][level].length > 0) {
            reqTypes = new uint8[](buildingResourcesRequirements[typeId][level].length);
            reqAmounts = new uint256[](buildingResourcesRequirements[typeId][level].length);
            for (uint i = 0; i < buildingResourcesRequirements[typeId][level].length; i++) {
                reqTypes[i] = buildingResourcesRequirements[typeId][level][i].resourceId;
                reqAmounts[i] = buildingResourcesRequirements[typeId][level][i].amount;
            }
        }
    }

    function getResourcesRequirementsSum(uint8 typeId, uint8 maxLevel)
    public view returns (uint[10] memory resources) {
        for (uint8 _level = 1; _level <= maxLevel; _level++) {
            if (buildingResourcesRequirements[typeId][_level].length > 0) {
                for (uint i = 0; i < buildingResourcesRequirements[typeId][_level].length; i++) {
                    resources[buildingResourcesRequirements[typeId][_level][i].resourceId] += buildingResourcesRequirements[typeId][_level][i].amount;
                }
            }
        }
    }

    function addBuildings(uint8[] memory buildingIds, uint8[] memory typeIds) public onlyManager {
        for (uint256 i = 0; i < buildingIds.length; i++) {
            buildingTypes[buildingIds[i]] = typeIds[i];
        }
    }

    function setBuildingLimit(
        uint8 typeId, uint8[8] memory maxCitizens, uint8[8] memory minCitizens,
        uint8[8] memory maxCars, uint8[8] memory maxAppliances, uint8[8] memory maxHelicopters
    ) public onlyManager {
        for (uint8 level = 1; level < 8; level++) {
            buildingLimits[typeId][level] = BuildingLimits(
                maxCitizens[level],
                minCitizens[level],
                maxCars[level],
                maxAppliances[level],
                maxHelicopters[level]
            );
        }
    }

    function setResourcesProduction(
        uint8 resourceId, uint8 level,
        uint256[] memory requirements
    ) public onlyManager {
        delete resourcesProductionRequirements[resourceId][level];
        for (uint256 i = 0; i < requirements.length; i += 2) {
            resourcesProductionRequirements[resourceId][level].push(
                Requirements(
                    uint8(requirements[i]),
                    requirements[i + 1]
                )
            );
        }
    }

    function setAppliancesProduction(
        uint8 level, uint256[] memory requirements
    ) public onlyManager {
        delete appliancesProductionRequirements[level];
        for (uint256 i = 0; i < requirements.length; i += 2) {
            appliancesProductionRequirements[level].push(
                Requirements(
                    uint8(requirements[i]),
                    requirements[i + 1]
                )
            );
        }
    }

    function setCitizensProduction(
        uint8[] memory levels, uint8[] memory resTypeIds, uint256[] memory resAmounts
    ) public onlyManager {
        for (uint256 i = 1; i < levels.length; i ++) {
            delete citizensProductionRequirements[levels[i]];

            citizensProductionRequirements[levels[i]].push(
                Requirements(
                    uint8(resTypeIds[i]),
                    uint256(resAmounts[i])
                )
            );
        }
    }

    function setOfficeCollectRequirements(uint8[] memory resTypeIds, uint256[] memory resAmounts
    ) public onlyManager {
        delete officeCollectRequirements;
        for (uint256 i = 0; i < resTypeIds.length; i ++) {
            officeCollectRequirements.push(
                Requirements(
                    uint8(resTypeIds[i]),
                    uint256(resAmounts[i])
                )
            );
        }
    }

    function setMunicipalCollectRequirements(uint8[] memory resTypeIds, uint256[] memory resAmounts
    ) public onlyManager {
        delete municipalCollectRequirements;
        for (uint256 i = 0; i < resTypeIds.length; i ++) {
            municipalCollectRequirements.push(
                Requirements(
                    uint8(resTypeIds[i]),
                    uint256(resAmounts[i])
                )
            );
        }
    }

    function setResourcesFees(
        uint8[] memory resourceIds, uint256[] memory fedFees
    ) public onlyManager {
        for (uint i = 0; i < resourceIds.length; i++) {
            resourcesFees[resourceIds[i]] = fedFees[i];
        }

    }

    function setAppliancesFee(
        uint256 fee
    ) public onlyManager {
        appliancesFee = fee;
    }

    function getResourcesProductionRequirements(
        uint8 resourceId, uint8 level
    )
    public view returns (
        uint8[] memory reqTypes,
        uint256[] memory reqAmounts
    ) {
        reqTypes = new uint8[](resourcesProductionRequirements[resourceId][level].length);
        reqAmounts = new uint[](resourcesProductionRequirements[resourceId][level].length);

        for (uint256 i = 0; i < resourcesProductionRequirements[resourceId][level].length; i++) {
            reqTypes[i] = resourcesProductionRequirements[resourceId][level][i].resourceId;
            reqAmounts[i] = resourcesProductionRequirements[resourceId][level][i].amount;
        }
    }

    function getAppliancesProductionInfo(
        uint8 level
    )
    public view returns (
        uint8[] memory reqTypes,
        uint256[] memory reqAmounts
    ) {
        reqTypes = new uint8[](appliancesProductionRequirements[level].length);
        reqAmounts = new uint[](appliancesProductionRequirements[level].length);

        for (uint256 i = 0; i < appliancesProductionRequirements[level].length; i++) {
            reqTypes[i] = appliancesProductionRequirements[level][i].resourceId;
            reqAmounts[i] = appliancesProductionRequirements[level][i].amount;
        }
    }

    function getCitizensProductionInfo(
        uint8 level
    )
    public view returns (
        uint8[] memory reqTypes,
        uint256[] memory reqAmounts
    ) {
        reqTypes = new uint8[](citizensProductionRequirements[level].length);
        reqAmounts = new uint[](citizensProductionRequirements[level].length);

        for (uint256 i = 0; i < citizensProductionRequirements[level].length; i++) {
            reqTypes[i] = citizensProductionRequirements[level][i].resourceId;
            reqAmounts[i] = citizensProductionRequirements[level][i].amount;
        }
    }

    function setStaminaRestoreFee(
        uint256 price, uint256 fee
    ) public onlyManager {
        staminaRestoreFee = fee;
        staminaRestorePrice = price;
    }

    function getStaminaRestorePrices() public view returns (uint256 fee, uint256 pricePerPoint) {
        fee = staminaRestoreFee;
        pricePerPoint = staminaRestorePrice;
    }

    function setResidentialFees(
        uint256[8] memory fees
    ) public onlyManager {
        residentialFees = fees;
    }

    function setBuildingCarTypes(
        uint8[] memory buildingIds, uint16[5][] memory carTypes
    ) public onlyManager {
        for (uint i = 0; i < buildingIds.length; i++) {
            buildingCarTypes[buildingIds[i]] = carTypes[i];
        }

    }

    function isAuthorizedCar(uint8 buildingId, uint16 carType) public view returns (bool) {
        for (uint i = 0; i < buildingCarTypes[buildingId].length; i++) {
            if(buildingCarTypes[buildingId][i] == carType) {
                return true;
            }
        }

        return false;
    }


    function getResidentialInfo(uint8 _buildingLevel) public view returns (uint8[2] memory info) {
        info[0] = residentialPercents[_buildingLevel][0];
        info[1] = residentialPercents[_buildingLevel][1];
    }

    function getBuildingTypeId(uint8 _buildingId) public view returns (uint8) {
        return buildingTypes[_buildingId];
    }

    function getOfficeCollectResources(uint256 _factor)
    public view returns (
        uint8[] memory reqTypes,
        uint256[] memory reqAmounts
    ) {
        reqTypes = new uint8[](officeCollectRequirements.length);
        reqAmounts = new uint[](officeCollectRequirements.length);

        for (uint256 i = 0; i < officeCollectRequirements.length; i++) {
            reqTypes[i] = officeCollectRequirements[i].resourceId;
            reqAmounts[i] = officeCollectRequirements[i].amount * _factor;
        }
    }

    function getMunicipalCollectResources(uint256 _factor)
    public view returns (
        uint8[] memory reqTypes,
        uint256[] memory reqAmounts
    ) {
        reqTypes = new uint8[](municipalCollectRequirements.length);
        reqAmounts = new uint[](municipalCollectRequirements.length);

        for (uint256 i = 0; i < municipalCollectRequirements.length; i++) {
            reqTypes[i] = municipalCollectRequirements[i].resourceId;
            reqAmounts[i] = municipalCollectRequirements[i].amount * _factor;
        }
    }
}

contract BuildingImprovements is Manageable {

    mapping(uint256 => uint8) public appliancesCount;
    mapping(uint256 => uint8) public appliancesInfluence;
    mapping(uint256 => uint256) public buildingVersion;

    function setCitizens(uint256 _tokenId) external onlyManager returns (uint256) {
        return increaseVersion(_tokenId);
    }

    function removeCitizens(uint256 _tokenId) external onlyManager returns (uint256) {
        return increaseVersion(_tokenId);
    }

    function setCar(uint256 _tokenId) external onlyManager returns (uint256) {
        return increaseVersion(_tokenId);
    }

    function removeCar(uint256 _tokenId) external onlyManager returns (uint256) {
        return increaseVersion(_tokenId);
    }

    function setAppliances(uint256 _tokenId, uint8 _power) external onlyManager {
        require(appliancesCount[_tokenId] < 3, "Appliances limit");
        appliancesCount[_tokenId]++;
        appliancesInfluence[_tokenId] += _power;
    }

    function removeAppliances(uint256 _tokenId) external onlyManager {
        appliancesCount[_tokenId] = 0;
        appliancesInfluence[_tokenId] = 0;
    }

    function getApplianceInfluence(uint256 _tokenId) public view returns (uint8) {
        return appliancesInfluence[_tokenId];
    }


    function clearBuilding(uint256 _tokenId) external onlyManager {
        increaseVersion(_tokenId);
    }

    function increaseVersion(uint256 _tokenId) public onlyManager returns (uint256) {
        buildingVersion[_tokenId]++;
        return buildingVersion[_tokenId];
    }

    function getVersion(uint256 _tokenId) public view returns (uint256) {
        return buildingVersion[_tokenId];
    }
}

contract Verifier is Manageable {

    mapping(address => bool) signers;

    constructor() public {
    }

    function addSigner(address _signer) public onlyManager {
        signers[_signer] = true;
    }

    function removeSigner(address _signer) public onlyManager {
        signers[_signer] = false;
    }
    /**
    * @dev Recover signer address from a message by using their signature
    * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
    * @param sig bytes signature, the signature is generated using web3.eth.sign(). Inclusive "0x..."
    */
    function verifySignature(bytes32 hash, bytes memory sig) public view returns (address) {
        require(sig.length == 65, "Require correct length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        // Divide the signature in r, s and v variables
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Signature version not match");

        address addr = ecrecover(hash, v, r, s);
        require(signers[addr], 'Invalid signature');

        return addr;
    }
}
contract MapManager is Manageable {

    Land public LandContract;
    UserBalance public UserBalanceContract;
    Buildings public BuildingsContract;
    Region public RegionContract;
    Banks public BanksContract;
    Verifier public VerifierContract;

    uint8 public divider = 8;
    uint256 public royalty = 0.007 ether;
    uint256 public basePrice = 0.035 ether;

    uint256 public basePriceCoef = 75;
    uint256 public maxPriceCoef = 150;
    uint256 public developerPart = 50;
    uint256 public regionOwnerPart = 50;

    modifier onlyLandOwner(int64 _x, int64 _y) {
        require(LandContract.ownerOfXY(_x, _y) == msg.sender, "Only land owner");
        _;
    }

    constructor(
        address payable _land,
        address payable _userBalance,
        address payable _buildings,
        address payable _region,
        address payable _banks,
        address payable _verifier
    ) public {
        LandContract = Land(_land);
        UserBalanceContract = UserBalance(_userBalance);
        BuildingsContract = Buildings(_buildings);
        RegionContract = Region(_region);
        BanksContract = Banks(_banks);
        VerifierContract = Verifier(_verifier);
    }

    function setPriceCoef(uint256 _base, uint256 _max) public onlyManager {
        basePriceCoef = _base;
        maxPriceCoef = _max;
    }

    function setLandContract(address payable _address) public onlyManager {
        LandContract = Land(_address);
    }

    function setUserBalanceContract(address payable _address) public onlyManager {
        UserBalanceContract = UserBalance(_address);
    }

    function setBuildingsContract(address payable _address) public onlyManager {
        BuildingsContract = Buildings(_address);
    }

    function setRegionContract(address payable _address) public onlyManager {
        RegionContract = Region(_address);
    }

    function setBanksContract(address payable _address) public onlyManager {
        BanksContract = Banks(_address);
    }

    function getLandPriceWithRegion(int64 _x, int64 _y, uint16 _regionId) public view returns (uint256) {
        (,,,, uint _tokenId) = LandContract.getCell(_x, _y);

        require(_tokenId == 0, 'glp1');

        (uint256 landValue, uint8 tokensBought) = getPrice(_x, _y);

        (uint landPlotPrice,,,,,,) = RegionContract.regions(_regionId);

        uint256 royaltyValue = basePrice + (uint(tokensBought) ** 2) * royalty;
        uint256 taxValue = regionLandPlotTaxValue(landPlotPrice, tokensBought);

        return landValue + royaltyValue + taxValue;
    }

    function buyLandSigned(int64 _x, int64 _y, uint16 _regionId, uint8 _resources, bytes memory _signature) public payable {
        (,,,uint16 _existingRegionId, uint _tokenId) = LandContract.getCell(_x, _y);
        require(_tokenId == 0, "Land cant be sold");

        bytes32 message = keccak256(abi.encode(_x, _y, _regionId, _resources));
        VerifierContract.verifySignature(
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message)),
            _signature
        );

        if (_existingRegionId == 0) {
            LandContract.setRegion(_x, _y, _regionId);
            _existingRegionId = _regionId;
        }

        _buy(_x, _y, _existingRegionId, msg.sender, msg.sender, msg.value);

    }

    function _buy(int64 _x, int64 _y, uint16 _regionId, address payable _sender, address payable _for, uint256 _value) internal {

        (uint256 landValue, uint8 tokensBought) = getPrice(_x, _y);
        (uint landPlotPrice,,,,,,) = RegionContract.regions(_regionId);

        uint256 royaltyValue = basePrice + (uint(tokensBought) ** 2) * royalty;
        uint256 taxValue = regionLandPlotTaxValue(landPlotPrice, tokensBought);

        uint256 _totalValue = landValue + royaltyValue + taxValue;

        require(_totalValue > 0 && _value >= _totalValue, "Value is not enough");

        LandContract.mint(_for, _x, _y);
        LandContract.setBuyPrice(_x, _y, _totalValue);

        _payout(_x, _y);
        _regionPayout(_regionId, taxValue, 0);

        if (_value > _totalValue) {
            _sender.transfer(_value - _totalValue);
        }

        UserBalanceContract.store.value(_totalValue - royaltyValue)();
        beneficiaryPayout(royaltyValue);
    }

    function getPrice(int64 _x, int64 _y) public view returns (uint256 value, uint8 tokensBought) {

        (uint256[] memory tokenIds, uint256[] memory buyPrices,) = LandContract.getTokens(_x, _y, 3);

        for (uint8 _i = 0; _i < tokenIds.length; _i++) {
            if (tokenIds[_i] > 0) {
                value += (buyPrices[_i] / divider);
                tokensBought++;
            }
        }
    }

    function activateHugeBuilding(int64 _x, int64 _y, uint8 _type) public {
        int64[] memory _xList = new int64[](2);
        int64[] memory _yList = new int64[](2);

        _xList[0] = _x;
        _yList[0] = _y;
        _xList[1] = _type == 1 ? _x - 1 : _x;
        _yList[1] = _type == 2 ? _y - 1 : _y;

        LandContract.setCell(_xList[0], _yList[0], 0, 0, 0);
        LandContract.setCell(_xList[1], _yList[1], 0, 0, 0);

        LandContract.mergeCells(_xList, _yList, msg.sender);

        emit BigBuildingActivated(_x, _y, _type);
    }

    function activateMegaBuilding(int64 _x, int64 _y, uint8 _type) public {
        int64[] memory _xList = new int64[](4);
        int64[] memory _yList = new int64[](4);

        _xList[0] = _x;
        _yList[0] = _y;

        _xList[1] = _x - 1;
        _yList[1] = _y;

        _xList[2] = _x;
        _yList[2] = _y - 1;

        _xList[3] = _x - 1;
        _yList[3] = _y - 1;

        LandContract.setCell(_xList[0], _yList[0], 0, 0, 0);
        LandContract.setCell(_xList[1], _yList[1], 0, 0, 0);
        LandContract.setCell(_xList[2], _yList[2], 0, 0, 0);
        LandContract.setCell(_xList[3], _yList[3], 0, 0, 0);

        LandContract.mergeCells(_xList, _yList, msg.sender);

        emit BigBuildingActivated(_x, _y, _type);
    }

    function bigDemolition(int64 _x, int64 _y, uint8 _buildingId, bytes memory _signature) public payable {
        bytes32 message = keccak256(abi.encode(_x, _y, _buildingId));
        VerifierContract.verifySignature(
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message)),
            _signature
        );

        require(LandContract.ownerOfXY(_x, _y) == msg.sender, 'Only owner');

        (,,,
        uint16 _regionId,
        uint _tokenId) = LandContract.getCell(_x, _y);

        require(!LandContract.isLocked(_tokenId));

        LandContract.unmergeToken(_tokenId);

        (uint256 _fp, uint256 _tax, uint256 _developerFee, uint256 _regionOwnerFee) = getBuildPrice(_buildingId, uint8(1), _regionId);

        uint256 _fullPrice = _fp / 2;
        _tax = _tax / 2;
        _developerFee = _developerFee / 2;
        _regionOwnerFee = _regionOwnerFee / 2;

        require(_fullPrice > 0 && _fullPrice <= msg.value, 'r2');
        _regionPayout(_regionId, _regionOwnerFee, 1);

        if (_tax > 0) {
            BanksContract.addToGlobalBank(_tax, 102);
            BanksContract.addToRegionBank(_tax, _regionId, 102);
        }

        UserBalanceContract.store.value(_fullPrice - _developerFee)();
        UserBalanceContract.beneficiaryTransfer(_developerFee);

        emit BigDemolition(
            _tokenId,
            _fullPrice
        );
    }

    function _addToBalance(address _to, uint256 _value, uint8 _reason) internal {
        if (_value > 0) {
            UserBalanceContract.addBalance(_to, _value, _reason, 0);
        }
    }

    function getBuildPrices(uint8[] memory buildingIds, uint8 buildingLevel, uint16 regionId)
    public view returns (uint256[] memory fullPrice, uint256[] memory tax, uint256[] memory developerFee, uint256[] memory regionOwnerFee){
        fullPrice = new uint256[](buildingIds.length);
        tax = new uint256[](buildingIds.length);
        developerFee = new uint256[](buildingIds.length);
        regionOwnerFee = new uint256[](buildingIds.length);
        for (uint i; i < buildingIds.length; i++) {
            (fullPrice[i], tax[i], developerFee[i], regionOwnerFee[i]) = _getBuildPrice(buildingIds[i], buildingLevel, regionId);
        }
    }

    function getBuildPrice(uint8 _buildingId, uint8 _buildingLevel, uint16 _regionId)
    public view returns (uint256 fullPrice, uint256 tax, uint256 developerFee, uint256 regionOwnerFee)
    {
        return _getBuildPrice(_buildingId, _buildingLevel, _regionId);
    }

    function _getBuildPrice(uint8 _buildingId, uint8 _buildingLevel, uint16 _regionId)
    internal view returns (uint256 fullPrice, uint256 tax, uint256 developerFee, uint256 regionOwnerFee)
    {
        uint8 constructionTax = RegionContract.getConstructionTaxesByType(_regionId, BuildingsContract.getBuildingTypeId(_buildingId));

        uint256 baseBuildingPrice = BuildingsContract.buildingPrices(_buildingLevel - 1);
        tax = baseBuildingPrice * (basePriceCoef + ((maxPriceCoef * uint(constructionTax)) / 100)) / 100;
        developerFee = tax * developerPart / 100;
        regionOwnerFee = tax * regionOwnerPart / 100;

        fullPrice = tax + tax + developerFee + regionOwnerFee;
    }

    function setFeeParts(uint _developerPart, uint _regionOwnerPart) public onlyManager {
        require(_developerPart + _regionOwnerPart == 100);
        developerPart = _developerPart;
        regionOwnerPart = _regionOwnerPart;
    }

    function regionLandPlotTaxValue(
        uint _tax, uint8 _cnt
    ) internal view returns (uint256) {
        return (
        (basePrice * _tax) / 100
        ) +
        (
        (
        (uint(_cnt) ** 2) * royalty * _tax
        ) / 100
        );
    }

    function _payout(int64 _x, int64 _y) internal {
        (uint256[] memory tokenIds, uint256[] memory buyPrices, address payable[] memory owners) = LandContract.getTokens(_x, _y, 3);

        for (uint i = 0; i < owners.length; i++) {
            if (tokenIds[i] > 0 && owners[i] != address(0)) {
                _addToBalance(
                    owners[i],
                    buyPrices[i] / divider,
                    0
                );

                emit LandPayout(owners[i], tokenIds[i], buyPrices[i] / divider, _x, _y);
            }
        }
    }

    function _regionPayout(uint16 _regionId, uint256 _value, uint8 _payoutType) internal {
        address _owner = RegionContract.ownerOf(_regionId);
        if (_owner != address(0) && _value > 0) {
            _addToBalance(_owner, _value, 1);
            emit RegionPayout(_owner, _regionId, _value, _payoutType);
        }
    }

    event LandPayout(address indexed owner, uint indexed _tokenId, uint256 _value, int64 _x, int64 _y);
    event RegionPayout(address indexed owner, uint indexed tokenId, uint256 value, uint8 _payoutType);
    event BigDemolition(uint256 indexed _tokenId, uint256 _fullPrice);
    event BigBuildingActivated(int64 _x, int64 _y, uint8 _type);
}