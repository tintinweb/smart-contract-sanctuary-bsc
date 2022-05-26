/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

abstract contract MobiusCircle {
    function transferJoin(address joinAddress, uint256 amountToWei) external virtual returns (bool);
}

contract Modifier {
    address internal owner; // Constract creater
    address internal approveAddress;

    modifier onlyOwner(){
        require(msg.sender == owner, "Modifier: The caller is not the creator");
        _;
    }

    modifier onlyApprove(){
        require(msg.sender == approveAddress || msg.sender == owner, "Modifier: The caller is not the approveAddress");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setApproveAddress(address externalAddress) public onlyOwner(){
        approveAddress = externalAddress;
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

contract MobiusSlippage is Modifier {

    using SafeMath for uint256;

    address private tradePoolAddress;
    address private daoAddress;
    address private lightNodeAddress;
    address private superNodeAddress;
    address private deflationPoolAddress;
    address private topTenAwardAddress;
    address private flatLevelAddress;
    address private gasAddress;
    address private minePoolAddress;
    address private circleAddress;

    uint256 private tradePoolRatio;
    uint256 private daoRatio;
    uint256 private lightNodeRatio;
    uint256 private superNodeRatio;
    uint256 private deflationPoolRatio;
    uint256 private topTenAwardRatio;
    uint256 private flatLevelRatio;
    uint256 private gasRatio;
    uint256 private neuronNodeRatio;
    
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isNeuronNode;
    mapping(address => bool) approveMapping;

    constructor() {
        tradePoolRatio = 8;
        daoRatio = 10;
        lightNodeRatio = 10;
        superNodeRatio = 10;
        deflationPoolRatio = 20;
        topTenAwardRatio = 5;
        flatLevelRatio = 5;
        gasRatio = 12;
        neuronNodeRatio = 400;

        tradePoolAddress = 0x1365a1069C4cd570093396Dc92502315747d95bF;
        daoAddress = 0x1BD87924b9c481e3B99a84C41D1Cca5BC427D60D;
        lightNodeAddress = 0x2d8e1693B4a4f99DE6F2d03549648Cc81F68df8B;
        superNodeAddress = 0x464F288a75e008B6467Ab7273B1827a8227bC544;
        deflationPoolAddress = 0x095739710ddd23A9b8E960fed99539eA5da0F672;
        topTenAwardAddress = 0x665d2dFCb13b3eDD4be606B77fAf9e6b9499A1f9;
        flatLevelAddress = 0x8D82076bD3CA6234c923A14F32f25e8584b87B9E;
        gasAddress = 0x7e38946F2d7c71BF7266A58c5828aeFE3c0Fd611;

        minePoolAddress = 0x452399BEb3699c2dbFeD3cd61539C4e6AcD72a96;

        _isExcludedFromFee[msg.sender] = true;
        approveMapping[msg.sender] = true;
    }

    function setTradePoolAddress(address _address) public onlyOwner {
        tradePoolAddress = _address;
    }

    function setDaoAddress(address _address) public onlyOwner {
        daoAddress = _address;
    }

    function setLightNodeAddress(address _address) public onlyOwner {
        lightNodeAddress = _address;
    }

    function setSuperNodeAddress(address _address) public onlyOwner {
        superNodeAddress = _address;
    }

    function setDeflationPoolAddress(address _address) public onlyOwner {
        deflationPoolAddress = _address;
    }

    function setTopTenAwardAddress(address _address) public onlyOwner {
        topTenAwardAddress = _address;
    }

    function setFlatLevelAddress(address _address) public onlyOwner {
        flatLevelAddress = _address;
    }

    function setGasAddress(address _address) public onlyOwner {
        gasAddress = _address;
    }

    function setMinePoolAddress(address _address) public onlyOwner {
        minePoolAddress = _address;
    }

    function setNeuronNodeRatio(uint256 _ratio) public onlyOwner {
        neuronNodeRatio = _ratio;
    }

    function setCircleContract(address contractAddress) public onlyOwner {
        circleAddress = contractAddress;
    }

    function excludeFromFee(address _address) public {
        require(approveMapping[msg.sender], "Mobius: The caller is not the approveAddress");
        _isExcludedFromFee[_address] = true;
    }

    function includeInFee(address _address) public {
        require(approveMapping[msg.sender], "Mobius: The caller is not the approveAddress");
        _isExcludedFromFee[_address] = false;
    }

    function isExcludedFromFee(address _address) public view returns (bool) {
        return _isExcludedFromFee[_address];
    }

    function setApproveStatus(address _address, bool _status) public onlyOwner {
        approveMapping[_address] = _status;
    }

    function isApproveAddress(address _address) public view returns (bool) {
        return approveMapping[_address];
    }

    function setNeuronNodeStatus(address _address, bool _status) public returns (bool) {
        require(approveMapping[msg.sender], "Mobius: The caller is not the approveAddress");
        _isNeuronNode[_address] = _status;
        return true;
    }

    function isNeuronNode(address _address) public view returns (bool) {
        return _isNeuronNode[_address];
    }

    function tradeSlippage(address _address, uint256 amountToWei) public view returns (address [] memory slippageAddresses, uint256 [] memory slippageAmounts) {
        require(approveMapping[msg.sender], "Mobius: The caller is not the approveAddress");

        if(!_isExcludedFromFee[_address]) {
            (slippageAddresses, slippageAmounts) = computeSlippage(amountToWei);
        }
    }

    function transferSlippage(address sender, address recipient, uint256 amountToWei) public returns (address [] memory slippageAddresses, uint256 [] memory slippageAmounts) {
        require(approveMapping[msg.sender], "Mobius: The caller is not the approveAddress");
        
        bool slippageflag = true;
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            slippageflag = false;
        }

        if(slippageflag) {
            if(_isNeuronNode[recipient]) {
                
                uint256 circleAmount = amountToWei.mul(neuronNodeRatio).div(1000);

                slippageAddresses[0] = minePoolAddress;
                slippageAddresses[1] = deflationPoolAddress;

                slippageAmounts[0] = circleAmount.mul(980).div(1000);
                slippageAmounts[1] = circleAmount.mul(20).div(1000);
                
                MobiusCircle(circleAddress).transferJoin(sender, circleAmount);

                slippageflag = false;
            } else if(_isNeuronNode[sender]) {
                slippageflag = false;
            }
        }

        if(slippageflag) {
            (slippageAddresses, slippageAmounts) = computeSlippage(amountToWei);
        }

    }

    function computeSlippage(uint256 amountToWei) private view returns (address [] memory slippageAddresses, uint256 [] memory slippageAmounts) {
        slippageAddresses = new address[](8);
        slippageAmounts = new uint256[](8);

        slippageAddresses[0] = tradePoolAddress;
        slippageAddresses[1] = daoAddress;
        slippageAddresses[2] = lightNodeAddress;
        slippageAddresses[3] = superNodeAddress;
        slippageAddresses[4] = deflationPoolAddress;
        slippageAddresses[5] = topTenAwardAddress;
        slippageAddresses[6] = flatLevelAddress;
        slippageAddresses[7] = gasAddress;

        slippageAmounts[0] = amountToWei.mul(tradePoolRatio).div(1000);
        slippageAmounts[1] = amountToWei.mul(daoRatio).div(1000);
        slippageAmounts[2] = amountToWei.mul(lightNodeRatio).div(1000);
        slippageAmounts[3] = amountToWei.mul(superNodeRatio).div(1000);
        slippageAmounts[4] = amountToWei.mul(deflationPoolRatio).div(1000);
        slippageAmounts[5] = amountToWei.mul(topTenAwardRatio).div(1000);
        slippageAmounts[6] = amountToWei.mul(flatLevelRatio).div(1000);
        slippageAmounts[7] = amountToWei.mul(gasRatio).div(1000);

    }

    function tokenOutput(address tokenAddress, address receiveAddress, uint amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(receiveAddress, amountToWei);
    }

}