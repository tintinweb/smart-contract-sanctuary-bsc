/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

pragma solidity 0.4.24;

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

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes data
    ) external returns (bytes4);
}

interface ISparkNFT{
    function mint(string _URI) external returns (uint256);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferOwnership(address newOwner) external;
}

contract Mintinglock is Ownable {
    /// @notice Indicates if minting is locked
    uint8 isLocked = 0;

    event Freezed();
    event UnFreezed();

    modifier validLock {
        require(isLocked == 0, "Minting is freezed");
        _;
    }

    function freeze() public onlyOwner {
        isLocked = 1;

        emit Freezed();
    }

    function unfreeze() public onlyOwner {
        isLocked = 0;

        emit UnFreezed();
    }
}

contract SelfMintSparkNFTStorage is EternalStorage, Ownable, Initializable, IERC721Receiver{
    using SafeERC20 for address;
    using SafeMath for uint256;

    function getSparkNFTCollection() public view returns (address){
        return addressStorage[keccak256(abi.encodePacked("sparkNFTCollectionAddress"))];
    }

    function _setSparkNFTCollection(address _collectionAddress) internal {
        addressStorage[keccak256(abi.encodePacked("sparkNFTCollectionAddress"))] = _collectionAddress;
    }

    function getTokenURI() public view returns (string){
        return stringStorage[keccak256(abi.encodePacked("sparkNFTCollectionTokenURI"))]; 
    }

    function _setTokenURI(string _tokenURI) internal {
        stringStorage[keccak256(abi.encodePacked("sparkNFTCollectionTokenURI"))] = _tokenURI;
    }

    function getSRKbToken() public view returns (address){
        return addressStorage[keccak256(abi.encodePacked("srkTokenAddress"))]; 
    }

    function _setSRKbToken(address _address) internal {
        addressStorage[keccak256(abi.encodePacked("srkTokenAddress"))] = _address;
    }

    function getPrice() public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("mintPrice"))]; 
    }

    function _setPrice(uint256 _price) internal {
        uintStorage[keccak256(abi.encodePacked("mintPrice"))] = _price;
    }

    function getLimit() public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("mintLimit"))];
    }

    function _setLimit(uint256 _limit) internal {
        uintStorage[keccak256(abi.encodePacked("mintLimit"))] = _limit;
    }

    function getCurrentMinted() public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("currentMinted"))];
    }

    function _setCurrentMinted(uint256 _amount) internal {
        uintStorage[keccak256(abi.encodePacked("currentMinted"))] = _amount;
    }

    function getIsAlreadyMinted(address _address) public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("isAlreadyMinted",_address))];
    }

    function _setIsAlreadyMinted(address _address, bool _isMinted) internal {
        boolStorage[keccak256(abi.encodePacked("isAlreadyMinted",_address))] = _isMinted;
    }

    function getMintedID(address _address) public view returns (uint256) {
        uintStorage[keccak256(abi.encodePacked("mintedID",_address))];
    }

    function _setMintedID(address _address, uint256 _nftID) internal {
        uintStorage[keccak256(abi.encodePacked("mintedID",_address))] = _nftID;
    }

    function getIsClaimed(address _address) public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("isClaimed",_address))];
    }

    function _setIsClaimed(address _address, bool _isClaimed) internal {
        boolStorage[keccak256(abi.encodePacked("isClaimed",_address))] = _isClaimed;
    }

    function getIsWhitelist(address _senderAddress) public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("isWhitelist",_senderAddress))];
    }

    function _setIsWhitelist(address _senderAddress, bool _isWhitelist) internal {
        boolStorage[keccak256(abi.encodePacked("isWhitelist",_senderAddress))] = _isWhitelist;
    }
}


