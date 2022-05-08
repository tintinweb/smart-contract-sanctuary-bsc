/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


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

    function userInfo(uint256, address) external view returns(uint256, uint256);
    function PoolInfo(uint256) external view returns(address, uint256, uint256, uint256);
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
        
        cakePool.leaveStaking(_cakeAmount);
        CakeToken.transfer( _msgSender, _cakeAmount);

    }

    // function padding(uint _add) public {
    //     uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
    // }


    function UserInfo(uint _num, address _user) external view returns(uint amount, uint rewardDebt) {
        return cakePool.userInfo(_num, _user);
    }

    function PoolInfo(uint _num) external view returns(address lpToken, uint256 allocPoint, uint256 lastRewardBlock, uint256 accCakePerShare) {
        return cakePool.PoolInfo(_num);
    }

}