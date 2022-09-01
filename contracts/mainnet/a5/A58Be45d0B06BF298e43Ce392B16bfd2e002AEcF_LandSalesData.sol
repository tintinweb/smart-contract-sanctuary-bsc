/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.12;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/LandSalesData.sol


contract LandSalesData is Ownable {
    struct LandsInput{
        string assetId;
        uint8 assetType;
    }
    mapping(address => bool) private WhiteList;
    mapping(address => bool) private WhiteListRound2;
    mapping(string => bool ) private LandData ;
    LandsInput[] private MintData;
    
    constructor(){ }
    
    function addToWhiteList(address[] memory _whiteList,bool status) onlyOwner public {
        for(uint8 i;i < _whiteList.length;i++) {
            WhiteList[_whiteList[i]] = status ; 
        }
    }
    function addToWhiteList2(address[] memory _whiteList,bool status) onlyOwner public {
        for(uint8 i;i < _whiteList.length;i++) {
            WhiteListRound2[_whiteList[i]] = status ; 
        }
    }

    function addLands(LandsInput[] memory _data) public onlyOwner {
        for(uint256 i=0;i < _data.length ; i++  ) {
            if(!LandData[_data[i].assetId]){
                MintData.push(LandsInput(_data[i].assetId  , _data[i].assetType)) ;
                LandData[_data[i].assetId] = true;
            }
        }
    }
    function addLandsMethod2(string[] memory _data,uint8 _type) public onlyOwner {
        for(uint256 i=0;i < _data.length ; i++  ) {
            if(!LandData[_data[i]]){
                MintData.push(LandsInput(_data[i]  , _type)) ;
                LandData[_data[i]] = true;
            }
        }
    }
    function getAssetType(string memory assetId) public view returns(uint8) {
        uint8 _type = 128;
        for(uint256 i=0;i < MintData.length ; i++  ) {
            if(  keccak256(bytes( MintData[i].assetId)) ==  keccak256(bytes( assetId)) ) {
                _type = MintData[i].assetType;
            }
        }
        return _type;
    }

    function getWhitelist(address _user) public view returns(bool){
        return WhiteList[_user];
    }
    function getWhitelist2(address _user) public view returns(bool){
        return WhiteListRound2[_user];
    }

    function getFullMainData() public view  returns (LandsInput[] memory) {
        return MintData;
    }
    function getLandByIndex(uint256 index) public view  returns (LandsInput memory) {
        return MintData[index];
    }
    function getAssetIdIndex(uint256 index) public view  returns (string memory) {
        return MintData[index].assetId;
    }
    function getAssetTypeIndex(uint256 index) public view  returns (uint8) {
        return MintData[index].assetType;
    }

    function getMainDataLength() public view  returns(uint256) {
        return MintData.length;
    }
}