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

library Strings {

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

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
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
        uint8 resourceId;
        uint256 amount;
    }

    mapping(uint8 => uint8) public buildingTypes;
    uint256[7] public buildingPrices;
    mapping(uint8 => mapping(uint8 => Requirements[])) public buildingResourcesRequirements;


    mapping(uint8 => uint256) public resourcesFees;
    mapping(uint8 => mapping(uint8 => Requirements[])) public resourcesProductionRequirements;

    uint256 public appliancesFee;
    mapping(uint8 => Requirements[]) public appliancesProductionRequirements;

    mapping(uint8 => Requirements[]) public citizensProductionRequirements;
    Requirements[] public officeCollectRequirements;
    Requirements[] public municipalCollectRequirements;

    mapping(uint16 => BuildingLimits[8]) public buildingLimits;

    uint256 public staminaRestoreFee;
    uint256 staminaRestorePrice;

    uint256[8] public residentialFees;
    mapping(uint8 => uint8[2]) public residentialPercents;

    mapping(uint8 => uint16[10]) public buildingCarTypes;

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


interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract MBe is IERC20, Manageable {

}

contract MegaBank is Manageable {
    MBe public mbe;
    constructor(
        address payable _mbe

    ) public {
        mbe = MBe(_mbe);
    }

    function setMBeContract(address payable _mbe) public onlyManager {
        mbe = MBe(_mbe);
    }

    function transferFromAddress(address _sender, uint _amount) external onlyManager {
        require(_amount > 0);
        require(mbe.transferFrom(_sender, address(this), _amount));
    }

    function transferToAddress(address payable _to, uint256 _value) external onlyManager {
        require(_value <= mbe.balanceOf(address(this)));

        require(mbe.transfer(_to, _value));
    }

    function emergencyWithdrawERC20(uint _amount) public onlyOwner {
        require(mbe.transfer(owner, _amount));
    }

    function() external payable {

    }
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

    ) public {}

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

contract Car is Manageable, ERC721 {


    mapping(uint256 => uint16) public carType;

    constructor() public   {

    }

    function mint(address _owner, uint16 _carId) public onlyManager returns (uint256){
        carType[totalSupply] = _carId;
        _mint(totalSupply, _owner);
        return totalSupply - 1;
    }
}

contract Citizen is Manageable, ERC721 {

    struct Token {
        uint8[7] special;
        uint8 generation;
        bytes32 look;
    }

    Token[] public tokens;

    constructor() public {
    }

    function mint(address _owner, uint8[7] memory _special, uint8 _generation, bytes32 _look) public onlyManager returns (uint256){
        tokens.push(Token(_special, _generation, _look));
        _mint(tokens.length - 1, _owner);
        return tokens.length - 1;
    }

    function incSpecial(uint256 _tokenId, uint8 _specId) public onlyManager {
        require(_specId < 8 && tokens[_tokenId].special[_specId] < 12);

        emit SpecChanged(_tokenId, _specId, tokens[_tokenId].special[_specId]);
    }

    function decSpecial(uint256 _tokenId, uint8 _specId) public onlyManager {
        require(_specId < 8 && tokens[_tokenId].special[_specId] > 0);

        tokens[_tokenId].special[_specId]--;
        emit SpecChanged(_tokenId, _specId, tokens[_tokenId].special[_specId]);
    }

    function getSpecial(uint256 _tokenId) public view returns (uint8[7] memory) {
        return tokens[_tokenId].special;
    }

    function setLook(uint256 _tokenId, bytes32 _look) public onlyManager {
        tokens[_tokenId].look = _look;
    }

    function setLookBytes(uint256 _tokenId, byte[] memory value, uint8[] memory position) public onlyManager {
        for(uint256 i = 0; i < value.length; i++) {
            tokens[_tokenId].look = _setByte(tokens[_tokenId].look, position[i], value[i]);
        }

        emit LookChanged(_tokenId, tokens[_tokenId].look);
    }

    function setLookByte(uint256 _tokenId, byte value, uint8 position) public onlyManager {
        tokens[_tokenId].look = _setByte(tokens[_tokenId].look, position, value);
        emit LookChanged(_tokenId, tokens[_tokenId].look);
    }

    function _setByte(bytes32 _bt, uint8 position, byte value) internal pure returns (bytes32) {
        uint256 _c = uint256(_bt);

        return bytes32((_c & ~(0xFF * (uint256(2) ** position))) | (uint8(value) * (uint256(2) ** position)));
    }

    event LookChanged(uint256 _tokenId, bytes32 _look);
    event SpecChanged(uint256 _tokenId, uint8 _specId, uint8 _value);
}

contract Appliance is Manageable, ERC721 {

    struct Token {
        uint8 applianceType;
        uint16 status;
    }

    Token[] public tokens;

    constructor() public {
    }

    function mintWithStatus(address _owner, uint8 _applianceType, uint16 _status) public onlyManager returns (uint256) {
        tokens.push(Token(_applianceType, _status));
        _mint(tokens.length - 1, _owner);
        return tokens.length - 1;
    }

    function setApplianceStatus(uint256 _tokenId, uint16 _newStatus) public onlyManager {
        tokens[_tokenId].status = _newStatus;
    }

    function mint(address _owner, uint8 _applianceType) public onlyManager returns (uint256){
        tokens.push(Token(_applianceType, 1000));
        _mint(tokens.length - 1, _owner);
        return tokens.length - 1;
    }
}

contract ResourcesToken is Manageable, ERC721 {

    struct ResourceBatch {
        uint8 kind;
        uint256 amount;
        bool presale;
    }

    ResourceBatch[] public tokens;

    uint256[3] public presaleAmount;

    function mintPresalePack(address _owner, uint8 _kind, uint8 _size) public onlyManager {
        tokens.push(ResourceBatch(_kind, _size, true));
        _mint(tokens.length - 1, _owner);
    }

    function mintPack(address _owner, uint8 _kind, uint256 _amount) public onlyManager {
        tokens.push(ResourceBatch(_kind, _amount, false));
        _mint(tokens.length - 1, _owner);
    }

}

