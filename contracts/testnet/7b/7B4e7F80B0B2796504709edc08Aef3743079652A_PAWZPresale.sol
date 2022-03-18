/**
 *Submitted for verification at BscScan.com on 2022-03-18
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




contract PAWZPresale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //===============================================//
    //          Contract Variables                   //
    //===============================================//

    
    // Start/end time //
    uint256 public openingTime;
    uint256 public closingTime;
    uint256 public launchDate;
    bool public canWithdraw = false;
    
    //Minimum contribution 
    uint256 public MIN_CONTRIBUTION;
    
    //Maximum contribution 
    uint256 public MAX_CONTRIBUTION;
    // cap above which the crowdsale is ended
 uint256 public cap;

    // Contributions state
    mapping(address => uint256) public contributions;

    //Token balance
    mapping(address => uint256) balances;
    
    //Token Available for withdraw
    mapping(address => uint256) released;
    mapping(address => uint8) vestStage;

    // Total wei raised (BNB)
    uint256 public weiRaised;


    // Pointer to the PAWZ Token
    IERC20 public Token;
 
    // How many PAWZ do we send per BNB contributed.
    uint256 public PerBnb;

    
    //===============================================//
    //                 Constructor                   //
    //===============================================//
    constructor(
        IERC20 _Token,
        uint256 _PerBnb,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _launchDate,
        uint256 _MIN_CONTRIBUTION,
        uint256 _MAX_CONTRIBUTION,
        uint256 _cap

    ) Ownable() {
        require(_openingTime >= block.timestamp, "Start time cannot be in the past.");
        require(_closingTime >= _openingTime, "Closing time needs to be greater than opening time.");
        require(_launchDate >= _closingTime, "Launch date needs to be greater than closing time.");
        require(_cap > 0,"Hard cap cannot be zero");
        Token = _Token;
        PerBnb = _PerBnb;
        openingTime = _openingTime;
        closingTime = _closingTime;
        launchDate = _launchDate;
        MIN_CONTRIBUTION = _MIN_CONTRIBUTION;
        MAX_CONTRIBUTION = _MAX_CONTRIBUTION;
        cap = _cap;
    }

    //===============================================//
    //                   Events                      //
    //===============================================//
    event TokenPurchase(
        address indexed beneficiary,
        uint256 weiAmount,
        uint256 tokenAmount
    );

    event TokenWithdrawn(
        address indexed beneficiary,
        uint256 tokenAmount
    );

    //===============================================//
    //                   VALIDATORS                     //
    //===============================================//
    //Checks if we have reached the cap
     function capReached() public view returns (bool) {
        return weiRaised >= cap;
      }
      //Make sure sale has started, still open and cap not reached yet
     modifier onlyWhileOpen {
        require(block.timestamp >= openingTime && block.timestamp <= closingTime && !capReached(), "Make sure sale has started, still open and cap not reached yet");
        _;
      }


    //===============================================//
    //                   Methods                     //
    //===============================================//


	// fallback function to buy tokens
	fallback () external payable {
        //Do nothing
	}
   receive() external payable {
        purchasePawzTokens(msg.sender);

    }

    function getPercent(uint256 percent, uint256 amount) internal pure returns (uint256){
        uint256 mul = percent.mul(amount);
        uint256 div = mul.div(100);
        return div;
    } 

    // Main entry point for buying into the Pre-Sale. Contract Receives $BNB
    function purchasePawzTokens(address beneficiary) public payable onlyWhileOpen {
          // Validations.
            require(
                beneficiary != address(0), "Presale: beneficiary is the zero address");
            
            require(isOpen() == true, "Presale has not yet started");
            require(hasEnded() == false, "Presale has ended");

            
            require(msg.value >= MIN_CONTRIBUTION, "Amount is less than minimum contribution.");
            require(msg.value <= MAX_CONTRIBUTION, "Amount is greater than max contribution.");
            require(weiRaised.add(msg.value) <= cap, "This purchase takes our hard cap beyond the required maximum.");
            
            // If we've passed validations, let's get them $PAWZ
            _buyTokens(msg.sender, msg.value);
      
    }

    
    

    /**
     * Function that perform the actual purchase of $PAWZ
     */
    function _buyTokens(address beneficiary, uint256 weiAmount) internal {
        
        // Update how much wei we have raised
        weiRaised = weiRaised.add(weiAmount);
        // Update how much wei has this address contributed
        contributions[beneficiary] = contributions[beneficiary].add(weiAmount);

        // Calculate how many $PAWZ can be bought with that wei amount
        uint256 tokenAmount = _getTokenAmount(weiAmount);
        // Store the tokens they bought instead of releasing them
        balances[beneficiary] = balances[beneficiary].add(tokenAmount);
        vestStage[beneficiary] = 1;

        //Token.safeTransfer(beneficiary, tokenAmount);

        // Create an event for this purchase
        emit TokenPurchase(beneficiary, weiAmount, tokenAmount);
    }

    // Calculate how many PPX do they get given the amount of wei
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256)
    {
        return weiAmount.mul(PerBnb);
    }

    function withdrawTokens() public {
        require(hasEnded(), "Presale has not ended.");
        require(canWithdraw == true, "Withdrawals are disabled at the moment. Please wait...");
        require(block.timestamp >= launchDate, "Project is not yet launched");
        require(balances[msg.sender] > 0, "You have already withdrawn all of your tokens...");
        
         //Pay out all released tokens.
        uint256 amount = _getReleasedTokens();
        require(amount > 0, "You currently do not have any released presale tokens to withdraw.");
        released[msg.sender] = 0;
        _deliverTokens(payable(msg.sender), amount);
      }

      function _deliverTokens(
        address payable _beneficiary,
        uint256 _tokenAmount
      )
        internal
      {
        Token.safeTransfer(_beneficiary, _tokenAmount);
      }

    // CONTROL FUNCTIONS

    // Is the sale open now?
    function isOpen() public view returns (bool) {
        return block.timestamp >= openingTime;
    }
     function hasEnded() public view returns (bool) {
    bool ended = (weiRaised >= cap) || block.timestamp >= closingTime;
    return ended;
  }

    function changePerBnbRate(uint256 _newRate) public onlyOwner returns(bool) {
        require(_newRate != 0, "New Rate can't be 0");
        PerBnb = _newRate;
        return true;
    }

    function setCanWithdraw(bool _option) public onlyOwner {
        canWithdraw = _option;
    }
    function updateMinContribution(uint256 _wei) public onlyOwner {
        MIN_CONTRIBUTION = _wei;
    }
    function updateMaxContribution(uint256 _wei) public onlyOwner {
        MAX_CONTRIBUTION = _wei;
    }
    function updateCap(uint256 _wei) public onlyOwner {
        cap = _wei;
    }
  
   
    function updateOpeningTime(uint256 _timestamp) public onlyOwner {
       // require(_timestamp >= block.timestamp, "Start time cannot be in the past.");
        openingTime = _timestamp;
    }

    function updateClosingTime(uint256 _timestamp) public onlyOwner {
        //require(_timestamp >= openingTime, "Closing time needs to be greater than opening time.");
        closingTime = _timestamp;
    }

    function updateLaunchDate(uint256 _timestamp) public onlyOwner {
        require(_timestamp >= closingTime, "Launch time needs to be greater than or equal to closing time.");
        launchDate = _timestamp;
    }

    function getRemainingTokens() public view onlyOwner returns(uint256){
        return Token.balanceOf(address(this));
    }
    function getUnclaimedTokens() public view returns(uint256){
        return balances[msg.sender];
    }

    function _getReleasedTokens() internal returns(uint256){
            //Release 60% after launch
        if(block.timestamp >= launchDate && balances[msg.sender] > 0 && vestStage[msg.sender] == 1){
        uint256 available = getPercent(60, balances[msg.sender]); 
        released[msg.sender] = released[msg.sender].add(available);
        balances[msg.sender] = balances[msg.sender].sub(available);
        vestStage[msg.sender] = 2;
        }
        //Release another 20% after 7 days
         if(block.timestamp >= (launchDate + 7 days) && block.timestamp < (launchDate + 14 days) && balances[msg.sender] > 0 && vestStage[msg.sender] == 2){
         uint256 available = getPercent(50, balances[msg.sender]); 
        released[msg.sender] = released[msg.sender].add(available);
         balances[msg.sender] = balances[msg.sender].sub(available);
         vestStage[msg.sender] = 3;
         }
         //Release the last 20% after 14 days.
          if(block.timestamp >= (launchDate + 14 days) && balances[msg.sender] > 0 && vestStage[msg.sender] == 3){
         uint256 available = balances[msg.sender]; 
        released[msg.sender] = released[msg.sender].add(available);
         balances[msg.sender] = 0;
         vestStage[msg.sender] = 0;
         }
        return released[msg.sender];
    }

  
    
    function takeOutRemainingTokens() public onlyOwner {
        Token.safeTransfer(msg.sender, Token.balanceOf(address(this)));
    }
    
    function takeOutFundingRaised()public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    
}

//CNC 0xeB257822ac02D15073Ed8a9d8B20Ce41Cb5C4868