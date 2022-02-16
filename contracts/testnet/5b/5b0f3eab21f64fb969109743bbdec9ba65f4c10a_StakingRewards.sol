/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract StakingRewards {


    // IERC20 stakingTokenP1 = IERC20(0xcDb972E8c80c17AE6ecBb04f52517e938493b0ab); // wcro
    // IERC20 stakingTokenP2 = IERC20(0x956f4E92563b9Fb660F16Ab183F84B4535088931); // USDC
    // IERC20 stakingTokenPair = IERC20(0x587eEF75710CdFB9a67F95cD747E256D71130d11); // wcro-USDC
    // IERC20 rewardsToken = IERC20(0x076633F276863b9b7A4B499031931502B334995b); // Cronosphere (SPHERE)
    IERC20 lpToken = IERC20(0xAf5e8AA68dd1b61376aC4F6fa4D06A5A4AB6cafD);
    Staking lpStakeContract=Staking(0x61d777dC41Bb391c491a644974C18fC069Ad3e62);


 
    function stake(address _pid,uint256 _amount) public {
       lpToken.approve(0x61d777dC41Bb391c491a644974C18fC069Ad3e62, _amount);
       lpStakeContract.stake(_pid, _amount);
    }
    function unstake(address _pid,uint256 _amount) public {
        lpStakeContract.unstake(_pid, _amount);
    }

    
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

// interface Staking {
//    function  deposit(uint256 _pid, uint256 _amount, address _referrer) external;
//    function withdraw(uint256 _pid, uint256 _amount) external;
// }
interface Staking {
   function  stake(address _pid, uint256 _amount) external;
   function unstake(address _pid, uint256 _amount) external;
}