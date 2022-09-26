// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IFarm.sol";

contract AggFarm is IFarm{

    IFarm public immutable defiWzFarm;
    IFarm public immutable wzDaoFarm;

    constructor(IFarm wzDaoFarm_,IFarm defiWzFarm_){
        wzDaoFarm = wzDaoFarm_;
        defiWzFarm =  defiWzFarm_;
    }

    function getReward(address account) external  {
        wzDaoFarm.getReward(account);
        defiWzFarm.getReward(account);
    }

    function earned(address account) external view returns (uint256){
        return wzDaoFarm.earned(account) + defiWzFarm.earned(account);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IFarm{
    function getReward(address account) external;
    function earned(address account) external view returns (uint256);
}