//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}


contract Timelock {
   
    struct Lock
    {
        address owner;
        address token;
        uint256 amount;
        uint256 unlockDate;
    }
   
    mapping(address => Lock[]) userToTokenLocks;

    event Locked(address indexed user, address indexed token, uint amount, uint deadline);
    event Withdraw(address indexed user, address indexed token,  uint amount);
   
    constructor(){}
   
    function lockToken(address _token, uint256 _amount, uint256 _deadline) external returns(bool)
    {
        //before and after balance to prevent _amount of being higher than the final receiving amount due to tokenomics such as fee on transfer
        uint balanceBefore = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        uint balanceAfter = IERC20(_token).balanceOf(address(this));
        
        userToTokenLocks[msg.sender].push(Lock(msg.sender, _token, balanceAfter-balanceBefore, _deadline));     
        
        emit Locked(msg.sender, _token, _amount, _deadline);
        return true;
    }

    function withdraw(uint256 _index) external returns(Lock[] memory)
    {
        Lock memory lock = userToTokenLocks[msg.sender][_index];
        require(msg.sender == lock.owner, "not the owner");
        require(block.timestamp >= lock.unlockDate, "Token not unlocked yet!");

        (address token, uint amount, uint last) = (lock.token,lock.amount,userToTokenLocks[msg.sender].length-1);

        if(_index != last) {
            userToTokenLocks[msg.sender][_index] = userToTokenLocks[msg.sender][last];
            userToTokenLocks[msg.sender][last] = lock;
        }

        userToTokenLocks[msg.sender].pop();

        IERC20(token).transfer(msg.sender, amount);
        emit Withdraw(msg.sender,token,amount);
        return userToTokenLocks[msg.sender];
    }
    
    
    function getLocks() public view returns(Lock[] memory)  {
        return userToTokenLocks[msg.sender];
    }

    function getLocksByUser(address _user) public view returns(Lock[] memory){
        return userToTokenLocks[_user];
    }
   
}