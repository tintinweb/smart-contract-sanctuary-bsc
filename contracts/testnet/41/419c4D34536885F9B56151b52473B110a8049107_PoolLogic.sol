/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: contracts/libraries/SafeMath.sol


pragma solidity ^0.8.11;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)
library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}
// File: contracts/libraries/TransferHelper.sol


pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
// File: contracts/PoolLogic.sol


pragma solidity ^0.8.11;




//  import the ERC20 interface
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

//  import pancakeswapv2 Router
//  the contract needs to use swapExactTokensForTokens
//  this will allow us to import swapExactTokensForTokens into our contract
interface IPancakeRouter02 {
    function WETH() external pure returns (address);
    
    function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);

    //  Receive an as many output tokens as possible for an exact amount of input tokens.
    function swapExactTokensForTokens(
        //  amount of tokens we are sending in
        uint256 amountIn,
        //  the minimum amount of tokens we want out of the trade
        uint256 amountOutMin,
        //  list of token addresses we are going to trade in.  this is necessary to calculate amounts
        address[] calldata path,
        //  this is the address we are going to send the output tokens to
        address to,
        //  the last time that the trade is valid for
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    //  Receive an exact amount of output tokens for as few input tokens as possible.
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    //  Receive an as many output tokens as possible for an exact amount of BNB.
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    //  Receive an exact amount of ETH for as few input tokens as possible.
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    //  Receive an as much BNB as possible for an exact amount of input tokens.
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    //  Receive an exact amount of output tokens for as little BNB as possible.
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract PoolLogic is ReentrancyGuard {
    using SafeMath for uint;

    // address public immutable factory;
    address public immutable router;
    address public immutable WBNB;


    // Declare state variables of the contract
    address public _owner = 0x2E2854cb744b8dd6FF48291F59671076612f28Dd;
    address public _manager;
    address payable[] private _investors;

    mapping(address => uint256) public _balances;
    mapping(address => uint256) public _indexOfInvestor;

    event Deposit(address from, uint256 value);
    event Withdraw(address to, uint256 value);
    event Received(address, uint256);

    constructor(address _router, address _WBNB) {
        _manager = msg.sender;
        // factory = _factory;
        router = _router;
        WBNB = _WBNB;
    }

    modifier onlyManager() {
        require(msg.sender == _manager, "only manager");
        _;
    }

    receive() external payable {
        assert(msg.sender == WBNB); // only accept ETH via fallback from the WBNB contract
        emit Received(msg.sender, msg.value);
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    function listInvestor() external view returns(address payable[] memory) {
        return _investors;
    }

    function deposit() external payable {
        require(msg.value > 0, "Amount insufficient");
        _balances[msg.sender] += msg.value;

        if (_indexOfInvestor[msg.sender] == 0) {
            _investors.push(payable(msg.sender));
            _indexOfInvestor[msg.sender] = _investors.length;
        }

        emit Deposit(msg.sender, msg.value);
    }
    
    function withdraw() external nonReentrant {
        uint256 amount = _balances[msg.sender];
        require(amount > 0 , "Balance insufficient");
        _balances[msg.sender] = 0; 

        remove(_indexOfInvestor[msg.sender] - 1);
        delete _indexOfInvestor[msg.sender];

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Failed to withdraw");

        emit Withdraw(msg.sender, amount);
    }

    // Move the last element to the deleted spot.
    // Remove the last element.
    function remove(uint256 index) private {
        require(index < _investors.length);
        bool isLastIndex = false;
        if (_investors[index] == _investors[_investors.length-1]) {
            isLastIndex = true;
        }
        _investors[index] = _investors[_investors.length-1];
        _investors.pop();

        if (!isLastIndex) {
            _indexOfInvestor[_investors[_investors.length-1]] = index + 1;
        }
    }

    function swapBNBToTokens(address _tokenOut,uint256 _amountIn, uint256 _amountOutMin) external onlyManager {
        uint amount = address(this).balance;
        require(amount > 0, "Zero balance");
        require(amount >= _amountIn, "Balance insufficient");

        address[] memory path;
        path = new address[](2);
        path[0] = WBNB;
        path[1] = _tokenOut;

        IPancakeRouter02(router).swapExactETHForTokens{value: _amountIn}(_amountOutMin, path, address(this), block.timestamp);
    }
}