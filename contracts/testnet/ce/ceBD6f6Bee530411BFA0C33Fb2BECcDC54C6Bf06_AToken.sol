/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.5.0;
interface IBEP20 {
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    function burnFrom(address account, uint256 amount) external returns (bool);

    function burn(uint256 amount) external returns (bool);
    function mint(address account, uint256 amount) external returns (bool);
    
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

interface IBToken20 is IBEP20 {
    function raisePrices() external;
}

pragma solidity >=0.4.0;

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
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: contracts\interfaces\IPancakeRouter02.sol

pragma solidity >=0.6.2;

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function sync() external;
    event Sync(uint112 reserve0, uint112 reserve1);
}

contract Ownable {
    address _owner;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

contract InviteReward {

    mapping (address => address) internal _refers;

    event BindUser(address indexed user, address indexed parent);

    function _bindParent(address sender, address recipient) internal {
        if(_refers[recipient] == address(0)) {
            _refers[recipient] = sender;
            emit BindUser(recipient, sender);
        }
    }
    
    function getParent(address user) public view returns (address) {
        return _refers[user];
    }

}

contract LaunchLimit is Ownable{

    uint32 public launchTimestamp;
    bool internal _hasLaunched = false;
    
    function launch() public onlyOwner {
        require(!_hasLaunched, "Already launched.");
        _hasLaunched = true;
        launchTimestamp = uint32(block.timestamp % 2**32);
    }

}


contract SwapPool {
    
    using SafeMath for uint256;

    // address public token0;
    // address public token1;
    address public creator;
    address public owner;
    // address public pancakeV2Router;
    constructor(address _owner)
    {
        // token0 = _token0;
        // token1 = _token1;
        // pancakeV2Router = _router;

        creator = msg.sender;
        owner = _owner;
    }

    function swap(address pancakeV2Router, address token0, address token1) public {

        require(msg.sender == creator || msg.sender == owner, "SWAP: error msg sender");

        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;

        uint256 token0Balance = IBEP20(token0).balanceOf(address(this));
        if(token0Balance == 0) {return;}

        IBEP20(token0).approve(pancakeV2Router, token0Balance);
        // make the swap
        IPancakeRouter02(pancakeV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            token0Balance,
            0,
            path,
            address(this),
            block.timestamp
        );

    }

    function toPancakePair(address token, address pancakeAddress) public {
        require(msg.sender == creator || msg.sender == owner, "SWAP: error msg sender");
        if(pancakeAddress == address(0)) { return; }
        uint256 tokenBalance = IBEP20(token).balanceOf(address(this));

        if(tokenBalance == 0) {return;}
        IBEP20(token).transfer(pancakeAddress, tokenBalance);
        IPancakePair(pancakeAddress).sync();
    }

    function mintPancakePair(address token, address mintToken, address pancakeAddress, uint rewardRate, address rewardAccount) public {
        require(msg.sender == creator || msg.sender == owner, "SWAP: error msg sender");

        if(pancakeAddress == address(0) || token == address(0) || mintToken == address(0)) { return; }

        uint256 tokenBalance = IBEP20(token).balanceOf(address(this));
        if(tokenBalance == 0) {return;}

        uint256 tokenPrice = getExchangeCountOfOneUsdt(mintToken, pancakeAddress);
        uint256 mintNumber = tokenBalance.mul(tokenPrice).div(1000).mul(rewardRate).div(1e18);

        IBEP20(token).transfer(pancakeAddress, tokenBalance);
        IBEP20(mintToken).mint(pancakeAddress, mintNumber);
        IBEP20(mintToken).mint(rewardAccount, mintNumber);
        IPancakePair(pancakeAddress).sync();
    }

    function getExchangeCountOfOneUsdt(address tokenAddress, address pancakeAddress) public view returns (uint256)
    {
        if(pancakeAddress == address(0)) {return 0;}

        IPancakePair pair = IPancakePair(pancakeAddress);

        (uint112 _reserve0, uint112 _reserve1, ) = pair.getReserves();

        uint256 a = _reserve1;
        uint256 b = _reserve0;

        if(a == 0 || b == 0) {return 0;}

        if(pair.token0() == tokenAddress)
        {
            a = _reserve0;
            b = _reserve1;
        }

        return a.mul(1e18).div(b);
    }

}

contract IdoPool {

    using SafeMath for uint256;

    mapping(address=>uint256) public userBalances;

    address public usdtTokenAddress;
    address public idoTokenAddress;
    address public pancakeAddress;

    uint256 public rewardRate;

    address _creator;
    address _owner;
    
    constructor(address owner)
    {
        _creator = msg.sender;
        _owner = owner;
        
    }

    function setRewardRate(uint256 _rewardRate) public {
        require(_creator == msg.sender || _owner == msg.sender, "Ownable: caller is not the owner");
        rewardRate = _rewardRate;
    }

    function setUsdtToken(address _usdtTokenAddress) public {
        require(_creator == msg.sender || _owner == msg.sender, "Ownable: caller is not the owner");
        usdtTokenAddress = _usdtTokenAddress;
    }

    function setIdoToken(address _idoTokenAddress) public {
        require(_creator == msg.sender || _owner == msg.sender, "Ownable: caller is not the owner");
        idoTokenAddress = _idoTokenAddress;
    }

    function setPancakeAddress(address _pancakeAddress) public {
        require(_creator == msg.sender || _owner == msg.sender, "Ownable: caller is not the owner");
        pancakeAddress = _pancakeAddress;
    }

    function sync(address account, uint256 amount) public {
        require(_creator == msg.sender || _owner == msg.sender, "Ownable: caller is not the owner");
        userBalances[account] = userBalances[account].add(amount);
    }
    
    function exchange(uint256 amount) public {

        address userAddress = msg.sender;

        require(userBalances[userAddress] >= amount, "IDO: user balance lt amount");
        require(pancakeAddress != address(0), "IDO: pancakeAddress is zero");
        require(usdtTokenAddress != address(0), "IDO: usdtTokenAddress is zero");
        require(idoTokenAddress != address(0), "IDO: idoTokenAddress is zero");

        IPancakePair pair = IPancakePair(pancakeAddress);
        // pair.sync();

        uint256 price = getExchangeCountOfOneUsdt(idoTokenAddress);
        uint256 toUsdt = amount.mul(1e18).div(price);
        uint256 toAmount = amount;

        uint256 usdtBalance = IBEP20(usdtTokenAddress).balanceOf(address(this));
        if(usdtBalance < toUsdt) {
            toUsdt = usdtBalance;
            toAmount = toUsdt.mul(price).div(1e18);
        }

        uint256 mintAmount = toAmount.div(1000).mul(rewardRate);

        IBEP20(usdtTokenAddress).transferFrom(userAddress, pancakeAddress, toUsdt);
        IBEP20(idoTokenAddress).mint(userAddress, mintAmount);
        IBEP20(idoTokenAddress).mint(pancakeAddress, mintAmount);
        pair.sync();

        userBalances[userAddress] = userBalances[userAddress].sub(toAmount);
    }

    function exchange(address userAddress, uint256 usdtAmount) public {
        require(_creator == msg.sender || _owner == msg.sender, "Ownable: caller is not the owner");

        require(userBalances[userAddress] > 0, "IDO: user balance lt 0");
        require(pancakeAddress != address(0), "IDO: pancakeAddress is zero");
        require(usdtTokenAddress != address(0), "IDO: usdtTokenAddress is zero");
        require(idoTokenAddress != address(0), "IDO: idoTokenAddress is zero");


        IPancakePair pair = IPancakePair(pancakeAddress);
        // pair.sync();

        uint256 price = getExchangeCountOfOneUsdt(idoTokenAddress);
        uint256 toAmount = usdtAmount.mul(price).div(1e18);
        uint256 tokenBalance = userBalances[userAddress];

        if(toAmount > tokenBalance) {
            toAmount = tokenBalance;
            usdtAmount = toAmount.mul(1e18).div(price);
        }

        uint256 mintAmount = toAmount.div(1000).mul(rewardRate);

        IBEP20(usdtTokenAddress).transfer(pancakeAddress, usdtAmount);
        IBEP20(idoTokenAddress).mint(userAddress, mintAmount);
        IBEP20(idoTokenAddress).mint(pancakeAddress, mintAmount);
        pair.sync();

        userBalances[userAddress] = userBalances[userAddress].sub(toAmount);
    }

    function toPancakePair() public {
        require(_creator == msg.sender || _owner == msg.sender, "Ownable: caller is not the owner");

        IPancakePair pair = IPancakePair(pancakeAddress);
        // pair.sync();

        uint256 price = getExchangeCountOfOneUsdt(idoTokenAddress);
        uint256 balance = IBEP20(usdtTokenAddress).balanceOf(address(this));
        uint256 mintAmount = balance.mul(price).div(1000).mul(rewardRate).div(1e18);

        IBEP20(usdtTokenAddress).transfer(pancakeAddress, balance);
        IBEP20(idoTokenAddress).mint(pancakeAddress, mintAmount);
        pair.sync();
    }

    function withdraw(address toAddress) public {
        require(_creator == msg.sender || _owner == msg.sender, "Ownable: caller is not the owner");
        uint256 balance = IBEP20(usdtTokenAddress).balanceOf(address(this));
        IBEP20(usdtTokenAddress).transfer(toAddress, balance);
    }

    function getExchangeCountOfOneUsdt(address tokenAddress) public view returns (uint256)
    {
        if(pancakeAddress == address(0)) {return 0;}

        IPancakePair pair = IPancakePair(pancakeAddress);

        (uint112 _reserve0, uint112 _reserve1, ) = pair.getReserves();

        uint256 a = _reserve1;
        uint256 b = _reserve0;

        if(a == 0 || b == 0) {return 0;}

        if(pair.token0() == tokenAddress)
        {
            a = _reserve0;
            b = _reserve1;
        }

        return a.mul(1e18).div(b);
    }

}

contract LpMiner {

    using SafeMath for uint256;

    uint256 public totalLp = 0;
    address[] public users;
    mapping(address=>uint256) public userLps;

    address public rewardTokenAddress;
    
    address _creator;
    address _owner;

    uint256 lastAirdropTime;
    uint256 rewardAmount = 100*1e18;
    
    constructor(address owner)
    {
        _creator = msg.sender;
        _owner = owner;
    }

    function totalUsers() public view returns(uint256) {
        return users.length;
    }

    function setRewardToken(address _rewardTokenAddress) public {
        require(_creator == msg.sender || _owner == msg.sender, "Ownable: caller is not the owner");
        rewardTokenAddress = _rewardTokenAddress;
    }

    function sync(address account, uint256 amount, bool isAdd) public {
        require(_creator == msg.sender || _owner == msg.sender, "Ownable: caller is not the owner");
        if(isAdd) {
            if(userLps[account] == 0) {
                users.push(account);
            }
            userLps[account] = userLps[account].add(amount);
            totalLp = totalLp.add(amount);
        } else {
            userLps[account] = userLps[account].sub(amount);
            totalLp = totalLp.sub(amount);
            if(userLps[account] == 0) {
                if(users.length > 1) {
                    for(uint256 i=0;i<users.length;i++) {
                        if(users[i] == account) {
                            users[i] = users[users.length - 1];
                            break;
                        }
                    }
                }
                users.pop();
            }
        }
    }
    
    function airdrop(uint256 startIndex, uint256 endIndex, uint256 lpLimit) public {
        require(_creator == msg.sender || _owner == msg.sender, "Ownable: caller is not the owner");
        require(rewardTokenAddress != address(0), "LpTool: rewardTokenAddress is zero");
        require(endIndex <= users.length, "LpTool: endIndex gt users.length");
        require(totalLp > 0, "LpTool: totalLp is zero");

        uint256 balance = IBEP20(rewardTokenAddress).balanceOf(address(this));
        uint256 baseAmount = rewardAmount > balance ? balance : rewardAmount;
        
        for(uint256 i=startIndex; i<endIndex; i++) {
            address user = users[i];
            uint256 userLp = userLps[user];
            if(userLps[user] == 0 || userLp <= lpLimit) {continue;}
            uint256 toAmount = baseAmount.mul(userLp).div(totalLp);
            IBEP20(rewardTokenAddress).transfer(user, toAmount);
        }

        lastAirdropTime = block.timestamp % 2**32;
    
    }

    function airdrop(address[] memory accounts, uint256 lpLimit) public {
        require(_creator == msg.sender || _owner == msg.sender, "Ownable: caller is not the owner");
        require(rewardTokenAddress != address(0), "LpTool: rewardTokenAddress is zero");
        require(totalLp > 0, "LpTool: totalLp is zero");

        uint256 balance = IBEP20(rewardTokenAddress).balanceOf(address(this));
        uint256 baseAmount = rewardAmount > balance ? balance : rewardAmount;
        
        for(uint256 i=0; i<accounts.length; i++) {
            address user = accounts[i];
            uint256 userLp = userLps[user];
            if(userLps[user] == 0 || userLp <= lpLimit) {continue;}
            uint256 toAmount = baseAmount.mul(userLp).div(totalLp);
            IBEP20(rewardTokenAddress).transfer(user, toAmount);
        }

        lastAirdropTime = block.timestamp % 2**32;
    
    }

}

contract AToken is IBEP20, Ownable, InviteReward, LaunchLimit {
    
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    string constant  _name = 'AToken';
    string constant _symbol = 'AToken';
    uint8 immutable _decimals = 18;
    uint256 private _totalSupply = 500000 * 1e18;

    
    address public fundAddress = 0x0000000000000000000000000000000000000000;
    address public lpAddress = 0x0000000000000000000000000000000000000001;
    
    address public pancakeAddress;

    address public usdtTokenAddress = 0x8b1324F4c6B6834885bC8a51d831418dF1C1CBD8;
    IPancakeRouter02 public pancakeV2Router = IPancakeRouter02(0xF19D0488478147cCC20Be934F82d364d79B00F42);

    uint256 public rewardRate = 800;
    address public rewardTokenB = 0xC78063DD7AD4a313EcE98f9041a288E61175FF4E;
    address public pancakeAddressB = 0x2CE928d21B50B5B0352d8729156d9b2a2771B882;

    // address public usdtTokenAddress = 0x55d398326f99059fF775485246999027B3197955;
    // IPancakeRouter02 public pancakeV2Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // uint256 public rewardRate = 800;
    // address public rewardTokenB = 0x264D5c8EB8b942c8D09496ccef6B2974032659Fd;
    // address public pancakeAddressB = 0x2c05824DbC092a99b4236b1736b8fa2245828050;

    SwapPool public swapAddress;
    IdoPool public idoAddress;
    LpMiner public lpMinerAddress;
    
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isBlacked;

    bool public isFine = false;
    uint256 public fineRate = 330;
    uint256 public fineStepRate = 200;
    uint256 public lastPrice = 0;
    uint256 public lastFineTime = 0;

    // uint32 public bonusIntervalTime = 86400;
    
    
    constructor()
    {
        _owner = msg.sender;
        
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
        
        setExcluded(_owner, true);
        setExcluded(address(this), true);

        pancakeAddress = IPancakeFactory(pancakeV2Router.factory())
            .createPair(
                usdtTokenAddress,
                address(this)
            );

        swapAddress = new SwapPool(_owner);
        setExcluded(address(swapAddress), true);

        idoAddress = new IdoPool(_owner);
        idoAddress.setUsdtToken(usdtTokenAddress);
        idoAddress.setIdoToken(rewardTokenB);
        idoAddress.setPancakeAddress(pancakeAddressB);
        idoAddress.setRewardRate(rewardRate);
        setExcluded(address(idoAddress), true);

        lpMinerAddress = new LpMiner(_owner);
        lpMinerAddress.setRewardToken(address(this));
        setExcluded(address(lpMinerAddress), true);

        _balances[_owner] = _balances[_owner].sub(100000*1e18);
        _balances[address(lpMinerAddress)] = _balances[address(lpMinerAddress)].add(100000*1e18);
        emit Transfer(_owner, address(lpMinerAddress), 100000*1e18);

    }

    function setSwapAddress(address _swapAddress) public onlyOwner {
        swapAddress = SwapPool(_swapAddress);
        setExcluded(_swapAddress, true);
    }

    function setIdoAddress(address _idoAddress) public onlyOwner {
        idoAddress = IdoPool(_idoAddress);
        idoAddress.setUsdtToken(usdtTokenAddress);
        idoAddress.setIdoToken(rewardTokenB);
        idoAddress.setPancakeAddress(pancakeAddressB);
        idoAddress.setRewardRate(rewardRate);
        setExcluded(_idoAddress, true);
    }

    function setLpMinerAddress(address _lpMinerAddress) public onlyOwner {
        lpMinerAddress = LpMiner(_lpMinerAddress);
        lpMinerAddress.setRewardToken(address(this));
        setExcluded(_lpMinerAddress, true);
    }

    function setLpAddress(address _lpAddress) public onlyOwner {
        lpAddress = _lpAddress;
        setExcluded(lpAddress, true);
    }

    function setFundAddress(address _fundAddress) public onlyOwner {
        fundAddress = _fundAddress;
        setExcluded(fundAddress, true);
    }

    function setRewardTokenB(address _rewardTokenB) public onlyOwner {
        rewardTokenB = _rewardTokenB;
        idoAddress.setIdoToken(rewardTokenB);
        lpMinerAddress.setRewardToken(rewardTokenB);
    }

    function setPancakeAddressA(address _pancakeAddress) public onlyOwner {
        pancakeAddress = _pancakeAddress;
    }

    function setPancakeAddressB(address _pancakeAddress) public onlyOwner {
        pancakeAddressB = _pancakeAddress;
        idoAddress.setPancakeAddress(pancakeAddressB);
    }

    function setRewardRate(uint256 _rewardRate) public onlyOwner {
        rewardRate = _rewardRate;
        idoAddress.setRewardRate(rewardRate);
    }
    
    function setFine(bool _isFine) public onlyOwner {
        isFine = _isFine;
    }

    function setFineRate(uint256 _fineRate) public onlyOwner {
        fineRate = _fineRate;
    }

    function setFineStepRate(uint256 _fineStepRate) public onlyOwner {
        fineStepRate = _fineStepRate;
    }

    function setExcluded(address account, bool excluded) public onlyOwner {
        _isExcluded[account] = excluded;
    }

    function setExcluded(address[] memory accounts, bool excluded) public onlyOwner {
        for(uint256 i=0; i<accounts.length; i++) {
            address account = accounts[i];
            _isExcluded[account] = excluded;
        }
    }
    
    function setBlacked(address account, bool blacked) public onlyOwner {
        _isBlacked[account] = blacked;
    }
    
    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }
    
    function isBlacked(address account) public view returns (bool) {
        return _isBlacked[account];
    }
    
    function name() public  pure returns (string memory) {
        return _name;
    }

    function symbol() public  pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }
    
    function mint(address account, uint256 amount) public onlyOwner override returns (bool) {
        _mint(account, amount);
        return true;
    }

    function burn(uint256 amount) public override returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }
    
    function burnFrom(address account, uint256 amount) public override returns (bool) {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!isBlacked(sender), "ERC20: sender is blacked");

        if(sender != recipient 
            && sender != pancakeAddress && recipient != pancakeAddress
            ) {
            _bindParent(sender, recipient);
        }
        
        uint256 transferAmount = amount;
        
        if(!isExcluded(sender) && !isExcluded(recipient)) {
            
            if(sender == pancakeAddress || recipient == pancakeAddress) {
                require(_hasLaunched, "ERC20: has not launched");
            }

        }

        IBToken20(rewardTokenB).raisePrices();

        updateFineStatus();

        if(sender == pancakeAddress) {
            
            if(!isExcluded(recipient)) {

                uint256 onepercent = amount.mul(1).div(1000);
                if(onepercent > 0)
                {
                    
                    //2%
                    uint256 tInvite = _takeInviterAmount(sender, recipient, amount);
                    uint256 tLp = onepercent.mul(20);
                    uint256 tSwap = onepercent.mul(20);
                    
                    _balances[address(swapAddress)] = _balances[address(swapAddress)].add(tSwap);
                    emit Transfer(sender, address(swapAddress), tSwap);
                    
                    _balances[lpAddress] = _balances[lpAddress].add(tLp);
                    emit Transfer(sender, lpAddress, tLp);
                    
                    uint256 tFee = tInvite.add(tLp).add(tSwap);
                    transferAmount = transferAmount.sub(tFee);

                }
                
            }
            
        }
            
        if(recipient == pancakeAddress) {
            
            if(!isExcluded(sender)) {
                
                uint256 onepercent = amount.mul(1).div(1000);
                if(onepercent > 0)
                {
                    
                    uint256 tSwap = onepercent.mul(100);
                    
                    swapAddress.swap(address(pancakeV2Router), address(this), usdtTokenAddress);
                    swapAddress.toPancakePair(usdtTokenAddress, pancakeAddressB);

                    _balances[address(swapAddress)] = _balances[address(swapAddress)].add(tSwap);
                    emit Transfer(sender, address(swapAddress), tSwap);
                    swapAddress.swap(address(pancakeV2Router), address(this), usdtTokenAddress);
                    // uint256 beforeBTokenAmount = IBEP20(rewardTokenB).balanceOf(sender);
                    swapAddress.mintPancakePair(usdtTokenAddress, rewardTokenB, address(pancakeAddressB), rewardRate, sender);
                    // uint256 nowBTokenAmount = IBEP20(rewardTokenB).balanceOf(sender);
                    // _syncIdoTokenBAmount(sender, beforeBTokenAmount, nowBTokenAmount);
                    
                    uint256 tFee = tSwap;
                    transferAmount = transferAmount.sub(tFee);

                    if(isFine) {
                        uint256 tFine = onepercent.mul(fineRate);
                        transferAmount = transferAmount.sub(tFine);
                        _totalSupply = _totalSupply.sub(tFine);
                        emit Transfer(sender, address(0), tFine);
                    }

                }
                
            }
            
        }
        
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(transferAmount);
        emit Transfer(sender, recipient, transferAmount);

    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    // function _swapTokenToUsdt(uint256 tokenAmount) private {
    //     address[] memory path = new address[](2);
    //     path[0] = address(this);
    //     path[1] = usdtTokenAddress;
    //     _approve(path[0], address(pancakeV2Router), tokenAmount);
    //     // make the swap
    //     pancakeV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //         tokenAmount,
    //         0,
    //         path,
    //         address(this),
    //         block.timestamp
    //     );
    // }

    // function _sendUsdtToPancakePairB() private {
    //     if(pancakeAddressB == address(0)) { return; }
    //     uint256 usdtBalance = IBEP20(usdtTokenAddress).balanceOf(address(this));
    //     if(usdtBalance == 0) {return;}
    //     IBEP20(usdtTokenAddress).transfer(pancakeAddressB, usdtBalance);
    //     IPancakePair(pancakeAddressB).sync();
    // }

    // function _mintTokenToPancakePairB(address rewardAccount) private {
    //     if(pancakeAddressB == address(0) || rewardTokenB == address(0)) { return; }
    //     uint256 usdtBalance = IBEP20(usdtTokenAddress).balanceOf(address(this));
    //     if(usdtBalance == 0) {return;}
    //     uint256 tokenBPrice  = getExchangeCountOfOneUsdt2();
    //     uint256 tokenBNumber = usdtBalance.div(1e18) * tokenBPrice;
    //     uint256 rewardTokenBNumber = tokenBNumber.mul(1).div(1000).mul(rewardRate);
    //     IBEP20(usdtTokenAddress).transfer(pancakeAddressB, usdtBalance);
    //     IBEP20(rewardTokenB).mint(pancakeAddressB, rewardTokenBNumber);
    //     IBEP20(rewardTokenB).mint(rewardAccount, rewardTokenBNumber);
    //     IPancakePair(pancakeAddressB).sync();
    // }

    function updateFineStatus() public {
        uint256 nowTime  = block.timestamp % 2**32;
        uint256 nowPrice = getExchangeCountOfOneUsdt();
        if(nowPrice == 0) { return; }
        if(lastPrice == 0 || nowTime.sub(lastFineTime) > 86400) {
            lastFineTime = nowTime - nowTime % 86400;
            lastPrice = nowPrice;
        }
        // down 20%
        uint256 stepPrice = lastPrice.mul(1).div(1000).mul(fineStepRate);
        if(nowPrice > lastPrice && nowPrice.sub(lastPrice) >= stepPrice) {
            isFine = true;
        } else {
            isFine = false;
        }
    }

    function idoAmount(address userAddress, uint256 usdtAmount) public onlyOwner {
        idoAddress.exchange(userAddress, usdtAmount);
    }

    function lpBouns(address[] memory accounts, uint256 lpLimit) public onlyOwner {
        uint256 totalBalance = _balances[lpAddress];
        uint256 totalLp = IBEP20(pancakeAddress).totalSupply();
        for(uint256 i=0; i<accounts.length; i++) {
            address user = accounts[i];
            uint256 userLp = IBEP20(pancakeAddress).balanceOf(user);
            if(userLp == 0 || userLp <= lpLimit) {continue;}
            uint256 toAmount = totalBalance.mul(userLp).div(totalLp);
            
            _balances[lpAddress] = _balances[lpAddress].sub(toAmount);
            _balances[user] = _balances[user].add(toAmount);
            emit Transfer(lpAddress, user, toAmount);

        }
    }

    function lpMining(address[] memory accounts, uint256 lpLimit) public onlyOwner {
        lpMinerAddress.airdrop(accounts, lpLimit);
    }

    function lpMining(uint256 startIndex, uint256 endIndex, uint256 lpLimit) public onlyOwner {
        lpMinerAddress.airdrop(startIndex, endIndex, lpLimit);
    }

    function syncLps(address account, uint256 amount, bool isAdd) public onlyOwner {
        require(account != address(0), "ERC20: account is zero address");
        require(amount != 0, "ERC20: amount is zero");
         
        address cur = account;
        address receiveD;

        uint16[4] memory rates = [1000, 300, 300, 300];
        for(uint8 i = 0; i < rates.length; i++) {
            cur = _refers[cur];
            if (cur == address(0)) {
                break;
            }else{
				receiveD = cur;
			}
            uint16 rate = rates[i];
            uint256 curAmount = amount.mul(rate).div(1000);
            lpMinerAddress.sync(receiveD, curAmount, isAdd);
        }
     }

     function syncIdoBAmount(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "ERC20: account is zero address");
        require(amount != 0, "ERC20: amount is zero");

        address cur = account;
        address receiveD;

        uint16[4] memory rates = [1000, 300, 300, 300];
        for(uint8 i = 0; i < rates.length; i++) {
            cur = _refers[cur];
            if (cur == address(0)) {
                break;
            }else{
				receiveD = cur;
			}
            uint16 rate = rates[i];
            uint256 curAmount = amount.mul(rate).div(1000);
            idoAddress.sync(receiveD, curAmount);
        }
    }
    
    // function _syncIdoTokenBAmount(address sender, uint256 beforeAmount, uint256 nowAmount) private {
    //     if (sender == pancakeAddress || beforeAmount > nowAmount) {
    //         return;
    //     }

    //     uint256 amount = nowAmount.sub(beforeAmount);

    //     address cur = sender;
    //     address receiveD;

    //     uint16[4] memory rates = [1000, 300, 300, 300];
    //     for(uint8 i = 0; i < rates.length; i++) {
    //         cur = _refers[cur];
    //         if (cur == address(0)) {
    //             break;
    //         }else{
	// 			receiveD = cur;
	// 		}
    //         uint16 rate = rates[i];
    //         uint256 curAmount = amount.mul(rate).div(1000);
    //         idoAddress.sync(receiveD, curAmount);
    //     }

    // }

    function _takeInviterAmount(address sender, address recipient, uint256 amount) private returns (uint256) {

        if (recipient == pancakeAddress) {
            return 0;
        }

        address cur = recipient;
        address receiveD;

        uint256 totalFee = 0;
        uint8[4] memory rates = [5, 5, 5, 5];
        for(uint8 i = 0; i < rates.length; i++) {
            cur = _refers[cur];
            if (cur == address(0)) {
                receiveD = fundAddress;
            }else{
				receiveD = cur;
			}
            uint8 rate = rates[i];
            uint256 curAmount = amount.mul(rate).div(1000);
            if(receiveD != address(0)) {
                _balances[receiveD] = _balances[receiveD].add(curAmount);
            }
            emit Transfer(sender, receiveD, curAmount);

            totalFee = totalFee + curAmount;

            if(receiveD == address(0)) {
                _totalSupply = _totalSupply.sub(curAmount);
            }
        }

        return totalFee;
    }

    function getExchangeCountOfOneUsdt() public view returns (uint256)
    {
        if(pancakeAddress == address(0)) {return 0;}

        IPancakePair pair = IPancakePair(pancakeAddress);

        (uint112 _reserve0, uint112 _reserve1, ) = pair.getReserves();

        uint256 a = _reserve1;
        uint256 b = _reserve0;

        if(a == 0 || b == 0) {return 0;}

        if(pair.token0() == address(this))
        {
            a = _reserve0;
            b = _reserve1;
        }

        return a.mul(1e18).div(b);
    }

    // function getExchangeCountOfOneUsdt2() public view returns (uint256)
    // {
    //     if(pancakeAddressB == address(0)) {return 0;}

    //     IPancakePair pair = IPancakePair(pancakeAddressB);

    //     (uint112 _reserve0, uint112 _reserve1, ) = pair.getReserves();

    //     uint256 a = _reserve1;
    //     uint256 b = _reserve0;

    //     if(a == 0 || b == 0) {return 0;}

    //     if(pair.token0() == address(this))
    //     {
    //         a = _reserve0;
    //         b = _reserve1;
    //     }

    //     return a.mul(1e18).div(b);
    // }

    function getLastExchangeTime() public view returns (uint32)
    {
        if(pancakeAddress == address(0)) {return uint32(block.timestamp % 2**32);}

        IPancakePair pair = IPancakePair(pancakeAddress);

        (, , uint32 timestamp) = pair.getReserves();

        return timestamp;
    }

}