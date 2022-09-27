/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WBNB() external pure returns (address);

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

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Ownable 
{    
  // Variable that maintains 
  // owner address
  address private _owner;
  
  // Sets the original owner of 
  // contract when it is deployed
  constructor()
  {
    _owner = msg.sender;
  }
  
  // Publicly exposes who is the
  // owner of this contract
  function owner() public view returns(address) 
  {
    return _owner;
  }
  
  // onlyOwner modifier that validates only 
  // if caller of function is contract owner, 
  // otherwise not
  modifier onlyOwner() 
  {
    require(isOwner(),
    "Function accessible only by the owner !!");
    _;
  }
  
  // function for owners to verify their ownership. 
  // Returns true for owners otherwise false
  function isOwner() public view returns(bool) 
  {
    return msg.sender == _owner;
  }
}

contract OboSwap is Ownable {
    using SafeMath for uint;

    //address of pancakeswap v2 router
    address private constant PANCAKE_V2_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private constant DEFAULT_FEE_ADDRESS = 0xb2566B33E0396E6A392F8a94FbC0C35e020ea592;

    address internal constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public contract_address;

    address[] public feeRecipientsAddresses;
    uint8[] public feeRecipientsFees;

    // mapping(address => uint8) public feeRecipients;

    constructor() {
        contract_address = address(this);
    }

    function ContractAddress() public view returns(address) {
        return contract_address;
    }

    function Allowance(address _tokenIn) external view returns (uint) {
        uint allowed_amount = IERC20(_tokenIn).allowance(msg.sender, contract_address);
        return allowed_amount;
    }

    function _allowance(address _tokenIn) private view returns (uint) {
        uint allowed_amount = IERC20(_tokenIn).allowance(msg.sender, contract_address);
        return allowed_amount;
    }

    function BalanceOf(address _tokenIn) external view returns (uint) {
        uint balance_amount = IERC20(_tokenIn).balanceOf(msg.sender);
        return balance_amount;
    }

    function _balanceOf(address _tokenIn) private view returns (uint) {
        uint balance_amount = IERC20(_tokenIn).balanceOf(msg.sender);
        return balance_amount;
    }

    function setFeeRecipients(address[] memory recipient_addresses, uint8[] memory recipient_fees) external onlyOwner {
        require(recipient_addresses.length == recipient_fees.length, "Recipient Addresses and Fees must be the same length");

        uint8 totalFees = 0;
        for (uint i = 0; i < recipient_fees.length; i++) {
            totalFees = totalFees + recipient_fees[i];
        }

        require(totalFees <= 100, "Total Fees cannot exceed 100");

        feeRecipientsAddresses = recipient_addresses;
        feeRecipientsFees = recipient_fees;
    }

    function takeFee(uint256 amountToTax, uint8 feePercentage) private pure returns (uint dev_tax_amount, uint amount_after_tax) {
        uint256 _dev_tax_amount;

        if (feePercentage == 0) {
            // Support 0.1% fee by default
            _dev_tax_amount = uint256 (1).mul(amountToTax.div(10)).div(100);
        } else {
            // Support fee >= 1
            _dev_tax_amount = uint256 (feePercentage).mul(amountToTax).div(100);
        }

        uint256 _amount_after_tax = amountToTax.sub(dev_tax_amount);

        return (_dev_tax_amount, _amount_after_tax);
    }

    function splitAndSendFeeToRecipients(address _tokenIn, uint256 feeAmount) private {
        if (feeRecipientsAddresses.length == 0) {
            IERC20(_tokenIn).transferFrom(msg.sender, address(DEFAULT_FEE_ADDRESS), feeAmount);
        }

        for (uint i = 0; i < feeRecipientsAddresses.length; i++) {
            uint256 recipient_amount = uint256(feeRecipientsFees[i]).mul(feeAmount).div(100);
            IERC20(_tokenIn).transferFrom(msg.sender, address(feeRecipientsAddresses[i]), recipient_amount);
        }
    }

    modifier safeAmount(uint256 _amountIn) {
        require(uint256(_amountIn) >= 1000, "Insufficient amountIn");
        _;
    }

    modifier safeAllowance(address _tokenIn, uint256 _amountIn) {
        // Require: More or Equal user allowance than amountIn
        if (_tokenIn != NATIVE_TOKEN) require(uint256(_allowance(_tokenIn)) >= uint256(_amountIn), "Insufficient allowance. Need to approve");
        _;
    }

    modifier safeBalance(address _tokenIn, uint256 _amountIn) {
        // Require: More or Equal user balance than amountIn
        require(uint256(_balanceOf(_tokenIn)) >= uint256(_amountIn), "Insufficient balance");
        _;
    }

    modifier safeFee(uint8 feePercentage) {
        // Require: Fees less or equal than 1%
        require(feePercentage <= 10, "Fees cannot exceed 1%");
        _;
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline,
        uint8 feePercentage
    ) external payable {
        uint amountIn = msg.value;

        require(uint256(amountIn) >= 1000, "Insufficient amountIn");

        // Require: Fees less or equal than 1%
        require(feePercentage <= 10, "Fees cannot exceed 1%");

        address _tokenIn = NATIVE_TOKEN;

        // take fee and send it to dev-wallet
        (uint256 dev_tax_amount, uint256 amount_after_tax) = takeFee(amountIn, feePercentage);

        // transfer the fee        
        splitAndSendFeeToRecipients(_tokenIn, dev_tax_amount);

        // transfer the token amount in this contract address
        IERC20(_tokenIn).transferFrom(msg.sender, contract_address, amount_after_tax);

        IERC20(_tokenIn).approve(PANCAKE_V2_ROUTER_ADDRESS, amount_after_tax);

        IPancakeRouter02(PANCAKE_V2_ROUTER_ADDRESS).swapExactETHForTokensSupportingFeeOnTransferTokens(amountOutMin, path, to, deadline);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline,
        uint8 feePercentage
    ) external {
        require(uint256(amountIn) >= 1000, "Insufficient amountIn");

        address _tokenIn = path[0];

        // Require: More or Equal user balance than amountIn
        require(uint256(_balanceOf(_tokenIn)) >= uint256(amountIn), "Insufficient balance");
        // Require: More or Equal user allowance than amountIn
        if (_tokenIn != NATIVE_TOKEN) require(uint256(_allowance(_tokenIn)) >= uint256(amountIn), "Insufficient allowance. Need to approve");
        // Require: Fees less or equal than 1%
        require(feePercentage <= 10, "Fees cannot exceed 1%");

        // take fee and send it to dev-wallet
        (uint256 dev_tax_amount, uint256 amount_after_tax) = takeFee(amountIn, feePercentage);

        // transfer the fee        
        splitAndSendFeeToRecipients(_tokenIn, dev_tax_amount);

        // transfer the token amount in this contract address
        IERC20(_tokenIn).transferFrom(msg.sender, contract_address, amount_after_tax);

        IERC20(_tokenIn).approve(PANCAKE_V2_ROUTER_ADDRESS, amount_after_tax);

        IPancakeRouter02(PANCAKE_V2_ROUTER_ADDRESS).swapExactTokensForTokensSupportingFeeOnTransferTokens(amount_after_tax, amountOutMin, path, to, deadline);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline,
        uint8 feePercentage
    ) external {
        require(uint256(amountIn) >= 1000, "Insufficient amountIn");

        address _tokenIn = path[0];

        // Require: More or Equal user balance than amountIn
        require(uint256(_balanceOf(_tokenIn)) >= uint256(amountIn), "Insufficient balance");
        // Require: More or Equal user allowance than amountIn
        if (_tokenIn != NATIVE_TOKEN) require(uint256(_allowance(_tokenIn)) >= uint256(amountIn), "Insufficient allowance. Need to approve");
        // Require: Fees less or equal than 1%
        require(feePercentage <= 10, "Fees cannot exceed 1%");

        // take fee and send it to dev-wallet
        (uint256 dev_tax_amount, uint256 amount_after_tax) = takeFee(amountIn, feePercentage);

        // transfer the fee        
        splitAndSendFeeToRecipients(_tokenIn, dev_tax_amount);

        // transfer the token amount in this contract address
        IERC20(_tokenIn).transferFrom(msg.sender, contract_address, amount_after_tax);

        IERC20(_tokenIn).approve(PANCAKE_V2_ROUTER_ADDRESS, amount_after_tax);

        IPancakeRouter02(PANCAKE_V2_ROUTER_ADDRESS).swapExactTokensForETHSupportingFeeOnTransferTokens(amount_after_tax, amountOutMin, path, to, deadline);
    }
}