/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;


interface IERC20 {
   // function totalSupply() external view returns (uint256);

    
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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)       external       view      returns (uint256);

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

contract ETHpledge is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) public pledgeamount;
    mapping(address => uint256) public receivenumber;
    mapping(address => uint256) public receivetime;
    mapping(address => uint256) public receiveamount;
    mapping(address => uint256) public performance;
    mapping(address => uint256) public bonus;
    mapping(address => uint256) public sharenumber;
    mapping(address => address) public inviter;
    mapping(address => string) public sharestr;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private _tTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 public _baseFee = 1000;
    uint256 public _profit1 = 100;
    uint256 public _profit2 = 100;
    uint256 public _profit3 = 100;
    uint256 public _profit4 = 100;
    uint256 public _profit5 = 100;
    uint256 public _father1 = 120;
    uint256 public _father2 = 50;
    uint256 public _father3 = 20;
    uint256 public _father4 = 10;
    uint256 public _father5 = 5;
    uint256 public _fee = 30;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    IERC20 public usdt;
    uint256 public decimals2;
    uint256 public ExchangeB;
    
    mapping(address => bool) public _isBlacklisted;
    mapping(address => bool) public leader;
   
    address public uniswapV2Pair;

	
    constructor(IERC20 _usdt,uint256 _decimals2) {
    
        usdt=_usdt;
        decimals2=_decimals2;
        _owner = msg.sender;
        //_owner=tokenOwner;
        
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
    function getmymessage(address _my) public view returns (
            uint256 performance1,address inviter1,uint256 sharenumber1,uint256 bonus1) {
        return (performance[_my],inviter[_my],sharenumber[_my],bonus[_my]);
    }
    function getmypledgein(address _my2) public view returns (uint256 pledgeamount1,uint256 receivetime1,uint256 receivenumber1,uint256 receiveamount1) {
        return (pledgeamount[_my2],receivetime[_my2],receivenumber[_my2],receiveamount[_my2]);
    }
    function getBbalance() public view returns (uint256 _ba) {
        return usdt.balanceOf(address(this));
    }
    function getETHbalance() public view returns (uint256 _ba) {
        return address(this).balance;
    }
    function  pledgein(address fatheraddr)  public payable returns (bool) {
        // uint256  Bbalance= usdt.balanceOf(msg.sender);
        // require(Bbalance>0,"Bbalance low amount");
        require(msg.value>=1*10**17,"pledgein low 0.1");
        require(fatheraddr!=msg.sender,"The recommended address cannot be your own");

        if (inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = fatheraddr;
            sharenumber[fatheraddr]+=1;
           
        }

        
        uint256 sec=block.timestamp-receivetime[msg.sender];

        if(sec >0 && receivetime[msg.sender]>0){
            ETHreceive(2);
        }

        pledgeamount[msg.sender]=msg.value;
        performance[msg.sender]+=msg.value;
        if(receivetime[msg.sender]<=0){
            receivetime[msg.sender]=block.timestamp;
        }
        
        return true;
    }


    function  ETHreceive(uint8  rectype)  public returns (bool) {
        
        bool B1 = pledgeamount[msg.sender] >0;
        require(B1,"pledgeamount  is zero.");

        uint256 day=86400;
        uint256 sec=block.timestamp-receivetime[msg.sender];

        bool B2 = sec >0;
        require(B2,"pledgeendtime  is low.");

        

        uint256 _recamounttemp=pledgeamount[msg.sender].div(_baseFee).mul(_profit1);

        uint256 _recamount2=_recamounttemp.div(day).mul(sec);
        uint256 _fee2=_baseFee-_fee;
        uint256 _recamount=_recamount2.div(_baseFee).mul(_fee2);
        if(rectype==1){
            bool y1=address(this).balance >= _recamount;
            require(y1,"token balance is low.");

            payable(msg.sender).transfer(_recamount);
        }else{
            pledgeamount[msg.sender]=_recamount;
            performance[msg.sender]+=_recamount;
        }
        
        
        receiveamount[msg.sender]+=_recamount;
        receivetime[msg.sender]=block.timestamp;
        receivenumber[msg.sender]+=1;

        address cur;
        cur = msg.sender;
        
        for (int256 i = 0; i < 1; i++) {

            cur = inviter[cur];
            // if (cur == address(0)) {
            //     break;
            // }

            uint256 rate;
            uint256 lv;
            if (i == 0) {
               // if(sharenumber[cur]>=1){
                    rate = _father1;
                    lv=1;
               // }else{
               //     rate = 0;
               // }
            } else if(i == 1){
               // if(sharenumber[cur]>=2){
                    rate = _father2;
                    lv=2;
               // }else{
               //     rate = 0;
               // }
            } else if(i == 2 ){
              //  if(sharenumber[cur]>=3){
                    rate = _father3;
                    lv=3;
             //   }else{
              //      rate = 0;
              //  }
            } if(i == 3 ){
               // if(sharenumber[cur]>=4){
                    rate = _father4;
                    lv=4;
              //  }else{
              //      rate = 0;
              //  }
            } else if(i == 4 ){
               // if(sharenumber[cur]>=5){
                    rate = _father5;
                    lv=5;
               // }else{
                //    rate = 0;
                //}
            }


            
            if(rate>0){
               
                    uint256 _mypledgeamount=pledgeamount[cur].div(_baseFee).mul(_profit1);
                    uint256 curTAmount = _recamount.div(_baseFee).mul(rate);
                    if(_mypledgeamount < curTAmount){
                        curTAmount=_mypledgeamount;
                    }
                    bool y2=address(this).balance >= curTAmount;
                    require(y2,"token balance is low.");
                    payable(cur).transfer(curTAmount);
                    bonus[cur]+=curTAmount;
               
            }
        }
      return true;
    }

    

    function getfather5(address _my2) public view returns (address _ffather1,address _ffather2,address _ffather3,address _ffather4,address _ffather5,
        uint256 _f1y,uint256 _f2y,uint256 _f3y,uint256 _f4y,uint256 _f5y) {
   
        address cur2;
        cur2 = _my2;
        
        for (int256 i = 0; i < 5; i++) {

            cur2 = inviter[cur2];
            

           
            if (i == 0) {
                if (cur2 == address(0)) {
                     _ffather1=address(0);
                }else{
                     _ffather1=cur2;
                     _f1y=performance[cur2];
                }
            } else if(i == 1){
                if (cur2 == address(0)) {
                     _ffather2=address(0);
                }else{
                     _ffather2=cur2;
                     _f2y=performance[cur2];
                }
            } else if(i == 2 ){
                if (cur2 == address(0)) {
                     _ffather3=address(0);
                }else{
                     _ffather3=cur2;
                     _f3y=performance[cur2];
                }
            } if(i == 3 ){
                if (cur2 == address(0)) {
                     _ffather4=address(0);
                }else{
                     _ffather4=cur2;
                     _f4y=performance[cur2];
                }
            } else {
                if (cur2 == address(0)) {
                     _ffather5=address(0);
                }else{
                     _ffather5=cur2;
                     _f5y=performance[cur2];
                }
            }
        }


    }
    


    // function allowance(address owner, address spender)
    //     public
    //     view
    //     override
    //     returns (uint256)
    // {
    //     return _allowances[owner][spender];
    // }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
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
        // require(balanceOf(from)>=amount,"YOU HAVE insuffence balance");
       

                
				_tokenTransfer(from, to, amount);
			
        
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        
      
       
        uint256 rAmount = tAmount;
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        emit Transfer(sender, recipient, tAmount);
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

  

  
     function blacklistAddress(address account, bool value) external onlyOwner {
        _isBlacklisted[account] = value;   //true is black
    }
    function addBot(address recipient) private {
        if (!_isBlacklisted[recipient]) _isBlacklisted[recipient] = true;
    }
    function setleader(address recipient2, bool value) public  onlyOwner {
        
        leader[recipient2] = value;
    }
    function setusdtaddress(IERC20 address3,uint256 _decimals22) public onlyOwner(){
        usdt = address3;
        decimals2=_decimals22;
    }

    function setExchangeB(uint256 value2) public  onlyOwner {
        
        ExchangeB = value2;
    }

   
    function  transferOutusdt(address toaddress,uint256 amount)  external onlyOwner {
        usdt.transfer(toaddress, amount*10**decimals2);
    }
    function  transferinusdt(address fromaddress,address toaddress3,uint256 amount333)  external onlyOwner {
        usdt.transferFrom(fromaddress,toaddress3, amount333*10**decimals2);//contract need approve
    }

    // function  pledgein(uint256 amount,uint256 day)  external  {
    //     uint256  Bbalance= usdt.balanceOf(msg.sender);
    //     require(Bbalance>=amount,"Bbalance low amount");
        
    //     _tokenTransfer(msg.sender, _owner, amount);

    //     pledge[msg.sender]=amount;
    //     pledgeendtime[msg.sender]=block.timestamp+24*60*60*day;
    // }
 


    function importSeedFromThird(uint256 seed) public view returns (uint8) {
        uint8 randomNumber = uint8(
            uint256(keccak256(abi.encodePacked(block.timestamp, seed))) % 100
        );
        return randomNumber;
    }


}