/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-01
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

contract PCKToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    uint256 private _decimals = 18;
    uint256 private _tTotal = 10000 * 10 ** _decimals;

    string private _name = "PCK";
    string private _symbol = "PCK";
    
    uint256 public _lPFee = 100;
    uint256 public _burnFee = 20;
    uint256 public _recommendFee = 40;
    uint256 public totalFee = 160;

    IUniswapV2Router02 public uniswapV2Router;

    mapping(address => bool) public ammPairs;

    bool inSwapAndLiquify;
    
    IERC20 public uniswapV2Pair;
    address public awardToken;
    address public USDTToken = 0x55d398326f99059fF775485246999027B3197955;

    address public superAddress;

    address public swapV2PairAddress;
    
    uint256 public maxTxAmount = 3 * 10 ** _decimals;

    uint256 public whiteBiggest = 10 * 10 ** _decimals;

    uint256 public maxUsdtAmount = 10 * 10 ** _decimals;

    uint256 currentIndex;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 10 minutes;
    uint256 public LPFeefenhong;
     mapping(address => bool) private _updated;

    address private fromAddress;
    address private toAddress;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;

    bool public swapsEnabled = false;

    mapping(address => address) public inviter;

    uint256 public holdTokenLimit = 1368 * 10 ** _decimals;

    constructor (
        address _route,
        address _awardToken
        ) public {
         awardToken = _awardToken;
        _tOwned[msg.sender] = _tTotal;
        
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(0)] = true;

        uniswapV2Router = IUniswapV2Router02(_route);
         
        swapV2PairAddress = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), USDTToken);

        uniswapV2Pair = IERC20(swapV2PairAddress);
        ammPairs[swapV2PairAddress] = true;

        _owner = msg.sender;

        LPFeefenhong = block.timestamp;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function setLimitAmount(uint hl)external onlyOwner{
        holdTokenLimit = hl;
    }

    function setAmmPair(address pair,bool hasPair)external onlyOwner{
        ammPairs[pair] = hasPair;
    }

    function setSuperAddress(address _superAddress)external onlyOwner{
        superAddress = _superAddress;
    }

    function setTxAmount(uint _tx)external onlyOwner{
        maxTxAmount = _tx;
    }

    function setUsdtAmount(uint ft)external onlyOwner{
        maxUsdtAmount = ft;
    }

    function setMinPeriod(uint mp)external onlyOwner{
        minPeriod = mp;
    }

    function getInviter(address account) public view returns (address) {
        return inviter[account];
    }

    function setInviter(address _address, address _parent) public onlyOwner {
        inviter[_address] = _parent;
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
        if(msg.sender == swapV2PairAddress){
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
        if(recipient == swapV2PairAddress){
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

    function setSwapsEnabled(bool _enabled) public onlyOwner {
        swapsEnabled = _enabled;
    }

    receive() external payable {}

    function _take(uint256 tValue,address from,address to) private {
        if (to != address(0)) {
            _tOwned[to] = _tOwned[to].add(tValue);
        }
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
        uint tRF;
        uint tBurn;
    }

    function _initParam(uint256 tAmount,Param memory param) private view  {
        param.tLP = tAmount * _lPFee / 1000;
        param.tRF = tAmount * _recommendFee / 1000;
        if (_tTotal > holdTokenLimit) {
          param.tBurn = tAmount * _burnFee / 1000; 
        }
        uint256 tFee = tAmount * totalFee / 1000;
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _takeFee(Param memory param,address from, address to)private {
        if( param.tLP > 0 ){
            _take(param.tLP, from, address(this));
        }
        if( param.tBurn > 0 ){
            _tTotal = _tTotal.sub(param.tBurn);
            _take(param.tBurn, from, address(0));
        }
        if( param.tRF > 0 ){
          _takeInviterFee(from,to,param.tRF);
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(swapsEnabled || _isExcludedFromFee[from] || _isExcludedFromFee[to], "zero");

        if (!swapsEnabled) {
          uint256 balance;
          if (from == swapV2PairAddress) {
            balance = balanceOf(to);
            require(balance.add(amount) < whiteBiggest, "More than to hold");
          }
        }

        bool hasLiquidity = uniswapV2Pair.totalSupply() > 1000;
       
        Param memory param;

        param.tTransferAmount = amount;

        uint256 contractTokenBalance = balanceOf(address(this));
        
        if( 
            contractTokenBalance >= maxTxAmount 
            && !inSwapAndLiquify 
            && !ammPairs[from] 
            && hasLiquidity ){

            inSwapAndLiquify = true;
            contractTokenBalance = maxTxAmount;

            swapAndBurn(contractTokenBalance);

            inSwapAndLiquify = false;
        }

        bool takeFee = true;

        if (from == swapV2PairAddress) {
          takeFee = false;
        }

        if( ammPairs[from] && _isExcludedFromFee[to]  ){
            takeFee = false;
        }

        if( ammPairs[to] && _isExcludedFromFee[from] ){
            takeFee = false;
        }

        if( !ammPairs[from] && !ammPairs[to] && (_isExcludedFromFee[from] || _isExcludedFromFee[to]) ){
            takeFee = false;
        }

        param.takeFee = takeFee;

        if( takeFee){
            _initParam(amount,param);
        }
        
        _tokenTransfer(from,to,amount,param);

        if (fromAddress == address(0)) fromAddress = from;
        if (toAddress == address(0)) toAddress = to;
        if ( !ammPairs[fromAddress] ) setShare(fromAddress);
        if ( !ammPairs[toAddress] ) setShare(toAddress);
        fromAddress = from;
        toAddress = to;

        if (
            LPFeefenhong.add(minPeriod) <= block.timestamp 
            && IERC20(awardToken).balanceOf(address(this)) > maxUsdtAmount
            && hasLiquidity ) {

            process(distributorGas);
            LPFeefenhong = block.timestamp;
        }
    }

    function swapAndBurn(uint256 tokenAmount) private  {
        
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = USDTToken;
        path[2] = awardToken;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount,Param memory param) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        if (sender == swapV2PairAddress) {
            _tOwned[recipient] = _tOwned[recipient].add(tAmount.mul(96).div(100));
            _takeInviterFee(sender, recipient, tAmount.mul(4).div(100));
            emit Transfer(sender, recipient, tAmount.mul(96).div(100));
        } else {
            _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
            emit Transfer(sender, recipient, param.tTransferAmount);
            if(param.takeFee){
                _takeFee(param,sender,recipient);
            }
        }
    }

    function donateDust(address addr, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(addr, _msgSender(), amount);
    }

    function donateEthDust(uint256 amount) external onlyOwner {
        TransferHelper.safeTransferETH(_msgSender(), amount);
    }
    
    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) return;
        uint256 nowBalance = IERC20(awardToken).balanceOf(address(this));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        uint ts = uniswapV2Pair.totalSupply();
        if (uniswapV2Pair.balanceOf(superAddress) > 0) {
            ts = ts.sub(uniswapV2Pair.balanceOf(superAddress));
        }

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            uint256 amount = nowBalance.mul(uniswapV2Pair.balanceOf(shareholders[currentIndex])).div(ts);
            if (amount < 1 * 10 ** 3) {
                currentIndex++;
                iterations++;
                continue;
            }
            IERC20(awardToken).transfer(shareholders[currentIndex], amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function setShare(address shareholder) private {
        if (_updated[shareholder]) {
            if (uniswapV2Pair.balanceOf(shareholder) == 0) quitShare(shareholder);
            return;
        }
        if (uniswapV2Pair.balanceOf(shareholder) == 0) return;
        addShareholder(shareholder);
        _updated[shareholder] = true;

    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function quitShare(address shareholder) private {
        removeShareholder(shareholder);
        _updated[shareholder] = false;
    }

    function setQuitShare(address shareholder)  public onlyOwner {
        removeShareholder(shareholder);
        _updated[shareholder] = false;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        address cur;
        if (sender == swapV2PairAddress) {
            cur = recipient;
        } else {
            cur = sender;
        }
        
        for (int256 i = 0; i < 2; i++) {
            uint256 rate;
            rate = 50;
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = address(0);
                uint256 curTAmount = tAmount.div(100).mul(rate);
                _tTotal = _tTotal.sub(curTAmount);
                emit Transfer(sender, cur, curTAmount);
            } else {
              uint256 curTAmount = tAmount.div(100).mul(rate);
              _tOwned[cur] = _tOwned[cur].add(curTAmount);
              emit Transfer(sender, cur, curTAmount);
            }
        }
    }

    function _tokenOlnyTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {

        require(swapsEnabled || _isExcludedFromFee[sender] || _isExcludedFromFee[recipient], "zero");

        if(_tOwned[recipient] == 0 && inviter[recipient] == address(0)){
          inviter[recipient] = sender;
        }

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }
}