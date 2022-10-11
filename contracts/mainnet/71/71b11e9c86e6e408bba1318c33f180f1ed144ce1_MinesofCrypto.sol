/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

//SPDX-License-Identifier: MIT

/**

███╗   ███╗██╗███╗   ██╗███████╗███████╗     ██████╗ ███████╗     ██████╗██████╗ ██╗   ██╗██████╗ ████████╗ ██████╗      ██████╗ ███████╗███╗   ███╗███████╗
████╗ ████║██║████╗  ██║██╔════╝██╔════╝    ██╔═══██╗██╔════╝    ██╔════╝██╔══██╗╚██╗ ██╔╝██╔══██╗╚══██╔══╝██╔═══██╗    ██╔════╝ ██╔════╝████╗ ████║██╔════╝
██╔████╔██║██║██╔██╗ ██║█████╗  ███████╗    ██║   ██║█████╗      ██║     ██████╔╝ ╚████╔╝ ██████╔╝   ██║   ██║   ██║    ██║  ███╗█████╗  ██╔████╔██║███████╗
██║╚██╔╝██║██║██║╚██╗██║██╔══╝  ╚════██║    ██║   ██║██╔══╝      ██║     ██╔══██╗  ╚██╔╝  ██╔═══╝    ██║   ██║   ██║    ██║   ██║██╔══╝  ██║╚██╔╝██║╚════██║
██║ ╚═╝ ██║██║██║ ╚████║███████╗███████║    ╚██████╔╝██║         ╚██████╗██║  ██║   ██║   ██║        ██║   ╚██████╔╝    ╚██████╔╝███████╗██║ ╚═╝ ██║███████║
╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝     ╚═════╝ ╚═╝          ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝        ╚═╝    ╚═════╝      ╚═════╝ ╚══════╝╚═╝     ╚═╝╚══════╝
                                                                                                                                                            
*/
pragma solidity ^0.8.7;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract MinesofCrypto is Ownable {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "MinesofCrypto";
    string constant _symbol = "$MOC";
    uint8 constant _decimals = 9;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    uint256 _totalSupply = 5000000 * (10**_decimals);

    uint256 public buyTax = 500; //total buy fee
    uint256 public sellTax = 500; //total sell fee

    uint256 public marketingFee = 500; //marketfee fee
    uint256 public burnFee = 0; //burnFee 
    uint256 public extraFeeOnSell = 0; //extra Fee
    uint256 public feeDenominator = 10000; //tax divider

    uint256 public swapThreshold = 10 * (10**_decimals);

    address public marketingFeeReceiver;
    address public winnerFeeReceiver;
    address public pair;

    IDEXRouter public router;

    bool public swapEnabled = false;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        winnerFeeReceiver = DEAD; // by default DeaD wallet
        marketingFeeReceiver = msg.sender; // by default Dev wallet

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

   function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }

    function setwinnerFeeReceiver(address _winnerFeeReceiver)
        external
        onlyOwner
    {
        winnerFeeReceiver = _winnerFeeReceiver;
    }

    function setmarketingFeeReceivers(address _marketingFeeReceiver)
        external
        onlyOwner
    {
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        onlyOwner
    {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (recipient == pair || sender == pair) {
            //on trade
            uint256 amountWithFee = amount;
            if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {}
            else{
                 uint256 burnFeeAmount = amount.mul(burnFee).div(feeDenominator);
                 uint256 marketingFeeAmount = amount.mul(marketingFee).div(feeDenominator);
                 uint256 extraFeeAmount = amount.mul(extraFeeOnSell).div(feeDenominator);
                _txTransfer(sender, DEAD, burnFeeAmount);
                _txTransfer(sender, address(this), marketingFeeAmount);
                if(recipient == pair){
                //on sell
                _txTransfer(sender, winnerFeeReceiver, extraFeeAmount);
                uint256 feeAmount = amount.mul(sellTax).div(feeDenominator);
                amountWithFee = amount.sub(feeAmount);
                }else{
                uint256 feeAmount = amount.mul(buyTax).div(feeDenominator);
                amountWithFee = amount.sub(feeAmount);
                }
                if (shouldSwapBack()) {swapBack(marketingFeeAmount);}
            }
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amountWithFee);
            emit Transfer(sender, recipient, amountWithFee);
            return true;
        } else {
            //free transfer
            _basicTransfer(sender, recipient, amount);
            return true;
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function _txTransfer(address sender,address recipient,uint256 amount) internal {
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
  
    function _burn(address account, uint256 amount) internal {
        _balances[account] = _balances[account].sub(amount,"Insufficient Balance");
        _balances[DEAD] = _balances[DEAD].add(amount);
        emit Transfer(account, DEAD, amount);
    }
    function swapBack(uint256 amount) internal swapping {
        uint256 a = amount;
        if(_balances[address(this)] >= a){
            if(a <= swapThreshold){
                a = amount;
            }else{
                a = swapThreshold;
            }
        }else{
            a = swapThreshold;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            a,
            0,
            path,
            marketingFeeReceiver,
            block.timestamp
        );
    }

    function setFees(
        uint256 _marketingFee,
        uint256 _burnFee,
        uint256 _extraFeeOnSell,
        uint256 _feeDenominator
    ) external onlyOwner {
        uint256 value = 100;
        require(
            value.mul(_marketingFee.add(_burnFee).add(_extraFeeOnSell)).div(
                _feeDenominator
            ) <= 10,
            "MAX TAX IS 10%"
        ); //max tax is 10% include extra just in trades
        marketingFee = _marketingFee;
        burnFee = _burnFee;
        extraFeeOnSell = _extraFeeOnSell;

        buyTax = _marketingFee.add(_burnFee);
        sellTax = _marketingFee.add(_burnFee).add(_extraFeeOnSell);
        feeDenominator = _feeDenominator;
    }

    function manualSend() external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        payable(marketingFeeReceiver).transfer(contractETHBalance);
        _basicTransfer(
            address(this),
            marketingFeeReceiver,
            balanceOf(address(this))
        );
    }
}