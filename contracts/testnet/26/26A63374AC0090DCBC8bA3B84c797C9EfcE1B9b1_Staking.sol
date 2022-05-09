/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
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
        return mod(a, b, 'SafeMath: modulo by zero');
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

interface ICakePool {
    function enterStaking(uint256 _amount) external;
    function leaveStaking(uint256 _amount) external;

}

interface IPancakeRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

contract Staking {

    IERC20 public CakeToken;
    IERC20 public mycoinToken;
    address public cakePoolAddress;
    ICakePool public cakePool;
    IPancakeRouter public pancakeRouter;

    constructor (
        address _cakeToken,
        // address _mycoinToken,
        address _cakePool
        // address _pancakeRouter
      ){
        CakeToken = IERC20(_cakeToken);
        // mycoinToken = IERC20(_mycoinToken);
        cakePool = ICakePool(_cakePool);
        cakePoolAddress = _cakePool;
        // pancakeRouter = IPancakeRouter(_pancakeRouter);
    }

    function stake(uint _cakeAmount) external {

        CakeToken.transferFrom(msg.sender, address(this), _cakeAmount);
        CakeToken.approve(cakePoolAddress, _cakeAmount);
        cakePool.enterStaking(_cakeAmount);

    }

    function unStake(uint _cakeAmount) external {
        
        address _msgSender = msg.sender;
        
        cakePool.leaveStaking( _cakeAmount );
        CakeToken.transfer( _msgSender, _cakeAmount );

        uint256 balance = CakeToken.balanceOf( address(this) );
        uint256 userBalance = ( balance / 2 );
        uint256 ownerBalance = ( balance / 2 );

        CakeToken.transfer( _msgSender, userBalance );
        CakeToken.transfer( _msgSender, ownerBalance );

    }

}