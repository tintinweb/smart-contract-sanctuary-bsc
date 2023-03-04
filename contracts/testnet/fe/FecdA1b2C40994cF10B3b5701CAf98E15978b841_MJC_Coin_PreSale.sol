/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.18;

interface IERC20 {
 
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract MJC_Coin_PreSale {

    using SafeMath for uint256;
    IERC20 public token;

    uint256 public rate;    // If rate = 100, then tokensPerBNB is 100
    uint256 public tokensPerUSDT;

    address public perSaleOwner;

    IERC20 USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);

    constructor(address _tokenAddress, address _owner, uint256 _rate, uint256 _tokensPerUSDT) {
        token = IERC20(_tokenAddress);
        perSaleOwner = _owner;
        rate = _rate; 
        tokensPerUSDT = _tokensPerUSDT;
    }

    modifier onlyOwner() {
        require(msg.sender == perSaleOwner, "ONLY_OWNER_CAN_ACCESS_THIS_FUNCTION");
        _;
    }

    function updateRate(uint256 newRate, uint256 newTokensPerUSDT) public onlyOwner() {
        rate = newRate;
        tokensPerUSDT = newTokensPerUSDT;
    }

    function endPreSale() public onlyOwner() {
        uint256 contractTokenBalance = token.balanceOf(address(this));
        token.transfer(msg.sender, contractTokenBalance);
    }

    function buy() public payable {

        uint256 bnbAmountToBuy = msg.value;

        uint256 tokenAmount = bnbAmountToBuy.mul(rate).div(10**8);

        require(token.balanceOf(address(this)) >= tokenAmount, "INSUFFICIENT_BALANCE_IN_CONTRACT");

        payable(perSaleOwner).transfer(bnbAmountToBuy);

        (bool sent) = token.transfer(msg.sender, tokenAmount);
        require(sent, "FAILED_TO_TRANSFER_TOKENS_TO_BUYER");
        
    }

    function buyWithUSDT(uint256 _USDTAmount) public {

        uint256 tokenAmount = _USDTAmount.mul(tokensPerUSDT).div(10**8);

        USDT.transferFrom(msg.sender, perSaleOwner, _USDTAmount);

        require(token.balanceOf(address(this)) >= tokenAmount, "INSUFFICIENT_BALANCE_IN_CONTRACT");

        (bool sent) = token.transfer(msg.sender, tokenAmount);
        require(sent, "FAILED_TO_TRANSFER_TOKENS_TO_BUYER");
        
    }

}