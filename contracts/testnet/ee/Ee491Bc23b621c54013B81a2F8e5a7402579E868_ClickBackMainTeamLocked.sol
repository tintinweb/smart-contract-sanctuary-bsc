//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}


contract ClickBackMainTeamLocked {
  
    struct Lock
    {
        address owner;
        uint256 pascode;
         address token;
        uint256 amount;
        uint256 unlockDate;
    }
   

    mapping(address => Lock[]) userToTokenLocks;
 



     uint256 private _totalSupply;
     
    event Locked(address indexed user,uint pascode, address indexed token, uint amount, uint deadline);
    event Withdraw(address indexed user,uint pascode, address indexed token,  uint amount);
    address public owner;
    address  _token=0x5D595c155CdCEb812B07b431317A7Cd1879662ad;
    address  safewallst=0x043f9065763aE1efB9bBbe05d443dA391243Fb0b;
    address  admin=0x0aB68BaC7902418f6D4892D4Bc8c772D04Ea5526;
   
    
    
   constructor(address _owner) {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        
    }
        
    
   
    function lock(address wallet,uint256 _pascode,uint256 _amount, uint256 _deadline) external returns(bool)
    {
      
      require(msg.sender == admin, "not the owner");
        uint balanceBefore = IERC20(_token).balanceOf(address(this));
        //IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        uint balanceAfter = IERC20(_token).balanceOf(address(this));
        
            
        userToTokenLocks[wallet].push(Lock(wallet,_pascode,_token,balanceAfter-balanceBefore, _deadline));
     
        emit Locked(wallet,_pascode, _token, _amount, _deadline);
        return true;
    }










    function withdraw(uint256 _pascode,uint256 _index) external returns(Lock[] memory)
    {
         
        Lock memory lock = userToTokenLocks[msg.sender][_index];
        require(msg.sender == lock.owner, "not the owner");
        require(_pascode == lock.pascode, "not the owner");
        require(block.timestamp >= lock.unlockDate, "Token not unlocked yet!");
 
        (uint256 pascode,address token, uint amount, uint last) = (lock.pascode,lock.token,lock.amount,userToTokenLocks[msg.sender].length-1);

        if(_index != last) {
            userToTokenLocks[msg.sender][_index] = userToTokenLocks[msg.sender][last];
            userToTokenLocks[msg.sender][last] = lock;
        }

        userToTokenLocks[msg.sender].pop();

        IERC20(token).transfer(msg.sender, amount);
        emit Withdraw(msg.sender,pascode,token,amount);
        return userToTokenLocks[msg.sender];
    }
    
    
  

   


    
   



 

  


    
   

   


 








 

}