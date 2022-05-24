/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

/******************************
*
*   Step - Run - Drink
*
*   Website: https://hyperrun.app
*
*   Telegram Channel: https://t.me/HyperRun_Ann
*
*   Telegram Chat: https://t.me/HyperRunGlobal
*
*   Twitter: https://twitter.com/HyperRunGlobal
*
******************************/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface ERC20TokenInterface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/**
 * Math operations with safety checks that throw on overflows.
 */
library SafeMath {

    function mul (uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b);
        return c;
    }

    function div (uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    function sub (uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add (uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
        return c;
    }

}

contract HyperRunBox {
    using SafeMath for uint256;

    address public owner;

    uint256 tokenCounter = 1;
    uint256 public MAX_TOKENS = 2000; // maximum supply
    uint256 public buyPrice = 300000000000000000; // 0.3

    struct BuyInfo {
        uint256 amount;
        uint256 totalBox;
    }

    mapping(address => BuyInfo) public buyList;

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller must be owner");
        _;
    }

    constructor () {
        owner = msg.sender;
    }

    function totalSupply() public view returns(uint256) {
        return MAX_TOKENS;
    }

    function buyedSupply() public view returns(uint256) {
        return tokenCounter - 1;
    }

    function buyBox() public payable {
        require(tokenCounter <= MAX_TOKENS, "Max supply");
        buyList[msg.sender].amount = buyList[msg.sender].amount + buyPrice;
        buyList[msg.sender].totalBox = buyList[msg.sender].totalBox + 1;
        tokenCounter = tokenCounter + 1;
    }

    function updateBuyPrice(uint256 _price) public onlyOwner {
        buyPrice = _price;
    }

    function withdrawFunds() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawTokens(address tokenAddress) public onlyOwner {
        ERC20TokenInterface token = ERC20TokenInterface(tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

}