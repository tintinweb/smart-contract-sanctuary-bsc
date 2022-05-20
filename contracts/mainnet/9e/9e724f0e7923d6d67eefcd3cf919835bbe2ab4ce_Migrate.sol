/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


abstract contract Context 
{
    function _msgSender() internal view virtual returns (address payable) 
    {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) 
    {
        this; 
        return msg.data;
    }
}


interface IERC20 
{
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


abstract contract ReentrancyGuard 
{
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() 
    {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


contract Ownable is Context 
{
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () 
    {
        address msgSender = 0xb8DE45f6150Bd0ABd946cf8C2d3597352a963666;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) 
    {
        return _owner;
    }

    modifier onlyOwner() 
    {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner 
    {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner 
    {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

contract Migrate is ReentrancyGuard, Context, Ownable
{

    mapping(address => bool) private claimed;
    address public immutable deadWallet = 0x000000000000000000000000000000000000dEaD;
    IERC20 public tokenV1; //address of the old version
    IERC20 public tokenV2; //address of the new version
    uint256 public rate; // 1 token V1 ---> 1 * rate token V2
    bool public migrationStarted;
    event MigrateToV2(address addr, uint256 amount);

    constructor() 
    { 
        tokenV1 = IERC20(0x23B3B5242244b3b346a08810B494cc8D02f9883d);
        tokenV2 = IERC20(0x819dD0B6e868dF9a80e78459a4Cb13c64826DF1A); 
        rate = 1;
    }

    /// @notice Enables the migration
    function startMigration() external onlyOwner 
    {
        require(migrationStarted == false, "Migration is already enabled");
        migrationStarted = true;
    }

    /// @notice Disable the migration
    function stopMigration() external onlyOwner 
    {
        require(migrationStarted == true, "Migration is already disabled");
        migrationStarted = false;
    }


    function setMigrationPrameters(address _v1, address _v2, uint256 _rate) external onlyOwner 
    { 
        tokenV1 = IERC20(_v1); //
        tokenV2 = IERC20(_v2);  //SIJ
        rate = _rate;
    }


    /// @notice Withdraws remaining tokens
    function withdrawTokens(uint256 amount) external onlyOwner 
    {
        require(migrationStarted == false, "Impossible to withdraw tokens if migration still enabled");
        tokenV2.transfer(msg.sender, amount * 10**(tokenV2.decimals()));
    }


    function migrateToV2(uint256 v1amount) public nonReentrant
    {
        require(migrationStarted == true, 'Migration not started yet');
        uint256 amount = v1amount * 10 ** tokenV1.decimals();
        uint256 userV1Balance = tokenV1.balanceOf(msg.sender);
        require(userV1Balance >= amount, 'You must hold V1 tokens to migrate');
        uint256 amtToMigrate = v1amount * rate * 10 ** tokenV2.decimals();
        require(tokenV2.balanceOf(address(this)) >= amtToMigrate, 'No enough V2 liquidity');
        tokenV1.transferFrom(msg.sender, deadWallet, amount);
        tokenV2.transfer(msg.sender, amtToMigrate);
        emit MigrateToV2(msg.sender, amtToMigrate);
    }


}