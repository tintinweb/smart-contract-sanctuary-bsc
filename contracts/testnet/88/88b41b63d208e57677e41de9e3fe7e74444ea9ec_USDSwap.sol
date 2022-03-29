/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

pragma solidity ^0.5.10;




contract SafeMath {
  function safeMul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}

contract Token {
  /// @return total amount of tokens
  function totalSupply() public view returns (uint256 supply) {}

  /// @param _owner The address from which the balance will be retrieved
  /// @return The balance
  function balanceOf(address _owner) public view returns (uint256 balance) {}

  /// @notice send `_value` token to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint256 _value) public returns (bool success) {}

  /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
  /// @param _from The address of the sender
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transferFrom(address _from, address _to, uint256 _value) public  returns (bool success) {}

  /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @param _value The amount of wei to be approved for transfer
  /// @return Whether the approval was successful or not
  function approve(address _spender, uint256 _value) public returns (bool success) {}

  /// @param _owner The address of the account owning tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @return Amount of remaining tokens allowed to spent
  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {}

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  uint public decimals;
  string public name;
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

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
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}



contract USDSwap is SafeMath, Ownable {

    event EtherTransfer(address beneficiary, uint256 amount);
    mapping (address => uint) public daiposit;
    uint public totaldai = 0;
    uint public baseMultiplier = 40;
    uint fee = 970; // 3.0%
    uint constant decOffset = 1;
    address public feeReceiver;
    address public busdReceiver;
    Token public   usdContract;
    Token public tknContract;

    constructor (address _feeReceiver,
                 address _busdReceiver,
                 Token _USDContract,
                 Token _tokenContract) public{

        feeReceiver = _feeReceiver;
        busdReceiver = _busdReceiver;
        usdContract = Token(_USDContract);
        tknContract = Token(_tokenContract);    
    }

    function() external payable {}

    function withdrawEther(address payable beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }
    function withdrawTokens(Token tknAdd, address beneficiary) public onlyOwner {
        // require(Token(tknAdd).transfer(beneficiary, Token(tknAdd).balanceOf(this)));
        Token(tknAdd).transfer(beneficiary, Token(tknAdd).balanceOf(address(this)));
    }

    function setFeReceivers(address _feeReceiver, address _busdReceiver) public onlyOwner {
            feeReceiver = _feeReceiver;
            busdReceiver = _busdReceiver;
    }

    function setTokens(Token _tokenUSD, Token _tokenAdd) public onlyOwner{
        usdContract = Token(_tokenUSD);
        tknContract = Token(_tokenAdd);
    }

    function sharesFromDai(uint dai) public view returns (uint) {
        if (totaldai == 0) return dai; // Initialisation 
        uint amt_dai  =  usdContract.balanceOf(address(this));
        return safeMul(dai, totaldai) / amt_dai;
    }

    function usdcAmountFromShares(uint shares) public view returns (uint) {
        if (totaldai == 0) return shares / decOffset; // Initialisation - 1 Dai = 1 Shares
        uint amt_usdc = safeMul(tknContract.balanceOf(address(this)), decOffset);
        return (safeMul(shares, amt_usdc) / totaldai) / decOffset;
    }
    
    function usdcAmountFromDai(uint dai) public view returns (uint) {
        return usdcAmountFromShares(sharesFromDai(dai));
    }
    
    function deposit(uint dai) public onlyOwner {
        uint shares = sharesFromDai(dai);
        uint usdc = usdcAmountFromShares(shares);
        daiposit[msg.sender] = safeAdd(daiposit[msg.sender], shares);
        totaldai             = safeAdd(totaldai, shares);
        if ( !usdContract.transferFrom(msg.sender, address(this), dai)) revert();
        if (!tknContract.transferFrom(msg.sender, address(this), usdc)) revert();
    }
    
    function withdraw() public onlyOwner {
        uint dai  = safeMul(daiposit[msg.sender],  usdContract.balanceOf(address(this))) / totaldai;
        uint usdc = safeMul(daiposit[msg.sender], tknContract.balanceOf(address(this))) / totaldai;
        totaldai  = safeSub(totaldai, daiposit[msg.sender]);
        daiposit[msg.sender] = 0;
        if ( !usdContract.transfer(msg.sender, dai)) revert();
        if (!tknContract.transfer(msg.sender, usdc)) revert();
    }
    
    function calcSwapForToken(uint dai) public view returns (uint) {
        uint base     = safeMul(baseMultiplier, totaldai);
        uint amt_dai  =          usdContract.balanceOf(address(this));
        uint amt_usdc = safeMul(tknContract.balanceOf(address(this)), decOffset);
        uint usdc     = safeSub(safeAdd(amt_usdc, base), ( safeMul(safeAdd(base, amt_usdc), safeAdd(base, amt_dai)) / safeAdd(safeAdd(base, amt_dai), dai)));
        usdc = usdc / decOffset;
        // safeMul(usdc, fee) / 1000;
        return usdc;
    }
    
    function swapForToken(uint dai) public {
        uint usdc = calcSwapForToken(dai);
        require(usdc < tknContract.balanceOf(address(this)));
        if ( !usdContract.transferFrom(msg.sender, address(busdReceiver), safeMul(dai, fee) / 1000)) revert();//received 9.7 BUSD
        if ( !usdContract.transferFrom(msg.sender, address(feeReceiver), safeSub(dai, safeMul(dai, fee) / 1000))) revert();//received 0.3 BUSD
        if (!tknContract.transfer(msg.sender, dai)) revert();// received 10 TKN
    }
    
    function calcSwapForUsd(uint usdc) public view returns (uint) {
        uint base     = safeMul(baseMultiplier, totaldai);
        uint amt_dai  =          usdContract.balanceOf(address(this));
        uint amt_usdc = safeMul(tknContract.balanceOf(address(this)), decOffset);
        uint dai      = safeSub(safeAdd(amt_dai, base), ( safeMul(safeAdd(base, amt_usdc), safeAdd(base, amt_dai)) / safeAdd(safeAdd(base, amt_usdc), safeMul(usdc, decOffset))));
        return safeMul(dai, fee) / 1000;
    }
    
    function swapForUSD(uint usdc) public {
        uint dai = calcSwapForUsd(usdc);
        require(dai < usdContract.balanceOf(address(this)));
        if ( !tknContract.transferFrom(msg.sender, address(busdReceiver), safeMul(usdc, fee) / 1000)) revert();//received 9.7 TKN
        if ( !usdContract.transferFrom(msg.sender, address(feeReceiver), safeSub(dai, safeMul(usdc, fee) / 1000))) revert();//received 0.3 TKN
        if (!usdContract.transfer(msg.sender, usdc)) revert();// received 10 USD


    }
}