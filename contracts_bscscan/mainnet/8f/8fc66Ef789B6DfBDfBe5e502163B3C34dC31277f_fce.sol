/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

pragma solidity >=0.4.0 <0.7.0;

contract fce{
    string public name = "Focusrite";
    uint8 public decimals = 18;
    string public symbol = "fce";
    string public version = '1.0';

    // Maximum number of Agcoin available for sale
    uint public max_agcoins = 1000000;
    uint totalSupply = 100000000000000000;
    // USD to Agcoin conversion rate
    uint public usd_to_agcoins = 1;
    // Total number of Agcoin bought by the investors
    uint public total_agcoins_bought = 0;
    // Mapping from the investor address to its equity in Agcoins and USD
    mapping(address => uint) agcoin_equity;
    mapping(address => uint) usd_equity;

    // Check if an investor can buy Agcoins
    modifier can_buy_agcoins(uint usd_invested){
        require(
            usd_invested * usd_to_agcoins + total_agcoins_bought <= 1000000,
            "Over investment is not allowed"
        );
        _;
    }

    // Getting the equity in agcoin of an investor
    function equity_in_agcoins(address investor) public view returns (uint){
        return agcoin_equity[investor];
    }

    // Getting the equity in USD of an investor
    function equity_in_usd(address investor) public view returns (uint){
        return usd_equity[investor];
    }

    // Buy Agcoins
    function buy(address investor, uint usd_amt) public can_buy_agcoins(usd_amt)  {
        uint agcoins_bought = usd_amt * usd_to_agcoins;
        agcoin_equity[investor] += agcoins_bought; // Store in array; Update if added more
        usd_equity[investor] = agcoin_equity[investor]/usd_to_agcoins; // Update total usd_amt invested
        total_agcoins_bought += agcoins_bought;
    }

    // Refund Usd
    function refund(address investor, uint amt) public {
        agcoin_equity[investor] -= amt;
        usd_equity[investor] = agcoin_equity[investor] / usd_to_agcoins;
        total_agcoins_bought -= amt;
    }

}