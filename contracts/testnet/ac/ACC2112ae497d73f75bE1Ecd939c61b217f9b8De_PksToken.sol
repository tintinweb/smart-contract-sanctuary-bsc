// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
    constructor (address token) {
        IERC20(token).approve(msg.sender,uint256(-1));
    }
}

contract PksToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => Param) public lockedLPTokens;

    mapping (address => bool) public _isExcludedFromFee;

    uint8 private _decimals = 18;
    uint256 private _tTotal = 500000000000 * 10**18;

    string private _name = "PKS";
    string private _symbol = "PKS";

    uint256 public _shareFee = 10;
    uint256 public _burnFee = 10;
    uint256 public _buyLqFee = 10;
    uint256 public _sellLqFee = 50;

    address public tokenReceiver;

    IUniswapV2Router02 public immutable uniswapV2Router;
    // address public  uniswapV2Pair;

    IERC20 private uniswapV2Pair;

    mapping(address => bool) public ammPairs;

    uint public lqAmount;
    uint256 public _lqTxAmount = 1000000 * 10**18;
   
    bool inSwapAndLiquify;
        
    address  holder;
    address  usdt;

    mapping (address => address) public _recommerMapping;
    uint constant public shareCondition = 1 * 10 ** 15;
    address constant public rootAddress = address(0x000000000000000000000000000000000000dEaD);

    // uint public lockEndTime;

    constructor (
        address _route,
        address _usdt,
        address _holder) {
        
        // lockEndTime = block.timestamp + 4 * 30 * 86400;
        holder = _holder;

        _recommerMapping[rootAddress] = address(0xdeaddead);
        _recommerMapping[holder] = rootAddress;

         usdt = _usdt;

        _tOwned[holder] = _tTotal;
        
         IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_route);
         uniswapV2Router = _uniswapV2Router;
         
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdt);
        
        uniswapV2Pair = IERC20(_uniswapV2Pair);

        ammPairs[address(uniswapV2Pair)] = true;

        _isExcludedFromFee[_holder] = true;
        _isExcludedFromFee[address(this)] = true;

        _owner = msg.sender;
        tokenReceiver = address(new TokenReceiver(usdt));
        emit Transfer(address(0), _holder, _tTotal);
    }

    function setlockEndTime(uint _lockEndTime) public onlyOwner{
        Param storage param = lockedLPTokens[msg.sender];
        param.unlockTime = _lockEndTime;
    }

    function setAmmPair(address pair,bool hasPair)external onlyOwner{
        ammPairs[pair] = hasPair;
    }

    function setMaxTx(uint256 lqTx) external onlyOwner{
        _lqTxAmount = lqTx;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
        _transfer(sender, recipient, amount);
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
        address user;
        bool takeFee;
        bool isSwapBuy;
        uint tTransferAmount;
        uint tLq;
        uint tUsdt;
        uint tBurn;
        uint tShare;
        uint256 unlockTime;
    }

    function _isLiquidity(address from,address to)internal view returns(bool isAdd,bool isDel){

        address token0 = IUniswapV2Pair(address(uniswapV2Pair)).token0();
        (uint r0,,) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));
        if( ammPairs[to] ){
            if( token0 != address(this) && bal0 > r0 ){
                isAdd = bal0 - r0 >= 1e18;
            }
        }

        if( ammPairs[from] ){
            if( token0 != address(this) && bal0 < r0 ){
                isDel = r0 - bal0 > 0;
            }
        }
    }


    function addRelationEx(address recommer,address user) internal {
        if( 
            recommer != user 
            && _recommerMapping[user] == address(0x0) 
            && _recommerMapping[recommer] != address(0x0) ){
                _recommerMapping[user] = recommer;
        }       
    }

    function _initParam(uint256 tAmount,Param memory param) private view  {
         uint tFee = 0;
        if( param.takeFee ){
            
            param.tBurn = tAmount * _burnFee / 1000;
            param.tShare = tAmount * _shareFee / 1000;

            if( param.isSwapBuy){
                param.tLq = tAmount * _buyLqFee / 1000;
            }else{
                param.tLq = tAmount * _sellLqFee / 1000; 
            }
            tFee = param.tLq  + param.tBurn + param.tShare;
        }
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _takeFee(Param memory param,address from)private {
         
        if( param.tLq > 0 ){
            _take(param.tLq, from, address(this));
            lqAmount += param.tLq;
        }
        if( param.tBurn > 0 ){
            _take(param.tBurn, from, address(0));
        }
        if( param.tShare > 0 ){
            address parent = _recommerMapping[param.user];
            _take(param.tShare,from,parent);
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        Param memory param = lockedLPTokens[msg.sender]; 
         
        if( 
            !_isContract(to) 
            && _recommerMapping[to] == address(0) 
            && amount >= shareCondition ){
            
            if( ammPairs[from]  ){
                addRelationEx(holder,to);
            }else{
                addRelationEx(from,to);
            }
        }

        bool isAddLiquidity;
        bool isDelLiquidity;
        ( isAddLiquidity, isDelLiquidity) = _isLiquidity(from,to);

        if( 
            from != address(this)
            && !inSwapAndLiquify 
            && !isAddLiquidity
            && !ammPairs[from] 
            &&  ammPairs[to]
            && IERC20(uniswapV2Pair).totalSupply() > 10000 ){
            
            inSwapAndLiquify = true;

            if( lqAmount >= _lqTxAmount && lqAmount <= balanceOf(address(this))){
                uint v = _lqTxAmount;
                lqAmount = lqAmount.sub(v);
                // swapAndLiquify(v);
                addLpProvider(msg.sender);
                processLP(500000);
                param.unlockTime = block.timestamp + 4 * 30 * 86400;
            }
            inSwapAndLiquify = false;
        }

        if( isDelLiquidity && block.timestamp < param.unlockTime){
            require(false,"lock not end");
        }

        if( ammPairs[from] && !_isExcludedFromFee[to] && !isDelLiquidity){
            param.takeFee = true;
            param.isSwapBuy = true;
            param.user = to;
        }

        if( ammPairs[to] && !_isExcludedFromFee[from] && !isAddLiquidity){
            param.takeFee = true;
            param.user = from;
        }

        _initParam(amount,param);
        _tokenTransfer(from,to,amount,param);
        
    }

    function swapAndLiquify(uint256 v) private  {    
        uint256 half = v.div(2);
        uint256 otherHalf = v.sub(half);

        uint256 initialBalance = IERC20(usdt).balanceOf(tokenReceiver);

        swapTokensForEth(half); 

        uint256 newBalance = IERC20(usdt).balanceOf(tokenReceiver).sub(initialBalance);

        addLiquidity(otherHalf, newBalance);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            tokenReceiver,
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        IERC20(usdt).transferFrom(tokenReceiver,address(this),ethAmount);

        IERC20(usdt).approve(address(uniswapV2Router), ethAmount);

        uniswapV2Router.addLiquidity(
            address(this),
            usdt,
            tokenAmount,
            ethAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
        
    }

    //��LP �ֺ�
    address[] private lpProviders;
    // ��¼LP��ֵ
    mapping(address => uint256) lpProviderIndex;

    uint256 private currentIndex;
    uint256 private lpRewardCondition = 10;
    uint256 private progressLPBlock;

    //����LP�����б����������׾ͼ���
    function addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }
    
    function processLP(uint256 gas) private {
        //��� 10 ���ӷֺ�һ��
        if (progressLPBlock + 200 > block.number) {
            return;
        }
        //���׶�û�����
        uint totalPair = uniswapV2Pair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(this));
        //�ֺ�С�ڷ���������һ��̫��Ҳ�Ͳ�����
        if (usdtBalance < lpRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;

        //һ�����Ͻ���ʣ��� gasLimit�������� Solidity gasleft() �˽�
        uint256 gasLeft = gasleft();

        //���ֻ���б���������һ�Σ�iterations < shareholderCount
        while (gasUsed < gas && iterations < shareholderCount) {
            //�±���б����ȴ󣬴�ͷ��ʼ
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = lpProviders[currentIndex];
            //���е� LP ������LP ����Ҳ��һ�ִ���
            pairBalance = uniswapV2Pair.balanceOf(shareHolder);
            //�����ų��б����ŷֺ�
            if (pairBalance > 0 ) {
                amount = usdtBalance * pairBalance / totalPair;
                //�ֺ����0���з��䣬��С����
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
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

     function _isContract(address a) internal view returns(bool){
        uint256 size;
        assembly {size := extcodesize(a)}
        return size > 0;
     }

}