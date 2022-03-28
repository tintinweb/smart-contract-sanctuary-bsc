/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

/**
 *Submitted for verification at Etherscan.io on 2022-03-28
*/

// SPDX-License-Identifier: none
pragma solidity ^0.6.0;

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return _sub(a, b, "SafeMath: subtraction overflow");
    }

    function _sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return _div(a, b, "SafeMath: division by zero");
    }

    function _div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return _mod(a, b, "SafeMath: modulo by zero");
    }

    function _mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity >=0.5.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
    
    function decimals() external view returns(uint8);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating wether the operation succeeded.
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
     * Returns a boolean value indicating wether the operation succeeded.
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


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

contract Ownable {
    
    address payable internal owner;

    modifier onlyOwner {
        require(msg.sender == owner, "Ownable: Only Owner"); 
        _;
    }
    
    /**
     * Event for Transfer Ownership
     * @param previousOwner : owner contract
     * @param newOwner : New Owner of contract
     * @param time : time when changeOwner function executed
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner, uint256 time);
    
    /**
     * Function to change contract Owner
     * Only Owner who could access this function
     * 
     * return event OwnershipTransferred
     */
    
    function transferOwnership(address payable _owner) onlyOwner external returns(bool) {
        owner = _owner;
        
        emit OwnershipTransferred(msg.sender, _owner, block.number);
        return true;
    }

    constructor() internal{
        owner = msg.sender;
    }
}

