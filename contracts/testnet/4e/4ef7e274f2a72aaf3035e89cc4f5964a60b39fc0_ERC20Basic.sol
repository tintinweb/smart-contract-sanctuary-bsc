/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

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

    string public constant name = "DEX 10";
    string public constant symbol = "DEX10";
    uint8 public constant decimals = 18;


    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_ = 10000 ether;


    constructor() {
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender]-numTokens;
        balances[receiver] = balances[receiver]+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner]-numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender]-numTokens;
        balances[buyer] = balances[buyer]+numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function swapTokensForETH(address addressSwapRouter, uint amountIn, uint amountOutMin) external {

        address addressUSDT = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684); // USDT
        IERC20 contractUSDT = IERC20(addressUSDT);

        //uint amountIn = 50 * 10 ** contractUSDT.decimals();
        require(contractUSDT.transferFrom(msg.sender, address(this), amountIn), 'transferFrom failed.');

        //address addressSwapRouter = address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // addressPancakeRouter
        require(contractUSDT.approve(addressSwapRouter, amountIn), 'approve failed.');
        IPancakeRouter02 contractRouter02 = IPancakeRouter02(addressSwapRouter);

        // amountOutMin must be retrieved from an oracle of some kind
        address[] memory path = new address[](2);
        path[0] = addressUSDT;
        path[1] = contractRouter02.WETH();
        //path[1] = address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd); // WBNB contract
        contractRouter02.swapExactTokensForETH(amountIn, amountOutMin, path, msg.sender, block.timestamp);
    }

    function swapTokens(address addressSwapRouter, uint amountIn, uint amountOutMin) external {

        address addressUSDT = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684); // USDT
        IERC20 contractUSDT = IERC20(addressUSDT);

        //uint amountIn = 50 * 10 ** contractUSDT.decimals();
        require(contractUSDT.transferFrom(msg.sender, address(this), amountIn), 'transferFrom failed.');

        //address addressSwapRouter = address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // addressPancakeRouter
        require(contractUSDT.approve(addressSwapRouter, amountIn), 'approve failed.');
        IPancakeRouter02 contractRouter02 = IPancakeRouter02(addressSwapRouter);

        // amountOutMin must be retrieved from an oracle of some kind
        address[] memory path = new address[](3);
        path[0] = addressUSDT;
        path[1] = contractRouter02.WETH();
        path[2] = address(this);
        contractRouter02.swapExactTokensForTokens(amountIn, amountOutMin, path, msg.sender, block.timestamp);
    }

    // addressRecipient - address of the recipient
    // addressStablecoinUSD - supported StablecoinUSD address
    // addressSwapRouter - PancakeSwap Router v2 address
    // amountOutMinCashback - 1
    // paymentInfo
    function sendRecipient(address addressRecipient, address addressTokenRecipient, uint256 amountTokenRecipient, address addressTokenSender, uint256 amountTokenSender, address addressSwapRouter, uint256 amountOutMinCashback, string calldata paymentInfo) public {
        address[] memory addressArr = new address[](4);
        addressArr[0] = addressRecipient;
        addressArr[1] = addressTokenRecipient;
        addressArr[2] = addressTokenSender;
        addressArr[3] = addressSwapRouter;

        uint256[] memory amountArr = new uint256[](3);
        amountArr[0] = amountTokenRecipient;
        amountArr[1] = amountTokenSender;
        amountArr[2] = amountOutMinCashback;

        paymentInfo = paymentInfo;
        require(amountArr[1] > 0, "You need to sell at least some tokens");

        // TODO addressTokenSender address check is BUSD ...
        IERC20 contractTokenSender = IERC20(addressArr[2]);
        IPancakeRouter02 contractRouter02 = IPancakeRouter02(addressArr[3]);
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
        if (addressArr[1] == addressArr[2] && amountArr[0] == amountArr[1]) {
            contractTokenSender.transferFrom(msg.sender, addressArr[0], amountGeneratedArr[2]);
        } else {
            //require(contractTokenSender.transferFrom(msg.sender, addressArr[1], amountGeneratedArr[2]), 'transferFrom failed.');

            // amountOutMin must be retrieved from an oracle of some kind
            address[] memory path = new address[](3);
            path[0] = addressArr[2];
            path[1] = contractRouter02.WETH();
            path[2] = addressArr[1];
            contractRouter02.swapExactTokensForTokens(amountGeneratedArr[2], amountGeneratedArr[3], path, addressArr[0], block.timestamp);
        }

        //1% cashback - we buy project tokens and send them to the Sender
        if (address(this) != addressArr[2]) {
            //require(contractTokenSender.transferFrom(msg.sender, address(this), amountGeneratedArr[4]), 'transferFrom failed.');

            // amountOutMin must be retrieved from an oracle of some kind
            address[] memory path = new address[](3);
            path[0] = addressArr[2];
            path[1] = contractRouter02.WETH();
            path[2] = address(this);
            contractRouter02.swapExactTokensForTokens(amountGeneratedArr[4], amountArr[2], path, msg.sender, block.timestamp);
        }

    }

    // Do not use in production
    // This function can be executed by anyone
    function sendTokens(address _token, address _to, uint256 _amount) external {
        // This is the mainnet USDT contract address
        // Using on other networks (rinkeby, local, ...) would fail
        //  - there's no contract on this address on other networks
        IERC20 usdt = IERC20(_token);

        // transfers USDT that belong to your contract to the specified address
        usdt.transfer(_to, _amount);
    }
}