contract SelfMintSparkNFT is SelfMintSparkNFTStorage, Mintinglock{
    using SafeERC20 for address;
    using SafeMath for uint256;

    event AdminERC20TokenRecovery(address tokenRecovered, uint256 amount);
    event AdminERC721TokenRecovery(address tokenRecovered, uint256 id);
    event AdminRevokeSparkNFTAdmin(address sparkNFTCollection, address newAdmin);
    event SelfMintBadgeCreated(address senderAddress, uint256 badgeID, bytes data);
    event SelfMintBadgeClaim(address senderAddress, uint256 badgeID);
    event SelfMintERC721Received(address operator, address from, uint256 tokenId, bytes data);

    modifier relativeSenderSRKb() {
        require(msg.sender == getSRKbToken(), "Token not valid");
        _;
    }
    
    modifier onlyRelativeMinter(){
        address senderAddress = msg.sender;
        require(getIsAlreadyMinted(senderAddress));
        
        _;
    }

    //////////////////////////////////////////////////
    //// READ FUNCTIONS
    ////

    //////////////////////////////////////////////////
    //// INITIAL FUNCTIONS
    ////

    function initialize(address _owner) public onlyRelevantSender returns (bool){
        require(!isInitialized());

        _setOwner(_owner);

        setInitialize();
        return isInitialized();
    }

    function setup(address _srkToken, address _sparkNFTCollection, uint256 _price, uint256 _mintLimit, string _URI) public onlyOwner {
        _setSRKbToken(_srkToken);
        _setSparkNFTCollection(_sparkNFTCollection);
        _setPrice(_price);
        _setLimit(_mintLimit);
        _setTokenURI(_URI);
    }

    function setLimit(uint256 _limit) public onlyOwner {
        require(_limit > getLimit(), "New minting limit must be greater");
        _setLimit(_limit);
    }

    function addWhitelistAddress(address[] _whitelist) public onlyOwner {
        for (uint256 x = 0 ; x < _whitelist.length ; x++){
            _setIsWhitelist(_whitelist[x], true);
        }
    }

    function removeWhitelistAddress(address[] _whitelist) public onlyOwner {
        for (uint256 x = 0 ; x < _whitelist.length ; x++){
            _setIsWhitelist(_whitelist[x], false);
        }
    }

    //////////////////////////////////////////////////
    //// ADMIN FUNCTIONS
    ////

    function recoverERC20Tokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        _tokenAddress.safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminERC20TokenRecovery(_tokenAddress, _tokenAmount);
    }

    function recoverERC721Tokens(address _tokenAddress, uint256 id) external onlyOwner {
        ISparkNFT(_tokenAddress).safeTransferFrom(address(this), address(msg.sender), id);

        emit AdminERC721TokenRecovery(_tokenAddress, id);
    } 

    function revokeSparkNFTAdmin() public onlyOwner {
        ISparkNFT(getSparkNFTCollection()).transferOwnership(address(msg.sender));

        emit AdminRevokeSparkNFTAdmin(getSparkNFTCollection(), msg.sender);
    }
    
    //////////////////////////////////////////////////
    //// SELF MINT FUNCTIONS
    ////
    
    function onTokenTransfer(address _from, uint256 _value, bytes _data) external relativeSenderSRKb validLock {
        if (!getIsWhitelist(_from)) require(_value >= getPrice(), "Not enough SRKb");
        require(!getIsAlreadyMinted(_from), "Address already minted");
        require(getCurrentMinted() <= getLimit(), "Limit already reached");

        // Send excess SRKb
        uint256 excess = _value.sub(getPrice());
        if (getIsWhitelist(_from)) excess = _value;
        if (excess > 0) getSRKbToken().safeTransfer(_from, excess);

        uint256 nftID = ISparkNFT(getSparkNFTCollection()).mint(getTokenURI());

        _setMintedID(_from, nftID);

        _setIsAlreadyMinted(_from, true);
        _setCurrentMinted(getCurrentMinted().add(1));

        emit SelfMintBadgeCreated(_from, nftID, _data);
    }
    
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns (bytes4){
        emit SelfMintERC721Received(_operator, _from, _tokenId, _data);
        return this.onERC721Received.selector;
    }

    function claimBadge() external onlyRelativeMinter {
        address senderAddress = msg.sender;
        uint256 nftID = getMintedID(senderAddress);
        require(getIsAlreadyMinted(senderAddress), "Address not yet minted");
        require(!getIsClaimed(senderAddress), "Address already claimed");
        
        ISparkNFT(getSparkNFTCollection()).safeTransferFrom(address(this), senderAddress, nftID);
        _setIsClaimed(senderAddress, true);

        emit SelfMintBadgeClaim(senderAddress, nftID);
    }
}