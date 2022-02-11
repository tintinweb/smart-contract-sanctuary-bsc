/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

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
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  function decimals() external view returns (uint8);

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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function sqrrt(uint256 a) internal pure returns (uint c) {
        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }

    function percentageAmount( uint256 total_, uint8 percentage_ ) internal pure returns ( uint256 percentAmount_ ) {
        return div( mul( total_, percentage_ ), 1000 );
    }

    function substractPercentage( uint256 total_, uint8 percentageToSub_ ) internal pure returns ( uint256 result_ ) {
        return sub( total_, div( mul( total_, percentageToSub_ ), 1000 ) );
    }

    function percentageOfTotal( uint256 part_, uint256 total_ ) internal pure returns ( uint256 percent_ ) {
        return div( mul(part_, 100) , total_ );
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }

    function quadraticPricing( uint256 payment_, uint256 multiplier_ ) internal pure returns (uint256) {
        return sqrrt( mul( multiplier_, payment_ ) );
    }

  function bondingCurve( uint256 supply_, uint256 multiplier_ ) internal pure returns (uint256) {
      return mul( multiplier_, supply_ );
  }
}

abstract contract ERC20 is IERC20 {

  using SafeMath for uint256;

  // TODO comment actual hash value.
  bytes32 constant private ERC20TOKEN_ERC1820_INTERFACE_ID = keccak256( "ERC20Token" );
    
  // Present in ERC777
  mapping (address => uint256) internal _balances;

  // Present in ERC777
  mapping (address => mapping (address => uint256)) internal _allowances;

  // Present in ERC777
  uint256 internal _totalSupply;

  // Present in ERC777
  string internal _name;
    
  // Present in ERC777
  string internal _symbol;
    
  // Present in ERC777
  uint8 internal _decimals;

  constructor (string memory name_, string memory symbol_, uint8 decimals_) {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
  }

  function name() public view returns (string memory) {
    return _name;
  }

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  function decimals() public view override returns (uint8) {
    return _decimals;
  }

  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view virtual override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
      require(sender != address(0), "ERC20: transfer from the zero address");
      require(recipient != address(0), "ERC20: transfer to the zero address");

      _beforeTokenTransfer(sender, recipient, amount);

      _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);
      emit Transfer(sender, recipient, amount);
    }

    function _mint(address account_, uint256 amount_) internal virtual {
        require(account_ != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address( this ), account_, amount_);
        _totalSupply = _totalSupply.add(amount_);
        _balances[account_] = _balances[account_].add(amount_);
        emit Transfer(address( this ), account_, amount_);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

  function _beforeTokenTransfer( address from_, address to_, uint256 amount_ ) internal virtual { }
}

library Counters {
    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

interface IERC2612Permit {

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);
}

abstract contract ERC20Permit is ERC20, IERC2612Permit {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    bytes32 public DOMAIN_SEPARATOR;

    constructor() {
        uint256 chainID;
        assembly {
            chainID := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name())),
                keccak256(bytes("1")), // Version
                chainID,
                address(this)
            )
        );
    }

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "Permit: expired deadline");

        bytes32 hashStruct =
            keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, _nonces[owner].current(), deadline));

        bytes32 _hash = keccak256(abi.encodePacked(uint16(0x1901), DOMAIN_SEPARATOR, hashStruct));

        address signer = ecrecover(_hash, v, r, s);
        require(signer != address(0) && signer == owner, "ZeroSwapPermit: Invalid signature");

        _nonces[owner].increment();
        _approve(owner, spender, amount);
    }

    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner].current();
    }
}

interface IOwnable {
  function owner() external view returns (address);

  function renounceOwnership() external;
  
  function transferOwnership( address newOwner_ ) external;
}

contract Ownable is IOwnable {
    
  address internal _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
    _owner = msg.sender;
    emit OwnershipTransferred( address(0), _owner );
  }

  function owner() public view override returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require( _owner == msg.sender, "Ownable: caller is not the owner" );
    _;
  }

  function renounceOwnership() public virtual override onlyOwner() {
    emit OwnershipTransferred( _owner, address(0) );
    _owner = address(0);
  }

  function transferOwnership( address newOwner_ ) public virtual override onlyOwner() {
    require( newOwner_ != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred( _owner, newOwner_ );
    _owner = newOwner_;
  }
}

