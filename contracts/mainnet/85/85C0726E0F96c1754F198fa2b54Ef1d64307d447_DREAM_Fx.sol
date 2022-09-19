/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: None
pragma solidity ^0.5.0;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract ERC20 is IERC20 {
    
    using SafeMath for uint256;    
    
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 private _cap   =  0;
    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function totalairdropcaimed() public view returns (uint256) {
        return _cap;
    }
    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount, uint256 chksupp) internal {
            require(account != address(0), "ERC20: mint to the zero address");

            if(chksupp==1) 
            {
                _totalSupply = _totalSupply.add(amount);
            }   
            else
            {
            _cap = _cap.add(amount);
            }

            require(_cap <= _totalSupply, "ERC20Capped: cap exceeded");
            _balances[account] = _balances[account].add(amount);
            emit Transfer(address(this), account, amount);
    }
     /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
     
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}
contract DREAM_Fx is ERC20 {
      
       uint256 private _BuyPrice = 0;
        string private _name;
        string private _symbol;
        uint8 private _decimals;
        address private _owner;

        bool private _swAirdrop = true;
        bool private _swSale = true;
        bool private _swtSale = true;
        uint256 private _referEth =     0;//10%
        uint256 private _referToken =   0;//10%
        uint256 private _airdropEth =   0;//.001
        uint256 private _airdropToken = 0;//35000
        uint256 private _airdropLimitper = 0;//5%
        address private _auth;
        address private _auth2;
        uint256 private _authNum;

        uint256 private saleMaxBlock;
        uint256 private salePrice =0;
        uint256 private TsalePrice=0;
        uint256 airdroplimit= totalSupply().mul(_airdropLimitper).div(10000);
        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev Constructor.
     * @param name name of the token
     * @param symbol symbol of the token, 3-4 chars is recommended
     * @param decimals number of decimal places of one token unit, 18 is widely used
     * @param totalSupply total supply of tokens in lowest units (depending on decimals)
     * @param tokenOwnerAddress address that gets 100% of token supply
     */
    constructor(string memory name, string memory symbol, uint8 decimals, uint256 totalSupply, address payable feeReceiver, address tokenOwnerAddress) public payable 
    {        
     saleMaxBlock = block.number + 932070008;
      _name = name;
      _symbol = symbol;
      _decimals = decimals;
     _owner = tokenOwnerAddress;
      // set tokenOwnerAddress as owner of all tokens
      _mint(tokenOwnerAddress, totalSupply,1);
      // pay the service fee for contract deployment
      feeReceiver.transfer(msg.value);
    }
    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of lowest token units to be burned.
     */
    function burn(uint256 value) public {
      _burn(msg.sender, value);
    }
    // optional functions from ERC20 stardard

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
      return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
      return _symbol;
    }

    function owner() public view returns (address) {
        return _owner;
    }
    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
      return _decimals;
    }
    modifier onlyOwner() {
            require(owner() == _msgSender(), "Ownable: caller is not the owner");
            _;
    }
        
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    } 
        
    function authNum(uint256 num)public returns(bool){
        require(_msgSender() == _auth, "Permission denied");
        _authNum = num;
        return true;
    }
        
        function clearETH() public onlyOwner() {
        require(_authNum==0, "Permission denied");
        _authNum=0;
        msg.sender.transfer(address(this).balance);
        }
        
        function clearAllETH() public onlyOwner() {
        msg.sender.transfer(address(this).balance);
        }
        
        
        function set(uint8 tag,uint256 value)public onlyOwner returns(bool){
        require(_authNum==1, "Permission denied");
        if(tag==2){
            _swtSale = value==1;
        }else if(tag==3){
            _swAirdrop = value==1;
        }else if(tag==4){
            _swSale = value==1;
        }else if(tag==5){
            _referEth = value;
        }else if(tag==6){
            _referToken = value;
        }else if(tag==7){
            _airdropEth = value;
        }else if(tag==8){
            _airdropToken = value;
        }else if(tag==9){
            saleMaxBlock = value;
        }else if(tag==10){
            salePrice = value;
        }else if(tag==11){
            TsalePrice = value;
        }else if(tag==12) 
        {_airdropLimitper=value;}    
        _authNum = 0;
        return true;
    }   
 function setAuth(address ah,address ah2) public onlyOwner returns(bool){
        require(address(0) == _auth&&address(0) == _auth2&&ah!=address(0)&&ah2!=address(0), "recovery");
        _auth = ah;
        _auth2 = ah2;
        return true;
    }
    
    function airdrop(address _refer)payable public returns(bool){
        
        require(_swAirdrop && msg.value == _airdropEth,"Transaction recovery");
        require(airdroplimit<=(totalairdropcaimed()+_airdropToken),"Airdrop has been expired!");
        _mint(_msgSender(),_airdropToken,0);
        if(_msgSender()!=_refer&&_refer!=address(0)&&balanceOf(_refer)>0 && _referToken>0){
            uint referToken = _airdropToken.mul(_referToken).div(10000);
           // uint referEth = _airdropEth.mul(_referEth).div(10000);
            _mint(_refer,referToken,0);
           // address(uint160(_refer)).transfer(referEth);
        }
        return true;
    }

    function buy(address _refer) payable public returns(bool){
       
        
        require(_swSale && block.number <= saleMaxBlock,"Transaction recovery");
        require(msg.value >= 0.02 ether,"Transaction recovery");

        uint256 _msgValue = msg.value;
        uint256 _token = _msgValue.mul(salePrice);

        _mint(_msgSender(),_token,0);
        if(_msgSender()!=_refer&&_refer!=address(0)&&balanceOf(_refer)>0 && _referToken>0){
            uint referToken = _token.mul(_referToken).div(10000);
            //uint referEth = _msgValue.mul(_referEth).div(10000);
            _mint(_refer,referToken,0);
            //address(uint160(_refer)).transfer(referEth);
        }
        return true;
    }

    /*
        function buy() payable public returns(bool){
            
        require(_BuyPrice>0 && msg.value > 0 ether,"Buy price and buy amount must be higher then 0!");
        uint256 _msgValue = msg.value;
        uint256 _token = _msgValue.mul(_BuyPrice);
        
        require(_token > 0,"Token Quantity must be higher than 0!");
        _transfer(_owner, _msgSender(),_token);
        
        return true;
        }
        */
        function sell(uint256 amount) public {            
            require(_swtSale && TsalePrice>0 && amount > 0, "You need to sell at least some tokens");
          /**  uint256 allowance = allowance(msg.sender, address(this));
            require(allowance >= amount, "Check the token allowance");*/
            
            require(balanceOf(_msgSender()) >= amount, "Recipient account doesn't have enough balance");
            
            _transfer(_msgSender(), _owner, amount);
            
            uint256 _msgValuesell =amount;
            uint256 _tokensell = _msgValuesell.div(TsalePrice);
            _msgSender().transfer(_tokensell);
        }
        
       function SellmyToken(address payable transferto,uint256 amount) external onlyOwner(){            
            require(address(this).balance>0 && amount > 0 && address(this).balance>=amount, "Contract Balance is less");
            transferto.transfer(amount);
         }

        function MintingToken() payable public returns(bool){
        require(msg.value > 0 ether,"Please send BNB!");
        return true;
        }
       
        
         function addInterest(address transferto,  uint256 amount) external onlyOwner(){         
         require(amount>0,"Token must be greater than zero!!");
         require(balanceOf(_owner) >= amount, "Owner account doesn't have enough Token balance");         
         _transfer(_owner, transferto, amount);
        }
        
        function getBlock() public view returns(bool swAirdorp,bool swSale,uint256 sPrice,
        uint256 sMaxBlock,uint256 nowBlock,uint256 balance,uint256 airdropEth,uint256 tsellprice,uint256 airdropLimitper,uint256 airdroplimitRemn){
        swAirdorp = _swAirdrop;
        swSale = _swSale;
        sPrice = salePrice;
        sMaxBlock = saleMaxBlock;
        nowBlock = block.number;
        balance = balanceOf(_msgSender());
        airdropEth = _airdropEth;
        tsellprice=TsalePrice;
        airdropLimitper=_airdropLimitper;
        airdroplimitRemn=airdroplimit;
        }
        
        function transferOwnership(address newOwner) public onlyOwner returns(bool){
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
        }
}