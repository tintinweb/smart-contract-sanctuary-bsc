/**
 *Submitted for verification at BscScan.com on 2022-05-18
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
    function deposit( uint256 _amount, uint256 _lockDuration ) external;
    function withdraw(uint256 _shares) external;
    function withdrawByAmount(uint256 _amount) external;

    function totalShares() external returns(uint256);
    function totalBoostDebt() external returns(uint256);
    function totalLockedAmount() external returns(uint256);
}

contract Staking {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public Owner;
    uint devFee = 2;

    ICakeToken public CakeToken;
    address CakeTokenAddress;
    IERC20 public mycoinToken;
    address mycoinTokenAddress;
    address public cakePoolAddress;
    ICakePool public cakePool;
    IPancakeRouter public pancakeRouter;
    address pancakeRouterAddress;

    uint256 public constant PRECISION_FACTOR = 1e12; // precision factor.
    uint256 public DURATION_FACTOR = 365 days; // 365 days, in order to calculate user additional boost.
    uint256 public UNLOCK_FREE_DURATION = 1 weeks; // 1 week
    uint256 public DURATION_FACTOR_OVERDUE = 180 days; // 180 days, in order to calculate overdue fee.
    uint256 public constant PRECISION_FACTOR_SHARE = 1e28; // precision factor for share.
    uint256 public BOOST_WEIGHT = 100 * 1e10; // 100%

    uint256 public performanceFee = 200; // 2%
    uint256 public overdueFee = 100 * 1e10; // 100%

    struct _userInfo {
        uint256 amount;
        uint256 shares;
    }

    mapping ( address => _userInfo ) public userInfo;
    
    event _stake ( address account, uint cakeAmount, uint256 shares );
    event _Withdraw(address indexed sender, uint256 amount, uint256 shares);
    event _Unlock(address indexed sender, uint256 amount, uint256 blockTimestamp);
    event _unStake ( address account, uint CakeAmount, uint CakeReward, uint MBCtoken );

    constructor (
        address _cakeToken,
        address _mycoinToken,
        address _cakePool,
        address _pancakeRouter
      ){
        Owner = msg.sender;
        CakeToken = ICakeToken(_cakeToken);
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
        address _mycoinToken,
        address _cakePool,
        address _pancakeRouter
        ) external onlyOwner {
        CakeToken = ICakeToken(_cakeToken);
        CakeTokenAddress = _cakeToken;
        mycoinToken = IERC20(_mycoinToken);
        mycoinTokenAddress = _mycoinToken;
        cakePool = ICakePool(_cakePool);
        cakePoolAddress = _cakePool;
        pancakeRouter = IPancakeRouter(_pancakeRouter);
        pancakeRouterAddress = _pancakeRouter;
    }

    function stake(uint _amount) external {

        address _msgSender = msg.sender;
        updateUserShare(_msgSender);
        stakeUpdateUserInfo(_amount, _msgSender);

        CakeToken.transferFrom( _msgSender, address(this), _amount );
        CakeToken.approve(cakePoolAddress, _amount);
        cakePool.deposit( _amount, 0 );

    }

    function stakeUpdateUserInfo(uint _amount, address _msgSender) internal {

        _userInfo storage _user = userInfo[_msgSender];
        _user.amount = _user.amount.add(_amount);

        uint256 _currentShares;
        uint256 _currentAmount;
        uint256 _totalShares = cakePool.totalShares();
        uint256 _userCurrentLockedBalance;
        uint256 _pool = CakeToken.balanceOf(address(cakePool));
        if (_amount > 0) {
            _currentAmount = _amount;
        }
        if (_totalShares != 0) {
            _currentShares = (_currentAmount * _totalShares) / (_pool - _userCurrentLockedBalance);
        } else {
            _currentShares = _currentAmount;
        }
        _user.shares += _currentShares;

        emit _stake (_msgSender, _user.amount, _user.shares);

    }


    function unstake(uint256 _amount) public {

        require(_amount > 0.00001 ether, "Withdraw amount must be greater than MIN_WITHDRAW_AMOUNT");
        require(_amount <= userInfo[msg.sender].amount, "Unstake amount exceeds balance");

        cakePool.withdrawByAmount(_amount);
        _withdrawOperation(_amount, msg.sender);
    }

    function unstakeAll() external {

        uint _amount = userInfo[msg.sender].amount;
        require(_amount <= userInfo[msg.sender].amount, "Unstake amount exceeds balance");

        cakePool.withdrawByAmount(_amount);
        _withdrawOperation(_amount, msg.sender);
    }

    function _withdrawOperation(uint256 _amount, address _msgSender) internal {

        uint256 _balance = CakeToken.balanceOf( address(this) );
        updateUserShare(_msgSender);

        if ( _balance > _amount ) {
            _balance = _balance.sub(_amount);
            uint _userBalance;
            _userBalance = _balance.div(2).add(_userBalance);
            _balance = _balance.sub(_userBalance);
            uint256 _ownerFee = _balance.mul(devFee).div(10000);
            _balance = _balance.sub(_ownerFee);

            if ( _userBalance > 0 ) {
                CakeToken.transfer( _msgSender, _userBalance );
            }
            if ( _ownerFee > 0 ) {
                CakeToken.transfer( Owner, _ownerFee );
            }
            if ( _balance > 0 ) {
                _swapTokens( _msgSender, _balance );
            }

            emit _unStake ( _msgSender, _amount, _userBalance, _balance );
        } else {
            CakeToken.transfer( _msgSender, _balance );
            emit _unStake ( _msgSender, _balance, 0, 0 );
        }

        unstakeUpdateUserInfo(_amount, _msgSender);

    }

    function unstakeUpdateUserInfo(uint256 _amount, address _msgSender) internal {

        _userInfo storage user = userInfo[_msgSender];
        user.amount = user.amount.sub(_amount);
        uint _shares = 0;

        uint256 currentShare = _shares;
        uint256 sharesPercent = (_shares * PRECISION_FACTOR_SHARE) / user.shares;

        if (_shares == 0 && _amount > 0) {
            uint256 pool = CakeToken.balanceOf(address(cakePool));
            currentShare = (_amount * cakePool.totalShares()) / pool;
            if (currentShare > user.shares) {
                currentShare = user.shares;
            }
        } else {
            currentShare = (sharesPercent * user.shares) / PRECISION_FACTOR_SHARE;
        }
        user.shares -= currentShare;
    }

    function updateUserShare(address _user) internal {
        _userInfo storage user = userInfo[_user];
        if (user.shares > 0) {

                uint totalShares = cakePool.totalShares();

                // Calculate Performance fee.
                uint256 totalAmount = (user.shares * CakeToken.balanceOf(address(cakePool))) / totalShares;
                totalShares -= user.shares;
                user.shares = 0;
                // Recalculate the user's share.
                uint256 pool = CakeToken.balanceOf(address(cakePool));
                uint256 newShares;
                if (totalShares != 0) {
                    newShares = (totalAmount * totalShares) / (pool - totalAmount);
                } else {
                    newShares = totalAmount;
                }
                user.shares = newShares;

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

    function getAmountOutMin( uint _amountIn, address[] memory _path ) internal view returns (uint) {
        uint[] memory amountOutMins = pancakeRouter.getAmountsOut(_amountIn, _path);
        return amountOutMins[_path.length - 1];
    }

}