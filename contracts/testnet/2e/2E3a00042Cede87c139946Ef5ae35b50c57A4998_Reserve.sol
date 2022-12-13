//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}


contract Reserve {
   
    struct Lock
    {
        address owner;
        address token;
        uint256 amount;
        uint256 unlockDate;
    }
   
    mapping(address => Lock[]) userToTokenLocks;
     uint256 private _totalSupply;
    event Locked(address indexed user, address indexed token, uint amount, uint deadline);
    event Withdraw(address indexed user, address indexed token,  uint amount);
    address public owner;
     address public nominatedOwner;
      mapping (address => bool) private _isBlackList;
   constructor(address _owner) {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }
        
    
   
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
    
    
  

    function getLocksByaddress(address _user) public view returns(Lock[] memory){
        return userToTokenLocks[_user];
    }


      function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
   



   function nominateNewOwner(address _owner) external onlyOwner {
       
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

 modifier onlyOwner {
        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {
        require(msg.sender == owner, "Only the contract owner may perform this action");
    }


 function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

function addBlackList (address _evilUser) public onlyOwner {
        _isBlackList[_evilUser] = true;
    }
    
    function removeBlackList (address _clearedUser) public onlyOwner {
        _isBlackList[_clearedUser] = false;
    }

    function _getBlackStatus(address _maker) private view returns (bool) {
        return _isBlackList[_maker];
    }

  event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);


}