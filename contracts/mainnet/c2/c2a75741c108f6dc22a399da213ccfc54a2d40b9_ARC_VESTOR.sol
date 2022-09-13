/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.15;

interface IBEP20 
{
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context 
{
    function _msgSender() internal view virtual returns (address) 
    {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) 
    {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(0x8bF8De4c3C36746386a94f55719d69201E4F883D);
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

    function renounceOwnership() external virtual onlyOwner {
        _setOwner(address(0));
    }


    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private 
    {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

}



contract ARC_VESTOR is Ownable 
{
    using SafeMath for uint256;
    mapping(address => uint256) internal _initialBalance;  
    mapping(address => uint256) private _balances;

    mapping(address => uint256) private _lastTxTimestamp;

    mapping(address => uint256) private _vestingPeriod;
    mapping(address => uint256) private _vestingTimestamp;

    mapping(address => uint256) private _allowedPercentage;

    mapping(address => uint256) private _lockPeriod;

    address[] private _vestorsAddresses;

    address arc_address = 0x07fbD9A52c3afa82108a85adA1977cc0F0B375e1;
    IBEP20 arcToken;
    
    uint256 lockPeriodDefaultValue;
    uint256 vestingPeriodDefaultValue;
    uint256 allowedPercentageDefaultValue;
    uint256 totalVestedAmount = 0;

    constructor()
    {
       arcToken = IBEP20(arc_address);
       lockPeriodDefaultValue = 30 days;
       allowedPercentageDefaultValue = 10;
       vestingPeriodDefaultValue = 30 days;
    }



    function checkIncludeAddress(address account) internal 
    {
        if(_balances[account]==0)  
        {
            _vestorsAddresses.push(account);
        }
    }

    function checkExcludAddress(address account) internal 
    {
        if(_balances[account]==0)  
        {
            _vestorsAddresses.push(account);
            for (uint256 i = 0; i < _vestorsAddresses.length; i++) 
            {
                if (_vestorsAddresses[i] == account) 
                {
                    _vestorsAddresses[i] = _vestorsAddresses[_vestorsAddresses.length - 1];
                    _vestorsAddresses.pop();
                    break;
                }
            }
        }
    }


    function vestARC(uint256 _amount) external 
    {
        require(_balances[msg.sender]==0, "You have already vested your tokens. You can try again after complete withdraw.");
        checkIncludeAddress(msg.sender);

        arcToken.transferFrom(msg.sender, address(this), _amount);
        _initialBalance[msg.sender] = _amount;
        _balances[msg.sender] = _amount;
        _vestingTimestamp[msg.sender] = block.timestamp;
        _allowedPercentage[msg.sender] = allowedPercentageDefaultValue;
        _lockPeriod[msg.sender] =  lockPeriodDefaultValue;
        _vestingPeriod[msg.sender] = vestingPeriodDefaultValue;
        totalVestedAmount = totalVestedAmount+_amount;
    }


    function vestArcForMember(uint256 _amount, address memberAddress) external 
    {
        require(_balances[memberAddress]==0, "You have already vested your tokens for this member.");
        checkIncludeAddress(memberAddress);
        arcToken.transferFrom(msg.sender, address(this), _amount);
        _initialBalance[memberAddress] = _amount;
        _balances[memberAddress] = _amount;
        _vestingTimestamp[memberAddress] = block.timestamp;
        _allowedPercentage[memberAddress] = allowedPercentageDefaultValue;
        _lockPeriod[memberAddress] =  lockPeriodDefaultValue;
        _vestingPeriod[memberAddress] = vestingPeriodDefaultValue;
        totalVestedAmount = totalVestedAmount+_amount;
    }


    function withdrawARC(uint256 _amount) external 
    {
        uint256 lockSpan = block.timestamp-_vestingTimestamp[msg.sender];
        require(lockSpan>_lockPeriod[msg.sender], "Lock period is not yet completed.");
        uint256 txSpan = block.timestamp-_lastTxTimestamp[msg.sender];
        require(txSpan>_vestingPeriod[msg.sender], "Vesting period is not yet completed.");
        uint256 allowed_amount = (_initialBalance[msg.sender]).mul(_allowedPercentage[msg.sender]).div(100);
        require(_amount<=allowed_amount, "You cannot withdraw more than allowed amount.");
        require(_amount<=_balances[msg.sender], "You cannot withdraw more than your balance");
        arcToken.transfer(msg.sender, _amount);
        _balances[msg.sender] = _balances[msg.sender]-_amount;
        _lastTxTimestamp[msg.sender] = block.timestamp;
        totalVestedAmount = totalVestedAmount-_amount;
        checkExcludAddress(msg.sender);
    }


    function totalVestors() external view returns (uint256)
    {
        return _vestorsAddresses.length;
    }


    function balanceOf(address account) external view returns(uint256)
    {
        return  _balances[account];
    }

    function getAllowedWithdralPercentage(address account) external view returns(uint256)
    {
        return   _allowedPercentage[account];
    }

    function getLockPeriodInDays(address account) external view returns(uint256)
    {
        return  _lockPeriod[account].div(86400);
    }

    function getVestingPeriodInDays(address account) external view returns(uint256)
    {
        return   _vestingPeriod[account].div(86400);
    }


    function setDefaultValues(uint256 lockPeriodInDays, uint256 vestingPeriodInDays,  uint256  defaultPercentage) 
    external onlyOwner
    {
       lockPeriodDefaultValue = lockPeriodInDays*86400;
       vestingPeriodDefaultValue = vestingPeriodInDays*86400;
       allowedPercentageDefaultValue =  defaultPercentage;
    }


    function setAllowedPercentage(address account, uint256  allowedPercentage) 
    external onlyOwner
    {
        _allowedPercentage[account] = allowedPercentage;
    }

    function setLockPeriodInDays(address account, uint256  lockPeriod) 
    external onlyOwner
    {
        _lockPeriod[account] = lockPeriod*86400;
    }

    function setVestingPeriodInDays(address account, uint256  vestingPeriod) 
    external onlyOwner
    {
        _vestingPeriod[account] = vestingPeriod*86400;
    }


}