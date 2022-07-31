/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;


interface IERC20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address _owner;

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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

contract NFTS is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => address) inviter;
	mapping(address => address) inviterParper;
    mapping(address => uint256) inviterNum;
    mapping(address => uint256) rewardDayAmount;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromVip;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 private _destroyMaxAmount;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    address _default = address(0x944010108a7181b7aBC9aB24b0cF25f31e2ECE16);
	address finallyAddress = address(0x396b565b58027B6911F9889669a00D29B5492975);
	address fundAddress = address(0x8495B58b68fBb6aD187E9ee8956844D316c7f74f);
    address public uniswapV2Pair;
    IERC20 pair;
    uint256 public startTime;
    address[] buyUser;
    mapping(address => bool) public havePush;
    uint256 public fundAmount;
    uint256 public fundOverAmount;

    bool public swapBuyStats = true;
    bool public swapSellStats = true;

    constructor(address tokenOwner) {
        _name = "NFTS";
        _symbol = "NFTS";
        _decimals = 18;
        _tTotal = 10**25;
		_destroyMaxAmount = _tTotal.div(100).mul(99);
        _rTotal = (MAX - (MAX % _tTotal));
        _rOwned[tokenOwner] = _rTotal;
        _owner = msg.sender;
        _isExcludedFromFee[tokenOwner] = true;
        emit Transfer(address(0), tokenOwner, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
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
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if(uniswapV2Pair == address(0) && amount >= _tTotal.div(10000000)){
            uniswapV2Pair = recipient;
            pair = IERC20(recipient);
            havePush[sender] = true;
            buyUser.push(sender);
		}
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function excludeFromVip(address account) public onlyOwner {
        _isExcludedFromVip[account] = true;
    }

    function includeInVip(address account) public onlyOwner {
        _isExcludedFromVip[account] = false;
    }
    

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function getInviterPerpar(address account) public view returns (address) {
        return inviterParper[account];
    }

    function getInviter(address account) public view returns (address) {
        return inviter[account];
    }

    uint256 public ldxRate = 3;
	uint256 public fundRate = 3;
	uint256 public finRate = 2;
	
    function changeRate(uint256 _ldxRate,uint256 _fundRate,uint256 _finRate) public onlyOwner {
        ldxRate = _ldxRate;
		fundRate = _fundRate;
		finRate = _finRate;
    }

    function changeSwapBuyStats() public onlyOwner {
        swapBuyStats = !swapBuyStats;
    }

    function changeSwapSellStats() public onlyOwner {
        swapSellStats = !swapSellStats;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_isExcludedFromVip[from]);
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(inviter[from] == address(0) && inviterParper[from] == to && amount == 15 * 10**16){
            inviter[from] = to;
            inviterNum[to] += 1;
        }
        
        bool isInviter = from != uniswapV2Pair && balanceOf(to) == 0 && inviterParper[to] == address(0) && amount == 2 * 10**17;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            _tokenTransfer(from, to, amount, false);
        }else{
            if(from == uniswapV2Pair){
                require(swapBuyStats);
                require(balanceOf(to).add(amount) <= 10**22);
                _tokenTransfer(from, to, amount, true);
            }else if(to == uniswapV2Pair){
                require(swapSellStats);
                if(balanceOf(from) == amount){amount = amount.div(10000).mul(9999);}
                _tokenTransfer(from, to, amount, true);
            }else{
                require(balanceOf(to).add(amount) <= 10**22);
                if(amount == balanceOf(from)){amount = amount.div(10000).mul(9999);}
                _tokenTransfer(from, to, amount, false);
            }
        }

        if(isInviter) {
            inviterParper[to] = from;
        }

        if(!havePush[from] && to == uniswapV2Pair){
            havePush[from] = true;
            buyUser.push(from);
        }
    }
    

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        uint256 rate;
        if (takeFee) {
            sender2parter();
            _takeTransfer(
                sender,
                fundAddress,
                tAmount.div(100).mul(fundRate),
                currentRate
            );
            _takeTransfer(
                sender,
                finallyAddress,
                tAmount.div(100).mul(finRate),
                currentRate
            );
            _takeTransfer(
                sender,
                address(this),
                tAmount.div(100).mul(ldxRate),
                currentRate
            );
            _takeInviterFee(sender, recipient, tAmount, currentRate);//5
            rate = 5 + ldxRate + finRate + fundRate;
        }
        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(rAmount.div(100).mul(recipientRate));
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }

    function sender2parter() private {
        uint256 balance = balanceOf(address(this));
        if(balance > 10**18){
            sender2parter2(balance);
        }
    }

    function getLdxSize() public view returns (uint256) {
        return buyUser.length;
    }

    uint256 public startIndex;
    function sender2parter2(uint256 thisAmount) private {
        uint256 buySize = buyUser.length;
		if(buySize>0){
			address user;
			uint256 totalAmount = pair.totalSupply();
			uint256 rate;
			if(buySize >20){
				for(uint256 i=0;i<20;i++){
					if(startIndex >= buySize){startIndex = 0;}
					user = buyUser[startIndex];
					if(balanceOf(user) >= 0){
						rate = pair.balanceOf(user).mul(1000000000).div(totalAmount);
						if(rate>0){
							_tokenTransfer(address(this), user, thisAmount.mul(rate).div(1000000000), false);
						}
					}
					startIndex = startIndex.add(1);
				}
			}else{
				for(uint256 i=0;i<buySize;i++){
					user = buyUser[i];
					if(balanceOf(user) >= 0){
						rate = pair.balanceOf(user).mul(1000000000).div(totalAmount);
						if(rate>0){
                            _tokenTransfer(address(this), user, thisAmount.mul(rate).div(1000000000), false);
						}
					}
				}
			}
		}
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[to] = _rOwned[to].add(rAmount);
        emit Transfer(sender, to, tAmount);
    }

    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
		pair = IERC20(router);
    }

    function withdrawToken(IERC20 router) public onlyOwner {
		router.transfer(msg.sender,router.balanceOf(address(this)));
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        address cur;
        address recieveD;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        }
        uint256 rate;
        for (uint256 i = 0; i < 15; i++) {
            cur = inviter[cur];
            if(i == 0){
                rate = 10;
            }else if(i < 3){
                rate = 5;
            }else if(i < 13){
                rate = 2;
            }else{
                rate = 5;
            }
            if (cur != address(0) && inviterNum[cur] > i) {
                recieveD = cur;
            }else{
                recieveD = _default;
			}
            uint256 curTAmount = tAmount.div(1000).mul(rate);
            uint256 curRAmount = curTAmount.mul(currentRate);
            _rOwned[recieveD] = _rOwned[recieveD].add(curRAmount);
            emit Transfer(sender, recieveD, curTAmount);
        }
    }
}