/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

abstract contract OwnAdmin {
    address public _owner;
   
    constructor ()  {
        address msgSender = msg.sender;
        _owner = msgSender;
    }
    function changeOwner(address onwer) public onlyOwner
    {
        _owner = onwer;
    }

    function owner() public view returns (address) {
        return _owner;
    }   

    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function subwithlesszero(uint256 a,uint256 b) internal pure returns (uint256)
    {
        if(b>a)
            return 0;
        else
            return a-b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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


// helper methods for interacting with BEP20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

interface IBEP20 {
 
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
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
    event Mint(address indexed sender, uint amount0, uint amount1);
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
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

 contract JintuToken is IBEP20, OwnAdmin
{
    using SafeMath for uint256;
    using Address for address;

    string private _name = "JinTu";
    string private _symbol = "JinTu";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 20230 * 10**_decimals;
    address public  deadAddress = 0x000000000000000000000000000000000000dEaD;
    address payable public marketingWalletAddress = payable(0xcB9C5F5Fd4bB9Af19Ee519FE06173cE8686A4920); 
    // TEST:0x1a5771B07dd54FbA6dF11E7F4873Da3bfa5ecb79   USDT:0x55d398326f99059fF775485246999027B3197955
    address usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
    //test 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3   0x10ED43C718714eb63d5aA57B78B54704E256024E
    address  public wapV2RouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    TokenDistributor public _tokenDistributorLp;
    TokenDistributor public _tokenDistributorGp;

    mapping (address => bool) public isDividendExempt; //用户排除特殊地址（非用户地址）
    bool public _ispair;
    bool public _isburn;
    bool public _isexit;

    uint256 distributorGas = 500000;
    address private fromAddress;
    address private toAddress;
    address[] public shareholders;
    mapping (address => uint256) public shareholderIndexes;
    mapping(address => bool) private _updated;
    uint256 public currentIndex;
    uint256 public minFenhongVal = 1*10**_decimals;  //最低一杖起分
    uint256 public minFenHongLP =  1* 10**_decimals; //最低持有LP数量
    uint256 public curPerFenhongHolderLP = 0;
    uint256 public lpFnehongNum = 0;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 internal constant magnitude = 2**128;   

    mapping (address => bool) public isBlackExempt; //黑名单
    mapping (address => bool) public isMarketPair; //白名单

    uint256 public _tranferYinxiaoFee = 1; //营销
    uint256 public _tranferPaiFee = 1; //公排
    uint256 public _tranferLpFenhongFee = 1; //Lp滑点
    uint256 public _tranferHolderFenhongFee = 1; //除以10 五个地址
    uint256 public _tranferHolderBurnFee = 0; //销毁

    uint256 public maxbuy = 3*10**_decimals;
    uint256 public _minpai = 1*10**_decimals;
    uint256 nonce;
    uint public transferid;
    mapping (uint => uint) public paiamount;
    mapping (address => uint) public addrtoid;

    //价格时间快照
    uint256 public nowprice;
    uint256 public nowtime;
    constructor()
    {
        nonce = 1;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(wapV2RouterAddress);  
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdtAddress);
        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        _tokenDistributorLp = new TokenDistributor(usdtAddress);
        _tokenDistributorGp = new TokenDistributor(usdtAddress);
        isDividendExempt[address(uniswapPair)] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(deadAddress)] = true;
        isDividendExempt[owner()] = true;

        isMarketPair[owner()] = true;
        isMarketPair[address(this)] = true;
        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);
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
        return _totalSupply;
    }

    function setispair(bool ispair) public onlyOwner
    {
        _ispair=ispair;
    }
    function setisburn(bool isburn) public onlyOwner
    {
        _isburn=isburn;
    }
    function setisexit(bool isexit) public onlyOwner
    {
        _isexit=isexit;
    }
    //设置最低起分. 
    function setFenhongMinNum(uint256 _minFenhongVal)public onlyOwner
    {
        minFenhongVal= _minFenhongVal;
    }
    //设置最低LP数量
    function setMinlpNum(uint256 _minlp) public onlyOwner
    {
        minFenHongLP = _minlp;
    }
    //设置限购金额
    function setmaxbuy(uint256 _max)public onlyOwner
    {
        maxbuy= _max;
    }

    //设置滑点
    function setFee(uint256 _fee, uint8 _number) public onlyOwner
    {
        if(_number == 1) { //营销
            _tranferYinxiaoFee = _fee;
        }else if(_number == 2) { //公排
            _tranferPaiFee = _fee;
        }else if(_number == 3) { //LP滑点
            _tranferLpFenhongFee = _fee;
        }else if(_number == 4) { //空投
            _tranferHolderFenhongFee = _fee;
        }else if(_number == 5) {
            _tranferHolderBurnFee = _fee;
        }
    }

    function getPrice() public view returns(uint){
        uint amount = 1*10**_decimals;
        address[] memory path = new address[](2);
        path[0] = usdtAddress;
        path[1] = address(this);
        uint[] memory result = uniswapV2Router.getAmountsIn(amount,path);
        return result[0];
    }

    //检查价格
    function checkprice() private
    {
        //时间是否超过12小时
        uint256 _checktime = nowtime + 12 * 3600;
        //uint256 _checktime = nowtime + 600;
        uint256 _now = block.timestamp;
        if(_now >= _checktime) {
            nowtime = _now;
            //判断价格
            uint256 newprice = getPrice();
            uint256 _checkprice = nowprice * 80 / 100;
            if(newprice <= _checkprice) { //下跌超过
                _tranferHolderBurnFee = 5;
            }else{
                _tranferHolderBurnFee = 0;
            }
            nowprice = newprice;
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function takeOutErrorTransfer(address tokenaddress, address addr) public onlyOwner
    {
        IBEP20(tokenaddress).transfer(addr, IBEP20(tokenaddress).balanceOf(address(this)));
    }


    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        _transfer(sender, recipient, amount);
        return true;
    }

   function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

   function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public  returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function distributeDividendHolderLp(address shareholder ,uint256 amount) internal {
        lpFnehongNum = lpFnehongNum - amount;   
        _basicTransfer(address(_tokenDistributorLp),shareholder,amount);
    }
    function setDividendExempt(address addr,bool b) external onlyOwner {
        isDividendExempt[addr] = b;
    }
    //白名单
    function setMarketAddress(address addr,bool b) external onlyOwner {
        isMarketPair[addr] = b;
    }
    //黑名单
    function setBlackExempt(address addr,bool b) external onlyOwner {
        isBlackExempt[addr] = b;
    }

    function setDistributorGas(uint256 val) external onlyOwner {
        distributorGas = val;
    }
    function setMinpai(uint256 val) external onlyOwner{
        _minpai = val;
    }

    function setShare(address shareholder) private {
        if(_updated[shareholder] ){      
            if(IUniswapV2Pair(uniswapPair).balanceOf(shareholder) < minFenHongLP) quitShare(shareholder);              
            return;  
        }
        if(IUniswapV2Pair(uniswapPair).balanceOf(shareholder) < minFenHongLP) return;  
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
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(!isBlackExempt[sender],"can not transfer");
        require(!isBlackExempt[recipient],"can not transfer");
        if(!_isexit) {
            if(recipient == uniswapPair && !isMarketPair[sender] && !isDividendExempt[sender]) {
                revert("Can not sell");
            }
            if(sender == uniswapPair && !isMarketPair[recipient] && !isDividendExempt[recipient]) {
                revert("Can not but");
            }
        }

        if(!_isburn && _ispair) {
            checkprice();
        }
        if(!_ispair) {
            if(recipient == uniswapPair) {
                _ispair = true;
            }
            return _basicTransfer(sender, recipient, amount);
        }else{
            fromAddress = sender;
            toAddress = recipient;  
            if(!isDividendExempt[fromAddress])//判断进入分红队伍
            {
                setShare(fromAddress);
            }
            if(!isDividendExempt[toAddress]) {
                setShare(toAddress);
            }

            if(sender != uniswapPair && recipient != uniswapPair) {
                return _basicTransfer(sender, recipient, amount);
            }
            //判断限购
            if(sender == uniswapPair && _balances[recipient] + amount > maxbuy && !isMarketPair[recipient]) {
                revert("Can not buy");
            }
            
            uint realamount = amount; //原金额
            //判断公排
            if(sender == uniswapPair && realamount >= _minpai) { //可以获得公排收益 只有购买时ID增加
                transferid ++;
                addrtoid[recipient] = transferid;
                if(paiamount[transferid] > 0) {
                    _basicTransfer(address(_tokenDistributorGp), recipient, paiamount[transferid]);
                }
            }

            if(recipient == uniswapPair && !isMarketPair[fromAddress]) { //卖出最大金额限制
                uint max = _balances[sender].mul(99).div(100);
                if(amount >= max) {
                    amount = max;
                }
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = (isMarketPair[sender] || isMarketPair[recipient]) ? 
                                         amount : takeFee(sender, recipient, amount, realamount);

            _balances[recipient] = _balances[recipient].add(finalAmount);
            emit Transfer(sender, recipient, finalAmount);


            if(balanceOf(address(_tokenDistributorLp)) >= minFenhongVal && curPerFenhongHolderLP== 0 ) {
                uint256 nowbanance = balanceOf(address(_tokenDistributorLp));//当前拥有
                uint256 totalHolderLp = IUniswapV2Pair(uniswapPair).totalSupply() - IUniswapV2Pair(uniswapPair).balanceOf(owner());
                lpFnehongNum = nowbanance;
                if(totalHolderLp >0)
                {
                    curPerFenhongHolderLP = lpFnehongNum.mul(magnitude).div(totalHolderLp);
                }
            }

            if(curPerFenhongHolderLP != 0)
            {
                process(distributorGas) ;
            }
            return true;
        }
    }

    function takeFee(address sender, address recipient,uint256 amount, uint256 realamount) internal returns (uint256) {
        uint256 feeAmount = 0;
       
        uint256 YinxiaoNum = amount.mul(_tranferYinxiaoFee).div(100); //营销滑点
        _takeFee(sender,address(marketingWalletAddress), YinxiaoNum);
        feeAmount += YinxiaoNum;
        
        uint256 GonpaiNum = amount.mul(_tranferPaiFee).div(100); //公排滑点
        if(realamount >= _minpai) {
            _takeFee(sender,address(_tokenDistributorGp), GonpaiNum);
            feeAmount += GonpaiNum;
            //公排收益分配
            uint hafGonpaiNum = GonpaiNum / 2;
            paiamount[transferid+1] += hafGonpaiNum;
            paiamount[transferid+2] += hafGonpaiNum;
        }else{
            _takeFee(sender,address(marketingWalletAddress), GonpaiNum);
            feeAmount += GonpaiNum;
        }
        uint256 Lpnum = amount.mul(_tranferLpFenhongFee).div(100); //LP滑点
        _takeFee(sender,address(_tokenDistributorLp), Lpnum);
        feeAmount += Lpnum;

        //空投五个钱包
        uint ktsum = amount.mul(_tranferHolderFenhongFee).div(1000);
        for(uint i=1;i <= 5; i++) {
            address ktaddr = createDSalted(nonce + i);
            _takeFee(sender,address(ktaddr), ktsum);
        }
        nonce = nonce + 5;
        feeAmount = feeAmount + ktsum * 5;

        //销毁判断
        if(_tranferHolderBurnFee > 0 && recipient == uniswapPair) {
            uint256 burnnum = amount.mul(_tranferHolderBurnFee).div(100); //LP滑点
            _takeFee(sender,address(deadAddress), burnnum);
            feeAmount += burnnum;
        }
        return amount.sub(feeAmount);
    }

   function _takeFee(address sender, address recipient,uint256 tAmount) private {
        if (tAmount == 0 ) return;
        _balances[recipient] = _balances[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }

    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;
        if(shareholderCount == 0)return;
       
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount ){
                currentIndex = 0;
                curPerFenhongHolderLP = 0;
                lpFnehongNum = 0;
                return;
            }
            uint256 amount   = IUniswapV2Pair(uniswapPair).balanceOf(shareholders[currentIndex]).mul(curPerFenhongHolderLP).div(magnitude);//持有人的数量*每个币可以分红的数量/一个大数 
            if( balanceOf(address(_tokenDistributorLp))  < amount || lpFnehongNum < amount )
            {
                currentIndex = 0;
                curPerFenhongHolderLP = 0;
                lpFnehongNum = 0;
                return;
            }
            distributeDividendHolderLp(shareholders[currentIndex],amount); //分红
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function createDSalted(uint arg) public view returns(address){
        bytes32 salt;
        address predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            salt,
            keccak256(abi.encodePacked(
                type(D).creationCode,
                abi.encode(arg)
            ))
        )))));

        return predictedAddress;
    }
}

contract TokenDistributor  {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}
contract D {
    uint public x;
    constructor(uint a) {
        x = a;
    }
}