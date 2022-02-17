/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

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

contract PoolLogic {
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

    bool internal locked;
    modifier noReentrant() {
        require(!locked);
        locked = true;
        _;
        locked = false;
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
    
    function withdraw() external noReentrant {
        uint256 amount = _balances[msg.sender];
        require(amount > 0 , "Balance insufficient");

        remove(_indexOfInvestor[msg.sender] - 1);
        delete _indexOfInvestor[msg.sender];

        _balances[msg.sender] = 0; 
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Failed to withdraw");

        emit Withdraw(msg.sender, amount);
    }

    // Move the last element to the deleted spot.
    // Remove the last element.
    function remove(uint256 index) private {
        require(index < _investors.length);
        _investors[index] = _investors[_investors.length-1];
        _investors.pop();
    }

    function swapExactTokensForTokens(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin) external onlyManager {
        require(address(this).balance > 0, "Zero balance");
        require(_amountIn <= address(this).balance, "Balance insufficient");
        TransferHelper.safeApprove(_tokenIn, address(router), _amountIn);

        //  path is an array of addresses.
        //  this path array will have 3 addresses [tokenIn, WBNB, tokenOut]
        //  if statement below takes into account if token in or token out is WBNB.  then the path is only 2 addresses
        address[] memory path;
        if (_tokenIn == WBNB || _tokenOut == WBNB) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WBNB;
            path[2] = _tokenOut;
        }
        
        IPancakeRouter02(router).swapExactTokensForTokens(_amountIn, _amountOutMin, path, address(this), block.timestamp);
    }
}