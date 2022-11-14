/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

    function owner() public view virtual returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

library SafeMath {
  
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}

interface IUniswapV2Router {

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

}

interface IUniswapV2Pair {
    
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

}

contract STWStaking is Ownable {

    using SafeMath for uint256;

    error RegistrationEnds();
    error InvalidPrice();
    error LockPeriodNotOver();
    error NotStaker();
    error RegistrationNotStarted();
    error RegistrationEnded();

    IUniswapV2Router public uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IUniswapV2Pair public LABs = IUniswapV2Pair(0xCa76427c4FBAb2b51B810f73f72c57c1dD43388c);
    IERC20 public token = IERC20(0x134B372f5543C5CCa30Be6a796Da032c8274bDdF);

    uint256 public minimumDeposit = 10 * 10**18;
    uint256 constant series = 31536000;
    bool public initilized;
    
    struct data {
        uint256 startDate;
        uint256 EndDate;
        uint256 APY;
        uint256 lockPeriod;
    }
    data public pool;

    struct userRecord {
        uint256 amount;
        uint256 timestamp;
        uint256 APY;
        uint256 registered;
    }
    mapping (address => userRecord) public userStaking;

    constructor(uint _s,uint _e, uint _a, uint _l) {
        initiate(_s,_e,_a,_l);
    }
    
    function initiate(uint256 _start, uint256 _end, uint256 _apy, uint256 _lock) public onlyOwner {
        // require(!initilized,"Pool Already Initialized");
        pool = data(_start,_end,_apy,_lock);
        initilized = true;
    }

    function stake(uint _amount) public {
        require(initilized,"Contract is not initialized Yet!!");
        address account = msg.sender;
        uint price = getPrice();
        if(_amount < price) revert InvalidPrice();
        if(block.timestamp < pool.startDate) revert RegistrationNotStarted();
        if(block.timestamp > pool.EndDate) revert RegistrationEnded();
        token.transferFrom(account,address(this),_amount);
        if(userStaking[account].registered == 0) {
            userStaking[account] = userRecord(_amount,pool.EndDate,pool.APY,1);
        }
        else {
            userStaking[account].amount += _amount;
        }
  
    }

    function unstake() public {
        require(initilized,"Contract is not initialized Yet!!");
        address account = msg.sender;
        if(userStaking[account].registered == 0) revert NotStaker();
        if(block.timestamp < /*userStaking[account].timestamp*/pool.EndDate + pool.lockPeriod) {
            revert LockPeriodNotOver();
        }
        else{
            uint value = userStaking[account].amount;
            uint reward = getEarning(account);
            token.transfer(account,reward.add(value));
            userStaking[account] = userRecord(0,0,0,0);
        }
    }

    function calSeconds(uint256 _timer) internal view returns (uint256) {
        if(_timer == 0) return 0;
        if(_timer > block.timestamp) {
            return 0;
        }
        else {
        uint locktime = pool.EndDate.add(pool.lockPeriod);
            if(locktime > block.timestamp) {
                return block.timestamp.sub(_timer);
            }
            else {
                return pool.lockPeriod;
            }
        }
    }

    function calReward(uint256 _amount,uint256 _APY) internal pure returns (uint256) {
        uint256 factor = _amount.mul(_APY).div(100);
        return factor.div(series);
    }

    function getTreasuryBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getEarning(address acc) public view returns (uint256) {
        uint value = userStaking[acc].amount;
        uint factor = calSeconds(userStaking[acc].timestamp);
        uint delta = calReward(value,userStaking[acc].APY);
        return delta * factor;
    }

    function getPrice() public view returns (uint256) {
        (uint256 reserve0, uint256 reserve1,) = LABs.getReserves();
        uint256 result = uniswapV2Router.getAmountIn(minimumDeposit,reserve0,reserve1);
        return result;
    }

    function getPriceEntry(uint _entry) public view returns (uint256) {
        (uint256 reserve0, uint256 reserve1,) = LABs.getReserves();
        uint256 result = uniswapV2Router.getAmountIn(minimumDeposit,reserve0,reserve1);
        return result*_entry;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function rescueTokens(address _token, uint256 amount) public onlyOwner {
        IERC20(_token).transfer(owner(), amount);
    }

    function rescueFunds() public onlyOwner {
        (bool os,) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    receive() external payable {}
}