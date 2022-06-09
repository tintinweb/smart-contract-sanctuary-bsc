/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
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
    address public _owner;
    
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

contract Util {

    function mathDivisionToFloat(uint256 a, uint256 b, uint decimals) public pure returns (uint256){
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 amount = aPlus / b;
        return amount;
    }

}

abstract contract ERC20 {
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function balanceOf(address account) external virtual view returns (uint256);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IUniswapV2Router02 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external view returns (address);

}

contract JkcToken is IERC20, Ownable, Util {

    using SafeMath for uint256;

    string public _name;
    string public _symbol;
    uint8 public _decimals;

    uint256 public _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    
    mapping(address => uint256) private lastPurchaseTime;
    uint256 private shortestTradingTime; // second

    mapping(address => uint256) private lastSellTime;
    uint private shortestSellTime; // second

    mapping(address => address) private inviter;

    uint256 private purchaseLimit;
    uint256 private holdNumLimit;
    uint256 private bindInviterLimit;
    uint256 private inviteAwardOneLimit;
    uint256 private inviteAwardTwoLimit;
    uint256 private sellLimitRatio;
    uint256 private transferLimitRatio;
    uint256 private maxDestroyLimit;

    uint256 private lpRatio;
    uint256 private tradePoolRatio;
    uint256 private destroyRatio;
    uint256 private promoteRatio;

    address private lpAddress;
    address private tradePoolAddress;
    address private destroyAddress;
    address private extraAddress;

    address public swapRouter;
    address private _scarecrow;

    uint256 [] levelRatios;

    ERC20 private usdtToken;
    IUniswapV2Router02 public immutable uniswapV2Router;
    
    constructor() {

        _name = "JKC";
        _symbol = "JKC";
        _decimals = 18;

        _totalSupply = 999999 * 10 ** uint(_decimals);
		
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
        
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _owner = msg.sender;
        _scarecrow = msg.sender;

        lpRatio = 40;
        tradePoolRatio = 10;
        destroyRatio = 10;
        promoteRatio = 70;

        shortestTradingTime = 0;
        shortestSellTime = 30;
        purchaseLimit = 200000000000000000000;
        holdNumLimit = 1000000000000000000000;
        bindInviterLimit = 10000000000000000;
        inviteAwardOneLimit = 1000000000000000000;
        inviteAwardTwoLimit = 0;
        sellLimitRatio = 99;
        transferLimitRatio = 99;
        maxDestroyLimit = 99999000000000000000000;

        usdtToken = ERC20(0x55d398326f99059fF775485246999027B3197955);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        swapRouter = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(usdtToken));
        uniswapV2Router = _uniswapV2Router;

        lpAddress = 0x4a4065392ACFe0C129fA72e93483E8C2881E2Bb8;
        extraAddress = 0x32c1608AfB248F9B0c0Ff4f9C51A6efBa31a919c;
        destroyAddress = 0x000000000000000000000000000000000000dEaD;

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
        return _totalSupply;
    }

    function balanceOf(address _address) public view override returns (uint256) {
        return _balances[_address];
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
    
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
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
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(sender != swapRouter && recipient != swapRouter && inviter[recipient] == address(0)
            && amount >= bindInviterLimit) {
            inviter[recipient] = sender;
        }

        if(sender == swapRouter && !_isExcludedFromFee[recipient]) {
            // buy

            if(amount > purchaseLimit) {
                revert("Exceeded maximum purchase amount");
            }

            if(_balances[recipient].add(amount) > holdNumLimit) {
                revert("Exceed the maximum amount of coins held");
            }

            uint256 lpAmount = amount.mul(lpRatio).div(1000);
            uint256 tradePoolAmount = amount.mul(tradePoolRatio).div(1000);

            uint256 destroyAmount = amount.mul(destroyRatio).div(1000);
            if(_balances[0x000000000000000000000000000000000000dEaD].add(destroyAmount) >= maxDestroyLimit) {
                destroyAmount = 0;
            }
            uint256 promoteAmount = amount.mul(promoteRatio).div(1000);

            uint256 inviteTotalAmount = 0;
            uint256 inviteAmount = 0;
            address inviteAddress = inviter[recipient];
            if(inviteAddress != address(0)) {
                for(uint8 i=0; i<levelRatios.length; i++) {
                    
                    if(_balances[inviteAddress] >= inviteAwardOneLimit || ERC20(swapRouter).balanceOf(inviteAddress) > inviteAwardTwoLimit) {

                        inviteAmount = promoteAmount.mul(levelRatios[i]).div(1000);

                        _balances[inviteAddress] = _balances[inviteAddress].add(inviteAmount);
                        emit Transfer(sender, inviteAddress, inviteAmount);
                        inviteTotalAmount = inviteTotalAmount.add(inviteAmount);

                        inviteAddress = inviter[inviteAddress];
                        if(inviteAddress == address(0)) {
                            break;
                        }

                    }

                }
            }

            if(promoteAmount > inviteTotalAmount) {
                _balances[extraAddress] = _balances[extraAddress].add(promoteAmount.sub(inviteTotalAmount));
                emit Transfer(sender, extraAddress, promoteAmount.sub(inviteTotalAmount));
            }

            _balances[lpAddress] = _balances[lpAddress].add(lpAmount);
            _balances[tradePoolAddress] = _balances[tradePoolAddress].add(tradePoolAmount);
            _balances[destroyAddress] = _balances[destroyAddress].add(destroyAmount);

            emit Transfer(sender, lpAddress, lpAmount);
            emit Transfer(sender, tradePoolAddress, tradePoolAmount);
            emit Transfer(sender, destroyAddress, destroyAmount);

            uint256 slippageAmount = lpAmount.add(tradePoolAmount).add(destroyAmount).add(promoteAmount);

            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount.sub(slippageAmount));
            emit Transfer(sender, recipient, amount.sub(slippageAmount));

        } else if(recipient == swapRouter && !_isExcludedFromFee[sender]) {
            // sell

            if((block.timestamp - lastPurchaseTime[sender]) < shortestTradingTime) {
                revert("Frequent operation");
            }

            uint256 sellLimit = _balances[sender].mul(sellLimitRatio).div(100);
            if(amount > sellLimit) {
                revert("Exceeded maximum sell amount");
            }

            if(block.timestamp - lastSellTime[sender] <= shortestSellTime) {
                revert("Exceeded sell interval");
            }

            lastSellTime[sender] = block.timestamp;

            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);

        } else {
            
            bool flag = true;
            if(sender == swapRouter || recipient == swapRouter) {
                flag = false;
            }
            if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
                flag = false;
            }

            if(flag) {
                uint256 transferLimit = _balances[sender].mul(transferLimitRatio).div(100);
                if(amount > transferLimit) {
                    revert("Exceeded maximum transfer amount");
                }

                if(_balances[recipient].add(amount) > holdNumLimit) {
                    revert("Exceed the maximum amount of coins held");
                }
            }

            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
            
        }
        
    }

    function excludeFromFee(address _address) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        _isExcludedFromFee[_address] = true;
    }

    function excludeFromFeeByArray(address [] memory addressList) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        for(uint8 i=0; i<addressList.length; i++) {
            _isExcludedFromFee[addressList[i]] = true;
        }
    }

    function includeInFee(address _address) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        _isExcludedFromFee[_address] = false;
    }

    function isExcludedFromFee(address _address) public view returns (bool) {
        return _isExcludedFromFee[_address];
    }

    function changeRouter(address router) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        swapRouter = router;
    }

    function setShortestTradingTime(uint256 _time) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        shortestTradingTime = _time;
    }

    function setShortestSellTime(uint _time) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        shortestSellTime = _time;
    }

    function setPurchaseLimit(uint256 _amount) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        purchaseLimit = _amount;
    }

    function setHoldNumLimit(uint256 _amount) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        holdNumLimit = _amount;
    }

    function setBindInviterLimit(uint256 _amount) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        bindInviterLimit = _amount;
    }

    function setInviteAwardOneLimit(uint256 _amount) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        inviteAwardOneLimit = _amount;
    }

    function setInviteAwardTwoLimit(uint256 _amount) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        inviteAwardTwoLimit = _amount;
    }

    function setMaxDestroyLimit(uint256 _amount) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        maxDestroyLimit = _amount;
    }

    function setSellLimitRatio(uint256 _ratio) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        sellLimitRatio = _ratio;
    }
    
    function setTransferLimitRatio(uint256 _ratio) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        transferLimitRatio = _ratio;
    }

    function setLpRatio(uint256 _ratio) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        lpRatio = _ratio;
    }

    function setTradePoolRatio(uint256 _ratio) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        tradePoolRatio = _ratio;
    }

    function setDestroyRatio(uint256 _ratio) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        destroyRatio = _ratio;
    }

    function setPromoteRatio(uint256 _ratio) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        promoteRatio = _ratio;
    }
    
    function bindInviter(address _address) public {
        if(inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = _address;
        }
    }

    function updateInviter(address [] memory addressList, address [] memory inviterList) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        for(uint8 i=0; i<addressList.length; i++) {
            inviter[addressList[i]] = inviterList[i];
        }
    }

    function setLevelRatios(uint256 [] memory _ratios) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        delete levelRatios;
        for(uint8 i=0; i<_ratios.length; i++) {
            levelRatios.push(_ratios[i]);
        }
    }

    function setLpAddress(address _address) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        lpAddress = _address;
    }

    function setTradePoolAddress(address _address) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        tradePoolAddress = _address;
    }

    function setExtraAddress(address _address) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        extraAddress = _address;
    }

    function setDestroyAddress(address _address) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        destroyAddress = _address;
    }

    function setScarecrowAddress(address _address) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        _scarecrow = _address;
    }

    function tokenOutput(address tokenAddress, address receiveAddress, uint amountToWei) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        ERC20(tokenAddress).transfer(receiveAddress, amountToWei);
    }

    function getInviter(address _address) public view returns (address) {
        return inviter[_address];
    }

    // 1 JKC = ? U
    function queryThisToUsdtPrice() public view returns (uint256) {
        uint256 reserveA = _balances[swapRouter];
        uint256 reserveB = usdtToken.balanceOf(swapRouter);
        return Util.mathDivisionToFloat(reserveB, reserveA, 18);
    }

    function queryUsdtToThisPrice() public view returns (uint256) {
        uint256 reserveA = _balances[swapRouter];
        uint256 reserveB = usdtToken.balanceOf(swapRouter);
        return Util.mathDivisionToFloat(reserveA, reserveB, 18);
    }

}