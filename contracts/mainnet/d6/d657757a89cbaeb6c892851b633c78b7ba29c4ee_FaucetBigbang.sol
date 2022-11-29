/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface IPancakeRouter01 {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
} 
 

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(  address from,  address to,  uint256 amount ) external returns (bool);
}
 

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

contract FaucetBigbang is ReentrancyGuard{
   
   address public Owner ;
   uint136 private Tokens;
   uint136 private limit_profit = 80 ;
   uint256 private Total_deposits = 0 ; 
    IPancakeRouter01 UniSwapRouter = IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E);
//=====================================================
   struct token{
     address erc20TokenAddress;//This variable stores the contract address of a digital currency .
     IERC20 erc20Token;
     AggregatorV3Interface priceFeed;
     uint256 Profit ;
     uint256 My_deposit ;
     uint56 decimal ;
     uint256 profit_balance ;
     uint256 limit_date ;
   }
    mapping (uint => token) private _Tokens ;
    mapping (address =>  mapping (uint => token)) private _Account;
    mapping (address => uint) private Date ;
    mapping (address => uint) private profit_limit ;
    event Deposit ( address indexed _From , address  indexed _To , uint256 _Value);
    event Withdraw(address indexed _From , address  indexed _To , uint256 _Value);
    event Update(address _From , uint256 _Limit , uint256 _date) ;
//======================================================
 constructor() {
    Owner = msg.sender ;
 }
 /* @ The following modifier locks and unlocks the function
This is done because the function can be executed by the back person when it is executed, and two people cannot execute the same function at the same time.
When the function is executed, this modifier is executed and checks whether the function is locked or not.  */
 
  modifier Im_owner(){
     require(msg.sender == Owner);
     _;
 }
