/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function decimal() external view returns(uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient,uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// contract PriceConsumerV3 {
//     AggregatorV3Interface internal priceFeed;

//     /**
//      * Network: Goerli
//      * Aggregator: ETH/USD
//      * Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
//      */
//     constructor() {
//         priceFeed = AggregatorV3Interface(
//             0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
//         );
//     }

//     /**
//      * Returns the latest price
//      */
//     function getLatestPrice() public view returns (int) {
//         (
//             ,
//             /*uint80 roundID*/ int price /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
//             ,
//             ,

//         ) = priceFeed.latestRoundData();
//         return price;
//     }
// }


contract Presale {
    
    IERC20  erc20;
    address  payable tknOwner;
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(IERC20 tokenaddress, address payable  owner){
        erc20 = tokenaddress;
        tknOwner = owner;
    }
        uint Ethr1 = 1 ether;
        uint token = 10;


// Buy tokens through Eth
    function buyThroughEth() public payable{
		require(msg.sender  != address(0), "Null address can't buy token");
		uint amount = msg.value * token * 10**erc20.decimal();
        amount = amount / Ethr1;
        erc20.transferFrom(tknOwner, msg.sender, amount);
        payable(tknOwner).transfer(msg.value);
        emit Transfer(tknOwner, msg.sender, amount);
    } 

    function sell(uint _amountofToken) public payable{
        require(msg.sender != address(0), "Null address");
        uint amount = _amountofToken *  10**erc20.decimal();
        // amount = amount  * Ethr1;
        amount = amount / token;
        erc20.transferFrom(msg.sender,tknOwner, _amountofToken);
        payable(msg.sender).transfer(amount);
        emit Transfer(msg.sender, tknOwner,  _amountofToken );
    }

    // Buy token through USD 
    // function buyThroughUsd() public payable{
    //     require(msg.sender != address(0), "Null address");
    //     uint amount = msg.value * uint(getLatestPrice()) * token *erc20.decimal();
    //     amount = amount/1 ether/1e8;
    //     erc20.transferFrom(tknOwner, msg.sender, amount);
    //     payable(tknOwner).transfer(amount);
    //     emit Transfer(tknOwner, msg.sender, amount);
    // }

}