pragma solidity 0.8.11;

// SPDX-License-Identifier: MIT

import "Token.sol";
import "Ownable.sol";
import "SafeMath.sol";

contract ECG_IDO is Ownable {
    using SafeMath for uint256;

    address public ecgToken = 0x110db3aacC2d49a66f05D2F074064FA0ab4491F6;
    address public busdToken = 0x50786816F3aF4a087011AaEE308Ae2dD515C375B;

    uint256 public tokenPrice = 5e3;
    uint256 public minAmount = 1e20;
    uint256 public maxAmount = 3e20;
    uint256 private divUint = 1e2;

    bool public isIdoActivated = false;
    bool public CanWithdrawTwentyPercent = false;
    bool public CanWithdrawFortyPercent = false;
    bool public CanWithdrawSixtyPercent = false;
    bool public CanWithdrawEightyPercent = false;
    bool public CanWithdrawAll = false;

    mapping (address => uint256) public totalBoughtAmount;
    mapping (address => uint256) public totalWithdrawnAmount;
    mapping (address => uint256) public remainingWithdrawnAmount;
    mapping (address => uint256) private totalClaimed;

    function swap(uint256 amount) public {
        require(isIdoActivated, "ECG_IDO: IDO is not activated..");
        require(amount >= minAmount && amount <= maxAmount, "ECG_IDO: Please enter a valid amount..");
        uint256 tokenAmount = amount.mul(tokenPrice).div(divUint);
        totalBoughtAmount[msg.sender] = totalBoughtAmount[msg.sender].add(tokenAmount);
        remainingWithdrawnAmount[msg.sender] = remainingWithdrawnAmount[msg.sender].add(tokenAmount);
        
        if (amount > 0) {
            Token(busdToken).transferFrom(msg.sender, address(this), amount);
        }
    }

    function getTotalBoughtToken(address userAdd) public view returns (uint256) {
        return totalBoughtAmount[userAdd];
    }

    function getRemainingWithdrawToken(address userAdd) public view returns (uint256) {
        return remainingWithdrawnAmount[userAdd];
    }

    function withdrawToken() public {
        uint256 amount = totalBoughtAmount[msg.sender];
		
        uint256 currentWithdrawAmount;
        uint256 twentyPercent = amount.div(5);

        if (CanWithdrawTwentyPercent
        && !CanWithdrawFortyPercent
        && !CanWithdrawSixtyPercent
        && !CanWithdrawEightyPercent
        && !CanWithdrawAll) {
            if (totalClaimed[msg.sender] == 0) {
                currentWithdrawAmount = twentyPercent;
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(1);
            }
        }
        if (CanWithdrawTwentyPercent
        && CanWithdrawFortyPercent
        && !CanWithdrawSixtyPercent
        && !CanWithdrawEightyPercent
        && !CanWithdrawAll) {
            if (totalClaimed[msg.sender] == 0) {
                currentWithdrawAmount = twentyPercent.mul(2);
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(2);
            }
            if (totalClaimed[msg.sender] == 1) {
                currentWithdrawAmount = twentyPercent;
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(1);
            }
        }
        if (CanWithdrawTwentyPercent
        && CanWithdrawFortyPercent
        && CanWithdrawSixtyPercent
        && !CanWithdrawEightyPercent
        && !CanWithdrawAll) {
            if (totalClaimed[msg.sender] == 0) {
                currentWithdrawAmount = twentyPercent.mul(3);
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(3);
            }
            if (totalClaimed[msg.sender] == 1) {
                currentWithdrawAmount = twentyPercent.mul(2);
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(2);
            }
            if (totalClaimed[msg.sender] == 2) {
                currentWithdrawAmount = twentyPercent;
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(1);
            }
        }
        if (CanWithdrawTwentyPercent
        && CanWithdrawFortyPercent
        && CanWithdrawSixtyPercent
        && CanWithdrawEightyPercent
        && !CanWithdrawAll) {
            if (totalClaimed[msg.sender] == 0) {
                currentWithdrawAmount = twentyPercent.mul(4);
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(4);
            }
            if (totalClaimed[msg.sender] == 1) {
                currentWithdrawAmount = twentyPercent.mul(3);
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(3);
            }
            if (totalClaimed[msg.sender] == 2) {
                currentWithdrawAmount = twentyPercent.mul(2);
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(2);
            }
            if (totalClaimed[msg.sender] == 3) {
                currentWithdrawAmount = twentyPercent;
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(1);
            }
        }
        if (CanWithdrawTwentyPercent
        && CanWithdrawFortyPercent
        && CanWithdrawSixtyPercent
        && CanWithdrawEightyPercent
        && CanWithdrawAll) {
            if (totalClaimed[msg.sender] == 0) {
                currentWithdrawAmount = twentyPercent.mul(4);
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(4);
            }
            if (totalClaimed[msg.sender] == 1) {
                currentWithdrawAmount = twentyPercent.mul(3);
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(3);
            }
            if (totalClaimed[msg.sender] == 2) {
                currentWithdrawAmount = twentyPercent.mul(2);
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(2);
            }
            if (totalClaimed[msg.sender] == 3) {
                currentWithdrawAmount = twentyPercent;
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(1);
            }
            if (totalClaimed[msg.sender] == 4) {
                currentWithdrawAmount = twentyPercent;
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(1);
            }
        }
        
        remainingWithdrawnAmount[msg.sender] = remainingWithdrawnAmount[msg.sender].sub(currentWithdrawAmount);
        totalWithdrawnAmount[msg.sender] = totalWithdrawnAmount[msg.sender].add(currentWithdrawAmount);
        
        require(currentWithdrawAmount > 0, "ECG_IDO: No token available for withdraw..");
        Token(ecgToken).transfer(msg.sender, currentWithdrawAmount);
    }

    function ActiveTheIDO() public onlyOwner {
        require(!isIdoActivated, "ECG_IDO: IDO alredy activated..");
        isIdoActivated = true;
    }

    function DeactiveTheIDO() public onlyOwner {
        require(isIdoActivated, "ECG_IDO: IDO alredy deactivated..");
        isIdoActivated = true;
    }

    function updateDivUint(uint256 newDiv) public onlyOwner {
        divUint = newDiv;
    }

    function updateTokenPrice(uint256 newPrice) public onlyOwner {
        tokenPrice = newPrice;
    }

    function updateMinimumAmount(uint256 newAmount) public onlyOwner {
        require(newAmount != minAmount, "ECG_IDO: The minimum amount is the same that you enterd..");
        minAmount = newAmount;
    }

    function updateMaximumAmount(uint256 newAmount) public onlyOwner {
        require(newAmount != maxAmount, "ECG_IDO: The maximum amount is the same that you enterd..");
        maxAmount = newAmount;
    }

    function updateECG_TokenAddress(address ecgAdd) public onlyOwner {
        require(ecgToken != ecgToken, "ECG_IDO: The ECG address is this the same that you enterd..");
        ecgToken = ecgAdd;
    }

    function updateBUSD_TokenAddress(address busdAdd) public onlyOwner {
        require(busdToken != busdToken, "ECG_IDO: The BUSD address is the same that you enterd..");
        busdToken = busdAdd;
    }

    function enableTwentyPercentWithdraw() public onlyOwner {
        CanWithdrawTwentyPercent = true;
    }

    function enableFortyPercentWithdraw() public onlyOwner {
        require(CanWithdrawTwentyPercent, "ECG_IDO: Please enable twenty percent withdrow first..");
        CanWithdrawFortyPercent = true;
    }

    function enableSixtyPercentWithdraw() public onlyOwner {
        require(CanWithdrawTwentyPercent && CanWithdrawFortyPercent, "ECG_IDO: Please enable twenty & forty percent withdrow first..");
        CanWithdrawSixtyPercent = true;
    }

    function enableEightyPercentWithdraw() public onlyOwner {
        require(CanWithdrawTwentyPercent && CanWithdrawFortyPercent && CanWithdrawSixtyPercent, "ECG_IDO: Please enable twenty, forty & sixty percent withdrow first..");
        CanWithdrawEightyPercent = true;
    }

    function enableWithdrawForAll() public onlyOwner {
        require(CanWithdrawTwentyPercent && CanWithdrawFortyPercent && CanWithdrawSixtyPercent && CanWithdrawEightyPercent, "ECG_IDO: Please enable twenty, forty, sixty & eighty percent withdrow first..");
        CanWithdrawAll = true;
    }

    function transferAnyToken(address token, address to, uint256 amount) public onlyOwner {
        Token(token).transfer(to, amount);
    }
}