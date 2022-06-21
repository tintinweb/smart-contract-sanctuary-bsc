/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

pragma solidity ^0.4.21;

interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
   function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}



contract TokenFaucet is Ownable {
    IERC20Token public tokenContract;  // the token being sent Faucet
    uint256 public price;              // the price, in wei, per token
    uint256 public tokenamount;
    address owner;

    uint256 public tokensGiven;

    event Given(address fauceter, uint256 amount);

    function Tokendrip(IERC20Token _tokenContract, uint256 _price, uint256 _Tokenamount) public onlyOwner{
        owner = msg.sender;
        tokenContract = _tokenContract;
        price = _price;
        tokenamount = _Tokenamount;
    }

    // Guards against integer overflows
    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }

    function faucetTokens() external payable {
        //gimmeSome();
        //require(msg.value == safeMultiply(tokenamount, price));
        require(msg.value == price, 'Need to send some ETH');

        uint256 scaledAmount = safeMultiply(tokenamount,
            uint256(10) ** tokenContract.decimals());

        require(tokenContract.balanceOf(this) >= scaledAmount);

        emit Given(msg.sender, tokenamount);
        tokensGiven += tokenamount;

        require(tokenContract.transfer(msg.sender, scaledAmount));
    }

    function gimmeSome() public payable onlyOwner{
         require(msg.value == price, 'Need to send some ETH');

    }
    

    function enddrip() public onlyOwner{
        require(msg.sender == owner);

        // Send unGiven tokens to the owner.
        require(tokenContract.transfer(owner, tokenContract.balanceOf(this)));

        msg.sender.transfer(address(this).balance);
    }

    function removeFee() public onlyOwner{
        require(msg.sender == owner);

        msg.sender.transfer(address(this).balance);
    }
}