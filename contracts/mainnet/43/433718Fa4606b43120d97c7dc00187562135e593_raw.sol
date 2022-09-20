// SPDX-License-Identifier: MIT

/* 
 * \file    rawToken.sol
 * \brief   RAW is an ERC20 token.
            But it is above all the kernel of an ecosystem of web3 applications.
 *
 * \brief   Release note
 * \version 1.0
 * \date    2022/09/20
 * \details The beginning
 *
 * \todo    Develop the raw ecosystem and his community.
 */

pragma solidity ^0.8.17;

import "../IERC20.sol";
import "../IERC20Metadata.sol";
import "../Context.sol";
import "../SafeMath.sol";

//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
//import "@openzeppelin/contracts/utils/Context.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/// https://docs.pancakeswap.finance/code/smart-contracts/pancakeswap-exchange/router-v2
interface IUniswapV2Router {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract raw is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    uint8 private constant TRANSFER = 0;
    uint8 private constant BUY 	    = 1;
    uint8 private constant SELL     = 2;

    address public admin;

    uint256 public MAX_TOKENS_PER_WALLET;
    uint8	public PURCHASE_TAX;
    uint8	public SALES_TAX;

    mapping(address => bool) public automaticPairs;
    mapping(address => bool) public dutyFree;

    struct taxWallet {
		address wallet;
		uint16 share;
		uint8 opType;
    }
    
    taxWallet[20] public _taxWallet;

    /// Variables related to uniswap :
    address private ROUTER_ADD;
    IUniswapV2Router public uniswapRouter;
    address public uniswapPair;

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    event Paused();
    event Unpaused();
    bool public paused = false;

    constructor() {
        _totalSupply = 23000000 * (10 ** 18);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        admin = msg.sender;
        
        MAX_TOKENS_PER_WALLET = 1000000 * (10 ** 18);
        PURCHASE_TAX = 2;
        SALES_TAX = 8;
	   
	   /*
         * Purchase tax : 2% -> 2% Development & Marketing
         */
        _taxWallet[0] = taxWallet(0xDb42a92000d07F3B3C28B76d205ea24CC155B17F, 2, BUY);		/// 2% BT - Dev & Marketing
	   
	   /*
         * Sales tax : 8% -> 4% Development & Marketing ; 4% Affiliate System
         */
	   _taxWallet[1] = taxWallet(0xDb42a92000d07F3B3C28B76d205ea24CC155B17F, 4, SELL);		/// 4% ST - Dev & Marketing
	   _taxWallet[2] = taxWallet(0xa29fcB48A76d9638C4D7bd42074A550E60d1e45D, 4, SELL);		/// 4% ST - Affiliate System
	   
        ROUTER_ADD = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

        uniswapRouter = IUniswapV2Router(ROUTER_ADD);
        uniswapPair = IUniswapV2Factory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());       /// Create a uniswap pair for this new token

