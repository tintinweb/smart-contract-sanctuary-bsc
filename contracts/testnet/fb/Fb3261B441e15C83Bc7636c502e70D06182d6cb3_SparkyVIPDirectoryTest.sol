/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

pragma solidity 0.4.24;

/**
 * @title EternalStorage
 * @dev This contract holds all the necessary state variables to carry out the storage of any contract.
 */
contract EternalStorage {
    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;
    
    mapping(bytes32 => uint256[]) internal uintArrayStorage;
    mapping(bytes32 => string[]) internal stringArrayStorage;
    mapping(bytes32 => address[]) internal addressArrayStorage;
    //mapping(bytes32 => bytes[]) internal bytesArrayStorage;
    mapping(bytes32 => bool[]) internal boolArrayStorage;
    mapping(bytes32 => int256[]) internal intArrayStorage;
    mapping(bytes32 => bytes32[]) internal bytes32ArrayStorage;
}


interface IUpgradeabilityOwnerStorage {
    function upgradeabilityOwner() external view returns (address);
}

/**
 * @title Ownable
 * @dev This contract has an owner address providing basic authorization control
 */
contract Ownable is EternalStorage {
    bytes4 internal constant UPGRADEABILITY_OWNER = 0x6fde8202; // upgradeabilityOwner()

    /**
    * @dev Event to show ownership has been transferred
    * @param previousOwner representing the address of the previous owner
    * @param newOwner representing the address of the new owner
    */
    event OwnershipTransferred(address previousOwner, address newOwner);

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner());
        /* solcov ignore next */
        _;
    }

    /**
    * @dev Throws if called by any account other than contract itself or owner.
    */
    modifier onlyRelevantSender() {
        // proxy owner if used through proxy, address(0) otherwise
        require(
            !address(this).call(abi.encodeWithSelector(UPGRADEABILITY_OWNER)) || // covers usage without calling through storage proxy
                msg.sender == IUpgradeabilityOwnerStorage(this).upgradeabilityOwner() || // covers usage through regular proxy calls
                msg.sender == address(this) // covers calls through upgradeAndCall proxy method
        );
        /* solcov ignore next */
        _;
    }

    bytes32 internal constant OWNER = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0; // keccak256(abi.encodePacked("owner"))

    /**
    * @dev Tells the address of the owner
    * @return the address of the owner
    */
    function owner() public view returns (address) {
        return addressStorage[OWNER];
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner the address to transfer ownership to.
    */
    function transferOwnership(address newOwner) external onlyOwner {
        _setOwner(newOwner);
    }

    /**
    * @dev Sets a new owner address
    */
    function _setOwner(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner(), newOwner);
        addressStorage[OWNER] = newOwner;
    }
}

contract Initializable is EternalStorage {
    bytes32 internal constant INITIALIZED = 0x0a6f646cd611241d8073675e00d1a1ff700fbf1b53fcf473de56d1e6e4b714ba; // keccak256(abi.encodePacked("isInitialized"))

    function setInitialize() internal {
        boolStorage[INITIALIZED] = true;
    }

    function isInitialized() public view returns (bool) {
        return boolStorage[INITIALIZED];
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
        return 0;
        }

        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // assert(_b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
        return _a / _b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }
}

interface ISparkNFT{
    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract SparkyVIPDirectoryStorage is EternalStorage, Ownable, Initializable {
    using SafeMath for uint256;

    function getVIPBadgeCollection() public view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("sparkyVIPBadgeCollection"))];
    } 

    function _setVIPBadgeCollection(address _collection) internal {
        addressStorage[keccak256(abi.encodePacked("sparkyVIPBadgeCollection"))] = _collection;
    }

    function _removeArray(address[] _array, address _address) internal pure returns (address[]){
        uint256 index = _array.length;
        for ( uint256 x = 0 ; x < _array.length ; x++ ){
            if(_array[x] == _address){
                index = x;
                break;
            }
        }

        address[] memory _temp;
        if (index != _array.length){
            _temp = new address[](_array.length - 1); 

            for( uint256 y = 0 ; y < _array.length - 1 ; y++ ){
                if (y >= index) _temp[y] = _array[y+1];
                else _temp[y] = _array[y];
            }

            return _temp;
        }

        return _array;
    }

    function _addWhitelistVIPs(address[] _vips) internal {
        for ( uint256 x = 0 ; x < _vips.length ; x++ ){
            if (!boolStorage[keccak256(abi.encodePacked("whitelistVIPs",_vips[x]))]){
                addressArrayStorage[keccak256(abi.encodePacked("whitelistVIPs"))].push(_vips[x]);
            }

            boolStorage[keccak256(abi.encodePacked("whitelistVIPs",_vips[x]))] = true; 
        }
    }

    function _removeWhitelistVIPs(address[] _vips) internal {
        for ( uint256 x = 0 ; x < _vips.length ; x++ ){
            if (boolStorage[keccak256(abi.encodePacked("whitelistVIPs",_vips[x]))]){
                addressArrayStorage[keccak256(abi.encodePacked("whitelistVIPs"))] = _removeArray(addressArrayStorage[keccak256(abi.encodePacked("whitelistVIPs"))],_vips[x]);
            }

            boolStorage[keccak256(abi.encodePacked("whitelistVIPs",_vips[x]))] = false; 
        }
    }

    function getIsVIPWhitelisted(address _vip) public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("whitelistVIPs",_vip))];
    }

    function getWhitelistVIPs() public view returns (address[]) {
        return addressArrayStorage[keccak256(abi.encodePacked("whitelistVIPs"))];
    }
}

contract SparkyVIPDirectoryTest is SparkyVIPDirectoryStorage {
    using SafeMath for uint256; 

    //////////////////////////////////////////////////
    //// INITIAL FUNCTIONS
    ////
    function initialize(address _owner) public onlyRelevantSender returns (bool){
        require(!isInitialized());

        _setOwner(_owner);

        setInitialize();
        return isInitialized();
    }

    function setup(address _VIPBadgeCollection) public onlyOwner {
        require(false, "Not needed");
        _setVIPBadgeCollection(_VIPBadgeCollection);
    }

    //////////////////////////////////////////////////
    //// READ FUNCTIONS
    ////

    //// Checks if address has SparkyVIP badge and is whitelisted
    function isSparkyVIP(address _vip) public view returns (bool){
        return getIsVIPWhitelisted(_vip);
    }

    //////////////////////////////////////////////////
    //// WRITE FUNCTIONS
    ////

    function addVIPToWhitelist(address[] _vips) public onlyOwner {
        _addWhitelistVIPs(_vips);
    }

    function removeVIPFromWhitelist(address[] _vips) public onlyOwner {
        _removeWhitelistVIPs(_vips);
    }
}