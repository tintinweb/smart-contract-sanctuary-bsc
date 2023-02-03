// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

interface IOmniZap {
  function Fees (  ) external view returns ( uint256 );
  function ListingFee (  ) external view returns ( uint256 );
  function ListingToken (  ) external view returns ( address );
  function isTokenListed ( address _token ) external view returns ( bool );
  function MaxFees (  ) external view returns ( uint256 );
  function WNAT (  ) external view returns ( address );
  function bestRouter ( address[] memory _from, uint256[] memory _amounts, address[] memory _to, address[] memory _routers ) external view returns ( uint256[] memory amountsOut, address[] memory bestRouters );
  function getPath ( address _from, address _to ) external view returns ( address[] memory path_ );
  function isLP ( address _address ) external view returns ( bool );
  function multiSwapTokens ( address[] memory _from, uint256[] memory _amountsIn, address[] memory _to, address[] memory _routers ) external;
  function owner (  ) external view returns ( address );
  function removeToken ( uint256 i ) external;
  function routePair ( address _address ) external view returns ( address );
  function safeSwapBNB (  ) external view returns ( address );
  function setBlacklist ( address token, bool _state ) external;
  function setFees ( uint256 _fees ) external;
  function setListingFee ( uint256 _amount ) external;
  function setListingToken ( address _token ) external;
  function setNotLP ( address token ) external;
  function setNotLPOwner ( address token ) external;
  function setRoutePairAddress ( address asset, address route ) external;
  function setRouters ( address[] memory _routers ) external;
  function slippageCalc ( uint256 _amountIn, address _tFrom, address _tTo, uint256 _slippage ) external view returns ( uint256 amountOut_, uint256 amountOutMin_, address bestRouter_ );
  function sweep (  ) external;
  function routePairAddresses ( address ) external view returns ( address );
  function tokens ( uint256 ) external view returns ( address );
  function tokensList (  ) external view returns ( address[] memory );
  function transferOwnership ( address _newOwner ) external;
  function withdraw (  ) external;
  function zapIn ( address _to, address _router ) payable external;
  function zapInToken ( address _from, uint256 amount, address _to, address _router ) external;
  function zapOut ( address _from, uint256 amount, address _router ) external;
  function zapOutTo ( address _lp, uint256 _amount, address _to, address _routerFrom, address _routerTo ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

interface IPancakePair {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

interface IPancakeRouter01 {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

import './IPancakeRouter01.sol';

interface IPancakeRouter02 is IPancakeRouter01 {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

interface ISafeSwapBNB {
    function withdraw(uint amount) external;
    function deposit() external payable;
}

// https://uniswap.org/docs/v2/smart-contracts/factory/
// https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2Factory.solimplementation
// SPDX-License-Identifier: MIT
// UniswapV2Factory is deployed at 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f on the Ethereum mainnet, and the Ropsten, Rinkeby, Görli, and Kovan testnets
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
  function allPairsLength() external view returns (uint);

  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);

  function createPair(address tokenA, address tokenB) external returns (address pair);
}

// https://uniswap.org/docs/v2/smart-contracts/pair/
// https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2Pair.sol implementation
// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

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
  
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;
pragma experimental ABIEncoderV2;
/*
*
* MIT License
* ===========
*
* Copyright Mizu (c) 2022
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import "./utils/SafeMath.sol";
import "./utils/SafeBEP20.sol";
import "./utils/Ownable.sol";
import "./interfaces/IPancakePair.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/ISafeSwapBNB.sol";
import "./utils/ZapHelper.sol";
import "./interfaces/IOmniZap.sol";

contract OmniZap is Ownable {
    using SafeMath for uint;
    using SafeBEP20 for IBEP20;

    IBEP20 public WNAT; // WRAPPED NATIVE FOR DEPLOYED CHAIN
    address public safeSwapBNB;
    uint public Fees; // protocol fees where 10000=100%
    uint immutable public MaxFees = 25; // maximum protocol fees 

    address[] public routers; //store the V2 routers on the chain

    constructor ( 
        address _WNAT
    ) {
        require( _WNAT != address(0) );
        WNAT = IBEP20(_WNAT);
        safeSwapBNB = address(WNAT);
        IBEP20(WNAT).approve(address(WNAT), uint(-1));
        Fees = 5; // set the fees at 0.05%
    }

    function setSafeWnat() external onlyOwner{

    }

    /* ========== EVENTS ========== */

    event ZapETH(address _to, address _router);
    event ZapToken(address _from, uint amount, address _to, address _router);
    event ZapOut(address _from, uint amount, address _router);
    event TokenAdded(address token);
    event TokenRemoved(address token);
    event SetRoute(address asset, address route);

    /* ========== STATE VARIABLES ========== */

    mapping(address => bool) private notLP;
    mapping(address => address) public routePairAddresses;
    mapping (address => bool) Blacklist;
    address[] public tokens;
    uint256 public ListingFee;
    address public ListingToken;

    receive() external payable {}

    /* ========== View Functions ========== */

    function isLP(address _address) public view returns (bool) {
        return !notLP[_address];
    }

    function isTokenListed(address _token) external view returns(bool){
        bool isListed;
        for (uint i = 0; i < tokens.length; i++) {
            if (_token != tokens[i]){
                isListed = false;
                continue;
            }
            else {
            isListed = true;
            break;
            }
        }
        return isListed;
    }

    function routePair(address _address) external view returns(address) {
        return routePairAddresses[_address];
    }

    function tokensList() external view returns(address[] memory){
            return tokens;
        }
    
    /* ========== External Functions ========== */

    function zapInToken(address _from, uint amount, address _to, address _router, uint _slippage) external {
        IBEP20(_from).safeTransferFrom(msg.sender, address(this), amount);
        amount -= amount.mul(Fees).div(10000); // remove fees from amount


        if (isLP(_to)) {
            _approveTokenIfNeeded(_from, _router);
            IPancakePair pair = IPancakePair(_to);
            address token0 = pair.token0();
            address token1 = pair.token1();
            if (_from == token0 || _from == token1) {
                // swap half amount for other
                address other = _from == token0 ? token1 : token0;
                //_approveTokenIfNeeded(other, _router);
                uint sellAmount = amount.div(2);
                uint otherAmount = _swap(_from, sellAmount, other, address(this), _slippage);
                pair.skim(address(this));
                IPancakeRouter02(_router).addLiquidity(_from, other, amount.sub(sellAmount), otherAmount, 0, 0, msg.sender, block.timestamp);
            } else {
                uint bnbAmount = _from == address(WNAT) ? _safeSwapToBNB(amount) : _swapTokenForBNB(_from, amount, address(this), _slippage);
                _swapBNBToLP(_to, bnbAmount, msg.sender, _router, _slippage);
            }
        } else {
            _swap(_from, amount, _to, msg.sender, _slippage);
        }
        emit ZapToken(_from, amount, _to, _router);
    }

    function zapIn(address _to, address _router, uint _slippage) external payable {
        uint amount = msg.value - (msg.value.mul(Fees).div(10000)); //remove fees from msg.value
        _swapBNBToLP(_to, amount, msg.sender, _router, _slippage);
        emit ZapETH(_to, _router);
    }

    function zapOut(address _from, uint amount, address _router, uint _slippage) external {
        amount -= amount.mul(Fees).div(10000); //remove fees from amount
        IBEP20(_from).safeTransferFrom(msg.sender, address(this), amount);


        if (!isLP(_from)) {
            _swapTokenForBNB(_from, amount, msg.sender, _slippage);
        } else {
            _approveTokenIfNeeded(_from, _router);
            IPancakePair pair = IPancakePair(_from);
            address token0 = pair.token0();
            address token1 = pair.token1();

            if (pair.balanceOf(_from) > 0) {
                pair.burn(address(this));
            }

            if (token0 == address(WNAT) || token1 == address(WNAT)) {
                IPancakeRouter02(_router).removeLiquidityETH(token0 != address(WNAT) ? token0 : token1, amount, 0, 0, msg.sender, block.timestamp);
            } else {
                IPancakeRouter02(_router).removeLiquidity(token0, token1, amount, 0, 0, msg.sender, block.timestamp);
            }
        }
        emit ZapOut(_from, amount, _router);
    }

    /* ========== Private Functions ========== */

    function _approveTokenIfNeeded(address token, address _router) private {
        if (IBEP20(token).allowance(address(this), address(_router)) == 0) {
            IBEP20(token).safeApprove(address(_router), uint(- 1));
        }
    }

    function _swapBNBToLP(address flip, uint amount, address receiver, address _router, uint _slippage) private {
        if (!isLP(flip)) {
            _swapBNBForToken(flip, amount, receiver, _slippage);
        } else {
            address token0 = IPancakePair(flip).token0();
            address token1 = IPancakePair(flip).token1();
            if (token0 == address(WNAT) || token1 == address(WNAT)) {
                address token = token0 == address(WNAT) ? token1 : token0;
                uint swapValue = amount.div(2);
                uint tokenAmount = _swapBNBForToken(token, swapValue, address(this), _slippage);

                _approveTokenIfNeeded(token, _router);
                IPancakePair(flip).skim(address(this));
                IPancakeRouter02(_router).addLiquidityETH{value : amount.sub(swapValue)}(token, tokenAmount, 0, 0, receiver, block.timestamp);
            } else {
                uint swapValue = amount.div(2);
                uint token0Amount = _swapBNBForToken(token0, swapValue, address(this), _slippage);
                uint token1Amount = _swapBNBForToken(token1, amount.sub(swapValue), address(this), _slippage);

                _approveTokenIfNeeded(token0, _router);
                _approveTokenIfNeeded(token1, _router);
                IPancakePair(flip).skim(address(this));
                IPancakeRouter02(_router).addLiquidity(token0, token1, token0Amount, token1Amount, 0, 0, receiver, block.timestamp);
            }
        }
    }

    function _swapBNBForToken(address token, uint value, address receiver, uint _slippage) private returns (uint) {     
        (, uint amountOutMin, address _router, _path[] memory paths) = slippageCalc(value, address(WNAT), token, _slippage);
        address[] memory path = paths[0].path;
        uint[] memory amounts = IPancakeRouter02(_router).swapExactETHForTokens{value : value}(amountOutMin, path, receiver, block.timestamp);
        return amounts[amounts.length - 1];
    }

    function _swapTokenForBNB(address token, uint amount, address receiver, uint _slippage) private returns (uint) {
        (, uint amountOutMin, address _router, _path[] memory paths) = slippageCalc(amount, token, address(WNAT), _slippage);
        address[] memory path = paths[0].path;
        _approveTokenIfNeeded(token, _router);

        uint[] memory amounts = IPancakeRouter02(_router).swapExactTokensForETH(amount, amountOutMin, path, receiver, block.timestamp);
        return amounts[amounts.length - 1];
    }

    function _swap(address _from, uint amount, address _to, address receiver, uint _slippage) private returns (uint) {
        (, uint amountOutMin, address _router, _path[] memory paths) = slippageCalc(amount, _from, _to, _slippage);
        address[] memory path = paths[0].path;
        _approveTokenIfNeeded(_from, _router);
        uint[] memory amounts = IPancakeRouter02(_router).swapExactTokensForTokens(amount, amountOutMin, path, receiver, block.timestamp);
        return amounts[amounts.length - 1];
    }

    function _safeSwapToBNB(uint amount) private returns (uint) {
        require(IBEP20(WNAT).balanceOf(address(this)) >= amount, "Zap: Not enough WNAT balance");
        require(safeSwapBNB != address(0), "Zap: safeSwapBNB is not set");
        uint beforeBNB = address(this).balance;
        ISafeSwapBNB(safeSwapBNB).withdraw(amount);
        return (address(this).balance).sub(beforeBNB);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setFees(uint _fees) external onlyOwner{
        require(_fees <= MaxFees, "Fee too high");
        Fees = _fees;
    }

    function setRouters(address[] calldata _routers) external onlyOwner{
        routers = _routers;
    }

    //setRoutePair
    function setRoutePairAddress(address asset, address route) external onlyOwner {
        routePairAddresses[asset] = route;
        emit SetRoute(asset, route);
    }

    //set new token
    function setNotLPOwner(address token) external onlyOwner {
        bool needPush = notLP[token] == false;
        notLP[token] = true;
        if (needPush) {
            tokens.push(token);
        }
        emit TokenAdded(token);
    }

    function setBlacklist(address token, bool _state) external onlyOwner{
            Blacklist[token] = _state;
        }

    function payListing() internal {
        if (ListingFee > 0){
            require (IBEP20(ListingToken).balanceOf(msg.sender) >= ListingFee);
            IBEP20(ListingToken).transferFrom(msg.sender, address(this), ListingFee);
        }
    }

    function setNotLP(address token) external {
        require (ZapHelper.isToken(token), "Token = LP");
        require (!Blacklist[token], "Blacklisted");
        payListing();
        bool needPush = notLP[token] == false;
        notLP[token] = true;
        if (needPush) {tokens.push(token);}
        emit TokenAdded(token);
    }

    function setListingFee(uint256 _amount) external onlyOwner {
        ListingFee = _amount;        
    }

    function setListingToken(address _token) external onlyOwner {
        ListingToken = _token;
    }
  

    //remove old token
    function removeToken(uint i) external onlyOwner {
        address token = tokens[i];
        notLP[token] = false;
        tokens[i] = tokens[tokens.length - 1];
        tokens.pop();
        emit TokenRemoved(tokens[i]);
    }

    function sweep() external onlyOwner {
        for (uint i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            if (token == address(0)) continue;
            uint amount = IBEP20(token).balanceOf(address(this));
            if (amount > 0) {
                IBEP20(token).transfer(msg.sender, amount);
            }
        }
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function zapOutFor(address _from, uint amount, address _router, uint _slippage) internal returns(uint amt1, uint amt2){
        IBEP20(_from).safeTransferFrom(msg.sender, address(this), amount);
        _approveTokenIfNeeded(_from, _router);

        if (!isLP(_from)) {
            _swapTokenForBNB(_from, amount, msg.sender, _slippage);
        } else {
            IPancakePair pair = IPancakePair(_from);
            address token0 = pair.token0();
            address token1 = pair.token1();

            if (pair.balanceOf(_from) > 0) {
                (amt1, amt2) = pair.burn(address(this));
            }

            if (token0 == address(WNAT) || token1 == address(WNAT)) {
                (amt1, amt2) = IPancakeRouter02(_router).removeLiquidityETH(token0 != address(WNAT) ? token0 : token1, amount, 0, 0, address(this), block.timestamp);
            } else {
                (amt1, amt2) = IPancakeRouter02(_router).removeLiquidity(token0, token1, amount, 0, 0, address(this), block.timestamp);
            }
        }
        emit ZapOut(_from, amount, _router);
        return (amt1, amt2);
    }

    function swapLpToNative(address _lp, uint _amount, address _router, uint _slippage) internal returns (uint){
        (uint amt1, uint amt2) = zapOutFor(_lp, _amount, _router, _slippage); //ZAPOUT THE LP
        IPancakePair pair = IPancakePair(_lp);
        address token0 = pair.token0(); // GET TOKEN 0 ADDR
        address token1 = pair.token1(); // GET TOKEN 1 ADDR
        uint natSum;
            //SWAP ALL TO WNAT
            if (token0 == address(WNAT))
            {   
                uint amtSwap = _swap(token1, amt1, address(WNAT), address(this), _slippage);
                _safeSwapToBNB(amtSwap);
                natSum = (amtSwap + amt2);
            }
            if (token1 == address(WNAT))
            {   

                uint amtSwap = _swap(token0, amt1, address(WNAT), address(this), _slippage);
                _safeSwapToBNB(amtSwap);
                natSum = (amtSwap + amt2);
            }
            else {
                uint amtSwap = _swap(token0, amt1, address(WNAT), address(this), _slippage);
                amtSwap += _swap(token1, amt2, address(WNAT), address(this), _slippage);
                _safeSwapToBNB(amtSwap);
                natSum = amtSwap;
            }
        return natSum;
    }

    function zapOutTo(address _lp, uint _amount, address _to, address _routerFrom, address _routerTo, uint _slippage) external { //added fees after conversion to NATIVE
        uint balanceBefore = address(this).balance;
        swapLpToNative(_lp, _amount, _routerFrom, _slippage);
        uint payOut = ((address(this).balance).sub(balanceBefore));
        uint payoutZapIn = payOut;
        payOut -= payOut.mul(Fees).div(10000);
        require(address(this).balance >= balanceBefore);

            if(_to == address(0) && _routerTo == address(0)){
                payable(msg.sender).transfer(payOut);
            }
            else{
                if(isLP(_to)){
                    IOmniZap(address(this)).zapIn{value: payoutZapIn}(_to, _routerTo);
                }
                if(!isLP(_to)){
                    _swapBNBForToken(_to, payOut, msg.sender, _slippage);
                }
            }
    }

    function multiSwapTokens(address[] memory _from, uint[] memory _amountsIn, address[] memory _to, address[] memory _receivers, uint[] memory _slippage) external { //todo slippage[]
        //pass address(0) as _to to swap to native
        
        //check that all arrays are same length
        require(_from.length == _amountsIn.length && _amountsIn.length == _to.length && _to.length == _receivers.length); 

        /* TODO SHOULD BE USELESS BECAUSE IT GETS CALCULATED FROM _slippageCalc
        //get the array of best routers in the same order as the inputs
        address[] memory best;
        best = new address[](_from.length);

        (, address[] memory bestRouters,) = bestRouter(_from, _amountsIn, _to, _routers);

        //populate best[] array
        for (uint256 b = 0; b < bestRouters.length; b++) {
            best[b] = bestRouters[b];
        }
        */

        //execute the swaps
        for (uint256 i = 0; i < _from.length; i++) {
            if (IBEP20(_from[i]).balanceOf(msg.sender) >= _amountsIn[i]){

                SafeBEP20.safeTransferFrom(IBEP20(_from[i]), msg.sender, address(this), _amountsIn[i]);
                _amountsIn[i] -= _amountsIn[i].mul(Fees).div(10000); //remove fees from _amountsIn[i]
                // _approveTokenIfNeeded(_from[i], best[i]); //TODO PUT IN ALL SWAPS
                if(_to[i] == address(0)){
                    _swapTokenForBNB(_from[i], _amountsIn[i], _receivers[i],  _slippage[i]);
                }
                else _swap(_from[i], _amountsIn[i], _to[i], _receivers[i],   _slippage[i]);
            }
            else continue;
        }
    }

    function getPath(address _from, address _to) public view returns (address[] memory path_) { //todo use it in bestRouter
        address intermediate = routePairAddresses[_from];
        if (intermediate == address(0)) {
            intermediate = routePairAddresses[_to];
        }

        address[] memory path;
        if (intermediate != address(0) && (_from == address(WNAT) || _to == address(WNAT))) {

            path = new address[](3);
            path[0] = _from;
            path[1] = intermediate;
            path[2] = _to;
        } else if (intermediate != address(0) && (_from == intermediate || _to == intermediate)) {

            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else if (intermediate != address(0) && routePairAddresses[_from] == routePairAddresses[_to]) {

            path = new address[](3);
            path[0] = _from;
            path[1] = intermediate;
            path[2] = _to;
        } else if (routePairAddresses[_from] != address(0) && routePairAddresses[_to] != address(0) && routePairAddresses[_from] != routePairAddresses[_to]) {

            path = new address[](5);
            path[0] = _from;
            path[1] = routePairAddresses[_from];
            path[2] = address(WNAT);
            path[3] = routePairAddresses[_to];
            path[4] = _to;
        } else if (intermediate != address(0) && routePairAddresses[_from] != address(0)) {

            path = new address[](4);
            path[0] = _from;
            path[1] = intermediate;
            path[2] = address(WNAT);
            path[3] = _to;
        } else if (intermediate != address(0) && routePairAddresses[_to] != address(0)) {

            path = new address[](4);
            path[0] = _from;
            path[1] = address(WNAT);
            path[2] = intermediate;
            path[3] = _to;
        } else if (_from == address(WNAT) || _to == address(WNAT)) {

            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {

            path = new address[](3);
            path[0] = _from;
            path[1] = address(WNAT);
            path[2] = _to;
        }
        
        return path;
    }

    struct _path{
        address[] path;
        }

    function bestRouter(address[] memory _from, uint[] memory _amounts, address[] memory _to, address[] memory _routers) public view
    returns(uint[] memory amountsOut, address[] memory bestRouters, _path[] memory paths){
        require(_from.length == _amounts.length && _amounts.length == _to.length);

        amountsOut = new uint[](_from.length); //create array slots based on the lenght of input arrays
        bestRouters = new address[](_from.length); //create array slots based on the lenght of input arrays
        paths = new _path[](_from.length); //create array slots for the struct _path[]
        
        //loop for factories and paths
        for (uint256 i = 0; i < _routers.length; i++) { // loop through all the routers in the array

                //loop to get amountsOut
                for (uint256 ii = 0; ii < _from.length; ii++){
                    
                    if (_to[ii] == address(0)){ //set address(0) as WNAT because of swapTokensToBNB input in multiSwapTokens
                        _to[ii] = address(WNAT);
                    }
                    if (_from[ii] == address(0)){
                        _from[ii] = address(WNAT);
                    }

                    address _fT = _from[ii];
                    address _tT = _to[ii];
                    address[] memory path;
                    path = getPath(_fT , _tT);
                    paths[ii].path = path;

                    if (path[path.length-1] == address(0)){

                    }
                    else{
                    uint[] memory _amountOut = IPancakeRouter01(_routers[i]).getAmountsOut(_amounts[ii], path);
                    uint amountOut = _amountOut[_amountOut.length-1];

                        if (amountOut > amountsOut[ii]){
                                amountsOut[ii] = amountOut; // set amountOut in the array if its bigger than before
                                bestRouters[ii] = _routers[i];
                        }
                    }
                }
            }        
        
        return(amountsOut, bestRouters, paths);
    }

    function slippageCalc(uint _amountIn, address _tFrom, address _tTo, uint _slippage) public view returns(uint amountOut_, uint amountOutMin_, address bestRouter_, _path[] memory paths){
        require (_slippage <= 100000);
        uint[] memory _amounts;
        _amounts = new uint[](1);
        _amounts[0] = _amountIn;
        address[] memory _from;
        _from = new address[](1);
        _from[0] = _tFrom;
        address[] memory _to;
        _to = new address[](1);
        _to[0] = _tTo;
        (uint[] memory amountOut, address[] memory best, _path[] memory bestPath) = bestRouter(_from, _amounts, _to, routers);
        bestRouter_ = best[0];
        require (bestRouter_ != address(0));
        amountOut_ = amountOut[0];
        amountOutMin_ = amountOut[0].sub(FullMath.mulDiv(amountOut[0], _slippage, 100000));
        paths = bestPath;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

import "./FullMath.sol";

library Babylonian {

    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;

        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
}

library BitMath {

    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0, 'BitMath::mostSignificantBit: zero');

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }
}


library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint256 _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint256 private constant Q112 = 0x10000000000000000000000000000;
    uint256 private constant Q224 = 0x100000000000000000000000000000000000000000000000000000000;
    uint256 private constant LOWER_MASK = 0xffffffffffffffffffffffffffff; // decimal of UQ*x112 (lower 112 bits)

    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    function decode112with18(uq112x112 memory self) internal pure returns (uint) {

        return uint(self._x) / 5192296858534827;
    }

    function fraction(uint256 numerator, uint256 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, 'FixedPoint::fraction: division by zero');
        if (numerator == 0) return FixedPoint.uq112x112(0);

        if (numerator <= uint144(-1)) {
            uint256 result = (numerator << RESOLUTION) / denominator;
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        } else {
            uint256 result = FullMath.mulDiv(numerator, Q112, denominator);
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        }
    }
    
    // square root of a UQ112x112
    // lossy between 0/1 and 40 bits
    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        if (self._x <= uint144(-1)) {
            return uq112x112(uint224(Babylonian.sqrt(uint256(self._x) << 112)));
        }

        uint8 safeShiftBits = 255 - BitMath.mostSignificantBit(self._x);
        safeShiftBits -= safeShiftBits % 2;
        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x) << safeShiftBits) << ((112 - safeShiftBits) / 2)));
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

library FullMath {
    function fullMul(uint256 x, uint256 y) private pure returns (uint256 l, uint256 h) {
        uint256 mm = mulmod(x, y, uint256(-1));
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    function fullDiv(
        uint256 l,
        uint256 h,
        uint256 d
    ) private pure returns (uint256) {
        uint256 pow2 = d & -d;
        d /= pow2;
        l /= pow2;
        l += h * ((-pow2) / pow2 + 1);
        uint256 r = 1;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        return l * r;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 d
    ) internal pure returns (uint256) {
        (uint256 l, uint256 h) = fullMul(x, y);
        uint256 mm = mulmod(x, y, d);
        if (mm > l) h -= 1;
        l -= mm;
        require(h < d, 'FullMath::mulDiv: overflow');
        return fullDiv(l, h, d);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.7.5;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

contract Ownable {

    address public owner;

    constructor () {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require( owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }
    
    function transferOwnership(address _newOwner) external onlyOwner() {
        require( _newOwner != address(0) );
        owner = _newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

import './IBEP20.sol';
import './SafeMath.sol';
import './Address.sol';

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import '../interfaces/IUniswapV2Pair.sol';
import '../interfaces/IUniswapV2Factory.sol';
import "./SafeMath.sol";

library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(IUniswapV2Factory(factory).getPair(tokenA, tokenB)).getReserves(); 
        //changed how it gets the pair address to avoid having fixed init code hash
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./IBEP20.sol";
import "./Address.sol";
import "../interfaces/IPancakePair.sol";
import "../utils/UniswapV2Library.sol";
import "../interfaces/IPancakeRouter02.sol";
import "../interfaces/IUniswapV2Factory.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../utils/SafeMath.sol";
import "../utils/FixedPoint.sol";
import "../utils/FullMath.sol";
import "../utils/UniswapV2Library.sol";
import "../interfaces/IOmniZap.sol";

/*
*
* MIT License
* ===========
*
* Copyright financesauce (c) 2022
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

library ZapHelper {
    using SafeMath for uint;
    using FixedPoint for uint224;

    function checkLP(address _token) internal view returns(bool){
        require (_token != address(0), "address 0");
        require (Address.isContract(_token) == true, "not a contract");
        (bool domain,) = _token.staticcall(abi.encodeWithSignature("DOMAIN_SEPARATOR()"));
        (bool minimum,) = _token.staticcall(abi.encodeWithSignature("MINIMUM_LIQUIDITY()"));
        (bool permit,) = _token.staticcall(abi.encodeWithSignature("PERMIT_TYPEHASH()"));
        (bool factory,) = _token.staticcall(abi.encodeWithSignature("factory()"));
        (bool kLast,) = _token.staticcall(abi.encodeWithSignature("kLast()"));
        (bool price0,) = _token.staticcall(abi.encodeWithSignature("price0CumulativeLast()"));
        (bool price1,) = _token.staticcall(abi.encodeWithSignature("price1CumulativeLast()"));
        (bool token0,) = _token.staticcall(abi.encodeWithSignature("token0()"));
        (bool token1,) = _token.staticcall(abi.encodeWithSignature("token1()"));
        if (
            (domain == true) &&
            (minimum == true) &&
            (permit == true) &&
            (factory == true) &&
            (kLast == true) &&
            (price0 == true) &&
            (price1 == true) &&
            (token0 == true) &&
            (token1 == true)
        ){return true;}
        return false;
    }

    function isToken(address _token) internal view returns(bool){
        require (_token != address(0), "address 0");
        require (Address.isContract(_token) == true, "not a contract");
        (bool name,) = _token.staticcall(abi.encodeWithSignature("name()"));
        (bool symbol,) = _token.staticcall(abi.encodeWithSignature("symbol()"));
        (bool decimals,) = _token.staticcall(abi.encodeWithSignature("decimals()"));
        (bool totalSupply,) = _token.staticcall(abi.encodeWithSignature("symbol()"));
        if (checkLP(_token)){return false;}
        else{
            if (
                (name == true) &&
                (symbol == true ) &&
                (decimals == true ) &&
                (totalSupply == true )
            ){return true;}
        return false;}
    }

    function getPair(address token0, address token1, address router) internal view returns(address pair){
        address factory = getFactoryRouter(router);
        pair = IUniswapV2Factory(factory).getPair(token0, token1);
    }

    function getLpTokens(address lp) internal view returns(address token0, address token1){ 
        IUniswapV2Pair pair = IUniswapV2Pair(lp);
        token0 = pair.token0();
        token1 = pair.token1();
    }

    function getFactoryRouter(address router) internal pure returns(address factory){ //works
        IPancakeRouter02 Router = IPancakeRouter02(router);
        factory = Router.factory();
    }

    function getFactoryPair(address pair) internal view returns(address factory){ //works
        factory =  IUniswapV2Pair(pair).factory();
    }

    function getRatio(address tokenIn, uint amountIn, address tokenOut, address _quoteToken, address router) internal view returns(uint ratio){ //SHOULD WORK
        IPancakeRouter02 Router = IPancakeRouter02(router);

        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        path[1] = _quoteToken;
        path[2] = tokenOut;

        uint[] memory amounts = Router.getAmountsOut(amountIn, path);

        ratio = FixedFraction(amounts[2], amountIn); //returns the ratio between the two tokens with 18 decimals precision

    }

    function getAmtOut(uint amountIn, address token0, address token1, address router) internal view returns(uint amoutOut){ //WORKS
        IPancakeRouter02 Router = IPancakeRouter02(router);

        address[] memory path;
        path = new address[](2);
        path[0] = token0;
        path[1] = token1;

        uint[] memory amounts = Router.getAmountsOut(amountIn, path);
        return amounts[1];
    }

    function computeLiquidityValue(
        uint256 reservesA,
        uint256 reservesB,
        uint256 totalSupply,
        uint256 liquidityAmount,
        bool feeOn,
        uint kLast
    ) internal pure returns (uint256 tokenAAmount, uint256 tokenBAmount) {
        if (feeOn && kLast > 0) {
            uint rootK = Babylonian.sqrt(reservesA.mul(reservesB));
            uint rootKLast = Babylonian.sqrt(kLast);
            if (rootK > rootKLast) {
                uint numerator1 = totalSupply;
                uint numerator2 = rootK.sub(rootKLast);
                uint denominator = rootK.mul(5).add(rootKLast);
                uint feeLiquidity = FullMath.mulDiv(numerator1, numerator2, denominator);
                totalSupply = totalSupply.add(feeLiquidity);
            }
        }
        return (reservesA.mul(liquidityAmount) / totalSupply, reservesB.mul(liquidityAmount) / totalSupply);
    }

    function getLiquidityValue(address factory, address tokenA, address tokenB, uint256 liquidityAmount) internal view 
    returns (uint256 tokenAAmount, uint256 tokenBAmount) {
        (uint reservesA, uint reservesB) = UniswapV2Library.getReserves(factory, tokenA, tokenB);
        IUniswapV2Pair pair = IUniswapV2Pair(IUniswapV2Factory(factory).getPair(tokenA, tokenB));
        bool feeOn = IUniswapV2Factory(factory).feeTo() != address(0);
        uint kLast = feeOn ? pair.kLast() : 0;
        uint totalSupply = pair.totalSupply();
        return computeLiquidityValue(reservesA, reservesB, totalSupply, liquidityAmount, feeOn, kLast);
    }

    function getLpTokensAmount(address lp, uint amountLp) internal view returns (address tokenA, uint amountA, address tokenB, uint amountB){
        address factory = IUniswapV2Pair(lp).factory();
        (tokenA, tokenB) = getLpTokens(lp);
        (amountA, amountB) = getLiquidityValue(factory, tokenA, tokenB, amountLp);
    }

    function getBondRatio(address tokenIn, uint amountIn, address tokenOut, address _quoteToken, address router, bool isLpBond) external view returns(uint ratio){

        if (isLpBond){
            (address tokenA, uint amountA, address tokenB, uint amountB) = getLpTokensAmount(tokenIn, amountIn);
            if (tokenA == tokenOut){
                uint sum = amountA.add(getAmtOut(amountB, tokenB, _quoteToken, router));
                ratio = FixedFraction(sum, amountIn);
            }
            else if (tokenB == tokenOut){
                uint sum = amountB.add(getAmtOut(amountA, tokenA, _quoteToken, router));
                ratio = FixedFraction(sum, amountIn);
            }
            else { uint sum;
            if (tokenA == _quoteToken){
                sum = getAmtOut(amountA, tokenA, tokenOut, router); //get amount of tokenOut for amtTknA
                uint amountQuote = (getAmtOut(amountB, tokenB, _quoteToken, router)); //get amount of _quoteToken for amtTokB
                sum = sum.add(getAmtOut(amountQuote, _quoteToken, tokenOut, router));
              
            }
            else if (tokenB == _quoteToken){
                sum = getAmtOut(amountB, tokenB, tokenOut, router); //get amount of tokenOut for amtTknA
                uint amountQuote = (getAmtOut(amountA, tokenA, _quoteToken, router)); //get amount of _quoteToken for amtTokB
                sum = sum.add(getAmtOut(amountQuote, _quoteToken, tokenOut, router));

            }
            else {
                uint amountQuote = getAmtOut(amountA, tokenA, _quoteToken, router); //get amount of tokenOut for amtTknA
                amountQuote = amountQuote.add(getAmtOut(amountB, tokenB, _quoteToken, router)); //get amount of tokenOut for amtTknA
                sum = getAmtOut(amountQuote, _quoteToken, tokenOut, router);
            }
        
            ratio = FixedFraction(sum, amountIn);}
        }
        if (!isLpBond){
            if (tokenIn == _quoteToken || tokenOut == _quoteToken){
                uint amountOut = getAmtOut(amountIn, tokenIn, tokenOut, router);
                ratio = FixedFraction(amountOut, amountIn);
            }

            else{
            ratio = getRatio(tokenIn, amountIn, tokenOut, _quoteToken, router);
            }
        }
    }

    function FixedFraction(uint numerator, uint denominator) internal pure returns(uint result){
        FixedPoint.uq112x112 memory resultEnc = FixedPoint.fraction(numerator, denominator);
        result = FixedPoint.decode112with18(resultEnc);
    }

}