        automaticPairs[uniswapPair] = true;
    }
    
    function version() public pure returns (string memory) {
    	   return "1.0";
    }
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(paused == false, "[raw] _approve : the contract is paused");
        require(owner != address(0), "[raw] _approve : approve FROM the zero address");
        require(spender != address(0), "[raw] _approve : approve TO the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(paused == false, "[raw] _transfer : the contract is paused");
        require(from != address(0), "[raw] _transfer : transfer FROM the zero address");
        require(to != address(0), "[raw] _transfer : transfer TO the zero address");
        require(amount > 0, "[raw] _transfer : transfer amount must be greater than zero");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "[raw] _transfer : transfer amount exceeds balance");

        unchecked {
            _balances[from] = fromBalance - amount;
        }

        uint256 fee;
        uint256 feeDeducted;
        uint8 opType;
        if ((from != admin) && (to != admin) && (dutyFree[from] != true) && (dutyFree[to] != true)) {
            if (automaticPairs[from]) {
                opType = BUY;
                fee = amount.mul(PURCHASE_TAX).div(100);
            } else if (automaticPairs[to]) {
                opType = SELL;
                fee = amount.mul(SALES_TAX).div(100);
            } else {
                opType = TRANSFER;
                fee = 0;        /// Without fee
            }
        }

        feeDeducted = (amount.sub(fee));
        
        if ((automaticPairs[to] == false) && (to != admin) && (dutyFree[to] != true)) {
        	require(_balances[to]+feeDeducted <= MAX_TOKENS_PER_WALLET, "[raw] _transfer : the wallet exceeds the maximum number of tokens");
        }
        
        unchecked {
            _balances[to] += feeDeducted;
        }
        
        if (fee > 0) {
        	  uint256 totalNbOfShares;
            uint256 totalAmountPaid = fee;
	  	  for (uint8 i=0 ; i<_taxWallet.length ; i++) {
	  	  	if (_taxWallet[i].opType == opType) {
	  			totalNbOfShares += _taxWallet[i].share;
	  		}
	  	  }
	  	  uint256 nbOfShares;
	  	  for (uint8 i=0 ; i<_taxWallet.length ; i++) {
	  	  	if (_taxWallet[i].opType == opType) {
			  	uint256 amountPaid;
			  	nbOfShares += _taxWallet[i].share; 
		  		if ((totalNbOfShares-nbOfShares) > 0) {
		  			amountPaid = _taxWallet[i].share*(10**6);
		  			amountPaid = amountPaid.div(totalNbOfShares).mul(fee).div(10**6);
		  		} else {
		  			amountPaid = totalAmountPaid;		/// For security and to be sure to redistribute all tokens
		  		}
		  		totalAmountPaid -= amountPaid; 
		  		_balances[_taxWallet[i].wallet] += amountPaid;
		  		emit Transfer(from, _taxWallet[i].wallet, amountPaid);
	  		}
	  	  }
        }

        emit Transfer(from, to, feeDeducted);

        _afterTokenTransfer(from, to, feeDeducted);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "[raw] _spendAllowance : insufficient allowance");
		    unchecked {
		       _approve(owner, spender, currentAllowance - amount);
		    }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    
    function pause() public {
        require(paused == false, "[raw] pause : the contract is already paused");
        require(msg.sender == admin, "[raw] pause : only admin");
        paused = true;
        emit Paused();
    }

    function unpause() public {
        require(paused == true, "[raw] unpause : the contract is not paused");
        require(msg.sender == admin, "[raw] unpause : only admin");
        paused = false;
        emit Unpaused();
    }

    function name() public view virtual returns (string memory) {
        return "raw";
    }

    function symbol() public view virtual returns (string memory) {
        return "RAW";
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);

        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);

        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "[raw] decreaseAllowance : decreased allowance below zero");
        unchecked {
        	_approve(owner, spender, currentAllowance - subtractedValue);
    	}

        return true;
    }

	function setMaxTokensPerWallet(uint256 newMaxTokensPerWallet) public {
		require(paused == true, "[raw] setMaxTokensPerWallet : the contract must be paused");
		require(msg.sender == admin, "[raw] setMaxTokensPerWallet : only admin");
		require (MAX_TOKENS_PER_WALLET != newMaxTokensPerWallet, "[raw] setMaxTokensPerWallet : MAX_TOKENS_PER_WALLET already has this value");
		MAX_TOKENS_PER_WALLET = newMaxTokensPerWallet;
	}

	function setAutomaticPair(address pair, bool value) public {
		require(paused == true, "[raw] setAutomaticPair : the contract must be paused");
		require(msg.sender == admin, "[raw] setAutomaticPair : only admin");
		require (automaticPairs[pair] != value, "[raw] setAutomaticPair : this pair already has this value");
		automaticPairs[pair] = value;
	}

	function setDutyFree(address elektron, bool value) public {
		require(paused == true, "[raw] setDutyFree : the contract must be paused");
		require(msg.sender == admin, "[raw] setDutyFree : only admin");
		require (dutyFree[elektron] != value, "[raw] setDutyFree : this elektron already has this value");
		dutyFree[elektron] = value;
	}

	function setPurchaseTax(uint8 percent) public {
		require(paused == true, "[raw] setPurchaseTax : the contract must be paused");
		require(msg.sender == admin, "[raw] setPurchaseTax : only admin");
		require (PURCHASE_TAX != percent, "[raw] setPurchaseTax : the purchase tax already has this value");
		PURCHASE_TAX = percent;
	}

	function setSalesTax(uint8 percent) public {
		require(paused == true, "[raw] setSalesTax : the contract must be paused");
		require(msg.sender == admin, "[raw] setSalesTax : only admin");
		require (SALES_TAX != percent, "[raw] setSalesTax : the sales tax already has this value");
		SALES_TAX = percent;
	}
    
	function newTaxWallet(address _wallet, uint16 _share, uint8 _opType) public {
		require(paused == true, "[raw] newTaxWallet : the contract must be paused");
		require(msg.sender == admin, "[raw] newTaxWallet : only admin");
		for (uint8 i=0 ; i<_taxWallet.length ; i++) {
			if (_taxWallet[i].share == 0) {
				_taxWallet[i] = taxWallet(_wallet, _share, _opType);
				break;
			}
		}
	}
    
	function deleteTaxWallet(address _wallet, uint16 _share, uint8 _opType) public {
		require(paused == true, "[raw] deleteTaxWallet : the contract must be paused");
		require(msg.sender == admin, "[raw] deleteTaxWallet : only admin");
		uint lengthMemo = _taxWallet.length;
		for (uint8 i=0 ; i<lengthMemo ; i++) {
			/// Only if the three fields are identical
			if ((_taxWallet[i].wallet == _wallet) && (_taxWallet[i].share == _share) && (_taxWallet[i].opType == _opType)) {
				delete _taxWallet[i];		/// Will create an empty location

				/// We move to fill the gap
				for (uint8 j=i ; j<lengthMemo-1 ; j++) {
					_taxWallet[j] = _taxWallet[j+1];
				}
				break;
			}
		}

		require(lengthMemo != _taxWallet.length, "[raw] deleteTaxWallet : no items to be deleted");
	}
    
    function updateTaxWallet(address _wallet, uint16 _newShare, uint8 _newOpType) public {
        require(paused == true, "[raw] updateTaxWallet : the contract must be paused");
    	require(msg.sender == admin, "[raw] updateTaxWallet : only admin");
    	for (uint8 i=0 ; i<_taxWallet.length ; i++) {
	   	    if (_taxWallet[i].wallet == _wallet) {
	   		    require ((_taxWallet[i].share != _newShare) || (_taxWallet[i].opType != _newOpType), "[raw] updateTaxWallet : share and operation type already have these values");
			    _taxWallet[i].share = _newShare;
			    _taxWallet[i].opType = _newOpType;
		    }
	   }
    }
    
    function setRouter(address newRouter) public {
	    require(paused == true, "[raw] setRouter : the contract must be paused");
    	require(msg.sender == admin, "[raw] setRouter : only admin");
        require (ROUTER_ADD != newRouter, "[raw] setRouter : the router address already has this value");
    	ROUTER_ADD = newRouter;
        IUniswapV2Router newUniswapRouter = IUniswapV2Router(ROUTER_ADD);
        uniswapPair = IUniswapV2Factory(newUniswapRouter.factory()).createPair(address(this), newUniswapRouter.WETH());
        uniswapRouter = newUniswapRouter;
    }
}