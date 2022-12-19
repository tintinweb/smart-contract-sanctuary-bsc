/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;

interface IERC20 {
    
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract mtmLockingContract is Ownable {

    using SafeMath for uint256;
    IERC20 public Token;
    uint256 tokenBalance;
    uint256 deployTime;
    uint256 maxSlotTime = 3153600;


    uint256 public withdrawlAmount;
    uint256 public maxSupply;
    uint256 public RemainingReward;
    uint256 public Duration = 3153600 minutes; 
    uint256 slotTime = 1 minutes;

    constructor()
    {
        deployTime = block.timestamp;
        RemainingReward = 7000000*(10**18);
        tokenBalance = RemainingReward;
        Duration= Duration.div(60);
    }

    function calculatingPerMinutes()
    public
    view
    returns (uint256)
    {
        uint256 totalTime;
        totalTime = (block.timestamp.sub(deployTime)).div(slotTime);
        if(totalTime >= maxSlotTime){
            totalTime = maxSlotTime;
        }
        return totalTime;
    }

    function WithdrawableTokens(address _user)
    public
    view
    returns(uint256)
    {
        uint256 _reward;
        uint256 TokenPerMinutes;
        if(_user == owner()){
            uint256 calcTime = calculatingPerMinutes();
            TokenPerMinutes = (tokenBalance.div(Duration));
            _reward =  (calcTime.mul(TokenPerMinutes));

            return _reward.sub(withdrawlAmount);  
        }
        else{
            return 0;
        }       
    }
    
    function updateTime(uint256 _time)
    public
    onlyOwner
    {
        Withdraw();
        deployTime = block.timestamp;
        Duration = _time;
        maxSlotTime = _time;
    }

    function Withdraw()
    public
    onlyOwner
    {
        uint256 transferReward = WithdrawableTokens(msg.sender);
        withdrawlAmount += transferReward;
        RemainingReward -= transferReward;
        require(withdrawlAmount <= Token.balanceOf(address(this)), "Not enough balance!");
        Token.transfer(owner(),transferReward);
    }

    function addContract(IERC20 BEP20)
    public
    onlyOwner
    {       Token = BEP20;      }

}