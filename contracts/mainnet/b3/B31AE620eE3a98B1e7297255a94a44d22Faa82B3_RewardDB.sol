/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: contracts/RewardDB.sol


pragma solidity ^0.8.5;




contract RewardDB is Ownable {

    struct reward
    {

        uint256 rewardId;
        uint256 rewardAmount;
        bool exist;
        bool enable;
        bool received;
        string rewardType;

    }


    struct winReward
    {
        uint256 rewardId;
        int256 x;
        int256 y;
        int256 z;
        
    }

    address private checkReward;


    mapping (address => bool )  private admins;

    mapping (uint256 => mapping (uint256 => reward)) public rewardInfo;

    mapping (uint256 => uint256) totalRewardAmount ;

    mapping (address => mapping (uint256 => mapping (int256 => mapping (int256 => mapping(int256 => uint256))))) public WinRewardId;

    mapping (address => mapping (uint256 => mapping( uint256 => winReward))) public WinRewardXYZ;


    modifier onlyOwnerOrAdmins()
    {
        require( msg.sender == owner() || admins[msg.sender] , " checkReward - onlyOwners - Owner/Admin Role Required." ) ;
        _;
    }

    modifier onlyCheckReward()
    {
        require ( msg.sender == checkReward , "only checkReward smart contract can call this function");
        _;
    }


    modifier onlyOwnerOrAdminsOrCheckReward()
    {
        require( msg.sender == owner() || admins[msg.sender] || msg.sender == checkReward, " checkReward - only Owners or Admins or CheckReward smart contract Role Required." ) ;
        _;
    }



    event AddAdminRole(address indexed adminAddress, string indexed role );
    event DelAdminRole(address indexed adminAddress, string indexed role );


    function addAdminRole ( address subject  ) external onlyOwner
    {

        admins[subject] = true ; 
        emit AddAdminRole( subject , "Admin" ) ; 

    }

    function removeAdminRole ( address subject  ) external onlyOwner
    {
        require ( subject != owner() , "NFT1155 - Owner Can't be Deleted" ) ; 
        admins[subject] = false ; 
        emit DelAdminRole( subject , "Admin") ; 

    }


    function setCheckRewardAddress (address _CheckReward ) external onlyOwner
    {
        require ( _CheckReward != address(0), " address shouldn't be 0 ");
        checkReward =_CheckReward;

    }


    function insertReward( uint256 _planetId, uint256 _rewardId , uint256 _rewardAmount , string memory _rewardType) external onlyOwnerOrAdmins returns(bool)
    {
        require ( rewardInfo[_planetId][_rewardId].exist == false , " reward Already Exist");
        require (_rewardId != 0 && _rewardAmount != 0 , " rewardId and rewardAmount shouldn't be 0");

        reward memory temp = reward( _rewardId , _rewardAmount  , true , true , false , _rewardType);
        rewardInfo[_planetId][_rewardId] = temp; 

        totalRewardAmount[_planetId]++;

        //  emit PrizeCreatedInXyz( _x, _y , _z , _tokenId, _tokenAmount);
       return true ;         
    }


    function getTotalRewardAmount (uint256 _planetId) external view onlyOwnerOrAdminsOrCheckReward returns (uint256)
    {

        return totalRewardAmount[_planetId];

    }
   

   function updateRewardInfo( uint256 _planetId, uint256 _rewardId , uint256 _rewardAmount , string memory _rewardType) external onlyOwnerOrAdmins returns(bool)
   {

        require ( rewardInfo[_planetId][_rewardId].exist == true , " reward dosn't Already Exist");
        require (_rewardId != 0 && _rewardAmount != 0 , " rewardId and rewardAmount shouldnt be 0");
        rewardInfo[_planetId][_rewardId].rewardAmount = _rewardAmount;
        rewardInfo[_planetId][_rewardId].rewardType = _rewardType;      

        return true;
   }


   function insertWinnerInfo( address _recipient, uint256 _planetId, int256 _x, int256 _y, int256 _z , uint256 _rewardId) external onlyCheckReward returns( bool)
   {
      
        WinRewardId[_recipient][_planetId][_x][_y][_z] = _rewardId; 

        winReward memory temp = winReward( _rewardId, _x  , _y , _z );
        WinRewardXYZ[ _recipient][_planetId][ _rewardId] = temp;

       return true;

   }


   function getWinRewardId (address _recipient, uint256 _planetId , int256 _x, int256 _y, int256 _z) external view onlyOwnerOrAdmins returns(uint256)
    {

        return WinRewardId[_recipient][_planetId][_x][_y][_z];

   }

   function getWinRewardXYZ (address _recipient, uint256 _planetId , uint256 _rewardId) external view onlyOwnerOrAdmins returns(winReward memory)
   {
       return WinRewardXYZ[_recipient][_planetId][_rewardId];
   }


   function setRewardRecieved(uint256 _planetId, uint256 _rewardId, bool _recieved) external onlyCheckReward returns( bool)
   {
       rewardInfo[_planetId][_rewardId].received = _recieved;
       return true; 
   }


   function getRewardInfo (uint256 _planetId, uint256 _rewardId) external onlyOwnerOrAdminsOrCheckReward view returns (reward memory)
   {
       reward memory rewardInfoTemp = rewardInfo[_planetId][_rewardId];
        return rewardInfoTemp; 

   }

}