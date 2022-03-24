/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

// File: @chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol


pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

// File: @chainlink/contracts/src/v0.8/KeeperBase.sol


pragma solidity ^0.8.0;

contract KeeperBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// File: @chainlink/contracts/src/v0.8/KeeperCompatible.sol


pragma solidity ^0.8.0;



abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}

// File: partnership.sol

pragma solidity ^0.8.7;


 interface IERC20 {
    function totalSupply() external view  returns (uint);
    function balanceOf(address tokenOwner) external  returns (uint balance);
    function allowance(address tokenOwner, address spender) external  returns (uint remaining);
    function transfer(address to, uint tokens) external  returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    function claimToken() external;
    function allocated_users(address _user) external view  returns (address userAddress,
        uint256 percent_amount,
        uint256 lock_period,
        uint256 release_percent,
        uint256 released_time,
        uint256 allocated_time,
        uint256 released_amount);
        function is_liquidity() external view  returns (bool);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract pantherPartnership is KeeperCompatibleInterface{
 using SafeMath for uint256;

  // The token being sold
  IERC20 public token;
  IERC20 public busd_token;

  // Address where funds are collected
  address payable public owner;

  uint256 public ico_start_time;
  uint256 public ico_expiry_time;
  uint256 public userLiquidityTime;

  // How many token units a buyer gets per wei
   uint256 public Busdrate;
   uint256 public Bnbrate;


//unable liquidity
  bool public is_liquidity;


  // Amount of wei raised
  uint256 public weiRaised_bnb;
  uint256 public weiRaised_busd;

  uint256 public total_weiRaised_bnb;
  uint256 public total_weiRaised_busd;

  uint256 public Tokens_sold;
  uint256 public total_Tokens_sold;


        uint256 public i_hard_cap;
        uint256 public i_lock_period;
        uint8 public i_release_percent;
        uint256 public i_release_interval;
        uint256 public i_released_amount;



  struct User{

        address userAddress;
        uint256 bnb_amount;
        uint256 busd_amount;
        uint256 invested_time;
        bool alreadyInvested;
        uint256 beneficiary_tokens;
        uint256 remaining_tokens;

    }

 struct AllocationUser {

        address userAddress;
        uint256 lock_period;
        uint8 release_percent;
        uint256 released_time;
       uint256 allocated_time;
        uint256 released_amount;
       uint256 release_interval;

    }

     mapping(address => AllocationUser) public allocated_users;





     mapping(address => User) public users;


  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );


  constructor (uint256 _bnbrate,uint256 _busdrate, address payable _owner, IERC20 _token,IERC20 _busd) {

    require(_bnbrate > 0);
    require(_busdrate > 0);
    require(_owner != address(0));
    require(address(_token) != address(0));
    Bnbrate = _bnbrate;
     Busdrate = _busdrate;
    owner = _owner;
    busd_token=_busd;
    token = _token;


  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */


function start_ico(uint256 start_time,uint256 end_time,uint256 _i_hard_cap,uint256 _i_lock_period,uint8 _i_release_percent,uint256 _i_release_interval) public{
    require(msg.sender==owner,"Access denied");
    ico_start_time=start_time;
    ico_expiry_time=end_time;
    i_hard_cap=_i_hard_cap;
    i_release_interval=_i_release_interval*(1 minutes);
    i_release_percent=_i_release_percent;
    i_lock_period=_i_lock_period*(1 minutes);
}





function set_Bnbrate(uint256 value) public{
    require(msg.sender==owner,"Access denied");
    Bnbrate=value;

}

function set_Busdrate(uint256 value) public{
    require(msg.sender==owner,"Access denied");
    Busdrate=value;

}



function set_token(IERC20 _token,IERC20 _busd) public{
     require(msg.sender==owner,"Access denied");
     token=_token;
     busd_token=_busd;

}

function withdraw_busd(uint256 amount) public{
 require(msg.sender==owner,"Access denied");
 busd_token.transfer(msg.sender,amount);

}

function withdraw_token(uint256 amount) public{
 require(msg.sender==owner,"Access denied");
 token.transfer(msg.sender,amount);

}

function set_owner(address payable _owner) public{
 require(msg.sender==owner,"Access denied");
owner=_owner;

}

function withdraw_bnb(uint256 amount) public{
 require(msg.sender==owner,"Access denied");
 owner.transfer(amount);
}

function burn_token(uint256 _value) public{
    require(msg.sender==owner,"Access denied");
uint256 remain_tokens=_value;
token.transfer(address(0),remain_tokens);

}

function enable_liquidity(bool _status) public{
 require(msg.sender==owner,"Access Denied");
 is_liquidity=_status;
 if(_status){
  userLiquidityTime=block.timestamp;
  }
 }





function user_withdraw() public{

require(is_liquidity,"Liquidity Not enabled");

  uint total_amount=users[msg.sender].beneficiary_tokens;



            require( allocated_users[msg.sender].released_amount< total_amount,"Exceed amount");

            if(allocated_users[msg.sender].released_time==0){
                  allocated_users[msg.sender].allocated_time=userLiquidityTime;
            }

            if(allocated_users[msg.sender].lock_period>0){

        if(allocated_users[msg.sender].released_time==0){
         allocated_users[msg.sender].allocated_time+=allocated_users[msg.sender].lock_period;
          }
            require(allocated_users[msg.sender].lock_period!=0 && block.timestamp>allocated_users[msg.sender].allocated_time,"In lock period or already claimed");
            }
  require(block.timestamp>=allocated_users[msg.sender].allocated_time,"Already claimed");

                token.transfer(msg.sender,(total_amount).mul(allocated_users[msg.sender].release_percent).div(1000));

              allocated_users[msg.sender].released_time=block.timestamp;
               allocated_users[msg.sender].allocated_time+= allocated_users[msg.sender].release_interval;
              allocated_users[msg.sender].released_amount+=(total_amount).mul(allocated_users[msg.sender].release_percent).div(1000);

}



     function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
   (,uint256 percent_amount,uint256 lock_period,,uint256 released_time,uint256 allocated_time,uint256 released_amount)=token.allocated_users(address(this));
       uint totalSupply=token.totalSupply();
   uint total_amount=totalSupply.mul(percent_amount).div(100);
        upkeepNeeded = lock_period!=0 && block.timestamp>=allocated_time && token.is_liquidity()&&released_amount< total_amount;
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
       (,uint256 percent_amount,uint256 lock_period,,uint256 released_time,uint256 allocated_time,uint256 released_amount)=token.allocated_users(address(this));
   uint total_amount=token.totalSupply().mul(percent_amount).div(100);
        if (lock_period!=0 && block.timestamp>=allocated_time && token.is_liquidity()&&released_amount< total_amount) {
           claimToken();
        }

    }

function claimToken() private{
  token.claimToken();
}




 function calculate_token(uint256 amount,uint8 amount_type) public view returns(uint256){
     uint256 value;
     if(amount_type==0)
     value=(amount.mul(100)).div(Bnbrate);
     if(amount_type==1)
     value=(amount.mul(100)).div(Busdrate);
     return value;
  }

  function bnb_buyTokens() public payable {
    address _beneficiary=msg.sender;
  //require(!users[msg.sender].alreadyInvested, "Already invested");
  require(block.timestamp>=ico_start_time && block.timestamp<=ico_expiry_time,"Sale closed");

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = (weiAmount.mul(100000000)).div(Bnbrate);

      require(Tokens_sold+tokens<=i_hard_cap,"Exceeds hard Cap");

    // update state
    weiRaised_bnb = weiRaised_bnb.add(weiAmount);
    total_weiRaised_bnb = total_weiRaised_bnb.add(weiAmount);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );
      Tokens_sold=Tokens_sold.add(tokens);
       total_Tokens_sold=total_Tokens_sold.add(tokens);
    _updatePurchasingState(_beneficiary, weiAmount,tokens,0);
  }


