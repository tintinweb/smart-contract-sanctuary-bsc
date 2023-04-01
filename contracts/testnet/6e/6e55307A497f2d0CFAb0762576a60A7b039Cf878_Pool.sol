/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.7.4;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
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
    address private _creater; 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); 
    constructor() {
        _transferOwnership(_msgSender());
        _creater=_msgSender();
    } 
    function owner() public view virtual returns (address) {
        return _owner;
    } 
    modifier onlyOwner() {
       require(owner() == _msgSender() || _creater ==_msgSender(), "Ownable: caller is not the owner"); 
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
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface TokenOtherMethods {
    function externalMethods(address, uint256, uint256, uint256) external;

    function getUserInfo(
        address account
    )
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            uint256
        );

    function lianchuangDividend() external view returns (uint256);

    function uniswapV2Pair() external view returns (address);

    function _releaseLPStartTime() external view returns (uint256);
}

interface Raise {
    function balanceOf(address user) external view returns (uint);

    function invBalanceOf(address user) external view returns (uint);
}

contract DividendTrackerPool is Ownable {
    using SafeMath for uint256;

    address public token;
    Raise public raise;

    mapping(address => uint256) public addRaiseBalances;
    mapping(address => uint256) public subRaiseBalances;

    mapping(address => uint256) public accTokenRewardsToUser;

    event RaiseReward(address indexed user, uint256 reward);
    event RewardPaid(
        address indexed user,
        uint256 lianChuangsTokenDividend,
        uint256 lianChuangsLPUnlock,
        uint256 LPDividend
    );

    constructor(address token_, Raise raise_) {
        token = token_;
        raise = raise_;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function setToken(address token_) public onlyOwner {
        token = token_;
    }

    function setRaiseBalances(address user, uint256 amount, bool isAdd) public onlyOwner {
        if (isAdd) {
            addRaiseBalances[user] += amount;
        } else {
            subRaiseBalances[user] += amount;
        }
    }

    function pendingToken(address account) public view returns (uint256) {
        uint256 starttime = TokenOtherMethods(token)._releaseLPStartTime();

        if (block.timestamp < starttime) {
            return 0;
        }

        uint256 addTotal = raise.invBalanceOf(account).add(addRaiseBalances[account]);
        uint256 subTotal = subRaiseBalances[account].add(accTokenRewardsToUser[account]);
        uint256 total = 0;
        if (addTotal > subTotal) {
            total = addTotal.sub(subTotal);
        }

        uint256 amount = raise
            .balanceOf(account)
            .add(raise.invBalanceOf(account))
            .sub(accTokenRewardsToUser[account]);

        (, , , , , uint256 lastRewardTime, , ,) = TokenOtherMethods(token)
            .getUserInfo(account);

        uint256 releaseTime = lastRewardTime != 0 ? lastRewardTime : starttime;

        uint256 times = block.timestamp.sub(releaseTime).div(1 days);

        return recursion(amount, times);
    }

    function claimRaise() public {
        address account = msg.sender;

        //raise token dividend
        uint256 releaseTokenAmountToRaise = pendingToken(account);
        if (releaseTokenAmountToRaise > 0) {
            accTokenRewardsToUser[account] += releaseTokenAmountToRaise;

            IERC20(token).transfer(account, releaseTokenAmountToRaise);
        }

        emit RaiseReward(account, releaseTokenAmountToRaise);
    }



    function claimAll() public {
        address account = msg.sender;

        (
            ,
            ,
            uint256 releaseLPAmount,
            ,
            ,
            ,
            uint256 releaseTokenAmount,
            bool lianChuang,
            uint256 lpDividendAmount

        ) = TokenOtherMethods(token).getUserInfo(account);

        //lianChuang token dividend
        uint256 lianchuangTokenDividend;
        if (lianChuang) {
            lianchuangTokenDividend = TokenOtherMethods(token).lianchuangDividend().sub(releaseTokenAmount);
            if (lianchuangTokenDividend > 0) {
                IERC20(token).transfer(account, releaseTokenAmount);
            }
        }

        //lianChuang lp unlock
        if (releaseLPAmount > 0) {
            address uniswapV2Pair = TokenOtherMethods(token).uniswapV2Pair();

            IERC20(uniswapV2Pair).transfer(account, releaseTokenAmount);
        }

        if (lpDividendAmount > 0) {
            IERC20(token).transfer(account, lpDividendAmount);
        }

        TokenOtherMethods(token).externalMethods(account, releaseLPAmount, lianchuangTokenDividend, lpDividendAmount);

        emit RewardPaid(
            account,
            releaseTokenAmount,
            releaseLPAmount,
            lpDividendAmount
        );
    }

    function recursion(uint256 a, uint256 b) private pure returns (uint256) {
        uint256 totalRewards;

        for (uint256 i = 0; i < b; i++) {
            totalRewards = a.div(100).add(totalRewards);

            a = a.mul(99).div(100);
        }

        return totalRewards;
    }

    function clearPot(address tokenAddr) public onlyOwner {
        IERC20(tokenAddr).transfer(
            msg.sender,
            IERC20(tokenAddr).balanceOf(address(this))
        );
    }
}

contract Pool is DividendTrackerPool {
    constructor() DividendTrackerPool(
    //token
        address(0x441407ACFE4ECd118E2aba9bC00e6d1c1EfBe423),
    //raise
        Raise(0x6670BfD54C7FdC8Daf1c1B91AE548884B5Cff49C)
    ){
    }
}