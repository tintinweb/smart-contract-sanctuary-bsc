/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

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


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
    * @dev Returns the name of the token.
    */
    function name() external view returns (string memory);

    /**
    * @dev Returns the symbol of the token.
    */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the decimals places of the token.
    */
    function decimals() external view returns (uint8);

    /**
    * @dev Returns the amount of tokens in existence.
    */
    function totalSupply() external view returns (uint256);

    /**
    * @dev Returns the amount of tokens owned by `account`.
    */
    function balanceOf(address account) external view returns (uint256);

    /**
    * @dev Moves `amount` tokens from the caller's account to `recipient`.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * Emits a {Transfer} event.
    */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
    * @dev Returns the remaining number of tokens that `spender` will be
    * allowed to spend on behalf of `owner` through {transferFrom}. This is
    * zero by default.
    *
    * This value changes when {approve} or {transferFrom} are called.
    */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
    * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * IMPORTANT: Beware that changing an allowance with this method brings the risk
    * that someone may use both the old and the new allowance by unfortunate
    * transaction ordering. One possible solution to mitigate this race
    * condition is to first reduce the spender's allowance to 0 and set the
    * desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    *
    * Emits an {Approval} event.
    */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
    * @dev Moves `amount` tokens from `sender` to `recipient` using the
    * allowance mechanism. `amount` is then deducted from the caller's
    * allowance.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * Emits a {Transfer} event.
    */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
    * @dev Emitted when `value` tokens are moved from one account (`from`) to
    * another (`to`).
    *
    * Note that `value` may be zero.
    */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
    * @dev Emitted when the allowance of a `spender` for an `owner` is set by
    * a call to {approve}. `value` is the new allowance.
    */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ManualClaimStorage is EternalStorage, Ownable, Initializable {
    using SafeMath for uint256;

    function getDistributionTime() public view returns (uint256[]) {
        return uintArrayStorage[keccak256(abi.encodePacked("distributionTime"))];
    }

    function _setDistributionTime(uint256[] _epoch) internal {
        uintArrayStorage[keccak256(abi.encodePacked("distributionTime"))] = _epoch;
    }

    function getWhitelistAddresses() public view returns (address[]) {
        return addressArrayStorage[keccak256(abi.encodePacked("whitelistAddresses"))];
    }

    function _setWhitelistAddresses(address[] _whitelist) internal {
        addressArrayStorage[keccak256(abi.encodePacked("whitelistAddresses"))] = _whitelist;
    }

    function getAddressDistributedAmount(address _whitelist, uint256 _epoch) public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("addressDistributedAmount",_whitelist,_epoch))];
    }

    function _setAddressDistributedAmount(address _whitelist, uint256 _epoch, uint256 _amount) internal {
        uintStorage[keccak256(abi.encodePacked("addressDistributedAmount",_whitelist,_epoch))] = _amount;
    }

    function getIsClaimed(address _whitelist, uint256 _epoch) public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("isClaimed",_whitelist,_epoch))];
    }

    function _setIsClaimed(address _whitelist, uint256 _epoch, bool _claimed) internal {
        boolStorage[keccak256(abi.encodePacked("isClaimed",_whitelist,_epoch))] = _claimed;
    }

    function getIsSetup() public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("isSetup"))];
    }

    function _setIsSetup(bool _setup) internal {
        boolStorage[keccak256(abi.encodePacked("isSetup"))] = _setup;
    }

    function getIsStart() public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("isStart"))];
    }

    function _setIsStart(bool _start) internal {
        boolStorage[keccak256(abi.encodePacked("isStart"))] = _start;
    }

    function getDistributionToken() public view returns (address){
        return addressStorage[keccak256(abi.encodePacked("distributionToken"))];
    }

    function _setDistributionToken(address _token) internal {
        addressStorage[keccak256(abi.encodePacked("distributionToken"))] = _token;
    }

}

