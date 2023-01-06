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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.5;

/*
*
* MIT License
* ===========
*
* Copyright Mizu (c) 2020
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

contract OmniZap is Ownable {
    using SafeMath for uint;
    using SafeBEP20 for IBEP20;

    IBEP20 public WNAT; // WRAPPED NATIVE FOR DEPLOYED CHAIN
    address public safeSwapBNB;

    constructor ( 
        address _WNAT
    ) {
        require( _WNAT != address(0) );
        WNAT = IBEP20(_WNAT);
        safeSwapBNB = _WNAT;
        IBEP20(WNAT).approve(_WNAT, uint(-1));
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
    mapping(address => address) private routePairAddresses;
    mapping (address => bool) Blacklist;
    address[] public tokens;
    uint256 public ListingFee;
    address public ListingToken;

    receive() external payable {}


    /* ========== View Functions ========== */

    function isLP(address _address) public view returns (bool) {
        return !notLP[_address];
    }

    function routePair(address _address) external view returns(address) {
        return routePairAddresses[_address];
    }

    /* ========== External Functions ========== */

    function zapInToken(address _from, uint amount, address _to, address _router) external {
        IBEP20(_from).safeTransferFrom(msg.sender, address(this), amount);
        _approveTokenIfNeeded(_from, _router);

        if (isLP(_to)) {
            IPancakePair pair = IPancakePair(_to);
            address token0 = pair.token0();
            address token1 = pair.token1();
            if (_from == token0 || _from == token1) {
                // swap half amount for other
                address other = _from == token0 ? token1 : token0;
                _approveTokenIfNeeded(other, _router);
                uint sellAmount = amount.div(2);
                uint otherAmount = _swap(_from, sellAmount, other, address(this), _router);
                pair.skim(address(this));
                IPancakeRouter02(_router).addLiquidity(_from, other, amount.sub(sellAmount), otherAmount, 0, 0, msg.sender, block.timestamp);
            } else {
                uint bnbAmount = _from == address(WNAT) ? _safeSwapToBNB(amount) : _swapTokenForBNB(_from, amount, address(this), _router);
                _swapBNBToLP(_to, bnbAmount, msg.sender, _router);
            }
        } else {
            _swap(_from, amount, _to, msg.sender, _router);
        }
        emit ZapToken(_from, amount, _to, _router);
    }

    function zapIn(address _to, address _router) external payable {
        _swapBNBToLP(_to, msg.value, msg.sender, _router);
        emit ZapETH(_to, _router);
    }

    function zapOut(address _from, uint amount, address _router) external {
        IBEP20(_from).safeTransferFrom(msg.sender, address(this), amount);
        _approveTokenIfNeeded(_from, _router);

        if (!isLP(_from)) {
            _swapTokenForBNB(_from, amount, msg.sender, _router);
        } else {
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

    function _swapBNBToLP(address flip, uint amount, address receiver, address _router) private {
        if (!isLP(flip)) {
            _swapBNBForToken(flip, amount, receiver, _router);
        } else {
            IPancakePair pair = IPancakePair(flip);
            address token0 = pair.token0();
            address token1 = pair.token1();
            if (token0 == address(WNAT) || token1 == address(WNAT)) {
                address token = token0 == address(WNAT) ? token1 : token0;
                uint swapValue = amount.div(2);
                uint tokenAmount = _swapBNBForToken(token, swapValue, address(this), _router);

                _approveTokenIfNeeded(token, _router);
                pair.skim(address(this));
                IPancakeRouter02(_router).addLiquidityETH{value : amount.sub(swapValue)}(token, tokenAmount, 0, 0, receiver, block.timestamp);
            } else {
                uint swapValue = amount.div(2);
                uint token0Amount = _swapBNBForToken(token0, swapValue, address(this), _router);
                uint token1Amount = _swapBNBForToken(token1, amount.sub(swapValue), address(this), _router);

                _approveTokenIfNeeded(token0, _router);
                _approveTokenIfNeeded(token1, _router);
                pair.skim(address(this));
                IPancakeRouter02(_router).addLiquidity(token0, token1, token0Amount, token1Amount, 0, 0, receiver, block.timestamp);
            }
        }
    }

    function _swapBNBForToken(address token, uint value, address receiver, address _router) private returns (uint) {     
        address[] memory path;

        if (routePairAddresses[token] != address(0)) {
            path = new address[](3);
            path[0] = address(WNAT);
            path[1] = routePairAddresses[token];
            path[2] = token;
        } else {
            path = new address[](2);
            path[0] = address(WNAT);
            path[1] = token;
        }

        uint[] memory amounts = IPancakeRouter02(_router).swapExactETHForTokens{value : value}(0, path, receiver, block.timestamp);
        return amounts[amounts.length - 1];
    }

    function _swapTokenForBNB(address token, uint amount, address receiver, address _router) private returns (uint) {
        address[] memory path;
        if (routePairAddresses[token] != address(0)) {
            path = new address[](3);
            path[0] = token;
            path[1] = routePairAddresses[token];
            path[2] = address(WNAT);
        } else {
            path = new address[](2);
            path[0] = token;
            path[1] = address(WNAT);
        }

        uint[] memory amounts = IPancakeRouter02(_router).swapExactTokensForETH(amount, 0, path, receiver, block.timestamp);
        return amounts[amounts.length - 1];
    }

    function _swap(address _from, uint amount, address _to, address receiver, address _router) private returns (uint) {
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

        uint[] memory amounts = IPancakeRouter02(_router).swapExactTokensForTokens(amount, 0, path, receiver, block.timestamp);
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

    // TEST ZAPOUTTO //

    function zapOutFor(address _from, uint amount, address _router) internal returns(uint amt1, uint amt2){
        IBEP20(_from).safeTransferFrom(msg.sender, address(this), amount);
        _approveTokenIfNeeded(_from, _router);

        if (!isLP(_from)) {
            _swapTokenForBNB(_from, amount, msg.sender, _router);
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

    function swapLpToNative(address _lp, uint _amount, address _router) internal returns (uint){
        (uint amt1, uint amt2) = zapOutFor(_lp, _amount, _router); //ZAPOUT THE LP
        IPancakePair pair = IPancakePair(_lp);
        address token0 = pair.token0(); // GET TOKEN 0 ADDR
        address token1 = pair.token1(); // GET TOKEN 1 ADDR
        uint natSum;
            //SWAP ALL TO WNAT
            if (token0 == address(WNAT))
            {   
                _approveTokenIfNeeded(token1, _router);
                uint amtSwap = _swap(token1, amt1, address(WNAT), address(this), _router);
                _safeSwapToBNB(amtSwap);
                natSum = (amtSwap + amt2);
            }
            if (token1 == address(WNAT))
            {   
                _approveTokenIfNeeded(token0, _router);
                uint amtSwap = _swap(token0, amt1, address(WNAT), address(this), _router);
                _safeSwapToBNB(amtSwap);
                natSum = (amtSwap + amt2);
            }
            else {
                uint amtSwap = _swap(token0, amt1, address(WNAT), address(this), _router);
                amtSwap += _swap(token1, amt2, address(WNAT), address(this), _router);
                _safeSwapToBNB(amtSwap);
            }
        return natSum;
    }

    function zapOutTo(address _lp, uint _amount, address _to, address _routerFrom, address _routerTo) external {
        uint natAmt = swapLpToNative(_lp, _amount, _routerFrom);

        if(isLP(_to)){
            _swapBNBToLP(_to, natAmt, msg.sender, _routerTo);
        }
        if(!isLP(_to)){
            _swapBNBForToken(_to, natAmt, msg.sender, _routerTo);
        }
        if(_to == address(0) && _routerTo == address(0)){
            payable(msg.sender).transfer(natAmt-1);
        }
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
pragma solidity 0.7.5;

import "./IBEP20.sol";
import "./Address.sol";
import "../interfaces/IPancakePair.sol";

/*
*
* MIT License
* ===========
*
* Copyright financesauce (c) 2020
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

}