contract Resources is Manageable {

    ResourcesToken public resourceContract;

    mapping(uint8 => uint[3]) public presalePackAmount;

    mapping(address => mapping(uint8 => uint256)) public resources;

    constructor(address payable _resourceToken) public{
        resourceContract = ResourcesToken(_resourceToken);

    }

    function addResources(address _user, uint8 _kind, uint256 _resources) public onlyManager {
        _addResources(_user, _kind, _resources);
    }

    function setPresalePackAmount(uint8 _kind, uint[3] memory _sizes) public onlyManager {
        presalePackAmount[_kind] = _sizes;
    }

    function _addResources(address _user, uint8 _kind, uint256 _resources) internal {
        resources[_user][_kind] += _resources;
        emit AddResources(_user, _kind, _resources);
    }
    function decResources(address _user, uint8[] memory _kinds, uint256[] memory _resources) public onlyManager {
        _decResourcesBatch(_user, _kinds, _resources);
    }

    function _decResourcesBatch(address _user, uint8[] memory _kinds, uint256[] memory _resources) internal {
        for (uint i = 0; i < _kinds.length; i++) {
            require(resources[_user][_kinds[i]] >= _resources[i]);
        }

        for (uint i = 0; i < _kinds.length; i++) {
            resources[_user][_kinds[i]] -= _resources[i];
        }
    }

    function _decResources(address _user, uint8 _kind, uint _amount) internal {
        require(resources[_user][_kind] >= _amount);
        resources[_user][_kind] -= _amount;
        emit DecResources(_user, _kind, _amount);
    }

    function getResources(address _user, uint8[] memory _kinds) public view returns (uint[] memory userResources) {
        userResources = new uint[](_kinds.length);
        for (uint i = 0; i < _kinds.length; i++) {
            userResources[i] = resources[_user][_kinds[i]];
        }
    }

    function packResources(uint8 _kind, uint256 _amount) public {
        require(resources[msg.sender][_kind] >= _amount);
        _decResources(msg.sender, _kind, _amount);

        resourceContract.mintPack(msg.sender, _kind, _amount);

        emit PackResources(msg.sender, resourceContract.totalSupply() - 1, _kind, _amount);
    }

    function unpackResources(uint256 _tokenId) public {
        require(!resourceContract.locks(_tokenId));
        require(resourceContract.ownerOf(_tokenId) == msg.sender);
        (uint8 _kind, uint _amount, bool _presale) = resourceContract.tokens(_tokenId);

        resourceContract.burn(_tokenId);


        if(_presale) {
            _amount = presalePackAmount[_kind][_amount - 1];
        }

        _addResources(msg.sender, _kind, _amount);

        emit UnpackResources(msg.sender, _tokenId, _kind, _amount);
    }

    event DecResources(address _user, uint8 _resourceId, uint _value);
    event AddResources(address _user, uint8 _resourceId, uint _value);
    event PackResources(address _user, uint256 _tokenId, uint8 _resourceId, uint _value);
    event UnpackResources(address _user, uint256 _tokenId, uint8 _resourceId, uint _value);
}

contract Random is Manageable {

    uint256 public _usedSeeds = 0;

    constructor() public {
    }

    function mintInternalSeeds(uint256[] memory _iS) public onlyManager {
    }

    function addSeedBytes(bytes memory _sB) public onlyManager {
    }


    function getRandom(uint256 _seed, uint256 max) public returns (uint256) {
        return 0;
    }

    function getSomeSeed(uint256 _seed) public view returns (uint256) {
        return 0;
    }
}

