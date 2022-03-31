/**
 *Submitted for verification at BscScan.com on 2022-03-31
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
    address public _miner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

     function miner() public view returns (address) {
        return _miner;
    }   

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyMiner() {
        require(_miner == msg.sender, "Ownable: caller is not the miner");
        _;
    }    

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }

    function changeMiner(address newMiner) public onlyOwner {
        _miner = newMiner;
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

contract WWE is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(uint256 => uint256) private _dayTokenTotal;    
    mapping(address => bool) private _isExcludedFromFee;

    uint256 private _tTotal;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint256 private _decimals; 

    uint256 public _marketFee = 2;
    uint256 public _lpFee = 3;

    address private _destroyAddress =
        address(0x000000000000000000000000000000000000dEaD);
    address public _swapAddress;
    address public _lpAddress;
    address public _withdrawAddress;
    uint256 public _mintTotal;
    uint256 public _isMint;
    uint256 public _swapTotal;
    uint256 public _marketTotal;                
        
    mapping(address => bool) public _isBlacklisted;
    mapping(address => address) public _inviter;
    mapping(address => address[]) private _junior; // 多个下级地址 
    uint256 public _recTime;       

    address public _IPancakePair;
    address public _IPancakeRouter;    
    event BecomeMyInviter(address sender, address to);          
    
    constructor(address tokenOwner, address mintAddress, address swapAddress, address withdrawAddress) {
        _name = "WORLD WRESTLING ENTERTAINMENT";
        _symbol = "WWE";
        _decimals = 8;

        _tTotal = 3000000 * 10**_decimals;
        _mintTotal = 95000000 * 10**_decimals;
        _swapTotal = 2000000 * 10**_decimals;
        _totalSupply = 100000000 * 10**_decimals;

        _rOwned[swapAddress] = _swapTotal;
        _rOwned[address(this)] = _tTotal;

        //exclude owner and this contract from fee
        _isExcludedFromFee[tokenOwner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[swapAddress] = true;
        _isExcludedFromFee[withdrawAddress] = true;

        _owner = tokenOwner;
        _miner = mintAddress;
        _swapAddress = swapAddress;
        _withdrawAddress = withdrawAddress;
        emit Transfer(address(0), swapAddress, _swapTotal);
        emit Transfer(address(0), address(this), _tTotal);
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
    
    function balanceOf(address account) public view override returns (uint256) {
        return _rOwned[account];
    }
               

    function transfer(address recipient, uint256 amount)
        public
        override 
        returns (bool)
    {
        if(msg.sender != _IPancakePair && recipient != _IPancakePair){
            _tokenOlnyTransfer(msg.sender, recipient, amount);
        }else{
            _transfer(msg.sender, recipient, amount);
        }
       
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
        if(sender != _IPancakePair && recipient != _IPancakePair){
            _tokenOlnyTransfer(sender, recipient, amount);
        }else{
            _transfer(sender, recipient, amount);
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

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

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
        require(amount >= 0, "Transfer amount must be greater than 0");
        require(!_isBlacklisted[from], 'Blacklisted address');
        require(!_isBlacklisted[to], 'Blacklisted address'); 

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
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

        if (takeFee) {
            if(recipient == _IPancakePair && sender != _IPancakePair && sender != _IPancakeRouter){
                _rOwned[sender] = _rOwned[sender].sub(tAmount);                
                _takeTransfer(
                    sender,
                    _lpAddress,
                    tAmount.div(100).mul(_lpFee)
                );
               //give back sender
                _takeTransfer(
                    sender,
                    sender,
                    tAmount.div(100).mul(1)
                );                

                uint256 rRate = 100 - _lpFee - 1;
                uint256 rAmount = tAmount.div(100).mul(rRate);
                _rOwned[recipient] = _rOwned[recipient].add(rAmount);                
                emit Transfer(sender, recipient, rAmount);               
            }
            else if(recipient != _IPancakePair && sender == _IPancakePair && recipient != _IPancakeRouter){
                _rOwned[sender] = _rOwned[sender].sub(tAmount); 

                _takeTransfer(
                    sender,
                    _lpAddress,
                    tAmount.div(100).mul(_lpFee)
                ); 
                address inviterAddress = (_inviter[recipient] == address(0))?_withdrawAddress:_inviter[recipient];

                _takeTransfer(
                    sender,
                    inviterAddress,
                    tAmount.div(100).mul(_marketFee)
                );                
                uint256 rRate = 100 - _lpFee - _marketFee;
                uint256 rAmount = tAmount.div(100).mul(rRate);
                _rOwned[recipient] = _rOwned[recipient].add(rAmount);
                if(_inviter[recipient] == address(0))_marketTotal += tAmount.div(100).mul(_marketFee);               
                emit Transfer(sender, recipient, rAmount);
            }
            else{
                _rOwned[sender] = _rOwned[sender].sub(tAmount);                
                _rOwned[recipient] = _rOwned[recipient].add(tAmount);
                emit Transfer(sender, recipient, tAmount);                
            }
        }
        else{
            _rOwned[sender] = _rOwned[sender].sub(tAmount);            
            _rOwned[recipient] = _rOwned[recipient].add(tAmount);
            emit Transfer(sender, recipient, tAmount);
        }
    }
    
    //this method is responsible for taking all fee, if takeFee is false
    function _tokenOlnyTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        require(!_isBlacklisted[sender], 'Blacklisted address');
        require(!_isBlacklisted[recipient], 'Blacklisted address');

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            _rOwned[sender] = _rOwned[sender].sub(tAmount);
            _rOwned[recipient] = _rOwned[recipient].add(tAmount); 
            emit Transfer(sender, recipient, tAmount);                       
        }
        else{
            uint256 burnAmount = tAmount.div(100).mul(_lpFee);
            uint256 rAmount = tAmount.sub(burnAmount);
            _takeTransfer(
                sender,
                _lpAddress,
                burnAmount
            ); 
            _rOwned[sender] = _rOwned[sender].sub(tAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rAmount);
            emit Transfer(sender, recipient, rAmount);            
        }
    }

    function _becomeMyInviter(
        address recipient       
    )private {
        require(_inviter[msg.sender] == address(0),"YOU HAVE ALREADY BE INVITED");
        require(recipient != msg.sender,"YOU CANNOT INVITE YOURSELF");        
        if(_junior[recipient].length>0){
             for(uint256 i=0;i<_junior[recipient].length;i++){
                   if(_junior[recipient][i] == msg.sender)return;
             }
        }
        _inviter[msg.sender] = recipient;
        _junior[recipient].push(msg.sender);     
        emit BecomeMyInviter(msg.sender, recipient);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _rOwned[to] = _rOwned[to].add(tAmount);
        emit Transfer(sender, to, tAmount);
    }

    function _startMint(uint256 daytime, uint256 amount) private {
        require(_mintTotal > _isMint, "ERC20: Out off Mining");        
        if(block.timestamp >= _recTime){
            _recTime =  daytime;
            _isMint += amount;
            _mintTotal -= amount;
            _recTime += 86400;
            _rOwned[address(this)] = _rOwned[address(this)].sub(amount);
            _rOwned[_swapAddress] = _rOwned[_swapAddress].add(amount); 
            emit Transfer(address(this), _swapAddress, amount);                    
        }
    }

    function _getMarketFund(
        address to,
        uint256 tAmount       
    ) private {
        require(tAmount > 0, "Amount must greater than zero");
        _rOwned[address(this)] = _rOwned[address(this)].sub(tAmount);
        _rOwned[to] = _rOwned[to].add(tAmount);
        emit Transfer(address(this), to, tAmount);        
    }

    function startMint(uint256 daytime, uint256 amount) external onlyMiner returns (bool) {
       _startMint(daytime, amount);
       return true;
    }

    function getMarketFund(address to, uint256 tAmount) public onlyMiner returns (bool) {
       _getMarketFund(to, tAmount);
       return true;
    } 

    function changePair(address pair) public onlyOwner {
        _IPancakePair = pair;
    }

    function changeRouter(address router) public onlyOwner {
        _IPancakeRouter = router;
    } 

    function changeLpAddress(address account) public onlyOwner {
        _lpAddress = account;
    }        
    
    function becomeMyInviter(address recipient) public returns (bool) {
       _becomeMyInviter(recipient);
       return true;
    }

    function blacklistAddress(address account, bool value) external onlyOwner {
        _isBlacklisted[account] = value;
    }

    function changeFee(uint256 marketFee, uint256 lpFee) external onlyOwner {
        _marketFee = marketFee;
        _lpFee = lpFee;
    }
    function juniorAmount(address _address) public view returns (uint256) {
        return _junior[_address].length;
    }

    function juniorAddress(address _address) public view returns (address[] memory _addrs) {
        uint256 _length = _junior[_address].length;
        _addrs = new address[](_length);
        for(uint256 i = 0; i < _length; i++) {
            _addrs[i] = _junior[_address][i];
        }
    }    

}