/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

pragma solidity 0.5.9;

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