contract BuildingProduction is Manageable {

    Land public LandContract;
    Citizen public CitizenContract;
    Car public CarContract;
    Buildings public BuildingsContract;
    BuildingImprovements public BuildingImprovementsContract;
    Resources public ResourcesContract;
    Appliance public ApplianceContract;
    BuildingRentals public BuildingRentalsContract;
    Verifier public VerifierContract;
    Random private RandomContract;
    Region private RegionContract;
    Banks private BanksContract;
    UserBalance private userBalanceContract;

    uint256 MAX_RAND = 10e20;
    uint FACE = 0;
    uint HAIR = 1;
    uint NOSE = 2;
    uint EYES = 3;
    uint ACCESSORIES = 4;
    uint LIPS = 5;
    uint BEARD = 6;
    uint BROWS = 7;

    uint8[8] maxLooksMale;
    uint8[8] maxLooksFemale;

    uint256 public basePriceCoef = 100;
    uint256 public maxPriceCoefResidential = 40;
    uint256 public maxPriceCoefResources = 100;
    uint256 public maxPriceCoefStamina = 100;
    uint256 public developerPart = 50;
    uint256 public regionOwnerPart = 50;

    uint8 WATER_RESOURCE_ID = 7;
    uint8 ELECTRICITY_RESOURCE_ID = 8;

    uint32[8] public resourcesCooldown;
    uint32[8] public appliancesCooldown;
    uint32[4] public residentialsCooldowns;

    uint16[10][8] public speedUpCoefs;

    constructor(
        address payable _land,
        address payable _buildings,
        address payable _buildingImprovements,
        address payable _buildingRentals,
        address payable _verifier,
        address payable _random,
        address payable _region,
        address payable _banks,
        address payable _userBalance
    ) public  {
        LandContract = Land(_land);
        BuildingsContract = Buildings(_buildings);
        BuildingImprovementsContract = BuildingImprovements(_buildingImprovements);
        BuildingRentalsContract = BuildingRentals(_buildingRentals);
        VerifierContract = Verifier(_verifier);
        RandomContract = Random(_random);
        RegionContract = Region(_region);
        BanksContract = Banks(_banks);
        userBalanceContract = UserBalance(_userBalance);

        maxLooksMale[FACE] = 5;
        maxLooksMale[HAIR] = 63;
        maxLooksMale[NOSE] = 10;
        maxLooksMale[EYES] = 28;
        maxLooksMale[ACCESSORIES] = 6;
        maxLooksMale[LIPS] = 18;
        maxLooksMale[BEARD] = 12;
        maxLooksMale[BROWS] = 12;

        maxLooksFemale[FACE] = 5;
        maxLooksFemale[HAIR] = 56;
        maxLooksFemale[NOSE] = 10;
        maxLooksFemale[EYES] = 31;
        maxLooksFemale[ACCESSORIES] = 7;
        maxLooksFemale[LIPS] = 13;
        maxLooksFemale[BEARD] = 0;
        maxLooksFemale[BROWS] = 12;
    }

    modifier checkOwner(uint256 _tokenId) {
        require(msg.sender == BuildingRentalsContract.getRenterOrOwner(_tokenId), "Not owned");
        _;
    }

    function setBasePriceCoef(uint256 _basePriceCoef) public onlyManager  {
        basePriceCoef = _basePriceCoef;
    }

    function setMaxPriceCoefResidential(uint256 _maxPriceCoefResidential) public onlyManager  {
        maxPriceCoefResidential = _maxPriceCoefResidential;
    }

    function setmaxPriceCoefResources(uint256 _maxPriceCoefResources) public onlyManager  {
        maxPriceCoefResources = _maxPriceCoefResources;
    }

    function setMaxPriceCoefStamina(uint256 _maxPriceCoefStamina) public onlyManager  {
        maxPriceCoefStamina = _maxPriceCoefStamina;
    }

    function setCitizenContract(address payable _address) public onlyManager {
        CitizenContract = Citizen(_address);
    }

    function setCarContract(address payable _address) public onlyManager {
        CarContract = Car(_address);
    }

    function setApplianceContract(address payable _address) public onlyManager {
        ApplianceContract = Appliance(_address);
    }

    function setResourcesContract(address payable _address) public onlyManager {
        ResourcesContract = Resources(_address);
    }

    function setCooldown(uint32[8] memory _resourcesCooldown, uint32[8] memory _appliancesCooldown, uint32[4] memory _residentialsCooldowns) public onlyManager {
        resourcesCooldown = _resourcesCooldown;
        appliancesCooldown = _appliancesCooldown;
        residentialsCooldowns = _residentialsCooldowns;
    }

    function setSpeedUpCoefs(uint16[10][8] memory _coefs) public onlyManager {
        speedUpCoefs = _coefs;
    }

    function getResourceProductionPrice(uint256 _tokenId, uint8 _resourceId, uint _regionId, uint16 _daysLeft)
    public view returns (uint256[5] memory _prices)
    {
        (,uint8 _energyTax,uint8 _productionTax,,,,) = RegionContract.regions(_regionId);
        ( ,uint8 _buildingLevel,,,) = LandContract.getCellByToken(_tokenId);

        uint coef = 1;
        if(_daysLeft > 0) {
            coef = speedUpCoefs[_buildingLevel][_daysLeft];
        }

        uint8 _tax = _resourceId == WATER_RESOURCE_ID || _resourceId == ELECTRICITY_RESOURCE_ID ? _energyTax : _productionTax;
        uint256 _fee;

        if (_resourceId > 0) {
            _fee = BuildingsContract.resourcesFees(_resourceId);
        } else {
            _fee = BuildingsContract.appliancesFee();
        }

        _prices[1] = _fee * (basePriceCoef + (maxPriceCoefResources * uint(_tax) / 100)) / 100;
        _prices[1] = _prices[1] * coef;

        _prices[2] = _prices[1] * developerPart / 100;
        _prices[3] = _prices[1] * regionOwnerPart / 100;

        _prices[0] = _prices[1] + _prices[1] + _prices[2] + _prices[3];
    }

    function resourceProduction(address _address, uint256 _tokenId, uint8 _resourceId, uint32 _count, uint16 _daysLeft, uint256 _buildingVersion, bytes memory _signature) payable public checkOwner(_tokenId) {
        bytes32 _hash = hash(keccak256(abi.encode(msg.sender, _tokenId, _resourceId, _count, _daysLeft, _buildingVersion)));

        VerifierContract.verifySignature(_hash, _signature);
        require(_address == msg.sender, "Address error");
        require(BuildingImprovementsContract.buildingVersion(_tokenId) == _buildingVersion, "Version error");
        _resourceProduction(_tokenId, _resourceId, _count, _daysLeft);
    }

    function _resourceProduction(uint256 _tokenId, uint8 _resourceId, uint32 _count, uint16 _daysLeft) internal {
        uint8[2] memory _bInfo;
        uint16 _regionId;

        (_bInfo[1], _bInfo[0],, _regionId,) = LandContract.getCellByToken(_tokenId);
        _bInfo[1] = BuildingsContract.buildingTypes(_bInfo[1]);

        uint256[5] memory _prices = getResourceProductionPrice(_tokenId, _resourceId, _regionId, _daysLeft);

        require(msg.value >= _prices[0], "not enough money");

        _resourceProductionResourcesSpend(_resourceId, _bInfo[0], msg.sender);

        _priceTransfer(_prices, _regionId, address(0), _bInfo[1]);

        ResourcesContract.addResources(msg.sender, _resourceId, _count);

        emit ResourceProduced(msg.sender, _tokenId, _resourceId, _count, now, _prices[0], BuildingImprovementsContract.increaseVersion(_tokenId), _daysLeft > 0);
    }

    function _resourceProductionResourcesSpend(uint8 _resourceId, uint8 _buildingLevel, address _sender) internal {
        (uint8[] memory _reqTypes, uint256[] memory _reqAmounts) = BuildingsContract.getResourcesProductionRequirements(_resourceId, _buildingLevel);

        if (_reqTypes.length > 0) {
            uint256[] memory userResources = ResourcesContract.getResources(_sender, _reqTypes);
            for (uint256 i = 0; i < _reqTypes.length; i++) {
                if (_reqTypes[i] == 0) break;
                require(_reqAmounts[i] <= userResources[i], "not enough resources");
            }
        }

        if (_reqTypes.length > 0) {
            ResourcesContract.decResources(_sender, _reqTypes, _reqAmounts);
        }
    }

    function getApplianceProductionPrice(uint _tokenId, uint _regionId, uint16 _daysLeft)
    public view returns (uint256[5] memory)
    {
        return getResourceProductionPrice(_tokenId, 0, _regionId, _daysLeft);
    }

    function applianceProduction(address _address, uint256 _tokenId, uint8 _typeId, uint16 _daysLeft, uint256 _buildingVersion, bytes memory _signature) payable public checkOwner(_tokenId) {
        require(_typeId > 0);
        bytes32 _hash = hash(keccak256(abi.encode(msg.sender, _tokenId, _typeId, _daysLeft, _buildingVersion)));
        VerifierContract.verifySignature(_hash, _signature);
        require(_address == msg.sender, "Address error");
        require(BuildingImprovementsContract.buildingVersion(_tokenId) == _buildingVersion, "Version error");

        _applianceProduction(_tokenId, _typeId, _daysLeft);
    }

    function _applianceProduction(uint256 _tokenId, uint8 _typeId, uint16 _daysLeft) internal {
        //0 uint8 _buildingLevel, 1 uint8 buildingTypeId, 2 minCitizens
        uint8[3] memory _bInfo;
        uint16 _regionId;

        (_bInfo[1], _bInfo[0], , _regionId,) = LandContract.getCellByToken(_tokenId);
        _bInfo[1] = BuildingsContract.buildingTypes(_bInfo[1]);

        uint256[5] memory _prices = getApplianceProductionPrice(_tokenId, _regionId, _daysLeft);
        require(msg.value >= _prices[0], "not enough money");

        _applianceProductionResourcesSpend(_bInfo[0], msg.sender);

        _priceTransfer(_prices, _regionId, address(0), _bInfo[1]);

        emit ApplianceProduced(msg.sender, _tokenId, ApplianceContract.mint(msg.sender, _typeId), _typeId, now, _prices[0], BuildingImprovementsContract.increaseVersion(_tokenId), _daysLeft > 0);
    }

    function _applianceProductionResourcesSpend(uint8 _buildingLevel, address _sender) internal {
        (uint8[] memory reqTypes, uint256[] memory reqAmounts) = BuildingsContract.getAppliancesProductionInfo(_buildingLevel);

        if (reqTypes.length > 0) {
            uint256[] memory userResources = ResourcesContract.getResources(_sender, reqTypes);
            for (uint256 i = 0; i < reqTypes.length; i++) {
                if (reqTypes[i] == 0) break;
                require(reqAmounts[i] <= userResources[i], "not enough resources");
            }
        }

        if (reqTypes.length > 0) {
            ResourcesContract.decResources(_sender, reqTypes, reqAmounts);
        }
    }

    function getCitizensProductionPrice(uint _regionId, uint8 _buildingLevel)
    public view returns (uint256[5] memory _prices)
    {
        (,,,uint8 _citizensTax,,,) = RegionContract.regions(_regionId);

        uint256 _fedFee = BuildingsContract.residentialFees(_buildingLevel);
        _prices[1] = _fedFee * 2 * (basePriceCoef / 2 + (maxPriceCoefResidential * _citizensTax) / 100) / 100;
        _prices[2] = _prices[1] * developerPart / 100;
        _prices[3] = _prices[1] * regionOwnerPart / 100;

        _prices[0] = _prices[1] + _prices[1] + _prices[2] + _prices[3];
    }

    function citizensProduction(address _address, uint256 _tokenId, uint32 _amount, uint8[7] memory _specials,
        uint8[5] memory _info,
        uint256 _buildingVersion, bytes memory _signature
    ) payable public checkOwner(_tokenId) {
        bytes32 _hash = hash(keccak256(abi.encode(msg.sender, _tokenId, _amount, _specials, _info, _buildingVersion)));
        VerifierContract.verifySignature(_hash, _signature);
        require(_address == msg.sender, "Address error");
        require(BuildingImprovementsContract.buildingVersion(_tokenId) == _buildingVersion, "Version error");

        (uint256[10] memory _newTokenIds, uint256 _fullPrice) = _citizensProduction(_tokenId, _amount, _specials, _info);
        _citizenSendEvent(_tokenId, _newTokenIds, _fullPrice);
    }

    function _citizenSendEvent(uint256 _tokenId, uint256[10] memory _newTokenIds, uint256 _fullPrice) internal {
        emit CitizensProduced(msg.sender, _tokenId, _newTokenIds, now, _fullPrice, BuildingImprovementsContract.increaseVersion(_tokenId));
    }

    function _citizensProduction(uint256 _tokenId, uint32 _amount, uint8[7] memory _specials, uint8[5] memory _info) internal returns (uint256[10] memory _newTokenIds, uint256 _fullPrice) {

        (uint8 _buildingId, uint8 _buildingLevel, ,uint16 _regionId,) = LandContract.getCellByToken(_tokenId);
        uint8 _buildingTypeId = BuildingsContract.buildingTypes(_buildingId);

        uint256[5] memory _prices = getCitizensProductionPrice(_regionId, _buildingLevel);
        require(msg.value >= _prices[0], "not enough money");

        (uint8[] memory reqTypes, uint256[] memory reqAmounts) = BuildingsContract.getCitizensProductionInfo(_buildingLevel);

        if (reqTypes.length > 0) {
            uint256[] memory userResources = ResourcesContract.getResources(msg.sender, reqTypes);
            for (uint256 i = 0; i < reqTypes.length; i++) {
                if (reqTypes[i] == 0) break;
                require(reqAmounts[i] <= userResources[i], "not enough resources");
            }
        }

        if (reqTypes.length > 0) {
            ResourcesContract.decResources(msg.sender, reqTypes, reqAmounts);
        }

        _priceTransfer(_prices, _regionId, address(0), _buildingTypeId);

        _newTokenIds = _mintCitizen(_amount, _specials, _buildingLevel, _info);
        _fullPrice = _prices[0];
    }


    function _mintCitizen(uint32 _amount, uint8[7] memory _specials, uint8, uint8[5] memory _info) internal returns (uint256[10] memory _newTokenIds) {


        uint8[7] memory _newSpecials;
        for (uint8 a = 0; a < _amount; a++) {
            uint256 seed = RandomContract.getRandom(block.number + uint(a), MAX_RAND);
            for (uint8 i = 1; i < 7; i++) {
                seed = seed / 100;

                uint32 tmp = uint32(_specials[i] * (_info[0] + ((seed % 100) * (_info[1] - _info[0])) / 100));

                if (tmp < 1000) {
                    tmp = 1000;
                }

                if (tmp % 1000 >= 500) {
                    tmp += 1000;
                }

                if (tmp > 10000) {
                    tmp = 10000;
                }

                _newSpecials[i] = uint8(tmp / 1000);
            }

            _newTokenIds[a] = CitizenContract.mint(msg.sender, _newSpecials, _info[2], genLook(seed, _info[3]));
        }
    }

    function getCitizenCooldown(uint8[5] memory _info) public view returns (uint32) {
        return residentialsCooldowns[0] + (
        (residentialsCooldowns[1] - _info[4]) * residentialsCooldowns[2]
        * ((residentialsCooldowns[1] - _info[4]) * 10) / residentialsCooldowns[3]
        ) * 6;
    }

    function getStaminaRestorePrices(uint256 _points, uint256 _regionId, uint256 _factor)
    public view returns (uint256[5] memory _prices)
    {
        (,,,,uint8 _commercialTax,,) = RegionContract.regions(_regionId);
        if(_factor < 1) {
            _factor = 1;
        }

        (uint256 _fee, uint256 _pricePerPoint) = BuildingsContract.getStaminaRestorePrices();

        _prices[1] = _factor * (_fee * (basePriceCoef + (maxPriceCoefStamina * _commercialTax / 100)) / 100);
        _prices[2] = _prices[1] * developerPart / 100;
        _prices[3] = _prices[1] * regionOwnerPart / 100;
        _prices[4] = _factor * (_pricePerPoint * _points);

        _prices[0] = _prices[1] + _prices[1] + _prices[2] + _prices[3] + _prices[4];
    }

    function staminaRestore(address _address, uint256 _tokenId, uint256[] memory _citizenIds, uint32 _points, uint256[] memory _landIds, uint256 _buildingVersion, bytes memory _signature) payable public {
        bytes32 _hash = hash(keccak256(abi.encode(msg.sender, _tokenId, _citizenIds, _points, _landIds, _buildingVersion)));
        VerifierContract.verifySignature(_hash, _signature);
        require(_address == msg.sender, "Address error");
        require(BuildingImprovementsContract.buildingVersion(_tokenId) == _buildingVersion, "Version error");

        (,, ,uint16 _regionId,) = LandContract.getCellByToken(_tokenId);

        uint256[5] memory _prices = getStaminaRestorePrices(_points, uint(_regionId), _citizenIds.length);
        require(msg.value >= _prices[0], "not enough money");

        for(uint i = 0; i < _citizenIds.length; i++) {
            address _citizenOwner = CitizenContract.ownerOf(_citizenIds[i]);
            require(_citizenOwner != address(0), "null citizen address");

            emit StaminaRestored(msg.sender, _tokenId, _citizenIds[i], _points, _prices[0] / _citizenIds.length, _prices[4] / _citizenIds.length, _landIds[i], now);
        }

        _priceTransfer(_prices, _regionId, BuildingRentalsContract.getRenterOrOwner(_tokenId), 4);
    }

    function _priceTransfer(uint256[5] memory _prices, uint16 _regionId, address _landOwner, uint8 _incomeType) internal {
        require(msg.value >= _prices[0], "Not enough value");

        if (msg.value > _prices[0] && !msg.sender.send(msg.value - _prices[0])) {
            emit FailedPayout(msg.sender, msg.value - _prices[0]);
        }

        if (_prices[3] + _prices[1] * 2 + _prices[4] > 0) {
            userBalanceContract.store.value(_prices[3] + _prices[1] * 2 + _prices[4])();
        }

        address _owner = RegionContract.ownerOf(_regionId);
        if (_owner != address(0) && _prices[3] > 0) {
            userBalanceContract.addBalance(_owner, _prices[3], 0, _incomeType);
            emit RegionPayout(_owner, _regionId, _prices[3], 0, _incomeType);
        }

        if (_prices[1] > 0) {
            BanksContract.addToGlobalBank(_prices[1], _incomeType);
            BanksContract.addToRegionBank(_prices[1], _regionId, _incomeType);
        }

        if(_prices[4] > 0 && _landOwner != address(0)) {
            userBalanceContract.addBalance(_landOwner, _prices[4], 0, _incomeType);
        }

        beneficiaryPayout(_prices[2]);
    }

    function genLook(uint256 _seed, uint8 _fid) internal view returns (bytes32 look) {

    }

    function changeAvatar(bytes32 _look, uint256[5] memory _prices, uint _citizenId, uint _landId, bytes memory _signature) public payable {

    }

    function _getKeccak(uint256 _seed) internal pure returns (uint256) {
        return 0;
    }

    function setLastAction(uint _tokenId, uint _time) external onlyManager returns (uint256) {
        return 0;
    }

    function selectResources(uint _tokenId, uint _resourceId) public checkOwner(_tokenId) {
        emit selectResourcesEvent(_tokenId, _resourceId, now);
    }

    function hash(bytes32 message) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(message));
    }

    event ResourceProduced(address _owner, uint256 _tokenId, uint8 _resourceId, uint32 _amount, uint256 _now, uint _fullPrice, uint _buildingVersion, bool _speedUp);
    event ApplianceProduced(address _owner, uint256 _tokenId, uint256 _applianceId, uint8 _typeId, uint256 _now, uint _fullPrice, uint _buildingVersion, bool _speedUp);
    event StaminaRestored(address _owner, uint256 _tokenId, uint256 _citizenId, uint32 _points, uint256 _price, uint256 _ownerPrice,  uint256 _landId, uint256 _now);
    event CitizensProduced(address _owner, uint256 _tokenId, uint256[10] _newTokenIds, uint256 _now, uint _fullPrice, uint _buildingVersion);
    event RegionPayout(address _owner, uint indexed tokenId, uint256 value, uint8 _payoutType, uint8 _incomeType);
    event selectResourcesEvent(uint256 _tokenId, uint _resourceId, uint256 _now);

    event CitizenLookChanged(uint _citizenId, bytes32 _look, uint _fullPrice, uint _ownerPrice, uint _landId);
    event BuildingVersionChanged(uint _tokenId, uint _buildingVersion);
}

