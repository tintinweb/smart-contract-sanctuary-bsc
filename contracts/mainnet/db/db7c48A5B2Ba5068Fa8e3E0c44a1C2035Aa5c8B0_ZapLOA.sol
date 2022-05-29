/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
    Zap function is developed for staking single token for liquidity pool participation.
    A single token amount is taken and instead same value of BUSD-LOA LP token is issued to the user excluding some fees.
    Underneath it calls pancakeswap router for token exchange and Liquidity Pool participation.
    This is heavily inspired from Pancake swap zap function (https://github.com/PancakeBunny-finance/Bunny/tree/main/contracts/zap)
 */

interface IZap {
    function covers(address _token) external view returns (bool);
    function zapOut(address _from, uint amount) external;
    function zapIn(address _to) external payable;
    function zapInToken(address _from, uint amount, address _to) external;
}


interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}


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
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {

}


library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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




library SafeBEP20 {
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

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

contract ZapLOA {
    using SafeBEP20 for IBEP20;

    //TESTNET
    address private LOA; 
    address private BUSD;
    address private WBNB; 

    address private ROUTER_ADDRESS;
    IPancakeRouter02 private ROUTER; // LIVE 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff , Test 0xD99D1c33F9fC3444f8101754aBC46c52416550D1

    /* ========== STATE VARIABLES ========== */

    mapping(address => bool) private notFlip;
    mapping(address => address) private routePairAddresses;
    address[] public tokens;

    mapping(address=> uint8) private _admins;
    address private _treasury;


    constructor(
            address busdAddress, 
            address loaAdddress, 
            address wBNBAddress, 
            address pancakeRouterAddress
        ) {
        ROUTER_ADDRESS = pancakeRouterAddress;
        ROUTER = IPancakeRouter02(ROUTER_ADDRESS);

        LOA = loaAdddress;
        BUSD = busdAddress;
        WBNB = wBNBAddress;

        _admins[msg.sender] = 1;

        setNotFlip(BUSD);
        setRoutePairAddress(LOA, BUSD);
    }

    function setTresury(address treasury) validAdmin public {
        _treasury = treasury;
    }

    modifier validAdmin() {
        require(_admins[msg.sender] == 1, "You are not authorized.");
        _;
    }

    function addAdmin(address newAdmin) validAdmin public {
        _admins[newAdmin] = 1;
    }

    function removeAdmin(address oldAdmin) validAdmin public {
        delete _admins[oldAdmin];
    }

    /* ========== View Functions ========== */
    //check if the token can be flipped to BUSD
    function isFlip(address _address) public view returns (bool) {
        return !notFlip[_address];
    }

    //check if the token is supported
    function covers(address _token) public view returns (bool) {
        return notFlip[_token];
    }

    function routePair(address _address) external view returns (address) {
        return routePairAddresses[_address];
    }


    /* ========== External Functions ========== */

    //Zap any supported token for BUSD-LOA LP token
    function zap ( address token, uint256 amount) external {

        require(covers(token), "Provided token not covered");
        IBEP20 busdToken = IBEP20(token);

        uint256 halfBUSDAmount = 0;
        uint256 loaAmount = 0;

        if(token != BUSD) {

            IBEP20 anyToken = IBEP20(token);
            require(anyToken.balanceOf(msg.sender) >= amount, "Amount not available" );

            anyToken.safeTransferFrom(msg.sender, address(this), amount);
            _approveTokenIfNeeded(token, amount);

            uint256 amountBUSD = _swap(token, amount, BUSD, 0, address(this), block.timestamp);

            halfBUSDAmount = amountBUSD / 2;

            _approveTokenIfNeeded(BUSD, amountBUSD);

             loaAmount = _swap(BUSD, halfBUSDAmount, LOA, 0, address(this), block.timestamp);
            _approveTokenIfNeeded(LOA, loaAmount);
            
        }
        else {

            require(busdToken.balanceOf(msg.sender) >= amount, "Amount not available" );

            halfBUSDAmount = amount / 2;

            busdToken.safeTransferFrom(msg.sender, address(this), amount);
            _approveTokenIfNeeded(token, amount);

            loaAmount = _swap(BUSD, halfBUSDAmount, LOA, 0, address(this), block.timestamp);
            _approveTokenIfNeeded(LOA, loaAmount);
        }

         ROUTER.addLiquidity(
                BUSD,
                LOA,
                halfBUSDAmount,
                loaAmount,
                0,
                0,
                msg.sender,
                block.timestamp
            );
    }



    // Zap BNB to get BUSD-LOA LP token
    function zapEth () external payable {

        uint256 halfBUSDAmount = 0;
        uint256 loaAmount = 0;

        require(msg.value > 0 , "Value not provided" );

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = BUSD;

        uint[] memory amounts = ROUTER.swapExactETHForTokens{ value: msg.value }(0, path, address(this), block.timestamp);
        uint amountBUSD = amounts[amounts.length - 1];

        halfBUSDAmount = amountBUSD / 2; 
        _approveTokenIfNeeded(BUSD, amountBUSD);

        loaAmount = _swap(BUSD, halfBUSDAmount, LOA, 0, address(this), block.timestamp);
        _approveTokenIfNeeded(LOA, loaAmount);
            

        ROUTER.addLiquidity(
                BUSD,
                LOA,
                halfBUSDAmount,
                loaAmount,
                0,
                0,
                msg.sender,
                block.timestamp
            );
    }


    /* ========== Private Functions ========== */

    function _approveTokenIfNeeded(address token, uint amount) private {
        if (IBEP20(token).allowance(address(this), address(ROUTER)) < amount) {
            IBEP20(token).safeIncreaseAllowance(address(ROUTER), amount - IBEP20(token).allowance(address(this), address(ROUTER)));
        }
    }


    //swap any supported token to another supported token
    function _swap(
        address _from,
        uint amount,
        address _to,
        uint amountOutMin,
        address receiver,
        uint deadline
    ) private returns (uint) {
        address intermediate = routePairAddresses[_from];
        if (intermediate == address(0)) {
            intermediate = routePairAddresses[_to];
        }

        address[] memory path;
        if (intermediate != address(0) && (_from == WBNB || _to == WBNB)) {
            // [WBNB, QUICK, X] or [X, QUICK, WBNB]
            path = new address[](3);
            path[0] = _from;
            path[1] = intermediate;
            path[2] = _to;
        } else if (intermediate != address(0) && (_from == intermediate || _to == intermediate)) {
            // [BTC, ETH] or [ETH, BTC]
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else if (intermediate != address(0) && routePairAddresses[_from] == routePairAddresses[_to]) {
            // [BTC, ETH, DAI] or [DAI, ETH, BTC]
            path = new address[](3);
            path[0] = _from;
            path[1] = intermediate;
            path[2] = _to;
        } else if (
            routePairAddresses[_from] != address(0) &&
            routePairAddresses[_to] != address(0) &&
            routePairAddresses[_from] != routePairAddresses[_to]
        ) {
            // routePairAddresses[xToken] = xRoute
            // [X, BTC, ETH, USDC, Y]
            path = new address[](5);
            path[0] = _from;
            path[1] = routePairAddresses[_from];
            path[2] = WBNB;
            path[3] = routePairAddresses[_to];
            path[4] = _to;
        } else if (intermediate != address(0) && routePairAddresses[_from] != address(0)) {
            // [BTC, ETH, WBNB, QUICK]
            path = new address[](4);
            path[0] = _from;
            path[1] = intermediate;
            path[2] = WBNB;
            path[3] = _to;
        } else if (intermediate != address(0) && routePairAddresses[_to] != address(0)) {
            // [QUICK, WBNB, ETH, BTC]
            path = new address[](4);
            path[0] = _from;
            path[1] = WBNB;
            path[2] = intermediate;
            path[3] = _to;
        } else if (_from == WBNB || _to == WBNB) {
            // [WBNB, QUICK] or [QUICK, WBNB]
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            // [QUICK, WBNB, X] or [X, WBNB, QUICK]
            path = new address[](3);
            path[0] = _from;
            path[1] = WBNB;
            path[2] = _to;
        }

        uint[] memory amounts = ROUTER.swapExactTokensForTokens(amount, amountOutMin, path, receiver, deadline);
        return amounts[amounts.length - 1];
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setRoutePairAddress(address asset, address route) public validAdmin {
        routePairAddresses[asset] = route;
    }

    function setNotFlip(address token) public validAdmin {
        bool needPush = notFlip[token] == false;
        notFlip[token] = true;
        if (needPush) {
            tokens.push(token);
        }
    }

    function removeToken(uint i) external validAdmin {
        address token = tokens[i];
        notFlip[token] = false;
        tokens[i] = tokens[tokens.length - 1];
        tokens.pop();
    }


    //sweep and transfer to admin if any extra tokens are allocated to this contract.
    function sweep() external validAdmin {
        for (uint i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            if (token == address(0)) continue;
            uint amount = IBEP20(token).balanceOf(address(this));
            if (amount > 0) {
                _swap(token, amount, BUSD, 0, _treasury, block.timestamp);
            }
        }
    }

    //withdraw and transfer to admin if any extra tokens are allocated to this contract.
    function withdraw(address token) external validAdmin {
        if (token == address(0)) {
            payable(_treasury).transfer(address(this).balance);
            return;
        }

        IBEP20(token).transfer(_treasury, IBEP20(token).balanceOf(address(this)));
    }

}