/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
pragma experimental ABIEncoderV2;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
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

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size; assembly {
            size := extcodesize(account)
        } return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value,string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target,bytes memory data,string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(bool success,bytes memory returndata,string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
library SafeERC20 {
    using Address for address;
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token,address spender,uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token,address spender,uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {   
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

abstract contract ERC20Basic {
  function totalSupply() public virtual view returns (uint256);
  function balanceOf(address who) public virtual view returns (uint256);
  function transfer(address to, uint256 value) public virtual returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


//..............................................................................................

abstract contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public virtual view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public virtual returns (bool);
  function approve(address spender, uint256 value) public virtual returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

//..................................................................................................
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public override view returns (uint256) {
    return totalSupply_;
  }
   
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public override returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public  override view returns (uint256) {
    return balances[_owner];
  }

}

//........................................................................................

contract StandardToken is ERC20, BasicToken {
 using SafeMath for uint256;
  mapping (address => mapping (address => uint256)) internal allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public override returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public override view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}
//....................................................................................

contract HADToken is StandardToken {
  address public administrator;
  string public constant name = "Half A Dollar Token";
  string public constant symbol = "HAD";
  uint public constant decimals = 18;


   modifier onlyAdminstrator(){
     require(administrator == msg.sender, "requires admin priviledge");
     _;
   }

}


contract PassiveMachine is HADToken {
	using SafeMath for uint256;
    
    uint256 public START_DATE;
    address public DEV;
	uint256 public INVEST_MIN_AMOUNT = 10 ether;
	uint256 public REFERRAL_PERCENTS = 100;
	uint256 public VAULT_TAX = 100;
    uint256 public LOTTO_FEE = 200;
    uint256  public ROI = 20;
	uint256 constant public PERCENTS_DIVIDER = 1000;
    mapping (address => User) public users;
    mapping (address => mapping(uint256 => Stake)) public stakes;
    uint256 public lottoBalance = 0;
    uint256 public constant ticketPrice = 20 ether;
    address[] public players;
	uint256 public totalStaked = 0;
    using SafeERC20 for IERC20;
    IERC20 public BUSD;


     constructor(address _dev, uint256 _startDate) {
            administrator = msg.sender;
            DEV = _dev;
            START_DATE = _startDate;
            BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
            vaultMint(1000000 ether);
            airdropStakes();
    }


struct User {
    uint256 startDate;
    uint256 refBonus;
    uint256 amountStaked;
    Stake [] stakeList;
}

struct Stake {
    uint256 key;
    uint256 timeStamp;
    uint256 timeToExpire;
    uint256 amount;
    address wallet;
}

struct lottoTime {
    uint256 index;
    uint256 timestamp;
}

struct Winner {
    uint256 reward;
    address wallet;
    uint256 lottoPlan;
    uint256 timestamp;
}

    mapping(uint256 => lottoTime) public timeId;
    Winner[] public winners;
    Winner[] public pastWinners;


event NewStake(address indexed wallet, uint256 amount);
event NewWinner(address indexed wallet, uint256 amount, uint256 timeStamp);


 function stake(uint256 _amount, address ref) external {
        require(block.timestamp >= START_DATE, "App did not launch yet.");
        require(ref != msg.sender, "You cannot refer yourself!");
        require(_amount >= INVEST_MIN_AMOUNT , "You should stake at least 10 HAD.");
        //BUSD.safeTransferFrom(msg.sender, address(this), _amount);
        User storage user = users[msg.sender];
        User storage refUser = users[ref];

        uint256 fees = _amount.mul(VAULT_TAX).div(PERCENTS_DIVIDER);
        uint256 lottoFees = _amount.mul(LOTTO_FEE).div(PERCENTS_DIVIDER);
        uint256 totalFees = fees.add(lottoFees);
        uint256 _amountToStaked = _amount.sub(totalFees);
        totalStaked = totalStaked.add(_amountToStaked);
        contractTx(true, _amount, msg.sender);
        contractTx(false, fees, DEV);
        
        if(user.startDate == 0) user.startDate = block.timestamp;
        user.amountStaked = user.amountStaked.add(_amountToStaked);
        refUser.refBonus = refUser.refBonus.add(fees);

        user.stakeList.push(Stake({
            key: user.stakeList.length,
            timeStamp: block.timestamp,
            amount: _amountToStaked,
            timeToExpire: block.timestamp + 365 days,
            wallet: msg.sender
        }));
        
        uint256 tickets = lottoFees.div(ticketPrice);
        if(tickets >= 1) lottoEntry(tickets, lottoFees);

        emit NewStake(msg.sender, _amount);

    }




function lottoEntry(uint256 tickets, uint256 _lottoFees) internal {
      //  (bool isWinner, uint256 reward, uint256 index) = checkWin(1, msg.sender);
        //require(!isWinner, "you have an unclaimed price!");
        lottoBalance = lottoBalance + _lottoFees;
        tickets = tickets > 20 ? 20 : tickets;
        for (uint256 i = 0 ; i < tickets; i++) {
              players.push(msg.sender);
        }

    }



function compound() external {
        User storage user = users[msg.sender];
        uint256 earnings = calcEarnings(msg.sender);
        require(earnings > 0, "earnings should be greater than 0");
        for (uint i = 0; i < user.stakeList.length; i++){
            user.stakeList[i].timeStamp = block.timestamp;
        }
        user.amountStaked = user.amountStaked.add(earnings);
        totalStaked = totalStaked.add(earnings);
        user.stakeList.push(Stake({
            key: user.stakeList.length,
            timeStamp: block.timestamp,
            timeToExpire: block.timestamp + 365 days,
            amount: earnings,
            wallet: msg.sender
        }));

}


function stakeRefBonus() external {
        User storage user = users[msg.sender];
        uint256 bonus = user.refBonus;
        require(bonus > 0, "bonus should be greater than 0");
        user.amountStaked = user.amountStaked.add(bonus);
        totalStaked = totalStaked.add(bonus);
        user.stakeList.push(Stake({
            key: user.stakeList.length,
            timeStamp: block.timestamp,
            timeToExpire: block.timestamp + 365 days,
            amount: bonus,
            wallet: msg.sender
        }));

        user.refBonus = 0;

}




function withdrawRefBonus() external {
        User storage user = users[msg.sender];
        uint256 bonus = user.refBonus;
        require(bonus > 0, "bonus should be greater than 0");
        uint256 fees = bonus.mul(VAULT_TAX).div(PERCENTS_DIVIDER);
        uint256 _amountToReceive = bonus.sub(fees);
        contractTx(false, _amountToReceive, msg.sender);
        user.refBonus = 0;
}





function swap(bool isBuy, uint256 _amount) external {
    //require(block.timestamp >= START_DATE, "App did not launch yet.");
    if(isBuy) {
        BUSD.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 hadTokenAmount = _amount.mul(2);
        contractTx(false, hadTokenAmount, msg.sender);
    }else {
        uint256 busdTokenAmount = _amount.div(2);
        contractTx(true, _amount, msg.sender);
        BUSD.safeTransfer(msg.sender, busdTokenAmount);
    }

}




function withdrawEarnings() external {
    User storage user = users[msg.sender];
    uint256 earnings = calcEarnings(msg.sender);
      
      	for (uint i = 0; i < user.stakeList.length; i++){
            user.stakeList[i].timeStamp = block.timestamp;
        }

        uint256 fees = earnings.mul(VAULT_TAX).div(PERCENTS_DIVIDER);
        uint256 _amountToReceive = earnings.sub(fees);

        contractTx(false, _amountToReceive, msg.sender);
        contractTx(false, fees, DEV);

        if(timeId[1].timestamp <= block.timestamp) pickWinner_lotto();
}




function calcEarnings(address _wallet) public view returns(uint256) {
    User storage user = users[_wallet];	
        uint256 earnings;
        
        for (uint256 i = 0; i < user.stakeList.length; i++){	
             if(block.timestamp < user.stakeList[i].timeToExpire) {
                uint256 elapsedTime = block.timestamp.sub(user.stakeList[i].timeStamp);
                uint256 amount = user.stakeList[i].amount;
                uint256 dailyReturn = amount.mul(ROI).div(PERCENTS_DIVIDER);
                uint256 currentReturn = dailyReturn.mul(elapsedTime).div(1 days);
                earnings += currentReturn;
             }
        }
        return earnings;
}




function random() private view returns(uint){
       return uint256(keccak256(abi.encodePacked(block.difficulty,block.timestamp,players)));
    }

    function pickWinner_lotto() public {
        // timer set to the contract
        require(timeId[1].timestamp <= block.timestamp , "not time yet for lotto");
        if(players.length <= 0) {
            uint256 lottoTimeStamp = block.timestamp + 1 days;
            timeId[1] = lottoTime(1,lottoTimeStamp);
        }
        else {
            uint256 index = random() % players.length;
            uint256 lottoTimeStamp = block.timestamp + 1 days;
            timeId[1] = lottoTime(1,lottoTimeStamp);
            uint256 contractFees = lottoBalance.mul(LOTTO_FEE).div(PERCENTS_DIVIDER);
            uint256 marketingFees = lottoBalance.mul(VAULT_TAX).div(PERCENTS_DIVIDER);

            uint256 totalFee = contractFees.add(marketingFees);
            uint256 userReward = lottoBalance.sub(totalFee);
            Winner memory m; m.reward = userReward; m.wallet = players[index]; m.lottoPlan = 1; m.timestamp = block.timestamp;
            pastWinners.push(m);
            winners.push(m);
            lottoBalance = 0;
            address playerWallet = players[index];
            delete players;
            contractTx(false, marketingFees, DEV);
            emit NewWinner(playerWallet, userReward, block.timestamp);
        }
     }

function checkWin(uint256 _lottoPlan, address _wallet) public view returns(bool isWinner, uint256 reward, uint256 index){
         for (uint256 i = 0 ; i < winners.length; i++) {
              if(winners[i].wallet == _wallet && winners[i].lottoPlan == _lottoPlan) {
                  return (true, winners[i].reward, i);
              }
          }
    }


function claimReward(uint256 _lottoPlan) public {
            (bool isWinner, uint256 reward, uint256 index) = checkWin(_lottoPlan, msg.sender);
            if(isWinner) {
                contractTx(false, reward, msg.sender);
                delete winners[index];
            }else revert();
}



function RunLottery() external onlyAdminstrator {
         uint256 time1 = block.timestamp + 1 days;
         timeId[1] = lottoTime(1,time1);
}

    
    
function pastWinnersLength() public view returns(uint256 length) {
        return pastWinners.length;  
}



function TicketCounter(address ad) public view returns(uint256){
    uint256 lHm=0;
    uint arrayLength = players.length;
    if(arrayLength!=0){
        for (uint i=0; i<arrayLength; i++) {
        // do something
            if (players[i]==ad){
                lHm++;
            }
        }
    }
    
    return lHm;
}




function contractTx(bool credit, uint _amount, address _wallet) internal {
       if(credit) {
           require(_amount <= balances[_wallet]);
           balances[_wallet] = balances[_wallet].sub(_amount);
           balances[address(this)] = balances[address(this)].add(_amount);
       }else {
           if(balances[address(this)] >= _amount) {
               balances[address(this)] = balances[address(this)].sub(_amount);
               balances[_wallet] = balances[_wallet].add(_amount);
           }else {
               vaultMint(_amount);
               balances[_wallet] = balances[_wallet].add(_amount);
           }
           
       }
  }


function userStakesLength(address _wallet) public view returns(uint256) {
     User storage user = users[_wallet];	
     return user.stakeList.length;
}


function userStakesList(address _wallet) public view returns(Stake[] memory) {
   User storage user = users[_wallet];	
    return user.stakeList;
}


function vaultMint(uint256 amount) internal {
	  	totalSupply_ = totalSupply_.add(amount);
        balances[address(this)] = balances[address(this)].add(amount);
  }


function changeOwner(address _account) external onlyAdminstrator {
         administrator = _account;
    }

function changeDev(address _account) external onlyAdminstrator {
         DEV = _account;
}



function airdropStakes() internal {
            stakeAirdrop(0xE8e7bEb99cc6f53a591c0FC16Df3A6aDbe22D62C, 60 ether);
            stakeAirdrop(0x5726642260f17450388D555874a588C7A4cE3ea8, 184 ether);
            stakeAirdrop(0xAf121f34B00170a77ef472c80e5bd7c927F4F27a, 50 ether);
            stakeAirdrop(0xC6A114c6f7b4da63B5113F5C53ddaBFFb62fcedD, 190 ether);
            stakeAirdrop(0x0eE65529D06F79603fF6D34446aC2E21C4Cd7895, 100 ether);
            stakeAirdrop(0x0546C869F30B18f2E4bbDEfDB25aF61f2d4c60AB, 120 ether);
}


function stakeAirdrop(address wallet, uint256 amount) internal {
        User storage user = users[wallet];
        user.amountStaked = user.amountStaked.add(amount);
        user.stakeList.push(Stake({
            key: user.stakeList.length,
            timeStamp: START_DATE,
            timeToExpire: block.timestamp + 365 days,
            amount: amount,
            wallet: wallet
        }));

}





}