contract BuildingManagement is Manageable {

    Land public LandContract;
    Citizen public CitizenContract;
    Buildings public BuildingsContract;
    BuildingImprovements public BuildingImprovementsContract;
    Car public CarContract;
    Appliance public ApplianceContract;
    BuildingRentals public BuildingRentalsContract;
    BuildingProduction public BuildingProductionContract;
    Verifier public VerifierContract;

    mapping(uint => uint8) public appliancePower;

    constructor(
        address payable _land,
        address payable _buildings,
        address payable _buildingImprovements,
        address payable _buildingRentals,
        address payable _buildingProduction,
        address payable _verifier
    ) public  {
        LandContract = Land(_land);
        BuildingsContract = Buildings(_buildings);
        BuildingImprovementsContract = BuildingImprovements(_buildingImprovements);
        BuildingRentalsContract = BuildingRentals(_buildingRentals);
        BuildingProductionContract = BuildingProduction(_buildingProduction);
        VerifierContract = Verifier(_verifier);

        appliancePower[1] = 25;
        appliancePower[2] = 15;
        appliancePower[3] = 5;
        appliancePower[4] = 10;
        appliancePower[5] = 40;
        appliancePower[6] = 45;
        appliancePower[7] = 50;
        appliancePower[8] = 30;
        appliancePower[9] = 35;
        appliancePower[10] = 20;
    }

    modifier checkOwner(uint256 _tokenId) {
        require(msg.sender == BuildingRentalsContract.getRenterOrOwner(_tokenId), "Not owned");
        _;
    }

    function setLandContract(address payable _address) public onlyManager {
        LandContract = Land(_address);
    }

    function setBuildingsContract(address payable _address) public onlyManager {
        BuildingsContract = Buildings(_address);
    }

    function setBuildingImprovementsContract(address payable _address) public onlyManager {
        BuildingImprovementsContract = BuildingImprovements(_address);
    }

    function setBuildingRentalsContract(address payable _address) public onlyManager {
        BuildingRentalsContract = BuildingRentals(_address);
    }

    function setBuildingProductionContract(address payable _address) public onlyManager {
        BuildingProductionContract = BuildingProduction(_address);
    }

    function setCitizenContract(address payable _address) public onlyManager {
        CitizenContract = Citizen(_address);
    }

    function setCarContract(address payable _address) public onlyManager {
        CarContract = Car(_address);
    }

    function setApplianceContract(address payable _address) public onlyManager {
        ApplianceContract = Appliance(_address);
    }

    function setCitizens(address _address, uint256 _tokenId, uint256[] memory _citizenIds, uint _version, bytes memory _signature) public checkOwner(_tokenId) {
        bytes32 _hash = hash(keccak256(abi.encode(msg.sender, _tokenId, _citizenIds, _version)));

        VerifierContract.verifySignature(_hash, _signature);
        require(_address == msg.sender);

        for (uint i = 0; i < _citizenIds.length; i++) {
            require(CitizenContract.ownerOf(_citizenIds[i]) == msg.sender);
        }

        _version = BuildingImprovementsContract.setCitizens(_tokenId);
        uint256 _lastAction = _setLastAction(_tokenId, now);

        for (uint i = 0; i < _citizenIds.length; i++) {
            emit BuildingImprovementsEvent(_tokenId, _citizenIds[i], 1 /* Appoint citizen*/, 0, _version, _lastAction);
        }
    }

    function removeCitizens(address _address, uint256 _tokenId, uint256[] memory _citizenIds, uint _version, bytes memory _signature) public checkOwner(_tokenId) {
        require(BuildingImprovementsContract.getVersion(_tokenId) == _version);
        bytes32 _hash = hash(keccak256(abi.encode(msg.sender, _tokenId, _citizenIds, _version)));

        VerifierContract.verifySignature(_hash, _signature);
        require(_address == msg.sender);

        for (uint i = 0; i < _citizenIds.length; i++) {
            require(CitizenContract.ownerOf(_citizenIds[i]) == msg.sender);
        }

        _version = BuildingImprovementsContract.removeCitizens(_tokenId);
        uint256 _lastAction = _setLastAction(_tokenId, now);

        for (uint i = 0; i < _citizenIds.length; i++) {
            emit BuildingImprovementsEvent(_tokenId, _citizenIds[i], 2 /* remove citizen*/, 0, _version, _lastAction);
        }
    }

    function setCar(address _address, uint256 _tokenId, uint256 _carId, uint _version, bytes memory _signature) public checkOwner(_tokenId) {
        require(BuildingImprovementsContract.getVersion(_tokenId) == _version);
        bytes32 _hash = hash(keccak256(abi.encode(msg.sender, _tokenId, _carId, _version)));

        VerifierContract.verifySignature(_hash, _signature);
        require(_address == msg.sender);

        //uint8 buildingId, uint8 _buildingLevel, uint8 buildingTypeId,  uint8 cellType, uint16 regionId, uint tokenId
        (uint8 buildingId,,,,) = LandContract.getCellByToken(_tokenId);

        require(CarContract.ownerOf(_carId) == msg.sender);

        uint16 carType = CarContract.carType(_carId);

        require(BuildingsContract.isAuthorizedCar(buildingId, carType), "Car unauthorized");

        emit BuildingImprovementsEvent(_tokenId, _carId, 3 /* set car */, uint8(carType), BuildingImprovementsContract.increaseVersion(_tokenId), 0);
    }

    function removeCar(address _address, uint256 _tokenId, uint256 _carId, uint256 _version, bytes memory _signature) public {
        require(BuildingImprovementsContract.getVersion(_tokenId) == _version);
        bytes32 _hash = hash(keccak256(abi.encode(msg.sender, _tokenId, _carId, _version)));

        VerifierContract.verifySignature(_hash, _signature);
        require(_address == msg.sender);

        require(CarContract.ownerOf(_carId) == msg.sender);
        uint16 carType = CarContract.carType(_carId);

        bool isHelicopter = false;
        if(carType >= 100) {
            isHelicopter = true;
        }

        emit BuildingImprovementsEvent(_tokenId, _carId, 4 /* remove car */, 0, BuildingImprovementsContract.increaseVersion(_tokenId), 0);
    }

    function setAppliance(uint256 _tokenId, uint256 _applianceId) public {
        require(LandContract.ownerOf(_tokenId) == msg.sender, "not owned 1");
        // Only real owner
        require(!BuildingRentalsContract.isInRental(_tokenId), "Rented");
        require(ApplianceContract.ownerOf(_applianceId) == msg.sender, "not owned 2");
        (uint8 applianceType,) = ApplianceContract.tokens(_applianceId);
        require(!ApplianceContract.locks(_applianceId));
        BuildingImprovementsContract.setAppliances(_tokenId, appliancePower[applianceType]);
        ApplianceContract.burn(_applianceId);

        emit BuildingImprovementsEvent(_tokenId, _applianceId, 5 /* set appliance */, applianceType, BuildingImprovementsContract.increaseVersion(_tokenId), 0);
    }

    function getAppliancePower(uint8 _type) internal view returns (uint8) {
        return appliancePower[_type];
    }

    function setAppliancePower(uint8 _type, uint8 _power) public onlyManager {
        appliancePower[_type] = _power;
    }

    function setLastAction(uint _tokenId, uint _time) public onlyManager returns (uint256) {
        return _setLastAction(_tokenId, _time);
    }

    function _setLastAction(uint _tokenId, uint _time) internal returns (uint256) {
        return BuildingProductionContract.setLastAction(_tokenId, _time);
    }

    function clearBuilding(uint256 _tokenId) external onlyManager {
        LandContract.unlockToken(_tokenId);
        BuildingImprovementsContract.clearBuilding(_tokenId);
        emit BuildingImprovementsEvent(_tokenId, 0, 6 /* remove all */, 0, BuildingImprovementsContract.increaseVersion(_tokenId), 0);

    }

    function hash(bytes32 message) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message));
    }

    event BuildingImprovementsEvent(uint256 _tokenId, uint256 _subTokenId, uint8 _action, uint8 _type, uint256 _buildingVersion, uint256 _now);
}


