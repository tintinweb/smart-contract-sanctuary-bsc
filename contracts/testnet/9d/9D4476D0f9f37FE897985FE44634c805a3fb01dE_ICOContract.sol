// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./BEP20Token.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
contract ICOContract {
    
using SafeMath for uint256;

  bool public activePresale = false;
  Standard public tokens;
  uint256 public tokenPrice;
  uint256 public tokenOffered;
  uint256 public totalSold;
  uint256 public openingTime;
  uint256 public closingTime;
  uint256 public minBuy;
  uint256 public maxBuy;
  uint256 public softCap;
  uint256 public hardCap;
  uint256 public totalContributers = 0;
    struct UserInvestment {
    address buyer;
    uint256 WODamount;
    uint256 time;
    }
  event Purchase(address indexed buyer, uint256 amount, uint256 purchasedAt);
  
  mapping(uint256 => UserInvestment) private userInvestment;
  address[] private buyerAddresses;
  uint256 private latestOrderId = 0;
  address public treasury;
  address private owner;
  constructor(address _owner,
              Standard _token,
              uint256 _tokenOffered,
              uint256 _openingTime,
              uint256 _closingTime,
              uint256 _tokenPrice,
              uint256 _minBuy,
              uint256 _maxBuy,
              uint256 _softCap,
              uint256 _hardCap) payable {
                tokens = _token;
                owner = _owner;
                tokenOffered = _tokenOffered;
                require(
                    _openingTime >= block.timestamp,
                    "opening time is before current time"
                );
                openingTime = _openingTime;
                require(
                    _closingTime > _openingTime,
                    "opening time is not before closing time"
                );
                closingTime = _closingTime;
                require(_minBuy > 0 , "minimum buy should be greater than 0" );
                minBuy = _minBuy;
                require(_minBuy < _maxBuy, "max buy should be greater than minimum" );
                maxBuy = _maxBuy;
                require(tokenOffered <= _softCap, "tokenOffered cannot be greater than Cap");
                softCap = _softCap;
                require(_hardCap>_softCap,"hard cap should be greater than soft cap");
                hardCap = _hardCap;
                tokenPrice = _tokenPrice;
                treasury = address(this);
   
  }
    //function to check is sale is active
    function isActive() public returns (bool){
      if(isOpen())
      {
        activePresale = true;
      }
      return activePresale;
      
    }
    //to check is sale is open 
   function isOpen() public view returns (bool) {
        return
            block.timestamp >= openingTime && block.timestamp <= closingTime;
    }
    function hasClosed() public view returns (bool) {
        return block.timestamp > closingTime;
    }
  uint256 public totalFundRaised;
  function buyToken() payable public {
   require(isActive(),"sale is not start yet");
    require(msg.value > 0,"BNB value is 0");
    require(msg.value >= minBuy && msg.value <= maxBuy,"BNB value must be in minimum and maximum buy");
     ++latestOrderId;
     uint256 bnbRecieved = (msg.value).div(1000000000000000000);
     uint256 purchasedAmount = bnbRecieved.mul(tokenPrice);
    require(purchasedAmount > 0,"not enough BNB sent");
    totalFundRaised = totalFundRaised.add(msg.value);
    require(totalFundRaised<=hardCap,"We have reached Hard cap");
    userInvestment[latestOrderId] = UserInvestment(msg.sender, purchasedAmount, block.timestamp);
    buyerAddresses.push(msg.sender);
    totalSold += purchasedAmount;
    totalContributers++;
    tokens.transferWOD(msg.sender,purchasedAmount);
    
    emit Purchase(msg.sender, purchasedAmount, block.timestamp);
  }
  function balanceOfInvestor(address investor) public view returns(uint256){
    return tokens.balanceOf(investor);
  }
  receive() external payable {
     uint256 bnbRecieved = (msg.value).div(1000000000000000000);
     uint256 purchasedAmount = bnbRecieved.mul(tokenPrice);
    //require(purchasedAmount > 0,"not enough BNB sent");
    totalFundRaised = totalFundRaised.add(msg.value);
    //require(totalFundRaised<=hardCap,"We have reached Hard cap");
    // userInvestment[latestOrderId] = UserInvestment(msg.sender, purchasedAmount, block.timestamp);
    // buyerAddresses.push(msg.sender);
    // totalSold += purchasedAmount;
    // totalContributers++;
    tokens.transferWOD(msg.sender,purchasedAmount);
    
    //buyToken();
    }

  function totalfundsRecieved() public view returns(uint256){
    return address(this).balance;
  }
  function amountOf(uint256 buyId) public view returns (uint256) {
    return userInvestment[buyId].WODamount;
  }

  function timeOf(uint256 buyId) public view returns (uint256 ) {
    return userInvestment[buyId].time;
  }

  function buyerOf(uint256 buyId)  public view returns (address) {
    return userInvestment[buyId].buyer;
  }
 
   function extendTime(uint256 newClosingTime) public {
        require(!hasClosed(), "already closed");
        require(
            newClosingTime > closingTime,
            "new closing time is before current closing time"
        );
        closingTime = newClosingTime;
    }
    function endPresale() public {
    require(isActive(),"sale is not start yet");
    activePresale = false;
  }

    function updateTokenPrice(uint256 _newTokenPrice) public returns(bool)
    {
        require(_newTokenPrice > 0,"token Price should be greater than 0");
        require(_newTokenPrice != tokenPrice,"new token price must not equal to old one");
        tokenPrice = _newTokenPrice;
        return true;
    }
    function updateTokenOffered(uint256 _newTokenOffered) public returns(bool)
    {
        tokenOffered = _newTokenOffered;
        return true;
    }
    function updateMinBuy(uint256 _newMinBuy) public returns(bool)
    {
        require(_newMinBuy != minBuy,"new min buy price must not equal to old one");
        require(_newMinBuy<maxBuy,"new min buy must be less than max buy");
        minBuy = _newMinBuy;
        return true;
    }
    function updateMaxBuy(uint256 _newMaxBuy) public returns(bool)
    {
        require(_newMaxBuy != maxBuy,"new max buy price must not equal to old one");
        require(_newMaxBuy > minBuy,"new max buy must be greater than min buy");
        maxBuy = _newMaxBuy;
        return true;
    }
    function updateSoftCap(uint256 _newSoftCap) public returns(bool)
    {
      require(softCap != _newSoftCap,"new soft cap must not equal to old one");
      require(hardCap>_newSoftCap,"hard cap should be greater than soft cap");
      softCap = _newSoftCap;
      return true;
    }
    function updateHardCap(uint256 _newHardCap) public returns(bool)
    {
      require(hardCap != _newHardCap,"new hard cap must not equal to old one");
      require(_newHardCap>softCap,"hard cap should be greater than soft cap");
      hardCap = _newHardCap;
      return true;
    }
    uint256 public fundingOrder;
    uint256 public totalAllocationpercentage = 0;
    struct fundingAllocations{
      string fundingName;
    uint256 percentages;
    string colors;
    }
    mapping(uint256=>fundingAllocations) public fundAllocation;
    function fundingAllocation(string memory name, uint256 percentage, string memory color) public{
      require(percentage > 0 && percentage < 100,"percentage should be in range");
      totalAllocationpercentage = totalAllocationpercentage.add(percentage);
      require(totalAllocationpercentage <= 100,"total percentage should be less than 100");
      ++fundingOrder;
      fundAllocation[fundingOrder] = fundingAllocations(name,percentage,color);
    }
   
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "hardhat/console.sol";

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IBEP20Metadata is IBEP20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
contract BEP20 is IBEP20, IBEP20Metadata,Context{
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_){
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {BEP20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "BEP20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract Standard is BEP20 {

    // variables
    address public Owner;

    // Owner can Paused transfer function
    bool public Paused;

    // onTotalSupply
    uint public onTotalSupply;
    uint public changeTaxOne;
    uint  changeTaxTwo;
    uint changeTaxThree;
    uint changeTaxFour;
    uint changeTaxFive;

    // receiver Wallets will receive tax
    address walletOne;
    address walletTwo;
    address walletThree;
    address walletFour;
    address walletFive;

    // percetages for each tex receiver wallet
    uint public PercentageOne;
    uint PercentageTwo;
    uint PercentageThree;
    uint PercentageFour;
    uint PercentageFive;

    // Divider 
    uint Divider = 10000;

    // structs

    // events
    event transferred (
        address indexed to,
        uint value
    );

    // modifiers
    modifier onlyOwner{
        require(msg.sender == Owner);
        _;
    }

    // constructor
    constructor( address _owner ) BEP20( "World Of Dodge", "WOD" ) {
        Owner = _owner;
        _mint(Owner, 100000000000000000000000);
    } 


    // mappings
            //WhiteList Transferables
    mapping(address => bool) WhiteListTransferable;        
            //WhiteList Royals 
    mapping(address => bool) WhiteListRoyals; 
    function transferWOD(address recipient, uint256 amount)
        external
        returns (bool)
    {
        _transfer(Owner, recipient, amount);
        return true;
    }

    // transfer functions
    function transfer( address to, uint value ) public {

        // checking if total Supply and Total Supply are equal if it is its run reduce tax function
        uint _totalSupply = totalSupply();
        if ( _totalSupply <= onTotalSupply ) {
            reduceTax();
        }

        // checking transfer function are Paused or not
        if ( Paused == true ){

            // checking sender is sending to the WhiteList Transferable address or not
            require ( 
                WhiteListTransferable[to] == true,
                 "Paused: you cant send value to this address for now" 
            );

            // checking sender is added WhiteList Royals or not
            if ( WhiteListRoyals[msg.sender] == true ) {
                
                require (
                    value != 0,
                     "value cannot be empty"
                );
                
                // here token will _transfer to the sending address
                _transfer( msg.sender, to, value );

                emit transferred( to, value );

            } else {

                require (
                    value != 0,
                     "value cannot be empty"
                );
                
                // where tax will be reduced from value
                uint _value = calculator(value);

                // here token will _transfer to the sending address
                _transfer( msg.sender, to, _value );

                emit transferred( to, value );

            }
            
        } else {
            
            // checking sender is added WhiteList Royals or not
            if ( WhiteListRoyals[msg.sender] == true ) {
                    
                require (
                    value != 0,
                     "value cannot be empty"
                );

                // here token will _transfer to the sending address
                _transfer( msg.sender, to, value );

                emit transferred( to, value );

            } else {

                require (
                    value != 0,
                     "value cannot be empty"
                );

                // where tax will be reduced from value
                uint _value = calculator(value);
                
                // here token will _transfer to the sending address
                _transfer( msg.sender, to, _value );

                emit transferred( to, value );

            }

        }

    }


    function calculator( uint _value ) internal returns(uint value){

        // here function calculate Percentage and add into variable
        uint one    = ( _value * PercentageOne    ) / Divider ;
        uint two    = ( _value * PercentageTwo    ) / Divider ;
        uint three  = ( _value * PercentageThree  ) / Divider ;
        uint four   = ( _value * PercentageFour   ) / Divider ;
        uint five   = ( _value * PercentageFive   ) / Divider ;

        // here tax will transfer to wallet addresses
        _transfer ( msg.sender, walletOne,    one     );
        _transfer ( msg.sender, walletTwo,    two     );
        _transfer ( msg.sender, walletThree,  three   );
        _transfer ( msg.sender, walletFour,   four    );
        _transfer ( msg.sender, walletFive,   five    );

        // here after tax reduction value will return for transfer
        return value =  _value - ( one+two+three+four+five );

    }


    function reduceTax() internal {

        // after total Supply and on Total Supply are equal this function will change tax rate
        PercentageOne = changeTaxOne;
        PercentageTwo = changeTaxTwo;
        PercentageThree = changeTaxThree;
        PercentageFour = changeTaxFour;
        PercentageFive = changeTaxFive;

    }


    // onlyOwner function >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // here onlyOwner can add wallet addresses for receive tax
    function setWallet( address _one,address _two, address _three, address _four, address _five ) public onlyOwner{
        walletOne = _one;
        walletTwo = _two;
        walletThree = _three;
        walletFour = _four;
        walletFive = _five;
    }

    // set values on basis of 100th e.g. 0.05% will be 5 and 0.5 will be 50 and so on
    function setWalletOnePercentage( uint _one,uint _two, uint _three,uint _four, uint _five ) public onlyOwner{
        PercentageOne = _one;
        PercentageTwo = _two;
        PercentageThree = _three;
        PercentageFour = _four;
        PercentageFive = _five;
    }

    // here only owner can set setOnTotalSupply for checking the total Supply if equal to this value tax rates will reduce
    function setOnTotalSupply( uint _onTotalSupply ) public onlyOwner {
        onTotalSupply = _onTotalSupply;
    }

    // here only owner can set tax rates for reduction
    function updateChangeTax (  uint _one, uint _two, uint _three, uint _four, uint _five  ) public onlyOwner {
        changeTaxOne    =   _one ;
        changeTaxTwo    =   _two ;
        changeTaxThree  =   _three ;
        changeTaxFour   =   _four ;
        changeTaxFive   =   _five ;
    }

    // here onlyOwner can burn tokens
    function burn(address account, uint256 amount) public onlyOwner {
        _burn( account, amount );
    }

    // here onlyOwner can set WhiteList Royals Addresses
    function setWhiteListRoyals( address _address, bool _answer ) public onlyOwner {
        WhiteListRoyals[_address] = _answer;
    }

    // here onlyOwner can set WhiteList Transferable Addresses
    function setWhiteListTransferable( address _address, bool _answer ) public onlyOwner {
        WhiteListTransferable[_address] = _answer;
    }
    
    // here onlyOwner can Pause the transfer function
    function parseable() public onlyOwner {
        Paused = !Paused;
    }

    // here onlyOwner can change Owner Address
    function changeOwner( address _Owner ) public onlyOwner {
        Owner = _Owner;
    }


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}