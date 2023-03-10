/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title Migration contract
/// @notice A contract to migrate from old to new token version

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IERC20 {
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface V1AndV2 {
    function claimed(address user) external view returns (bool);
    function onlyRequire(address user) external view returns (bool);
}

/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}



contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BidaMigration is ReentrancyGuard, Context, Ownable{

    // we want to track who has already migrated to V2
    mapping(address => bool) public claimed;
    mapping(address => bool) public isExcluded;
    // mapping(address => bool) public onlyRequire;
    mapping(address => uint256) public myNextClaimTime;

    IERC20 public tokenV1; //address of the old version
    IERC20 public tokenV2; //address of the new version
    address private constant v1 = address(0xFF218559Ad9DA76c3673C5e26b7F4431E42Bf757);
    address private constant v2 = address(0xEA77e28BCF18A60bd7F6FC35942bA26244083175);
    uint256 public rate; // 1 token V1 ---> 1 * rate token V2
    uint256 public next;

    bool public migrationStarted;

    /// @notice Emits event every time someone migrates
    event MigrateToV2(address indexed addr, uint256 indexed amount);

    /// @param tokenAddressV1 The address of old version
    /// @param tokenAddressV2 The address of new version
    /// @param _rate The rate between old and new version
    constructor(IERC20 tokenAddressV1, IERC20 tokenAddressV2, uint256 _rate) {
        tokenV2 = tokenAddressV2;
        tokenV1 = tokenAddressV1;
        rate = _rate;
        next = 7 days;
    }

    function resetNext(uint256 nex) external onlyOwner{
        next = nex;
    }

    /// @notice Enables the migration
    function startMigration() external onlyOwner{
        require(migrationStarted == false, "Migration is already enabled");
        migrationStarted = true;
    }

    /// @notice Disable the migration
    function stopMigration() external onlyOwner{
        require(migrationStarted == true, "Migration is already disabled");
        migrationStarted = false;
    }

    /// @notice Updates "tokenV1", "tokenV2" and the "rate"
    /// @param _rate The rate between old and new version
    function setTokenRate(uint256 _rate) external onlyOwner{
        rate = _rate;
    }

    /// @notice Withdraws remaining tokens
    function withdrawTokens(IERC20 token, uint256 amount) external onlyOwner{
        token.transfer(msg.sender, amount );
    }

    /// @param v1amount The amount of tokens to migrate
    /// @notice Migrates from old version to new one
    ///   User must call "approve" function on tokenV1 contract
    ///   passing this contract address as "sender".
    ///   Old tokens will be sent to burn
    function migrateToV2(uint256 v1amount) public nonReentrant(){
        require(migrationStarted, 'Migration not started yet');
        require(V1AndV2(v2).onlyRequire(msg.sender), 'Forbidden');
        if (V1AndV2(v1).claimed(msg.sender) || claimed[msg.sender]) {
            if (!isExcluded[msg.sender]) {
                require(!V1AndV2(v1).claimed(msg.sender), "User already migrated");
                require(!claimed[msg.sender], "User already migrated");
            }
        }
        if(isExcluded[msg.sender]) {
            require( block.timestamp > myNextClaimTime[msg.sender], "Invalid Time");
        }
        myNextClaimTime[msg.sender] = block.timestamp + next;
        tokenV1.transferFrom(msg.sender, address(this), v1amount);
        uint256 amtToMigrate = (v1amount * rate) / 1e18;
        require(tokenV2.balanceOf(address(this)) >= amtToMigrate, 'No enough V2 liquidity');
        tokenV2.transfer(msg.sender, amtToMigrate);
        claimed[msg.sender] = true;
        emit MigrateToV2(msg.sender, amtToMigrate);
    }

    function excluded(address[] memory _excluded, bool status) external onlyOwner  {
        uint256 lent = _excluded.length;
        for (uint256 i; i < lent; ) {
            isExcluded[_excluded[i]] = status;
            unchecked {
                i++;
            }
        }
    }
}