contract ManualClaim is ManualClaimStorage {
    using SafeMath for uint256; 

    struct DistributedAmountInput {
        address wallet;
        uint256 amount;
    }

    struct DistributedAmount {
        uint256 amount;
        uint256 epoch;
        bool isClaimed;
    }

    //////////////////////////////////////////////////
    //// EVENTS
    ////

    event EDistributionStart(bool start);
    event EClaimTokens(address whitelist, uint256 epoch, uint256 amount);
    event AERC20Recovery(address token, uint256 amount);


    //////////////////////////////////////////////////
    //// MODIFIER FUNCTIONS
    ////

    modifier distributionTimeExist(uint256 _epoch){
        uint256[] memory _distributionTime = getDistributionTime();
        bool _exists;

        for(uint256 x = 0 ; x < _distributionTime.length ; x++){
            if(_distributionTime[x] == _epoch) {
                _exists = true;
                break;
            }
        }

        require(_exists, "Distribution time does not exist");

        _;
    }

    //////////////////////////////////////////////////
    //// INITIAL FUNCTIONS
    ////
    function initialize(address _owner) public onlyRelevantSender returns (bool){
        require(!isInitialized());

        _setOwner(_owner);

        setInitialize();
        return isInitialized();
    }

    function setup(uint256[] _distributionTime, address[] _whitelist, address _token) public onlyOwner {
        require(!getIsSetup(), "Already set uped");

        for (uint256 x = 0 ; x < _distributionTime.length - 1 ; x++ ){
            require(_distributionTime[x] < _distributionTime[x+1], "Invalid _distributionTime"); 
        }

        _setDistributionTime(_distributionTime);
        _setWhitelistAddresses(_whitelist);
        _setDistributionToken(_token);
        _setIsSetup(true);
    }


    function setDistributedAmount(uint256 _epoch, DistributedAmountInput[] memory _input) public onlyOwner distributionTimeExist(_epoch) {
        require(!getIsStart(), "Distribution already started");

        for(uint256 x = 0 ; x < _input.length ; x++ ){
            DistributedAmountInput memory _distributedAmount = _input[x];

            require(isWhitelistExist(_distributedAmount.wallet), "Some address/es is not whitelisted");

            _setAddressDistributedAmount(_distributedAmount.wallet, _epoch, _distributedAmount.amount);
        }
    }

    function startDistribution() public onlyOwner {
        require(!getIsStart(), "Distribution already started");

        _setIsStart(true);
        emit EDistributionStart(true);
    }

    //////////////////////////////////////////////////
    //// READ FUNCTIONS
    ////

    function isWhitelistExist(address _whitelist) public view returns (bool) {
        address[] memory _whitelistAddresses = getWhitelistAddresses();

        for(uint256 x = 0 ; x < _whitelistAddresses.length ; x++){
            if(_whitelistAddresses[x] == _whitelist) {
                return true;
            }
        }

        return false;
    }

    function distributedAmount(address _whitelist) public view returns (DistributedAmount[]) {
        require(isWhitelistExist(_whitelist), "Address is not whitelisted");
        DistributedAmount[] memory _distributedAmount = new DistributedAmount[](getDistributionTime().length); 

        uint256[] memory _distributionTime = getDistributionTime();

        for (uint256 x = 0 ; x < _distributedAmount.length ; x++ ){
            _distributedAmount[x] = DistributedAmount(getAddressDistributedAmount(_whitelist, _distributionTime[x]), _distributionTime[x], getIsClaimed(_whitelist, _distributionTime[x]));
        }

        return _distributedAmount;
    }

    function epochTime() public view returns (uint256) {
        return block.timestamp;
    }

    //////////////////////////////////////////////////
    //// WRITE FUNCTIONS
    ////

    function claim(uint256 _epoch) public distributionTimeExist(_epoch) {
        address _claimant = address(msg.sender);
        uint256 _amount = getAddressDistributedAmount(_claimant,_epoch);
        
        require(getIsStart(), "Not yet started");
        require(isWhitelistExist(_claimant), "Address is not whitelisted");
        require(_epoch <= epochTime(), "No available claim");
        require(!getIsClaimed(_claimant,_epoch), "Already claimed");
        require(_amount > 0, "No available claim");

        IERC20(getDistributionToken()).transfer(_claimant, _amount);
        _setIsClaimed(_claimant, _epoch, true);

        emit EClaimTokens(_claimant, _epoch, _amount);
    }

    function claimAll() public {
        address _claimant = address(msg.sender);
        uint256[] memory _distributionTime = getDistributionTime();
        uint256 _epoch = epochTime();
        uint256 _claimCount;

        for(uint256 x = 0 ; x < _distributionTime.length ; x++ ){
            if (_distributionTime[x] <= _epoch){
                if (!getIsClaimed(_claimant,_distributionTime[x])){
                    claim(_distributionTime[x]);
                    _claimCount++;
                }
            }
            else{
                break;
            }
        }

        require(_claimCount > 0, "No available claim");
    }


    //////////////////////////////////////////////////
    //// ADMIN FUNCTIONS
    ////

    function recoverERC20Tokens(address _tokenAddress, uint256 _tokenAmount) public onlyOwner {
        IERC20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);

        emit AERC20Recovery(_tokenAddress, _tokenAmount);
    } 
}