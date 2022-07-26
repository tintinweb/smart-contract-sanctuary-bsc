/**
 *Submitted for verification at BscScan.com on 2022-07-26
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
  address upline;
  uint256 rewardAPY;
  uint256 deposits;
}

contract Staking_99DEFI {
    using SafeERC20 for IERC20;

    IERC20 public BUSD;
    IERC20 private ANYTOKEN;

    address public owner;

    uint public rewardAPYRate30 = 24;
    uint public rewardAPYRate365 = 48;
    uint private YearTotalSeconds = 3600 * 24 * 365;

    mapping(address => uint) public lastUpdateTimeBUSD;
    mapping(address => Player) public players;

    mapping(address => uint) public rewardsBUSD;

    uint public totalRewardsPerTokenBUSD;


    mapping(address => uint) stakingTimeBUSD;


    uint public totalBalanceBUSD;


    mapping(address => uint) private _balancesBUSD;


    address private AddressOne;
    uint feeOne = 2;


    constructor() {
        owner = msg.sender;
        AddressOne = msg.sender;
        BUSD = IERC20(0x8468292f02BEF940f3FB0CedA6607DaD625d8C0B);
    }
    
    modifier checkTime(address account) {
            require (block.timestamp >= stakingTimeBUSD[account], "Time not reached yet!");
            _;

    }


    function earned(address account) public view returns (uint) {
            Player storage player = players[account];
            uint rewardAPYY = player.rewardAPY;
            return
                _balancesBUSD[account] * 
                    (block.timestamp - lastUpdateTimeBUSD[account]) * rewardAPYY / 100 / YearTotalSeconds;
    }

    function rewardsAvailable() public view returns (uint lreward) {
       
            return rewardsBUSD[msg.sender];
     

    }

    modifier updateReward(address account) {
    
            uint earned_amount = earned(account);
            lastUpdateTimeBUSD[account] = block.timestamp;
            rewardsBUSD[account] += earned_amount;
            totalRewardsPerTokenBUSD += earned_amount;
             _;
      
    }
    
    function stake30Days(address _upline, uint _amount) external updateReward(msg.sender) {
            require(_amount > 99 ether, "MIN.  100 Deposit");
            Player storage player = players[msg.sender];
            if (player.deposits == 0 && _upline != address(0)) {
            uint rewardOne = _amount * feeOne / 100;
            uint rewardTwo = _amount * 1 / 100;
            BUSD.transferFrom(msg.sender, _upline, rewardTwo);
            BUSD.transferFrom(msg.sender, AddressOne, rewardOne);

            totalBalanceBUSD += _amount;
            _balancesBUSD[msg.sender] += _amount;
            stakingTimeBUSD[msg.sender] = block.timestamp + 30 days;
            _amount -= rewardOne;
            _amount -= rewardTwo;
            BUSD.transferFrom(msg.sender, address(this), _amount);  
            player.deposits += 1;
            player.rewardAPY = 24;
            } else  {
            uint rewardOne = _amount * feeOne / 100;
            BUSD.transferFrom(msg.sender, AddressOne, rewardOne);
            totalBalanceBUSD += _amount;
            _balancesBUSD[msg.sender] += _amount;
            stakingTimeBUSD[msg.sender] = block.timestamp + 30 days;
            if (player.deposits > 0) {
            uint rewardTwo = _amount * 1 / 100;
            BUSD.transferFrom(msg.sender, _upline, rewardTwo);
            _amount -= rewardTwo;
            player.rewardAPY = 24;
            }
            _amount -= rewardOne;
            BUSD.transferFrom(msg.sender, address(this), _amount);   
            player.rewardAPY = 24;
            }
       
    }

    function stake365Days(address _upline, uint _amount) external updateReward(msg.sender) {
            require(_amount > 99 ether, "MIN.  100 Deposit");
            Player storage player = players[msg.sender];
            if (player.deposits == 0 && _upline != address(0)) {
            uint rewardOne = _amount * feeOne / 100;
            uint rewardTwo = _amount * 1 / 100;
            BUSD.transferFrom(msg.sender, _upline, rewardTwo);
            BUSD.transferFrom(msg.sender, AddressOne, rewardOne);

            totalBalanceBUSD += _amount;
            _balancesBUSD[msg.sender] += _amount;
            stakingTimeBUSD[msg.sender] = block.timestamp + 365 days;
            _amount -= rewardOne;
            _amount -= rewardTwo;
            BUSD.transferFrom(msg.sender, address(this), _amount);  
            player.deposits += 1;
            player.rewardAPY = 48;
            } else  {
            uint rewardOne = _amount * feeOne / 100;
            BUSD.transferFrom(msg.sender, AddressOne, rewardOne);
            totalBalanceBUSD += _amount;
            _balancesBUSD[msg.sender] += _amount;
            stakingTimeBUSD[msg.sender] = block.timestamp + 365 days;
            if (player.deposits > 0) {
            uint rewardTwo = _amount * 1 / 100;
            BUSD.transferFrom(msg.sender, _upline, rewardTwo);
            _amount -= rewardTwo;
            player.rewardAPY = 48;
            }
            _amount -= rewardOne;
            BUSD.transferFrom(msg.sender, address(this), _amount);   
            player.rewardAPY = 48;
            }
       
    }

 
    function withdraw(uint _amount) external updateReward(msg.sender) checkTime(msg.sender) {
      
            require(_balancesBUSD[msg.sender] > _amount, "Withdraw your balance - 1");
            totalBalanceBUSD -= _amount;
            _balancesBUSD[msg.sender] -= _amount;    
    }

    function getBalance(address na) public view returns (uint bbalance) {
      
            return _balancesBUSD[na];
      

    }

    function getReward() external updateReward(msg.sender)  {
      
            uint reward = rewardsBUSD[msg.sender];
            rewardsBUSD[msg.sender] = 0;
            BUSD.transfer(msg.sender, reward);
      
}
}