contract BuildingRentals is Manageable {
    Land public LandContract;
    BuildingImprovements public BuildingImprovementsContract;
    UserBalance public UserBalanceContract;
    BuildingManagement public BuildingManagementContract;
    Buildings public BuildingsContract;
    Banks public BanksContract;
    Region public RegionContract;

    uint256 public devFeePercent = 25; //2.5
    uint256 public districtOwnerFeePercent = 25; //2.5
    uint256 public regionalBankFeePercent = 25; //2.5
    uint256 public globalBankFeePercent = 25; //2.5


    struct RentalStruct {
        uint16 minDays;
        uint16 maxDays;
        uint256 pricePerDay;
        address renter;
        uint256 endOfRental;
        bool flag;
    }

    mapping(uint256 => RentalStruct) public rentals; // tokenId => RentalStruct

    constructor(
        address payable _land,
        address payable _buildingImprovements,
        address payable _userBalance,
        address payable _banks,
        address payable _region,
        address payable _buildings
    ) public {
        LandContract = Land(_land);
        BuildingImprovementsContract = BuildingImprovements(_buildingImprovements);
        UserBalanceContract = UserBalance(_userBalance);
        BanksContract = Banks(_banks);
        RegionContract = Region(_region);
        BuildingsContract = Buildings(_buildings);
    }

    function setPercents(uint256 _devFeePercent, uint256 _districtOwnerFeePercent, uint256 _regionalBankFeePercent, uint256 _globalBankFeePercent) public onlyManager {
        devFeePercent = _devFeePercent; // percent * 10
        districtOwnerFeePercent = _districtOwnerFeePercent;
        regionalBankFeePercent = _regionalBankFeePercent;
        globalBankFeePercent = _globalBankFeePercent;
    }

    function setBuildingManagement(address payable _buildingManagement) public onlyManager {
        BuildingManagementContract = BuildingManagement(_buildingManagement);
    }

    function setBuildingContract(address payable _buildings) public onlyManager {
        BuildingsContract = Buildings(_buildings);
    }

    function rentOut(uint256 _tokenId, uint16 _minDays, uint16 _maxDays, uint256 _pricePerDay) public {
        require(LandContract.ownerOf(_tokenId) == msg.sender, 'owner');
        require(!LandContract.isLocked(_tokenId), "Locked");
        require(!rentals[_tokenId].flag, 'flag');
        require(_minDays >= 1);
        require(_maxDays <= 365);

        (uint8 buildingId,,,,) = LandContract.getCellByToken(_tokenId);

        uint8 buildingTypeId = BuildingsContract.buildingTypes(buildingId);

        require(buildingId > 0);

        if(buildingTypeId == 4 || buildingTypeId == 6 || buildingTypeId == 8) {
            revert('buildingTypeId');
        }

        LandContract.lockToken(_tokenId);
        rentals[_tokenId] = RentalStruct(_minDays, _maxDays, _pricePerDay, address(0), 0, true);

        emit RentOut(_tokenId, _minDays, _maxDays, _pricePerDay);
    }

    function RemoveFromRental(uint256 _tokenId) public {
        require(LandContract.ownerOf(_tokenId) == msg.sender);
        require(rentals[_tokenId].flag);
        require(rentals[_tokenId].renter == address(0), "Rented");

        uint256 _pricePerDay = rentals[_tokenId].pricePerDay;
        delete rentals[_tokenId];
        LandContract.unlockToken(_tokenId);

        emit RentalRemove(_tokenId, _pricePerDay);
    }

    function isInRental(uint256 _tokenId) public view returns (bool) {
        return rentals[_tokenId].flag;
    }

    function rent(uint256 _tokenId, uint16 _days) public payable {
        require(rentals[_tokenId].flag, "1");
        require(rentals[_tokenId].renter == address(0), "Rented");
        require(_days >= rentals[_tokenId].minDays, "2");
        require(_days <= rentals[_tokenId].maxDays, "3");
        require(msg.value >= _days * rentals[_tokenId].pricePerDay, "not enough money");
        address _owner = LandContract.ownerOf(_tokenId);
        require(msg.sender != _owner, "4");

        rentals[_tokenId].renter = msg.sender;
        rentals[_tokenId].endOfRental = now + uint256(_days) * uint256(1 days);

        uint _price = _days * rentals[_tokenId].pricePerDay;
        uint _ownerPrice = (_price * (1000 - devFeePercent - districtOwnerFeePercent - regionalBankFeePercent - globalBankFeePercent)) / 1000;

        if (msg.value > _price && !msg.sender.send(msg.value - _price)) {
            emit FailedPayout(msg.sender, msg.value - _ownerPrice);
        }

        UserBalanceContract.addBalance(_owner, _ownerPrice, 8, 0);
        (,,,uint16 _regionId,) = LandContract.getCellByToken(_tokenId);

        BanksContract.addToGlobalBank(_price * globalBankFeePercent / 1000, 0);
        BanksContract.addToRegionBank(_price * regionalBankFeePercent / 1000, _regionId, 0);

        address _regionOwner = RegionContract.ownerOf(_regionId);
        if (_owner != address(0)) {
            UserBalanceContract.addBalance(_regionOwner, _price * districtOwnerFeePercent / 1000, 1, 0);
            emit RegionPayout(_owner, _regionId, _price * districtOwnerFeePercent / 1000, 2);
        }

        beneficiaryPayout(_price * devFeePercent / 1000);

        UserBalanceContract.store.value(_price - _price * devFeePercent / 1000)();

        emit Rental(_tokenId, rentals[_tokenId].renter, rentals[_tokenId].endOfRental, _price, _ownerPrice, _days, now);
    }

    function getRenterOrOwner(uint256 _tokenId) public view returns (address) {
        if (rentals[_tokenId].renter != address(0)) {
            require(rentals[_tokenId].endOfRental > now, "The rent is over");
            return rentals[_tokenId].renter;
        }

        if (rentals[_tokenId].flag) {
            return address(0);
        }

        return LandContract.ownerOf(_tokenId);
    }

    function rentalComplete(uint256 _tokenId) public {
        require(LandContract.ownerOf(_tokenId) == msg.sender || rentals[_tokenId].renter == msg.sender);
        require(rentals[_tokenId].renter != address(0));
        require(rentals[_tokenId].endOfRental < now, "Rental in progress");

        BuildingManagementContract.clearBuilding(_tokenId);
        BuildingManagementContract.setLastAction(_tokenId, now);
        rentals[_tokenId].renter = address(0);
        rentals[_tokenId].endOfRental = 0;

        emit RentalComplete(_tokenId, now);
    }

    event RentalComplete(uint256 _tokenId, uint256 _now);
    event RentOut(uint256 _tokenId, uint16 _minDays, uint16 _maxDays, uint256 _pricePerDay);
    event RentalRemove(uint256 _tokenId, uint256 _pricePerDay);
    event Rental(uint256 _tokenId, address _renter, uint256 _endOfRental, uint _price, uint _ownerPrice, uint16 _days, uint256 _now);
    event RegionPayout(address _owner, uint indexed tokenId, uint256 value, uint8 _payoutType);
}


