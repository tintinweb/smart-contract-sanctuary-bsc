/**
 *Submitted for verification at BscScan.com on 2022-05-27
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

    /*
     * @dev wei convert
     * @param price
     * @param decimals
     */
    function toWei(uint price, uint decimals) public pure returns (uint){
        uint amount = price * (10 ** uint(decimals));
        return amount;
    }

}



contract MaxIdo is Modifier, Util {

    using SafeMath for uint256;

    uint256 public totalNodeNumber;
    uint256 public totalNormalNumber;
    uint256 public salesNodeNumber;
    uint256 public salesNormalNumber;

    mapping(address => address) private invitationMapping;
    mapping(address => uint256) private buyNodeNumber;
    mapping(address => uint256) private receiveNodeNumber;
    mapping(address => uint256) private buyNormalNumber;
    mapping(address => uint256) private receiveNormalNumber;

    address [] private receiveAddress;
    address private defaultInviteAddress;

    bool idoOpenStatus = false;

    uint256 private idoNodeLimit;
    uint256 private idoNormalLimit;

    ERC20 private buyToken;
    ERC20 private sellToken;

    constructor() {
        totalNodeNumber = toWei(2000000, 18);
        totalNormalNumber = toWei(3000000, 18);
        idoNodeLimit = toWei(5000, 18);
        idoNormalLimit = toWei(100, 18);
    }

    function settotalNodeNumber(uint256 _numberToWei) public onlyOwner {
        totalNodeNumber = _numberToWei;
    }

    function settotalNormalNumber(uint256 _numberToWei) public onlyOwner {
        totalNormalNumber = _numberToWei;
    }

    function setTokenContract(address _buyToken, address _sellToken) public onlyOwner {
        buyToken = ERC20(_buyToken);
        sellToken = ERC20(_sellToken);
    }

    function setIdoOpenStatus(bool _status) public onlyOwner {
        idoOpenStatus = _status;
    }

    function setDefaultInviteAddress(address _address) public onlyOwner {
        defaultInviteAddress = _address;
    }

    function setReceiveAddress(address [] memory addresses) public onlyOwner {
        for(uint8 i=0; i<addresses.length; i++) {
            receiveAddress.push(addresses[i]);
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
        uint256 availableNumber = totalNodeNumber.sub(salesNodeNumber);
        if(amountToWei > availableNumber) {
            _status = _NOT_ENTERED;
            revert("Max: The purchase amount exceeds limit");
        }

        // bind inviter
        if(invitationMapping[msg.sender] == address(0)) {
            if(_address != address(0) && _address != address(this)) {
                if(buyNodeNumber[_address] <= 0) {
                    _status = _NOT_ENTERED;
                    revert("Seed: Inviter is invalid");
                }
                invitationMapping[msg.sender] = _address;
            } else {
                invitationMapping[msg.sender] = defaultInviteAddress;
            }
        }

        buyToken.transferFrom(msg.sender, address(this), amountToWei);

        salesNodeNumber = salesNodeNumber.add(amountToWei);
        buyNodeNumber[msg.sender] = buyNodeNumber[msg.sender].add(amountToWei);
        uint256 inviterReward = amountToWei.mul(10).div(100);

        buyToken.transfer(invitationMapping[msg.sender], inviterReward);

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
        if(amountToWei != idoNormalLimit) {
            _status = _NOT_ENTERED;
            revert("Max: The purchase amount is invalid");
        }
        uint256 availableNumber = totalNormalNumber.sub(salesNormalNumber);
        if(amountToWei > availableNumber) {
            _status = _NOT_ENTERED;
            revert("Max: The purchase amount exceeds limit");
        }

        // bind inviter
        if(invitationMapping[msg.sender] == address(0)) {
            if(_address != address(0) && _address != address(this)) {
                if(buyNormalNumber[_address] <= 0) {
                    _status = _NOT_ENTERED;
                    revert("Seed: Inviter is invalid");
                }
                invitationMapping[msg.sender] = _address;
            } else {
                invitationMapping[msg.sender] = defaultInviteAddress;
            }
        }

        buyToken.transferFrom(msg.sender, address(this), amountToWei);

        salesNormalNumber = salesNormalNumber.add(amountToWei);
        buyNormalNumber[msg.sender] = buyNormalNumber[msg.sender].add(amountToWei);
        uint256 inviterReward = amountToWei.mul(10).div(100);

        buyToken.transfer(invitationMapping[msg.sender], inviterReward);

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

    /*
    function getNumberForIdo() public view returns(uint number) {
        if(buyDetailFrequency[msg.sender] == 0 || receiveIdoNumber[msg.sender] > 0) {
            return 0;
        }
        return computeReceiveIdoNumber();
    }

    function receiveForIdo() public isRunning nonReentrant returns (bool) {
         if(buyDetailFrequency[msg.sender] == 0 || receiveIdoNumber[msg.sender] > 0) {
            _status = _NOT_ENTERED;
            revert("Seed: No amount available at the moment");
        }
        uint receiveNumber = computeReceiveIdoNumber();

        receiveIdoNumber[msg.sender] = receiveNumber;
        sellToken.transfer(msg.sender, receiveNumber);
        
        if(!receiveWhitelist[msg.sender]) {
            uint notReceiveNumber = buyIdoNumber[msg.sender].sub(receiveNumber);
            if(notReceiveNumber > 0) {
                // transfer to black hole
                sellToken.transfer(0x000000000000000000000000000000000000dEaD, notReceiveNumber);

            }
        }
        
        return true;
    }

    function receiveForIdoNew() public isRunning nonReentrant returns (bool) {

        if(receiveWhitelist[msg.sender]) {
            
            uint receiveNumber = buyIdoNumber[msg.sender].sub(receiveIdoNumber[msg.sender]);

            if(receiveNumber <= 0) {
                _status = _NOT_ENTERED;
                revert("Seed: No amount available at the moment");
            }

            receiveIdoNumber[msg.sender] = receiveIdoNumber[msg.sender].add(receiveNumber);
            sellToken.transfer(msg.sender, receiveNumber);
        }
        return true;
    }

    function computeReceiveIdoNumber() private view returns (uint number) {
        uint secondsOfDay = 24 * 60 * 60;
        uint availableReceive = 0;
        for(uint8 i=1; i<=buyDetailFrequency[msg.sender]; i++) {

            uint onlineDay = block.timestamp.sub(buyDetailInfo[msg.sender][i].buyTime).div(secondsOfDay);
            if(onlineDay >= idoReceivePeriod) {
                uint availableReceivePeriod = onlineDay.div(idoReceivePeriod);
                if(availableReceivePeriod >= 10) {
                    availableReceive = availableReceive.add(buyDetailInfo[msg.sender][i].buyAmount);
                } else {
                    availableReceive = availableReceive.add((buyDetailInfo[msg.sender][i].buyAmount).mul(10).div(100).mul(availableReceivePeriod));
                }
            }

        }

        return availableReceive;
        
    }
    */

    function tokenOutput(address tokenAddress, address toAddress, uint amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(toAddress, amountToWei);
    }

}