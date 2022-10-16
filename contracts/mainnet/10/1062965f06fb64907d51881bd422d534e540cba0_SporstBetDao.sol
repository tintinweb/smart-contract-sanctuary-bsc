/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}
interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    // don't need to define other functions, only using `transfer()` in this case
}
contract SporstBetDao {
  using SafeMath for uint256;
  address payable [] public BeterAddresses;
  address public owner;
  uint public BnbBet= 74*10**15;
  uint public BetUsd= 20*10**18;
  uint public BetSPM= 50*10**18;
  uint public ContractBusdBalance;
  uint public ContractUsdtBalance;
  uint public ContractBnbBalance;
  uint public ContractSpmBalance;
  uint[] public Percent = [5*10**18 , 10*10**18 , 15*10**18 , 20*10**18];
  address private DappWallet;
  address public usdtAddress;
  address public spmAddress;
  address public busdAddress;
  struct Account {
    bool exists;
    string [10] Data;
    uint BetCount;
    uint BnbBetAmount;
    uint SpmBetAmount;
    uint UsdtBetAmount;
    uint BusdBetAmount;
    uint UsdtBalance;
    uint BusdBalance;
    uint BnbBalance;
    uint SpmBalance;
    }
   mapping(address => Account) public accounts;
constructor(address _usdt, address _spm, address _busd,address _DappWallet) {
    usdtAddress =_usdt;
    spmAddress=_spm;
    busdAddress=_busd;
    DappWallet=_DappWallet;
    owner = msg.sender;
  }
function BetBnb(address _BeterAddress , string memory data) public payable returns(bool){
    require(msg.sender == _BeterAddress,"Only user can bet");
    require(accounts[_BeterAddress].BetCount<=10,"You have placed max bets");
    require(msg.value>= BnbBet,"Min bet amount is 20$");
    Account memory account;
    if(accounts[_BeterAddress].exists)
    {
    account = accounts[_BeterAddress];
    account.Data[account.BetCount]=data;
    account.BetCount+=1;
    account.BnbBetAmount+=msg.value;
    accounts[_BeterAddress]=account;
    return true;
    }
    account = Account(true,["","","","","","","","","",""],0,0,0,0,0,0,0,0,0);
    BeterAddresses.push(payable (_BeterAddress));
    account.exists = true;
    account.Data[account.BetCount]=data;
    account.BetCount+=1;
    account.BnbBetAmount+=msg.value;
    accounts[_BeterAddress]=account;
    return true;
}
function BetOtherCurrency(address _BeterAddress , string memory data , uint ammount, string memory currency) public returns(bool){
    require(msg.sender == _BeterAddress,"Only user can bet");
    require(accounts[_BeterAddress].BetCount<=10,"You have placed max bets");
    
    Account memory account;
    if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("USDT"))))
    {
        require(ammount>= BetUsd,"Min bet amount is 20$");
        IERC20 usdt = IERC20(address(usdtAddress));
        if(accounts[_BeterAddress].exists)
            {
                account = accounts[_BeterAddress];
                account.Data[account.BetCount]=data;
                account.BetCount+=1;
                account.UsdtBetAmount+=ammount;
                accounts[_BeterAddress]=account;
                
                
            // transfers USDT that belong to your contract to the specified address
                usdt.transferFrom(_BeterAddress, address(this),ammount);
                return true;
            }
            account = Account(true,["","","","","","","","","",""],0,0,0,0,0,0,0,0,0);
            BeterAddresses.push(payable (_BeterAddress));
            account.exists = true;
            account.Data[account.BetCount]=data;
            account.BetCount+=1;
            account.UsdtBetAmount+=ammount;
            accounts[_BeterAddress]=account;
            usdt.transferFrom(_BeterAddress, address(this),ammount);
            return true;

    }
     if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("BUSD"))))
    {
        require(ammount>= BetUsd,"Min bet amount is 20$");
        IERC20 busd = IERC20(address(busdAddress));
        if(accounts[_BeterAddress].exists)
            {
                account = accounts[_BeterAddress];
                account.Data[account.BetCount]=data;
                account.BetCount+=1;
                account.BusdBetAmount+=ammount;
                accounts[_BeterAddress]=account;
                
            
            // transfers USDT that belong to your contract to the specified address
                busd.transferFrom(_BeterAddress, address(this),ammount);
                return true;
            }
            account = Account(true,["","","","","","","","","",""],0,0,0,0,0,0,0,0,0);
            BeterAddresses.push(payable (_BeterAddress));
            account.exists = true;
            account.Data[account.BetCount]=data;
            account.BetCount+=1;
            account.BusdBetAmount+=ammount;
            accounts[_BeterAddress]=account;
            busd.transferFrom(_BeterAddress, address(this),ammount);
            return true;

    }
    if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("SPM"))))
    {
        require(ammount>= BetSPM,"Min bet amount is 20$");
        IERC20 spm = IERC20(address(spmAddress));
        if(accounts[_BeterAddress].exists)
            {
                account = accounts[_BeterAddress];
                account.Data[account.BetCount]=data;
                account.BetCount+=1;
                account.SpmBetAmount+=ammount;
                accounts[_BeterAddress]=account;
                
            
            // transfers USDT that belong to your contract to the specified address
                spm.transferFrom(_BeterAddress, address(this),ammount);
                return true;
            }
            account = Account(true,["","","","","","","","","",""],0,0,0,0,0,0,0,0,0);
            BeterAddresses.push(payable (_BeterAddress));
            account.exists = true;
            account.Data[account.BetCount]=data;
            account.SpmBetAmount+=ammount;
            account.BetCount+=1;
            accounts[_BeterAddress]=account;
            spm.transferFrom(_BeterAddress, address(this),ammount);
            return true;

    }
    return false;
    
}
function GetData(address _UserAddress ) external view returns( string[] memory){
    uint n = accounts[_UserAddress].BetCount;
    string[] memory array = new string[](n);
    for (uint i = 0; i < n; i++)
            array[i] = accounts[_UserAddress].Data[i];
    return array;
   
}
function remove(uint index, string[10] memory array) internal pure returns(string[10] memory) {
        if (index >= array.length) return array;

        for (uint i = index; i<array.length-1; i++){
            array[i] = array[i+1];
        }
        delete array[array.length-1];
        return array;
    }

