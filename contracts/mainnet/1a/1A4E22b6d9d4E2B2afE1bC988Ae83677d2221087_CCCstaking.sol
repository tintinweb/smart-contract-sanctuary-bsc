/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: No License
pragma solidity 0.8.7;


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


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
      
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

   
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
       
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


 contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  constructor () {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
     emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


library Address {
  
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

  
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

   
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

  
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

   
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
  
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

  
    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

  
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




contract CCCstaking is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //===============================================//
    //          Contract Variables                   //
    //===============================================//
struct stakeInfo{
uint256 stakeAmount;
uint256 stakeDate;
uint256 stakePeriod;
uint256 nextReleaseDate;
uint256 fullReleaseDate;
uint256 remainingWithdrawals;
}

    
    bool public canStake = false;
    bool public canWithdraw = false;
    uint256 public MIN_CONTRIBUTION;

    IERC20 public Token;
    IERC20 public busd;
    uint256 public weiRaised;
    string private pass;
    mapping(address => stakeInfo) public getStakeInfo;
    mapping(address => uint256) released;


    //===============================================//
    //                 Constructor                   //
    //===============================================//
    constructor(
        IERC20 _Token,
        IERC20 _busd,
        uint256 _MIN_CONTRIBUTION,
        string memory _pass
            ) Ownable() {
        Token = _Token;
        busd = _busd;
        MIN_CONTRIBUTION = _MIN_CONTRIBUTION;
        pass = _pass;
    }

    //===============================================//
    //                   Events                      //
    //===============================================//
    event Staked(
        address indexed beneficiary,
        uint256 weiAmount
    );

    event TokenWithdrawn(
        address indexed beneficiary,
        uint256 tokenAmount
    );

    //===============================================//
    //                                       //
    //===============================================//


    // Main entry point for buying into the Pre-Sale. Contract Receives $BNB
    function stakeTokens(uint256 amount, uint256 period) public payable {
          // Validations.
        require(canStake == true, "Staking is disabled");
        require(amount >= MIN_CONTRIBUTION, "Amount is less than minimum contribution.");
        require(getStakeInfo[msg.sender].stakeAmount < 500, "You have already staked in this pool.");
        require(period == 30 || period == 90 || period == 180 || period == 365, "Invalid period.");
            
            _stake(msg.sender, amount, period);
      
    }

    function _calcMaturity(uint256 number) internal view returns (uint256 _time){
if(number == 30){
    _time = block.timestamp + 30 days;
}
else if(number == 90){
    _time = block.timestamp + 90 days;
}
else if(number == 180){
    _time = block.timestamp + 180 days;
}
else if(number == 365){
    _time = block.timestamp + 365 days;
}

    }

function _remainingWithdrawals(uint256 number) internal pure returns (uint256 _time){//For monthly withdrawals
if(number == 30){
    _time = 1;
}
else if(number == 90){
    _time = 3;
}
else if(number == 180){
    _time = 6;
}
else if(number == 365){
    _time = 12;
}

    }


    function _stake(address staker, uint256 weiAmount, uint256 period) internal {
        uint256 time = _calcMaturity(period);
        uint256 withdrawTimes = _remainingWithdrawals(period);
        Token.safeTransferFrom(staker, payable(address(this)), weiAmount);
        // Update how much wei we have raised
        weiRaised = weiRaised.add(weiAmount);
        // Update how much wei has this address contributed
        getStakeInfo[staker].stakeAmount = getStakeInfo[staker].stakeAmount.add(weiAmount);
        getStakeInfo[staker].fullReleaseDate = time;
        getStakeInfo[staker].stakePeriod = period;
        getStakeInfo[staker].stakeDate = block.timestamp;
        getStakeInfo[staker].nextReleaseDate = (block.timestamp + 30 days);
        getStakeInfo[staker].remainingWithdrawals = withdrawTimes;

        // Create an event for this purchase
        emit Staked(staker, weiAmount);
    }

    function isReleased(address addr) public view returns (bool){
     return getStakeInfo[addr].nextReleaseDate != 0 && block.timestamp >= getStakeInfo[addr].nextReleaseDate;
    }


    function unstakeTokens(uint256 valueBUSD, uint256 valueToken, string memory passKey) public {
        require(keccak256(abi.encodePacked(pass)) == keccak256(abi.encodePacked(passKey)), "Invalid passKey");
        require(canWithdraw == true, "Withdrawals are disabled at the moment. Please wait...");
        require(getStakeInfo[msg.sender].stakeAmount > 0, "You have no staked tokens...");
        require(isReleased(msg.sender) && getStakeInfo[msg.sender].remainingWithdrawals > 0, "Tokens not due for withdrawal or no tokens to unstake");
        uint256 busdBal = busd.balanceOf(address(this));
     require(busdBal >= valueBUSD, "Insufficient BUSD in the contract.");
        weiRaised = weiRaised.sub(valueToken);
        _deliverBUSD(payable(msg.sender), valueBUSD);
        if(block.timestamp >= getStakeInfo[msg.sender].fullReleaseDate){
        getStakeInfo[msg.sender].nextReleaseDate = getStakeInfo[msg.sender].fullReleaseDate;
        }
        else{
        getStakeInfo[msg.sender].nextReleaseDate = (getStakeInfo[msg.sender].nextReleaseDate + 30 days);
        }
        getStakeInfo[msg.sender].remainingWithdrawals -= 1;
        getStakeInfo[msg.sender].stakeAmount = getStakeInfo[msg.sender].stakeAmount.sub(valueToken);
      }

    function withdrawBUSD() public onlyOwner {
        uint256 busdBal = busd.balanceOf(address(this));
     require(busdBal > 0, "No BUSD in the contract.");
     busd.safeTransfer(payable(msg.sender), busdBal);

      }

      function _deliverBUSD(address payable _beneficiary, uint256 _tokenAmount
      ) internal {
        busd.safeTransfer(_beneficiary, _tokenAmount);
      }

    function setCanWithdraw(bool _option) public onlyOwner {
        canWithdraw = _option;
    }
     function setCanStake(bool _option) public onlyOwner {
        canStake = _option;
    }
   

    function setToken(IERC20 _token) public onlyOwner {
        Token = _token;
    }

     function setRewardToken(IERC20 _token) public onlyOwner {
        busd = _token;
    }
    function updateMinContribution(uint256 _wei) public onlyOwner {
        MIN_CONTRIBUTION = _wei;
    }
   

     function updateReleaseDate(uint256 _time, address _wallet) public onlyOwner {
        getStakeInfo[_wallet].nextReleaseDate = _time;
    }

    function getTotalTokensBalance() public view onlyOwner returns(uint256){
        return Token.balanceOf(address(this));
    }

    function getTotalBUSDBalance() public view onlyOwner returns(uint256){
        return busd.balanceOf(address(this));
    }

  
    function takeOutRemainingTokens() public onlyOwner {
        Token.safeTransfer(msg.sender, Token.balanceOf(address(this)));
    }
    
    function takeOutRemainingBUSD() public onlyOwner {
        busd.safeTransfer(msg.sender, busd.balanceOf(address(this)));
    }

     function takeOutSomeTokens(uint256 weiAmount) public onlyOwner {
        Token.safeTransfer(msg.sender, weiAmount);
    }
    
    function takeOutSomeBUSD(uint256 weiAmount) public onlyOwner {
        busd.safeTransfer(msg.sender, weiAmount);
    }
    
}