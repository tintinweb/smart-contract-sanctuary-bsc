/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

pragma solidity ^0.4.21;

interface IERC20Token {
    function balanceOf(address owner) public returns (uint256);
    function transfer(address to, uint256 amount) public returns (bool);
    function decimals() public returns (uint256);
}

contract TokenFaucet {
    IERC20Token public tokenContract;  // the token being sent Faucet
    uint256 public price;              // the price, in wei, per token
    uint256 public tokenamount;
    address owner;

    uint256 public tokensGiven;

    event Given(address fauceter, uint256 amount);

    function Tokendrip(IERC20Token _tokenContract, uint256 _price, uint256 _Tokenamount) public {
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
        require(msg.value == safeMultiply(tokenamount, price));

        uint256 scaledAmount = safeMultiply(tokenamount,
            uint256(10) ** tokenContract.decimals());

        require(tokenContract.balanceOf(this) >= scaledAmount);

        emit Given(msg.sender, tokenamount);
        tokensGiven += tokenamount;

        require(tokenContract.transfer(msg.sender, scaledAmount));
    }

    function gimmeSome() public payable {
         require(msg.value == price, 'Need to send some ETH');

    }
    

    function enddrip() public {
        require(msg.sender == owner);

        // Send unGiven tokens to the owner.
        require(tokenContract.transfer(owner, tokenContract.balanceOf(this)));

        msg.sender.transfer(address(this).balance);
    }

    function removeFee() public {
        require(msg.sender == owner);

        msg.sender.transfer(address(this).balance);
    }
}