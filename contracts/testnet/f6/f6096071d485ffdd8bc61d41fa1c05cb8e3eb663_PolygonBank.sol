/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 *ERC20 Interface standard for bank interaction
*/
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/**
 *Safemath Library for uint
*/
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract PolygonBank {
    using SafeMath for uint;
    IERC20 public USDC;
    IERC20 public USDT;
    IERC20 public DAI;

    enum Currency{USDC, USDT, DAI}

    struct Savings{
        uint My_USDC_Balance; //Usdc Balance of user
        uint My_USDT_Balance; //Usdt Balance of user
        uint My_DAI_Balance; //DAI Balance of user
        uint My_Net_Worth; //Total Net woth of user
    }

    mapping(address => Savings) public SAVINGS;

    constructor(IERC20 _usdc, IERC20 _usdt, IERC20 _dai) {
        USDC = _usdc;
        USDT = _usdt;
        DAI = _dai;
    }

    function deposit(uint depositAmount, Currency _currency)public{
        Savings storage savings = SAVINGS[msg.sender];
        if (_currency == Currency.USDC) {
            require(USDC.balanceOf(msg.sender) > depositAmount, 
                "YOU DON'T HAVE ENOUGH USDC TO COMPLETE THIS DEPOSIT");
            USDC.transferFrom(msg.sender, address(this), depositAmount);
            savings.My_USDC_Balance += depositAmount;
            savings.My_Net_Worth += depositAmount;
        }
        if (_currency == Currency.USDT) {
            require(USDT.balanceOf(msg.sender) > depositAmount, 
                "YOU DON'T HAVE ENOUGH USDT TO COMPLETE THIS DEPOSIT");
            USDT.transferFrom(msg.sender, address(this), depositAmount);
            savings.My_USDT_Balance += depositAmount;
            savings.My_Net_Worth += depositAmount;
        }
        if (_currency == Currency.DAI) {
            require(DAI.balanceOf(msg.sender) > depositAmount, 
                "YOU DON'T HAVE ENOUGH DAI TO COMPLETE THIS DEPOSIT");
            DAI.transferFrom(msg.sender, address(this), depositAmount);
            savings.My_DAI_Balance += depositAmount;
            savings.My_Net_Worth += depositAmount;
        }
    }

    function transferInternal(uint transferAmount, address recipient, Currency _currency) public{
        Savings storage savings = SAVINGS[msg.sender];
        Savings storage reciever = SAVINGS[recipient];
        if (_currency == Currency.USDC) {
            require(savings.My_USDC_Balance > transferAmount, 
                "YOU DO NOT HAVE ENOUGH USDC IN YOUR SAVINGS TO COMPLETE THIS TRANSFER");
            savings.My_USDC_Balance -= transferAmount;
            reciever.My_USDC_Balance += transferAmount;
            savings.My_Net_Worth -= transferAmount;
            reciever.My_Net_Worth += transferAmount;
        }
        if (_currency == Currency.USDT) {
            require(savings.My_USDT_Balance > transferAmount, 
                "YOU DO NOT HAVE ENOUGH USDT IN YOUR SAVINGS TO COMPLETE THIS TRANSFER");
            savings.My_USDT_Balance -= transferAmount;
            reciever.My_USDT_Balance += transferAmount;
            savings.My_Net_Worth -= transferAmount;
            reciever.My_Net_Worth += transferAmount;
        }
        if (_currency == Currency.DAI) {
            require(savings.My_DAI_Balance > transferAmount, 
                "YOU DO NOT HAVE ENOUGH DAI IN YOUR SAVINGS TO COMPLETE THIS TRANSFER");
            savings.My_USDC_Balance -= transferAmount;
            reciever.My_USDC_Balance += transferAmount;
            savings.My_Net_Worth -= transferAmount;
            reciever.My_Net_Worth += transferAmount;
        }
    }

    function transferExternal(uint transferAmount, address recipient, Currency _currency)public{
        Savings storage savings = SAVINGS[msg.sender];
        if (_currency == Currency.USDC) {
            require(savings.My_USDC_Balance > transferAmount, 
                "YOU DO NOT HAVE ENOUGH USDC IN YOUR SAVINGS TO COMPLETE THIS WITHDRAWAL");
            USDC.transfer(recipient, transferAmount);
            savings.My_USDC_Balance -= transferAmount;
            savings.My_Net_Worth -= transferAmount;
        }
        if (_currency == Currency.USDT) {
            require(savings.My_USDT_Balance > transferAmount, 
                "YOU DO NOT HAVE ENOUGH USDT IN YOUR SAVINGS TO COMPLETE THIS WITHDRAWAL");
            USDT.transfer(recipient, transferAmount);
            savings.My_USDT_Balance -= transferAmount;
            savings.My_Net_Worth -= transferAmount;
        }
        if (_currency == Currency.DAI) {
            require(savings.My_DAI_Balance > transferAmount, 
                "YOU DO NOT HAVE ENOUGH DAI IN YOUR SAVINGS TO COMPLETE THIS WITHDRAWAL");
            DAI.transfer(recipient, transferAmount);
            savings.My_DAI_Balance -= transferAmount;
            savings.My_Net_Worth -= transferAmount;
        }
    }


    function withdraw(uint withdrawAmount, Currency _currency)public{
        Savings storage savings = SAVINGS[msg.sender];
        if (_currency == Currency.USDC) {
            require(savings.My_USDC_Balance > withdrawAmount, 
                "YOU DO NOT HAVE ENOUGH USDC IN YOUR SAVINGS TO COMPLETE THIS WITHDRAWAL");
            USDC.transfer(msg.sender, withdrawAmount);
            savings.My_USDC_Balance -= withdrawAmount;
            savings.My_Net_Worth -= withdrawAmount;
        }
        if (_currency == Currency.USDT) {
            require(savings.My_USDT_Balance > withdrawAmount, 
                "YOU DO NOT HAVE ENOUGH USDT IN YOUR SAVINGS TO COMPLETE THIS WITHDRAWAL");
            USDT.transfer(msg.sender, withdrawAmount);
            savings.My_USDT_Balance -= withdrawAmount;
            savings.My_Net_Worth -= withdrawAmount;
        }
        if (_currency == Currency.DAI) {
            require(savings.My_DAI_Balance > withdrawAmount, 
                "YOU DO NOT HAVE ENOUGH DAI IN YOUR SAVINGS TO COMPLETE THIS WITHDRAWAL");
            DAI.transfer(msg.sender, withdrawAmount);
            savings.My_DAI_Balance -= withdrawAmount;
            savings.My_Net_Worth -= withdrawAmount;
        }
    }

    function withdrawAll()public{
        Savings storage savings = SAVINGS[msg.sender];
        USDC.transfer(msg.sender, savings.My_USDC_Balance);
        USDT.transfer(msg.sender, savings.My_USDT_Balance);
        DAI.transfer(msg.sender, savings.My_DAI_Balance);
        savings.My_USDC_Balance = 0;
        savings.My_USDT_Balance = 0;
        savings.My_DAI_Balance = 0;
        savings.My_Net_Worth = 0;
    }

    
}