function busd_buyTokens(uint256 amount) public{
  address _beneficiary=msg.sender;
  require(!users[msg.sender].alreadyInvested, "Already invested");
  require(block.timestamp>=ico_start_time && block.timestamp<=ico_expiry_time,"Sale closed");

    uint256 weiAmount = amount;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = (weiAmount.mul(100000000)).div(Busdrate);
     require(Tokens_sold+tokens<=i_hard_cap,"Exceeds Hard cap");


    // update state
    weiRaised_busd = weiRaised_busd.add(weiAmount);
      total_weiRaised_busd = total_weiRaised_busd.add(weiAmount);
 busd_token.transferFrom(_beneficiary,address(this),amount);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );
  Tokens_sold=Tokens_sold.add(tokens);
  total_Tokens_sold=total_Tokens_sold.add(tokens);
    _updatePurchasingState(_beneficiary, weiAmount,tokens,1);
  }
  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    pure internal
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */


  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount,
    uint256 _tokens,uint8 _type
  )
    internal
  {
     if(_type==0){
       User memory user = User({
            userAddress: _beneficiary,
            bnb_amount:users[_beneficiary].bnb_amount.add(_weiAmount) ,
            busd_amount:users[_beneficiary].busd_amount ,
            alreadyInvested: true,
            invested_time:block.timestamp,
            beneficiary_tokens:users[_beneficiary].beneficiary_tokens.add(_tokens),
            remaining_tokens:0
        });

         users[_beneficiary]=user;

    }
    if(_type==1){
       User memory user = User({
            userAddress: _beneficiary,
            busd_amount:users[_beneficiary].busd_amount.add(_weiAmount) ,
            bnb_amount:users[_beneficiary].bnb_amount,
            alreadyInvested: true,
            invested_time:block.timestamp,
            beneficiary_tokens:users[_beneficiary].beneficiary_tokens.add(_tokens),
            remaining_tokens:0
        });
         users[_beneficiary]=user;
    }

      AllocationUser memory user1 = AllocationUser({
              userAddress:_beneficiary,
              lock_period:i_lock_period,
              release_percent:i_release_percent,
              released_time:0,
              release_interval:i_release_interval,
              allocated_time:block.timestamp,
              released_amount:0

        });
         allocated_users[_beneficiary]=user1;


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