/**
 *Submitted for verification at BscScan.com on 2022-10-06
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

contract TokenReceiver{
    constructor (address token, address award) public {
        IERC20(token).approve(msg.sender, 10 ** 18 * 10**18);
        IERC20(award).approve(msg.sender, 10 ** 18 * 10**18);
    }
}

contract DAcoin is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    uint256 private _decimals = 9;
    uint256 private _tTotal = 10000000 * 10 ** _decimals;
    uint256 private burnMaxTotal = 1000000 * 10 ** _decimals;

    string private _name = "DAcoin";
    string private _symbol = "DAcoin";
    
    uint256 public _lPFee = 4;
    uint256 public _burnFee = 4;
    uint256 public _inviterFee = 10;
    uint256 public _sellFee = 1;
    uint256 public totalFee = 18;

    IUniswapV2Router02 public uniswapV2Router;

    mapping(address => bool) public ammPairs;

    bool inSwapAndLiquify;
    
    IERC20 public uniswapV2Pair;
    address public awardToken;

    address public shibBoken = address(0x2859e4544C4bB03966803b044A93563Bd2D0DD4D);
    address public tokenReceiver;

    uint256 public buyAmount;
    uint256 public sellAmount;

    uint256 public mkTxAmount = 1000 * 10 ** _decimals;
    uint256 public lpTxAmount = 1000 * 10 ** _decimals;
    uint256 public maxTxAmount = 1000 * 10 ** _decimals;

    uint256 public sellThisAmount = 300 * 10 ** _decimals;
    uint256 public sellUSDT = 300 * 10 ** _decimals;
    uint256 public buyThisUsdt = 1 * 10 ** 18;

    uint256 public shibMinAmount = 1000 * 10 ** _decimals;

    uint256 currentIndex;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 10 minutes;
    uint256 public LPFeefenhong;
     mapping(address => bool) private _updated;

    address private fromAddress;
    address private toAddress;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;

    mapping(address => address) public inviter;

    bool public swapsEnabled = true;

    address public fundAddress;

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
         
        address swapV2PairAddress = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), awardToken);

        uniswapV2Pair = IERC20(swapV2PairAddress);
        ammPairs[swapV2PairAddress] = true;

        tokenReceiver = address(new TokenReceiver(address(shibBoken), address(awardToken)));
        _owner = msg.sender;
        fundAddress = msg.sender;

        LPFeefenhong = block.timestamp;

        emit Transfer(address(0), msg.sender, _tTotal);
    }

    modifier onlyFunder() {
      require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
      _;
    }

    function setAmmPair(address pair,bool hasPair)external onlyFunder{
        ammPairs[pair] = hasPair;
    }

    function setTxAmount(uint256 _mk,uint256 _lp,uint256 _tx)external onlyFunder{
        mkTxAmount = _mk * 10 ** _decimals;
        lpTxAmount = _lp * 10 ** _decimals;
        maxTxAmount = _tx * 10 ** _decimals;
    }

    function setSellThisAmount(uint256 _amount)external onlyFunder{
        sellThisAmount = _amount * 10 ** _decimals;
    }

    function setSellUSDT(uint256 _amount)external onlyFunder{
        sellUSDT = _amount * 10 ** _decimals;
    }

    function setBuyThisUsdt(uint256 _amount)external onlyOwner{
        buyThisUsdt = _amount * 10 ** 18;
    }

    function setSwapsEnabled(bool _enabled) public onlyOwner {
        swapsEnabled = _enabled;
    }

    function setMinPeriod(uint256 _mp)external onlyOwner{
        minPeriod = _mp;
    }

    function setShibMinAmount(uint256 _sb)external onlyFunder{
        shibMinAmount = _sb;
    }

    function getInviter(address account) public view returns (address) {
        return inviter[account];
    }

    function setInviter(address user, address parent) public onlyOwner {
        inviter[user] = parent;
    }

    function setOutsideInviter(address parent) public {
        require(parent != address(uniswapV2Pair), 'The superior cannot be the pool');
        require(inviter[msg.sender] == address(0), 'Bound to a higher layer');
        require(msg.sender != parent, 'no');
        inviter[msg.sender] = parent;
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
       if(msg.sender == address(uniswapV2Pair)){
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
        if(recipient == address(uniswapV2Pair)){
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
        uint sLP;
        uint tBurn;
        uint tInviterFee;
    }

    function _initParam(uint256 tAmount,Param memory param) private view  {
        param.tLP = tAmount * _lPFee / 100;
        param.tInviterFee = tAmount * _inviterFee / 100;
        uint tFee = 0;
        if (_tTotal <= burnMaxTotal) {
            tFee = tAmount * (totalFee - 4) / 100;
        } else {
            param.tBurn = tAmount * _burnFee / 100;
            tFee = tAmount * totalFee / 100;
        }
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _sellParam(uint256 tAmount,Param memory param) private view  {
        param.sLP = tAmount * _sellFee / 100;
        param.tTransferAmount = tAmount.sub(param.sLP);
    }

    function _takeFee(Param memory param,address from)private {
        if( param.tLP > 0 ){
            _take(param.tLP, from, address(this));
            sellAmount += param.tLP;
        }
        if( param.sLP > 0 ){
            _take(param.sLP, from, address(this));
            buyAmount += param.sLP;
        }
        if( param.tBurn > 0 ){
            _tTotal = _tTotal.sub(param.tBurn);
            _take(param.tBurn, from, address(0));
        }
    }

    function _takeInviterFee( address sender, address recipient, uint256 tAmount) private {
        if (_inviterFee == 0) return;
        address cur;
        if (sender == address(uniswapV2Pair)) {
          cur = recipient;
        } else {
          cur = sender;
        }
        
        for (int256 i = 0; i < 7; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 3;
            } else if (i == 1) {
                rate = 2;
            } else {
                rate = 1;
            }
            cur = inviter[cur];
            uint256 curTAmount = tAmount.div(100).mul(rate);
            _tOwned[cur] = _tOwned[cur].add(curTAmount);
            if (cur == address(0)) {
                emit Transfer(sender, address(0), curTAmount);
            } else {
                emit Transfer(sender, cur, curTAmount);
            }
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
            uint v = buyAmount;
            if( v >= lpTxAmount && v <= balanceOf(address(this))){
                buyAmount = 0;
                swapAndAward(sellThisAmount);
                swapAndUSDT(sellUSDT);
            }  
            
            uint b = sellAmount;
            if( b >= mkTxAmount && b <= balanceOf(address(this))){
                sellAmount = 0;
                IERC20(awardToken).transfer(address(uniswapV2Pair), buyThisUsdt);
            }

            inSwapAndLiquify = false;
        }

        bool takeFee = true;

        if( ammPairs[from] && _isExcludedFromFee[to] ){
            takeFee = false;
        }

        if( ammPairs[to]  && _isExcludedFromFee[from]){
            takeFee = false;
        }

        if( !ammPairs[from] && !ammPairs[to] && (_isExcludedFromFee[from] || _isExcludedFromFee[to]) ){
            takeFee = false;
        }

        param.takeFee = takeFee;

        if( takeFee ){
            if (from == address(uniswapV2Pair)) {
                _sellParam(amount,param);
            } else {
                _initParam(amount,param);
            }
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
            && IERC20(address(this)).balanceOf(address(this)) > shibMinAmount
            && hasLiquidity ) {

            process(distributorGas);
            LPFeefenhong = block.timestamp;
        }

    }

    function swapAndAward(uint256 tokenAmount) private  {
        
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = awardToken;
        path[2] = shibBoken;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            tokenReceiver,
            block.timestamp
        );

        uint bal = IERC20(shibBoken).balanceOf(tokenReceiver);
        if( bal > 0 ){
            IERC20(shibBoken).transferFrom(tokenReceiver,address(this),bal);
        }
    }

    function swapAndUSDT(uint256 tokenAmount) private  {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = awardToken;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            tokenReceiver,
            block.timestamp
        );

        uint bal = IERC20(awardToken).balanceOf(tokenReceiver);
        if( bal > 0 ){
            IERC20(awardToken).transferFrom(tokenReceiver,address(this),bal);
        }
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount,Param memory param) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
        emit Transfer(sender, recipient, param.tTransferAmount);
        if(param.takeFee){
            if (sender == address(uniswapV2Pair)) {
                _takeFee(param,sender);
            } else {
                _takeFee(param,sender);
                _takeInviterFee(sender, recipient, tAmount);
            }
        }
    }

    function _tokenOlnyTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {

        require(swapsEnabled || _isExcludedFromFee[sender] || _isExcludedFromFee[recipient], "zero");

        // 扣除发送人的
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        
        if (_isExcludedFromFee[recipient] || _isExcludedFromFee[sender]) {
            _tOwned[recipient] = _tOwned[recipient].add(tAmount);
            emit Transfer(sender, recipient, tAmount);
        }else{
            _tTotal = _tTotal.sub(tAmount.div(100).mul(4));
            _tOwned[recipient] = _tOwned[recipient].add(tAmount.div(100).mul(96));
            emit Transfer(sender, address(0), tAmount.div(100).mul(4));
            emit Transfer(sender, recipient, tAmount.div(100).mul(96));
        }
    }

    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) return;
        uint256 nowBalance = IERC20(shibBoken).balanceOf(address(this));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;


        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            uint256 amount = nowBalance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(uniswapV2Pair.totalSupply());
            if (amount < 1 * 10 ** 3) {
                currentIndex++;
                iterations++;
                continue;
            }
            IERC20(shibBoken).transfer(shareholders[currentIndex], amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function setShare(address shareholder) private {
        if (_updated[shareholder]) {
            if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);
            return;
        }
        if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;
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

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function donateDust(address addr, uint256 amount) external onlyFunder {
        TransferHelper.safeTransfer(addr, _msgSender(), amount);
    }

    function donateEthDust(uint256 amount) external onlyFunder {
        TransferHelper.safeTransferETH(_msgSender(), amount);
    }
    
}