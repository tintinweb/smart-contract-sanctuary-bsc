/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

// SPDX-License-Identifier: MIT
//testnet
pragma solidity ^0.8.15;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
      return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
      return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

contract AtomilkLottery is Ownable {
  
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    //address public dev;
    event Executed(address indexed from, uint256 indexed num_extract, uint256 is_win, uint256 win);
    
    uint256 private nonce = 0;
    uint256 private next_extraction = 0;    
    Bet [] private _history;    
    
    uint256 public hist_max_length = 20;
    uint256 public dev_fee_perc = 0; //2%
    uint256 public num_extractions = 0;
   
    IERC20 public BUSD;    
    
    struct Bet {
      uint256 index;
      uint256 timestamp;
      address account;
      uint256 amount;
      uint256 extraction;
      uint64 is_win;
      uint256 win;
    }
    
    enum PARAM { 
      DEV_FEE_PERC, //0
      HIST_MAX_LENGTH //1
    }    

    constructor(bool mainnet) {
      //dev = _msgSender(); 
      if(mainnet) {
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
      } else {
        BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
      }
      random();
    }

    function changeParams(PARAM what, uint256 value) external onlyOwner returns ( bool )  {
      if(what == PARAM.DEV_FEE_PERC) {
        require(value >= 0 && value <= 10, "Max fee is 10%");
        dev_fee_perc = value;
      } else if(what == PARAM.HIST_MAX_LENGTH) {
        require(value >= 1 && value <= 50, "Max history length is 50");
      } else {
        return false;
      }
      return true;
    }

    function exec(uint256 amount, uint256 num_possib) external returns(Bet memory __bet) {
      uint64 min_bet = uint64(amount.div(num_possib).div(1e18));
      require(amount >= 10*1e18 && amount <= 500*1e18 && num_possib >= 1 && num_possib <= 10 && (min_bet == 10 || min_bet == 20 || min_bet == 30 || min_bet == 40 || min_bet == 50), 'wrong bet');
      
      num_extractions++;
      
      Bet memory _bet = Bet({
        index: num_extractions,
        timestamp: block.timestamp,
        account: _msgSender(),
        amount: amount,
        extraction: random(),
        is_win: 0,
        win: 0
      });

      //uint256 interval_win = num_possib; //(20*prob_win_perc)/100;
      uint256 win_mul = 30 - 2*(num_possib - 1); //from x3 to x1.2
      
      BUSD.safeTransferFrom(msg.sender, owner(), amount);

      if(_bet.extraction <= num_possib) {
        uint256 win_raw = amount.mul(win_mul).div(10);
        uint256 fee = win_raw.mul(dev_fee_perc*10).div(1000);
        _bet.win = win_raw.sub(fee);

        BUSD.safeTransferFrom(owner(), msg.sender, _bet.win);
        //BUSD.transfer(_owner, fee);
        _bet.is_win = 1;
      }
      
      _history.push(_bet);
      
      if(_history.length > hist_max_length) {
        shiftHistory();
      }
      emit Executed(_bet.account, _bet.extraction, _bet.is_win, _bet.win);
      return (_bet);      
    }
    
    function getHistory() external view returns(Bet [] memory bets) {
      return _history;
    }

    function getExtraction() external view onlyOwner returns(uint256) {
      return next_extraction;
    }
    
    function resetNonce() external onlyOwner {
      nonce = 0;
    }
    
    function resetNumExtraction() external onlyOwner {
      num_extractions = 0;
    }
    
    function resetHistory() external onlyOwner {
      delete _history;
    }

    function random() internal returns(uint256) {
      uint256 extraction = next_extraction;
      next_extraction = uint256(keccak256(abi.encodePacked(block.timestamp,abi.encodePacked(block.difficulty, msg.sender),nonce)));
      next_extraction = (next_extraction % 20)+1;
      nonce += next_extraction;
      return extraction;
    }
        
    function shiftHistory() internal {
      for(uint i = 0; i < _history.length-1; i++){
        _history[i] = _history[i+1];      
      }
      _history.pop();      
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