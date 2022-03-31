/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

// SPDX-License-Identifier: MIT

// Crao Token is HERE to Disrupt the BNB Chain with Crypto Nodes and Rewards!  🚀
// JOIN the First of It’s Kind.

// ✅  Referrals Contract V1.2
// ✅  Earn BNB percentage of each buy


// 🐦 Twitter:  https://twitter.com/CraoToken
// 📲 Telegram: https://t.me/CraoToken
// 🌎 Website:  https://CraoToken.com


pragma solidity 0.8.13;


////////////////////////////////
/// BEP20 standard interface ///
////////////////////////////////
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
////////////////////////////////
////  Basic access control  ////
////////////////////////////////
abstract contract Ownable {
    address internal owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function Ownershiplock(uint256 time) public virtual onlyOwner {
        _previousOwner = owner;
        owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(owner, address(0));
    }

    function Ownershipunlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked");
        emit OwnershipTransferred(owner, _previousOwner);
        owner = _previousOwner;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
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

////////////////////////////////
/////   Router Interface   /////
////////////////////////////////

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
        function _msgSender() internal view virtual returns (address payable) {
    return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



////////////////////////////////
/// Contract  Implementation ///
////////////////////////////////

contract Referrals is Ownable {
 //   IWETH wbnb;
    using SafeMath for uint256;
    IDEXRouter public router;
    event Referral(address referrer, address buyer);
    event SetEarnPercentage(uint256 indexed earnPercentage);

    address public buyContract;
    uint public earnPercentage;

    constructor () Ownable(msg.sender) {
        buyContract = 0xD8162f7C7c83B260E9Fd0A77aA250A5C40Ff5A0e;
        // Mainnet: 0xD8162f7C7c83B260E9Fd0A77aA250A5C40Ff5A0e
        // Local:   0xc39F9115D6477002B8221f7AaE06Fd3E76428295
        earnPercentage = 12;
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // Local:   0xaF5287CbFF01619DBdd8980De6055c342950AB47
    }

    function setEarnPercentage(uint _earnPercentage) public onlyOwner returns (bool) {
        require(_earnPercentage <= 16, "dev: you cannot set that value!");
        earnPercentage = _earnPercentage;
        emit SetEarnPercentage(earnPercentage);
        return true;
    }

    function buyCraoToken(address referrer) 
    external 
    payable 
    returns (bool) {
        require(msg.value > 100, "dev: the minimum Buy amount is 100 wei BNB!");
        uint256 buyValue = msg.value;
        uint256 commission = buyValue.div(100).mul(earnPercentage);
        buyValue -= commission;
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = buyContract;

        
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: buyValue}(
            1,
            path,
            address(this),
            block.timestamp + 360
        );
        IBEP20(buyContract).transfer(msg.sender, IBEP20(buyContract).balanceOf(address(this)));

        address payable wallet = payable(referrer);
        wallet.transfer(commission);

        emit Referral(referrer, msg.sender);
        return true;
    }




    receive() external payable { }
}