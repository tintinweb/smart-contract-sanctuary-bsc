/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
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

interface IERC20 {
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}

interface ICakeToken {
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

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

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: BEP20 operation did not succeed");
        }
    }
}

interface IPancakeRouter {
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

interface ICakePool {
    function enterStaking(uint256 _amount) external;
    function leaveStaking(uint256 _amount) external;

    function poolInfo(uint256) external view returns(address, uint256, uint256, uint256);
    function totalCAKEStaked() external view returns(uint);
}

contract Staking {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public Owner;
    uint devFee = 2;

    ICakeToken public CakeToken;
    ICakeToken public SyrupBar;
    address CakeTokenAddress;
    IERC20 public mycoinToken;
    address mycoinTokenAddress;
    address public cakePoolAddress;
    ICakePool public cakePool;
    IPancakeRouter public pancakeRouter;
    address pancakeRouterAddress;

    struct _userInfo {
        uint256 cakeAmount;
        uint256 syrupAmount;
        uint256 rewardDebt;
    }
    struct _poolInfo {
        address lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accCakePerShare;
    }

    mapping ( address => _userInfo ) public userInfo;
    mapping ( uint => _poolInfo ) public poolInfo;
    
    event _stake ( address account, uint cakeAmount, uint SyrupBalance );
    event unStakeLogs ( uint256 _pending, uint256 _balance );
    event _unStake ( address account, uint CakeAmount, uint CakeReward, uint MBCtoken, uint SyrupBalance );

    constructor (
        address _cakeToken,
        address _syrupBar,
        address _mycoinToken,
        address _cakePool,
        address _pancakeRouter
      ){
        Owner = msg.sender;
        CakeToken = ICakeToken(_cakeToken);
        SyrupBar = ICakeToken(_syrupBar);
        CakeTokenAddress = _cakeToken;
        mycoinToken = IERC20(_mycoinToken);
        mycoinTokenAddress = _mycoinToken;
        cakePool = ICakePool(_cakePool);
        cakePoolAddress = _cakePool;
        pancakeRouter = IPancakeRouter(_pancakeRouter);
        pancakeRouterAddress = _pancakeRouter;
    }

    modifier onlyOwner {
        require( msg.sender == Owner , "Not Owner");
        _;
    }

    function updateAddress(
        address _cakeToken,
        address _syrupBar,
        address _mycoinToken,
        address _cakePool,
        address _pancakeRouter
        ) external onlyOwner {
        CakeToken = ICakeToken(_cakeToken);
        SyrupBar = ICakeToken(_syrupBar);
        CakeTokenAddress = _cakeToken;
        mycoinToken = IERC20(_mycoinToken);
        mycoinTokenAddress = _mycoinToken;
        cakePool = ICakePool(_cakePool);
        cakePoolAddress = _cakePool;
        pancakeRouter = IPancakeRouter(_pancakeRouter);
        pancakeRouterAddress = _pancakeRouter;
    }

    function stake(uint _cakeAmount) external {

        require(
            _cakeAmount != 0, 
            "AMOUNT_CANNOT_BE_ZERO"
        );

        address _msgSender = msg.sender;
        updatePoolInfo();

        _userInfo storage user = userInfo[_msgSender];
        _poolInfo storage pool = poolInfo[0];

        user.cakeAmount = user.cakeAmount.add(_cakeAmount);
        user.rewardDebt = user.cakeAmount.mul(pool.accCakePerShare).div(1e12);

        CakeToken.transferFrom( _msgSender, address(this), _cakeAmount );
        CakeToken.approve(cakePoolAddress, _cakeAmount);
        cakePool.enterStaking(_cakeAmount);

        uint256 _syrupBalance = SyrupBar.balanceOf( address(this) );
        user.syrupAmount = user.syrupAmount.add(_syrupBalance);
        SyrupBar.transfer( _msgSender, _syrupBalance );

        emit _stake ( _msgSender, _cakeAmount, _syrupBalance );

    }


    function unStake(uint _cakeAmount) external {

        require(
            _cakeAmount != 0, 
            "AMOUNT_CANNOT_BE_ZERO"
        );

        require(
            _cakeAmount <= userInfo[msg.sender].cakeAmount,
            "You didn't have that many tokens for unstake."
        );

        require(
            userInfo[msg.sender].syrupAmount <= SyrupBar.balanceOf( msg.sender ),
            "Ops that's a problem. You didn't have SyrupBar."
        );

        address _msgSender = msg.sender;
        updatePoolInfo();

        _userInfo storage user = userInfo[_msgSender];
        _poolInfo storage pool = poolInfo[0];

        uint256 __pending = user.cakeAmount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);

        user.cakeAmount = user.cakeAmount.sub(_cakeAmount);
        user.rewardDebt = user.cakeAmount.mul(pool.accCakePerShare).div(1e12);

        SyrupBar.transferFrom( _msgSender, address(this), user.syrupAmount );
        SyrupBar.approve( cakePoolAddress, user.syrupAmount );
        cakePool.leaveStaking( _cakeAmount );
        CakeToken.transfer( _msgSender, _cakeAmount );

        uint256 _syrupBalance = SyrupBar.balanceOf( address(this) );
        user.syrupAmount = _syrupBalance;
        if ( _syrupBalance > 0 ) {
            SyrupBar.transfer( _msgSender, _syrupBalance );
        }
        
        uint256 balance = CakeToken.balanceOf( address(this) );
        emit unStakeLogs ( __pending, balance );

        if ( balance > 0 ) {
            uint256 _userBalance = balance.div(2);
            uint256 _ownerFee = balance.mul(devFee).div(10000);
            uint256 _swapBalance = balance.sub(_userBalance).sub(_ownerFee);

            if ( _userBalance > 0 ) {
                CakeToken.transfer( _msgSender, _userBalance );
            }
            if ( _ownerFee > 0 ) {
                CakeToken.transfer( Owner, _ownerFee );
            }
            if ( _swapBalance > 0 ) {
                _swapTokens( _msgSender, _swapBalance );
            }

            emit _unStake ( _msgSender, _cakeAmount, _userBalance, _swapBalance, _syrupBalance );
        }
    }

