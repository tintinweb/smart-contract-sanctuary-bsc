/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

pragma solidity 0.8.15;

//SPDX-License-Identifier: MIT Licensed

interface IERC20  {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool); 

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); 
} 
contract SHIBURAIVESTKEEPER {
    using SafeMath for uint256;

    IERC20 public shiburai;
    address public owner;
    uint256 public withdrawAmount;
    uint256 public withdrawTime;
    uint256 public maxHoldings;
    bool public withdrawEnabled;
    uint256 public contractShiburaiBalance;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public lastWithdraw; 
    mapping(address => uint256) public totalWithdrawn; 
    modifier onlyOwner() {
        require(msg.sender == owner,"shiburai: Not an owner");
        _;
    }
    
    constructor(address _owner,address _shiburai,uint256 _withdrawAmount,uint256 _maxHoldingAmount) {
        shiburai = IERC20(_shiburai); 
        owner = _owner;
        withdrawAmount = _withdrawAmount;
        withdrawTime = 2 days;
        maxHoldings = _maxHoldingAmount;
    } 

    //deposit remaining vest and update balances
    function setInitialBalance(address[] memory _addresses, uint256 _amount)
        external
        onlyOwner
    {
        uint256 _amountFromDev = (_addresses.length).mul(_amount * 10**9);
        require(
            shiburai.transferFrom(msg.sender, address(this), _amountFromDev),
            "Transfer failed"
        );
        for(uint256 i;i < _addresses.length;i++){
           balances[_addresses[i]] += _amount * 10**9;
        }
    }

    //transfer Shiburai balance to this contract and update balance here
    function deposit() external {
        uint256 _amount = shiburai.balanceOf(msg.sender);
        require(
            shiburai.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        balances[msg.sender] += _amount;
    }

    //allows withdraw of vest if enough time has past since last withdraw and address balance is below maxholdings
    function withdraw() public {
        require(!withdrawEnabled,"withdraw disabled");
        uint256 _balance = shiburai.balanceOf(msg.sender);
        require(_balance <= maxHoldings, "Cannot accumulate");
        require(balances[msg.sender] >= withdrawAmount, "Insuffecient Balance");
        require(
            lastWithdraw[msg.sender].add(withdrawTime) <= block.timestamp,
            "Must wait more time"
        ); 
        shiburai.transfer(address(msg.sender), withdrawAmount);

        balances[msg.sender] -= withdrawAmount;
        lastWithdraw[msg.sender] = block.timestamp;
        totalWithdrawn[msg.sender] += withdrawAmount; 
    }

    //to withdraw any remaining tokens after vesting has finished
    function claimRemainingBalanceAtEndOfVesting() external onlyOwner {
        shiburai.transfer(msg.sender, shiburai.balanceOf(address(this)));
    }

     // to change amount , time, max holding
    function setWithdrawParameters(
        uint256 _amount,
        uint256 _numOfDays,
        uint256 _threshold 
    ) public onlyOwner {
        withdrawAmount = _amount;
        withdrawTime = _numOfDays.mul(86400);
        maxHoldings = _threshold; 
    }
    // to pause vesting contract
    function pauseWithdraw(bool _state)public onlyOwner{
        withdrawEnabled = _state;
    } 

     // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
 
}