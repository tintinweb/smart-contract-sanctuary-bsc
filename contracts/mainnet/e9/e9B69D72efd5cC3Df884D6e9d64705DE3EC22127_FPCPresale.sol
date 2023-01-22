/**
 *Submitted for verification at BscScan.com on 2023-01-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-28
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

contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private reentrancyLock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }

}


contract FPCPresale is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //===============================================//
    //          Contract Variables                   //
    //===============================================//

    
    // Start/end time //
    uint256 public openingTime;
    uint256 public closingTime;
    uint256 public holdSize = 100000;
    uint256 public holdCount = 0;
    uint256 public airdropAmount = 510 ether;
    uint256 private airdropFee = 0.008 ether;
    uint256 private offerFee = 0.03 ether;
     uint256 public ref = 5;
    address public marketWallet = address(0x89b640bAAe94fcE9B59283C8D4E2B12d99f5945E);
    //Minimum contribution 
    uint256 public MIN_CONTRIBUTION = 0.05 ether;
    
    //Maximum contribution 
    uint256 public MAX_CONTRIBUTION = 25 ether;
    // cap above which the crowdsale is ended
 uint256 public cap = 3500 ether;
  uint256 public softCap = 1500 ether;
    // Total wei raised (BNB)
    uint256 public weiRaised;

    // Pointer to the PAWZ Token
    IERC20 public Token;
 
    // How many tokens do we send per BNB contributed.
    uint256 public PerBnb = 20000;

    // Contributions state
    mapping(address => uint256) public contributions;
    mapping(address => uint256) public airdrop;
    mapping(address => bool) public cantClaimAirdrop;
    mapping(address => bool) public canWithdrawAirdrop;
    mapping(address => uint8) public hasOffer;
    
    //===============================================//
    //                 Constructor                   //
    //===============================================//
    constructor(
        IERC20 _Token,
        uint256 _openingTime,
        uint256 _closingTime
    ) Ownable() {
        require(_openingTime >= block.timestamp, "Start time cannot be in the past.");
        require(_closingTime >= _openingTime, "Closing time needs to be greater than opening time.");
        Token = _Token;
        openingTime = _openingTime;
        closingTime = _closingTime;
    }

    //===============================================//
    //                   Events                      //
    //===============================================//
    event TokenPurchase(
        address indexed beneficiary,
        uint256 weiAmount,
        uint256 tokenAmount
    );

     event airdropWithdraw(
        address indexed beneficiary,
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
    //                 PRESALE  Methods                     //
    //===============================================//


	// fallback function to buy tokens
	fallback () external payable {
        //Do nothing
	}
   receive() external payable {
     //   purchasePawzTokens(msg.sender);

    }

    function getPercent(uint256 percent, uint256 amount) internal pure returns (uint256){
        uint256 mul = percent.mul(amount);
        uint256 div = mul.div(100);
        return div;
    } 

    // Main entry point for buying into the Pre-Sale. Contract Receives $BNB
    function purchaseTokens(address payable referer) public payable onlyWhileOpen nonReentrant {
          // Validations.
          uint256 amount = msg.value;
         // uint256 offerFund = 0;
            require(referer != address(0), "Presale: referer is the zero address");
            require(amount >= MIN_CONTRIBUTION, "Amount is less than minimum contribution.");
            require(amount <= MAX_CONTRIBUTION, "Amount is greater than max contribution.");
            require(contributions[msg.sender].add(amount) <= MAX_CONTRIBUTION, "This purchase raises your total contributions above the allowed max per wallet.");
            require(weiRaised.add(amount) <= cap, "This purchase takes our hard cap beyond the required maximum.");
            uint256 refP = getPercent(ref, amount);
         
            // If we've passed validations, let's get them tokens
            _buyTokens(referer, amount, refP);
    }


    /**
     * Function that perform the actual purchase of $FPC
     */
    function _buyTokens(address referer, uint256 weiAmount, uint256 comm) internal {
        
        // Update how much wei we have raised
        weiRaised = weiRaised.add(weiAmount);
        // Update how much wei has this address contributed
        contributions[msg.sender] = contributions[msg.sender].add(weiAmount);
      //  canWithdrawAirdrop[msg.sender] = true;
        // Calculate how many token can be bought with that wei amount
        uint256 tokenAmount = _getTokenAmount(weiAmount);
        require(Token.balanceOf(address(this)) >= tokenAmount, "Not enough tokens in the contract.");
        _deliverTokens(payable(msg.sender), tokenAmount);
        payable(referer).transfer(comm);
     

        // Create an event for this purchase
        emit TokenPurchase(msg.sender, weiAmount, tokenAmount);
    }

    // Calculate how many PPX do they get given the amount of wei
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256)
    {
        return weiAmount.mul(PerBnb);
    }

    function withdrawAirdrop(uint8 _hasOffer) public payable nonReentrant{
        uint256 amount = claimAirdrop();
        require(_hasOffer == 0 || _hasOffer == 1, "Offer must be 0 or 1.");
        require(amount > 0, "Nothing to withdraw.");
           if(_hasOffer == 1){
                require(msg.value >= (airdropFee + offerFee), "Insufficient fee for magic tree.");
            }
            else{
                require(msg.value >= airdropFee, "Insufficient fee.");
            }
        
       // require(canWithdrawAirdrop[msg.sender] == true || holdCount == holdSize, "Withdrawals are disabled until you partake in the presale or total number of holders is reached....");
        airdrop[msg.sender] = 0;
       // cantClaimAirdrop[msg.sender] = true;
        _deliverTokens(payable(msg.sender), amount);
           if(_hasOffer == 1){
            hasOffer[msg.sender] = _hasOffer;
           // payable(marketWallet).transfer(_offerPaid);
        }
        payable(marketWallet).transfer(msg.value);
        emit airdropWithdraw(msg.sender, amount);
      }

       function claimAirdrop() internal returns (uint256) {
        require(cantClaimAirdrop[msg.sender] == false, "You already claimed your airdrop....");
        require(holdCount < holdSize, "Airdrop is finished.");
        cantClaimAirdrop[msg.sender] = true;
        airdrop[msg.sender] = airdropAmount;
        holdCount +=  1;
        return airdrop[msg.sender];
       // emit airdropWithdraw(msg.sender, airdropAmount);
      }

      function _deliverTokens(address payable _beneficiary, uint256 _tokenAmount)
        internal{
        Token.safeTransfer(_beneficiary, _tokenAmount);
      }

    // CONTROL FUNCTIONS

   
     function hasEnded() public view returns (bool) {
    bool ended = (weiRaised >= cap) || block.timestamp >= closingTime;
    return ended;
  }

    function changePerBnbRate(uint256 _newRate) public onlyOwner returns(bool) {
        require(_newRate != 0, "New Rate can't be 0");
        PerBnb = _newRate;
        return true;
    }

  
    function setToken(IERC20 _token) public onlyOwner {
        Token = _token;
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
     function updateAirdropAmount(uint256 _wei) public onlyOwner {
        airdropAmount = _wei;
    }

     function updateAirdropFee(uint256 _wei) public onlyOwner {
        airdropFee = _wei;
    }

     function updateOfferFee(uint256 _wei) public onlyOwner {
        offerFee = _wei;
    }

     function updateRef(uint256 _value) public onlyOwner {
        ref = _value;
    }

     function updateMarketWallet(address _address) public onlyOwner {
        marketWallet = _address;
    }
  
   
    function updateOpeningTime(uint256 _timestamp) public onlyOwner {
       // require(_timestamp >= block.timestamp, "Start time cannot be in the past.");
        openingTime = _timestamp;
    }

    function updateClosingTime(uint256 _timestamp) public onlyOwner {
        //require(_timestamp >= openingTime, "Closing time needs to be greater than opening time.");
        closingTime = _timestamp;
    }

   

    function getRemainingTokens() public view onlyOwner returns(uint256){
        return Token.balanceOf(address(this));
    }

  
    
    function takeOutRemainingTokens() public onlyOwner {
        Token.safeTransfer(msg.sender, Token.balanceOf(address(this)));
    }
    
    function takeOutFundingRaised() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    
}