contract LitedexTokenMigrationV2 is Ownable{
    using SafeMath for uint256;

    struct users {
        bool isApproved;
        uint256 totalApproved;
        uint256 totalMigrated;
    }

    struct admins {
        address account;
        bool isApproved;
    }
    mapping (address => users) private whitelist;
    mapping (address => admins) private roleAdmins;

    uint private totalWhitelist;
    uint private hasMigrated;
    uint private shouldMigrated;

    IBEP20 private olderToken;
    IBEP20 private newToken;
    
    uint256 private rate = 1;
    bool private migrationStatus = false;

    uint256 private allocation;
    
    modifier whileOpen{
        require(migrationStatus, "Migration is paused");
        _;
    }
    modifier isWhitelist{
            require(isWhitelisted(msg.sender), "Not Whitelist");
        _;
    }
    modifier onlyAdmin {
        require(msg.sender == roleAdmins[msg.sender].account && roleAdmins[msg.sender].isApproved == true || msg.sender == owner, "Only Owner or Admin");
        _;
    }

    event Migrate(address indexed _account, uint256 _totalAmountTokens, uint256 _getAmountTokens, uint256 _time);
    
    event MigrationOpened(uint256 _time);
    event MigrationClosed(uint256 _time);

    event AddAllocation(uint256 _amount, uint256 _time);
    event RemoveAllocation(uint256 _amount, uint256 _time);
    event SetAdmin(address indexed _account, bool _status, uint256 _time);
    event SetWhitelist(address indexed _account, bool _status, uint256 _totalApproved, uint256 _time);
    
    constructor(address _olderToken, address _newToken) public {
        olderToken = IBEP20(_olderToken);
        newToken = IBEP20(_newToken);
    }
    function checkWhitelist(address _account) external view returns(bool){
        return(isWhitelisted(_account));
    }
    function isWhitelisted(address _account) private view returns(bool){
        return whitelist[_account].isApproved;
    }
    function getTotalWhitelist() external view returns(uint){
        return totalWhitelist;
    }
    function getTotalHasMigrated() external view returns(uint){
        return hasMigrated;
    }
    function shouldBeMigrated() external view returns(uint){
        return shouldMigrated;
    }
    function getDataWhitelist(address _account) external view returns(
        uint256 tApproved, uint256 tMigrated
    ){
        return(
            whitelist[_account].totalApproved,
            whitelist[_account].totalMigrated
        );
    }
    function addAllocation(uint256 _amount) external onlyOwner returns(bool){
        require(_amount > 0, "Amount is 0");
        
        emit AddAllocation(_amount, block.timestamp);
        newToken.transferFrom(msg.sender, address(this), _amount);
        allocation = allocation.add(_amount);
    }

    function removeAllocation(uint256 _amount) external onlyOwner returns(bool){
        require(_amount > 0, "Amount is 0");
        require(_amount <= allocation, "_amount higher than allocation");

        emit RemoveAllocation(_amount, block.timestamp);
        newToken.transfer(msg.sender, _amount);
        allocation = allocation.sub(_amount);
    }

    function getAllocation() external view returns(uint256){
        return allocation;
    }

    function getRate() external view returns(uint256){
        return rate;
    }

    function setWhitelist(address _account, bool _status, uint256 _totalApproved) external onlyAdmin returns(bool){
        require(_account != address(0), "Account is zero address");

        emit SetWhitelist(_account, _status, _totalApproved, block.timestamp);
        whitelist[_account].isApproved = _status;
        whitelist[_account].totalApproved = _totalApproved;
        shouldMigrated = shouldMigrated.add(_totalApproved);

        if(_status){
            totalWhitelist = totalWhitelist.add(1);
        }else {
            totalWhitelist = totalWhitelist.sub(1);
        }
        return true;
    }
    function incTotalApproved(address _account, uint256 _incAmount) external onlyOwner returns(bool){
        whitelist[_account].totalApproved = whitelist[_account].totalApproved.add(_incAmount);
        return true;
    }
    
    function decTotalApproved(address _account, uint256 _decAmount) external onlyOwner returns(bool){
        whitelist[_account].totalApproved = whitelist[_account].totalApproved.sub(_decAmount);
        return true;
    }

    function setAdmin(address payable _account, bool _status) external onlyOwner returns(bool){
        require(_account != address(0), "Account is zero address");

        emit SetAdmin(_account, _status, block.timestamp);
        roleAdmins[_account].account = _account;
        roleAdmins[_account].isApproved = _status;
        return true;
    }

    function _getToken(address _account) private view returns(uint256) {
         return olderToken.balanceOf(_account).mul(rate);
    }
     
    function setRate(uint256 _newRate) external onlyOwner returns(bool){
         require(_newRate > 0, "New rate is zero");

         rate = _newRate;
         return true;
    }

    function setMigrationStatus(bool _status) external onlyOwner returns(bool){
        require(_status != migrationStatus, "Status is same as migration status");
         if(_status) {
             emit MigrationOpened(block.timestamp);
         }else{
             emit MigrationClosed(block.timestamp);
         }
         migrationStatus = _status;
         return true;
    }

    function getMigrationStatus() external view returns(bool){
        return migrationStatus;
    }
    
    function migrate() external whileOpen isWhitelist returns(bool){
         uint256 _get = _getToken(msg.sender); 
         uint256 _approved = whitelist[msg.sender].totalApproved;
         uint256 _migrated = whitelist[msg.sender].totalMigrated;

         if(_get > _approved){
             _get = _approved;
         }
         _get = _get.sub(_migrated);
         require(_get > 0 , "has migrate all");

         olderToken.transferFrom(msg.sender, address(this), _get) ;
         newToken.transfer(msg.sender, _get);
         
         whitelist[msg.sender].totalMigrated = whitelist[msg.sender].totalMigrated.add(_get);
         hasMigrated = hasMigrated.add(_get);

         emit Migrate(msg.sender, _get.div(rate), _get, block.timestamp);
         return true;
    }
    
    function redeemOlderToken(address _to) external onlyOwner returns(bool){
        require(!migrationStatus, "Migration has started");
        return _pay(olderToken, _to);
    }

    function redeemNewToken(address _to) external onlyOwner returns(bool){
        require(!migrationStatus, "Migration has started");
        return _pay(newToken, _to);
    }

    function _pay(IBEP20 _token, address _to) private returns (bool){
        return(_token.transfer(_to, _token.balanceOf(address(this))));
    }
}