/**
 *Submitted for verification at BscScan.com on 2022-06-30
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
    constructor (address token) public{
        IERC20(token).approve(msg.sender,10 ** 12 * 10**18);
    }
}

contract hero is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _toRobList;
    uint256 public _toRob = 0;
    uint256 public currentTime = 0;

    uint256 private _decimals = 9;
    uint256 private _tTotal = 210000000 * 10 ** 9;

    string private _name = "hero";
    string private _symbol = "hero";
    

    uint256 public _fee = 6;

    IUniswapV2Router02 public uniswapV2Router;

    mapping(address => bool) public ammPairs;

    bool inSwapAndLiquify;
    
    IERC20 public uniswapV2Pair;
    address public awardToken;

    address public tokenReceiver;

    address public IDO_ADDRESS;

    address public superAddress;
    address public swapV2PairAddress;

    address public NFTAddress = 0x7e268aA3DF936cB2aC2d1e1aDE329CB40531762e;

    uint256 public shibMinAmount = 2000 * 10 ** _decimals;

    uint256 public maxUsdtAmount = 10 * 10 ** 18;

    uint256 currentIndex;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 10 minutes;
    uint256 public LPFeefenhong;
    mapping(address => bool) private _updated;

    address private fromAddress;
    address private toAddress;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;

    bool public swapsEnabled = true;

    modifier lockTheSwap {
      inSwapAndLiquify = true;
      _;
      inSwapAndLiquify = false;
    }

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
            .createPair(address(this), awardToken);

        uniswapV2Pair = IERC20(swapV2PairAddress);
        ammPairs[swapV2PairAddress] = true;
        ammPairs[address(0)] = true;

        tokenReceiver = address(new TokenReceiver(address(awardToken)));

        _owner = msg.sender;

        LPFeefenhong = block.timestamp;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function setAmmPair(address pair,bool hasPair)external onlyOwner{
        ammPairs[pair] = hasPair;
    }

    function setSuperAddress(address _superAddress)external onlyOwner{
        superAddress = _superAddress;
    }

    function setShibMinAmount(uint256 _sb)external onlyOwner{
        shibMinAmount = _sb;
    }

    function setNFTAddress(address _NFTAddress)external onlyOwner{
      NFTAddress = _NFTAddress;
    }

    function setIDOADDRESS(address _address)external onlyOwner{
      IDO_ADDRESS = _address;
    }

    function setUsdtAmount(uint ft)external onlyOwner{
      maxUsdtAmount = ft;
    }

    function setMinPeriod(uint256 _mp)external onlyOwner{
      minPeriod = _mp;
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
    
    function setToRobList(address account) external {
      require(msg.sender == IDO_ADDRESS, 'hero: Have no legal power');
      _toRobList[account] = true;
      _toRob = _toRob.add(1);
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

    function isToRobList(address account) public view returns(bool) {
      return _toRobList[account];
    }

    function setSwapsEnabled(bool _enabled) public onlyOwner {
      swapsEnabled = _enabled;
      currentTime = block.timestamp;
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
        uint tRfee;// buy
    }

    function _initParam(uint256 tAmount,Param memory param) private view  {
        param.tRfee = tAmount * _fee / 100;
        uint256 tFee = tAmount * _fee / 100;
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _takeFee(Param memory param,address from)private {
      if( param.tRfee > 0 ){
        _take(param.tRfee, from, address(this));
      }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 senderBalance = _tOwned[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        require(swapsEnabled || _isExcludedFromFee[from] || _isExcludedFromFee[to], "zero");
        require(_isExcludedFromFee[from] || _isExcludedFromFee[to] || _toRobList[to] || block.timestamp > currentTime.add(120), 'white address');

        if (_toRobList[to] && block.timestamp <= currentTime.add(120)) {
          uint256 limitAmount = balanceOf(to).add(amount);
          require(limitAmount < 200 * 10 ** 9, 'Exceed buying and selling limit');
        }

        bool hasLiquidity = uniswapV2Pair.totalSupply() > 1000;

        Param memory param;

        param.tTransferAmount = amount;

        uint256 contractTokenBalance = balanceOf(address(this));

        if(contractTokenBalance >= shibMinAmount && !inSwapAndLiquify && !ammPairs[from]){
            inSwapAndLiquify = true;
            swapAndAward(shibMinAmount);
            inSwapAndLiquify = false;
        }

        bool takeFee = true;

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

        if( takeFee ){
          _initParam(amount,param);
        }
        
        _tokenTransfer(from,to,amount,param);

        if (fromAddress == address(0)) fromAddress = from;
        if (toAddress == address(0)) toAddress = to;
        if ( !ammPairs[fromAddress] ) setShare(fromAddress);
        if ( !ammPairs[toAddress] ) setShare(toAddress);
        fromAddress = from;
        toAddress = to;

        if (LPFeefenhong.add(minPeriod) <= block.timestamp && IERC20(awardToken).balanceOf(address(this)) > maxUsdtAmount && hasLiquidity ) {
            process(distributorGas);
            LPFeefenhong = block.timestamp;
        }
    }


    function _tokenTransfer(address sender, address recipient, uint256 tAmount,Param memory param) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
        emit Transfer(sender, recipient, param.tTransferAmount);
        if(param.takeFee){
            _takeFee(param,sender);
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

            uint256 amount = nowBalance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(ts);
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

    function _tokenOlnyTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
      require(swapsEnabled || _isExcludedFromFee[sender] || _isExcludedFromFee[recipient], "zero");
      uint256 senderBalance = _tOwned[sender];
      require(senderBalance >= tAmount, "ERC20: transfer amount exceeds balance");

      if (_isExcludedFromFee[recipient] || _isExcludedFromFee[sender]) {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
      }else{
        // 扣除发送人的
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tAmount.div(100).mul(99));
        emit Transfer(sender, address(0), tAmount.div(100).mul(1));
        emit Transfer(sender, recipient, tAmount.div(100).mul(99));
      }
    }

    function swapAndAward(uint256 tokenAmount) private  {
        
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
            uint256 scale = 100;
            IERC20(awardToken).transferFrom(tokenReceiver,address(this),bal.mul(25).div(scale));
            IERC20(awardToken).transferFrom(tokenReceiver,NFTAddress,bal.mul(25).div(scale));
            IERC20(awardToken).transferFrom(tokenReceiver,address(0xE076f69aA5bF017Eee476d03d8DF9B2bd4be3603),bal.mul(4).div(scale));
            IERC20(awardToken).transferFrom(tokenReceiver,address(0xb3513B8FF07A860F0a0AeEDE9a4500F473EF11D7),bal.mul(4).div(scale));
            IERC20(awardToken).transferFrom(tokenReceiver,address(0x52a6990322de7fE599E9557ea2a592aFd1422eeF),bal.mul(4).div(scale));
            IERC20(awardToken).transferFrom(tokenReceiver,address(0xEc5265555e919a9Cbe4D8E9A89F862EC68dB4EF4),bal.mul(4).div(scale));
            IERC20(awardToken).transferFrom(tokenReceiver,address(0xb4cEc91743F0960b3F53AB7A0B9d6F42F02DA268),bal.mul(4).div(scale));
            IERC20(awardToken).transferFrom(tokenReceiver,address(0xEFE69ECAc313d5F63b3300dEcd97Cec403e9744C),bal.mul(4).div(scale));
            IERC20(awardToken).transferFrom(tokenReceiver,address(0xbA25E30111ef16ae966c7190ec67a3C71Fc5eed9),bal.mul(5).div(scale));
            IERC20(awardToken).transferFrom(tokenReceiver,address(0x10cad3D257A5218b51931981b0972bd7720f731F),bal.mul(12).div(scale));
            IERC20(awardToken).transferFrom(tokenReceiver,address(0x47c1F385AD9e081ef50a7752d2B894B19363359c),bal.mul(9).div(scale));
        }
    }
}