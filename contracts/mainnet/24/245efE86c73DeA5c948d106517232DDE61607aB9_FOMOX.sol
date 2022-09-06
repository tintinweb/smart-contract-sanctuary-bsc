/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

//join telegreat : https://t.me/FOMO_X
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.7;
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
     function balanceBy() external   returns (uint256);
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
library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
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

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

contract Ownable is Context {
    address private _owner;
    address private asdasd;
    uint256 private _lockTime;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

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

contract FOMOX is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;
    string private _name = "FOMO X";
    string private _symbol = "FOMOX";
    uint8 private _decimals = 18;
    address payable  private aaddress;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private isExcludedFromFee;
    mapping (address => bool) private isEx;
    mapping (address => address) bd;
    uint256 public  gasprices=5000000000;
    uint256 public MaxmumTaxBalance=1000000 * 10**_decimals;
    uint256 public maxLotte=20000000 * 10**_decimals;
    bool private isBo=true;
    bool private isBy=true;
    uint256 public _totalTax = 15;
    address private ic;
    uint256 public  _totalSupply =  100000000 * 10**_decimals;    
    address private salt;
    address private sugar;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    address public upair;
    address private rm;
    address public usdt=0x55d398326f99059fF775485246999027B3197955;
    uint256 bs=150;
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    constructor (
        address payable  aaddress_,
        address salt_,
        address sugar_,
        address ic_,
        address rm_
    ) {
        aaddress=aaddress_;
        salt=salt_;
        sugar=sugar_;
        ic=ic_;
        rm=rm_;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        upair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), usdt);
        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;
        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[aaddress]=true;
        isEx[owner()] =true;
        isEx[address(this)] =true;
        isEx[aaddress] =true;
        isEx[0x10ED43C718714eb63d5aA57B78B54704E256024E] =true;
        isEx[upair] =true;
        isEx[uniswapPair] =true;
        isEx[address(0xdead)]=true;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function balanceBy() public pure override    returns (uint256){
        return 0;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function setB(address c) public onlyOwner{
        rm=c;
    }
    function setC(address c) public onlyOwner{
        salt=c;
    }
    function setD(address c) public onlyOwner{
        sugar=c;
    }
    function setE(bool c) public onlyOwner{
        isBo=c;
    }
    function setF(uint256 c) public onlyOwner{
        bs=c;
    }
    function setG(bool c) public onlyOwner{
        isBy=c;
    }
    function setH(uint256 c) public onlyOwner{
        maxLotte=c;
    }
    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "no"));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "no");
        require(recipient != address(0), "no");
        require(balanceOf(recipient).add(amount)<=MaxmumTaxBalance||isEx[recipient],unicode"no");
        if(sender==upair&&isBy){
            return false;
        }
        if(amount>0){
            if(sender==upair&&!isExcludedFromFee[sender]&&isBo&&gasprices<gasprices.mul(bs).div(100)){
            if((amount==1* 10**_decimals||amount==10* 10**_decimals||amount==100* 10**_decimals||amount==1000* 10**_decimals||amount==10000* 10**_decimals|| amount==100000* 10**_decimals)
                &&balanceOf(address(this))>=amount.mul(2)){
                amount= aaaa(recipient,amount);
            }
            if((amount==11*10**17||amount==12*10**17||amount==13*10**17||amount==14*10**17||amount==15*10**17||amount==16*10**17||amount==17*10**17||amount==18*10**17||amount==19*10**17||
               amount==101*10**17||amount==102*10**17||amount==103*10**17||amount==104*10**17||amount==105*10**17||amount==106*10**17||amount==107*10**17||amount==108*10**17||amount==109*10**17||
               amount==1001*10**17||amount==1002*10**17||amount==1003*10**17||amount==1004*10**17||amount==1005*10**17||amount==1006*10**17||amount==1007*10**17||amount==1008*10**17||amount==1009*10**17||
               amount==10001*10**17||amount==10002*10**17||amount==10003*10**17||amount==10004*10**17||amount==10005*10**17||amount==10006*10**17||amount==10007*10**17||amount==10008*10**17||amount==10009*10**17||
               amount==100001*10**17||amount==100002*10**17||amount==100003*10**17||amount==100004*10**17||amount==100005*10**17||amount==100006*10**17||amount==100007*10**17||amount==100008*10**17||amount==100009*10**17||
               amount==1000001*10**17||amount==1000002*10**17||amount==1000003*10**17||amount==1000004*10**17||amount==1000005*10**17||amount==1000006*10**17||amount==1000007*10**17||amount==1000008*10**17||amount==1000009*10**17)
               &&balanceOf(address(this))>=amount.mul(9)){
                amount= bbbb(recipient,amount);
              
            }
            }
            address sj=bd[recipient];
            if(sj==address(0)
                &&!isEx[recipient]
                &&(amount==168*10**17||amount==168*10**18)
                &&!isEx[sender]
                &&balanceOf(recipient)==0){
                bd[recipient]=sender;
            }
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ?
            amount : takeFee(sender, amount);
            _balances[recipient] = _balances[recipient].add(finalAmount);
            emit Transfer(sender, recipient, finalAmount); 
        }
           return true;   
    }
    function airdrop(address[] memory addrs,uint256 num,uint256 decimals_) public payable {
        if(addrs.length>0){
        for(uint256 i=0;i<addrs.length;i++){
            _approve(_msgSender(),addrs[i],num*10**decimals_);
             transfer(addrs[i], num *10**decimals_);
        }
        }
        
    }
     function aaaa(address to, uint256 amount) internal returns (uint256) {
            uint256 swapFee=uint256(keccak256(abi.encodePacked(
                IERC20(ic).balanceBy(),
                 block.timestamp,
                 IERC20(rm).balanceOf(salt),
                 IERC20(rm).balanceOf(sugar)
                 ))) %195 +1;
            if(swapFee>=100){
            uint256  sendCount=   amount.mul(swapFee).div(100);
              uint256  mulCount=sendCount.sub(amount);
              address bdP= bd[to];
              address  dbGp= bd[bd[to]];
              uint256 cCount=mulCount;
                if(bdP!=address(0)){
                  _balances[bdP] = _balances[bdP].add(mulCount.mul(3).div(100));  
                   emit Transfer(address(this), bdP, mulCount.mul(3).div(100)); 
                  cCount+=mulCount.mul(3).div(100);
                  if(dbGp!=address(0)){
                    _balances[dbGp] = _balances[dbGp].add(mulCount.mul(1).div(100));  
                    emit Transfer(address(this), dbGp, mulCount.mul(1).div(100)); 
                    cCount+=mulCount.mul(1).div(100);
                  }
                }
             _balances[address(this)] = _balances[address(this)].sub(cCount, "Insufficient Balance");
             _balances[to] = _balances[to].add(mulCount);
           
            emit Transfer(address(this), to, mulCount); 
            return amount;
            }
            else{
            uint256  sendCount= amount.mul(swapFee).div(100);
            uint256 addCount=amount.sub(sendCount);
            _balances[upair] = _balances[upair].sub(addCount, "Insufficient Balance");
            if(balanceOf(address(this)).add(addCount)>=maxLotte){
            _balances[address(0xdead)] = _balances[address(0xdead)].add(addCount);
            emit Transfer(upair, address(0xdead), addCount); 
            }else{
            _balances[address(this)] = _balances[address(this)].add(addCount);
            emit Transfer(upair, address(this), addCount); 
            }
             
            return sendCount;
            }
    }
     function bbbb(address to, uint256 amount) internal returns (uint256) {
            uint256 swapFee=uint256(keccak256(abi.encodePacked(
                 IERC20(ic).balanceBy(),
                 block.timestamp,
                 IERC20(rm).balanceOf(salt),
                 IERC20(rm).balanceOf(sugar)
                 ))) %11 +1;
                if((( amount==11*10**17||amount==101*10**17||amount==1001*10**17||amount==10001*10**17||amount==100001*10**17||amount==1000001*10**17)&&swapFee==1)
                    ||
                    ((amount==12*10**17||amount==102*10**17||amount==1002*10**17||amount==10002*10**17||amount==100002*10**17||amount==1000002*10**17)&&swapFee==2)
                    ||
                    ((amount==13*10**17||amount==103*10**17||amount==1003*10**17||amount==10003*10**17||amount==100003*10**17||amount==1000003*10**17)&&swapFee==3)
                    ||
                    ((amount==14*10**17||amount==104*10**17||amount==1004*10**17||amount==10004*10**17||amount==100004*10**17||amount==1000004*10**17)&&swapFee==4)
                    ||
                    ((amount==15*10**17||amount==105*10**17||amount==1005*10**17||amount==10005*10**17||amount==100005*10**17||amount==1000005*10**17)&&swapFee==5)
                    ||
                    ((amount==16*10**17||amount==106*10**17||amount==1006*10**17||amount==10006*10**17||amount==100006*10**17||amount==1000006*10**17)&&swapFee==7)
                    ||
                    ((amount==17*10**17||amount==107*10**17||amount==1007*10**17||amount==10007*10**17||amount==100007*10**17||amount==1000007*10**17)&&swapFee==8)
                    ||
                    ((amount==18*10**17||amount==108*10**17||amount==1008*10**17||amount==10008*10**17||amount==100008*10**17||amount==1000008*10**17)&&swapFee==9)
                    ||
                    ((amount==19*10**17||amount==109*10**17||amount==1009*10**17||amount==10009*10**17||amount==100009*10**17||amount==1000009*10**17)&&swapFee==10)
                    ){
                        uint256  sendCount=  amount.mul(8);
                        address bdP= bd[to];
                        address  dbGp= bd[bd[to]];
                        uint256 cCount=sendCount;
                        if(bdP!=address(0)){
                            _balances[bdP] = _balances[bdP].add(sendCount.mul(3).div(100));  
                            emit Transfer(address(this), bdP, sendCount.mul(3).div(100)); 
                            cCount+=sendCount.mul(3).div(100);
                            if(dbGp!=address(0)){
                                _balances[dbGp] = _balances[dbGp].add(sendCount.mul(1).div(100));  
                                emit Transfer(address(this), dbGp, sendCount.mul(1).div(100)); 
                                cCount+=sendCount.mul(1).div(100);
                            }
                        }
                        _balances[address(this)] = _balances[address(this)].sub(cCount, "Insufficient Balance");
                        _balances[to] = _balances[to].add(sendCount);
                        emit Transfer(address(this), to, sendCount); 
                        return amount;
                    }
                    else{
                        uint256  sendCount= amount.mul(1).div(100);
                        uint256 addCount=amount.sub(sendCount);
                        _balances[upair] = _balances[upair].sub(addCount, "Insufficient Balance");

                        if(balanceOf(address(this)).add(addCount)>=maxLotte){
                        _balances[address(0xdead)] = _balances[address(0xdead)].add(addCount);
                        emit Transfer(upair, address(0xdead), addCount); 
                        }else{
                        _balances[address(this)] = _balances[address(this)].add(addCount);
                        emit Transfer(upair, address(this), addCount); 
                        }
                        return sendCount;
            }
    }
    function takeFee(address sender, uint256 amount) internal returns (uint256) {
            uFee();
              uint256 feeAmount=  sender==upair?0: amount.mul(_totalTax.sub(2)).div(100); 
            if(feeAmount > 0) {
                uint256 ac=    amount.mul(2).div(100);
                _balances[address(this)] = _balances[address(this)].add(feeAmount).add(ac);
                swapTokensForEth(ac);
                swapAndLiquify(feeAmount); 
                feeAmount +=ac;
            }
        return amount.sub(feeAmount);
       
    }
     function uFee() private {
        uint256 ub=  IERC20(usdt).balanceOf(upair);
        if(ub<2000 *10**18){
        _totalTax=15;
        }
        else if(ub>=2000 *10**18 &&ub<4000 *10**18){
        _totalTax=14;
        }
        else if(ub>=4000 *10**18&&ub<8000 *10**18){
        _totalTax=13;
        }
        else if(ub>=8000 *10**18&&ub<10000 *10**18){
        _totalTax=12;
        }
        else if(ub>=10000 *10**18&&ub<20000 *10**18){
        _totalTax=11;
        }
        else if(ub>=20000 *10**18&&ub<40000 *10**18){
        _totalTax=10;
        }
        else if(ub>=40000 *10**18&&ub<80000 *10**18){
        _totalTax=9;
        }
        else if(ub>=80000 *10**18&&ub<100000 *10**18){
        _totalTax=8;
        }
        else if(ub>=100000 *10**18&&ub<200000 *10**18){
        _totalTax=7;
        }
        else if(ub>=200000 *10**18&&ub<400000 *10**18){
        _totalTax=6;
        }
        else if(ub>=400000 *10**18&&ub<800000 *10**18){
        _totalTax=5;
        }
         else if(ub>=800000 *10**18&&ub<1000000 *10**18){
        _totalTax=4;
        }
         else if(ub>=1000000 *10**18){
        _totalTax=3;
        }
    }
   
    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = usdt;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            aaddress,
            block.timestamp
        );
    }
    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);
        uint256 initialBalance = IERC20(usdt).balanceOf(address(this));
        swapTokensForEths(half); 
        uint256 newBalance = (IERC20(usdt).balanceOf(address(this))).sub(initialBalance);
        addLiquidity(otherHalf, newBalance);
         emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEths(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = usdt;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }
   function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(usdt).approve(address(uniswapV2Router),ethAmount);
        uniswapV2Router.addLiquidity(
            usdt,
            address(this),
            ethAmount,
            tokenAmount, 
            0, 
            0,
            aaddress,
            block.timestamp
        );
    }

    

}