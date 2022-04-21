/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

pragma solidity ^0.8.7;

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


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
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
   
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    
}

contract AFT is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) public limitExcluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    // uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

      IUniswapV2Router02 public uniswapV2Router;
    // address public uniswapV2Pair;
    address public uniswapV2BNBPair;


    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);

    address private _destroy = address(0x000000000000000000000000000000000000dEaD);

    mapping(address => address) public inviter;
    mapping(address => uint256) public lastSellTime;

    address public swapV2Router;
    address public swapV2pairs;
    
    address public fund1Address = address(0x4EC3aC715dA69A66Acad28d4884da203E892B242);
    
    address public fund2Address = address(0x8d2988d868A0d5c0fE508fE11A5Fe7f8d1eBAD37);
    
    uint256 public _mintTotal;

    
    constructor(address tokenOwner) {
         if (block.chainid == 56) {
            uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        }
        // Create a pancake pair for this new token

        uniswapV2BNBPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH());
        swapV2pairs = uniswapV2BNBPair;
        limitExcluded[swapV2pairs] = true;
        limitExcluded[_destroyAddress] = true;

        _name = "AFTswap";
        _symbol = "AFT";
        _decimals = 18;

        _tTotal = 30000 * 10**_decimals;
        _mintTotal = 3000 * 10**_decimals;
        _rTotal = (MAX - (MAX % _tTotal));

        _rOwned[tokenOwner] = _rTotal;
        // setMintTotal(_mintTotal);
        //exclude owner and this contract from fee
        _isExcludedFromFee[tokenOwner] = true;
        _isExcludedFromFee[address(this)] = true;
         limitExcluded[tokenOwner] = true;
          limitExcluded[address(this)] = true;

        _owner = tokenOwner;
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
    
    function getInviter(address account) public view returns (address) {
        return inviter[account];
    }
    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }
    
    // function balancROf(address account) private view returns (uint256) {
    //     return _rOwned[account];
    // }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        // if(msg.sender == uniswapV2Pair){
             _transfer(msg.sender, recipient, amount);
        // }else{
        //     _tokenOlnyTransfer(msg.sender, recipient, amount);
        // }
       
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
        // if(recipient == uniswapV2Pair){
             _transfer(sender, recipient, amount);
        // }else{
        //      _tokenOlnyTransfer(sender, recipient, amount);
        // }
       
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

    // function totalFees() public view returns (uint256) {
    //     return _tFeeTotal;
    // }

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

    // function excludeFromFee(address account) public onlyOwner {
    //     _isExcludedFromFee[account] = true;
    // }

    // function includeInFee(address account) public onlyOwner {
    //     _isExcludedFromFee[account] = false;
    // }

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

    // function claimTokens() public onlyOwner {
    //     payable(_owner).transfer(address(this).balance);
    // }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    // function updateLimited(address account, bool enabled) public onlyOwner {
    //     limitExcluded[account] = enabled;
    // }


    function updateLimitedall(address[] memory _account, bool enabled) public  onlyOwner {
         for (uint i=0; i<_account.length; i++) {
            limitExcluded[_account[i]] = enabled;
         }
    }

    // function setInviter(address account, address paccount) public onlyOwner {
    //     inviter[account]=paccount;
    // }

    function setallInviter(address[] memory _a, address[] memory _pa) public onlyOwner {
        require(_a.length == _pa.length, "account neq paccount");
        for (uint i=0; i<_a.length; i++) {
            inviter[_a[i]] = _pa[i];
         }
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
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf(from) >= amount, "ERC20: transfer amount exceeds balance");
        if(_rOwned[to] == 0 && inviter[to] == address(0) && amount >= 1 * 10**15){
                    inviter[to] = from;
                }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        if(to==address(0) || to==_destroy || to==swapV2Router || from==swapV2Router){
            takeFee = false;
        }
        if(_mintTotal>=_tTotal){
            takeFee = false;
        }
        if(from==swapV2pairs){//buy
            if (limitExcluded[to]) {
                takeFee = false;
            }
        }else{
            if (limitExcluded[from]) {
            takeFee = false;
            }
        }
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 currentRate = _getRate();

        // 扣除发送人的
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount,"a");

        uint256 rate = 0;
        uint256 crate;
        if (takeFee) {
            rate = 6;
            // 销毁
            if(sender==swapV2pairs){//buy
            bool _isBuy = true;
            _takeInviterFee(sender, recipient, tAmount, currentRate,_isBuy);
            }else if(recipient==swapV2pairs){//sell
            bool _isBuy = false;
            _takeTransfer(
                    sender,
                    fund1Address,
                    tAmount.div(100).mul(1),
                    currentRate
                            );
                _takeTransfer(
                    sender,
                    fund2Address,
                    tAmount.div(100).mul(1),
                    currentRate
                );
                _takeInviterFee(sender, recipient, tAmount, currentRate,_isBuy);
            }else{
            // _takeTransfer(
            // sender,
            // _destroyAddress,
            // tAmount.div(100).mul(6),
            // currentRate
            // );
             if(balanceOf(_destroyAddress)<27000 * 10**18){            
             _rOwned[_destroyAddress] = _rOwned[_destroyAddress].add(rAmount.div(100).mul(6));
            emit Transfer(sender, _destroyAddress, tAmount.div(100).mul(6));
             }else{
                 rate = 0;
             }
            }
        }
        // 接收
        crate = 100 - rate;
         _takeTransfer(
            sender,
            recipient,
            tAmount.div(100).mul(crate),
            currentRate
            );
        // _rOwned[recipient] = _rOwned[recipient].add(
        //     rAmount.div(100).mul(94)
        // );
        // emit Transfer(sender, recipient, tAmount.div(100).mul(94));
    }
    

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        
         if(!limitExcluded[to] && balanceOf(to).add(tAmount) > 30 * 10**18){

            uint256 dAmount = balanceOf(to).add(tAmount).sub(30 * 10**18,"b");
            uint256 rdAmount = dAmount.mul(currentRate);
            _rOwned[_destroyAddress] = _rOwned[_destroyAddress].add(rdAmount);
            emit Transfer(sender, _destroyAddress, dAmount);
            
            tAmount = tAmount.sub(dAmount,"c");
        }
            uint256 rAmount = tAmount.mul(currentRate);
            _rOwned[to] = _rOwned[to].add(rAmount);
            emit Transfer(sender, to, tAmount);
    }

    // function _reflectFee(uint256 rFee, uint256 tFee) private {
    //     _rTotal = _rTotal.sub(rFee);
    //     _tFeeTotal = _tFeeTotal.add(tFee);
    // }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate,
        bool _isBuy
    ) private {
        address cur;
        if (_isBuy) {
            cur = recipient;
        } else {
            cur = sender;
        }
        
        for (int256 i = 1; i < 8; i++) {
            uint256 rate = 20;
            if(_isBuy){
                if(i==2 || i== 3){
                    rate = 10;
                }else if(i>3){
                    rate = 5;
                }
            }else{
                if(i==1){
                    rate = 10;
                }else if(i>1){
                    rate = 5;
                }
            }
            
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }
            // uint256 curTAmount = tAmount.div(100).mul(rate);
             _takeTransfer(
                    sender,
                    cur,
                    tAmount.div(1000).mul(rate),
                    currentRate
                );
            // uint256 curRAmount = curTAmount.mul(currentRate);
            // _rOwned[cur] = _rOwned[cur].add(curRAmount);
            // emit Transfer(sender, cur, curTAmount);
        }
    }

    function changeV2pairs(address router) public onlyOwner {
        swapV2pairs = router;
        limitExcluded[swapV2pairs] = true;
    }
 
}