function CheckWin(address _UserAddress , bool check, uint _amount , uint _type, string memory currency, uint index) public returns(bool){
    require(accounts[_UserAddress].exists,"You have not placed any bet yet");
    require(msg.sender==DappWallet,"Only user can run");
    Account memory account;
    account = accounts[_UserAddress];
    if(check)
    {
        if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("USDT"))))
        {
            require(account.UsdtBetAmount>= BetUsd,"Min bet amount is 20$");
            account.UsdtBalance+=_amount.mul(_type);
            account.Data=remove(index,account.Data);
            account.UsdtBetAmount-=_amount;
            account.BetCount-=1;
        }
        else if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("BUSD"))))
        {
            require(account.BusdBetAmount>= BetUsd,"Min bet amount is 20$");
            account.BusdBalance+=_amount.mul(_type);
            account.Data=remove(index,account.Data);
            account.BusdBetAmount-=_amount;
            account.BetCount-=1;

        }
        else if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("SPM"))))
        {
            require(account.SpmBetAmount>= BetSPM,"Min bet amount is 20$");
            account.SpmBalance+=_amount.mul(_type);
            account.Data=remove(index,account.Data);
            account.SpmBetAmount-=_amount;
            account.BetCount-=1;

        }
        else if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("BNB"))))
        {
            require(account.BnbBetAmount>= BnbBet,"Min bet amount is 20$");
            account.BnbBalance+=_amount.mul(_type);
            account.Data=remove(index,account.Data);
            account.BnbBetAmount-=_amount;
            account.BetCount-=1;

        }
    }
    else if(!check)
    {
        uint balance;
        if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("USDT"))))
        {
            require(account.UsdtBetAmount>= BetUsd,"Min bet amount is 20$");
            if(_type==2)
                {
                    balance=Percent[0].mul(_amount).div(100*10**18);
                }
            else if(_type==3)
                {
                    balance=Percent[1].mul(_amount).div(100*10**18);   
                }
            else if(_type==4)
                {
                    balance=Percent[2].mul(_amount).div(100*10**18);
                }
            else if(_type==5)
                {
                    balance=Percent[3].mul(_amount).div(100*10**18);
                } 
            else if(_type==50)
                {
                    balance=_amount;
                } 
            else if(_type==100)
                {
                    balance=_amount;
                }        
                ContractUsdtBalance += balance;
                account.UsdtBalance += _amount.sub(balance);
                account.Data=remove(index,account.Data);
                account.UsdtBetAmount-=_amount;
                account.BetCount-=1;       
        }
        else if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("BNB"))))
        {
            require(account.BnbBetAmount>= BnbBet,"Min bet amount is 20$");
            if(_type==2)
                {
                    balance=Percent[0].mul(_amount).div(100*10**18);
                }
            else if(_type==3)
                {
                    balance=Percent[1].mul(_amount).div(100*10**18);
                }
            else if(_type==4)
                {
                    balance=Percent[2].mul(_amount).div(100*10**18);
                }
            else if(_type==5)
                {
                    balance=Percent[3].mul(_amount).div(100*10**18);
                } 
            else if(_type==50)
                {
                    balance=_amount;
                } 
            else if(_type==100)
                {
                    balance=_amount;
                }    
                ContractBnbBalance += balance;
                account.BnbBalance += _amount.sub(balance);
                account.Data=remove(index,account.Data);
                account.BnbBetAmount-=_amount;
                account.BetCount-=1;           
        }
        else if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("BUSD"))))
        {
            require(account.BusdBetAmount>= BetUsd,"Min bet amount is 20$");
            if(_type==2)
                {
                    balance=Percent[0].mul(_amount).div(100*10**18);
                    

                }
            else if(_type==3)
                {
                    balance=Percent[1].mul(_amount).div(100*10**18);
                    

                }
            else if(_type==4)
                {
                    balance=Percent[2].mul(_amount).div(100*10**18);
                    

                }
            else if(_type==5)
                {
                    balance=Percent[3].mul(_amount).div(100*10**18);
                    
                } 
            else if(_type==50)
                {
                    balance=_amount;
                    

                } 
            else if(_type==100)
                {
                    balance=_amount;
                    

                }       
                ContractBusdBalance += balance;
                account.BusdBalance += _amount.sub(balance);
                account.Data=remove(index,account.Data);
                account.BusdBetAmount-=_amount;
                account.BetCount-=1;        
        }
        else if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("SPM"))))
        {
            require(account.SpmBetAmount>= BetSPM,"Min bet amount is 20$");
            if(_type==2)
                {
                    balance=Percent[0].mul(_amount).div(100*10**18);
                }
            else if(_type==3)
                {
                    balance=Percent[1].mul(_amount).div(100*10**18);
                }
            else if(_type==4)
                {
                    balance=Percent[2].mul(_amount).div(100*10**18);                 
                }
            else if(_type==5)
                {
                    balance=Percent[3].mul(_amount).div(100*10**18);
                } 
            else if(_type==50)
                {
                    balance=_amount;
              } 
            else if(_type==100)
                {
                    balance=_amount;
                } 
                ContractSpmBalance += balance;
                account.SpmBalance += _amount.sub(balance);
                account.Data=remove(index,account.Data);
                account.SpmBetAmount-=_amount;
                account.BetCount-=1;              
        }
        

    }
    accounts[_UserAddress]=account;
  return true;
}
function UserWithdrawal(address _UserAddress) public returns(bool){
    require(msg.sender == _UserAddress,"Only user can withdraw");
    require(accounts[_UserAddress].exists,"You do not have any Balance");
    IERC20 usdt = IERC20(address(usdtAddress));
    usdt.transfer(_UserAddress,accounts[_UserAddress].UsdtBalance);
    IERC20 busd = IERC20(address(busdAddress));
    busd.transfer(_UserAddress,accounts[_UserAddress].BusdBalance);
    IERC20 spm = IERC20(address(spmAddress));
    spm.transfer(_UserAddress,accounts[_UserAddress].SpmBalance);
    payable(_UserAddress).transfer(accounts[_UserAddress].BnbBalance);
    Account memory account;
    account= accounts[_UserAddress];
    account.UsdtBalance = 0;
    account.BusdBalance = 0;
    account.SpmBalance = 0;
    account.BusdBalance = 0;

    return true;


}
function OwnerWithdrawal() public returns(bool){
    require(msg.sender == owner,"Only owner can withdraw");
    
    IERC20 usdt = IERC20(address(usdtAddress));
    usdt.transfer(owner,ContractUsdtBalance);
    IERC20 busd = IERC20(address(busdAddress));
    busd.transfer(owner,ContractBusdBalance);
    IERC20 spm = IERC20(address(spmAddress));
    spm.transfer(owner,ContractSpmBalance);
    payable(owner).transfer(ContractBnbBalance);
    ContractBnbBalance =0;
    ContractBusdBalance =0;
    ContractSpmBalance =0;
    ContractUsdtBalance=0;

    return true;


}
function TopUpBnb() public payable returns(bool){
    require(msg.value>0,"TopUp amount is too low");
    ContractBnbBalance += msg.value;
    return true;
}
function TopUpOtherCurrencies(string memory currency, uint _amount) public returns(bool)
{
    require(_amount>0,"Amount must be greater then zero");
    if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("BUSD"))))
    {
        IERC20 Busd = IERC20(address(spmAddress));
        Busd.transferFrom(msg.sender, address(this),_amount);
        ContractSpmBalance += _amount;
        return true;
    }
    if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("USDT"))))
    {
        IERC20 Usdt = IERC20(address(spmAddress));
        Usdt.transferFrom(msg.sender, address(this),_amount);
        ContractSpmBalance += _amount;
        return true;
    }
    if(keccak256(abi.encodePacked((currency))) == keccak256(abi.encodePacked(("SPM"))))
    {
        IERC20 spm = IERC20(address(spmAddress));
        spm.transferFrom(msg.sender, address(this),_amount);
        ContractSpmBalance += _amount;
        return true;

    }
    return false;

}


}