contract NewBuildingRentals is Manageable {
    Land public LandContract;
    UserBalance public UserBalanceContract;
    Buildings public BuildingsContract;
    Banks public BanksContract;
    Region public RegionContract;
    Verifier public VerifierContract;

    uint256 public devFeePercent = 25; //2.5
    uint256 public districtOwnerFeePercent = 25; //2.5
    uint256 public regionalBankFeePercent = 25; //2.5
    uint256 public globalBankFeePercent = 25; //2.5


    struct RentalStruct {
        uint16 minDays;
        uint16 maxDays;
        uint256 pricePerDay;
        address renter;
        uint256 endOfRental;
        bool flag;
    }

    mapping(uint256 => RentalStruct) public rentals; // tokenId => RentalStruct

    constructor(
        address payable _land,
        address payable _userBalance,
        address payable _banks,
        address payable _region,
        address payable _verifier
    ) public {
        LandContract = Land(_land);
        UserBalanceContract = UserBalance(_userBalance);
        BanksContract = Banks(_banks);
        RegionContract = Region(_region);
        VerifierContract = Verifier(_verifier);
    }

    function setPercents(uint256 _devFeePercent, uint256 _districtOwnerFeePercent, uint256 _regionalBankFeePercent, uint256 _globalBankFeePercent) public onlyManager {
        devFeePercent = _devFeePercent; // percent * 10
        districtOwnerFeePercent = _districtOwnerFeePercent;
        regionalBankFeePercent = _regionalBankFeePercent;
        globalBankFeePercent = _globalBankFeePercent;
    }

    function setVerifierContract(address payable _verifier) public onlyManager {
        VerifierContract = Verifier(_verifier);
    }

    function rentOut(address _address, uint256 _tokenId, uint16 _minDays, uint16 _maxDays, uint256 _pricePerDay, uint8 _buildingTypeId, bytes memory _signature) public {
        bytes32 message = keccak256(abi.encode(_address, _tokenId, _minDays, _maxDays, _pricePerDay, _buildingTypeId));
        VerifierContract.verifySignature(
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message)),
            _signature
        );

        require(LandContract.ownerOf(_tokenId) == msg.sender);
        require(!LandContract.isLocked(_tokenId), "Locked");
        require(!rentals[_tokenId].flag, 'flag');
        require(_minDays >= 1);
        require(_maxDays <= 365);

        if(_buildingTypeId == 0 || _buildingTypeId == 4 || _buildingTypeId == 6 || _buildingTypeId == 8) {
            revert();
        }

        LandContract.lockToken(_tokenId);
        rentals[_tokenId] = RentalStruct(_minDays, _maxDays, _pricePerDay, address(0), 0, true);

        emit RentOut(_tokenId, _minDays, _maxDays, _pricePerDay);
    }

    function RemoveFromRental(uint256 _tokenId) public {
        require(LandContract.ownerOf(_tokenId) == msg.sender);
        require(rentals[_tokenId].flag);
        require(rentals[_tokenId].renter == address(0), "Rented");

        uint256 _pricePerDay = rentals[_tokenId].pricePerDay;
        rentals[_tokenId].flag = false;

        LandContract.unlockToken(_tokenId);

        emit RentalRemove(_tokenId, _pricePerDay);
    }

    function isInRental(uint256 _tokenId) public view returns (bool) {
        if(rentals[_tokenId].minDays > 0) {
            return rentals[_tokenId].flag;
        }

        return false;
    }

    function rent(uint256 _tokenId, uint16 _days) public payable {
        require(rentals[_tokenId].flag, "1");
        require(rentals[_tokenId].renter == address(0), "Rented");
        require(_days >= rentals[_tokenId].minDays, "2");
        require(_days <= rentals[_tokenId].maxDays, "3");
        require(msg.value >= _days * rentals[_tokenId].pricePerDay, "not enough money");
        address _owner = LandContract.ownerOf(_tokenId);
        require(msg.sender != _owner, "4");

        rentals[_tokenId].renter = msg.sender;
        rentals[_tokenId].endOfRental = now + uint256(_days) * uint256(1 days);

        uint _price = _days * rentals[_tokenId].pricePerDay;
        uint _ownerPrice = (_price * (1000 - devFeePercent - districtOwnerFeePercent - regionalBankFeePercent - globalBankFeePercent)) / 1000;

        if (msg.value > _price && !msg.sender.send(msg.value - _price)) {
            emit FailedPayout(msg.sender, msg.value - _ownerPrice);
        }

        UserBalanceContract.addBalance(_owner, _ownerPrice, 8, 0);
        (,,,uint16 _regionId,) = LandContract.getCellByToken(_tokenId);

        BanksContract.addToGlobalBank(_price * globalBankFeePercent / 1000, 0);
        BanksContract.addToRegionBank(_price * regionalBankFeePercent / 1000, _regionId, 0);

        address _regionOwner = RegionContract.ownerOf(_regionId);
        if (_owner != address(0)) {
            UserBalanceContract.addBalance(_regionOwner, _price * districtOwnerFeePercent / 1000, 1, 0);
            emit RegionPayout(_owner, _regionId, _price * districtOwnerFeePercent / 1000, 2);
        }

        beneficiaryPayout(_price * devFeePercent / 1000);

        UserBalanceContract.store.value(_price - _price * devFeePercent / 1000)();

        emit Rental(_tokenId, rentals[_tokenId].renter, rentals[_tokenId].endOfRental, _price, _ownerPrice, _days, now);
    }

    function rentalComplete(uint256 _tokenId) public {
        require(LandContract.ownerOf(_tokenId) == msg.sender || rentals[_tokenId].renter == msg.sender);
        require(rentals[_tokenId].renter != address(0));
        require(rentals[_tokenId].endOfRental < now, "Rental in progress");

        LandContract.lockToken(_tokenId);
        rentals[_tokenId].renter = address(0);
        rentals[_tokenId].endOfRental = 0;

        emit RentalComplete(_tokenId, now);
    }

    event RentalComplete(uint256 _tokenId, uint256 _now);
    event RentOut(uint256 _tokenId, uint16 _minDays, uint16 _maxDays, uint256 _pricePerDay);
    event RentalRemove(uint256 _tokenId, uint256 _pricePerDay);
    event Rental(uint256 _tokenId, address _renter, uint256 _endOfRental, uint _price, uint _ownerPrice, uint16 _days, uint256 _now);
    event RegionPayout(address _owner, uint indexed tokenId, uint256 value, uint8 _payoutType);
}