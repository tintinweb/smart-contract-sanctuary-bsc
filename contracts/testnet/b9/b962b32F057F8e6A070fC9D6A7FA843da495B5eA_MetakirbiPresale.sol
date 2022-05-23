/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.7;

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MetakirbiPresale{

    uint256 public tokensPerBNB;
    uint256 public maxToBuy;
    uint256 public minToBuy;
    address public metaKirbiToken;
    address public treasuryWallet;
    bool public paused;
    address public owner;

    event BuyTokens(address indexed Buyer, uint256 BNBvalue, uint256 TokenValue);

    constructor(address _metaKirbi, address _treasuryWallet, uint256 _tokensPerBNB) {
        metaKirbiToken = _metaKirbi;
        owner = msg.sender;
        treasuryWallet = _treasuryWallet; 
        tokensPerBNB = _tokensPerBNB;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "caller is a not owner");
        _;
    }

    function buyToken() external payable {
        require(msg.value > minToBuy && msg.value < maxToBuy,"invalid amount To Buy");
        require(!paused,"sale is paused");
        uint256 tokens = msg.value * tokensPerBNB / 1e18;
        require(payable(treasuryWallet).send(msg.value),"transaction failed");
        IBEP20(metaKirbiToken).transfer(msg.sender, tokens);

        emit BuyTokens(msg.sender, msg.value, tokens);
    }

    function updateMetaKirbi(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0x0), "invalid address");
        metaKirbiToken = _tokenAddress;
    }

    function transferOwnership(address _newOwner) external onlyOwner{
        owner = _newOwner;
    }

    function updateWallet(address _wallet) external onlyOwner{
        require(_wallet != address(0x0), "invalid address");
        treasuryWallet = _wallet;
    }

    function updateMinMaxAmount(uint256 _minAmount,uint256 _maxAmount) external onlyOwner{
        require(_minAmount < _maxAmount,"invalid params");
        minToBuy = _minAmount;
        maxToBuy = _maxAmount;
    }

    function Pause() external onlyOwner{
        require(!paused, "contract already paused");
        paused = true;
    }

    function UnPause() external onlyOwner{
        require(paused, "contract already paused");
        paused = false;
    }

    function recover(address _tokenAddres, address _to, uint256 _amount) external onlyOwner {
        if(_tokenAddres == address(0x0)){
            require(payable(_to).send(_amount),"transaction failed");
        } else {
            IBEP20(_tokenAddres).transfer(_to, _amount);
        }
    }


}