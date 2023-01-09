// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";
import "./FarmCore.sol";

contract Farm is Ownable, FarmCore {

    /**
     * @dev Struct variable type
     */
    struct Deposit {
        uint256 amountFirst;
        uint256 amountSecond;
    }

    struct Withdrawal {
        uint256 farmPoolId;
        uint256 amountFirst;
        uint256 amountSecond;
    }

    struct User {
        address referral;
        bool isBlocked;
        uint256 depositCount;
        uint256 withdrawCount;
        mapping(uint256 => Deposit) deposits;
        mapping(uint256 => Withdrawal) withdrawals;
    }

    /**
     * @dev Mapping data for quick access by index or address.
     */
    mapping(address => User) public users;

    /**
     * @dev All events. Used to track changes in the contract
     */
    event NewDeposit(address indexed user, uint256 amountFirst, uint256 amountSecond);
    event NewWithdraw(address indexed user, uint256 amountFirst, uint256 amountSecond, uint256 farmPoolId);
    event UserBlocked(address indexed user);
    event UserUnblocked(address indexed user);
    event NewUser(address indexed user, address indexed referral);

    bool private itialized;

    /**
     * @dev Initial setup.
     */
    function initialize() external virtual {
        require(itialized != true, 'FarmContract: already initialized');
        itialized = true;
        initOwner(_msgSender());
        addAdmin(_msgSender());
        MINTVL = 50000000000000000000000;
        CAPY = 2000000000000000000;
        MINAPY = 2000000000000000000;
        servicePercent = 1000000000000000000;
    }

    /**
     * @dev Block user by address.
     *
     * NOTE: Can only be called by the admin address.
     */
    function blockUser(address _address) external onlyWhenServiceEnabled onlyAdmin {
        users[_address].isBlocked = true;
        emit UserBlocked(_address);
    }

    /**
     * @dev Unblock user by address.
     *
     * NOTE: Can only be called by the admin address.
     */
    function unblockUser(address _address) external onlyWhenServiceEnabled onlyAdmin {
        users[_address].isBlocked = false;
        emit UserUnblocked(_address);
    }

    /**
     * @dev Create new (`User`) object by address.
     *
     * Emits a {NewUser} event.
     *
     * NOTE: Only internal call.
     */
    function createNewUser(address _referral) private {
        users[_msgSender()].referral = _referral;
        users[_msgSender()].isBlocked = false;
        users[_msgSender()].depositCount = 0;
        users[_msgSender()].withdrawCount = 0;

        emit NewUser(_msgSender(), _referral);
    }

    /**
     * @dev To call this method, certain conditions are required, as described below:
     * 
     * Checks if user isn't blocked;
     * Checks if (`_amountFirst`) or (`_amountSecond`) is greater than zero;
     * Checks if contact has required amount of token for transfer from current caller;
     * Checks if farm pool is active;
     * Checks if farm pool is not moving;
     *
     * Transfers the amount of tokens to the current deposit pool.
     * 
     * If its called by new address then new user will be created.
     * 
     * Creates new object of (`Deposit`) struct.
     *
     * Emits a {NewDeposit} event.
     */
    function deposit(
        uint256 _amountFirst,
        uint256 _amountSecond,
        uint256 _farmPoolId,
        address _referral
    ) external onlyWhenServiceEnabled {

        require(users[_msgSender()].isBlocked == false, "FarmContract: User blocked");
        require(_amountFirst > 0 || _amountSecond > 0, "FarmContract: Zero amount");
        require(farmPools[_farmPoolId].isActive, "FarmContract: No active Farm Pools");
        require(farmPools[_farmPoolId].isFarmMoving == false, "FarmContract: Farm pool is moving");

        if (users[_msgSender()].depositCount == 0) {
            createNewUser(_referral);
        }

        if (_amountFirst > 0 ) {
            users[_msgSender()].deposits[_farmPoolId].amountFirst += _amountFirst;

            _transferTokens(
                farmPools[_farmPoolId].firstToken,
                farmPools[_farmPoolId].depositAddress,
                _amountFirst
            );
        }

        if (_amountSecond > 0 ) {
            users[_msgSender()].deposits[_farmPoolId].amountSecond += _amountSecond;
            _transferTokens(
                farmPools[_farmPoolId].secondToken,
                farmPools[_farmPoolId].depositAddress,
                _amountSecond
            );
        }

        users[_msgSender()].depositCount += 1;

        emit NewDeposit(_msgSender(), _amountFirst, _amountSecond);
    }

    /**
     * @dev Transfers tokens to deposit address.
     * Internal function without access restriction.
     */
    function _transferTokens(IERC20 _token, address _depositAddress, uint256 _amount) internal virtual {
        uint256 allowance = _token.allowance(_msgSender(), address(this));
        require(allowance >= _amount, "FarmContract: Recheck the token allowance");
        (bool sent) = _token.transferFrom(_msgSender(), _depositAddress, _amount);
        require(sent, "FarmContract: Failed to send tokens");
    }

    /**
     * @dev To call this method, certain conditions are required, as described below:
     * 
     * Checks if user isn't blocked;
     * Checks if (`_amountFirst`) or (`_amountSecond`) is greater than zero;
     * Checks if farm pool is not moving;
     *
     * Creates new object of (`Withdrawal`) struct.
     *
     * If its called by new address then new user will be created.
     *
     * Can be called an infinite number of times. Balances are validated in API
     *
     * Emits a {NewWithdraw} event.
     */
    function withdraw(
        uint256 _farmPoolId,
        uint256 _amountFirst,
        uint256 _amountSecond,
        address _referral
    ) external onlyWhenServiceEnabled {

        require(users[_msgSender()].isBlocked == false, "FarmContract: User blocked");
        require(_amountFirst > 0 || _amountSecond > 0, "FarmContract: Zero amount");
        require(farmPools[_farmPoolId].isFarmMoving == false, "FarmContract: Farm pool is moving");

        if (users[_msgSender()].withdrawCount == 0 && users[_msgSender()].depositCount == 0) {
            createNewUser(_referral);
        }
        
        users[_msgSender()].withdrawals[users[_msgSender()].withdrawCount] = Withdrawal(_farmPoolId, _amountFirst, _amountSecond);
        users[_msgSender()].withdrawCount += 1;

        emit NewWithdraw(_msgSender(), _amountFirst, _amountSecond, _farmPoolId);
    }

    /**
     * @dev Returns the user (`Deposit`) object.
     */
    function getUserDeposit(
        address _userAddress,
        uint256 _farmPoolId
    ) external view returns (Deposit memory) {
        return users[_userAddress].deposits[_farmPoolId];
    }

    /**
     * @dev Returns the user (`Withdrawal`) object.
     */
    function getUserWithdraw(
        address _userAddress,
        uint256 _withdrawId
    ) external view returns (Withdrawal memory) {
        return users[_userAddress].withdrawals[_withdrawId];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";
import "./Ownable.sol";
import "./IERC20.sol";

abstract contract FarmCore is Context, Ownable {

     /**
     * @dev Enum variable type
     */
    enum Network{ BSC, AVAX }

    /**
     * @dev Struct variable type
     */
    struct FarmService {
        string name;
        Network network;
        bool isActive;
    }

    struct FarmPair {
        uint256 farmServiceId;
        uint256 farmPoolId;
        address contractAddress;
        Network network;
        bool isActive;
    }

    struct FarmPool {
        uint256 farmPairId;
        string name;
        address depositAddress;
        address withdrawAddress;
        IERC20 firstToken;
        IERC20 secondToken;
        bool isActive;
        bool isFarmMoving;
    }

     /**
     * @dev Mapping data for quick access by index or address.
     */
    mapping(uint256 => FarmService) public farmServices;
    mapping(uint256 => FarmPair) public farmPairs;
    mapping(uint256 => FarmPool) public farmPools;

    /**
     * @dev Counters for mapped data. Used to store the length of the data.
     */
    uint256 public farmPairsCount;
    uint256 public farmPoolsCount;
    uint256 public farmServicesCount;

    /**
     * @dev All events. Used to track changes in the contract
     */
    event AdminIsAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event MINTVLUpdated(uint256 value);
    event CAPYUpdated(uint256 value);
    event MINAPYUpdated(uint256 value);
    event ServiceDisabled();
    event ServiceEnabled();
    event FarmServiceChanged(string name, Network network);
    event FarmPoolChanged(string name);
    event FarmPairChanged(uint256 farmPairId, address indexed contractAddress);
    event FarmToFarmMovingStart(uint256 time, uint256 farmPairId);
    event FarmToFarmMovingEnd(uint256 time, uint256 farmPairId);

    /**
     * @dev Admins data
     */
    mapping(address => bool) public isAdmin;
    address[] public adminsList;
    uint256 public adminsCount;

    /**
     * @dev Core data
     */
    bool public serviceDisabled;
    uint256 public MINTVL;
    uint256 public CAPY;
    uint256 public MINAPY;
    uint256 public servicePercent;

    /**
     * @dev Throws if called when variable (`serviceDisabled`) is equals (`true`).
     */
    modifier onlyWhenServiceEnabled() {
        require(serviceDisabled == false, "FarmContract: Currently service is disabled. Try again later.");
        _;
    }

    /**
     * @dev Throws if called by any account other than the admin.
     */
    modifier onlyAdmin() {
        require(isAdmin[msg.sender] == true, "Access denied!");
        _;
    }

    /**
     * @dev Set deposit address.
     *
     * NOTE: Can only be called by the current owner.
     */
    function setDepositAddress(uint256 _farmPoolId, address _address) external onlyWhenServiceEnabled onlyOwner {
       farmPools[_farmPoolId].depositAddress = _address;
    }

    /**
     * @dev Set withdraw address.
     *
     * NOTE: Can only be called by the current owner.
     */
    function setWithdrawAddress(uint256 _farmPoolId, address _address) external onlyWhenServiceEnabled onlyOwner {
       farmPools[_farmPoolId].withdrawAddress = _address;
    }

    /**
     * @dev Set service percent.
     *
     * NOTE: Can only be called by the admin.
     */
    function setServicePercent(uint256 _percent) external onlyWhenServiceEnabled onlyAdmin {
       servicePercent = _percent;
    }

    /**
     * @dev Start moving farm to farm.
     *
     * NOTE: Can only be called by the current owner.
     */
    function startFarmToFarm(uint256 _farmPoolId, uint256 _newFarmPairId) external onlyWhenServiceEnabled onlyOwner {
        farmPools[_farmPoolId].farmPairId = _newFarmPairId;
        farmPools[_farmPoolId].isFarmMoving = true;
        emit FarmToFarmMovingStart(block.timestamp, _farmPoolId);
    }

    /**
     * @dev End moving farm to farm.
     *
     * NOTE: Can only be called by the current owner.
     */
    function endFarmToFarm(uint256 _farmPoolId) external onlyWhenServiceEnabled onlyOwner {
         farmPools[_farmPoolId].isFarmMoving = false;
        emit FarmToFarmMovingEnd(block.timestamp, _farmPoolId);
    }

    /**
     * @dev Gives administrator rights to the address.
     *
     * NOTE: Can only be called by the current owner.
     */
    function addAdmin(address _address) public onlyWhenServiceEnabled onlyOwner {
        adminsList.push(_address);
        isAdmin[_address] = true;
        adminsCount++;
        emit AdminIsAdded(_address);
    }

    /**
     * @dev Removes administrator rights from the address.
     *
     * NOTE: Can only be called by the current owner.
     */
    function removeAdmin(address _address, uint256 _index) external onlyWhenServiceEnabled onlyOwner {
        isAdmin[_address] = false;
        adminsList[_index] = adminsList[adminsList.length - 1];
        adminsList.pop();
        adminsCount--;
        emit AdminRemoved(_address);
    }

    /**
     * @dev Disable all callable methods of service except (`enableService()`).
     *
     * NOTE: Can only be called by the admin address.
     */
    function disableService() external onlyWhenServiceEnabled onlyAdmin {
        serviceDisabled = true;
        emit ServiceDisabled();
    }

    /**
     * @dev Enable all callable methods of service.
     *
     * NOTE: Can only be called by the admin address.
     */
    function enableService() external onlyAdmin {
        serviceDisabled = false;
        emit ServiceEnabled();
    }

    /**
     * @dev Sets new value for (`MINTVL`) variable.
     *
     * NOTE: Can only be called by the admin address.
     */
    function setMINTVL(uint256 _value) external onlyWhenServiceEnabled onlyAdmin {
        MINTVL = _value;
        emit MINTVLUpdated(_value);
    }

    /**
     * @dev Sets new value for (`CAPY`) variable.
     *
     * NOTE: Can only be called by the admin address.
     */
    function setCAPY(uint256 _value) external onlyWhenServiceEnabled onlyAdmin {
        CAPY = _value;
        emit CAPYUpdated(_value);
    }

    /**
     * @dev Sets new value for (`MINAPY`) variable.
     *
     * NOTE: Can only be called by the admin address.
     */
    function setMINAPY(uint256 _value) external onlyWhenServiceEnabled onlyAdmin {
        MINAPY = _value;
        emit MINAPYUpdated(_value);
    }

    /**
     * @dev Adds or update (`FarmService`) object.
     *
     * NOTE: Can only be called by the admin address.
     */
    function setFarmService(
        uint256 _id,
        string memory _name,
        Network _network,
        bool _isActive
    ) external onlyWhenServiceEnabled onlyAdmin {

        if (bytes(farmServices[_id].name).length == 0) {
            farmServicesCount++;
        }

        farmServices[_id] = FarmService(_name, _network, _isActive);

        emit FarmServiceChanged(_name, _network);
    } 

    /**
     * @dev Adds or update (`Farm Pool`) object.
     *
     * NOTE: Can only be called by the admin address.
     */
    function setFarmPool(
        uint256 _id,
        uint256 _farmPairId,
        string memory _name,
        IERC20 _firstToken,
        IERC20 _secondToken,
        bool _isActive
    ) external onlyWhenServiceEnabled onlyAdmin {

        if (bytes(farmPools[_id].name).length == 0) {
            farmPoolsCount++;
        }

        farmPools[_id] = FarmPool(
            _farmPairId,
            _name,
            farmPools[_id].depositAddress,
            farmPools[_id].withdrawAddress,
            _firstToken,
            _secondToken,
            _isActive,
            farmPools[_id].isFarmMoving
        );

        emit FarmPoolChanged(_name);
    } 

    /**
     * @dev Adds or update (`Farm Pair`) object.
     *
     * NOTE: Can only be called by the admin address.
     */
    function setFarmPair(
        uint256 _id,
        uint256 _farmServiceId,
        uint256 _farmPoolId,
        address _contractAddress,
        Network _network,
        bool _isActive
    ) external onlyWhenServiceEnabled onlyAdmin {

        require(farmServices[_farmServiceId].isActive == true, "Farm service with this ID does not exist or inactive!");

        if (farmPairs[_id].contractAddress == address(0)) {
            farmPairsCount++;
        }

        farmPairs[_id] = FarmPair(
            _farmServiceId,
            _farmPoolId,
            _contractAddress,
            _network,
            _isActive
        );

        emit FarmPairChanged(_id, _contractAddress);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";

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

    bool private ownableOnitialized;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function initOwner(address _address) internal virtual {
        require(ownableOnitialized != true, 'Ownable: already initialized');
        ownableOnitialized = true;
        _transferOwnership(_address);
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