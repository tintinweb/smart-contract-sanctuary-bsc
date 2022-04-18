/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;


interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

   
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
     function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

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

interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

contract CMToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    uint256 private _decimals = 18;
    uint256 private _tTotal = 520000 * 10 ** _decimals;
    uint256 public holdTokenLimit = 5200 * 10 ** _decimals;
    uint256 public minIncome = 10 * 10 ** _decimals;

    string private _name = "CM";
    string private _symbol = "CM";
    
    uint256 public _lPFee = 20;
    uint256 public _burnFee = 10;
    uint256 public _marketFee = 10;
    uint256 public _fundFee = 10;
    uint256 public _inviterFee = 30;
    uint256 public totalFee = 80;

    mapping(address => address) public inviter;

    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapV2Pair;

    address public awardToken;
    address public funaddress;
    address public marketaddress;

    bool public swapsEnabled = false;

    mapping(address => bool) private _blackList;


    constructor (
        address _route,
        address _awardToken,
        address _funaddress,
        address _marketaddress
        ) public {
        
        awardToken = _awardToken;
        funaddress = _funaddress;
        marketaddress = _marketaddress;
        _tOwned[msg.sender] = _tTotal;

        _owner = msg.sender;
        
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(0)] = true;

        uniswapV2Router = IUniswapV2Router02(_route);
         
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), awardToken);

        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if(msg.sender == uniswapV2Pair){
             _transfer(_msgSender(), recipient, amount);
        }else{
            _tokenOlnyTransfer(_msgSender(), recipient, amount);
        }
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if(recipient == uniswapV2Pair){
             _transfer(sender, recipient, amount);
        }else{
             _tokenOlnyTransfer(sender, recipient, amount);
        }
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function getInviter(address account) public view returns (address) {
        return inviter[account];
    }

    function setInviter(address _address, address _parent) public onlyOwner {
        inviter[_address] = _parent;
    }

    function setSwapsEnabled(bool _enabled) public onlyOwner {
        swapsEnabled = _enabled;
    }

    function isBlackList(address account) public onlyOwner view returns (bool) {
        return _blackList[account];
    }

    function _setBlackList(address account, bool status) internal {
        _blackList[account] = status;
    }

    function setBlackList(address account, bool status) public onlyOwner returns(bool) {
        _setBlackList(account, status);
        return true;
    }

    receive() external payable {}

    function _take(uint256 tValue,address from,address to) private {
        _tOwned[to] = _tOwned[to].add(tValue);
        emit Transfer(from, to, tValue);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    struct Param{
        bool takeFee;
        uint tTransferAmount;
        uint tLP;
        uint tMk;
        uint tFd;
        uint tIfee;
        uint tBurn;
    }

    function _initParam(uint256 tAmount,Param memory param) private view  {
        param.tLP = tAmount * _lPFee / 1000;
        param.tMk = tAmount * _marketFee / 1000;
        param.tFd = tAmount * _fundFee / 1000;
        param.tBurn = tAmount * _burnFee / 1000;
        param.tIfee = tAmount * _inviterFee / 1000;
        uint tFee = tAmount * totalFee / 1000;
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _takeFee(Param memory param,address from)private {
        if( param.tLP > 0 ){
            _take(param.tLP, from, uniswapV2Pair);
        }
        if( param.tMk > 0 ){
            _take(param.tMk, from, marketaddress);
        }
        if( param.tFd > 0 ){
            _take(param.tMk, from, funaddress);
        }
        if( param.tBurn > 0 ){
            _take(param.tBurn, from, address(0));
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_blackList[from], "The address is blacklisted");
        require(!_blackList[to], "The address is blacklisted");

        require(swapsEnabled || _isExcludedFromFee[from] || _isExcludedFromFee[to], "zero");

        Param memory param;

        uint256 balance = balanceOf(from);
        if (amount == balance) {
            amount = amount.sub(1 * 10 ** 14);
        }

        param.tTransferAmount = amount;

        bool takeFee = true;

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        param.takeFee = takeFee;
        if( takeFee ){
            _initParam(amount,param);
        }
        _tokenTransfer(from,to,amount,param);
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount,Param memory param) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
        emit Transfer(sender, recipient, param.tTransferAmount);
        if(param.takeFee){
            _takeFee(param,sender);
            _takeInviterFee(sender, recipient, tAmount);
        }
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        address cur;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        }
        
        for (int256 i = 0; i < 6; i++) {
            uint256 rate;
            if (i == 0 || i == 1) {
                rate = 100;
            } else {
                rate = 25;
            }
            cur = inviter[cur];
            
            if (cur == address(0)) {
                cur = address(0);
                uint256 curTAmount = tAmount.div(10000).mul(rate);
                _burnTransfer(sender, cur, curTAmount);
            } else {
                uint256 balance = balanceOf(cur);
                uint256 curTAmount = tAmount.div(10000).mul(rate);
                if (balance < minIncome) {
                    _burnTransfer(sender, address(0), curTAmount);
                } else {
                    _tOwned[cur] = _tOwned[cur].add(curTAmount);
                    emit Transfer(sender, cur, curTAmount);
                }
            }
        }
    }

    function _burnTransfer (address sender, address to,uint256 tAmount) private {
        _tTotal = _tTotal.sub(tAmount);
        emit Transfer(sender, to, tAmount);
    }

    function _tokenOlnyTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        require(!_blackList[sender], "The address is blacklisted");
        require(!_blackList[recipient], "The address is blacklisted");

        require(swapsEnabled || _isExcludedFromFee[sender] || _isExcludedFromFee[recipient], "zero");

        if(_tOwned[recipient] == 0 && inviter[recipient] == address(0)){
          inviter[recipient] = sender;
        }
        // 扣除发送人的
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        
        if (_isExcludedFromFee[recipient] || _isExcludedFromFee[sender]) {
            _tOwned[recipient] = _tOwned[recipient].add(tAmount);
            emit Transfer(sender, recipient, tAmount);
        }else{
             _tTotal = _tTotal.sub(tAmount.div(100).mul(5));
            _tOwned[recipient] = _tOwned[recipient].add(tAmount.div(100).mul(95));
            emit Transfer(sender, address(0), tAmount.div(100).mul(5));
            emit Transfer(sender, recipient, tAmount.div(100).mul(95));
        }
    }

    function donateDust(address addr, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(addr, _msgSender(), amount);
    }

    function donateEthDust(uint256 amount) external onlyOwner {
        TransferHelper.safeTransferETH(_msgSender(), amount);
    }
}