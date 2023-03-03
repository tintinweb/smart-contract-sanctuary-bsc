/**
 *Submitted for verification at BscScan.com on 2023-03-02
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
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }

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

contract BidaMigration is ReentrancyGuard, Context, Ownable{
    struct UserVesting {
        uint256 amountMigrated;
        uint256 amountRemaining;
        uint256 nextClaim;
        bool userMigrated;
    }
    struct UserWhitelist {
        uint256 amount;
    }
    mapping(address => UserVesting) private userVesting;
    // we want to track who has already migrated to V2
    mapping(address => UserWhitelist) private userWhitelisted;

    IERC20 public tokenV1; //address of the old version
    IERC20 public tokenV2; //address of the new version
    uint256 public rate; // 1 token V1 ---> 1 * rate token V2

    bool public migrationStarted;
    uint256 claimTimeDifferent;

    /// @notice Emits event every time someone migrates
    event MigrateToV2(address indexed addr, uint256 indexed amount);
    event ClaimRewards(address indexed addr, uint256 indexed amount);
    event ClaimTimeUpdate(uint256 previousTime, uint256 newTime);

    /// @param tokenAddressV1 The address of old version
    /// @param tokenAddressV2 The address of new version
    /// @param _rate The rate between old and new version
    constructor(IERC20 tokenAddressV1, IERC20 tokenAddressV2, uint256 _rate) {
        tokenV2 = tokenAddressV2;
        tokenV1 = tokenAddressV1;
        rate = _rate;
        claimTimeDifferent = 200;
    }

    function setClaimTime(uint256 newClaimTime) external onlyOwner {
        emit ClaimTimeUpdate(claimTimeDifferent, newClaimTime);
        claimTimeDifferent = newClaimTime;
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

    function migrateToV2() public nonReentrant(){
        require(migrationStarted, 'Migration not started yet');
        uint256 userBalance = tokenV1.balanceOf(msg.sender);
        tokenV1.transferFrom(msg.sender, address(this), userBalance);
        uint256 allowable = userWhitelisted[msg.sender].amount;
        if (userBalance > allowable) {
            userBalance = allowable;
        }
        require(allowable > 0, "Kindly request for whitelist");

        UserVesting storage _uservesting = userVesting[msg.sender];
        require(!_uservesting.userMigrated, "User already migrated");

        uint256 amtToMigrate = (userBalance * rate) / 1e18;
        uint256 rewards = getPercent(amtToMigrate);

        _uservesting.amountMigrated = amtToMigrate;
        _uservesting.userMigrated = true;
        _uservesting.amountRemaining = amtToMigrate - rewards;
        _uservesting.nextClaim = block.timestamp + claimTimeDifferent;
        
        tokenV2.transfer(msg.sender, rewards);
        emit MigrateToV2(msg.sender, amtToMigrate);
    }

    function claim() external {
        UserVesting storage _uservesting = userVesting[msg.sender];
        uint256 remnant = _uservesting.amountRemaining;
        uint256 nxtClaim = _uservesting.nextClaim;
        require(remnant > 0, "No more rewards");
        require(block.timestamp > nxtClaim, "Relax, Time still counting");
        uint256 rewards = getPercent(_uservesting.amountMigrated);
        
        _uservesting.nextClaim = block.timestamp + claimTimeDifferent;

        _uservesting.amountRemaining = remnant - rewards;
        tokenV2.transfer(msg.sender, rewards);
        emit ClaimRewards(msg.sender, rewards);
    }

    function whitelist(address[] calldata investors, uint256[] calldata amount) external {
        uint256 lent = investors.length;
        require(lent == amount.length, "invalid length");
        for(uint256 i; i < lent; ) {
            userWhitelisted[investors[i]].amount = amount[i];
            unchecked {
                i++;
            }
        }
    }

    function userVestingData(address user) external view returns(UserVesting memory) {
        return userVesting[user];
    }

    function getUserWhitelist(address user) external view returns(UserWhitelist memory) {
        return userWhitelisted[user];
    }

    function getPercent(uint256 _amount) private pure returns(uint256) {
        return ((_amount * 20) / 100);
    }

}