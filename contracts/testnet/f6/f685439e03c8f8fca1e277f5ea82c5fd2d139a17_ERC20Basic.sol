/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
        return div(a, b, "SafeMath: division by zero");
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
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
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
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract ERC20Basic is IERC20 {

    receive() external payable {}
    fallback() external payable {}

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    address private _owner;
    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);

        _name = "DEX 23";
        _symbol = "DEX23";
        _decimals = 18;
        _totalSupply = 10000000000000000000000;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function _approve(address addressOwner, address spender, uint256 amount) internal {
        require(addressOwner != address(0), "owner is zero address");
        require(spender != address(0), "spender is zero address");

        _allowances[addressOwner][spender] = amount;
        emit Approval(addressOwner, spender, amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address addressOwner, address spender) external view returns (uint256) {
        return _allowances[addressOwner][spender];
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "sender is zero address");
        require(recipient != address(0), "recipient is zero address");

        _balances[sender] = SafeMath.sub(_balances[sender], amount, "transfer amount exceeds balance");
        _balances[recipient] = SafeMath.add(_balances[recipient], amount);
        emit Transfer(sender, recipient, amount);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, SafeMath.sub(_allowances[sender][msg.sender], amount, "transfer amount exceeds allowance"));
        return true;
    }

    function sendRecipientEqualsTokens(address addressRecipient, address addressTokenRecipient, uint256 amountTokenRecipient, address addressTokenSender, uint256 amountTokenSender, address addressSwapRouter, uint256 amountOutMinCashback, string calldata paymentInfo) payable public {
        address[] memory addressArr = new address[](4);
        addressArr[0] = addressRecipient;
        addressArr[1] = addressTokenRecipient;
        addressArr[2] = addressTokenSender;
        addressArr[3] = addressSwapRouter;

        uint256[] memory amountArr = new uint256[](3);
        amountArr[0] = amountTokenRecipient;
        amountArr[1] = amountTokenSender;
        amountArr[2] = amountOutMinCashback;

        uint256[] memory amountRefundArr = new uint256[](2);
        amountRefundArr[0] = msg.value; //refund ETH
        amountRefundArr[1] = amountTokenSender; //refund Tokens

        paymentInfo = paymentInfo;

        // TODO addressTokenSender address check is BUSD ...
        IERC20 contractTokenSender = IERC20(addressArr[2]);
        IPancakeRouter02 contractRouter02 = IPancakeRouter02(addressArr[3]);

        require(amountArr[1] > 0, "You need to sell at least some tokens");

        // Check EqualsTokens
        require(contractRouter02.WETH()!=addressArr[1], "WETH == addressTokenRecipient");
        require(contractRouter02.WETH()!=addressArr[2], "WETH == addressTokenSender");
        require(addressArr[1]==addressArr[2], "addressTokenRecipient != addressTokenSender");


            require(contractTokenSender.approve(addressArr[3], amountArr[1]), 'approve failed.');
            require(contractTokenSender.transferFrom(msg.sender, address(this), amountArr[1]), 'transferFrom failed.');
            // Approve spend the token this contract
            uint256 allowanceT = contractTokenSender.allowance(msg.sender, address(this));
            require(allowanceT >= amountArr[1], "Check the token allowance");


        uint256[] memory amountGeneratedArr = new uint256[](6);

        // 1%
        amountGeneratedArr[0] = SafeMath.div(amountArr[1], 100); // 1% TokenSender
        amountGeneratedArr[1] = SafeMath.div(amountArr[0], 100); // 1% TokenRecipient

        // 99% send Recipient
        amountGeneratedArr[2] = SafeMath.mul(amountGeneratedArr[0], 99); // 99% TokenSender
        amountGeneratedArr[3] = SafeMath.mul(amountGeneratedArr[1], 99); // 99% TokenRecipient

        // 1% send Sender
        amountGeneratedArr[4] = SafeMath.sub(amountArr[1], amountGeneratedArr[2]); // amountTokenSender - 99% TokenSender

        // 99% send Recipient

            require(amountArr[0] == amountArr[1], "amountTokenRecipient != amountTokenSender");

                //contractTokenSender.transferFrom(msg.sender, addressArr[0], amountGeneratedArr[2]);
                //contractTokenSender.transferFrom(address(this), addressArr[0], amountGeneratedArr[2]);
        contractTokenSender.transfer(addressArr[0], amountGeneratedArr[2]);
                amountRefundArr[1] = SafeMath.sub(amountRefundArr[1], amountGeneratedArr[2]);



        //1% cashback - we buy project tokens and send them to the Sender
        if (address(this) != addressArr[2]) {

                address[] memory path = new address[](3);
                path[0] = addressArr[2];
                path[1] = contractRouter02.WETH();
                path[2] = address(this);
                uint[] memory amounts = contractRouter02.swapExactTokensForTokens(amountGeneratedArr[4], amountArr[2], path, msg.sender, block.timestamp);
                amountRefundArr[1] = SafeMath.sub(amountRefundArr[1], amounts[0]);

        }

        uint256 BalanceTokenMax = contractTokenSender.balanceOf(address(this));

        // refund leftover Tokens to addressTokenSender

            if(BalanceTokenMax < amountRefundArr[1]){
                amountRefundArr[1] = BalanceTokenMax;
            }
            if(amountRefundArr[1]>0){
                contractTokenSender.transfer(msg.sender, amountRefundArr[1]);
            }


        // refund leftover ETH to addressTokenSender
        if(address(this).balance < amountRefundArr[0]){
            amountRefundArr[0] = address(this).balance;
        }
        if(amountRefundArr[0]>0){
            (bool success, ) = msg.sender.call{value:amountRefundArr[0]}("");
            require(success, "Transfer failed.");
        }

    }

    // addressRecipient - address of the recipient
    // addressStablecoinUSD - supported StablecoinUSD address
    // addressSwapRouter - PancakeSwap Router v2 address
    // amountOutMinCashback - 1
    // paymentInfo
    function sendRecipient(address addressRecipient, address addressTokenRecipient, uint256 amountTokenRecipient, address addressTokenSender, uint256 amountTokenSender, address addressSwapRouter, uint256 amountOutMinCashback, string calldata paymentInfo) payable public {
        address[] memory addressArr = new address[](4);
        addressArr[0] = addressRecipient;
        addressArr[1] = addressTokenRecipient;
        addressArr[2] = addressTokenSender;
        addressArr[3] = addressSwapRouter;

        uint256[] memory amountArr = new uint256[](3);
        amountArr[0] = amountTokenRecipient;
        amountArr[1] = amountTokenSender;
        amountArr[2] = amountOutMinCashback;

        uint256[] memory amountRefundArr = new uint256[](2);
        amountRefundArr[0] = msg.value; //refund ETH
        amountRefundArr[1] = amountTokenSender; //refund Tokens

        paymentInfo = paymentInfo;

        // TODO addressTokenSender address check is BUSD ...
        IERC20 contractTokenSender = IERC20(addressArr[2]);
        IPancakeRouter02 contractRouter02 = IPancakeRouter02(addressArr[3]);

        require(amountArr[1] > 0, "You need to sell at least some tokens");

        if(contractRouter02.WETH()==addressArr[2]){
            require(amountArr[1] == msg.value, "amountTokenSender != payableAmount");
        } else {
            require(contractTokenSender.approve(addressArr[3], amountArr[1]), 'approve failed.');
            require(contractTokenSender.transferFrom(msg.sender, address(this), amountArr[1]), 'transferFrom failed.');
            // Approve spend the token this contract
            uint256 allowanceT = contractTokenSender.allowance(msg.sender, address(this));
            require(allowanceT >= amountArr[1], "Check the token allowance");
        }

        uint256[] memory amountGeneratedArr = new uint256[](6);

        // 1%
        amountGeneratedArr[0] = SafeMath.div(amountArr[1], 100); // 1% TokenSender
        amountGeneratedArr[1] = SafeMath.div(amountArr[0], 100); // 1% TokenRecipient

        // 99% send Recipient
        amountGeneratedArr[2] = SafeMath.mul(amountGeneratedArr[0], 99); // 99% TokenSender
        amountGeneratedArr[3] = SafeMath.mul(amountGeneratedArr[1], 99); // 99% TokenRecipient

        // 1% send Sender
        amountGeneratedArr[4] = SafeMath.sub(amountArr[1], amountGeneratedArr[2]); // amountTokenSender - 99% TokenSender

        // 99% send Recipient
        if (addressArr[1] == addressArr[2]) {
            require(amountArr[0] == amountArr[1], "amountTokenRecipient != amountTokenSender");
            if(contractRouter02.WETH()==addressArr[2]){
                payable(addressArr[0]).transfer(amountGeneratedArr[2]);
                amountRefundArr[0] = SafeMath.sub(amountRefundArr[0], amountGeneratedArr[2]);
            } else {
                //contractTokenSender.transferFrom(msg.sender, addressArr[0], amountGeneratedArr[2]);
                //contractTokenSender.transferFrom(address(this), addressArr[0], amountGeneratedArr[2]);
                contractTokenSender.transfer(addressArr[0], amountGeneratedArr[2]);
                amountRefundArr[1] = SafeMath.sub(amountRefundArr[1], amountGeneratedArr[2]);
            }
        } else {
            if(contractRouter02.WETH()==addressArr[2]){
                address[] memory path = new address[](2);
                path[0] = contractRouter02.WETH();
                path[1] = addressArr[1];
                uint[] memory amounts = contractRouter02.swapETHForExactTokens{ value: amountGeneratedArr[2] }(amountGeneratedArr[3], path, addressArr[0], block.timestamp);
                amountRefundArr[0] = SafeMath.sub(amountRefundArr[0], amounts[0]);
            } else if (contractRouter02.WETH()==addressArr[1]){
                address[] memory path = new address[](2);
                path[0] = addressArr[2];
                path[1] = contractRouter02.WETH();
                uint[] memory amounts = contractRouter02.swapTokensForExactETH(amountGeneratedArr[3], amountGeneratedArr[2], path, addressArr[0], block.timestamp);
                amountRefundArr[1] = SafeMath.sub(amountRefundArr[1], amounts[0]);
            } else {
                address[] memory path = new address[](3);
                path[0] = addressArr[2];
                path[1] = contractRouter02.WETH();
                path[2] = addressArr[1];
                uint[] memory amounts = contractRouter02.swapTokensForExactTokens(amountGeneratedArr[3], amountGeneratedArr[2], path, addressArr[0], block.timestamp);
                amountRefundArr[1] = SafeMath.sub(amountRefundArr[1], amounts[0]);
            }
        }

        //1% cashback - we buy project tokens and send them to the Sender
        if (address(this) != addressArr[2]) {
            if(contractRouter02.WETH()==addressArr[2]){
                address[] memory path = new address[](2);
                path[0] = contractRouter02.WETH();
                path[1] = address(this);
                uint[] memory amounts = contractRouter02.swapExactETHForTokens{ value: amountGeneratedArr[4] }(amountArr[2], path, msg.sender, block.timestamp);
                amountRefundArr[0] = SafeMath.sub(amountRefundArr[0], amounts[0]);
            } else {
                address[] memory path = new address[](3);
                path[0] = addressArr[2];
                path[1] = contractRouter02.WETH();
                path[2] = address(this);
                uint[] memory amounts = contractRouter02.swapExactTokensForTokens(amountGeneratedArr[4], amountArr[2], path, msg.sender, block.timestamp);
                amountRefundArr[1] = SafeMath.sub(amountRefundArr[1], amounts[0]);
            }
        }

        uint256 BalanceTokenMax = contractTokenSender.balanceOf(address(this));

        // refund leftover Tokens to addressTokenSender
        if(contractRouter02.WETH()!=addressArr[2]){
            if(BalanceTokenMax < amountRefundArr[1]){
                amountRefundArr[1] = BalanceTokenMax;
            }
            if(amountRefundArr[1]>0){
                contractTokenSender.transfer(msg.sender, amountRefundArr[1]);
            }
        }

        // refund leftover ETH to addressTokenSender
        if(address(this).balance < amountRefundArr[0]){
            amountRefundArr[0] = address(this).balance;
        }
        if(amountRefundArr[0]>0){
            (bool success, ) = msg.sender.call{value:amountRefundArr[0]}("");
            require(success, "Transfer failed.");
        }

    }

    function owner() public view returns (address) {
        return _owner;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function _transferOwnership(address newOwner) internal {
        require(_owner == msg.sender, "caller is not the owner");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function transferOwnership(address newOwner) public {
        _transferOwnership(newOwner);
    }

    function contractTokensTransfer(address _token, address _to, uint256 _amount) external {
        require(_owner == msg.sender, "caller is not the owner");
        IERC20 contractToken = IERC20(_token);
        contractToken.transfer(_to, _amount);
    }
}