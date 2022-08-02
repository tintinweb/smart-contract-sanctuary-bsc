/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

contract Modifier {
    address internal owner; // Constract creater
    address internal approveAddress;
    bool public running = true;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status;

    modifier onlyOwner(){
        require(msg.sender == owner, "Modifier: The caller is not the creator");
        _;
    }

    modifier onlyApprove(){
        require(msg.sender == approveAddress || msg.sender == owner, "Modifier: The caller is not the approveAddress");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier isRunning {
        require(running, "Modifier: No Running");
        _;
    }

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }

    function setApproveAddress(address externalAddress) public onlyOwner(){
        approveAddress = externalAddress;
    }

    function startStop() public onlyOwner returns (bool success) {
        if (running) { running = false; } else { running = true; }
        return true;
    }

    /*
     * @dev Get approve address
     */
    function getApproveAddress() internal view returns(address){
        return approveAddress;
    }

    fallback () payable external {}
    receive () payable external {}
}

library SafeMath {
    /* a + b */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /* a - b */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    /* a * b */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /* a / b */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    /* a / b */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* a % b */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    /* a % b */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Util {

    function toWei(uint price, uint decimals) public pure returns (uint){
        uint amount = price * (10 ** uint(decimals));
        return amount;
    }

}



contract MaxNewIdo is Modifier, Util {

    using SafeMath for uint256;
    
    uint256 public nodeBuyPrice;
    uint256 public normalBuyPrice;
    uint256 public totalNodeNumber;
    uint256 public totalNormalNumber;
    uint256 public salesNodeNumber;
    uint256 public salesNormalNumber;

    uint256 public receiveNodeIndex;
    uint256 public receiveNormalIndex;

    mapping(address => address) private invitationMapping;
    mapping(address => uint256) private buyNodeNumber;
    mapping(address => uint256) private buyNormalNumber;
    mapping(address => uint256) private totalBuyAmount;

    address [] private receiveNodeAddress;
    address [] private receiveNormalAddress;

    bool idoOpenStatus = true;

    uint256 private idoNodeLimit;
    uint256 private idoOneLimit;
    uint256 private idoTwoLimit;
    uint256 private idoThreeLimit;

    ERC20 private buyToken;
    ERC20 private sellToken;

    constructor() {
        nodeBuyPrice = 1500000000000000000;
        normalBuyPrice = 2000000000000000000;
        totalNodeNumber = toWei(200000, 18);
        totalNormalNumber = toWei(800000, 18);
        idoNodeLimit = toWei(6000, 18);
        idoOneLimit = toWei(100, 18);
        idoTwoLimit = toWei(500, 18);
        idoThreeLimit = toWei(1000, 18);
        buyToken = ERC20(0x55d398326f99059fF775485246999027B3197955);
        sellToken = ERC20(0xba84b4f7E3F43AEBa8e06CcD6b9fc3D96Bb6E232);
    }

    function setTokenContract(address _buyToken, address _sellToken) public onlyOwner {
        buyToken = ERC20(_buyToken);
        sellToken = ERC20(_sellToken);
    }

    function setIdoNodeLimit(uint256 _amountToWei) public onlyOwner {
        idoNodeLimit = _amountToWei;
    }

    function setOneNodeLimit(uint256 _amountToWei) public onlyOwner {
        idoOneLimit = _amountToWei;
    }

    function setTwoNodeLimit(uint256 _amountToWei) public onlyOwner {
        idoTwoLimit = _amountToWei;
    }

    function setThreeNodeLimit(uint256 _amountToWei) public onlyOwner {
        idoThreeLimit = _amountToWei;
    }

    function setNodeBuyPrice(uint256 _priceToWei) public onlyOwner {
        nodeBuyPrice = _priceToWei;
    }

    function setNormalBuyPrice(uint256 _priceToWei) public onlyOwner {
        normalBuyPrice = _priceToWei;
    }

    function setTotalNodeNumber(uint256 _numberToWei) public onlyOwner {
        totalNodeNumber = _numberToWei;
    }

    function setTotalNormalNumber(uint256 _numberToWei) public onlyOwner {
        totalNormalNumber = _numberToWei;
    }

    function setIdoOpenStatus(bool _status) public onlyOwner {
        idoOpenStatus = _status;
    }

    function setReceiveNodeAddress(address [] memory addresses) public onlyOwner {
        for(uint8 i=0; i<addresses.length; i++) {
            receiveNodeAddress.push(addresses[i]);
        }
    } 

    function setReceiveNormalAddress(address [] memory addresses) public onlyOwner {
        for(uint8 i=0; i<addresses.length; i++) {
            receiveNormalAddress.push(addresses[i]);
        }
    }

    function buyNode(uint256 amountToWei, address _address) public isRunning nonReentrant returns (bool) {
        if(!idoOpenStatus) {
            _status = _NOT_ENTERED;
            revert("Max: IDO not started");
        }
        if(msg.sender == _address) {
            _status = _NOT_ENTERED;
            revert("Max: Inviter is invalid");
        }
        if(amountToWei == 0) {
            _status = _NOT_ENTERED;
            revert("Max: The purchase amount must be greater than 0");
        }
        if(amountToWei != idoNodeLimit) {
            _status = _NOT_ENTERED;
            revert("Max: The purchase amount is invalid");
        }

        uint256 buyNumbers = toWei(amountToWei, 18).div(nodeBuyPrice);
        uint256 availableNumber = totalNodeNumber.sub(salesNodeNumber);
        if(buyNumbers > availableNumber) {
            _status = _NOT_ENTERED;
            revert("Max: The purchase amount exceeds limit");
        }

        // bind inviter
        if(invitationMapping[msg.sender] == address(0)) {
            if(_address != address(0) && _address != address(this)) {
                if(totalBuyAmount[_address] <= 0) {
                    _status = _NOT_ENTERED;
                    revert("Seed: Inviter is invalid");
                }
                invitationMapping[msg.sender] = _address;
            } else {
                invitationMapping[msg.sender] = address(this);
            }
        }

        buyToken.transferFrom(msg.sender, address(this), amountToWei);
        
        salesNodeNumber = salesNodeNumber.add(buyNumbers);
        buyNodeNumber[msg.sender] = buyNodeNumber[msg.sender].add(buyNumbers);
        totalBuyAmount[msg.sender] = totalBuyAmount[msg.sender].add(amountToWei);

        if(receiveNodeIndex >= receiveNodeAddress.length) {
            receiveNodeIndex = 0;
        }
        buyToken.transfer(receiveNodeAddress[receiveNodeIndex], amountToWei);

        receiveNodeIndex = receiveNodeIndex.add(1);
        
        sellToken.transfer(msg.sender, buyNumbers);

        return true;
    }

    function buyNormal(uint256 amountToWei, address _address) public isRunning nonReentrant returns (bool) {
        if(!idoOpenStatus) {
            _status = _NOT_ENTERED;
            revert("Max: IDO not started");
        }
        if(msg.sender == _address) {
            _status = _NOT_ENTERED;
            revert("Max: Inviter is invalid");
        }
        if(amountToWei == 0) {
            _status = _NOT_ENTERED;
            revert("Max: The purchase amount must be greater than 0");
        }
        if(amountToWei != idoOneLimit && amountToWei != idoTwoLimit && amountToWei != idoThreeLimit) {
            _status = _NOT_ENTERED;
            revert("Max: The purchase amount is invalid");
        }
        
        uint256 buyNumbers = toWei(amountToWei, 18).div(normalBuyPrice);
        uint256 availableNumber = totalNormalNumber.sub(salesNormalNumber);
        if(buyNumbers > availableNumber) {
            _status = _NOT_ENTERED;
            revert("Max: The purchase amount exceeds limit");
        }

        // bind inviter
        if(invitationMapping[msg.sender] == address(0)) {
            if(_address != address(0) && _address != address(this)) {
                if(totalBuyAmount[_address] <= 0) {
                    _status = _NOT_ENTERED;
                    revert("Seed: Inviter is invalid");
                }
                invitationMapping[msg.sender] = _address;
            } else {
                invitationMapping[msg.sender] = address(this);
            }
        }

        buyToken.transferFrom(msg.sender, address(this), amountToWei);

        salesNormalNumber = salesNormalNumber.add(buyNumbers);
        buyNormalNumber[msg.sender] = buyNormalNumber[msg.sender].add(buyNumbers);
        totalBuyAmount[msg.sender] = totalBuyAmount[msg.sender].add(amountToWei);

        if(receiveNormalIndex >= receiveNormalAddress.length) {
            receiveNormalIndex = 0;
        }
        buyToken.transfer(receiveNormalAddress[receiveNormalIndex], amountToWei);

        receiveNormalIndex = receiveNormalIndex.add(1);
        
        sellToken.transfer(msg.sender, buyNumbers);

        return true;
    }

    function updateInviter(address _address, address inviterAddress) public onlyApprove {
        invitationMapping[_address] = inviterAddress;
    }

    function getBindStatus() public view returns(bool status) {
        if(invitationMapping[msg.sender] == address(0)) {
            return false;
        }
        return true;
    }

    function getInviter(address _address) public view returns(address) {
        return invitationMapping[_address];
    }

    function getIdoOpenStatus() public view returns(bool status) {
        return idoOpenStatus;
    }

    function getNodeNumberByAddress(address _address) public view returns(uint256 numberToWei) {
        return buyNodeNumber[_address];
    }

    function getNormalNumberByAddress(address _address) public view returns(uint256 numberToWei) {
        return buyNormalNumber[_address];
    }

    function tokenOutput(address tokenAddress, address toAddress, uint amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(toAddress, amountToWei);
    }

}