contract MurkyFinance is ERC20Permit, Ownable {

    using SafeMath for uint256;

    uint8 private decimal_ = 9;

    uint256 public MaxLimitSupply = 6666666 * (10 ** decimal_); // 6,666,666
    uint256 public circulationSupply;

    address public treasuryWallet;
    address public buybackWallet;
    
    uint public buyBackFee = 50; // 50%
    uint public treasuryFee = 50; // 50%
    
    uint256 transferAmountThresold = 0; //1000 * 10 ** 18; // $1000
    
    address[] public reserveTokens; // Push only, beware false-positives.
    mapping(address => bool) public isReserveToken;
    
    uint256 latestUpdateTime;
    
    uint256 previousMintPrice;
    uint256 public floorPrice = 2 * 10 ** 18;
    
    uint256 priceUpdateTimeLimit = 8 * 3600; // 8 hour
    
    bool public buyBackNeed;

    event Mint(address token, uint256 amount);

    constructor(address _DAI, address _AVAI, address _treasuryWallet, address _buyBackWallet) ERC20("MurkyFinance", "MKY", decimal_) {
      isReserveToken[_DAI] = true;
      reserveTokens.push(_DAI);

      isReserveToken[_AVAI] = true;
      reserveTokens.push(_AVAI);

      treasuryWallet = _treasuryWallet;
      buybackWallet = _buyBackWallet;
    }

    // function valueOf(address _token, uint256 _amount) public view returns (uint256 value_) {
    //     if (isReserveToken[_token]) {
    //         // convert amount to match CST decimals
    //         value_ = _amount.mul(10 ** decimal_).div(10**IERC20(_token).decimals());
    //     } else {
    //         value_ = 0;
    //     }
    // }

    function amountOfReserveToken(address account) internal view returns (uint256) {
      uint256 amount = 0;
      for (uint8 i = 0; i < reserveTokens.length; i++) {
        if (isReserveToken[reserveTokens[i]]) {
          amount = amount + IERC20(reserveTokens[i]).balanceOf(account);
        }
      }
      return amount;
    }

    function getMintPrice() public view returns (uint256) {
      uint256 mintPrice;
      if (circulationSupply == 0) {
        mintPrice = floorPrice;
      } else {
        uint256 backingTreasury = amountOfReserveToken(address(buybackWallet)); // + amountOfReserveToken(address(this)).mul(buyBackFee).div(100);
        mintPrice = backingTreasury.div(circulationSupply / (10 ** decimal_)).mul(2);
      }

    //   if (mintPrice < previousMintPrice && latestUpdateTime + priceUpdateTimeLimit < block.timestamp) {
    //     buyBackNeed = true;
    //   }

    //   if (mintPrice != previousMintPrice) {
    //     previousMintPrice = mintPrice;
    //     latestUpdateTime = block.timestamp;
    //   }

      return mintPrice;
    }

    // function shouldBuyBack() public view returns (bool) {
    //   return buyBackNeed;
    // }

    // function sendReserveTokens() private {
    //   for (uint8 i = 0; i < reserveTokens.length; i++) {
    //     if (isReserveToken[reserveTokens[i]]) {
    //       uint256 amount = IERC20(reserveTokens[i]).balanceOf(address(this));
    //       uint256 treasuryFeeAmount = amount.mul(treasuryFee).div(100);
    //       uint256 buyBackFeeAmount = amount.mul(buyBackFee).div(100);
    //       IERC20(reserveTokens[i]).transfer(treasuryWallet, treasuryFeeAmount);
    //       IERC20(reserveTokens[i]).transfer(buybackWallet, buyBackFeeAmount);
    //     }
    //   }
    // }

    function getTreasuryValue() external view returns (uint256) {
        return amountOfReserveToken(treasuryWallet);
    }

    function getBuyBackValue() external view returns (uint256) {
        return amountOfReserveToken(buybackWallet);
    }

    function mintMKY(address _token, uint256 _amount) external {
      require(isReserveToken[_token], "Not accepted");
      require(_amount > 0, "Invalid amount");

      // IERC20(_token).transferFrom(msg.sender, address(this), _amount);
      // sendReserveTokens();

      // uint256 contractTokenBalance = amountOfReserveToken(address(this));
      // if(contractTokenBalance >= transferAmountThresold) {
      // }

      uint256 payOut = _amount.mul(10 ** decimal_).div(getMintPrice());
      if (circulationSupply + payOut > MaxLimitSupply) {
        payOut = MaxLimitSupply - circulationSupply;
        _amount = payOut.mul(getMintPrice()).div((10 ** decimal_));
      }

      IERC20(_token).transferFrom(msg.sender, treasuryWallet, _amount/2);
      IERC20(_token).transferFrom(msg.sender, buybackWallet, _amount/2);
      super._mint(address(msg.sender), payOut);
      circulationSupply = circulationSupply + payOut;

      emit Mint(msg.sender, payOut);
    }

    function setTreasuryWallet(address account) external onlyOwner() {
      require(account != address(0), "Invalid address");
      treasuryWallet = account;
    }

    function setBuybackWallet(address account) external onlyOwner() {
      require(account != address(0), "Invalid address");
      buybackWallet = account;
    }

    function setBuybackFee(uint percent) external onlyOwner() {
      require(percent >= 0, "BuybackFee should be bigger than 0");
      require(percent <= 100, "BuybackFee should be smaller than 100");
      buyBackFee = percent;
    }

    function setTreasuryFee(uint percent) external onlyOwner() {
      require(percent >= 0, "TreasuryFee should be bigger than 0");
      require(percent <= 100, "TreasuryFee should be smaller than 100");
      treasuryFee = percent;
    }

    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }
     
    function setReserveToken(address token) external onlyOwner() {
      require(token != address(0), "Token address should not be 0");
      if (isReserveToken[token] == true) {
        return;
      }

      reserveTokens.push(token);
      isReserveToken[token] = true;
    }

    // function burnFrom(address account_, uint256 amount_) public virtual {
    //     _burnFrom(account_, amount_);
    // }

    // function _burnFrom(address account_, uint256 amount_) public virtual {
    //     uint256 decreasedAllowance_ =
    //         allowance(account_, msg.sender).sub(
    //             amount_,
    //             "ERC20: burn amount exceeds allowance"
    //         );

    //     _approve(account_, msg.sender, decreasedAllowance_);
    //     _burn(account_, amount_);
    // }
}