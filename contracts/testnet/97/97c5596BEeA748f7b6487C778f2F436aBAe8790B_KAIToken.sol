/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface IPancakeSwapRouter{
	function factory() external pure returns (address);
	function WETH() external pure returns (address);

	function addLiquidity(
			address tokenA,
			address tokenB,
			uint amountADesired,
			uint amountBDesired,
			uint amountAMin,
			uint amountBMin,
			address to,
			uint deadline
	) external returns (uint amountA, uint amountB, uint liquidity);
	function addLiquidityETH(
			address token,
			uint amountTokenDesired,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline
	) external payable returns (uint amountToken, uint amountETH, uint liquidity);
	function removeLiquidity(
			address tokenA,
			address tokenB,
			uint liquidity,
			uint amountAMin,
			uint amountBMin,
			address to,
			uint deadline
	) external returns (uint amountA, uint amountB);
	function removeLiquidityETH(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline
	) external returns (uint amountToken, uint amountETH);
	function removeLiquidityWithPermit(
			address tokenA,
			address tokenB,
			uint liquidity,
			uint amountAMin,
			uint amountBMin,
			address to,
			uint deadline,
			bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountA, uint amountB);
	function removeLiquidityETHWithPermit(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline,
			bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountToken, uint amountETH);
	function swapExactTokensForTokens(
			uint amountIn,
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
	) external returns (uint[] memory amounts);
	function swapTokensForExactTokens(
			uint amountOut,
			uint amountInMax,
			address[] calldata path,
			address to,
			uint deadline
	) external returns (uint[] memory amounts);
	function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
			external
			payable
			returns (uint[] memory amounts);
	function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
			external
			returns (uint[] memory amounts);
	function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
			external
			returns (uint[] memory amounts);
	function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
			external
			payable
			returns (uint[] memory amounts);

	function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
	function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
	function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
	function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
	function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
	function removeLiquidityETHSupportingFeeOnTransferTokens(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline
	) external returns (uint amountETH);
	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline,
		bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountETH);

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external;
	function swapExactETHForTokensSupportingFeeOnTransferTokens(
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external payable;
	function swapExactTokensForETHSupportingFeeOnTransferTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external;
}

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

contract Context {
	constructor () internal { }

	function _msgSender() internal view returns (address payable) {
		return msg.sender;
	}

	function _msgData() internal view returns (bytes memory) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}

contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor () internal {
		address msgSender = _msgSender();
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
	}

	function owner() public view returns (address) {
		return _owner;
	}

	modifier onlyMainOwner() {
		require(_owner == _msgSender(), "Ownable: caller is not the mainowner");
		_;
	}

	function renounceOwnership() public onlyMainOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	function transferOwnership(address newOwner) public onlyMainOwner {
		_transferOwnership(newOwner);
	}

	function _transferOwnership(address newOwner) internal {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

library SafeMath {

	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}


contract KAIToken is  Context, Ownable  {

	using SafeMath for uint256;

	IPancakeSwapRouter public PancakeSwapRouter;

	uint256 private _totalSupply;
	uint8 private _decimals;

	uint256 public _maxSupply = 5e9 * 1e15; // maximum supply: 5,000,000,000,000,000
	uint public _limitTxAmount = 5e9 * 1e15; // transaction limit: 5,000,000,000,000,000
	uint public limitedBuybackBalance = 5e18; // swap token amount: 5 BNB

	string private _symbol;
	string private _name;
 
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
	address public marketingAddress = 0xa14d5003084bd888784a39F46c6D7603Bc9D55D7;
	address public LPAddress = 0x17ec08a4B8C1c98fC0FC70A1619e02220C07aBac;
	address private BUSD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
	address public WBNB = address(0);

	bool public autoBuyback = true;

	mapping (address => uint256) private _balances;
	mapping (address => bool) private substituteOwner;
	mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) _isExcludeFromFee;
    mapping(address => bool) isBlackList;
    mapping(address => bool) isMinter;

	address[] holderList;

	struct Fees {
		uint reflection;
		uint marketing;
		uint liquidity;
		uint buyback;
	}
	
	Fees public transferFees = Fees({
		reflection : 6,
		liquidity : 4,
        marketing : 2,
		buyback : 3
	});
	uint transterTotalfee = transferFees.reflection + transferFees.liquidity + transferFees.marketing + transferFees.buyback;
	/* --------- event define --------- */

    event SetWhiteList(address user, bool isWhiteList);
    event SetBlackList(address user, bool isBlackList);
    event SetSellFee(Fees sellFees);
    event SetBuyFee(Fees buyFees);
	event SetTransferFee(Fees transferFees);
	event TransterTotalFee(uint transferFees);
    event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);

	modifier onlyMinter() {
        require(isMinter[msg.sender], "LST::onlyMinter: caller is not the minter");
        _;
    }
	modifier onlyOwner() {
		require(substituteOwner[_msgSender()], "Ownable: caller is not the owner");
		_;
	}

	function getOwner() external view returns (address) {return owner();}

	function decimals() external view returns (uint8) {return _decimals;}

	function symbol() external view returns (string memory) {return _symbol;}

	function name() external view returns (string memory) {return _name;}

	function totalSupply() external view returns (uint256) {return _totalSupply;}

	function balanceOf(address account) public view returns (uint256) {return _balances[account];}

	function transfer(address recipient, uint256 amount) external returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) external view returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) external returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "LST::transferFrom: transfer amount exceeds allowance"));
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "LST::decreaseAllowance: decreased allowance below zero"));
		return true;
	}

	function burn(uint256 amount) external {
		_burn(msg.sender,amount);
	}

	function _mint(address account, uint256 amount) internal {
		require(account != address(0), "LST::_mint: mint to the zero address");
		require(
            _maxSupply >= _totalSupply.add(amount),
            "LST::_mint: The total supply has exceeded the max supply."
        );
		_totalSupply = _totalSupply.add(amount);
		_balances[account] = _balances[account].add(amount);
		emit Transfer(address(0), account, amount);
	}

	function _burn(address account, uint256 amount) internal {
		require(account != address(0), "LST::_burn: burn from the zero address");

		_balances[account] = _balances[account].sub(amount, "LST::_burn: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, burnAddress, amount);
	}

	function _approve(address owner, address spender, uint256 amount) internal {
		require(owner != address(0), "LST::_approve approve from the zero address");
		require(spender != address(0), "LST::_approve approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}
 
	function _burnFrom(address account, uint256 amount) internal {
		_burn(account, amount);
		_approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "LST::_burnFrom: burn amount exceeds allowance"));
	}

    constructor () public {
        _name = "KAI";
        _symbol = "KAI";
        _decimals = 9;
        _totalSupply = 1e9*1e15; /// initial supply 1,000,000,000,000,000
        _balances[msg.sender] = _totalSupply;

        PancakeSwapRouter = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        // PancakeSwapRouter = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

		WBNB = PancakeSwapRouter.WETH();
        
        _isExcludeFromFee[owner()] = true;

        emit Transfer(address(0), msg.sender, _totalSupply);
        emit SetWhiteList(owner(), true);
    }

	function mint(uint256 _amount) external onlyMinter returns (bool) {
        _mint(_msgSender(), _amount);
        return true;
    }

    function mint(address _to, uint256 _amount)external onlyMinter returns (bool) {
        _mint(_to, _amount);
        return true;
    }

	function setAutoBuyback() external onlyOwner returns (bool){
		autoBuyback = !autoBuyback;
		return autoBuyback;
	}

	function setSubstituteOwner(address toBeowner) external onlyMainOwner returns (bool){
		require(toBeowner != address(0), "LST:: address 0 can not be Owner");
		substituteOwner[toBeowner] = true;
		return true;
	}

	function setInitialAddresses(address _RouterAddress) external onlyOwner {
		require(_RouterAddress != address(0),"LST::_RouterAddress RouterAddress to the zero address" );
        PancakeSwapRouter = IPancakeSwapRouter(_RouterAddress);
		WBNB = PancakeSwapRouter.WETH();
	}

	function setFeeAddresses( address _marketingAddress, address _LPAddress) external onlyOwner {
		marketingAddress = _marketingAddress;		
		LPAddress = _LPAddress;
	}

	function setLimitTxAmount(uint limitTxAmount) external onlyOwner {
		require(limitTxAmount <= 0,"LST:: setLimitTxAmount:value must better than 0");
		_limitTxAmount = limitTxAmount;
	}

	function setLimitedBuybackBalance(uint _limitedBuybackBalance) external onlyOwner {
		require(_limitedBuybackBalance <= 0,"LST:: setLimitedBuybackBalance:value must better than zero");
		limitedBuybackBalance = _limitedBuybackBalance;
	}

	function setTransferFee(uint256 _reflection, uint256 _LPFee, uint256 _marketingFee, uint256 _buybackFee) external onlyOwner{
		transferFees.reflection = _reflection;
		transferFees.liquidity = _LPFee;
        transferFees.marketing = _marketingFee;
		transferFees.buyback = _buybackFee;
        transterTotalfee = _LPFee + _marketingFee + _buybackFee + _reflection;
		emit SetTransferFee(transferFees);
		emit TransterTotalFee(transterTotalfee);
	}

	function setBlackList(address account, bool _isBlackList) external onlyOwner {
        require(
            isBlackList[account] != _isBlackList,
            "LST::setBlackList: Account is already the value of that"
        );
        isBlackList[account] = _isBlackList;

        emit SetBlackList(account, _isBlackList);
    }

    function excludeFromFee(address account) external onlyOwner {
        require(
            _isExcludeFromFee[account] != true,
            "LST::excludeFromFee: Account in list already."
        );
        _isExcludeFromFee[account] = true;

        emit SetWhiteList(account, true);
    }

    function includeInFee(address account) external onlyOwner {
        require(
            _isExcludeFromFee[account] == true,
            "LST::includeInFee: Account not in list."
        );
        _isExcludeFromFee[account] = false;

        emit SetWhiteList(account, false);
    }
	function refBalanceTransferFrom( address to, uint256 amount) external onlyOwner {
		require(to == address(0), "LST::recipient address to the zero address");
		IBEP20(WBNB).transferFrom(address(this), to, amount);
	}

	function setMinter(address _minterAddress, bool _isMinter) external onlyOwner {
        require(
            isMinter[_minterAddress] != _isMinter,
            "LST::setMinter: Account is already the value of that"
        );
        isMinter[_minterAddress] = _isMinter;
    }

	function _transfer(address sender, address recipient, uint256 amount) internal {

		require(sender != address(0), "LST::_transfer: transfer from the zero address");
		require(recipient != address(0), "LST::_transfer: transfer to the zero address");
		require(!isBlackList[sender], "LST::_transfer: Sender is backlisted");
		require(!isBlackList[recipient], "LST::_transfer: Recipient is backlisted");

		checkHolderList(sender);
		checkHolderList(recipient);

		_balances[sender] = _balances[sender].sub(amount, "LST::_transfer: transfer amount exceeds balance");

		uint recieveAmount = amount;

		uint reflectionLimited = IBEP20(BUSD).balanceOf(address(this));
		if(reflectionLimited>=2000e18){
			divideReflectBalance(reflectionLimited);
		}

		uint buybackBalance = IBEP20(WBNB).balanceOf(address(this));
		if(autoBuyback && buybackBalance >=5e18){
			swapTokensAndBurn(buybackBalance);
		}else if(!autoBuyback && buybackBalance >= limitedBuybackBalance){
			swapTokensAndBurn(buybackBalance);
		}

		if(!_isExcludeFromFee[sender] && !_isExcludeFromFee[recipient]) {
			recieveAmount = amount.mul(transterTotalfee).div(100);

			uint refBalance = swapTokensForBUSD(amount.mul(transferFees.reflection).div(100));
			uint lpBalance = swapTokensForBNB(amount.mul(transferFees.liquidity).div(100), LPAddress);
			uint buyBalance = swapTokensForBNB(amount.mul(transferFees.buyback).div(100), address(this));
			swapTokensForBNB(amount.mul(transferFees.marketing).div(100) ,marketingAddress);
			_balances[LPAddress] += lpBalance;

			emit Transfer(sender, marketingAddress, refBalance);
			emit Transfer(sender, LPAddress, lpBalance);
			emit Transfer(sender, address(this), buyBalance);
		}

		_balances[recipient] = _balances[recipient].add(recieveAmount);

		emit Transfer(sender, recipient, amount);
	}


	function swapTokensForBNB(
		uint256 tokenAmount,
		address toAddress
	) public returns (uint){
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

		_approve(_msgSender(), address(PancakeSwapRouter),tokenAmount);
		
        uint[] memory amounts = PancakeSwapRouter.swapExactTokensForETH(
            tokenAmount,
            0,
            path,
            toAddress,
            block.timestamp.add(10000)
        );
		return amounts[1];

    }
	function swapTokensForBUSD(
		uint256 tokenAmount
	) public returns (uint) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = BUSD;

		_approve(address(this), address(PancakeSwapRouter), tokenAmount);
        IBEP20(BUSD).approve(address(this),tokenAmount);

        uint[] memory amounts = PancakeSwapRouter.swapExactTokensForTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp.add(10000)
        );
		return amounts[1];
    }

	function swapTokensAndBurn(
		uint256 tokenAmount
	) public {
        address[] memory path = new address[](2);
        path[0] = BUSD;
        path[1] = address(this);

        PancakeSwapRouter.swapExactTokensForTokens(
            tokenAmount,
            0, 
            path,
            burnAddress,
            block.timestamp
        );
    }

	function checkHolderList(address toAddress) private{
		bool flag = false;
		for(uint i=0; i< holderList.length; i++){
			if(holderList[i] == toAddress){
				flag = true;
				break;
			}
		}
		if(!flag && !_isExcludeFromFee[toAddress]) 
			holderList.push(toAddress);
	}

	function divideReflectBalance(uint Balance) private {
		uint totalHoldersBalances = 0;
		for(uint i=0; i < holderList.length; i++ ){
			totalHoldersBalances += _balances[holderList[i]];
		}
		uint val = uint(Balance/totalHoldersBalances);
		for(uint i=0; i<holderList.length; i++){
			IBEP20(BUSD).transferFrom(address(this), holderList[i], IBEP20(BUSD).balanceOf(holderList[i])*val);
		}
	}

	function withdrawStuckBNB() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

	receive() external payable {
	}

    function safe32(uint256 n, string memory errorMessage)internal pure returns (uint32){
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}