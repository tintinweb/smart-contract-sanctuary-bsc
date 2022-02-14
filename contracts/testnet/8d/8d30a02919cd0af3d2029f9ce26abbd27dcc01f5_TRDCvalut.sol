/**
 *Submitted for verification at BscScan.com on 2022-02-14
*/

// SPDX-License-Identifier: MIT


// TGB Rewarding System

pragma solidity ^0.8.10;



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface iBEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface iBEP20Metadata is iBEP20 {
   
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract BEP20 is iBEP20, iBEP20Metadata {
    mapping(address => mapping(address => uint256)) private _allowances;
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint256  private cardPower;
    uint private number=4;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

    }
    function _mint(address account, uint256 amount, uint256 _cardPower) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_totalSupply <= 11, "Playing Cards total reached");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _cardPower = cardPower;
    }
    function getPower() internal virtual{
        cardPower = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
        if (cardPower == 0){
            cardPower = 1;
        }
    }
    
}


contract TRDCvalut is BEP20 {
    address private _owner;

    event BuyCard(address nftOwner, uint256 NFTpower);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event WithdrawalBNB(uint256 _amount, address to);
    event WithdrawalToken(address _tokenAddr, uint256 _amount, address to);

    BEP20 public currency;// = 0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47; //0x7e8DB69dcff9209E486a100e611B0af300c3374e; TRDC
    address public currencyAd = 0x64544969ed7EBf5f083679233325356EbE738930;
    address public dEaD= 0x000000000000000000000000000000000000dEaD;
    uint256 public paymentAmount = 1;
    uint256 fractions = 10** 18;
    uint256 public cardPrice = 1;
    uint256 cardPower;
    uint number = 4;
    uint constant MAX_UINT = 2**256 - 1;
    
    //address public bank1 = 0x7e8DB69dcff9209E486a100e611B0af300c3374e;

  mapping(address => bool) public whitelist;
  //mapping(address => mapping(address => uint256)) public _allowances;

  /**
   * @dev Reverts if beneficiary is not whitelisted. Can be used when extending this contract.
   */
  modifier isWhitelisted(address _beneficiary) {
    require(whitelist[_beneficiary]);
    _;
  }
    

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () BEP20("TRDCGame", "TG") payable{
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
        currency = BEP20(0x64544969ed7EBf5f083679233325356EbE738930);
    }
    
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }


    function setCurrency (address Cryptocurrency, uint decimal) external onlyOwner {
        currency = BEP20(Cryptocurrency);
        currencyAd = Cryptocurrency;
        fractions = 10** decimal;
    }

    

  /**
   * @dev Adds single address to whitelist.
   * @param _beneficiary Address to be added to the whitelist
   */
  function addToWhitelist(address _beneficiary) external onlyOwner {
      require(whitelist[_beneficiary] != true, "Address already exist");
    whitelist[_beneficiary] = true;
  }
  function addToWhitelistInternal(address _beneficiary) internal {
      require(whitelist[_beneficiary] != true, "Address already exist");
    whitelist[_beneficiary] = true;
  }

  /**
   * @param _beneficiaries Addresses to be added to the whitelist
   */
  function addManyToWhitelist(  address[]memory _beneficiaries) external onlyOwner {
    for (uint256 i = 0; i < _beneficiaries.length; i++) {
      whitelist[_beneficiaries[i]] = true;
    }
  }

  /**
   * @dev Removes single address from whitelist.
   * @param _beneficiary Address to be removed to the whitelist
   */
  function removeFromWhitelist(address _beneficiary) external onlyOwner {
    whitelist[_beneficiary] = false;
  }
  function removeFromWhitelistinternal(address _beneficiary) internal {
    whitelist[_beneficiary] = false;
  }

  function _getPower() internal {
        cardPower = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
        if (cardPower == 0){
            cardPower = 1;
        }
    }
    function changePrice(uint256 _cardPrice) external {
        cardPrice = _cardPrice;
    }
  function approvePlayer(BEP20 _Currency) external {
      _Currency.approve(address(this), MAX_UINT);
  }
  function externalbuy() external {
      currency.transferFrom(msg.sender, address(this), cardPrice);
  }
  function buyCard() external returns(uint256 CardPower) {
      //require(allowance(msg.sender, address(this)) >= cardPrice, "Check the token allowance");
      _getPower();
      //currency.approve(address(this), cardPrice);
      //emit BuyCard(msg.sender, 1);
      currency.transferFrom(msg.sender, address(this), cardPrice);//Trasfer from User to this contract TRDC token (price of game card)

      _mint(msg.sender, 1, cardPower); //Mint token card with power
      if (whitelist[msg.sender] != true){
          addToWhitelistInternal(msg.sender);
      }
      CardPower = cardPower;
      return(CardPower);
  }

  function receiveRewards () public {
      
      require(whitelist[msg.sender], "Sorry no Gifts for you now");
      uint256 _amount = paymentAmount;

      iBEP20(currency).transfer (msg.sender, _amount * fractions);
      super.transferFrom(msg.sender, dEaD, 1);

      if  (balanceOf(msg.sender) == 0){
          removeFromWhitelistinternal(msg.sender);
      }
      
      
  }

  function withdrawalToken(address _tokenAddr, uint256 _amount, address to) external onlyOwner() {
        iBEP20 token = iBEP20(_tokenAddr);
        emit WithdrawalToken(_tokenAddr, _amount, to);
        token.transfer(to, _amount);
    }
    
    function withdrawalBNB(uint256 _amount, address to) external onlyOwner() {
        require(address(this).balance >= _amount);
        emit WithdrawalBNB(_amount, to);
        payable(to).transfer(_amount);
    }

    receive() external payable {}
}

//Developed by: MetaIdentity