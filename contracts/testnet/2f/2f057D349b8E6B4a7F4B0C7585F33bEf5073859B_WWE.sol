/**
 *Submitted for verification at BscScan.com on 2022-03-26
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
    mapping(address => uint256) private _rToken;
    
    mapping(address => uint256) private _numTokenList;
    mapping(address => uint256) private _numAirList;
    mapping(address => uint256) private _numWithdrawList;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => mapping(uint256 => uint256)) private _tokenListNum;
    mapping(address => mapping(uint256 => uint256)) private _tokenListTime;
    mapping(address => mapping(uint256 => uint256)) private _airListNum;
    mapping(address => mapping(uint256 => uint256)) private _airListTime;
    mapping(address => mapping(uint256 => uint256)) private _withdrawNum;
    mapping(address => mapping(uint256 => uint256)) private _withdrawTime;

    mapping(uint256 => uint256) private _dayTokenTotal;    
    bool public _canGetNFT;
    mapping(address => bool) private _isExcludedFromFee;

    uint256 private _tTotal;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    uint256 public _personFee = 40;
    uint256 public _linkFee = 20;
    uint256 public _linkFee1 = 70;
    uint256 public _linkFee2 = 30;
    uint256 public _teamFee = 25;
    uint256 public _teamFee1 = 25;
    uint256 public _teamFee2 = 35;
    uint256 public _teamFee3 = 40;
    uint256 public _bansFee = 15;
    uint256 public _banFee = 60;
    uint256 public _SbanFee = 40;   

    uint256 public _destroyFee = 3;
    uint256 public _marketFee = 2;
    uint256 public _lpFee = 3;

    uint256 public _minTranfer = 1;
    uint256 public _okTime = 0;

    address private _destroyAddress =
        address(0x000000000000000000000000000000000000dEaD);
    address public _swapAddress;
    address public _lpAddress;
    address public _withdrawAddress;

    mapping(address => address) public _inviter;
    mapping(address => address[]) private _junior; // 多个下级地址
    mapping(address => address[]) public _myDrectPush;
    mapping(address => uint256) public _myDrectPushNum;
        
    mapping(address => mapping(address => uint256)) public _isAirPost;
    mapping(address => bool) public _isBlacklisted;
    mapping(address => uint256) public _myWithdrawTotal;
    mapping(address => uint256) public _myMintTotal;
    mapping(address => uint256) public _myMintNow;
    mapping(address => uint256) public _myMintTurn;
    mapping(address => uint256) public _myNFTtotal;
    mapping(address => uint256) public _myLevel;

    mapping(address => mapping(uint256 => uint256)) public _myLevelNum;
    mapping(uint256 => uint256) public _levelNum;

    address[] public _addressList;
    address[] public _addrL;
    address[] public _addressW1;
    address[] public _addressW2;
    address[] public _addressW3;
    address[] public _addressW4;
    address[] public _addressW5;    
    mapping(address => uint256) public _myJuniorToken;//我的下级业绩
    mapping(address => uint256) public _myAreaToken;//我的小区业绩
    mapping(address => uint256) public _myAreaRank;//我的小区业绩排行
    mapping(uint256 => address) public _addressRank;//我的小区业绩排行
    mapping(uint256 => uint256) public _wAreaToken;//级别小区业绩

    address public _IPancakePair;
    address public _IPancakeRouter;

    uint256 public _mintTotal;
    uint256 public _swapTotal;
    uint256 public _marketTotal;
    uint256 public _tokenTotal;
    uint256 public _dayTokenMax;
    uint256 public _withdrawTotal;
    uint256 public _isMint;
    uint256 public _isDayMint;
    uint256 public _maxDayMint; 
    uint256 public _beNFTtotal;
    uint256 public _Enum;
    uint256 public _startTime;
    uint256 public _recTime;
    uint256 public _blockHeight;
    uint256 public _dayPower;
    uint256 public _lastRank;
    uint256 public _price; 

    mapping(address => uint256) public _usdtPool;
    mapping(address => uint256) public _nextCash;
    mapping(address => uint256) public _myPowerPct;
    mapping(address => uint256) public _myPowerAmount;
    mapping(address => uint256) public _mylevelAmount;
    mapping(address => uint256) public _myDayMint;
    mapping(address => uint256) public _myDayNFTMint;        

    event GetToken(address sender, address to, uint256 amount);
    event AirPost(address sender, address to, uint256 amount);
    event Withdrawn(address sender, address to, uint256 amount);
    event BecomeMyInviter(address sender, address to);
    
    constructor(address tokenOwner, address mintAddress, address swapAddress, address withdrawAddress) {
        _name = "WORLD WRESTLING ENTERTAINMENT";
        _symbol = "WWE";
        _decimals = 8;

        _tTotal = 3000000 * 10**_decimals;
        _mintTotal = 95000000 * 10**_decimals;
        _swapTotal = 2000000 * 10**_decimals;
        _totalSupply = 100000000 * 10**_decimals;

        _dayTokenMax = 10000;
        _maxDayMint = 95000 * 10**_decimals;
        _Enum = 10;
        _rOwned[swapAddress] = _swapTotal;
        _rOwned[address(this)] = _tTotal;

        //exclude owner and this contract from fee
        _isExcludedFromFee[tokenOwner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[swapAddress] = true;
        _isExcludedFromFee[withdrawAddress] = true;
        _canGetNFT = false;

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

    function balanceOfToken(address account) public view returns (uint256) {
        return _rToken[account];
    }

    function numTokenList(address account) public view returns (uint256) {
        return _numTokenList[account];
    }

    function numAirList(address account) public view returns (uint256) {
        return _numAirList[account];
    }

    function numWithdrawList(address account) public view returns (uint256) {
        return _numWithdrawList[account];
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

    function tokenListNum(address owner, uint256 num)
        public
        view
        returns (uint256)
    {
        return _tokenListNum[owner][num];
    }

    function tokenListTime(address owner, uint256 num)
        public
        view
        returns (uint256)
    {
        return _tokenListTime[owner][num];
    }

    function airListNum(address owner, uint256 num)
        public
        view
        returns (uint256)
    {
        return _airListNum[owner][num];
    }

    function airListTime(address owner, uint256 num)
        public
        view
        returns (uint256)
    {
        return _airListTime[owner][num];
    }

    function withdrawNum(address owner, uint256 num)
        public
        view
        returns (uint256)
    {
        return _withdrawNum[owner][num];
    }

    function withdrawTime(address owner, uint256 num)
        public
        view
        returns (uint256)
    {
        return _withdrawTime[owner][num];
    }

    function dayTokenTotal(uint256 time)
        public
        view
        returns (uint256)
    {
        return _dayTokenTotal[time];
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
        require(amount >= _minTranfer.div(10000), "Transfer amount must be greater than 0.0001");
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

        _rOwned[sender] = _rOwned[sender].sub(tAmount);
        if (takeFee) {
            if(recipient == _IPancakePair && sender != _IPancakePair && sender != _IPancakeRouter && _okTime < block.timestamp){
                
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

                _takeTransfer(
                    sender,
                    _destroyAddress,
                    tAmount.div(100).mul(_destroyFee)
                );

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
                uint256 rRate = 100 - _lpFee - _destroyFee - _marketFee;
                uint256 rAmount = tAmount.div(100).mul(rRate);
                _rOwned[recipient] = _rOwned[recipient].add(rAmount);
                if(_inviter[recipient] == address(0))_marketTotal += tAmount.div(100).mul(_marketFee);               
                emit Transfer(sender, recipient, rAmount);
            }
            else{
                _rOwned[recipient] = _rOwned[recipient].add(tAmount);
                emit Transfer(sender, recipient, tAmount);                
            }
        }
        else{
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
        }
        else{
            uint256 burnAmount = tAmount.div(100).mul(_destroyFee);
            uint256 rAmount = tAmount.sub(burnAmount);
            _takeTransfer(
                sender,
                _destroyAddress,
                burnAmount
            ); 
            _rOwned[sender] = _rOwned[sender].sub(tAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rAmount);            
        }
        emit Transfer(sender, recipient, tAmount);

    }

    function _countAreaRank(
        address account
    )private{ 
       if(_myDrectPush[account].length>0){
           uint256 total = 0;
           uint256 max = 0;
           uint256 num = 0;
           _addressRank[0] = address(0);
           for(uint256 i=0;i<_myDrectPush[account].length;i++){
               if(_rToken[_myDrectPush[account][i]]>0)num +=1;
               if(max < _myJuniorToken[_myDrectPush[account][i]]){
                   max = _myJuniorToken[_myDrectPush[account][i]];
                }
                total += _myJuniorToken[_myDrectPush[account][i]];              
           }
           _myAreaToken[account] = total - max; 
           _myDrectPushNum[account] = num;       
       } 
    }
    function _removeAddressList(
        address account
    )private {
        for(uint256 i=0;i<_addressList.length;i++){
            if(_addressList[i] == account){
                uint256 _lastKey = _addressList.length - 1;
                _addressList[i] = _addressList[_lastKey];
                _addressList.pop();
            }                               
        }        
    }    
    function _removeAddress(
        address account
    )private {
        if(_myLevel[account] == 1){
            for(uint256 i=0;i<_addressW1.length;i++){
                if(_addressW1[i] == account){
                    uint256 _lastKey = _addressW1.length - 1;
                    _addressW1[i] = _addressW1[_lastKey];
                    _addressW1.pop();                  
                }                             
            }             
        }
        if(_myLevel[account] == 2){
            for(uint256 i=0;i<_addressW2.length;i++){
                if(_addressW2[i] == account){
                    uint256 _lastKey = _addressW2.length - 1;
                    _addressW2[i] = _addressW2[_lastKey];
                    _addressW2.pop(); 
                }
            }                              
        }
        if(_myLevel[account] == 3){
            for(uint256 i=0;i<_addressW3.length;i++){
                if(_addressW3[i] == account){
                    uint256 _lastKey = _addressW3.length - 1;
                    _addressW3[i] = _addressW3[_lastKey];
                    _addressW3.pop();
                }
            }                           
        }
        if(_myLevel[account] == 4){
            for(uint256 i=0;i<_addressW4.length;i++){
                if(_addressW4[i] == account){
                    uint256 _lastKey = _addressW4.length - 1;
                    _addressW4[i] = _addressW4[_lastKey];
                    _addressW4.pop();
                }
            }            
        }
        if(_myLevel[account] == 5){
            for(uint256 i=0;i<_addressW5.length;i++){
                if(_addressW5[i] == account){
                    uint256 _lastKey = _addressW5.length - 1;
                    _addressW5[i] = _addressW5[_lastKey];
                    _addressW5.pop();
                }
            }               
        }
    }

    function _updateLevel(
        address inviter,
        uint256 level
    )private {
        _removeAddress(inviter); 
        _levelNum[_myLevel[inviter]] -= 1;
        _myLevelNum[_inviter[inviter]][_myLevel[inviter]] -=1;                                       
        _myLevel[inviter] =1;
        _levelNum[level] += 1;
        _myLevelNum[_inviter[inviter]][level] +=1;        
    }
    

    function _changeMyInviter(
        address inviter,
        uint256 tAmount
    )private { 
        _myJuniorToken[inviter] += tAmount;
        _levelNum[0] += 1;
        _myLevelNum[_inviter[inviter]][0] +=1;
        _countAreaRank(inviter);              

        if(_rToken[inviter] >= 50 && _myDrectPushNum[inviter]>=5 && _myAreaToken[inviter]>=1000 && _myLevel[inviter] != 1){
            _updateLevel(inviter, 1);
            _addressW1.push(inviter);
        }

        if(_rToken[inviter] >= 150 && _myDrectPushNum[inviter]>=5 && _myAreaToken[inviter]>=3000 && _myLevelNum[inviter][1]>=2 && _myLevel[inviter] != 2){
            _updateLevel(inviter, 2);
            _addressW2.push(inviter);         
        }

        if(_rToken[inviter] >= 300 && _myDrectPushNum[inviter]>=5 && _myAreaToken[inviter]>=6000 && _myLevelNum[inviter][2]>=2 && _myLevel[inviter] != 3){
            _updateLevel(inviter, 3);
            _addressW3.push(inviter);        
        }

        if(_rToken[inviter] >= 500 && _myDrectPushNum[inviter]>=5 && _myLevelNum[inviter][3]>=2 && _myLevel[inviter] != 4){
            _updateLevel(inviter, 4);
            _addressW4.push(inviter);           
        }

        if(_rToken[inviter] >= 800 && _myDrectPushNum[inviter]>=5 && _myLevelNum[inviter][4]>=2 && _myLevel[inviter] != 5){
            _updateLevel(inviter, 5);
            _addressW5.push(inviter);            
        }                               

        if(_inviter[inviter] != address(0)){
            _changeMyInviter(_inviter[inviter], tAmount);
        }
    }

    function _becomeMyInviter(
        address recipient       
    )private {
        require(_inviter[msg.sender] == address(0),"YOU HAVE ALREADY BE INVITED");

        if(_junior[recipient].length>0){
             for(uint256 i=0;i<_junior[recipient].length;i++){
                   if(_junior[recipient][i] == msg.sender)return;
             }
        }
       _inviter[msg.sender] = recipient;
       _junior[recipient].push(msg.sender);
       _updateJunior(recipient);
       _myDrectPush[recipient].push(msg.sender);
       emit BecomeMyInviter(msg.sender, recipient);
    }

    function _updateJunior(
        address recipient
    )private {
        if(_inviter[recipient] != address(0)){
            _junior[_inviter[recipient]].push(msg.sender);
            _updateJunior(_inviter[recipient]);            
        }
    }   

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _rOwned[to] = _rOwned[to].add(tAmount);
        emit Transfer(sender, to, tAmount);
    }

    function _countMyMint(address cur) private {
        _dayPower = _maxDayMint.mul(_Enum).div(100);
        _blockHeight = _dayPower.div(24);
        _myDayMint[cur] = 0;
        _myDayNFTMint[cur]=0;

        _myPowerPct[cur] = _rToken[cur].mul(1000).div(_tokenTotal);
        _myPowerAmount[cur] = _dayPower.mul(_myPowerPct[cur]).mul(_personFee).div(100000);
        _myDayMint[cur] = _myDayMint[cur].add(_myPowerAmount[cur]);
        _myDayNFTMint[cur] = _myDayNFTMint[cur].add(_myPowerAmount[cur]);
    }

    function _countIvinterMint(address cur) private {
        uint256 myIvinterAmount;
        uint256 myIvinterAmount2;
        uint256 pct;

        if(_myDrectPush[cur].length > 0){
            pct = _linkFee.mul(_linkFee1);
            myIvinterAmount = _dayPower.mul(_myPowerPct[cur]).mul(pct).div(10000);
            _myDayMint[cur] = _myDayMint[cur].add(myIvinterAmount);
            _myDayNFTMint[cur] = _myDayNFTMint[cur].add(myIvinterAmount);
        }
        if(_myDrectPush[cur].length > 0 && _junior[cur].length > _myDrectPush[cur].length){
            pct = _linkFee.mul(_linkFee2);
            myIvinterAmount2 = _dayPower.mul(_myPowerPct[cur]).mul(pct).div(10000);
            _myDayMint[cur] = _myDayMint[cur].add(myIvinterAmount2);
            _myDayNFTMint[cur] = _myDayNFTMint[cur].add(myIvinterAmount2); 
        }
    }

    function _countlevelMint(address cur) private {
        uint256 pct;

        if(_myLevel[cur]>0){
            if(_myLevel[cur] == 1){
                _countAreaToken(1);
                pct = _teamFee.mul(_teamFee1);
                _mylevelAmount[cur] = _myAreaToken[cur].div(_wAreaToken[1]).mul(_dayPower).mul(pct).div(10000);
            }
            if(_myLevel[cur] == 2){
                _countAreaToken(2);
                pct = _teamFee.mul(_teamFee2);
                _mylevelAmount[cur] = _myAreaToken[cur].div(_wAreaToken[2]).mul(_dayPower).mul(pct).div(10000);
            }
            if(_myLevel[cur] == 3){
                _countAreaToken(3);
                pct = _teamFee.mul(_teamFee3);
                _mylevelAmount[cur] = _myAreaToken[cur].div(_wAreaToken[3]).mul(_dayPower).mul(pct).div(10000);
            }
            if(_myLevel[cur] == 4){
                _countAreaToken(4);
                pct = _bansFee.mul(_banFee);
                _mylevelAmount[cur] = _myAreaToken[cur].div(_wAreaToken[4]).mul(_dayPower).mul(pct).div(10000);
            }
            if(_myLevel[cur] == 5){
                _countAreaToken(5);
                pct = _bansFee.mul(_SbanFee);
                _mylevelAmount[cur] = _myAreaToken[cur].div(_wAreaToken[5]).mul(_dayPower).mul(pct).div(10000);
            }
            _myDayMint[cur] = _myDayMint[cur].add(_mylevelAmount[cur]);
            _myDayNFTMint[cur] = _myDayNFTMint[cur].add(_mylevelAmount[cur]);          
        }                                                   
                 
        _myDayMint[cur] = _myDayMint[cur].mul(70).div(100);
        _myDayNFTMint[cur] = _myDayNFTMint[cur].mul(30).div(100);
    }

    function _upDateMint() private {
        for(uint256 i=0;i<_addressList.length;i++){
            _myMintNow[_addressList[i]] = _myMintNow[_addressList[i]].add(_myDayMint[_addressList[i]]);
            _myMintTurn[_addressList[i]] = _myMintTurn[_addressList[i]].add(_myDayMint[_addressList[i]]);
            _myMintTotal[_addressList[i]] = _myMintTotal[_addressList[i]].add(_myDayMint[_addressList[i]]);

            _isDayMint = _isDayMint.add(_myDayMint[_addressList[i]]); 
            _mintTotal = _mintTotal.sub(_myDayMint[_addressList[i]]); 
            _isMint = _isMint.add(_myDayMint[_addressList[i]]);
        }        

    }

    function _upDateNftMint() private {
        for(uint256 i=0;i<_addressList.length;i++){
            _myNFTtotal[_addressList[i]] = _myNFTtotal[_addressList[i]].add(_myDayNFTMint[_addressList[i]]);
            _beNFTtotal = _beNFTtotal.add(_myDayNFTMint[_addressList[i]]);

            _isDayMint = _isDayMint.add(_myDayNFTMint[_addressList[i]]);
            _mintTotal = _mintTotal.sub(_myDayNFTMint[_addressList[i]]);
            _isMint = _isMint.add(_myDayNFTMint[_addressList[i]]);                                   
             
        }       

    }     

    function _startMint(uint256 daytime, uint256 price) private {
        require(_mintTotal > _isMint, "ERC20: Out off Mining");        
        if(block.timestamp >= _recTime){
           _startTime =  block.timestamp;
           _recTime =  daytime;

           for(uint256 i=0;i<_addressList.length;i++){
              _countMyMint(_addressList[i]);
              _countIvinterMint(_addressList[i]);
              _countlevelMint(_addressList[i]);               
           }

           _upDateMint();
           _upDateNftMint();
           for(uint256 i=0;i<_addressList.length;i++){
               if(price > 0){
                   _getOutTurn(_addressList[i], price);   
               }  
           }
            _countEnum(daytime);
            if(_dayPower > _isDayMint)_destroyLess();
            _isDayMint = 0; 
            //测试注释掉，正式用要解开注释
            _recTime += 86400;                   
        }      
    }

    function _getOutTurn(address cur, uint256 price) private {
        _price = price;
        uint256 myTotalMint = _myDayMint[cur].add(_myDayNFTMint[cur]).div(100000000);
        uint256 usdtAdd = myTotalMint.mul(_price).div(100000000); 
        _usdtPool[cur] = _usdtPool[cur].add(usdtAdd);
        uint256 maxToken = _rToken[cur].mul(10).mul(4);
                    //出局
        if(maxToken <= _usdtPool[cur]){
            _nextCash[cur] = _rToken[cur].mul(10).div(2);
            _myMintTurn[cur] = 0;
            _rToken[cur] = 0;
            _usdtPool[cur] = 0;

            if(_levelNum[_myLevel[cur]]>1)_levelNum[_myLevel[cur]] -= 1;
            if(_myLevelNum[_inviter[cur]][_myLevel[cur]]>1)_myLevelNum[_inviter[cur]][_myLevel[cur]] -=1;                                   
            if(_myLevel[cur]>1)_removeAddress(cur);
            _myLevel[cur] =0;
            _myPowerPct[cur] = 0;
            _myPowerAmount[cur] = 0;
            _mylevelAmount[cur] = 0;
            _myDayMint[cur] = 0;
            _myDayNFTMint[cur] = 0;
            _removeAddressList(cur);                                                 
        }        
    }

    function _countAreaToken(
        uint256 level
    ) private {
        if(level == 1){
            for(uint256 i=0;i<_addressW1.length;i++){
                _wAreaToken[1] +=  _myAreaToken[_addressW1[i]];  
            } 
        }
        if(level == 2){
            for(uint256 i=0;i<_addressW2.length;i++){
                _wAreaToken[2] +=  _myAreaToken[_addressW1[i]];  
            } 
        }
        if(level == 3){
            for(uint256 i=0;i<_addressW3.length;i++){
                _wAreaToken[3] +=  _myAreaToken[_addressW1[i]];  
            } 
        }
        if(level == 4){
            for(uint256 i=0;i<_addressW4.length;i++){
                _wAreaToken[4] +=  _myAreaToken[_addressW1[i]];  
            } 
        }
        if(level == 5){
            for(uint256 i=0;i<_addressW5.length;i++){
                _wAreaToken[5] +=  _myAreaToken[_addressW1[i]];  
            } 
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

    function _getNFTfund(
        uint256 tAmount       
    ) private {
        require(tAmount > 0, "Amount must greater than zero");
        require(_myNFTtotal[msg.sender] >= tAmount, "ERC20: Out off Amount");
        require(_canGetNFT, "NOT OPEN");

        _myNFTtotal[msg.sender] = _myNFTtotal[msg.sender].sub(tAmount);
        _rOwned[msg.sender] = _rOwned[msg.sender].add(tAmount);
        _beNFTtotal -= tAmount;
        emit Transfer(address(this), msg.sender, tAmount);        
    }    

    function _getToken(
        address to,
        uint256 tAmount,
        uint256 daytime       
    ) private {
        require(tAmount >= 10, "Amount must greater than 10");
        require(_dayTokenMax >= _dayTokenTotal[daytime], "OUT OFF dayTokenMax");
        require(tAmount >= _nextCash[to], "be 50% last usdt");
        //_rToken[address(this)] = _rToken[address(this)].sub(tAmount);
        if(_rToken[to] == 0)_addressList.push(to);        
        _rToken[to] = _rToken[to].add(tAmount);
        _tokenTotal += tAmount;
        _dayTokenTotal[daytime] += tAmount;
        _numTokenList[to] += 1;
        _tokenListNum[to][_numTokenList[to]] = tAmount;
        _tokenListTime[to][_numTokenList[to]] = block.timestamp;

        _changeMyInviter(to, tAmount);
        //_countEnum(daytime);

        emit GetToken(address(this), to, tAmount);               
    } 

    function _airPost(
        address to,
        uint256 tAmount   
    ) private {
        require(tAmount >= _minTranfer.mul(10000), "Transfer amount must be greater than 0.0001");
        require(_isAirPost[msg.sender][to] == 0, "ALREADY AIRPOST TO THIS ADDRESS");
        require(msg.sender != to, "cannot airpost yourself");
        
        _rOwned[msg.sender] = _rOwned[msg.sender].sub(tAmount);
        uint256 burn = tAmount.mul(3).div(100);
        tAmount = tAmount.sub(burn);
        _takeTransfer(msg.sender, to, tAmount);
        _takeTransfer(msg.sender, _destroyAddress, burn);  

        _isAirPost[msg.sender][to] = 1;
        _numAirList[to] += 1;
        _airListNum[to][_numAirList[to]] = tAmount;
        _airListTime[to][_numAirList[to]] = block.timestamp;

        emit AirPost(address(this), to, tAmount);               
    }

    function _withdrawn(
        address to,
        uint256 tAmount   
    ) private {
        require(tAmount >= 0, "withdraw amount must be greater than 0");
        require(_myMintNow[to]>=tAmount, "must be greater");

        _myMintNow[to] -= tAmount;
         
        _numWithdrawList[to] += 1;
        _withdrawNum[to][_numWithdrawList[to]] = tAmount;
        _withdrawTime[to][_numWithdrawList[to]] = block.timestamp;

        _rOwned[to] = _rOwned[to].add(tAmount.mul(94).div(100));
        emit Transfer(address(this), to, tAmount.mul(94).div(100));

        _rOwned[_withdrawAddress] = _rOwned[_withdrawAddress].add(tAmount.mul(3).div(100));
        emit Transfer(address(this), _withdrawAddress, tAmount.mul(3).div(100));

        if(_addressW5.length > 0){
            for(uint256 i=1;i<=_addressW5.length;i++){
                uint256 superFee = tAmount.mul(3).div(100*_addressW5.length);
                _rOwned[_addressW5[i]] = _rOwned[_addressW5[i]].add(superFee);
                emit Transfer(address(this), _addressW5[i], superFee);
            }            

        }
        else{
            _rOwned[_withdrawAddress] = _rOwned[_withdrawAddress].add(tAmount.mul(3).div(100));
            emit Transfer(address(this), _withdrawAddress, tAmount.mul(3).div(100));
        }            
        emit Withdrawn(address(this), to, tAmount);               
    }

    function _countEnum(
        uint256 daytime
    ) private {
        uint256 total = _tokenTotal.sub(_dayTokenTotal[daytime]);
        uint256 addPct = _dayTokenTotal[daytime].div(total>0?total:1).mul(10);
        uint256 nowEnum = _Enum.add(addPct);
        if(nowEnum <= 100){
            _Enum =  _tokenTotal>0?nowEnum:10; 
        }
        else{
           _Enum =  100; 
        }            
    }

    function _destroyLess() private {
        uint256 less = _dayPower.sub(_isDayMint);
        if(less > 0){
            _isMint = _isMint.add(less);
            _mintTotal = _mintTotal.sub(less);
            _rOwned[_destroyAddress] = _rOwned[_destroyAddress].add(less);                         
        }       
        _isDayMint = 0;
        emit Transfer(address(this), _destroyAddress, less);
            
    }   
               
    function getToken(address to, uint256 tAmount, uint256 daytime) external onlyMiner returns (bool) {
        _getToken(to, tAmount, daytime);
       return true;               
    }

    function airPost(address to, uint256 tAmount) public returns (bool) {
        _airPost(to, tAmount);
       return true;               
    }      

    function withdrawn(address to, uint256 tAmount) public returns (bool) {
       _withdrawn(to, tAmount);
       return true;
    }

    function startMint(uint256 daytime, uint256 price) external onlyMiner returns (bool) {
       _startMint(daytime, price);
       return true;
    }    

    function getMarketFund(address to, uint256 tAmount) public onlyMiner returns (bool) {
       _getMarketFund(to, tAmount);
       return true;
    } 

    function getNFTfund(uint256 tAmount) public returns (bool) {
       _getNFTfund(tAmount);
       return true;
    }              

    function changePair(address pair) public onlyOwner {
        _IPancakePair = pair;
    }

    function changeLevel(address account,uint256 level) external onlyOwner {
        _myLevel[account] = level;
    }       

    function changeDayTokenMax(uint256 amount) external onlyOwner {
        _dayTokenMax = amount;
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

    function changeRecTime(uint256 value) external onlyOwner {
        _recTime = value;
    }    

    function changeFee(uint256 destroyFee, uint256 marketFee, uint256 lpFee) external onlyOwner {
        _destroyFee = destroyFee;
        marketFee = marketFee;
        _lpFee = lpFee;
    }

    function changeMaxDayMint(uint256 value) external onlyOwner {
        _maxDayMint = value;
    }

    function changeOkTime(uint256 value) external onlyOwner {
        _okTime = value;
    }    

    function changeEnum(uint256 value) external onlyOwner {
        _Enum = value;
    }

    function changeNftStatus(bool value) public onlyOwner {
        _canGetNFT = value;
    }    

    function addressAmount() public view returns (uint256) {
        return _addressList.length;
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

    function changeFees(uint256 personFee, uint256 linkFee, uint256 linkFee1,uint256 linkFee2, uint256 teamFee, uint256 teamFee1,uint256 teamFee2, uint256 teamFee3, uint256 bansFee, uint256 banFee, uint256 SbanFee) external onlyOwner {
        _personFee = personFee;
        _linkFee = linkFee;
        _linkFee1 = linkFee1;
        _linkFee2 = linkFee2;
        _teamFee = teamFee;
        _teamFee1 = teamFee1;
        _teamFee2 = teamFee2;
        _teamFee3 = teamFee3;
        _bansFee = bansFee;
        _banFee = banFee;
        _SbanFee = SbanFee;        
    }     
}