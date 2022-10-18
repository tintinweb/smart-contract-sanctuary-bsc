pragma solidity >0.5.0;

import "./Token.sol";

contract TokenSaleContract {
    address admin;
    TokenContract public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;

    event Sell(address _buyer, uint256 _amount);

    constructor(TokenContract _tokenContract, uint256 _tokenPrice) public {
        admin = address(this);
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;

        _tokenContract.mint(address(this), 1000000000000000000000000);
    }

    // function multiply(uint x, uint y) internal pure returns (uint z) {
    //     require(y == 0 || (z = x * y) / y == x);
    // }

    function buyTokens(uint256 _numberOfTokens) public payable {
        // require(msg.value == multiply(_numberOfTokens, tokenPrice));
        require(tokenContract.balanceOf(admin) >= _numberOfTokens);
        require(tokenContract.transfer(msg.sender, _numberOfTokens));
        tokensSold += _numberOfTokens;
        emit Sell(msg.sender, _numberOfTokens);
    }

    function balanceTokens() public returns (uint) {
        return tokenContract.balanceOf(admin);
    }

}