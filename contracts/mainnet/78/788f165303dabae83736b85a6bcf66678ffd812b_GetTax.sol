/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

// Testing 0xfd87dC9f5e73e251c59022b0084b69643115b5fb MutantDog on BSC
// THIS CONTRACT = 0x0C12554628a2c32ad6c00bA4eAf5aA1e8685BB34 on BSC


// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
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
    
    modifier onlyOwner() virtual {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IFactoryV2 {
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IRouterV2 {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);

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
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

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

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);


    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function decimals() external view returns (uint8);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value); 
    function owner() external returns (address);  
    function renounceOwnership() external;
}


interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}

contract GetTax is Context, Ownable {

    using SafeMath for uint256;
    using Address for address;

    address[] sellPath;
    address[] buyPath;    
    address factoryAddress;
    address private constant wethAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    
    constructor () {}

    function getTxInfo(address tokenAddress) external payable returns(address whoAmI, address thisContract, uint256 msgValue, uint256 tokenBalance) {
        IERC20 erc20 = IERC20(tokenAddress);
        whoAmI = msg.sender;
        thisContract = address(this);
        msgValue = msg.value;
        tokenBalance = erc20.balanceOf(whoAmI);
    } 

    function transferTokens(address tokenAddress, uint256 tokenAmount) public returns (uint256 tokenBalance) {
        IERC20 tokenContract = IERC20(tokenAddress);
        tokenContract.transferFrom(msg.sender, address(this), tokenAmount);

        tokenBalance = tokenContract.balanceOf(address(this));
    }


    function addLiquidityWETH(address tokenA, address tokenB, uint256 amountTokenA, uint256 amountTokenB, address routerAddress)  public {


        IRouterV2 v2Router = IRouterV2(routerAddress);
        IFactoryV2 v2Factory = IFactoryV2(v2Router.factory());
        bool tokenAWeth = false;
        if (tokenA == wethAddress) {
            tokenAWeth = true;
        }

       

        IERC20 tokenAContract = IERC20(tokenA);
        IERC20 tokenBContract = IERC20(tokenB);
        approve(tokenA, tokenB, routerAddress);

        if (tokenAWeth) {
            tokenBContract.transferFrom(msg.sender, address(this), amountTokenB);
        }
        else 
        {
            tokenAContract.transferFrom(msg.sender, address(this), amountTokenA);

        }

        address pairAddress = v2Factory.getPair(tokenA, tokenB);

        if (pairAddress == address(0) || ((tokenAWeth && tokenAContract.balanceOf(pairAddress) == 0) || (!tokenAWeth && tokenBContract.balanceOf(pairAddress) == 0)) ) {
            (bool success, bytes memory returndata) = routerAddress.delegatecall(
                     abi.encodeWithSelector(v2Router.addLiquidity.selector, 
                                                                    tokenA, 
                                                                    tokenB,
                                                                    tokenAContract.balanceOf(address(this)),
                                                                    tokenBContract.balanceOf(address(this)),
                                                                    0, 
                                                                    0, 
                                                                    msg.sender, 
                                                                    block.timestamp+600));
                                                                 
            // if the function call reverted
            if (success == false) {
                // if there is a return reason string
                if (returndata.length > 0) {
                    // bubble up any reason for revert
                    assembly {
                        let returndata_size := mload(returndata)
                        revert(add(32, returndata), returndata_size)
                    }
                } else {
                    revert("Function call reverted");
                }
            }
        }
    }


    function addLiquidity(address tokenAddress, address routerAddress) private {
        IRouterV2 v2Router = IRouterV2(routerAddress);
        IFactoryV2 v2Factory = IFactoryV2(factoryAddress);
        IERC20 weth = IERC20(wethAddress);
        IERC20 erc20 = IERC20(tokenAddress);
        address ercOwner = msg.sender;
        uint256 ethBalance = msg.value;

        address pairAddress = v2Factory.getPair(tokenAddress, wethAddress);
        if (pairAddress == address(0) || weth.balanceOf(pairAddress) == 0) {
            v2Router.addLiquidityETH{value: ethBalance.div(2)}(
                tokenAddress, 
                erc20.balanceOf(ercOwner),
                0, 
                0, 
                ercOwner, 
                block.timestamp+1200);
        }
    }

    
    function getTaxesAsOwner(
                      address tokenAddress,
                      bool checkLiquidity,
                      bool renounce,
                      address routerAddress) external payable returns(uint256 wethOut, uint256 ercOut, uint256 swapWethOut, uint256 swapErcOut, bool isHoney) {

        IRouterV2 v2Router = IRouterV2(routerAddress);
        factoryAddress = v2Router.factory();
        
        approveAll(tokenAddress, routerAddress);
        IERC20 erc20 = IERC20(tokenAddress);
        sellPath = [tokenAddress, wethAddress];
        buyPath = [wethAddress, tokenAddress];
        isHoney = false;
        address owner = msg.sender;
        uint256 ethBalance = msg.value;

        // Add Liquidity
        if (checkLiquidity) {addLiquidity(tokenAddress, routerAddress);}

        if (renounce){erc20.renounceOwnership();}

        // Buy ERC20 
        try v2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethBalance.div(2)}(
                0,
                buyPath,
                address(this),
                block.timestamp
            ) {
            swapErcOut =  erc20.balanceOf(address(this));
        }
        catch {
            swapErcOut = 0;
        }

        try v2Router.getAmountsOut(ethBalance.div(2), buyPath) returns (uint[] memory amounts) {
            ercOut = amounts[1];
        }
        catch {
            ercOut = 0;
        }

        // Sell ERC20 
        uint256 currentEth = owner.balance;
        try v2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                swapErcOut,
                0,
                sellPath,
                address(this),
                block.timestamp) {

            uint256 _swapWethBalance = owner.balance.sub(currentEth);
            swapWethOut = _swapWethBalance;
        }
        catch {
            swapWethOut = 0;
            isHoney = true;
        }

        // Get Current Router Amounts
        try v2Router.getAmountsOut(swapErcOut, sellPath) returns (uint[] memory amounts) {
            wethOut = amounts[1];
        }
        catch {
            wethOut = 0;
        } 
    }

    function approveAll(address tokenAddress, address routerAddress) private {
        IERC20 erc20 = IERC20(tokenAddress);
        IERC20 weth = IERC20(wethAddress);
        erc20.approve(routerAddress, type(uint256).max);
        weth.approve(routerAddress, type(uint256).max);
        erc20.approve(address(this), type(uint256).max);
        weth.approve(address(this), type(uint256).max);
    }

    function approve(address tokenA, address tokenB, address routerAddress) private {
        IERC20 tokenAContract = IERC20(tokenA);
        IERC20 tokenBContract = IERC20(tokenB);
        tokenAContract.approve(routerAddress, type(uint256).max);
        tokenBContract.approve(routerAddress, type(uint256).max);
        tokenAContract.approve(address(this), type(uint256).max);
        tokenBContract.approve(address(this), type(uint256).max);
    }

    function getTaxes(address tokenAddress,
                      address routerAddress
                      ) external payable returns(uint256 wethOut, uint256 ercOut, uint256 swapWethOut, uint256 swapErcOut, bool isHoney) {
        IRouterV2 v2Router = IRouterV2(routerAddress);
        approveAll(tokenAddress, routerAddress);
        IERC20 erc20 = IERC20(tokenAddress);
        IERC20 weth = IERC20(wethAddress);
        sellPath = [tokenAddress, wethAddress];
        buyPath = [wethAddress, tokenAddress];
        isHoney = false;

        IWETH(v2Router.WETH()).deposit{value: msg.value}();

        // Buy ERC20 
        try v2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                msg.value,
                0,
                buyPath,
                address(this),
                block.timestamp
            ) {
            swapErcOut =  erc20.balanceOf(address(this));
        }
        catch {
            swapErcOut = 0;
        }

        try v2Router.getAmountsOut(msg.value, buyPath) returns (uint[] memory amounts) {
            ercOut = amounts[1];
        }
        catch {
            ercOut = 0;
        }

        // Sell ERC20 
        uint256 wethBalance = weth.balanceOf(address(this));
        try v2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                swapErcOut,
                0,
                sellPath,
                address(this),
                block.timestamp) {

            uint256 _swapWethBalance = weth.balanceOf(address(this)).sub(wethBalance);
            swapWethOut = _swapWethBalance;
        }
        catch {
            swapWethOut = 0;
            isHoney = true;
        }

        // Get Current Router Amounts
        try v2Router.getAmountsOut(swapErcOut, sellPath) returns (uint[] memory amounts) {
            wethOut = amounts[1];
        }
        catch {
            wethOut = 0;
        } 
    }

    receive() external payable {}

    function withdrawETH() external onlyOwner() {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function withdrawERC20(address _token, address _to) public onlyOwner returns(bool _sent){
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }
}