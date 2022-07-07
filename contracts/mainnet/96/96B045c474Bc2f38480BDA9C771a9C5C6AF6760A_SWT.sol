/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.6;


interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(  address indexed owner,address indexed spender, uint256 value);

}

abstract contract Ownable {

    address private _owner;

    address private _previousOwner; 

    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {

        address msgSender = msg.sender;

        _owner = msgSender;

        emit OwnershipTransferred(address(0), msgSender);

    }    
    
    function owner() public view returns (address) {

        return _owner;

    }       
    
    modifier onlyOwner() {

        require(_owner == msg.sender, "Ownable: caller is not the owner");

        _;

    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

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

}

interface IUniswapV2Factory {

    event PairCreated(address indexed token0,address indexed token1, address pair,uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}

interface IUniswapV2Pair {

    event Approval( address indexed owner,address indexed spender,uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to,uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(address owner,address spender,uint256 value, uint256 deadline,uint8 v, bytes32 r,bytes32 s) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);

    event Burn( address indexed sender,uint256 amount0,uint256 amount1,address indexed to );

    event Swap(address indexed sender, uint256 amount0In,uint256 amount1In,uint256 amount0Out,uint256 amount1Out,address indexed to);

    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0,uint112 reserve1,uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(uint256 amount0Out,uint256 amount1Out,address to,bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;

}


interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity( address tokenA,address tokenB,uint256 amountADesired,uint256 amountBDesired,uint256 amountAMin, 
    uint256 amountBMin, address to,uint256 deadline) external returns (uint256 amountA,uint256 amountB,uint256 liquidity);

    function addLiquidityETH(

        address token,

        uint256 amountTokenDesired,

        uint256 amountTokenMin,

        uint256 amountETHMin,

        address to,

        uint256 deadline

    )  external payable

    returns (


        uint256 amountToken,

        uint256 amountETH,

        uint256 liquidity

        );

    function removeLiquidity(

        address tokenA,

        address tokenB,

        uint256 liquidity,

        uint256 amountAMin,

        uint256 amountBMin,

        address to,

        uint256 deadline

    ) external returns (uint256 amountA, uint256 amountB);



    function removeLiquidityETH(

        address token,

        uint256 liquidity,

        uint256 amountTokenMin,

        uint256 amountETHMin,

        address to,

        uint256 deadline

    ) external returns (uint256 amountToken, uint256 amountETH);



    function removeLiquidityWithPermit(

        address tokenA,

        address tokenB,

        uint256 liquidity,

        uint256 amountAMin,

        uint256 amountBMin,

        address to,

        uint256 deadline,

        bool approveMax,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) external returns (uint256 amountA, uint256 amountB);



    function removeLiquidityETHWithPermit(

        address token,

        uint256 liquidity,

        uint256 amountTokenMin,

        uint256 amountETHMin,

        address to,

        uint256 deadline,

        bool approveMax,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) external returns (uint256 amountToken, uint256 amountETH);



    function swapExactTokensForTokens(

        uint256 amountIn,

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external returns (uint256[] memory amounts);



    function swapTokensForExactTokens(

        uint256 amountOut,

        uint256 amountInMax,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external returns (uint256[] memory amounts);



    function swapExactETHForTokens(

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external payable returns (uint256[] memory amounts);



    function swapTokensForExactETH(

        uint256 amountOut,

        uint256 amountInMax,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external returns (uint256[] memory amounts);



    function swapExactTokensForETH(

        uint256 amountIn,

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external returns (uint256[] memory amounts);



    function swapETHForExactTokens(

        uint256 amountOut,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external payable returns (uint256[] memory amounts);



    function quote(

        uint256 amountA,

        uint256 reserveA,

        uint256 reserveB

    ) external pure returns (uint256 amountB);



    function getAmountOut(

        uint256 amountIn,

        uint256 reserveIn,

        uint256 reserveOut

    ) external pure returns (uint256 amountOut);



    function getAmountIn(

        uint256 amountOut,

        uint256 reserveIn,

        uint256 reserveOut

    ) external pure returns (uint256 amountIn);



    function getAmountsOut(uint256 amountIn, address[] calldata path)

        external

        view

        returns (uint256[] memory amounts);



    function getAmountsIn(uint256 amountOut, address[] calldata path)

        external

        view

        returns (uint256[] memory amounts);

} 



interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(

        address token,

        uint256 liquidity,

        uint256 amountTokenMin,

        uint256 amountETHMin,

        address to,

        uint256 deadline

    ) external returns (uint256 amountETH);



    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(

        address token,

        uint256 liquidity,

        uint256 amountTokenMin,

        uint256 amountETHMin,

        address to,

        uint256 deadline,

        bool approveMax,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) external returns (uint256 amountETH);



    function swapExactTokensForTokensSupportingFeeOnTransferTokens(

        uint256 amountIn,

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external;



    function swapExactETHForTokensSupportingFeeOnTransferTokens(

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external payable;



    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint256 amountIn,

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external;

}

contract SWT is IERC20, Ownable {

    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _updated;    uint256 private _tFeeTotal;

    string private _name = "Sun tea";

    string private _symbol = "SWTTEA";

    uint8 private _decimals = 18;

    uint256 public _burnFee = 0;

    uint256 public _inviterFee = 0;

    uint256 currentIndex;  

    uint256 private _tTotal = 50000000 * 10**18;

    IUniswapV2Router02 public immutable uniswapV2Router;

    address public immutable uniswapV2Pair;

    mapping(address => address) public inviter;

    mapping(address => bool) public storeAddresss; 


    constructor() {

        _tOwned[msg.sender] = _tTotal;

        // Pancake-币安主链-合约地址：0x10ED43C718714eb63d5aA57B78B54704E256024E
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()) .createPair(address(this), _uniswapV2Router.WETH());        
           
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[msg.sender] = true;

        _isExcludedFromFee[address(this)] = true;

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

    // 设置/取消门店特殊地址(可以设置/取消多个)
    function setStoreAddress (address[] calldata storeAddress, bool isStore) public onlyOwner {

        for(uint256 i = 0; i < storeAddress.length; i++){

            storeAddresss[storeAddress[i]] = isStore;

        }
    }

    function transfer(address recipient, uint256 amount)

        public

        override

        returns (bool)

    {

        _transfer(msg.sender, recipient, amount);

        return true;

    }



    function allowance(address owner, address spender)

        public

        view

        override

        returns (uint256)

    {

        return _allowances[owner][spender];

    }



    function approve(address spender, uint256 amount)

        public

        override

        returns (bool)

    {

        _approve(msg.sender, spender, amount);

        return true;

    }



    function transferFrom(

        address sender,

        address recipient,

        uint256 amount

    ) public override returns (bool) {

        _transfer(sender, recipient, amount);

        _approve(

            sender,

            msg.sender,

            _allowances[sender][msg.sender].sub(

                amount,

                "ERC20: transfer amount exceeds allowance"

            )

        );

        return true;

    }



    function increaseAllowance(address spender, uint256 addedValue)

        public

        virtual

        returns (bool)

    {

        _approve(

            msg.sender,

            spender,

            _allowances[msg.sender][spender].add(addedValue)

        );

        return true;

    }



    function decreaseAllowance(address spender, uint256 subtractedValue)

        public

        virtual

        returns (bool)

    {

        _approve(

            msg.sender,

            spender,

            _allowances[msg.sender][spender].sub(

                subtractedValue,

                "ERC20: decreased allowance below zero"

            )

        );

        return true;

    }



    function totalFees() public view returns (uint256) {

        return _tFeeTotal;

    }



   function isExcludedFromFee(address account) public view returns (bool) {

        return _isExcludedFromFee[account];

    }

    function excludeFromFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = true;

    }


    function includeInFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = false;

    }    
    
    receive() external payable {}    
    
    
    function _updateFee(uint256 burnFee, uint256 inviterFee) private {

        _burnFee = burnFee;

        _inviterFee = inviterFee;

    }    
    
    
    function _approve(

        address owner,

        address spender,

        uint256 amount

    ) private {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }


    function _transfer(

        address from,

        address to,

        uint256 amount

    ) private {

        require(from != address(0), "ERC20: transfer from the zero address");

        require(to != address(0), "ERC20: transfer to the zero address");

        require(amount > 0, "Transfer amount must be greater than zero");

        

        uint8 takeFee = 0;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || from == address(uniswapV2Router) ) {

            takeFee = 1;
        }
        
        
        if (from != address(uniswapV2Pair) && to != address(uniswapV2Pair)) {

            takeFee = 1;
        } 

        // 门店特殊地址
        if(storeAddresss[from]){

            takeFee = 2;

        }

        _tokenTransfer(from, to, amount, takeFee);        
        
        
        bool shouldSetInviter =  to != address(0) && (inviter[to] == address(0) || inviter[from] == address(0));
        
        // 门店地址不参与互绑
        bool isStore = storeAddresss[from] || storeAddresss[to];

        if (shouldSetInviter && !isStore) {

			SendData memory sendData = waitInviter[from][to];

			bool doubleCheck = false;

			if (sendData.fromAddress == to){

				if (sendData.status && inviter[from] == address(0)){

					_setInvite(from, to);

				}

				doubleCheck = true;

			}

			

			if (!doubleCheck && inviter[to] == address(0)){

				SendData memory mySend = SendData(from, true);

				waitInviter[to][from] = mySend;

			}

        }
    }  
    
    struct SendData {

		address fromAddress;

		bool status;

    }    
    
    mapping(address => mapping(address => SendData)) public waitInviter;
    
    function _setInvite(address to, address from) private {

		if (inviter[from] != to){

			inviter[to] = from;

		}

	}

    //this method is responsible for taking all fee, if takeFee is true

    function _tokenTransfer(

        address sender,

        address recipient,

        uint256 amount,

        uint8 takeFee

    ) private {

        if(takeFee == 0){

             _updateFee(200, 0);       
             
         } 
         else if(takeFee == 1){

            _updateFee(0, 0);     
        }
         else if(takeFee == 2){

            _updateFee(0, 2000);

        }

        _transferStandard(sender, recipient, amount);

    }

    // 销毁  交易所
    function _takeburnFee(

        address sender,

        uint256 tAmount

    ) private {

        if (_burnFee == 0) return;

        if(_tFeeTotal >= 40000000 * 10**18) _burnFee = 0;

        _tOwned[address(0)] = _tOwned[address(0)].add(tAmount);

        _tFeeTotal = _tFeeTotal.add(tAmount);

        emit Transfer(sender, address(0), tAmount);

    }  

    // 上级分配  门店
    function _takeInviterFee(

        address sender,

        address recipient,

        uint256 tAmount

    ) private {

        if (_inviterFee == 0) return;

        address cur;

        if(storeAddresss[sender]){

            cur = recipient;

        } 

        uint256 accurRate;

        for (int256 i = 0; i < 2; i++) {

            uint256 rate;

            if (i == 0) {

                rate = 1500;

            }  else {

                rate = 500;

            }

            cur = inviter[cur];

            if (cur == address(0)) {

                break;

            }

            accurRate = accurRate.add(rate);    

            uint256 curTAmount = tAmount.div(10000).mul(rate);

            _tOwned[cur] = _tOwned[cur].add(curTAmount);

            emit Transfer(sender, cur, curTAmount);

        }

        // 分配之后剩下的，进到黑洞地址
        _tOwned[address(0)] = _tOwned[address(0)].add(tAmount.div(10000).mul(_inviterFee.sub(accurRate)));

        emit Transfer(sender, address(0), tAmount.div(10000).mul(_inviterFee.sub(accurRate)));

    }    
    
    function _transferStandard(

        address sender,

        address recipient,

        uint256 tAmount

    ) private {

        _tOwned[sender] = _tOwned[sender].sub(tAmount);

        _takeburnFee(sender, tAmount.div(10000).mul(_burnFee));

        _takeInviterFee(sender, recipient, tAmount);

        uint256 recipientRate = 10000 - _burnFee - _inviterFee;

        _tOwned[recipient] = _tOwned[recipient].add( tAmount.div(10000).mul(recipientRate) );

        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));

    }

}