//======================================================
    function Set_token(address _tokenAddress, address chainlink , uint56 _decimal ,uint256 _balance , uint256 _date) public Im_owner()  returns (bool success){
      Tokens++ ;
      token memory _To ;
      _To.erc20TokenAddress = _tokenAddress ; // Sets "erc20TokenAddress"
      _To.erc20Token = IERC20(_To.erc20TokenAddress);
      _To.priceFeed = AggregatorV3Interface(chainlink);
      _To.Profit = 0 ;
      _To.My_deposit  = 0 ;
      _To.decimal  = _decimal;
      _To.profit_balance = _balance ;
      _To.limit_date = _date ;
      _Tokens[Tokens] = _To ;
       return(true);
    }
    /* @  The following function specifies the bandwidth
It is a numerical value between 10 and 100.
This function can be executed by the owner */
    function Bandwidth( uint136 _limit) public Im_owner()  {
       require(_limit > 9 && _limit < 101);
       limit_profit = _limit ;
    } 
    /* @ The following function receives an address as input, which replaces this address with the address of the contract owner.
This function can only be executed by the administrator  */
    function Change_manager(address _newOwner) public Im_owner()  {
      Owner = _newOwner;
    }
     function Limit_date(uint136 _idToken) public view returns(uint){
      return (_Tokens[_idToken].limit_date);
    }
     function Limit_profit() public view returns(uint){
      return (limit_profit);
    }
    function BigbangToUsdt() public view returns(uint){
       address[] memory Path = new address[](2);
       Path[0] = 0xB583fEf0FE1c9b7a7e085eA757AD26aa4fF9b251;
       Path[1] = 0x55d398326f99059fF775485246999027B3197955;
       uint256 A = UniSwapRouter.getAmountsOut(uint(1*(10**18)) , Path)[1];
         return (A / 10 **7);
    }
    function getLatestPrice(uint136 _Key) private view returns (uint256) {
       (, int price, , , ) = _Tokens[_Key].priceFeed.latestRoundData();
        return uint256(price );
    }
    function BalanceAccount(address Myaddress ) public view returns (uint){
        return(_Account[Myaddress][1].My_deposit);
    }
    function BalancePlatform(uint136 _idToken) public view returns (uint){
           return(_Tokens[_idToken].erc20Token.balanceOf(address(this)));
    }
    function extraction_BGB() public view returns(uint){
      return(_Tokens[1].erc20Token.balanceOf(address(this)) - Total_deposits );
    }
    function Mybandwidth() public view returns (uint){
      return( profit_limit[msg.sender]);
    }
    function Mydepositdate() public view returns (uint){
      return(Date [msg.sender] );
    }
    function My_profit(address Myaddress , uint136  _idToken) public view returns (uint){
        return(_Account[Myaddress][_idToken].Profit);
    }
  /*If the following function is executed, it will deposit the Big Bang token to the smart contract.
Please note: when depositing, some bandwidth will be given to the account owner.
Anyone can use this bandwidth to extract native token (Big Bang) and other tokens.
Please note: after depositing tokens, they will not be locked and withdrawable for 30 days. */
    function deposit(uint256 _value) public nonReentrant  returns(bool){ 
      require(_value <= _Tokens[1].erc20Token.balanceOf(msg.sender) ,"Your account balance is insufficient.");
      bool A =  IERC20(_Tokens[1].erc20TokenAddress).transferFrom(msg.sender, address(this) , _value);//Deposit with Big Bang(BGB) Token only.
        if(A == true){
            uint256 Computing1 = _value / 100;
            //uint256 Price =  (BigbangToUsdt() * _value) / 10 ** 18;
            //uint256 limit = Price / 100;
            Total_deposits += _value ;
            _Account[msg.sender][1].My_deposit += _value ;//Token BGB
            Date [msg.sender] = block.timestamp + 2592000 ;
            profit_limit[msg.sender] += Computing1 * limit_profit ;
            emit Deposit( msg.sender , address(this) ,  _value);
            emit  Update(msg.sender , Computing1 * limit_profit , Date [msg.sender]) ;
            return(true);
        }
      return(false);
    }
    /* @ If the following function is executed, the account owner can extract the native token of this platform. This value can be an arbitrary value and is given to the input of the function when it is executed.
Note: By mining the native token (Big Bang), some bandwidth is consumed as fuel.*/
    function profit_withdrawalBGB(uint256 _value) public nonReentrant returns(bool success){ 
           uint256  Comput = _Tokens[1].erc20Token.balanceOf(address(this)) - Total_deposits;
          require(_value <= Comput, "This amount of profit is not available on the platform.");
        require(_Account[msg.sender][1].My_deposit > 0  &&  _value <= profit_limit[msg.sender]);
          bool A =  IERC20(_Tokens[1].erc20TokenAddress).transfer(msg.sender , _value);
        if(A == true){
              Date [msg.sender] = block.timestamp + _Tokens[1].limit_date  ;
              profit_limit[msg.sender] -= _value;
             _Account[msg.sender][1].Profit += _value ;
              emit Withdraw(address(this) , msg.sender, _value);
              return(true);
        }
        return(false);
    }
      function _Computing(uint136 _id , uint256 _value) private view returns (uint){
       uint R = _value / 10 ** _Tokens[_id].decimal ;
       return (R * _Tokens[_id].profit_balance );
    }
 /* @ If the following function is executed, the account owner can mine the desired token. This value can be an arbitrary value and is given to the function input during execution.
Note: As each token is mined, some bandwidth is consumed as fuel.
Note: mining each token (native or non-native) consumes different bandwidth and locks the initial tokens for a certain time.  */
    function profit_withdrawal(uint136 _idToken , uint256 _value) public nonReentrant returns(bool success){     
        require(_idToken > 1 && _idToken <= Tokens);
        require(_Computing(_idToken , _value) <= profit_limit[msg.sender] ); 
        require(_value <= _Tokens[_idToken].erc20Token.balanceOf(address(this)));
        require(  _Account[msg.sender][1].My_deposit > 0 );
        bool A =  IERC20(_Tokens[_idToken].erc20TokenAddress).transfer(msg.sender , _value);
        if(A == true){
            Date [msg.sender] = block.timestamp + _Tokens[_idToken].limit_date  ;
            profit_limit[msg.sender] -= _Computing(_idToken , _value);
            _Account[msg.sender][_idToken].Profit += _value ;
              emit Withdraw(address(this) , msg.sender, _value);
              return(true);
        }
        return(false);
    }
    /* @If the following function is executed, it will transfer the initial tokens from the address of the smart contract to the address of the account holder. (the token will be collected).
Note: This function is executed when the time specified in the executing account has passed. */
       function withdraw(uint136 _value) public nonReentrant returns(bool success){     
        require(_value <=  _Account[msg.sender][1].My_deposit  && block.timestamp > Date [msg.sender]);
        bool A =  IERC20(_Tokens[1].erc20TokenAddress).transfer(msg.sender , _value);
        if(A == true){
            _Account[msg.sender][1].My_deposit -= _value ;//Token BGB
              Total_deposits -= _value ;
              emit Withdraw(address(this) , msg.sender, _value);
                            return(true);
        }
        return(false);
    }
     /* @If the following function is executed, the initial tokens of the account owner will receive bandwidth again and the tokens will be locked in the contract account for a certain period of time.
Note: This function is executed when the previously specified time has passed
Otherwise, it is not applicable */
     function Update_Account() public  returns (bool success){
         require(block.timestamp > Date [msg.sender]);
         require(_Account[msg.sender][1].My_deposit > 0);
            uint256 Computing1 = _Account[msg.sender][1].My_deposit / 100;
            Date [msg.sender] = block.timestamp + 2592000 ;
            profit_limit[msg.sender] += Computing1 * limit_profit ;
            emit  Update(msg.sender , Computing1 * limit_profit , Date [msg.sender]) ;
            return(true);
      

    }
}