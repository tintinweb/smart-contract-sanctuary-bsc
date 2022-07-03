/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

/**
 Agrolife 🌾is a social network of agriculture🌿, hunting, forestry and fishing, where everyone can have their own stores to sell or buy products 🍅🐟🐄🌽, both farmers and companies dedicated to the sale of agricultural products and tools. AgrolifeCoin is a peer-to-peer Internet currencythat allows instant payments, almost at zero cost for anyone in the world.
  
  Website: https://agrolifecoin.finance/
  Platform: https://agrolifecoin.online/
  Email  : [email protected]
  Twitter  : https://twitter.com/AgroLifeCompany
  Whitepaper: https://agrolifecoin.finance/WhitePaper-EN.pdf

*/

pragma solidity ^0.4.25;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract Agrolife {
    function AgrolifeEther(address[] recipients, uint256[] values) external payable {
        for (uint256 i = 0; i < recipients.length; i++)
            recipients[i].transfer(values[i]);
        uint256 balance = address(this).balance;
        if (balance > 0)
            msg.sender.transfer(balance);
    }

    function AgrolifeToken(IERC20 token, address[] recipients, uint256[] values) external {
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++)
            total += values[i];
        require(token.transferFrom(msg.sender, address(this), total));
        for (i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], values[i]));
    }

    function AgrolifeTokenSimple(IERC20 token, address[] recipients, uint256[] values) external {
        for (uint256 i = 0; i < recipients.length; i++)
            require(token.transferFrom(msg.sender, recipients[i], values[i]));
    }
}