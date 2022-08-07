/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// File: contracts/staking standard.sol


pragma solidity ^0.8.4;


interface Staking_Standard {

    function deposit(address tokenAddress,address userAddress, uint256 amount) external;
    function withdraw(address tokenAddress,address userAddress, uint256 amount) external ;
    function pendingReward(address account) external view returns (uint256);
    function autoCompound(address tokenAddress, uint256 amount) external returns (uint256);
}

interface ERC20 {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface Push_Interface {

    function deposit(address tokenAddress, uint256 amount) external;
    function withdraw(address tokenAddress, uint256 amount) external ;
    function balanceOf(address user, address token) external view returns (uint256) ;

}

interface IYieldFarm {
    function massHarvest() external returns (uint);
}

contract Push_Staking is Staking_Standard{
    Push_Interface push ;
    IYieldFarm yield ;
    
    constructor(address _pushStake, address _yieldAddress) {
        push = Push_Interface(_pushStake);
        yield = IYieldFarm(_yieldAddress);
    }

    // deposit
     function deposit(address tokenAddress,address userAddress, uint256 amount) public virtual override{
         ERC20(tokenAddress).approve(address(push),amount);
         push.deposit(tokenAddress, amount);
     }

    // withdraw
     function withdraw(address tokenAddress, address userAddress, uint256 amount) public virtual override {
        push.withdraw(tokenAddress, amount);
        ERC20(tokenAddress).transfer(userAddress,amount);
    }
     
    // reward
    function pendingReward(address account) public virtual override view returns (uint256){
        
    }

    // autocompound
    function autoCompound(address tokenAddress, uint256 amount) public virtual override returns (uint256){
        yield.massHarvest();
        uint pushBalance = ERC20(tokenAddress).balanceOf(address(this));
        ERC20(tokenAddress).approve(address(push),pushBalance);
        push.deposit(tokenAddress, pushBalance);
        return pushBalance;
    }


}