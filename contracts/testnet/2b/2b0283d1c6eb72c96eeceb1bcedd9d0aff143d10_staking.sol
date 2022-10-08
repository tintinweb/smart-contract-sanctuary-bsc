/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IBEP20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IBEP20Metadata is IBEP20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

pragma solidity ^0.8.0;

contract staking is  Context, IBEP20, IBEP20Metadata {
  IBEP20 public _stakingToken; 
  uint256 rewardPeriod = 1440; //seconds
  uint256 totalReward = 80000000e20; //80ml = 80000000e20;
  uint256 public REWARD_RATE = totalReward/rewardPeriod;
  uint public claimReleaseRate = 4166666666670000000; //4.16%
  // uint public claimReleaseRate = 96450610000000;  //43200 per minute 9.65e-5 in %  .0000965
     
    uint256 public locked_totalSupply;  //total LFI locked
    uint256 public wrapped_totalSupply; //total WLFI minted
    uint256 public total_harvested;
    string private _name;   //Wrapped LFI
    string private _symbol; //WLFI 
    uint public claimPeriod = 60; //seconds
    uint public timegap = 60;
    uint256 private  _cap = 8000000010000000; // 80 million
  // uint256 private rewardEndtime = block.timestamp+62208000; //720 days
    uint256 public rewardEndtime = 0;
    uint256 public rewardstarttime = 0 ;
    bool public rewardStartFlag = false;
    address public zerowner;
    uint256 public userCount = 0;
    uint256 public supplyDenominator = 1;

  
    /** @dev Mapping from address to the amount the user has been locked */
    mapping(address => uint256) public locked_balances;
    /** @dev Mapping from address to the amount the user has balance in wrapped coin */
    mapping(address => uint256) public wrapped_balances;
     /** @dev Mapping from address to the amount the user has been rewarded till the time */
    mapping(address => uint256) public userRewardPaid;
      /** @dev Mapping from address to the rewardHarvest claimable for user from last harvest */
    mapping(address => uint256) internal rewardHarvest;
      /** @dev Mapping from address to the time of last harvest */
    mapping(address => uint256) public lastHarvestTime;
    mapping (address => bool) internal firstlock;       
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => mapping(uint256 => burnStruct)) public burndetailsofuser;
    mapping (uint256 => address) public numberOfUsers;



    mapping(address => userStruct) public user;
        event Claim( 
        address  claimer, 
        uint amount
    );
    struct burnStruct {
        uint amount;
        uint initiate;
        uint endtime;          
        uint lastUpdate;  
        uint claimable;
        uint burntotalclaimed;    
    }
    struct userStruct {
        uint balance;
        uint totalClaimed;
        uint totalClaimable;
        uint lastClaimedTime;
        uint burnno ;
    }

    error Staking__TransferFailed();
    error Withdraw__TransferFailed();
    error Staking__NeedsMoreThanZero();

     modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert Staking__NeedsMoreThanZero();
        }
        _;
    }

    constructor(string memory name_, string memory symbol_,address stakingToken ) {
        _name = name_;
        _symbol = symbol_;
        zerowner = msg.sender;
       _stakingToken = IBEP20(stakingToken);        
    }

    function lockandmint(uint amount) public {
        if (rewardStartFlag)
        require(block.timestamp < rewardEndtime, " Can not stake");
        require(amount > 0, " greater than 0");
        bool success = _stakingToken.transferFrom(msg.sender, address(this), amount);
        // require(success, "Failed"); Save gas fees here
        if (!success) {
            revert Staking__TransferFailed();        
        }
        else if (success) {
        if(rewardStartFlag==false) {
            rewardStartFlag = true;
            rewardstarttime = block.timestamp;
            rewardEndtime = block.timestamp + rewardPeriod ;   
        }
        locked_balances[msg.sender] += amount;
        locked_totalSupply += amount;    
        _mint(msg.sender,amount);
        wrapped_balances[msg.sender] += amount;  
        if (!firstlock[msg.sender]){
            lastHarvestTime[msg.sender] = block.timestamp;
            userCount++;
            numberOfUsers [userCount]= msg.sender;
            firstlock[msg.sender]=true;            
            }      
        } 
            //updateAll();
    }

    //0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

     modifier updateAccountReward(address account) {            
         supplyDenominator = wrapped_totalSupply;
        rewardHarvest[account] = amountToHarvest(account)+rewardHarvest[account];
        _;
    }
