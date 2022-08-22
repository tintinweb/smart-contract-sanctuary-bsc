/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;


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
        
        
        

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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
        
        
        
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
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
pragma solidity ^0.8;


struct Player {
  address organi;
  address wallet;
  uint256 list;
  uint256 amount;
  uint256 da;
}

struct Organization {
  address boss;
  string name;
  uint256 capital;
  uint256 exist;
}

contract SalaryRahi {
    using SafeERC20 for IERC20;

    IERC20 private ANYTOKEN;
    IERC20 public BUSD;
    address public owner;
    mapping(address => Player) public players;
    mapping(address => Organization) public organizations;
    mapping(address => uint) private _balancesBUSD;
    mapping(address => uint) public rewardsBUSD;
    mapping(address => uint) public lastUpdateTimeBUSD;
    mapping(address => uint) stakingTimeBUSD;
    uint private YearTotalSeconds = 3600 * 24;
    constructor() {
        owner = msg.sender;
        BUSD = IERC20(0x308079C9c0Ed2a7C1EAa43E81613C1E94B18aE65);
    }
    

    function transferAnyERC20Tokens(address _tokenAddress, uint256 _amount) public  {
        require(msg.sender == owner, "You are not allowed to do this!");
        ANYTOKEN = IERC20(_tokenAddress);
        ANYTOKEN.safeTransfer(msg.sender, _amount);
    }

    function createOrganization (string memory _name, uint256 _capital)  public {
        Organization storage organization = organizations[msg.sender];
        require(organization.exist != 1, "You have already an organization with this address");
        if (_capital > 0) {
            BUSD.transferFrom(msg.sender, address(this), _capital);
            organization.capital += _capital;
            organization.boss = msg.sender;
            organization.name = _name;
            organization.exist = 1;
        } else {
            organization.capital = 0;
            organization.boss = msg.sender;
            organization.name = _name;  
            organization.exist = 1; 
        }
        //we can add here a fee tax on organization create.
    }

    function depositCapitalOrganization (uint256 _capital) public {
        Organization storage organization = organizations[msg.sender];
        require(organization.boss == msg.sender, "You are not the boss!");
        require(_capital > 0, "Please deposit a capital bigger than zero!"); 
        BUSD.transferFrom(msg.sender, address(this), _capital);
        //we can add here a fee tax on capital deposits.
    }
  
    function earned(address account) public view returns (uint) { 
        if (players[account].da == 0)
            return 0;
        return
            _balancesBUSD[account] * 
                (block.timestamp - lastUpdateTimeBUSD[account]) / (YearTotalSeconds * players[account].da);

    } 
        
     modifier updateReward(address account) {
   
        uint earned_amount = earned(account);
        lastUpdateTimeBUSD[account] = block.timestamp;
        rewardsBUSD[account] += earned_amount;
        

        _;
    }
    function DepositForEmployer(address _wallet, uint _amount, uint256 _da)  external updateReward(_wallet) {
        Player storage player = players[_wallet];
        require(organizations[msg.sender].exist > 0, "Need to create organization!");
        require(_amount > 0, "Deposit can't be 0");
        require(_da > 0, "At least 1 day");
        player.wallet = _wallet;
        player.amount += _amount;
        player.organi = msg.sender;
        player.da = _da;
        uint256 TotalDays = _da * 1 days; 
        _balancesBUSD[_wallet] += _amount;
        stakingTimeBUSD[_wallet] = block.timestamp + TotalDays;
        lastUpdateTimeBUSD[_wallet] = block.timestamp;
        if (organizations[msg.sender].capital >= _amount) {
            organizations[msg.sender].capital -= _amount;
        } else  {
            BUSD.transferFrom(msg.sender, address(this), _amount);
        }
    }

    function changeList(address _wallet, uint256 _list) public {
        require(msg.sender == players[_wallet].organi, "You are not the owner of the employer!!");
        players[_wallet].list = _list;
    }

    function returnList (address _wallet) public view returns (uint256 _list) {
        
        return players[_wallet].list;
    }

    function getBalance(address na) public view returns (uint bbalance) {
        
        return players[na].amount;
      
    }

    function getNameCompany(address na) public view returns (string memory nname) {
       
        return organizations[na].name;
      
    }

    

    modifier checkTime(address account) {
   
        require (block.timestamp <= stakingTimeBUSD[account], "Time it's over for your Salary!");
        _;
      
    }

    function getSalary() external updateReward(msg.sender) checkTime(msg.sender)  {
        require(players[msg.sender].list > 0, "You are in the blacklist!");
        uint reward = rewardsBUSD[msg.sender];
        rewardsBUSD[msg.sender] = 0;
        organizations[players[msg.sender].organi].capital -= reward;
        BUSD.transferFrom(address(this), msg.sender, reward);
    }
}