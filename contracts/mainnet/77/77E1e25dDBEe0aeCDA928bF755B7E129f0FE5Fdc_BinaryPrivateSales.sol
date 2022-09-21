/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface BEP20 {
    function balanceOf(address _addr) external view returns(uint);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract BinaryPrivateSales {
    address public admin;
    uint public price;
    address public BNRY;
    address[] public acceptedCoins;
    uint constant million = 10**24;
    uint public minToBuy;
    uint public checkPoint;
    uint public soldTokens;
    mapping(address => uint) allowanceToBuy;
    bool public isAllowed;
    bool isInit;
    bool public salesClosed;

    event newPurchase(address _purchaser, uint _bnryAmount, uint _forTokenAmount, uint timestamp);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin!");
        _;
    }

    modifier onlyInited() {
        require(isInit, "Contract is not inited!");
        _;
    }


    // Admin

    function initContract(address _addrTokenBNRY) external onlyAdmin returns(bool) {
        require(!isInit, "Contract is already inited!");
        require(_addrTokenBNRY != address(0), "Error address Zero!");
        acceptedCoins = [0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d, 
                         0x55d398326f99059fF775485246999027B3197955, 
                         0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56];
        price = 5;
        BNRY = _addrTokenBNRY;
        checkPoint = million;
        minToBuy = 100*10**18;
        isInit = true;
        return true;
    }

    function moveBinaryToken(uint _amount, address _addr) external onlyAdmin returns(bool) {
        require(getContractBalance() >= _amount, "Contract balance il lower then your request!");
        BEP20(BNRY).transfer(_addr, _amount);
        soldTokens += _amount;
        if (soldTokens >= checkPoint) {
            changePrice();
        }
        return true;
    }

    function allowAddressToBuyAmount(address _addr, uint _amount) external onlyAdmin returns(bool) {
        require(_addr != address(0), "Error address Zero!");
        allowanceToBuy[_addr] += _amount;
        return true;
    }

    function removeAllowanceToBuy(address _addr) external onlyAdmin returns(bool) {
        require(_addr != address(0), "Error address Zero!");
        allowanceToBuy[_addr] = 0;
        return true;
    }

    function togglePermisionToBuy() external onlyAdmin returns(bool) {
        if (isAllowed) {
            isAllowed = false;
        } else {
            isAllowed = true;
        }
        return true;
    }

    function transferAdminship(address _addr) external onlyAdmin returns(bool) {
        admin = _addr;
        return true;
    }


    // View 

    function getInfo() external view returns(uint, uint, uint) {
        return (price, soldTokens, checkPoint);
    }

    function calcAmountToApprove(uint _bnryAmount) external view returns(uint usdAmount) {
        usdAmount = (_bnryAmount * price) / 100;
    }

    function getAllowanceToBuy(address _addr) external view returns(uint) {
        return allowanceToBuy[_addr];
    }

    function getContractBalance() public view returns(uint balance) {
        balance = BEP20(BNRY).balanceOf(address(this));
    }


    // User

    function buyAllTokens(uint _idx) external onlyInited returns(bool) {
        uint bnryAmount = checkPoint - soldTokens;
        if (!isAllowed && msg.sender != admin) {
            require(allowanceToBuy[msg.sender] >= bnryAmount, "Allovance is to low!");
        }
        require(!salesClosed, "Sale is closed!");
        uint amount = (bnryAmount * price) / 100;
        soldTokens += bnryAmount;
        BEP20(acceptedCoins[_idx]).transferFrom(msg.sender, admin, amount);
        BEP20(BNRY).transfer(msg.sender, bnryAmount);
        if (!isAllowed && msg.sender != admin) {
            allowanceToBuy[msg.sender] -= bnryAmount;
        }
        changePrice();
        emit newPurchase(msg.sender, bnryAmount, price, block.timestamp);
        return true;
    }

    function buyExactBinaryForTokens(uint _bnryAmount, uint _idx) external onlyInited returns(bool) {
        if (!isAllowed && msg.sender != admin) {
            require(allowanceToBuy[msg.sender] >= _bnryAmount, "Allovance is to low!");
        }
        require(checkPoint >= soldTokens + _bnryAmount && !salesClosed, "Contract balance is lower then your request!");
        require(minToBuy <= _bnryAmount, "Should buy at least 100 binary coin!");
        uint amount = (_bnryAmount * price) / 100;
        soldTokens += _bnryAmount;
        BEP20(acceptedCoins[_idx]).transferFrom(msg.sender, admin, amount);
        BEP20(BNRY).transfer(msg.sender, _bnryAmount);
        if (!isAllowed && msg.sender != admin) {
            allowanceToBuy[msg.sender] -= _bnryAmount;
        }
        if (soldTokens == checkPoint) {
            changePrice();
        }
        emit newPurchase(msg.sender, _bnryAmount, price, block.timestamp);
        return true;
    }

    function buyBinaryForExactTokens(uint _usdToken, uint _idx) external onlyInited returns(bool) {
        uint bnryAmount = (_usdToken / price) * 100;
        require(checkPoint >= soldTokens + bnryAmount && !salesClosed, "Contract balance is lower then your request!");
        require(minToBuy <= bnryAmount, "Should buy at least 100 binary coin!");
        if (!isAllowed && msg.sender != admin) {
            require(allowanceToBuy[msg.sender] >= bnryAmount, "Allovance is to low!");
        }
        soldTokens += bnryAmount;
        require(BEP20(acceptedCoins[_idx]).transferFrom(msg.sender, admin, _usdToken), "Error durring transfer USD!");
        require(BEP20(BNRY).transfer(msg.sender, bnryAmount), "Error durring transfer BNRY!");
        if (!isAllowed && msg.sender != admin) {
            allowanceToBuy[msg.sender] -= bnryAmount;
        }
        if (soldTokens == checkPoint) {
            changePrice();
        }
        emit newPurchase(msg.sender, bnryAmount, price, block.timestamp);
        return true;
    }

    function changePrice() internal {
        if (price == 5) {
            price = 10;
            checkPoint += million;
        }
        else if (price == 90) {
            price += 10;
            checkPoint += million;
        }
        else if (soldTokens == 11*10**24) {
            salesClosed = true; 
        }
        else {
            price += 10;
            checkPoint += million;
        }
    }
}