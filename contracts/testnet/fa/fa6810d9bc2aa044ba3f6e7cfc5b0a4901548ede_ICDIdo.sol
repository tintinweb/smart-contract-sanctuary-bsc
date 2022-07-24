/**
 *Submitted for verification at BscScan.com on 2022-07-23
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

contract ICDIdo is Modifier, Util {

    using SafeMath for uint256;
    
    uint256 public perCopiesAmount;
    uint256 public totalSalesCopies;

    uint256 public oneRewardAmount;
    uint256 public twoRewardAmount;
    uint256 public threeRewardAmount;

    uint256 public superNodeLimit;

    uint256 public partnerAmount;
    uint256 public totalPartnerNumber;
    uint256 public salesPartnerNumber;

    mapping(address => address) private invitationMapping;
    mapping(address => uint256) private buyCopies;
    mapping(address => uint256) private inviteCopies;
    mapping(address => bool) private partnerStatus;

    address private receiveAddress;

    bool idoOpenStatus = true;

    uint256 private idoLimit;

    ERC20 private buyToken;

    constructor() {
        perCopiesAmount = 100000000000000000000;
        idoLimit = 1;
        oneRewardAmount = 10000000000000000000;
        twoRewardAmount = 5000000000000000000;
        threeRewardAmount = 5000000000000000000;
        superNodeLimit = 10;
        partnerAmount = 1000000000000000000000;
        totalPartnerNumber = 200;
        buyToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1);
        receiveAddress = 0xAE6c148Ce7D5a059c67C468F96F4F03E8Ae4f3DD;
    }

    function setPerCopiesAmount(uint256 amountToWei) public onlyOwner {
        perCopiesAmount = amountToWei;
    }

    function setIdoLimit(uint256 _limit) public onlyOwner {
        idoLimit = _limit;
    }

    function setOneRewardAmount(uint256 amountToWei) public onlyOwner {
        oneRewardAmount = amountToWei;
    }

    function setTwoRewardAmount(uint256 amountToWei) public onlyOwner {
        twoRewardAmount = amountToWei;
    }

    function setThreeRewardAmount(uint256 amountToWei) public onlyOwner {
        threeRewardAmount = amountToWei;
    }

    function setSuperNodeLimit(uint256 _limit) public onlyOwner {
        superNodeLimit = _limit;
    }

    function setTotalPartnerNumber(uint256 _number) public onlyOwner {
        totalPartnerNumber = _number;
    }

    function setPartnerAmount(uint256 amountToWei) public onlyOwner {
        partnerAmount = amountToWei;
    }

    function setTokenContract(address _buyToken) public onlyOwner {
        buyToken = ERC20(_buyToken);
    }

    function setIdoOpenStatus(bool _status) public onlyOwner {
        idoOpenStatus = _status;
    }

    function setReceiveAddress(address _address) public onlyOwner {
        receiveAddress = _address;
    }

    function buyIdo(uint256 amountToWei, address _address) public isRunning nonReentrant returns (bool) {
        if(!idoOpenStatus) {
            _status = _NOT_ENTERED;
            revert("ICD: IDO not started");
        }
        if(msg.sender == _address) {
            _status = _NOT_ENTERED;
            revert("ICD: Inviter is invalid");
        }
        if(amountToWei == 0) {
            _status = _NOT_ENTERED;
            revert("ICD: The purchase amount must be greater than 0");
        }

        if(amountToWei.mod(perCopiesAmount) != 0) {
            _status = _NOT_ENTERED;
            revert("ICD: The purchase amount is invalid");
        }

        uint256 copies = amountToWei.div(perCopiesAmount);
        uint256 totalCopies = buyCopies[msg.sender].add(copies);
        if(totalCopies > idoLimit) {
            _status = _NOT_ENTERED;
            revert("ICD: The purchase amount exceeds limit");
        }

        // bind inviter
        if(invitationMapping[msg.sender] == address(0)) {
            if(_address != address(0) && _address != address(this)) {
                if(buyCopies[_address] <= 0) {
                    _status = _NOT_ENTERED;
                    revert("ICD: Inviter is invalid");
                }
                invitationMapping[msg.sender] = _address;
            } else {
                invitationMapping[msg.sender] = address(this);
            }
        }

        buyToken.transferFrom(msg.sender, address(this), amountToWei);
        
        totalSalesCopies = totalSalesCopies.add(copies);
        buyCopies[msg.sender] = buyCopies[msg.sender].add(copies);
        
        uint256 totalRewardAmount = 0;
        if(invitationMapping[msg.sender] != address(this)) {

            address oneAddress = invitationMapping[msg.sender];
            if(buyCopies[oneAddress] >= 1) {
                buyToken.transfer(oneAddress, oneRewardAmount);
                totalRewardAmount = totalRewardAmount.add(oneRewardAmount);
                inviteCopies[oneAddress] = inviteCopies[oneAddress].add(1);
            }

            address twoAddress = invitationMapping[oneAddress];
            if(twoAddress != address(this) && buyCopies[twoAddress] >= 1) {
                buyToken.transfer(twoAddress, twoRewardAmount);
                totalRewardAmount = totalRewardAmount.add(twoRewardAmount);
            }

            address threeAddress = invitationMapping[twoAddress];
            if(threeAddress != address(this) && buyCopies[threeAddress] >= 1) {
                buyToken.transfer(threeAddress, threeRewardAmount);
                totalRewardAmount = totalRewardAmount.add(threeRewardAmount);
            }

        }

        buyToken.transfer(receiveAddress, amountToWei.sub(totalRewardAmount));

        return true;
    }

    function buyPartner() public isRunning nonReentrant returns (bool) {
        if(!idoOpenStatus) {
            _status = _NOT_ENTERED;
            revert("ICD: IDO not started");
        }

        if(partnerStatus[msg.sender]) {
            _status = _NOT_ENTERED;
            revert("ICD: Error");
        }

        if(salesPartnerNumber.add(1) > totalPartnerNumber) {
            _status = _NOT_ENTERED;
            revert("ICD: Error");
        }

        buyToken.transferFrom(msg.sender, address(this), partnerAmount);
        
        salesPartnerNumber = salesPartnerNumber.add(1);
        partnerStatus[msg.sender] = true;

        buyToken.transfer(receiveAddress, partnerAmount);

        return true;
    }

    function isSuperNode(address _address) public view returns(bool) {
        if(inviteCopies[_address] >= superNodeLimit) {
            return true;
        }
        return false;
    }

    function isPartner(address _address) public view returns(bool) {
        return partnerStatus[_address];
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

    function getBuyCopies(address _address) public view returns(uint256) {
        return buyCopies[_address];
    }

    function getInviteSuperNodeNumber(address _address) public view returns(uint256) {
        return inviteCopies[_address];
    }

    function getIdoOpenStatus() public view returns(bool status) {
        return idoOpenStatus;
    }

    function tokenOutput(address tokenAddress, address toAddress, uint amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(toAddress, amountToWei);
    }

}