/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

/*  
Token Bridge
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.15;

interface IBEP20 {
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract TheBridge {
    address public token;
    address public constant BRIDGE = 0x5288009820Ff073Bb664e7330F5f0C9868878888;
    address public constant CEO = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;

    mapping (address => mapping (uint256 => bool)) public bridgingCompleted;
    mapping (address => mapping (uint256 => uint256)) public bridgingToChainID;
    mapping (address => uint256) public personalTxID;
    mapping (address => mapping (uint256 => uint256)) public tokensDepositedAtTxID;

    uint256 public feeForBridging = 10 * 10**(_decimals - feeDecimals);
    uint256 public feeDecimals = 1;
    uint8 public _decimals;

    modifier onlyBridge() {if(msg.sender != BRIDGE) return; _;}
    modifier onlyOwner() {if(msg.sender != CEO) return; _;}

    event TokensHaveArrived(address account, uint256 amount);
    event TokensHaveBeenSent(address account, uint256 amount);

    constructor(address tokenAddress) {
        token = tokenAddress;
        _decimals = IBEP20(token).decimals();
        
    }

    function sendTokensToBridge(uint256 amount, uint256 toChain) external {
        require(IBEP20(token).allowance(msg.sender, address(this)) >= amount, "Amount exceeds allowance, please approve the bridge to use your tokens");
        IBEP20(token).transferFrom(msg.sender, address(this), amount);
        personalTxID[msg.sender]++;
        tokensDepositedAtTxID[msg.sender][personalTxID[msg.sender]] = amount;
        bridgingToChainID[msg.sender][personalTxID[msg.sender]] = toChain;
        emit TokensHaveArrived(msg.sender, amount);
    }
    
    function checkDeposit(address account, uint256 txID) public view returns(uint256) {
        return tokensDepositedAtTxID[account][txID];
    }

    function sendTokensToClient(address account, uint256 amount, uint256 txID) external onlyBridge {
        if(bridgingCompleted[account][txID]) return;
        bridgingCompleted[account][txID] = true;

        uint256 amountAfterFee = amount - feeForBridging;

        IBEP20(token).transfer(account, amountAfterFee);
        emit TokensHaveBeenSent(account, amountAfterFee);
    }
    
    function setFeeForBridging(uint256 fee) external onlyOwner {
        feeForBridging = fee;
    }

    function setFeeDivisor(uint256 newFeeDecimals) external onlyOwner {
        feeDecimals = newFeeDecimals;
    }

    function rescueTokens() external onlyOwner{
        IBEP20(token).transfer(CEO, IBEP20(token).balanceOf(address(this)));
    }
}