    function _swapTokens(address _account, uint _cakeAmount) internal {

        address[] memory path;
        path = new address[](2);
        path[0] = CakeTokenAddress;
        path[1] = mycoinTokenAddress;
        uint amountOfTokens = getAmountOutMin(_cakeAmount, path);

        CakeToken.approve(pancakeRouterAddress, _cakeAmount);
        pancakeRouter.swapExactTokensForTokens(
            _cakeAmount,
            amountOfTokens,
            path,
            _account,
            block.timestamp.mul(2)
        );

    }

    function getPoolInfo() public view returns(address, uint256, uint256, uint256) {
        return cakePool.poolInfo(0);
    }

    function updatePoolInfo() internal {
        (address lpToken, uint256 allocPoint, uint256 lastRewardBlock, uint256 accCakePerShare) = getPoolInfo();
        poolInfo[0] = _poolInfo( lpToken, allocPoint, lastRewardBlock, accCakePerShare);
    }

    function getPending(address _account) public view returns(uint256) {

        _userInfo storage user = userInfo[_account];
        (address lpToken, uint256 allocPoint, uint256 lastRewardBlock, uint256 accCakePerShare) = getPoolInfo();

        uint256 _pending = user.cakeAmount.mul(accCakePerShare).div(1e12).sub(user.rewardDebt);

        return _pending;
    }

    function getAmountOutMin( uint _amountIn, address[] memory _path ) internal view returns (uint) {
        uint[] memory amountOutMins = pancakeRouter.getAmountsOut(_amountIn, _path);
        return amountOutMins[_path.length - 1];
    }

    function balanceOfStakedToken(address _account) public view returns(uint256 amount, uint256 rewardDebt) {
        _userInfo storage user = userInfo[_account];
        return (user.cakeAmount, user.rewardDebt);
    }

}