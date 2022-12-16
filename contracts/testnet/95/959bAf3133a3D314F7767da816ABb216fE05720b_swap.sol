/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IBEP20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
contract swap{
    address public owner;
    uint public fee;
    //IBEP20 token1;
    //IBEP20 token2;

    mapping(string => Coin) public TokenMapping;

    struct Coin{
        string Symbol;
        address TokenAddress;
        uint price;
    }

    constructor(uint _fee) {
        owner = msg.sender;
        fee = _fee;
    }
    function createTokenPair (string memory _symbol, address _token, uint price) public {
        require(msg.sender == owner, "Not an owner");
        Coin memory tokens = Coin({
           Symbol: _symbol,
           TokenAddress: _token,
           price: price
        });
        TokenMapping[_symbol] = tokens;
    }
    function swapToken(string memory token1, string memory token2, uint _amount) public{
        uint price1 = TokenMapping[token1].price*_amount;
        uint price2 = TokenMapping[token2].price;
        uint Tamount = price1/price2;
        //uint tamt = Tamount*(10**18);
        address Token1 = TokenMapping[token1].TokenAddress;
        address Token2 = TokenMapping[token2].TokenAddress;
        IBEP20(Token1).transferFrom(msg.sender, address(this), _amount);
        uint percent = 100-fee;
        uint tamt1 = (percent*Tamount)/100;
        IBEP20(Token2).transfer(msg.sender, tamt1);

    }
    function swapBNB (string memory token1,string memory token2) public payable {
        uint price1 = TokenMapping[token1].price *msg.value;
        uint price2 = TokenMapping[token2].price;
        uint Tamount = price1/price2;
        payable(owner).transfer(msg.value);
        address Token2 = TokenMapping[token2].TokenAddress;
        uint tamt1 = (fee*Tamount)/100;
        IBEP20(Token2).transfer(msg.sender, tamt1);
    }

}