/**
 *Submitted for verification at BscScan.com on 2022-03-21
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

    modifier onlyOwner(){
        require(msg.sender == owner, "Modifier: The caller is not the creator");
        _;
    }

    modifier onlyApprove(){
        require(msg.sender == approveAddress || msg.sender == owner, "Modifier: The caller is not the approveAddress");
        _;
    }

    modifier isRunning {
        require(running, "Modifier: No Running");
        _;
    }

    constructor() {
        owner = msg.sender;
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

contract AntKingSlippage is Modifier {

    using SafeMath for uint;

    address private authorizeAddress;
    address private lpRewardAddress;

    uint private destroyRatio;
    uint private lpRewardRatio;
    uint private firstFloorRatio;
    uint private secondFloorRatio;
    uint private otherFloorRatio;

    ERC20 private slippageToken;

    constructor() {
        destroyRatio = 30;
        lpRewardRatio = 50;
        firstFloorRatio = 20;
        secondFloorRatio = 10;
        otherFloorRatio = 5;
    }

    /*
     * @dev Set up | Creator call | Set the token contract address
     * @param token Configure the address of the sell token contract
     */
    function setSlippageToken(address _token) public onlyOwner {
        slippageToken = ERC20(_token);
    }

    function setLpRewardAddress(address _address) public onlyOwner {
        lpRewardAddress = _address;
    }

    function setDestroyRatio(uint ratio) public onlyOwner {
        destroyRatio = ratio;
    }

    function setLpRewardRatio(uint ratio) public onlyOwner {
        lpRewardRatio = ratio;
    }

    function setFirstFloorRatio(uint ratio) public onlyOwner {
        firstFloorRatio = ratio;
    }

    function setSecondFloorRatio(uint ratio) public onlyOwner {
        secondFloorRatio = ratio;
    }

    function setOtherFloorRatio(uint ratio) public onlyOwner {
        otherFloorRatio = ratio;
    }

    function slippage(uint256 amountToWei, address [] calldata superiors) public view onlyApprove isRunning returns (address [] memory slippageAddresses, uint256 [] memory slippageAmounts) {

        slippageAddresses = new address[](9);
        slippageAmounts = new uint256[](9);

        slippageAddresses[0] = 0x000000000000000000000000000000000000dEaD;
        slippageAmounts[0] = amountToWei.mul(destroyRatio).div(1000);

        slippageAddresses[1] = lpRewardAddress;
        slippageAmounts[1] = amountToWei.mul(lpRewardRatio).div(1000);
        
        uint256 firstFloorReward = amountToWei.mul(firstFloorRatio).div(1000);
        uint256 secondFloorReward = amountToWei.mul(secondFloorRatio).div(1000);
        uint256 otherFloorReward = amountToWei.mul(otherFloorRatio).div(1000);
        
        uint256 extraDestroyAmount = 0;

        if(superiors[0] != address(0)) {
            slippageAddresses[2] = superiors[0];
            slippageAmounts[2] = firstFloorReward;
        } else {
            extraDestroyAmount = extraDestroyAmount.add(firstFloorReward);
        }

        if(superiors[1] != address(0)) {
            slippageAddresses[3] = superiors[1];
            slippageAmounts[3] = secondFloorReward;
        } else {
            extraDestroyAmount = extraDestroyAmount.add(secondFloorReward);
        }

        for(uint8 i=2; i<superiors.length; i++) {
            if(superiors[i] != address(0)) {
                slippageAddresses[i+2] = superiors[i];
                slippageAmounts[i+2] = otherFloorReward;
            } else {
                extraDestroyAmount = extraDestroyAmount.add(otherFloorReward);
            }
        }

        if(extraDestroyAmount > 0) {
            slippageAddresses[8] = 0x000000000000000000000000000000000000dEaD;
            slippageAmounts[8] = extraDestroyAmount;
        }

    }

    function setAuthorizeAddress(address _address) public onlyOwner {
        authorizeAddress = _address;
    }

    function lpRewardOutput(address _address, uint amountToWei) public {
        require(msg.sender == authorizeAddress, "Modifier: The caller is not the authorizeAddress");
        slippageToken.transfer(_address, amountToWei);
    }

}