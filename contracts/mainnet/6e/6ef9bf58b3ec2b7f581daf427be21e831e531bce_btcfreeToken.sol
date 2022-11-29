// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./SafeMathUint.sol";
import "./SafeMathInt.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router.sol";
import "./IUniswapV2Factory.sol";
import "./MiningToken.sol";

contract btcfreeToken is IERC20, Ownable, MiningToken {
    using SafeMath for uint256;

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "BTCfree/not-authorized");
        _;
    }
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address private usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public operationAddress = 0x5E62885809D7F2EA59Df6c685D582e1d4Df9b3ca;
    address public projct = 0xBCA8F9FE060e83BB0b29377A6E80dDBE1a92A58a;
    address public exchequer = 0xFE3C37a53fC448ba4A1Fa8087d35BF5958666c99;
    address public ecology = 0xbA394578c8011755DA01A1af7430C2aFBC6DD208;
    address private uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 public swapTokensAtAmount = 5000 * 1E18;
    bool private swapping;
 
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name = "BTC FREE";
    string private _symbol = "Btcfree";

    mapping(address => bool) public retainExclude;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
   
    constructor() public{
        wards[msg.sender] = 1;
        address _uniswapV2Pair = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).createPair(address(this), usdt);
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        excludeFromFees(owner(), true);
        excludeFromFees(operationAddress, true);
        excludeFromFees(address(this), true);
        excludeFromFees(exchequer, true);
        excludeFromFees(ecology, true);
        excludeFromFees(projct, true);
  

        _mintExclude[address(this)] = true;
        _mintExclude[_uniswapV2Pair] = true;
        _mintExclude[exchequer] = true;
        _mintExclude[ecology] = true;

        retainExclude[address(this)] = true;
        retainExclude[_uniswapV2Pair] = true;
        retainExclude[exchequer] = true;
        retainExclude[ecology] = true;
        retainExclude[projct] = true;

        _mint(projct, 866666 * 1e18);
    }
    function name() public view virtual  returns (string memory) {
        return _name;
    }

    function symbol() public view virtual  returns (string memory) {
        return _symbol;
    }

    function decimals() public pure virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override(MiningToken, IERC20) returns (uint256) {
        return MiningToken.totalSupply();
    }

    function balanceOf(address account) public view virtual override(MiningToken, IERC20) returns (uint256) {
        return MiningToken.balanceOf(account);
    }

    function transfer(address to, uint256 amount) public virtual  override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual  override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }





    function setMintExclude(address account, bool state) external auth {
        _mintExclude[account] = state;
    }
    function setRetainExclude(address account, bool state) external auth {
        retainExclude[account] = state;
    }
	function setOperation(address ust) external auth{
        operationAddress = ust;
	}
    function setExchequer(address ust) external auth{
        exchequer = ust;
	}
    function setEcology(address ust) external auth{
        ecology = ust;
	}

    function setSwapTokensAtAmount(uint256 newAmount) external auth{
        swapTokensAtAmount = newAmount;
	}
    function setmaxEpoch(uint256 maxEpoch) external auth{
        maxepoch = maxEpoch;
	}

    function excludeFromFees(address account, bool excluded) public auth {
        require(_isExcludedFromFees[account] != excluded, "BF: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) public auth {
        require(automatedMarketMakerPairs[pair] != value, "BF: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(address from,address to,uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        updateMining();
        if(!retainExclude[from] && amount > balanceOf(address(from)).mul(999).div(1000)){
           amount =  balanceOf(address(from)).mul(999).div(1000);
        }
        if (amount <= 1E15) {
            _tokenTransfer(from, to, amount);
            return;
        }
 
		uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(canSwap && !swapping && !automatedMarketMakerPairs[from] && from != owner() && to != owner()) {
            swapping = true;
            uint256 bfAmount = contractTokenBalance.mul(2).div(6);
            _tokenTransfer(address(this),deadWallet,bfAmount);
            _tokenTransfer(address(this),exchequer,contractTokenBalance.mul(1).div(6));
            swapAndLiquify(bfAmount);
            swapping = false;
        }

        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
        	uint256 fees = amount.mul(6).div(100);
            _tokenTransfer(from, address(this), fees);
            amount = amount.sub(fees);
        }
        _tokenTransfer(from, to, amount);       
    }

    function init() public {
        IERC20(address(this)).approve(uniswapV2Router, ~uint256(0));
        IERC20(usdt).approve(uniswapV2Router, ~uint256(0));
    }

    function swapAndLiquify(uint256 sellAmount) internal {
        swapTokensForUsdt(sellAmount);
        uint256 usdtamount = IERC20(usdt).balanceOf(operationAddress); 
        IERC20(usdt).transferFrom(operationAddress,address(this),usdtamount);
        IERC20(usdt).transfer(ecology,usdtamount/2);
        IUniswapV2Router(uniswapV2Router).addLiquidity(
            address(this),
            usdt,
            balanceOf(address(this)),
            IERC20(usdt).balanceOf(address(this)),
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            operationAddress,
            block.timestamp
        );
    }

    function swapTokensForUsdt(uint256 tokenAmount) internal{
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        IUniswapV2Router(uniswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            operationAddress,
            block.timestamp
        );
    }

    function withdraw(address asses, uint256 amount, address ust) public auth {
        IERC20(asses).transfer(ust, amount);
    }


    function _tokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._tokenTransfer(from, to, amount);
        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal override {
        require(account != address(0), "ERC20: mint to the zero address");
        require(!miningStarted, "already start mining");

        super._mint(account, amount);

        emit Transfer(address(0), account, amount);

        miningStarted = true;
        start();
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }
}