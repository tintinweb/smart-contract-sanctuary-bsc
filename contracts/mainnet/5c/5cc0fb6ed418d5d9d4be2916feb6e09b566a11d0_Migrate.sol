/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-10
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
    address private _previousOwner;

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

}

contract Migrate is ReentrancyGuard, Context, Ownable{

    // we want to track who has already migrated to V2
    mapping(address => bool) private claimed;

    IERC20 public tokenV1; //address of the old version
    IERC20 public tokenV2; //address of the new version
    uint256 public rate; // 1 token V1 ---> 1 * rate token V2

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
        tokenV1.transferFrom(msg.sender, address(this), v1amount);
        uint256 amtToMigrate = (v1amount * rate) / 1e18;
        require(tokenV2.balanceOf(address(this)) >= amtToMigrate, 'No enough V2 liquidity');
        tokenV2.transfer(msg.sender, amtToMigrate);
        emit MigrateToV2(msg.sender, amtToMigrate);
    }

}