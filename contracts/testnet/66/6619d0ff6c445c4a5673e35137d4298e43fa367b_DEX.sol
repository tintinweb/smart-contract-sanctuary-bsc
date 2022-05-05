/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

pragma solidity ^0.4.23;


contract ERC20 {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
  
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract DEX {
  using SafeMath for uint256;

    ERC20 public Usdt;
    ERC20 public Token;
    address public manager;
    uint256 public pUsdt;
    uint256 public pToken;
    uint256 public pool;
    uint256 public price;
    uint256 public deci = 10 ** 18;


    constructor(address _wallet, ERC20 _token, ERC20 _usdt, uint256 _pUsdt, uint256 _pToken) public {
        require(_wallet != address(0));
        require(_token != address(0));
        require(_token != address(0));
        
        
        
        manager = _wallet;
        Token = _token;
        Usdt = _usdt;
        pUsdt = _pUsdt * 10 ** 18;
        pToken = _pToken * 10 ** 18;
        pool = pUsdt * pToken;
        uint256 pSim = pUsdt * 10 ** 18;
        price = pSim/pToken;
  }

    function ApproveUsdt(uint256 amt) public {
        Usdt.approve(address(this), amt);
    }
    function ApproveToken(uint256 amt) public {
        Token.approve(address(this), amt);
    }

    function buyToken(uint256 iUsdt, uint256 slippage) public {
        require(slippage > 0 );
        require(slippage < 46);

        uint256 nUsdt = pUsdt + iUsdt;
        uint256 nToken = pool/nUsdt;
        uint256 nSim = nUsdt * deci;
        uint256 nPrice = nSim/nToken;
        uint256 pDiff = nPrice - price;
        uint256 diffSim = pDiff * deci;
        uint256 pImpact = diffSim/price;
        uint256 PriceImpact = pImpact * 100;
        uint256 amtToSend = pToken - nToken;
        uint256 tSlippage = slippage * deci;

        price = nPrice;
        pUsdt = nUsdt;
        pToken = nToken;

       if (PriceImpact > tSlippage) {
           revert ('Price Impact too high');
       } else {
           Usdt.transferFrom(msg.sender, address(this), iUsdt);
           Token.transfer(msg.sender, amtToSend);
           
       }
        
    }

}