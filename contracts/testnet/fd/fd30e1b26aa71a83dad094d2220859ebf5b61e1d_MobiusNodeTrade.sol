/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function approve(address spender, uint256 amount) external virtual returns (bool);
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

    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

}

contract MobiusNodeTrade is Modifier, Util {

    using SafeMath for uint256;

    address private minePoolAddress;

    uint256 private lightTransferFee;
    uint256 private superTransferFee;
    uint256 private lightDefaultFee;
    uint256 private lightRaiseFee;
    uint256 private superDefaultFee;
    uint256 private superRaiseFee;

    uint256 private limitTradeTime;

    mapping(uint256 => bool) tradeIdStatus;
    mapping(uint256 => uint256) tradeIdLasttime;

    mapping(uint256 => uint256) tradeIdIndex;
    mapping(uint256 => mapping(uint256 => address)) tradeIdAddress;
    mapping(uint256 => mapping(address => uint256)) tradeIdAddressAmount;

    mapping(address => address) transferMapping;
    mapping(address => uint256) hangSellMapping;

    ERC20 private mobToken;

    constructor() {
        superTransferFee = 20000000000000000000;
        superTransferFee = 50000000000000000000;
        lightDefaultFee = 200000000000000000000;
        lightRaiseFee = 100000000000000000000;
        superDefaultFee = 2000000000000000000000;
        superRaiseFee = 1000000000000000000000;

        limitTradeTime = 8 * 60 * 60;

        mobToken = ERC20(0x1365a1069C4cd570093396Dc92502315747d95bF);
        minePoolAddress = 0x452399BEb3699c2dbFeD3cd61539C4e6AcD72a96;
    }

    function setTokenContract(address _mobToken) public onlyOwner {
        mobToken = ERC20(_mobToken);
    }

    function setMinePoolAddress(address _address) public onlyOwner {
        minePoolAddress = _address;
    }

    function setLightTransferFee(uint256 amountToWei) public onlyOwner {
        lightTransferFee = amountToWei;
    }

    function setSuperTransferFee(uint256 amountToWei) public onlyOwner {
        superTransferFee = amountToWei;
    }

    function compete(uint256 tradeId, uint256 nodeType) public isRunning nonReentrant returns (bool) {
        // 1 = light node, 2 = super node
        if(tradeIdStatus[tradeId]) {
            _status = _NOT_ENTERED;
            revert("Mobius: Invalid transaction ID");
        }

        if(tradeIdIndex[tradeId] > 0) {
            uint256 intervalTime = tradeIdLasttime[tradeId].sub(block.timestamp);
            if(intervalTime >= limitTradeTime) {
                _status = _NOT_ENTERED;
                revert("Mobius: Invalid transaction");
            }
        }

        uint256 competeAmount = 0;
        if(tradeIdIndex[tradeId] == 0) {
            if(nodeType == 1) {
                competeAmount = lightDefaultFee;
            } else {
                competeAmount = superDefaultFee;
            }
        } else {
            if(nodeType == 1) {
                competeAmount = lightDefaultFee.add(tradeIdIndex[tradeId].mul(lightRaiseFee));
            } else {
                competeAmount = superDefaultFee.add(tradeIdIndex[tradeId].mul(superRaiseFee));
            }
        }

        mobToken.transferFrom(msg.sender, address(this), competeAmount);

        tradeIdIndex[tradeId] = tradeIdIndex[tradeId].add(1);
        tradeIdAddress[tradeId][tradeIdIndex[tradeId]] = msg.sender;
        tradeIdAddressAmount[tradeId][msg.sender] = competeAmount;
        
        tradeIdLasttime[tradeId] = block.timestamp;

        return true;
    }

    function clinch(uint256 tradeId) public isRunning onlyApprove returns (bool) {

        if(tradeIdIndex[tradeId] > 0) {
            
            for(uint8 i=1; i<=tradeIdIndex[tradeId]; i++) {

                if(i == tradeIdIndex[tradeId]) {
                    mobToken.transfer(minePoolAddress, tradeIdAddressAmount[tradeId][tradeIdAddress[tradeId][i]]);
                } else {
                    mobToken.transfer(tradeIdAddress[tradeId][i], tradeIdAddressAmount[tradeId][tradeIdAddress[tradeId][i]]);
                }

            }

            tradeIdStatus[tradeId] = true;

        }
        return true;
    }

    function transfer(uint256 nodeType, address to) public isRunning nonReentrant returns (bool) {
        // 1 = light node, 2 = super node
        if(nodeType != 1 && nodeType != 2) {
            _status = _NOT_ENTERED;
            revert("Mobius: Wrong node type");
        }

        uint256 transferFee = 0;
        if(nodeType == 1) {
            transferFee = superTransferFee;
        } else {
            transferFee = superTransferFee;
        }

        mobToken.transferFrom(msg.sender, address(this), transferFee);
        transferMapping[msg.sender] = to;
        mobToken.transfer(minePoolAddress, transferFee);

        return true;
    }

    function hangSell(uint256 nodeType) public isRunning nonReentrant returns (bool) {
        // 1 = light node, 2 = super node
        hangSellMapping[msg.sender] = nodeType;
        return true;
    }

    function getTransferMapping(address _address) public view returns(address){
        return transferMapping[_address];
    }

    function getCompeteInfo(uint256 tradeId, address _address) public view returns(uint256 amountToWei){
        amountToWei = tradeIdAddressAmount[tradeId][_address];
    }

    function tokenOutput(address tokenAddress, address receiveAddress, uint256 amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(receiveAddress, amountToWei);
    }

}