pragma solidity 0.8.12;

// SPDX-License-Identifier: MIT

import "Token.sol";
import "Ownable.sol";
import "SafeMath.sol";

contract ECG_IDO is Ownable {
    using SafeMath for uint256;

    address public ecgToken = 0xf002d64DF02f1710EC99bF7084a55A80D4B1B1d8;
    address public busdToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public teamAddress = 0xb86d108Db9b4f0ed493b05FD7aa36C0C576235CB;

    uint256 public tokenPrice = 5e3;
    uint256 public minAmount = 1e20;
    uint256 public maxAmount = 3e20;
    uint256 private divUint = 1e2;

    uint256 public totalSoldOut;
    uint256 public totalSoldOutInBUSD;

    bool public isIdoActivated = false;
    bool public CanWithdrawTwentyPercent = false;
    bool public CanWithdrawFortyPercent = false;
    bool public CanWithdrawSixtyPercent = false;
    bool public CanWithdrawEightyPercent = false;
    bool public CanWithdrawAll = false;
    bool public isIDO_For_All = false;

    mapping (address => uint256) public totalBoughtAmount;
    mapping (address => uint256) public totalWithdrawnAmount;
    mapping (address => uint256) public remainingWithdrawnAmount;
    mapping (address => uint256) public amountCanInvest;
    mapping (address => uint256) public totalInvested;
    mapping (address => uint256) public totalClaimed;
    
    mapping (address => bool) public isWhiteListed;

    function swap(uint256 amount) public {
        require(totalClaimed[msg.sender] == 0, "Please use differant address..");
        require(isIdoActivated, "ECG_IDO: IDO is not activated..");
        require(amount >= minAmount && amount <= maxAmount, "ECG_IDO: Please enter a valid amount..");

        uint256 _remainingAmountCanBuy = maxAmount;

        if (!isIDO_For_All) {
             _remainingAmountCanBuy = remainingAmountCanBuy(msg.sender);
        }

        require(_remainingAmountCanBuy > 0, "ECG_IDO: You have bought maximum amount, No more..");

        if (!isIDO_For_All) {
            require(isWhiteListed[msg.sender], "ECG_IDO: The IDO is whitelisted..");
        }

        if (!isIDO_For_All && amount > _remainingAmountCanBuy) {
            amount = _remainingAmountCanBuy;
        }

        uint256 tokenAmount = amount.mul(tokenPrice).div(divUint);
        totalBoughtAmount[msg.sender] = totalBoughtAmount[msg.sender].add(tokenAmount);
        remainingWithdrawnAmount[msg.sender] = remainingWithdrawnAmount[msg.sender].add(tokenAmount);
        
        if (amount > 0 && isIDO_For_All) {
            Token(busdToken).transferFrom(msg.sender, teamAddress, amount);
            totalInvested[msg.sender] = totalInvested[msg.sender].add(amount);
            totalSoldOut = totalSoldOut.add(tokenAmount);
            totalSoldOutInBUSD = totalSoldOutInBUSD.add(amount);
        }

        if (amount > 0 && !isIDO_For_All) {
            Token(busdToken).transferFrom(msg.sender, teamAddress, amount);
            totalInvested[msg.sender] = totalInvested[msg.sender].add(amount);
            totalSoldOut = totalSoldOut.add(tokenAmount);
            totalSoldOutInBUSD = totalSoldOutInBUSD.add(amount);
        }
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
                currentWithdrawAmount = twentyPercent.mul(5);
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(5);
            }
            if (totalClaimed[msg.sender] == 1) {
                currentWithdrawAmount = twentyPercent.mul(4);
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(4);
            }
            if (totalClaimed[msg.sender] == 2) {
                currentWithdrawAmount = twentyPercent.mul(3);
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(3);
            }
            if (totalClaimed[msg.sender] == 3) {
                currentWithdrawAmount = twentyPercent.mul(2);
                totalClaimed[msg.sender] = totalClaimed[msg.sender].add(2);
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

    function addOnWhiteList(address[] memory user) public onlyOwner {
        
        for (uint256 i = 0; i < user.length; i++) {
            isWhiteListed[user[i]] = true;
            amountCanInvest[user[i]] = maxAmount;
        }
    }

    function enable_IDO_For_All() public onlyOwner {
        require(!isIDO_For_All, "ECG_IDO: Alredy enabled..");
        isIDO_For_All = true;
    }

    function disable_IDO_For_All() public onlyOwner {
        require(isIDO_For_All, "ECG_IDO: Alredy disabled..");
        isIDO_For_All = false;
    }

    function remainingAmountCanBuy(address user) public view returns (uint256) {
        uint256 amount = amountCanInvest[user].sub(totalInvested[user]);
        return amount;
    }

    function isTheAddressWhiteListed(address user) public view returns (bool) {
        return isWhiteListed[user];
    }

    function getTotalSoldOut() public view returns (uint256) {
        return totalSoldOut;
    }

    function getTotalSoldOutInBUSD() public view returns (uint256) {
        return totalSoldOutInBUSD;
    }

    function getTotalBoughtToken(address userAdd) public view returns (uint256) {
        return totalBoughtAmount[userAdd];
    }

    function getRemainingWithdrawToken(address userAdd) public view returns (uint256) {
        uint256 amount = totalBoughtAmount[userAdd];
		
        uint256 currentWithdrawAmount;
        uint256 twentyPercent = amount.div(5);
        
        if (CanWithdrawTwentyPercent
        && !CanWithdrawFortyPercent
        && !CanWithdrawSixtyPercent
        && !CanWithdrawEightyPercent
        && !CanWithdrawAll) {
            if (totalClaimed[msg.sender] == 0) {
                currentWithdrawAmount = twentyPercent;
            }
        }
        if (CanWithdrawTwentyPercent
        && CanWithdrawFortyPercent
        && !CanWithdrawSixtyPercent
        && !CanWithdrawEightyPercent
        && !CanWithdrawAll) {
            if (totalClaimed[msg.sender] == 0) {
                currentWithdrawAmount = twentyPercent.mul(2);
            }
            if (totalClaimed[msg.sender] == 1) {
                currentWithdrawAmount = twentyPercent;
            }
        }
        if (CanWithdrawTwentyPercent
        && CanWithdrawFortyPercent
        && CanWithdrawSixtyPercent
        && !CanWithdrawEightyPercent
        && !CanWithdrawAll) {
            if (totalClaimed[msg.sender] == 0) {
                currentWithdrawAmount = twentyPercent.mul(3);
            }
            if (totalClaimed[msg.sender] == 1) {
                currentWithdrawAmount = twentyPercent.mul(2);
            }
            if (totalClaimed[msg.sender] == 2) {
                currentWithdrawAmount = twentyPercent;
            }
        }
        if (CanWithdrawTwentyPercent
        && CanWithdrawFortyPercent
        && CanWithdrawSixtyPercent
        && CanWithdrawEightyPercent
        && !CanWithdrawAll) {
            if (totalClaimed[msg.sender] == 0) {
                currentWithdrawAmount = twentyPercent.mul(4);
            }
            if (totalClaimed[msg.sender] == 1) {
                currentWithdrawAmount = twentyPercent.mul(3);
            }
            if (totalClaimed[msg.sender] == 2) {
                currentWithdrawAmount = twentyPercent.mul(2);
            }
            if (totalClaimed[msg.sender] == 3) {
                currentWithdrawAmount = twentyPercent;
            }
        }
        if (CanWithdrawTwentyPercent
        && CanWithdrawFortyPercent
        && CanWithdrawSixtyPercent
        && CanWithdrawEightyPercent
        && CanWithdrawAll) {
            if (totalClaimed[msg.sender] == 0) {
                currentWithdrawAmount = twentyPercent.mul(5);
            }
            if (totalClaimed[msg.sender] == 1) {
                currentWithdrawAmount = twentyPercent.mul(4);
            }
            if (totalClaimed[msg.sender] == 2) {
                currentWithdrawAmount = twentyPercent.mul(3);
            }
            if (totalClaimed[msg.sender] == 3) {
                currentWithdrawAmount = twentyPercent.mul(2);
            }
            if (totalClaimed[msg.sender] == 4) {
                currentWithdrawAmount = twentyPercent;
            }
        }

        return currentWithdrawAmount;
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

    function updateTeam_Address(address teamAdd) public onlyOwner {
        require(teamAddress != teamAdd, "ECG_IDO: The team address is this the same that you enterd..");
        teamAddress = teamAdd;
    }

    function updateBUSD_TokenAddress(address busdAdd) public onlyOwner {
        require(busdToken != busdToken, "ECG_IDO: The BUSD address is the same that you enterd..");
        busdToken = busdAdd;
    }

    function enableTwentyPercentWithdraw() public onlyOwner {
        require(!CanWithdrawTwentyPercent, "ECG_IDO: Alredy enabled..");
        CanWithdrawTwentyPercent = true;
    }

    function enableFortyPercentWithdraw() public onlyOwner {
        require(!CanWithdrawFortyPercent, "ECG_IDO: Alredy enabled..");
        require(CanWithdrawTwentyPercent, "ECG_IDO: Please enable twenty percent withdrow first..");
        CanWithdrawFortyPercent = true;
    }

    function enableSixtyPercentWithdraw() public onlyOwner {
        require(!CanWithdrawSixtyPercent, "ECG_IDO: Alredy enabled..");
        require(CanWithdrawTwentyPercent && CanWithdrawFortyPercent, "ECG_IDO: Please enable twenty & forty percent withdrow first..");
        CanWithdrawSixtyPercent = true;
    }

    function enableEightyPercentWithdraw() public onlyOwner {
        require(!CanWithdrawEightyPercent, "ECG_IDO: Alredy enabled..");
        require(CanWithdrawTwentyPercent && CanWithdrawFortyPercent && CanWithdrawSixtyPercent, "ECG_IDO: Please enable twenty, forty & sixty percent withdrow first..");
        CanWithdrawEightyPercent = true;
    }

    function enableWithdrawForAll() public onlyOwner {
        require(!CanWithdrawAll, "ECG_IDO: Alredy enabled..");
        require(CanWithdrawTwentyPercent && CanWithdrawFortyPercent && CanWithdrawSixtyPercent && CanWithdrawEightyPercent, "ECG_IDO: Please enable twenty, forty, sixty & eighty percent withdrow first..");
        CanWithdrawAll = true;
    }

    function transferAnyToken(address token, address to, uint256 amount) public onlyOwner {
        Token(token).transfer(to, amount);
    }
}