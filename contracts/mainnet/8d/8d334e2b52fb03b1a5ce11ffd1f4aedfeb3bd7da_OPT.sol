/**
 *Submitted for verification at BscScan.com on 2022-04-06
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

contract OPT is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    // uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint256 private _decimals;


    // uint256 public _liquidityFee = 3;
    address public lpaddress = address(0xc36805AbFd610Aa789C6DC4bfF1457fAeE1E5a2A);
    

    // uint256 public _destroyFee = 1;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);

    address private _destroy = address(0x000000000000000000000000000000000000dEaD);

    // uint256 public _inviterFee = 6;

    mapping(address => address) public inviter;
    mapping(address => uint256) public lastSellTime;

    address public swapV2Router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public swapV2OPT;
    
    address public fund1Address = address(0x5a9BD8e6f2333a8b5115F3395B2e41327569cc4C);
    
    address public fund2Address = address(0xb8b310d92A2718254673d821d7f39B911D6A97f2);
    
    // uint256 public _fund1Fee = 2;
    
    // uint256 public _fund2Fee = 1;
    
    uint256 public _mintTotal;

    
    constructor(address tokenOwner) {
        _name = "Ocs1";
        _symbol = "O1";
        _decimals = 18;

        _tTotal = 21000 * 10**_decimals;
        _mintTotal = 210 * 10**_decimals;
        _rTotal = (MAX - (MAX % _tTotal));

        _rOwned[tokenOwner] = _rTotal;
        setMintTotal(_mintTotal);
        //exclude owner and this contract from fee
        _isExcludedFromFee[tokenOwner] = true;
        _isExcludedFromFee[address(this)] = true;

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

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
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

    // function claimTokens() public onlyOwner {
    //     payable(_owner).transfer(address(this).balance);
    // }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
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

        if(_rOwned[to] == 0 && inviter[to] == address(0)){
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
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }
    function isBuy(address sender, address recipient)
        internal 
        view 
        returns (bool)
    {
        recipient;
        if (sender == swapV2OPT) {
            return true;
        } else {
            return false;
        }
    }

    function isSell(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        sender;
         if (recipient == swapV2OPT) {
            return true;
        } else {
            return false;
        }
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

        uint256 rate = 0;
        bool _isBuy = isBuy(sender, recipient);
        bool _isSell = isSell(sender, recipient);
        bool _noburn = false;
        if (takeFee) {

            if ( totalSupply().sub(balanceOf(_destroyAddress)).sub(balanceOf(address(0))) <= 2100 * 10**_decimals) {
                _noburn = true;
            }

            if(!_isBuy && !_isSell && !_noburn){//转账：4%黑洞
                rate = 4;
                _takeTransfer(
                    sender,
                    _destroyAddress,
                    tAmount.div(100).mul(4),
                    currentRate
                            );
            }else if(_isSell){//卖：2%黑洞+2%回流到基金会地址
                rate = 2;
                if(!_noburn){
                _takeTransfer(
                    sender,
                    _destroyAddress,
                    tAmount.div(100).mul(2),
                    currentRate
                            );
                rate = 4;
                }
                _takeTransfer(
                    sender,
                    fund1Address,
                    tAmount.div(100).mul(2),
                    currentRate
                            );
            }else{// 买：2%LP分红地址+2%回流到基金会地址+2%进入指定的营销钱包地址+6%用于团队7代奖励
                rate = 12;
                _takeTransfer(
                    sender,
                    lpaddress,
                    tAmount.div(100).mul(2),
                    currentRate
                );
                _takeTransfer(
                    sender,
                    fund1Address,
                    tAmount.div(100).mul(2),
                    currentRate
                            );
                _takeTransfer(
                    sender,
                    fund2Address,
                    tAmount.div(100).mul(2),
                    currentRate
                );
                _takeInviterFee(sender, recipient, tAmount, currentRate);
            }

      
        }

        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
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



    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        address cur = recipient;

        for (int256 i = 1; i < 8; i++) {
            uint256 rate = 10;
            if(i == 1 || i == 3 || i == 5 || i == 7){
             rate = 5;
            }else if(i == 4 || i == 6){
             rate = 15;
            }

            
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }
            if(balanceOf(cur) >= 1 * 10**_decimals){
            uint256 curTAmount = tAmount.div(1000).mul(rate);
            uint256 curRAmount = curTAmount.mul(currentRate);
            _rOwned[cur] = _rOwned[cur].add(curRAmount);
            emit Transfer(sender, cur, curTAmount);
            }
        }
    }

    function changeV2OPT(address router) public onlyOwner {
        swapV2OPT = router;
    }

     function changeRouter(address router) public onlyOwner {
        swapV2Router = router;
    }
    
    function setMintTotal(uint256 mintTotal) private {
        _mintTotal = mintTotal;
    }
}