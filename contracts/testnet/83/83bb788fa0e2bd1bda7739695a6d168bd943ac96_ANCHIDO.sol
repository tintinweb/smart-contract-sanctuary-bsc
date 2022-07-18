/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

pragma solidity ^0.5.16;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    function mint(address account, uint amount) external;

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ANCHIDO {
    
    using SafeMath for uint256;

    IERC20 public token;

    IERC20 public usdtToken;

    address payable public projectAddress;
    
    address public contractOwner;

    uint256 public percent = 10000;

    mapping(address => uint256) public userBuy1Amount;

    mapping(address => uint256) public userBuy2Amount;

    mapping(address => uint256) public userWithdrawedAmount;

    mapping(address => bool) public isBuyed;

    uint256 public p1StartTime;
    uint256 public p1FinishTime;
    uint256 public p1MAXAmount = 400000 * 1e18;
    uint256 public p1Price = 3; // 0.3 U
    uint256 public p1Period = 120;
    uint256 public p1DayRelease = 75;
    uint256 public p1BuyedTotal;
    uint256 public p1USDTTotal;

    uint256 public p2StartTime;
    uint256 public p2FinishTime;
    uint256 public p2MAXAmount = 600000 * 1e18;
    uint256 public p2Price = 5; // 0.5 U
    uint256 public p2Period = 90;
    uint256 public p2DayRelease = 100;
    uint256 public p2BuyedTotal;
    uint256 public p2USDTTotal;

    uint256 public onlineTime;

    uint256 public MAXPAYUSDT = 500 * 1e18;

    mapping(address => uint256) public userPayUSDTAmount;

    uint256 public dayPeriod = 1 days;

    constructor(IERC20 _token,
                IERC20 _usdtToken, 
                address payable _projectAddress, 
                uint256 _p1Start, 
                uint256 _p2Start,
                uint256 _onlineTime) public {
        
        contractOwner = msg.sender;
        token = _token;
        usdtToken = _usdtToken;
        projectAddress = _projectAddress;

        p1StartTime = _p1Start;
        p1FinishTime = p1StartTime.add(2 days);

        p2StartTime = _p2Start;
        p2FinishTime = p2StartTime.add(3 days);

        onlineTime = _onlineTime;
    }


    function setToken(IERC20 _token) public {
        require(msg.sender == contractOwner, "Must be owner");
        token = _token;
    }



    function setProjectAddress( address payable _projectAddress) public {
        require(msg.sender == contractOwner, "Must be owner");
        projectAddress = _projectAddress;
    }
     
    function setOwner(address _contractOwner) public {
        require(msg.sender == contractOwner, "Must be owner");
        contractOwner = _contractOwner;
    }
    

    function setOnlineTime(uint256 _onlineTime) public {
        require(msg.sender == contractOwner, "Must be owner");
        onlineTime = _onlineTime;
    }

    function setP1StartTime(uint256 _p1Start) public {
        require(msg.sender == contractOwner, "Must be owner");
        p1StartTime = _p1Start;
        p1FinishTime = p1StartTime.add(2 days);
    }

    function setP2StartTime(uint256 _p2Start) public {
        require(msg.sender == contractOwner, "Must be owner");
        p2StartTime = _p2Start;
        p2FinishTime = p2StartTime.add(3 days);
    }

    function setMaxPayUSDT(uint256 _maxpayusdt) public {
        require(msg.sender == contractOwner, "Must be owner");
        MAXPAYUSDT = _maxpayusdt;
    }

     
    function swap(uint256 amount) public {
        
        require(!isBuyed[msg.sender], "buy only once");

        require(amount == MAXPAYUSDT, "must swap MAX USDT");

        require((block.timestamp >= p1StartTime && block.timestamp <= p1FinishTime) || 
                (block.timestamp >= p2StartTime && block.timestamp <= p2FinishTime) , "ido no start or ido finish");

        uint256 tokenAmount;

        if(block.timestamp >= p1StartTime && block.timestamp <= p1FinishTime) {
            tokenAmount = amount.mul(10).div(p1Price);
            require(p1BuyedTotal.add(tokenAmount) <= p1MAXAmount, "over p1 MAX");

            userBuy1Amount[msg.sender] = userBuy1Amount[msg.sender].add(tokenAmount);
            p1BuyedTotal = p1BuyedTotal.add(tokenAmount);
            p1USDTTotal = p1USDTTotal.add(amount);
            userPayUSDTAmount[msg.sender] = userPayUSDTAmount[msg.sender].add(amount);

            isBuyed[msg.sender] = true;
        } else if(block.timestamp >= p2StartTime && block.timestamp <= p2FinishTime) {
            tokenAmount = amount.mul(10).div(p2Price);
            require(p2BuyedTotal.add(tokenAmount) <= p2MAXAmount, "over p2 MAX");

            userBuy2Amount[msg.sender] = userBuy2Amount[msg.sender].add(tokenAmount);
            p2BuyedTotal = p2BuyedTotal.add(tokenAmount);
            p2USDTTotal = p2USDTTotal.add(amount);
            userPayUSDTAmount[msg.sender] = userPayUSDTAmount[msg.sender].add(amount);

            isBuyed[msg.sender] = true;
        }
        
        usdtToken.transferFrom(address(msg.sender), projectAddress, amount);
 
    }


    function addWhiteList(uint256 phase, address[] memory dests, uint256[] memory amount) public  {

        require(msg.sender == contractOwner, "Must be owner");
        require(phase == 1 || phase == 2, "phase must 1 or 2");

        uint256 tokenAmount;
        for(uint256 i=0; i<dests.length; i++) {

            if(phase == 1) {
                tokenAmount = amount[i].mul(10).div(p1Price);

                userBuy1Amount[dests[i]] = userBuy1Amount[dests[i]].add(tokenAmount);
                p1BuyedTotal = p1BuyedTotal.add(tokenAmount);
                p1USDTTotal = p1USDTTotal.add(amount[i]);
                userPayUSDTAmount[dests[i]] = userPayUSDTAmount[dests[i]].add(amount[i]);

                isBuyed[dests[i]] = true;
            } else {
                tokenAmount = amount[i].mul(10).div(p2Price);

                userBuy2Amount[dests[i]] = userBuy2Amount[dests[i]].add(tokenAmount);
                p2BuyedTotal = p2BuyedTotal.add(tokenAmount);
                p2USDTTotal = p2USDTTotal.add(amount[i]);
                userPayUSDTAmount[dests[i]] = userPayUSDTAmount[dests[i]].add(amount[i]);

                isBuyed[dests[i]] = true;
            }

        }
        
    }


    function withdraw() public {

        uint256 releaseTokenAmout = getReleaseTokenAmount(msg.sender);
        if(releaseTokenAmout > 0) {
            safeTokenTransfer(msg.sender, releaseTokenAmout) ; 
            userWithdrawedAmount[msg.sender] = userWithdrawedAmount[msg.sender].add(releaseTokenAmout);
        }

    }

    function getReleaseTokenAmount(address account) public view returns (uint256){

        
        if(block.timestamp >= onlineTime) {

            uint256 releaseToken;

            uint256 time = (block.timestamp.sub(onlineTime)).div(dayPeriod);

            if(userBuy1Amount[account] > 0) {
                if(time > p1Period)
                    time = p1Period;
                releaseToken = releaseToken.add(userBuy1Amount[account].div(100).mul(10));
                releaseToken = releaseToken.add(userBuy1Amount[account].mul(time).div(percent).mul(p1DayRelease));
            }

            if(userBuy2Amount[account] > 0) {
                if(time > p2Period)
                    time = p2Period;
                releaseToken = releaseToken.add(userBuy2Amount[account].div(100).mul(10));
                releaseToken = releaseToken.add(userBuy2Amount[account].mul(time).div(percent).mul(p2DayRelease));
            }

            releaseToken = releaseToken.sub(userWithdrawedAmount[account]);
            return releaseToken;

        } else {
            return 0;
        }
    }

    function getSwapTokenAmount(address account) public view returns (uint256){
        
        return userBuy1Amount[account].add(userBuy2Amount[account]);
        
    }


    
    function withdraw(IERC20 _token) public {

        require(msg.sender == contractOwner, "Must be owner");

        uint256 tokenBalance = _token.balanceOf(address(this));
        if(tokenBalance > 0) {
            _token.transfer(msg.sender, tokenBalance);
        } 

 
    }


    function safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBalance = token.balanceOf(address(this));
        if(tokenBalance > 0) {
            if(_amount > tokenBalance) {
                token.transfer(_to, tokenBalance);
            } else {
                token.transfer(_to, _amount);
            }
        }
        
        
    }


    function getIDOPInfo() view external returns(uint256 ,uint256 , uint256 , uint256 , uint256, uint256 , uint256 , uint256) {

        if(block.timestamp <= p1FinishTime) {
            return (p1StartTime,
                p1FinishTime,
                p1MAXAmount,
                p1Price,
                p1Period,
                p1DayRelease,
                p1BuyedTotal,
                p1USDTTotal);
            
        } else {
            
            return (p2StartTime,
                p2FinishTime,
                p2MAXAmount,
                p2Price,
                p2Period,
                p2DayRelease,
                p2BuyedTotal.add(p1BuyedTotal),
                p2USDTTotal.add(p1USDTTotal));

        }
    }


    function getIDOP1Info() view external returns(uint256 ,uint256 , uint256 , uint256 , uint256, uint256 , uint256 , uint256) {

        return (p1StartTime,
                p1FinishTime,
                p1MAXAmount,
                p1Price,
                p1Period,
                p1DayRelease,
                p1BuyedTotal,
                p1USDTTotal);
    }

    function getIDOP2Info() view external returns(uint256 ,uint256 , uint256 , uint256 , uint256, uint256 , uint256 , uint256) {
        
        return (p2StartTime,
                p2FinishTime,
                p2MAXAmount,
                p2Price,
                p2Period,
                p2DayRelease,
                p2BuyedTotal,
                p2USDTTotal);
    }


}