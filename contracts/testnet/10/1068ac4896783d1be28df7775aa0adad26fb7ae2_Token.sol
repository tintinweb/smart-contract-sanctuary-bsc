// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./TokenLib.sol";

contract Token is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) public override balanceOf;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _liquidityFee;
    uint256 public _marketingFee;
    address public _marketingFeeReceiver;
    uint256 public _developmentFee;
    address public _developmentFeeReceiver;
    uint256 public _totalFee;

    uint256 public _sellMultiplier;
    uint256 public _buyMultiplier;
    uint256 public _transferMultiplier;

    address public _burnAddress;
    IUniswapV2Router public uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public WBNB;

    constructor (string memory __name, string memory __symbol) {
        _name = __name;
        _symbol = __symbol;
        _mint(_msgSender(), 1000000000000000000000000000);
        _decimals = 18;
        
        _sellMultiplier = 100;
        _buyMultiplier = 100;
        _transferMultiplier = 50;
        _marketingFeeReceiver = _msgSender();
        _developmentFeeReceiver = _msgSender();

        _burnAddress = 0x000000000000000000000000000000000000dEaD;

        //Testnet 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        //Mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E
        uniswapV2Router = IUniswapV2Router(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        WBNB = uniswapV2Router.WETH();
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), WBNB);
    }

/*
    constructor (address creator, string memory __name, string memory __symbol, uint256 __supply, uint8 __decimals) {
        _name = __name;
        _symbol = __symbol;
        _mint(creator, __supply);
        _decimals = __decimals;
        
        _sellMultiplier = 100;
        _buyMultiplier = 100;
        _transferMultiplier = 50;

        _burnAddress = 0x000000000000000000000000000000000000dEaD;
    }
    */
    
    function name() external view returns (string memory) {
        return _name;
    }
    
    function symbol() external view returns (string memory) {
        return _symbol;
    }
    
    function decimals() external view returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(_msgSender(), recipient, amount);
    }
    
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
   
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][_msgSender()] != type(uint256).max){
            _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        balanceOf[sender] = balanceOf[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = takeFee(sender, amount, recipient);

        balanceOf[recipient] = balanceOf[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
   
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }
    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        balanceOf[account] = balanceOf[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {
        if(amount == 0 || _totalFee == 0){
            return amount;
        }

        uint256 multiplier = _transferMultiplier;

        if(recipient == uniswapV2Pair) {
            multiplier = _sellMultiplier;
        } else if(sender == uniswapV2Pair) {
            multiplier = _buyMultiplier;
        }

        uint256 feeAmount = amount.mul(_totalFee).mul(multiplier).div(1000 * 100);

        if(feeAmount > 0){
            balanceOf[address(this)] = balanceOf[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }

    function setMultipliers(uint256 buy, uint256 sell, uint256 trans) external onlyOwner {
        _sellMultiplier = sell;
        _buyMultiplier = buy;
        _transferMultiplier = trans;
    }

    function setFees(uint256 liquidityFee, uint256 marketingFee, uint256 developmentFee) external onlyOwner {
        _liquidityFee = liquidityFee;
        _marketingFee = marketingFee;
        _developmentFee = developmentFee;
        _totalFee = liquidityFee + marketingFee + developmentFee;
    }

    function setFeeReceivers(address marketingFeeReceiver, address developmentFeeReceiver) external onlyOwner {
        require(marketingFeeReceiver != address(0),"Marketing fee address cannot be zero address");
        require(developmentFeeReceiver != address(0),"Development fee address cannot be zero address");

        _marketingFeeReceiver = marketingFeeReceiver;
        _developmentFeeReceiver = developmentFeeReceiver;
    }

    function takeFeeBuySellTest(uint256 amount) external pure returns (uint256 feeAmount) {
        uint256 totalFee = 57;
        uint256 feeDenominator = 1000;
        uint256 multiplier = 100;

        feeAmount = amount.mul(totalFee).mul(multiplier).div(feeDenominator * 100);
    }
}