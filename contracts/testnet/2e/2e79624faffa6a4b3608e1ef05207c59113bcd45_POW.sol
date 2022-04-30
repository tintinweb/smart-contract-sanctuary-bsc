/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-20
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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender , "Ownable: caller is not the owner");
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

contract POW is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) public _updated;
    mapping(address => bool) public _updatedStaker;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _tTotalMaxDestroy;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    uint256 public period = 1 minutes;
    uint256 public fundLock = 365*24 hours;
    uint256 public curentTime;
    uint256 public startTime;


    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 public totalShares;
    uint256 public totalRelease;
    bool public swapStats;
    bool public swapAndLiquify;
    mapping (address => uint256) public shareholderIndexes;
    address[] public shareholders;

    address[] public stakers;
    mapping (address => uint256) public stakerIndexes;

    uint256 currentIndex;
    uint256 stakerIndex;

    uint256 public _liquidityFee = 20;

    uint256 public _destroyFee = 10;
    address private _destroyAddress =
        address(0x000000000000000000000000000000000000dEaD);
     uint256 public constant PRECISION_FACTOR = 10**18;

    uint256 public _inviterFee = 10;
    address public inviterAddress = address(0x14Cec78de39948FA4BB19Fc2184Ee5394f653A54);
    mapping(address => address) public inviter;
    address public uniswapV2Pair;
    address public socialAddress = address(0xEFd0cD405ff9974cC36F9B98F8Ca0C74330aF425);
    address public techAddress = address(0x67dd5825748645e0699c8724Af054Fa1855d736C);
    address public fundAddress = address(0x3A26894729dAFc87B4B1c8fD9E3F6BA12D149e77);
    address public fenHongAddress;

    uint256 public LPFeefenhong;
    address public wkgToken;
    uint256 public FHTotal;
    
    uint256 public _fund1Fee = 20;
   

    address private fromAddress;
    address private toAddress;
    struct UserInfo {
        uint256 shares; // shares of WKG staked
        uint256 rewards; // pending rewards
    }
    mapping(address => UserInfo) public userInfo;

    constructor(address _wkgToken,address _fenHongAddress) {
        _name = "POWER PLANET";
        _symbol = "POW";
        _decimals = 18;
        FHTotal = 60;
        wkgToken = _wkgToken;
        curentTime = block.timestamp;
        startTime = block.timestamp;
        fenHongAddress = _fenHongAddress;

        _tTotal = 10008 * 10**_decimals;
        uint256 leftAmount = 1 * 10**_decimals;
        _tTotalMaxDestroy = _tTotal.sub(leftAmount);
        _rTotal = (MAX - (MAX % _tTotal));

        _rOwned[address(this)] = _rTotal.div(1000).mul(900);

        //exclude owner and this contract from fee
        _isExcludedFromFee[address(this)] = true;
        _owner = msg.sender;
        _rOwned[socialAddress] = _rTotal.div(1000).mul(50);
        _rOwned[techAddress] = _rTotal.div(1000).mul(30);
        _rOwned[fundAddress] = _rTotal.div(1000).mul(20);

        emit Transfer(address(0), address(this), _rTotal.div(1000).mul(900));
        emit Transfer(address(0), socialAddress, _rTotal.div(1000).mul(50));
        emit Transfer(address(0), techAddress, _rTotal.div(1000).mul(30));
        emit Transfer(address(0), fundAddress, _rTotal.div(1000).mul(20));
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
        require(swapAndLiquify || _isExcludedFromFee[sender]);
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

    function changeSwapStats() public onlyOwner {
        swapStats = !swapStats;
    }
    function openSwapAndLiquify() public onlyOwner {
        swapAndLiquify = true;
    }

    //to recieve BNB from uniswapV2Router when swaping
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

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

//获取用户信息
    function getUserInfo(address user) public returns (UserInfo memory) {
        _updateReward();
        return userInfo[user];
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
//质押
    function deposit(uint256 amount) public  {
        require(amount >= PRECISION_FACTOR, "Deposit: Amount must be >= 1 WKG");
        // Update reward for user
        _updateReward();

        // Transfer WKG tokens to this address
        IERC20(wkgToken).transferFrom(msg.sender, address(this), amount);

        // Adjust internal shares
        userInfo[msg.sender].shares += amount;
        setStaker(msg.sender);
        
        totalShares += amount;
    }

//提现
    function withdraw(uint256 amount) public  {
        require(
            (amount > 0) && (amount <= userInfo[msg.sender].shares),
            "Withdraw: Shares equal to 0 or larger than user shares"
        );

        // Update reward for user
        _updateReward();

        // Transfer WKG tokens to this address
        IERC20(wkgToken).transfer(msg.sender, amount);

        // Adjust internal shares
        userInfo[msg.sender].shares -= amount;
        totalShares -= amount;
    }
    function _updateReward() public {
        uint256 hh = (block.timestamp-startTime)/period;
        uint256 currentRelease;
        if(hh != 0){
        uint256 perPaid = 6169315068493151000;
        totalRelease += hh*perPaid;
        currentRelease = hh*perPaid;
        startTime = hh*period+startTime;
        }
        uint256 stakerCount = stakers.length;
        uint256 iterations = 0;
        uint256 nowbanance = currentRelease;
        if(stakerCount == 0)return;
        while(iterations < stakerCount && nowbanance != 0) {
            if(stakerIndex >= stakerCount){
                stakerIndex = 0;
            }
        uint256 amount = nowbanance.mul(userInfo[stakers[currentIndex]].shares).div(totalShares);
        userInfo[stakers[currentIndex]].rewards += amount;
            stakerIndex++;
            iterations++;
        }
    }
    

    //提取奖励的POW

    function harvest() public {

        // Update reward for user
        _updateReward();

        // Retrieve pending rewards
        uint256 pendingRewards = userInfo[msg.sender].rewards;

        // If pending rewards are null, revert
        require(pendingRewards > 0, "Harvest: Pending rewards must be > 0");

        // Adjust user rewards and transfer
        userInfo[msg.sender].rewards = 0;

        // Transfer reward token to sender
        distributeDividend(address(this),msg.sender, pendingRewards);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        _updateReward();

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        uint256 _destroyAmount = balanceOf(_destroyAddress);
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || _destroyAmount >= _tTotalMaxDestroy) {
            takeFee = false;
        }

       
        bool shouldSetInviter = balanceOf(to) == 0 &&
            inviter[to] == address(0) &&
            from != uniswapV2Pair;

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);

        if (shouldSetInviter) {
            inviter[to] = from;
        }
        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;  
        if(fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(toAddress != uniswapV2Pair ) setShare(toAddress);
        
        fromAddress = from;
        toAddress = to; 
        uint256  fengHongAmount = amount.div(1000).mul(_fund1Fee);
        distributeDividend(from,fenHongAddress,fengHongAmount);
        uint256 fenhongTotal = _rOwned[fenHongAddress];
        if(fenhongTotal >= FHTotal * 10**18 && from !=address(this) && LPFeefenhong <= block.timestamp) {
             process(fenHongAddress,fenhongTotal) ;
             LPFeefenhong = block.timestamp;
        }

         
    }

     function process(address from,uint256 fengHongAmount) private {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0)return;
        uint256 nowbanance = fengHongAmount;

        uint256 iterations = 0;

        while(iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

          uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());
            distributeDividend(from,shareholders[currentIndex],amount);
            currentIndex++;
            iterations++;
        }
    }
    function distributeDividend(address from ,address shareholder ,uint256 amount) internal {
            
            _rOwned[from] = _rOwned[from].sub(amount);
            _rOwned[shareholder] = _rOwned[shareholder].add(amount);
             emit Transfer(from, shareholder, amount);
    }
    function setShare(address shareholder) private {
           if(_updated[shareholder] ){      
                if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
            addShareholder(shareholder);
            _updated[shareholder] = true;
          
      }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
           removeShareholder(shareholder);   
           _updated[shareholder] = false; 
      }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function setStaker(address staker) private {
           if(_updatedStaker[staker] ){      
                if(userInfo[staker].shares == 0) quitStaker(staker);              
                return;  
           }
           if(userInfo[staker].shares == 0) return;  
            addStaker(staker);
            _updatedStaker[staker] = true;
          
      }
    function addStaker(address staker) internal {
        stakerIndexes[staker] = stakers.length;
        stakers.push(staker);
    }
    function quitStaker(address staker) private {
           removeStaker(staker);   
           _updatedStaker[staker] = false; 
      }
    function removeStaker(address staker) internal {
        stakers[stakerIndexes[staker]] = stakers[stakers.length-1];
        stakerIndexes[stakers[stakers.length-1]] = stakerIndexes[staker];
        stakers.pop();
    }

 

    //this method is responsible for taking all fee, if takeFee is true
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
            _takeTransfer(
                sender,
                _destroyAddress,
                tAmount.div(1000).mul(_destroyFee),
                currentRate
            );
            _takeTransfer(
                sender,
                inviterAddress,
                tAmount.div(1000).mul(_inviterFee),
                currentRate
            );
            if(sender == uniswapV2Pair){
                _takeTransfer(
                sender,
                uniswapV2Pair,
                tAmount.div(1000).mul(20),
                currentRate
                );
            }else{
                _takeTransfer(
                sender,
                uniswapV2Pair,
                tAmount.div(1000).mul(10),
                currentRate
             );
             _takeInviterFee(sender, recipient, tAmount, currentRate);
            }
           
            rate = _destroyFee + _inviterFee + _fund1Fee + _liquidityFee;
        }
        uint256 recipientRate = 1000 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(1000).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(1000).mul(recipientRate));
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

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        address cur;
        
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        }
        for (int256 i = 0; i < 2; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 8;
            } else if (i <= 1) {
                rate = 2;
            } else {
                rate = 10;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                uint256 curTAmount = tAmount.div(1000).mul(rate);
                uint256 curRAmount = curTAmount.mul(currentRate);
                _rOwned[_destroyAddress] = _rOwned[_destroyAddress].add(curRAmount);
                
                emit Transfer(sender, _destroyAddress, curTAmount);
                
            }else{
                uint256 curTAmount = tAmount.div(1000).mul(rate);
                uint256 curRAmount = curTAmount.mul(currentRate);
                _rOwned[cur] = _rOwned[cur].add(curRAmount);
                emit Transfer(sender, cur, curTAmount);
            }
            
        }
    }

    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }

    function changeFHTotal(uint256 fhTotal) public onlyOwner {
        FHTotal = fhTotal;
    }

    
}