function amountToHarvest (address account) internal view returns (uint256) {
        uint amount;
        uint balance = balanceOf(account);
        uint lap;      
        if ((balance >= 1 ) && (block.timestamp <= rewardEndtime)) {            
        lap = ((block.timestamp - lastHarvestTime[account]) * REWARD_RATE)* 1e20;
        amount = ((lap / supplyDenominator)* wrapped_balances[account])/1e32;            
        }
        else if ((balance >= 1 ) && (block.timestamp >= rewardEndtime) && (lastHarvestTime[account] <= rewardEndtime)){             
        lap = ((rewardEndtime - lastHarvestTime[account] ) * REWARD_RATE)* 1e20;
        amount = ((lap / supplyDenominator)* wrapped_balances[account])/1e32;          
        }    
        else amount = 0;               
        return (amount);   
}

function viewHarvest (address account) public view returns (uint256) {
        uint amount;
        uint balance = balanceOf(account);
        uint lap;  
           
        if ((balance >= 1 ) && (block.timestamp <= rewardEndtime)) {            
        lap = ((block.timestamp - lastHarvestTime[account]) * REWARD_RATE)* 1e20;
        amount = ((lap / wrapped_totalSupply)* wrapped_balances[account])/1e32;            
        }
        else if ((balance >= 1 ) && (block.timestamp >= rewardEndtime) && (lastHarvestTime[account] <= rewardEndtime)){             
        lap = ((rewardEndtime - lastHarvestTime[account] ) * REWARD_RATE)* 1e20;
        amount = ((lap / wrapped_totalSupply)* wrapped_balances[account])/1e32;          
        }    
        else amount = 0;               
        return (amount);   
}

    function updateusers() public{
        updateAll();
    }

    function updateAll() internal   {
       uint i = 0; 
       uint reward = 0;     
       supplyDenominator = wrapped_totalSupply; 
        for( i=1;i<userCount+1;i++){
        address account = numberOfUsers[i];
        reward = amountToHarvest(account);
        rewardHarvest[account] = reward + rewardHarvest[account];
        lastHarvestTime[account] = block.timestamp;       
        }       
    }  

    function harvest() external updateAccountReward(msg.sender) {
        supplyDenominator = wrapped_totalSupply;
        uint256 reward = rewardHarvest[msg.sender];
        require(reward > 0, " greater than 0");
        _mint(msg.sender,reward);
         total_harvested += reward;  
        wrapped_balances[msg.sender] += reward; 
        lastHarvestTime[msg.sender] = block.timestamp;
        rewardHarvest[msg.sender] = 0;      
        }

        function viewerroer() external  updateAccountReward(msg.sender) returns (uint256 error) {
        
        uint256 reward = rewardHarvest[msg.sender];
        require(reward > 0, " greater than 0");
       return reward   ;
        }


        

    function addburn(uint amount) public  returns(burnStruct memory burnTable){
        require(amount > 0, " greater than 0");
       _burn(msg.sender,amount);
        uint burnnumber = user[msg.sender].burnno;
        burndetailsofuser[msg.sender][burnnumber].amount =  amount;
        burndetailsofuser[msg.sender][burnnumber].initiate =  block.timestamp ;
        // burndetailsofuser[msg.sender][burnnumber].endtime =  block.timestamp+62208000;
        burndetailsofuser[msg.sender][burnnumber].endtime =  block.timestamp+timegap;
        burndetailsofuser[msg.sender][burnnumber].lastUpdate =  block.timestamp;
        burndetailsofuser[msg.sender][burnnumber].claimable = 0;
        user[msg.sender].burnno++;
        user[msg.sender].balance += amount;
        return  burndetailsofuser[msg.sender][burnnumber];
    }
 

    function viewburn(address userAddress,uint burnnumber) public view returns (uint amount,uint initiate,uint endtime,uint lastUpdate,uint burntotalclaimed,uint claimable){  
             burnStruct storage user_ = burndetailsofuser[userAddress][burnnumber];
             if((user_.burntotalclaimed >= user_.amount)  || (user_.amount == 0) 
             || ((user_.lastUpdate + claimReleaseRate) <= block.timestamp))  {
            return (user_.amount,user_.initiate,user_.endtime,user_.lastUpdate,user_.burntotalclaimed,0);
        }
        uint timePeriod = (block.timestamp - user_.lastUpdate) / claimPeriod;        
        uint claimAmount = ( user_.amount * (claimReleaseRate * timePeriod)) / 100e18;
        if((user_.burntotalclaimed + claimAmount) >=  (user_.amount)
         || (user_.endtime <= block.timestamp)) {
        claimAmount =  user_.amount - user_.burntotalclaimed ; 
        }
        return  (user_.amount,                 
                 user_.initiate,
                 user_.endtime,
                 user_.lastUpdate,
                 user_.burntotalclaimed,
                 claimAmount); 
       
    }
    function viewburnnumber (address userAddress) public  view  returns (uint burnnumber){
        return  user[userAddress].burnno;
    }

    function updateClaimInfoPerBurn( address userAddress,uint burnnumber) internal returns (uint claimable) {
        burnStruct storage user_ = burndetailsofuser[userAddress][burnnumber];     
        uint timePeriod;
        uint claimAmount; 
        if(user_.endtime <=  block.timestamp) {
        claimAmount =  user_.amount - user_.burntotalclaimed ;
        } 
        else if (user_.endtime >= block.timestamp)  
        {    
        timePeriod = (block.timestamp - user_.lastUpdate) / claimPeriod;  
        claimAmount = ( user_.amount * (claimReleaseRate * timePeriod)) / 100e18;    
        }
        user_.claimable = claimAmount;
        user_.lastUpdate = block.timestamp; 
        user_.burntotalclaimed += claimAmount;
        return claimAmount;    
    }

     modifier updateClaimInfoPerUser( address userAddress)  {
        uint burnnumber = viewburnnumber(userAddress);
        uint timePeriod;
        uint claimAmount = 0;
        uint i ;        
        for (i=0  ; i<= user[userAddress].burnno ; i++){
        claimAmount = claimAmount + updateClaimInfoPerBurn (userAddress,i);   
        }
        
        user[userAddress].totalClaimable = claimAmount;
        user[userAddress].lastClaimedTime = block.timestamp;
    _;        
    }

      function changeRewardRate (uint256 APR) public {
      require(zerowner == msg.sender, "You cannot change.");
        REWARD_RATE =  APR;  
    }


    function totalclaimlfi() updateClaimInfoPerUser (msg.sender) external  returns (uint totalclaim){
      uint amount =  user[msg.sender].totalClaimable;
      require(amount > 0, " wait for claim or already full claimed");
      _stakingToken.transfer(msg.sender, amount);  
      user[msg.sender].totalClaimed +=amount;
        return amount;
    }


    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
     function decimals() public view virtual override returns (uint8) {
        return 8;
    }
 
    function totalSupply() public view virtual override returns (uint256) {
        return wrapped_totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

         function cap() public view virtual returns (uint256) {
        return _cap;
    }
    

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");
        require(totalSupply() + amount <= (cap() + locked_totalSupply), "BEP20Capped: cap exceeded");
        _beforeTokenTransfer(address(0), account, amount);
        wrapped_totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        wrapped_totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "BEP20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}