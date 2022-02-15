/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract LegacyERC20 {
    function transfer(address _spender, uint256 _value) public; // returns (bool);
    function transferFrom(address _owner, address _spender, uint256 _value) public; // returns (bool);
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
 * @title SafeERC20
 * @dev Helper methods for safe token transfers.
 * Functions perform additional checks to be sure that token transfer really happened.
 */
library SafeERC20 {
    using SafeMath for uint256;

    /**
    * @dev Same as ERC20.transfer(address,uint256) but with extra consistency checks.
    * @param _token address of the token contract
    * @param _to address of the receiver
    * @param _value amount of tokens to send
    */
    function safeTransfer(address _token, address _to, uint256 _value) internal {
        LegacyERC20(_token).transfer(_to, _value);
        assembly {
            if returndatasize {
                returndatacopy(0, 0, 32)
                if iszero(mload(0)) {
                    revert(0, 0)
                }
            }
        }
    }

    /**
    * @dev Same as ERC20.transferFrom(address,address,uint256) but with extra consistency checks.
    * @param _token address of the token contract
    * @param _from address of the sender
    * @param _value amount of tokens to send
    */
    function safeTransferFrom(address _token, address _from, uint256 _value) internal {
        LegacyERC20(_token).transferFrom(_from, address(this), _value);
        assembly {
            if returndatasize {
                returndatacopy(0, 0, 32)
                if iszero(mload(0)) {
                    revert(0, 0)
                }
            }
        }
    }
}

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

contract SparkINOStorage is EternalStorage, Ownable, Initializable {
    using SafeERC20 for address;
    using SafeMath for uint256;

    modifier rarityExist(uint256 _rarityId){
        require(_rarityId > 0, "Invalid rarity");
        require(_rarityId <= getRarityId(), "Rarity does not exist");

        _;
    }

    /**
    * @dev Function to get rarity (NFT gacha boxes) count
    * @return Returns latest Rarity ID
    */
    function getRarityId() public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("rarityCount"))];
    }

    /**
    * @dev Function to increase rarity count by one (Push new rarity) 
    * @return Returns latest Rarity ID
    */
    function _increaseRarityId() internal returns (uint256) {
        uint256 _rarityId = getRarityId().add(1);
        uintStorage[keccak256(abi.encodePacked("rarityCount"))] = _rarityId;
        return _rarityId;
    }

    /**
    * @dev Function to decrease rarity count by one (Pop last rarity)
    * @return Returns latest Rarity ID
    */
    function _decreaseRarityId() internal returns (uint256) {
        uint256 _rarityId = getRarityId().sub(1);
        uintStorage[keccak256(abi.encodePacked("rarityCount"))] = _rarityId;
        return _rarityId;
    }


    /**
    * @dev Function to get rarity (NFT gacha boxes) price and supply
    * @param _rarityId Rarity ID
    * @return _rarityPrice Price of Rarity
    * @return _rarityCount Supply of Rarity
    */
    function getRarity(uint256 _rarityId) public view rarityExist(_rarityId) returns (uint256 rarityPrice, uint256 raritySupply){
        uint256 _rarityPrice = uintStorage[keccak256(abi.encodePacked("rarityPrice",_rarityId))];
        uint256 _raritySupply = uintStorage[keccak256(abi.encodePacked("raritySupply",_rarityId))];

        return (_rarityPrice, _raritySupply);
    }

    /**
    * @dev Function to set rarity (NFT gacha boxes) price
    * @param _rarityPrice Rarity Price
    * @param _rarityId Rarity ID
    * @return Returns price of Rarity
    */
    function _setRarityPrice(uint256 _rarityPrice, uint256 _rarityId) internal rarityExist(_rarityId) returns (uint256) {
        uintStorage[keccak256(abi.encodePacked("rarityPrice",_rarityId))] = _rarityPrice;
        return _rarityPrice;
    }

    /**
    * @dev Function to set rarity (NFT gacha boxes) supply
    * @param _raritySupply Rarity Supply
    * @param _rarityId Rarity ID
    * @return Returns supply of Rarity
    */
    function _setRaritySupply(uint256 _raritySupply, uint256 _rarityId) internal rarityExist(_rarityId) returns (uint256) {
        uintStorage[keccak256(abi.encodePacked("raritySupply",_rarityId))] = _raritySupply;
        return _raritySupply;
    }

    /**
    * @dev Function to get IDO start time
    * @return Returns timestamp of IDO start time
    */
    function getStartTime() public view returns (uint256){
        return uintStorage[keccak256(abi.encodePacked("startTime"))];
    }

    /**
    * @dev Function to set IDO start time
    * @param _startTime Timestamp of IDO start time
    * @return Returns timestamp of IDO start time
    */
    function _setStartTime(uint256 _startTime) internal returns (uint256) {
        uintStorage[keccak256(abi.encodePacked("startTime"))] = _startTime;
        return _startTime;
    }

    /**
    * @dev Function to get if IDO Sale is finished
    * @return Returns boolean if IDO Sale is finished
    */
    function getIsFinished() public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("isFinished"))];
    }

    /**
    * @dev Function to set if IDO Sale is finished
    * @param _isFinished Boolean if IDO Sale is finished
    * @return Returns boolean if IDO Sale is finished
    */
    function _setIsFinished(bool _isFinished) internal returns (bool) {
        boolStorage[keccak256(abi.encodePacked("isFinished"))] = _isFinished;
        return _isFinished;
    }

    /**
    * @dev Function to get sold amount per rarity ID
    * @param _rarityId Rarity Id
    * @return Returns sold amount of rarity
    */
    function getSoldRarity(uint256 _rarityId) public view rarityExist(_rarityId) returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("raritySold",_rarityId))];
    }
    
    /**
    * @dev Function to set sold amount per rarity ID
    * @param _rarityId Rarity Id
    * @param _amount Rarity sold amount
    * @return Returns sold amount of rarity
    */
    function _setSoldRarity(uint256 _rarityId, uint256 _amount) internal rarityExist(_rarityId) returns (uint256)  {
        uintStorage[keccak256(abi.encodePacked("raritySold",_rarityId))] = _amount;
        return _amount;
    }

    /**
    * @dev Function to get total raised of all raritys 
    * @return Returns total raised amount in ETH/BNB
    */
    function getTotalRaised() public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("totalRaisedIDO"))];
    }

    /**
    * @dev Function to set total raised of all raritys 
    * @param _totalRaised ETH/BNB amount of total raised
    * @return Returns total raised amount of all raritys
    */
    function _setTotalRaised(uint256 _totalRaised) internal returns (uint256) {
        uintStorage[keccak256(abi.encodePacked("totalRaisedIDO"))] = _totalRaised;
        return _totalRaised;
    }

    /**
    * @dev Function to get total accepted amount by sender address 
    * @param _senderAddress Senders address
    * @return Returns total accepted amount by sender address 
    */
    function getAddressAcceptedAmount(address _senderAddress) public view returns (uint256){
        return uintStorage[keccak256(abi.encodePacked("acceptedAmount",_senderAddress))];
    }

    /**
    * @dev Function to set total accepted amount by sender address 
    * @param _senderAddress Senders address
    * @param _acceptedAmount ETH/BNB amount of total accepted amount
    * @return Returns total accepted amount by sender address 
    */
    function _setAddressAcceptedAmount(address _senderAddress, uint256 _acceptedAmount) internal returns (uint256) {
        uintStorage[keccak256(abi.encodePacked("acceptedAmount",_senderAddress))] = _acceptedAmount;
        return _acceptedAmount;
    }

    /**
    * @dev Function to get total rewarded amount or purchased raritys by sender address
    * @param _senderAddress Senders address
    * @param _rarityId Rarity ID
    * @return Returns total rewarded amount for sender address 
    */
    function getAddressRewardedAmount(address _senderAddress, uint256 _rarityId) public view rarityExist(_rarityId) returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("rewardedAmount",_senderAddress,_rarityId))];
    } 

    /**
    * @dev Function to set total rewarded amount or purchased raritys by sender address
    * @param _senderAddress Senders address
    * @param _rarityId Rarity ID
    * @param _rewardedAmount Rewarded amount
    * @return Returns total rewarded amount for sender address 
    */
    function _setAddressRewardedAmount(address _senderAddress, uint256 _rarityId, uint256 _rewardedAmount) internal rarityExist(_rarityId) returns (uint256) {
        uintStorage[keccak256(abi.encodePacked("rewardedAmount",_senderAddress,_rarityId))] = _rewardedAmount;
        return _rewardedAmount;
    }

    /**
    * @dev Function to get all buyers list array
    * @return Returns an array of all buyer list address
    */
    function getAddressBuyersList() public view returns (address[]) {
        return addressArrayStorage[keccak256(abi.encodePacked("addressBuyersList"))];
    }

    /**
    * @dev Function to add sender address to buyers list
    * @param _senderAddress Sender address
    */
    function _addAddressBuyersList(address _senderAddress) internal {
        address[] memory _addressArrayStorage = getAddressBuyersList();

        bool exists = false;
        for (uint256 x = 0 ; x < _addressArrayStorage.length ; x++){
            if (_addressArrayStorage[x] == _senderAddress){
                exists = true;
                break;
            }
        }

        if (!exists) addressArrayStorage[keccak256(abi.encodePacked("addressBuyersList"))].push(_senderAddress);
    }

    function getWhitelistEnable() public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("isWhitelistEnabled"))];
    }

    function _setWhitelistEnable(bool _enabled) internal returns (bool) {
        boolStorage[keccak256(abi.encodePacked("isWhitelistEnabled"))] = _enabled;
        return _enabled;
    }

    function getAddressInWhitelist(address _senderAddress) public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("isAddressInWhitelist",_senderAddress))];
    }

    function _setAddressInWhitelist(address _senderAddress, bool _enabled) internal returns (bool) {
        boolStorage[keccak256(abi.encodePacked("isAddressInWhitelist",_senderAddress))] = _enabled;
        return _enabled;
    }

    function getWhitelistAmount(address _senderAddress, uint256 _rarityId) public view rarityExist(_rarityId) returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("whitelistAmount",_rarityId,_senderAddress))];
    }

    function _setWhitelistAmount(address _senderAddress, uint256 _rarityId, uint256 _whitelistAmount) internal rarityExist(_rarityId) returns (uint256) {
        uintStorage[keccak256(abi.encodePacked("whitelistAmount",_rarityId,_senderAddress))] = _whitelistAmount;
        return _whitelistAmount;
    }
}

