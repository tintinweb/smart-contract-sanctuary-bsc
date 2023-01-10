// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13 <0.9.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
interface IERC20Meta is IERC20 {
    function tokenPair() external view returns (address pair);
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

pragma solidity >=0.8 <0.9.0;

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

pragma solidity >=0.8 <0.9.0;
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}


pragma solidity >=0.8.13 <0.9.0;
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract LockpaySwap is Ownable {
    using SafeMath for uint256;
    bool private swapping;

    IUniswapV2Router02 public uniswapV2Router;
    address public bnb_address;
    address public lockpay_address;

    address public directPaymentBNBAddressReceiver;
    address public tokenWalletForSendingLOCKPAYfrom;

    address public uniswapRouter;

    uint256 public bonusDirectTransaction = 1; //0.1%
    bool public sendLockpayIncoming = true;
    
    uint256 private MAX_INT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;


    event TransferReceived (
        address indexed buyer,
        uint256 amount,
        uint256 price,
        uint256 paidLockpay
    );
    event TransferSentBack (
        address indexed buyer,
        uint256 amount
    );


    constructor() {
            if( block.chainid == 97) {
                 uniswapRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //testnet
            }
            else{
                 uniswapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //mainnet
            }

            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniswapRouter);
            uniswapV2Router = _uniswapV2Router;
            bnb_address = _uniswapV2Router.WETH();
        }

    /*
    receive() external payable {
        if( sendLockpayIncoming) {
                    uint256 LockpayPrice = getPriceBNB(msg.value);
                    uint256 paidLockpay = LockpayPrice.mul(bonusDirectTransaction).div(1000);

                    address payable wallet1 = payable(directPaymentBNBAddressReceiver);
                    wallet1.transfer(msg.value);
                    emit TransferReceived(msg.sender, msg.value, LockpayPrice,paidLockpay);
                    IERC20(lockpay_address).transferFrom(
                            tokenWalletForSendingLOCKPAYfrom,
                            msg.sender,
                            paidLockpay
                    );
                }
                else{
                    address payable wallet1 = payable(msg.sender);
                    wallet1.transfer(msg.value);
                    emit TransferSentBack(msg.sender, msg.value);
        }
  	}*/
    
    function recoverTokens(address tokenAddress, address receiver) external onlyOwner {
        IERC20(tokenAddress).approve(address(this), MAX_INT);
        IERC20(tokenAddress).transferFrom(
                            address(this),
                            receiver,
                            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    function previewPrice( uint256 amount) public view returns(uint256 paidLockpay) {
        uint256 LockpayPrice = getPriceBNB(amount);
        paidLockpay = LockpayPrice.mul(bonusDirectTransaction).div(1000);
        return paidLockpay;
    }

    function buy() payable public {
            if( sendLockpayIncoming) {
                    uint256 LockpayPrice = getPriceBNB(msg.value);
                    require(msg.value > 0, "You need to send some BNBs");
                    uint256 paidLockpay = LockpayPrice.mul(bonusDirectTransaction).div(1000);

                    address payable wallet1 = payable(directPaymentBNBAddressReceiver);
                    wallet1.transfer(msg.value);
                    emit TransferReceived(msg.sender, msg.value, LockpayPrice,paidLockpay);
                    IERC20(lockpay_address).transferFrom(
                            tokenWalletForSendingLOCKPAYfrom,
                            msg.sender,
                            paidLockpay
                    );
                }
                else{
                    address payable wallet1 = payable(msg.sender);
                    wallet1.transfer(msg.value);
                    emit TransferSentBack(msg.sender, msg.value);
        }
    }



    function getPriceBNB(uint256 inAmount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = bnb_address;
        path[1] = lockpay_address;
        return uniswapV2Router.getAmountsOut(inAmount, path)[1];
    }


    function setBonusDirectTransaction(uint256 value) external onlyOwner {
        require(value >= 0, "Bonus direct transaction greater than 0");
        bonusDirectTransaction = value;
    }

    function updateDirectPaymentBNBAddressReceiver(address newAddress) public onlyOwner {
        directPaymentBNBAddressReceiver = newAddress;
    }

    function setLockpayAddress(address newAddress) public onlyOwner {
        lockpay_address = newAddress;
    }


    function updateTokenWalletForSendingLOCKPAYfrom(address newAddress) public onlyOwner {
        tokenWalletForSendingLOCKPAYfrom = newAddress;
    }


    function setSendLockpayIncoming(bool _send) public onlyOwner {
        sendLockpayIncoming = _send;
    }

    
    function getContractBNBBalance() public view returns (uint256) {
        uint256 contractBNBBalance = address(this).balance;
        return contractBNBBalance; 
    }

    function sendBNBtoWallet(uint256 bnbBalance) public onlyOwner {
        transferOutBNB(payable(directPaymentBNBAddressReceiver), bnbBalance);
    }

    function sendAllBNBToWallet() public onlyOwner {
        transferOutBNB(payable(directPaymentBNBAddressReceiver), getContractBNBBalance());
    }

    function transferOutBNB(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

}

pragma solidity >=0.8.13 <0.9.0;

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

pragma solidity >=0.8.13 <0.9.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}