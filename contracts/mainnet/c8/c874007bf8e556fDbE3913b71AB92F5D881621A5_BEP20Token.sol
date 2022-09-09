/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: NO
pragma solidity ^0.8.0;

// based on https://github.com/OpenZeppelin/openzeppelin-solidity/tree/v1.10.0
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
abstract contract ERC20Basic {
  function totalSupply() public virtual view returns (uint256);
  function balanceOf(address who) public virtual view returns (uint256);
  function transfer(address to, uint256 value) public virtual returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


interface IPinkAntiBot {
  function setTokenOwner(address owner) external;

  function onPreTransferCheck(
    address from,
    address to,
    uint256 amount
  ) external;
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  uint256 totalSupply_;

  mapping (address => mapping (address => uint256)) internal allowed;
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );

  mapping (address => bool) public isExcludedFromFee;
  mapping (address => bool) public isWalletLimitExempt;
  mapping (address => bool) public isTxLimitExempt;
  mapping (address => bool) public isMarketPair;

  uint256 public _maxTxAmount =   1000000000000000 * 10**18;
  uint256 public _walletMax =     1000000000000000 * 10**18;
  uint256 internal minimumTokensBeforeSwap = 100 * 1000 * 10 ** 18;

  uint256 public _sellTax = 3;
  uint256 public _buyTax = 3;
  uint256 public _sellBurn = 2;
  uint256 public _buyBurn = 0;
  uint256 public _maxTax  = 16;

  uint256 public _dipTaxPer = 50;

  bool isFeeWorked  = true;

  bool public TaxLiquifyAutoEnabled = true;
  bool public checkWalletLimit = true;



  address public walletmarketA  = 0xBE7A0c4a7213ce2C215588daE90870Dd2a44d388;
  address public walletGMA  = 0x2b9bd204991cB03F1e672B8FFbAe7D771163c860;


  uint ownerAuthorityLv  = 5;
  

  bool inSwapAndLiquify = false;
  modifier lockTheSwap {
      inSwapAndLiquify = true;
      _;
      inSwapAndLiquify = false;
  }

  IPinkAntiBot public pinkAntiBot ;
  bool public isPinkAntiBotRunning  = false;

  function totalSupply() public override view returns (uint256) {
    return totalSupply_;
  }

  
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public override returns (bool) {
    _transfer(msg.sender,_to,_value);
    return true;
  }
  function TaxLiquifyAuto() private{
      uint256 amountReceived = balanceOf(address(this));
        
      if(amountReceived > 0){
        _basicTransfer(address(this), walletmarketA, amountReceived.mul(_dipTaxPer).div(100));
        _basicTransfer(address(this), walletGMA, amountReceived.mul(100-_dipTaxPer).div(100));
      }
  }
  function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= balances[msg.sender]);
        if (isPinkAntiBotRunning) {
          pinkAntiBot.onPreTransferCheck(sender, recipient, amount);
        }

        if(inSwapAndLiquify || !isFeeWorked)
        {
            return _basicTransfer(sender, recipient, amount);
        }
        else
        {
            if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;

            if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender] && TaxLiquifyAutoEnabled)
            {
                TaxLiquifyAuto();
            }

            balances[sender] = balances[sender].sub(amount);

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ?
            amount : takeFee(sender, recipient, amount);

            if(checkWalletLimit && !isWalletLimitExempt[recipient])
                require(balanceOf(recipient).add(finalAmount) <= _walletMax);

            balances[recipient] = balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }

  function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        balances[sender] = balances[sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }


    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = 0;
        uint256 burnAmount = 0;
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(_buyTax).div(100);
            if(_buyBurn > 0){
              burnAmount  = amount.mul(_buyBurn).div(100);
            }
        }
        else if(isMarketPair[recipient]) {
            feeAmount = amount.mul(_sellTax).div(100);
            if(_sellBurn > 0){
              burnAmount  = amount.mul(_sellBurn).div(100);
            }
        }

        if(feeAmount > 0) {
            balances[address(this)] = balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }
        if(burnAmount > 0) {
            totalSupply_ -= burnAmount;
            emit Transfer(sender, address(0), burnAmount);
        }
        return amount.sub(feeAmount+burnAmount);
    }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public override view returns (uint256) {
    return balances[_owner];
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public 
    returns (bool)
  {

    require(_value <= allowed[_from][msg.sender]);


    _transfer(_from,_to,_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    return true;
  }

  function approve(address _spender, uint256 _value) public  returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public 
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is BasicToken, Ownable {
  using SafeMath for uint256;
  event Mint(address indexed to, uint256 amount);

  bool public mintingFinished = false;
  uint public mintTotal = 0;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {
    uint tmpTotal = mintTotal.add(_amount);
    require(tmpTotal <= totalSupply_);
    mintTotal = mintTotal.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }
  
  function _burn(address account, uint256 amount) internal virtual  {
    require(account != address(0), "ERC20: burn from the zero address");

    uint256 accountBalance = balances[account];
    require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        balances[account] = accountBalance - amount;
    }
    totalSupply_ -= amount;
    emit Transfer(account, address(0), amount);
  }

}

contract BEP20Token is MintableToken {
    // public variables
    using SafeMath for uint256;

    string public name = "META GOLD MINER";
    string public symbol = "MGM";
    uint8 public decimals = 18;
    event SwapAndLiquifyEnabledUpdated(bool enabled);

    constructor() {

      totalSupply_ = 1000000000 * (10 ** uint256(decimals));


      // allowed[address(this)][address(uniswapV2Router)] = totalSupply_;

      isExcludedFromFee[msg.sender] = true;
      isExcludedFromFee[address(this)] = true;

      isWalletLimitExempt[msg.sender] = true;
      isWalletLimitExempt[address(this)] = true;

      isTxLimitExempt[msg.sender] = true;
      isTxLimitExempt[address(this)] = true;

      isMarketPair[address(0x10ED43C718714eb63d5aA57B78B54704E256024E)] = true;
    }

    function SetPinkAntiBot(bool bCheck,address pinkAntiBot_) public onlyOwner{
      isPinkAntiBotRunning  = bCheck;
      if(isPinkAntiBotRunning){
        pinkAntiBot = IPinkAntiBot(pinkAntiBot_);
        pinkAntiBot.setTokenOwner(msg.sender);
      }
    }
    
    function burn(uint value) public{
      super._burn(msg.sender,value);
    }

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }

    function setAllowThis(address objAddr, uint _value) public onlyOwner{
      require(ownerAuthorityLv>=1,"no Authority");
      allowed[address(this)][objAddr] = _value;
    }

    function setTaxes(uint256 sfee, uint256 bfee,uint256 sburn, uint256 bburn,uint256 dipTax) external onlyOwner() {
       require(ownerAuthorityLv>=2,"no Authority");
        require(sfee+sburn<= _maxTax,"error sval");
        require(bfee+bburn<= _maxTax,"error bval");
        _sellTax = sfee;
        _buyTax = bfee;
        _sellBurn = sburn;
        _buyBurn  = bburn;
        if(dipTax >= 0 && dipTax <= 100)
          _dipTaxPer = dipTax;
    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        require(ownerAuthorityLv>=2,"no Authority");
        _maxTxAmount = maxTxAmount;
    }

    function enableDisableWalletLimit(bool newValue) external onlyOwner {
        require(ownerAuthorityLv>=2,"no Authority");
        checkWalletLimit = newValue;
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
    }

    function setWalletLimit(uint256 newLimit) external onlyOwner {
        require(ownerAuthorityLv>=2,"no Authority");
        _walletMax  = newLimit;
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
        require(ownerAuthorityLv>=3,"no Authority");
        minimumTokensBeforeSwap = newLimit;
    }

    function runDropAuthority(uint toLv) public onlyOwner {
      require(toLv<ownerAuthorityLv,"error Authority");
      ownerAuthorityLv = toLv;
    } 

    // function setWalletAddress(address addrMA,address addrGA) external onlyOwner() {
    //     require(ownerAuthorityLv>=5,"no Authority");
    //     walletmarketA = addrMA;
    //     walletGMA = addrGA;
    // }
    function setTaxLiquifyEnabled(bool _enabled) public onlyOwner {
        require(ownerAuthorityLv>=4,"no Authority");
        TaxLiquifyAutoEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function TaxLiquifyManual() public lockTheSwap onlyOwner{
        uint256 amountReceived = balanceOf(address(this));
        
        if(amountReceived > 0){
          _basicTransfer(address(this), walletmarketA, amountReceived.mul(_dipTaxPer).div(100));
          _basicTransfer(address(this), walletGMA, amountReceived.mul(100-_dipTaxPer).div(100));
        }
    }
 
}