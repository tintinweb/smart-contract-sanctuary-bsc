// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./StakingData.sol";

contract ManagementStakingForm is Ownable {

    uint256 public minAmountFlex;
    uint256 public maxAmountFlex;
    uint256 public maxTotalAmountFlex;
    bool public isStakeFlex;
    bool public isStakeLock;
    address public treasury;
    address public manager;
    StakingData.PackLock public minPackLock;
    StakingData.PackFlex[] public packsFlex;
    StakingData.PackLock[] public packsLock;

    constructor( address _manager, address _treasury) {
        require(_manager!= address(0),
            "Formation.Fi: zero address");
        require(_treasury!= address(0),
            "Formation.Fi: zero address");
        manager = _manager;
        treasury = _treasury; 
    }

    modifier onlyManager() {
        require(msg.sender == manager , 
            "Formation.Fi: not manager");
        _;
    }
   
    function getSizePacksFlex() public view returns(uint256) {
        return packsFlex.length;
    }

    function getSizePacksLock() public view returns(uint256) {
        return packsFlex.length;
    }

    function getPacksFlex( uint256 _id) public view returns(StakingData.PackFlex memory) {
        return packsFlex[_id];
    }

    function getPacksLock( uint256 _id) public view returns(StakingData.PackLock memory) {
        return packsLock[_id];
    }


    function addPackFex( StakingData.PackFlex memory _packFlex) public onlyManager {
        _packFlex.startTime = block.timestamp;
        if (_packFlex.isCompoundInterest){
            require(_packFlex.compoundFrequency > 0,
            "Formation.Fi: zero frequency");
        }
        packsFlex.push(_packFlex);
    }

    function addPackLock( StakingData.PackLock memory _packLock) public onlyManager {
        require(_packLock.minAmount < _packLock.maxAmount, 
            "Formation.Fi: max amount");
        require(_packLock.maxAmount <= _packLock.maxTotalAmount,
            "Formation.Fi: max total amount");
        packsLock.push(_packLock);
    }

    function setMinPackLock( StakingData.PackLock memory _minPackLock) public onlyManager {
        require(_minPackLock.minAmount < _minPackLock.maxAmount, 
            "Formation.Fi: max amount");
        require(_minPackLock.maxAmount <= _minPackLock.maxTotalAmount,
            "Formation.Fi: max total amount");
        minPackLock = _minPackLock;
    }

    function setMinAmountFlex(uint256 _minAmountFlex) public onlyManager {
        minAmountFlex = _minAmountFlex;
    }

    function setMaxAmountFlex(uint256 _maxAmountFlex) public onlyManager {
        require(_maxAmountFlex <= maxTotalAmountFlex,
            "Formation.Fi: max total amount");
        maxAmountFlex = _maxAmountFlex;
    }
    function setMaxTotalAmountFlex(uint256 _maxTotalAmountFlex) public onlyManager {
        require(maxAmountFlex <= _maxTotalAmountFlex,
            "Formation.Fi: max total amount");
        maxTotalAmountFlex = _maxTotalAmountFlex;
    }

    function setIsStakeFlex(bool _isStakeFlex) public onlyManager {
        isStakeFlex = _isStakeFlex;
    }

    function setIsStakeLock(bool _isStakeLock) public onlyManager {
        isStakeLock = _isStakeLock;
    }

    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0),
            "Formation.Fi: zero address");
        treasury = _treasury;
    }

    function setManager(address _manager) external onlyOwner {
        require(_manager != address(0),
            "Formation.Fi: zero address");
        manager = _manager ;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
library StakingData {
    uint256 public constant COEFF_SCALE_DECIMALS = 1e18;

    struct PackFlex {
        uint256 rewardsRate;
        uint256 startTime;
        uint256 compoundFrequency;
        bool isCompoundInterest;
    }

    struct PackLock {
        uint256 rewardsRate;
        uint256 startTime;
        uint256 stakingPeriod;
        uint256 minAmount;
        uint256 maxAmount;
        uint256 maxTotalAmount;
        uint256 earlyWithdrawalFee;
        uint256 compoundFrequency;
        bool isEarlyWithdrawal;
        bool isCompoundInterest;
    }

    struct StakeFlex {
        uint256 amount;
        uint256 time;
    }

    struct StakeLock {
        uint256 id_pack;
        uint256 amount;
        uint256 time;
    }


    struct Data {
        uint256 alpha;
        uint256 beta;
        uint256 gamma;
    }


}

// SPDX-License-Identifier: MIT
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