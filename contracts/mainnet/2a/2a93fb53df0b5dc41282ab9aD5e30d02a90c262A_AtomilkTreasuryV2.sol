/**
 *Submitted for verification at BscScan.com on 2022-11-17
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

contract AtomilkTreasuryV2 {
  
  using SafeMath for uint256;
  using SafeMath for uint112;
  using SafeERC20 for IERC20;

  struct Bond {
    uint256 depoTime;
    uint256 initial;    
    uint256 amount;
    //IERC20 _contract;
    uint256 tokenPrice;
    uint256 marketPrice;
    uint256 warmup;
    uint256 duration;
    uint256 claimDays;
    bool isOver;
  } 
    
  address internal _treasury;
  
  IERC20 private BUSD;
  IERC20 private TOKEN;
  address private pair_address;
  
  address private stakerAddress;
  
  uint64 private perc30daysDebt = 3000;
  
  //Bond AMIK price in tokenPrice
  uint256 private tokenBuyPrice;
  uint256 private maxTokenBuyAmount;
  uint256 private minHoldTokenBuyAmount;
  uint256 private tokenWarmupDays = 0*86400;  
  uint256 private tokenBondDuration = 7*86400;
  uint256 private tokenClaimDays = 1*86400;
  uint256 public buy_earn_perc = 40;
  
  //Bond BUSD price in tokenPrice
  uint256 private tokenSellPrice;
  uint256 private maxBusdSellAmount;
  uint256 private minHoldBusdSellAmount;    
  uint256 private busdWarmupDays = 0*86400;  
  uint256 private busdBondDuration = 5*86400;
  uint256 private busdClaimDays = 1*86400;
  uint256 public sell_earn_perc = 20;
    
  mapping (address => Bond []) public busd_bond;
  mapping (address => Bond []) public token_bond;
      
  uint256 private tokenToBurn;
  uint256 private stakerTvlSent;
  bool    auto_price = true;
  
  bool private _stopAll = false;
  bool public _buyEnabled = false;
  bool public _sellEnabled = false;

  function setPerc30dayDebt(uint64 newPerc) external onlyOwner {
    require(newPerc >= 450 && newPerc <= 5000);
    perc30daysDebt = newPerc;
  }

  enum PARAM { 
    TOKEN_WU_DAYS, //0
    TOKEN_DURATION, //1
    TOKEN_CLAIM_DAYS, //2
    BUSD_WU_DAYS, //3
    BUSD_DURATION, //4
    BUSD_CLAIM_DAYS, //5
    AUTO_PRICE, //6
    BUY_EARN_PERC, //7
    SELL_EARN_PERC //8
  }

  function changeParams(PARAM what, uint256 value) external onlyOwner returns ( bool )  {
    
    if(what == PARAM.TOKEN_WU_DAYS) {
      tokenWarmupDays = value;
    } else if(what == PARAM.TOKEN_DURATION) {
      tokenBondDuration = value;
    } else if(what == PARAM.TOKEN_CLAIM_DAYS) {
      tokenClaimDays = value;
    } else if(what == PARAM.BUSD_WU_DAYS) {
      busdWarmupDays = value;
    } else if(what == PARAM.BUSD_DURATION) {
      busdBondDuration = value;
    } else if(what == PARAM.BUSD_CLAIM_DAYS) {
      busdClaimDays = value;
    } else if(what == PARAM.AUTO_PRICE) {
      auto_price = !auto_price;
    } else if(what == PARAM.BUY_EARN_PERC) {
      buy_earn_perc = value;
    } else if(what == PARAM.SELL_EARN_PERC) {
      sell_earn_perc = value;
    } else {
      return false;
    }
    return true;
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
  
  //For contract to sell token    
  function _setMinHoldBusdSellAmount(uint256 busd_amount) internal {
    require(busd_amount >= 0 && busd_amount <= treasuryBusdBalance(), 'Not negative is possible and lower than balance');
    minHoldBusdSellAmount = busd_amount;
  }
  
  //For contract to buy token    
  function _setMinHoldTokenBuyAmount(uint256 token_amount) internal {
    require(token_amount >= 0 && token_amount <= treasuryTokenBalance(), 'Not negative is possible and lower than balance');
    minHoldTokenBuyAmount = token_amount;
  }  
  
  function configBusdBond(uint256 _minHoldBusdSellAmount, uint256 _maxBusdSellAmount, uint256 _sellPrice) external onlyOwner {
    _setMinHoldBusdSellAmount(_minHoldBusdSellAmount);
    _setMaxSellBusdPacketAmount(_maxBusdSellAmount);
    _setSellPrice(_sellPrice);
  }
  
  function configTokenBond(uint256 _minHoldTokenBuyAmount, uint256 _maxBuyTokenPacketAmount, uint256 _buyPrice) external onlyOwner {
    _setMinHoldTokenBuyAmount(_minHoldTokenBuyAmount);
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
  
  function buyTokenBond(uint256 busd_amount) external returns (uint256) {
    require(!_stopAll && _buyEnabled, 'Stopped');
    require(tokenBuyPrice > 0, 'Buy disabled');
    require(busd_amount > 0, 'Not busd received');
    if(auto_price) {
      _adjustTokenPrice();
    }
    uint256 num_tokens = busd_amount.mul(1e8).div(tokenBuyPrice).mul(1e10);
    require(num_tokens <= maxTokenBuyAmount && minHoldTokenBuyAmount <= treasuryTokenBalance().sub(num_tokens), 'Max buy amount excedes');
    
    Bond [] storage userBondList = token_bond[msg.sender];
    
    userBondList.push(Bond({
      depoTime: block.timestamp,
      initial: num_tokens,
      amount: num_tokens,
      tokenPrice: tokenBuyPrice,
      marketPrice: tokenMarketPrice(),
      warmup: tokenWarmupDays,
      duration: tokenBondDuration,
      claimDays: tokenClaimDays,
      isOver: false
    }));
    
    //need user approval for this contract to spend busd
    BUSD.safeTransferFrom(msg.sender, _treasury, busd_amount);

    return num_tokens;
  }
  
  function buyBusdBond(uint256 token_amount) external {
    require(!_stopAll && _sellEnabled, 'Stopped');
    require(tokenSellPrice > 0, 'Sell disabled');
    require(token_amount > 0, 'Not token received');
    if(auto_price) {
      _adjustTokenPrice();
    }
    uint256 busds = token_amount.div(1e8).mul(tokenSellPrice).div(1e10);
    require(busds <= maxBusdSellAmount && minHoldBusdSellAmount <= treasuryBusdBalance().sub(busds), 'Max sell amount excedes');
    
    Bond [] storage userBondList = busd_bond[msg.sender];
    
    userBondList.push(Bond({
      depoTime: block.timestamp,
      initial: busds,
      amount: busds,
      tokenPrice: tokenSellPrice,
      marketPrice: tokenMarketPrice(),
      warmup: busdWarmupDays,
      duration: busdBondDuration,
      claimDays: busdClaimDays,
      isOver: false      
    }));
    
    //need user approval for this contract to spend token
    TOKEN.safeTransferFrom(msg.sender, _treasury, token_amount);
    //tokenToBurn = tokenToBurn.add(token_amount);    
  }  
  
  function claimToken(uint256 index) external {
    Bond storage _bond = token_bond[msg.sender][index];
    require(!_bond.isOver,'Bond is over');    
    
    uint256 claimables = _calculateClaimable(_bond);
    require(claimables > 0, "No token claimables");
    _bond.amount = _bond.amount.sub(claimables);
    
    if(_bond.amount == 0) {
      _bond.isOver = true;
      removeOverTokenBond(msg.sender, index);
    }
    //need _treasury approval for this contract to spend token
    TOKEN.safeTransferFrom(_treasury, msg.sender, claimables);
    if(auto_price) {
      _adjustTokenPrice();
    }
  }
  
  function claimBusd(uint256 index) external {    
    Bond storage _bond = busd_bond[msg.sender][index];
    require(!_bond.isOver,'Bond is over');    
    
    uint256 claimables = _calculateClaimable(_bond);
    require(claimables > 0, "No token claimables");
    _bond.amount = _bond.amount.sub(claimables);
    
    if(_bond.amount == 0) {
      _bond.isOver = true;
      removeOverBusdBond(msg.sender, index);
    }
    //need _treasury approval for this contract to spend busd    
    BUSD.safeTransferFrom(_treasury, msg.sender, claimables);
    if(auto_price) {
      _adjustTokenPrice();
    }
  }

  function calculateClaimableToken(uint256 index) external view returns(uint256) {
    Bond memory _bond = token_bond[msg.sender][index];
    return _calculateClaimable(_bond);
  }
  
  function calculateClaimableBusd(uint256 index) external view returns(uint256) {
    Bond memory _bond = busd_bond[msg.sender][index];
    return _calculateClaimable(_bond);
  }
  
  function _calculateClaimable(Bond memory _bond) internal view returns(uint256) {
    
    uint256 bondLifeSecs = block.timestamp.sub(_bond.depoTime);
    if(bondLifeSecs <= _bond.warmup) {
      return 0;
    }
    
    uint256 tranche = _bond.initial.mul(_bond.claimDays).mul(1e5).div(_bond.duration).div(1e5);
    uint256 num_tokens = (bondLifeSecs.sub(_bond.warmup)).div(_bond.claimDays).add(1).mul(tranche).sub(_bond.initial.sub(_bond.amount));
    
    if(num_tokens > _bond.amount) {
      return _bond.amount;
    }    
    
    return num_tokens;    
  }
    
  function tokenMarketPrice() view public returns(uint256) {
    
    (uint112 _token, uint112 _busd, ) = IPancakeswapV2Pair(pair_address).getReserves();     
    return _busd.mul(1e8).div(_token).mul(1e10);
    
  }
  
  function adjustTokenPrice() onlyOwner external {
    _adjustTokenPrice();
  }  
  
  function _adjustTokenPrice() internal {
    uint256 marketPrice = tokenMarketPrice();
    tokenBuyPrice = marketPrice.mul(1000 - buy_earn_perc).div(1000);
    tokenSellPrice = marketPrice.mul(1000 + sell_earn_perc).div(1000);
  }
  
  function removeOverTokenBond(address addr, uint256 index) internal {
    Bond storage _bond = token_bond[addr][index];
    require(_bond.isOver, 'Bond not over');
    
    for(uint i = index; i < token_bond[addr].length-1; i++){
      token_bond[addr][i] = token_bond[addr][i+1];      
    }
    token_bond[addr].pop();
  }  
  
  function removeOverBusdBond(address addr, uint256 index) internal {
    Bond storage _bond = busd_bond[addr][index];
    require(_bond.isOver, 'Bond not over');
    
    for(uint i = index; i < busd_bond[addr].length-1; i++){
      busd_bond[addr][i] = busd_bond[addr][i+1];      
    }
    busd_bond[addr].pop();
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
      pair_address = 0xb2d3a3d55E6598662B351a6c057aF289431Db5D2;
    } else {
      BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
      stakerAddress = 0x70f5DE0CF5C7674c718D9fbfedAbb07501B7770B;
      pair_address = 0x583A13FCBbB3f559272a4d3607c112Ba77Dc3E28;
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
  
  function userTokenBondList() external view returns(Bond [] memory list) {
    return token_bond[msg.sender];
  }

  function userBusdBondList() external view returns(Bond [] memory list) {
    return  busd_bond[msg.sender];
  }  
/*
  function userTokenBondList() external view returns(Bond [] memory list, uint256 [] memory claimables) {
    uint256 [] memory _claimables;
    Bond [] memory _list = token_bond[msg.sender];
    for(uint256 i = 0; i < _list.length; i++) {
      _claimables[i] = _calculateClaimable(_list[i]);
    }
    return (_list, _claimables);
  }

  function userBusdBondList() external view returns(Bond [] memory list, uint256 [] memory claimables) {
    uint256 [] memory _claimables;
    Bond [] memory _list = busd_bond[msg.sender];
    for(uint256 i = 0; i < _list.length; i++) {
      _claimables[i] = _calculateClaimable(_list[i]);
    }    
    return (_list, _claimables);    
  }
*/  
  function getParameters() view external returns (Atparams memory at_params) {
    Atparams memory params;

    params.stakerAddress = stakerAddress;
    params.marketPrice = tokenMarketPrice();
    params.tokenBuyPrice = tokenBuyPrice;
    params.maxTokenBuyAmount = maxTokenBuyAmount;
    params.maxBusdBuyAmount = maxTokenBuyAmount.div(1e8).mul(tokenBuyPrice).mul(1e10);
    params.minHoldTokenBuyAmount = minHoldTokenBuyAmount;
    params.tokenSellPrice = tokenSellPrice;
    if(tokenSellPrice > 0) {
      params.maxTokenSellAmount = maxBusdSellAmount.mul(1e8).div(tokenSellPrice).mul(1e10);
    } else {
      params.maxTokenSellAmount = 0;
    }
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
    params.tokenWarmupDays = tokenWarmupDays;  
    params.tokenBondDuration = tokenBondDuration;
    params.tokenClaimDays = tokenClaimDays;
    params.busdWarmupDays = busdWarmupDays;  
    params.busdBondDuration = busdBondDuration;
    params.busdClaimDays = busdClaimDays;  
    params.buyEnabled = _buyEnabled;
    params.sellEnabled = _sellEnabled;
    params.autoPrice = auto_price;
    
    return (params);
  }  
  
}

struct Atparams {
  
  address stakerAddress;  
  uint256 marketPrice; 
  uint256 tokenBuyPrice;
  uint256 maxTokenBuyAmount;
  uint256 maxBusdBuyAmount;
  uint256 minHoldTokenBuyAmount;
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
  uint256 tokenWarmupDays;  
  uint256 tokenBondDuration;
  uint256 tokenClaimDays;
  uint256 busdWarmupDays;  
  uint256 busdBondDuration;
  uint256 busdClaimDays;  
  bool buyEnabled;
  bool sellEnabled;
  bool autoPrice;
  
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
interface IPancakeswapV2ERC20 {
    function totalSupply() external view returns (uint);
}

interface IPancakeswapV2Pair is IPancakeswapV2ERC20 {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns ( address );
    function token1() external view returns ( address );
}