contract SparkINO is SparkINOStorage {
    using SafeERC20 for address;
    using SafeMath for uint256;

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event PushRarity(uint256 rarityId, uint256 rarityPrice, uint256 raritySupply);
    event EditRarity(uint256 rarityId, uint256 rarityPrice, uint256 raritySupply);
    event PopRarity(uint256 rarityId);
    event AddWhiteList(uint256 whitelistCount);
    event RemoveWhiteList(address wallet);
    event StartSale(uint256 startTime, bool isStart);
    event FinishSale(bool isFinished);
    event Buy(address _sender, uint256 _value, uint256 _totalToken, uint256 _rewardedAmount, uint256 _senderSoldAmount, uint256 _senderTotalRise);
    event WithdrawBNBBalance(address sender, uint256 balance);

    struct AddressRewardedRarity{
        uint256 _rarityId;
        address _senderAddress;
        uint256 _rewardedAmount;
    }

    struct WhitelistInput {
        address wallet;
        uint256[] rarityLimit;
    }

    modifier isWhitelisted(uint256 _rarityId) {
        address _senderAddress = msg.sender;
        if (getWhitelistEnable()) require(getAddressInWhitelist(_senderAddress), "Address not whitelisted");

        _;

        if (getWhitelistEnable()) require(getAddressRewardedAmount(_senderAddress,_rarityId) <= getWhitelistAmount(_senderAddress,_rarityId), "Address rewarded amount exceeds whitelist");
    }

    ////////////////////////////////////////////////////////
    //// Read functions

    function isStart() public view returns (bool){
        return isInitialized() && getStartTime() > 0 && block.timestamp >= getStartTime();
    }

    function calculateAmount(uint256 _acceptedAmount, uint256 _rarityId) public view rarityExist(_rarityId) returns (uint256) {
        (uint256 _rarityPrice,) = getRarity(_rarityId);

        return _acceptedAmount / _rarityPrice;
    }

    function getRarityPriceETH(uint256 _amount, uint256 _rarityId) public view returns (uint256) {
        (uint256 _rarityPrice,) = getRarity(_rarityId);

        return _amount * _rarityPrice;
    }

    function addressRewardedRarity(uint256 _rarityId) public view returns (AddressRewardedRarity[] memory) {
        address[] memory _addressArrayStorage = getAddressBuyersList();

        AddressRewardedRarity[] memory _addressRewardedRarity = new AddressRewardedRarity[](_addressArrayStorage.length);

        for (uint256 x = 0 ; x < _addressArrayStorage.length ; x++){
            _addressRewardedRarity[x]._rarityId = _rarityId;
            _addressRewardedRarity[x]._senderAddress = _addressArrayStorage[x];
            _addressRewardedRarity[x]._rewardedAmount = getAddressRewardedAmount(_addressArrayStorage[x],_rarityId);
        }

        return _addressRewardedRarity;
    }

    function getTotalRaritySupply() public view returns (uint256){
        uint256 _totalRaritySupply;
        for (uint256 x = 1 ; x <= getRarityId() ; x++){
            (, uint256 _raritySupply) = getRarity(x);
            _totalRaritySupply = _totalRaritySupply.add(_raritySupply);
        }

        return _totalRaritySupply;
    }

    function getTotalRaritySold() public view returns (uint256){
        uint256 _totalSoldRarity;
        for (uint256 x = 1 ; x <= getRarityId() ; x++){
            uint256 _raritySold = getSoldRarity(x);
            _totalSoldRarity = _totalSoldRarity.add(_raritySold);
        }

        return _totalSoldRarity;
    }

    ////////////////////////////////////////////////////////
    //// BEFORE SALE functions

    function initialize(address _owner) public onlyRelevantSender returns (bool){
        require(!isInitialized());

        _setOwner(_owner);

        setInitialize();
        return isInitialized();
    }

    function pushRarity(uint256 _rarityPrice, uint256 _raritySupply) public onlyOwner {
        require(!isStart(), "Sale already started");
        uint256 _rarityId = _increaseRarityId();

        _setRarityPrice(_rarityPrice,_rarityId);
        _setRaritySupply(_raritySupply,_rarityId);

        emit PushRarity(_rarityId, _rarityPrice, _raritySupply);
    }

    function editRarity(uint256 _rarityId, uint256 _rarityPrice, uint256 _raritySupply) public rarityExist(_rarityId) onlyOwner {
        require(!isStart(), "Sale already started");

        _setRarityPrice(_rarityPrice,_rarityId);
        _setRaritySupply(_raritySupply,_rarityId);

        emit EditRarity(_rarityId, _rarityPrice, _raritySupply);
    }

    function popRarity() public onlyOwner {
        require(!isStart(), "Sale already started");
        uint256 _rarityId = getRarityId();

        _decreaseRarityId();
        _setRarityPrice(0,_rarityId);
        _setRaritySupply(0,_rarityId);

        emit PopRarity(_rarityId);
    }

    function addWhitelist(WhitelistInput[] memory _whitelists) public onlyOwner {
        require(!isStart(), "Sale already started");

        uint256 addressesLength = _whitelists.length;

        for (uint256 x = 0; x < addressesLength; x++) {
            WhitelistInput memory _whitelist = _whitelists[x];
            _setAddressInWhitelist(_whitelist.wallet, true);
            for (uint256 y = 0 ; y < getRarityId() ; y++ ){
                _setWhitelistAmount(_whitelist.wallet, y.add(1), _whitelist.rarityLimit[y]);
            }    
        }

        emit AddWhiteList(addressesLength);
    }

    function removeWhitelist(address _senderAddress) public onlyOwner {
        _setAddressInWhitelist(_senderAddress, false);
        for (uint256 x = 1 ; x < getRarityId() ; x++ ){
            _setWhitelistAmount(_senderAddress, x, 0);
        }   

        emit RemoveWhiteList(_senderAddress);
    }

    function openSale(uint256 _startTime, bool _whitelist) public onlyOwner {
        require(isInitialized(), "This step should perform before the sale");
        require(getRarityId() > 0, "No rarity currently set");
        require(_startTime >= block.timestamp, "Start time should be greater than current time");
        require(getStartTime() == 0, "A start time is currently in set");
        require(!getIsFinished(), "A sale already ends");

        _setStartTime(_startTime);
        _setIsFinished(false);
        _setWhitelistEnable(_whitelist);

        emit StartSale(_startTime, isStart());
    } 

    ////////////////////////////////////////////////////////
    //// DURING SALE functions

    function buy(uint256 _rarityId) public isWhitelisted(_rarityId) payable {
        address _senderAddress = msg.sender;
        uint256 _acceptedAmount = msg.value;

        require(isStart(), "Sale is not started yet");
        require(!getIsFinished(), "Sale is finished");
        require(_acceptedAmount > 0, "You must pay some accepted tokens to get sale tokens");

        (, uint256 _raritySupply) = getRarity(_rarityId);

        uint256 _rewardedAmount = calculateAmount(_acceptedAmount, _rarityId);

        uint256 _prevAcceptedAmount = getAddressAcceptedAmount(_senderAddress);
        uint256 _prevRewardedAmount = getAddressRewardedAmount(_senderAddress, _rarityId);
        
        uint256 _totalSold = getSoldRarity(_rarityId);
        uint256 _unsoldTokens = _raritySupply - _totalSold;

        uint256 _excessAmount;
        // Check if accepted amount exceeds amount of unsold tokens
        if (_acceptedAmount > getRarityPriceETH(_unsoldTokens, _rarityId)){
            // Calculate excess amount
            _excessAmount = _acceptedAmount - getRarityPriceETH(_unsoldTokens, _rarityId);
            // Send excess amount
            _acceptedAmount = _acceptedAmount - _excessAmount;
            _senderAddress.transfer(_excessAmount);
            // Update Rewarded amount
            _rewardedAmount = calculateAmount(_acceptedAmount, _rarityId);
        }
        //
        else if (_acceptedAmount > getRarityPriceETH(_rewardedAmount, _rarityId)){
            // Calculate excess amount
            _excessAmount = _acceptedAmount - getRarityPriceETH(_rewardedAmount, _rarityId);
            // Send excess amount
            _acceptedAmount = _acceptedAmount - _excessAmount;
            _senderAddress.transfer(_excessAmount);
            // Update Rewarded amount
            _rewardedAmount = calculateAmount(_acceptedAmount, _rarityId);
        }

        require(_rewardedAmount > 0, "Zero rewarded amount");

        _addAddressBuyersList(_senderAddress);

        _setAddressAcceptedAmount(_senderAddress, _prevAcceptedAmount.add(_acceptedAmount));
        _setAddressRewardedAmount(_senderAddress, _rarityId, _prevRewardedAmount.add(_rewardedAmount));

        _totalSold = _totalSold + _rewardedAmount;
        _setSoldRarity(_rarityId, _totalSold);
        uint256 _totalRaised = getTotalRaised() + _acceptedAmount;
        _setTotalRaised(_totalRaised);

        if (getTotalRaritySupply() == getTotalRaritySold()){
            finishSale();
        }
        
        emit Buy(_senderAddress, _acceptedAmount, _raritySupply, _rewardedAmount, _totalSold, _totalRaised); 
    }

    function finishSale() public onlyOwner {
        _setIsFinished(true);

        emit FinishSale(true);
    }

    ////////////////////////////////////////////////////////
    //// AFTER SALE functions

    function withdrawBNBBalance() public onlyOwner {
        address sender = msg.sender;

        uint256 balance = address(this).balance;
        sender.transfer(balance);

        // Emit event
        emit WithdrawBNBBalance(sender, balance);
    }

    ////////////////////////////////////////////////////////
    //// FREE STATE

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        _tokenAddress.safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }
}