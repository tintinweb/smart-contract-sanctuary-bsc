/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT

   pragma solidity ^0.8.0;

    abstract contract Context 
    {
      function _msgSender() internal view virtual returns (address payable) 
      {
        return payable(msg.sender);
      }

      function _msgData() internal view virtual returns (bytes memory) 
      {
        this;
        return msg.data;
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

   interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
   }




contract  troncontract  is Context {


address payable owner;
 bool private _paused;
IERC20 public Token;
IPancakePair public ULEtobnblp;
IPancakePair public bnbbusdlp;
    uint256 public Valueinbnb;
    uint256 public ValueinULE;
    uint256 public pricetime = 10 minutes;
    uint256 public Pricein_token =1;


    constructor (IERC20 _Token ,IPancakePair _ULEtobnblp ,IPancakePair _bnbbusdlp)  
    {
     
          owner=payable(msg.sender);
          Token = _Token;
           ULEtobnblp = _ULEtobnblp;
           bnbbusdlp = _bnbbusdlp;
         
         uint256 a =one$toULE();
         Valueinbnb = BnbtoBusd()*Pricein_token;
         ValueinULE = a*Pricein_token;
        
    }

     modifier onlyOwner() {
        require(msg.sender==owner, "Only Call by Owner");
        _;
    }


  function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        
    }

    function pauseContract() public onlyOwner{
        _pause();

    }
    function unpauseContract() public onlyOwner{
        _unpause();

    }




     
    function register(address _address)public pure returns(address)
    {
        return _address;
    }
    
    
    function multisendToken( address[] calldata _contributors, uint256[] calldata __balances) external whenNotPaused  onlyOwner
        {
            uint8 i = 0;
            for (i; i < _contributors.length; i++) {
            Token.transfer(_contributors[i], __balances[i]);
            }
        }
    
    
  
    function sendMultiBnb(address payable[]  memory  _contributors, uint256[] memory __balances) public  payable whenNotPaused
    {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= __balances[i],"Invalid Amount");
            total = total - __balances[i];
            _contributors[i].transfer(__balances[i]);
        }
    }


    function buy() external payable whenNotPaused
    {
        require(msg.value>0,"Select amount first");
    }
    


    function sell (uint256 _token) external payable whenNotPaused
    {
        require(_token>= 0,"Select amount first");
        require(msg.value>= 0,"Select amount first");

   
        Token.transferFrom(msg.sender,address(this),_token);

                  if( block.timestamp > pricetime )
    {
         uint256 a =one$toULE();
         Valueinbnb = BnbtoBusd()*Pricein_token;
         ValueinULE = a*Pricein_token;
         pricetime = block.timestamp + 10 minutes;
    }

    }


    function getPrice(uint256 _amount) public view returns(uint256 _Valueinbnb,uint256 _ValueinULE)
    {

         uint256 a =one$toULE();
         _Valueinbnb = (BnbtoBusd()*_amount)/1E18;
         _ValueinULE = (a*_amount)/1E18;
    }
    
    
    
    function withDraw (uint256 _amount) onlyOwner public whenNotPaused
    {
        payable(msg.sender).transfer(_amount);
    }
    
      function SetPricein_Token(uint256 _value) external onlyOwner
  {
      Pricein_token = _value;
  }
    
    function getTokens (uint256 _amount) onlyOwner public whenNotPaused
    {
        Token.transfer(msg.sender,_amount);
    }





//........................................price.....................................................................









    function BnbtoBusd() public view returns(uint256 )
    {
       (uint256 a,uint256 b,uint256 c) =  bnbbusdlp.getReserves();

       uint256 z = (a*1e18)/b;
       return z;
    }

    function BUSDtobnb() public view returns(uint256 )
    {
       (uint256 a,uint256 b,uint256 c) =  bnbbusdlp.getReserves();
       uint256 z = (b*1e18)/a;
       return z;
    }
    


    function ULEtobnb() public view returns(uint256 )
    {
       (uint256 a,uint256 b,uint256 c) =  ULEtobnblp.getReserves();
       uint256 z = (a*1e18)/b;
       return z;
    }

    function bnbtoULE() public view returns(uint256 )
    {
       (uint256 a,uint256 b,uint256 c) =  ULEtobnblp.getReserves();

       uint256 z = (b*1e18)/a;
       return z;
    }


    function one$toULE() public view returns(uint256)
    {
        uint256 a =BnbtoBusd();
        uint256 b = a*ULEtobnb();
        return b/1e18;
    }

// ULE token 0x3a549866a592C81719F3b714a356A8879E20F5d0
// BUSD 0xe9e7cea3dedca5984780bafc599bd69add087d56
// BNBtoBUSDLP 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16
// ULEtoBNBLP 0x718cEc478B7cEBfe7dC4986D295065e3cb60E635





}