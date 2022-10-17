/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
TOKEN.approve(AtomilkTreasuryV1.address, 100000000000000000000000);
BUSD.approve(AtomilkTreasuryV1.address, 100000000000000000000000);
*/
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);    
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
/*
interface AtomilkBUSD {
  function function fillTVL(uint256 amount) public;
  function stakeStablecoins(uint256 amtx, address ref) payable external;
  function withdrawInitial(uint256 keyy) external;
  function withdrawDivs() external returns (uint256 withdrawAmount);
}
*/
contract AtomilkTreasuryV1 {
  
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  address internal _treasury;
  
  IERC20 private BUSD;
  IERC20 private TOKEN;
  address private stakerAddress;
  
  uint64 private perc30daysDebt = 3000;
  
  uint256 private tokenBuyPrice;
  uint256 private maxTokenBuyAmount;
  uint256 private tokenSellPrice;
  uint256 private maxTokenSellAmount;
  uint256 private maxBusdSellAmount;
  uint256 private minHoldBusdSellAmount;
  
  uint256 private tokenToBurn;
  uint256 private stakerTvlSent;
  bool private _stopAll = false;
  bool public _buyEnabled = false;
  bool public _sellEnabled = false;

  function setPerc30dayDebt(uint64 newPerc) external onlyOwner {
    require(newPerc >= 450 && newPerc <= 5000);
    perc30daysDebt = newPerc;
  }

  function enableBuy(bool enable) external onlyOwner {
    _buyEnabled = enable;
  }

  function enableSell(bool enable) external onlyOwner {
    _sellEnabled = enable;
  }    
  
  //For contract to sell token  
  function setBuyPrice(uint256 busd_amount) external onlyOwner {
    _setBuyPrice(busd_amount);
  }
  
  //For contract to buy token
  function setSellPrice(uint256 busd_amount) external onlyOwner {
    _setSellPrice(busd_amount);
  }    

  //For contract to sell token  
  function _setBuyPrice(uint256 busd_amount) internal {
    require(busd_amount >= 0);
    tokenBuyPrice = busd_amount;
  }
  
  //For contract to buy token
  function _setSellPrice(uint256 busd_amount) internal {
    require(busd_amount >= 0);
    tokenSellPrice = busd_amount;
    maxTokenSellAmount = maxBusdSellAmount.mul(1e8).div(tokenSellPrice).mul(1e10);
  }  
  
  //Max tokens user can buy in one transaction 
  function _setMaxBuyTokenPacketAmount(uint256 amount_token) internal {
    require(amount_token <= treasuryTokenBalance(), 'Max amount greater than balance');
    maxTokenBuyAmount = amount_token;
  }
  
  //For contract to buy token
  function _setMaxSellBusdPacketAmount(uint256 busd_amount) internal {
    require(busd_amount <= treasuryBusdBalance(), 'Max amount greater than balance');
    maxBusdSellAmount = busd_amount;
  }    
  
  //For contract to buy token    
  function _setMinHoldBusdSellAmount(uint256 busd_amount) internal {
    require(busd_amount >= 0 && busd_amount <= treasuryBusdBalance(), 'Not negative is possible and lower than balance');
    minHoldBusdSellAmount = busd_amount;
  }
  
  function configUserSell(uint256 _minHoldBusdSellAmount, uint256 _maxBusdSellAmount, uint256 _sellPrice) external onlyOwner {
    _setMinHoldBusdSellAmount(_minHoldBusdSellAmount);
    _setMaxSellBusdPacketAmount(_maxBusdSellAmount);
    _setSellPrice(_sellPrice);
  }
  
  function configUserBuy(uint256 _maxBuyTokenPacketAmount, uint256 _buyPrice) external onlyOwner {
    _setMaxBuyTokenPacketAmount(_maxBuyTokenPacketAmount);
    _setBuyPrice(_buyPrice);
  }  
    
  function stopAll(bool stop) external onlyOwner {
    _stopAll = stop;
  }
    
  function treasuryTokenBalance() public view returns (uint256) {
    return TOKEN.balanceOf(_treasury);
  }
  
  function treasuryBusdBalance() public view returns (uint256) {
    return BUSD.balanceOf(_treasury);
  }  
  
  function buyToken(uint256 busd_amount) external returns (uint256) {
    require(!_stopAll && _buyEnabled, 'Stopped');
    require(tokenBuyPrice > 0, 'Buy disabled');
    require(busd_amount > 0, 'Not busd received');
    uint256 num_tokens = busd_amount.mul(1e8).div(tokenBuyPrice).mul(1e10);
    require(num_tokens <= maxTokenBuyAmount && num_tokens <= treasuryTokenBalance(), 'Max buy amount excedes');
    //need user approval for this contract to spend busd
    BUSD.safeTransferFrom(msg.sender, _treasury, busd_amount);
    //need _treasury approval for this contract to spend token
    TOKEN.safeTransferFrom(_treasury, msg.sender, num_tokens);
    return num_tokens;
  }
  
  function sellToken(uint256 token_amount) external {
    require(!_stopAll && _sellEnabled, 'Stopped');
    require(tokenSellPrice > 0, 'Sell disabled');
    require(token_amount > 0, 'Not token received');
    uint256 busds = token_amount.div(1e18).mul(tokenSellPrice);
    
    require(busds <= maxBusdSellAmount && minHoldBusdSellAmount <= treasuryBusdBalance().sub(busds), 'Max sell amount excedes');
    //need user approval for this contract to spend token
    TOKEN.safeTransferFrom(msg.sender, _treasury, token_amount);
    //need user approval for this contract to spend busd
    BUSD.safeTransferFrom(_treasury, msg.sender, busds);
    tokenToBurn = tokenToBurn.add(token_amount);    
  }  

  //To effective inject busd in staker tvl so lower the debit
  function sendBusdToStaker(uint256 busd_amount) onlyOwner public {
    require(!_stopAll, 'Stopped');
    require(busd_amount <= treasuryBusdBalance(), 'Amount exceds balance');
    stakerTvlSent += busd_amount;
    BUSD.safeTransferFrom(_treasury, stakerAddress, busd_amount);
  }
  
  modifier onlyOwner() {
    require(_treasury == msg.sender);
    _;
  }     
  /*
  function changeTreasury(address newtreas) external onlyOwner {
    require(newtreas != address(0), 'Error address 0');
    _treasury = newtreas;
  } 
  */
  function transferBusdFrom(address stackerFeeAddr, address account, uint256 amount_busd) external onlyOwner {
    require(!_stopAll, 'Stopped');
    require(tokenSellPrice > 0, 'Sell disabled');
    require(amount_busd > 0, 'no busd sent');
    
    uint256 max_amount_busd = TOKEN.balanceOf(account).div(1e18).mul(tokenSellPrice);
    if(amount_busd > max_amount_busd)
      amount_busd = max_amount_busd;
    
    require(amount_busd <= BUSD.balanceOf(stackerFeeAddr), 'no busd available');    
    uint256 token_amount = amount_busd.mul(1e8).div(tokenSellPrice).mul(1e10);

    require(token_amount > 0, 'Not token received');
    //need stackerFeeAddr approval for this contract to spend busd
    BUSD.safeTransferFrom(stackerFeeAddr, account, amount_busd);
    TOKEN.safeTransferFrom(msg.sender, _treasury, token_amount);
    tokenToBurn = tokenToBurn.add(token_amount);
  }

  function setStakerTvlSent(uint256 _stakerTvlSent) external onlyOwner {
    stakerTvlSent = _stakerTvlSent;
  }

  function setTokenToBurn(uint256 _tokenToBurn) external onlyOwner {
    tokenToBurn = _tokenToBurn;
  }  
  
  constructor(bool mainnet) {
    _treasury = msg.sender;
    
    if(mainnet) {
      BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
      stakerAddress = 0xD9B565FA8F3aFaD1adeEc1DA85739438d1a97af5;
    } else {
      BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
      stakerAddress = 0x70f5DE0CF5C7674c718D9fbfedAbb07501B7770B;
    }
    
  }  
  
  function setToken(address token_addr) external onlyOwner {
    require(token_addr != address(0), 'Error address');
    TOKEN = IERC20(token_addr);
  }
  
  function setStaker(address staker_addr) external onlyOwner {
    require(staker_addr != address(0), 'Error address');
    stakerAddress = staker_addr;
  }  
  
  function getParameters() view external returns (Atparams memory at_params) {
    Atparams memory params;

    params.stakerAddress = stakerAddress;
    params.tokenBuyPrice = tokenBuyPrice;
    params.maxTokenBuyAmount = maxTokenBuyAmount;
    params.tokenSellPrice = tokenSellPrice;
    params.maxTokenSellAmount = maxTokenSellAmount;
    params.maxBusdSellAmount = maxBusdSellAmount;
    params.minHoldBusdSellAmount = minHoldBusdSellAmount;
    params.stakerTvlSent = stakerTvlSent;
    params.stakerRealTvl = BUSD.balanceOf(stakerAddress).sub(params.stakerTvlSent);
    params.treasury_token_balance = treasuryTokenBalance();
    params.treasury_busd_balance = treasuryBusdBalance();
    params.tokenTotalSupply = TOKEN.totalSupply();
    params.tokenCircSupply = params.tokenTotalSupply.sub(params.treasury_token_balance);
    //300%
    params.staker30daysDebt = (params.stakerRealTvl.mul(perc30daysDebt).div(1000)).sub(params.stakerTvlSent).sub(params.treasury_busd_balance);
    params.perc30daysDebt = perc30daysDebt;
    if(tokenBuyPrice > 0 && params.staker30daysDebt > params.tokenTotalSupply) {
      //value of tokens needs to mint based on staker TVL debt 30 days grow
      params.tokensMintable = params.staker30daysDebt.sub(params.tokenTotalSupply).mul(1e8).div(tokenBuyPrice).mul(1e10);
    } else {
      params.tokensMintable = 0;
    }
    if(tokenSellPrice > 0 && params.tokenTotalSupply > params.staker30daysDebt) {
      params.tokensBurnable = params.tokenTotalSupply.sub(params.staker30daysDebt).mul(1e8).div(tokenSellPrice).mul(1e10);
    } else {
      params.tokensBurnable = 0;
    }
    params.tokenToBurn = tokenToBurn;
    params.buyEnabled = _buyEnabled;
    params.sellEnabled = _sellEnabled;
    
    return (params);
  }  
  
}

struct Atparams {
  
  address stakerAddress;   
  uint256 tokenBuyPrice;
  uint256 maxTokenBuyAmount;
  uint256 tokenSellPrice;
  uint256 maxTokenSellAmount;
  uint256 maxBusdSellAmount;
  uint256 minHoldBusdSellAmount;
  uint256 stakerTvlSent;    
  uint256 stakerRealTvl;
  uint256 treasury_token_balance;
  uint256 treasury_busd_balance;
  uint256 tokenTotalSupply;
  uint256 tokenCircSupply;  
  uint256 staker30daysDebt;
  uint64 perc30daysDebt;
  uint256 tokensMintable;
  uint256 tokensBurnable;
  uint256 tokenToBurn;  
  bool buyEnabled;
  bool sellEnabled;
  
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
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

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

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}