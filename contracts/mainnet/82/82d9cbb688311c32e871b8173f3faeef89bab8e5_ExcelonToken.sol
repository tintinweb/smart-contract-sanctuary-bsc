/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

/*
 * ERC-20 Standard Token Smart Contract Interface modified for Excelon Network Bridges
 * Author: Giannis Zarifis <[email protected]>
 */
pragma solidity ^0.4.16;

/**
 * ERC-20 standard token interface, as defined
 * <a href="http://github.com/ethereum/EIPs/issues/20">here</a>.
 */
contract Token {
  /**
   * Get total number of tokens in circulation.
   *
   * @return total number of tokens in circulation
   */
  function totalSupply () constant returns (uint256 supply);

  /**
   * Get number of tokens currently belonging to given owner.
   *
   * @param _owner address to get number of tokens currently belonging to the
   *        owner of
   * @return number of tokens currently belonging to the owner of given address
   */
  function balanceOf (address _owner) constant returns (uint256 balance);

  /**
   * Transfer given number of tokens from message sender to given recipient.
   *
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer to the owner of given address
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transfer (address _to, uint256 _value) returns (bool success);

  /**
   * Transfer given number of tokens from given owner to given recipient.
   *
   * @param _from address to transfer tokens from the owner of
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer from given owner to given
   *        recipient
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transferFrom (address _from, address _to, uint256 _value)
  returns (bool success);

  /**
   * Allow given spender to transfer given number of tokens from message sender.
   *
   * @param _spender address to allow the owner of to transfer tokens from
   *        message sender
   * @param _value number of tokens to allow to transfer
   * @return true if token transfer was successfully approved, false otherwise
   */
  function approve (address _spender, uint256 _value) returns (bool success);

  /**
   * Tell how many tokens given spender is currently allowed to transfer from
   * given owner.
   *
   * @param _owner address to get number of tokens allowed to be transferred
   *        from the owner of
   * @param _spender address to get number of tokens allowed to be transferred
   *        by the owner of
   * @return number of tokens given spender is currently allowed to transfer
   *         from given owner
   */
  function allowance (address _owner, address _spender) constant
  returns (uint256 remaining);

  /**
   * Logged when tokens were transferred from one owner to another.
   *
   * @param _from address of the owner, tokens were transferred from
   * @param _to address of the owner, tokens were transferred to
   * @param _value number of tokens transferred
   */
  event Transfer (address indexed _from, address indexed _to, uint256 _value);

  /**
   * Logged when owner approved his tokens to be transferred by some spender.
   *
   * @param _owner owner who approved his tokens to be transferred
   * @param _spender spender who were allowed to transfer the tokens belonging
   *        to the owner
   * @param _value number of tokens belonging to the owner, approved to be
   *        transferred by the spender
   */
  event Approval (
    address indexed _owner, address indexed _spender, uint256 _value);
}



/**
 * Provides methods to safely add, subtract and multiply uint256 numbers.
 */
contract SafeMath {
  uint256 constant private MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  /**
   * Add two uint256 values, throw in case of overflow.
   *
   * @param x first value to add
   * @param y second value to add
   * @return x + y
   */
  function safeAdd (uint256 x, uint256 y)
  constant internal
  returns (uint256 z) {
    assert (x <= MAX_UINT256 - y);
    return x + y;
  }

  /**
   * Subtract one uint256 value from another, throw in case of underflow.
   *
   * @param x value to subtract from
   * @param y value to subtract
   * @return x - y
   */
  function safeSub (uint256 x, uint256 y)
  constant internal
  returns (uint256 z) {
    assert (x >= y);
    return x - y;
  }

  /**
   * Multiply two uint256 values, throw in case of overflow.
   *
   * @param x first value to multiply
   * @param y second value to multiply
   * @return x * y
   */
  function safeMul (uint256 x, uint256 y)
  constant internal
  returns (uint256 z) {
    if (y == 0) return 0; // Prevent division by zero at the next line
    assert (x <= MAX_UINT256 / y);
    return x * y;
  }
}


/**
 * Abstract Token Smart Contract that could be used as a base contract for
 * ERC-20 token contracts.
 */
contract AbstractToken is Token, SafeMath {
  /**
   * Create new Abstract Token contract.
   */
  function AbstractToken () {
    // Do nothing
  }

  /**
   * Get number of tokens currently belonging to given owner.
   *
   * @param _owner address to get number of tokens currently belonging to the
   *        owner of
   * @return number of tokens currently belonging to the owner of given address
   */
  function balanceOf (address _owner) constant returns (uint256 balance) {
    return accounts [_owner];
  }

  /**
   * Transfer given number of tokens from message sender to given recipient.
   *
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer to the owner of given address
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transfer (address _to, uint256 _value) returns (bool success) {
    if (accounts [msg.sender] < _value) return false;
    if (_value > 0 && msg.sender != _to) {
      accounts [msg.sender] = safeSub (accounts [msg.sender], _value);
      accounts [_to] = safeAdd (accounts [_to], _value);
    }
    Transfer (msg.sender, _to, _value);
    return true;
  }

  /**
   * Transfer given number of tokens from given owner to given recipient.
   *
   * @param _from address to transfer tokens from the owner of
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer from given owner to given
   *        recipient
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transferFrom (address _from, address _to, uint256 _value)
  returns (bool success) {
    if (allowances [_from][msg.sender] < _value) return false;
    if (accounts [_from] < _value) return false;

    allowances [_from][msg.sender] =
      safeSub (allowances [_from][msg.sender], _value);

    if (_value > 0 && _from != _to) {
      accounts [_from] = safeSub (accounts [_from], _value);
      accounts [_to] = safeAdd (accounts [_to], _value);
    }
    Transfer (_from, _to, _value);
    return true;
  }

  /**
   * Allow given spender to transfer given number of tokens from message sender.
   *
   * @param _spender address to allow the owner of to transfer tokens from
   *        message sender
   * @param _value number of tokens to allow to transfer
   * @return true if token transfer was successfully approved, false otherwise
   */
  function approve (address _spender, uint256 _value) returns (bool success) {
    allowances [msg.sender][_spender] = _value;
    Approval (msg.sender, _spender, _value);

    return true;
  }

  /**
   * Tell how many tokens given spender is currently allowed to transfer from
   * given owner.
   *
   * @param _owner address to get number of tokens allowed to be transferred
   *        from the owner of
   * @param _spender address to get number of tokens allowed to be transferred
   *        by the owner of
   * @return number of tokens given spender is currently allowed to transfer
   *         from given owner
   */
  function allowance (address _owner, address _spender) constant
  returns (uint256 remaining) {
    return allowances [_owner][_spender];
  }

  /**
   * Mapping from addresses of token holders to the numbers of tokens belonging
   * to these token holders.
   */
  mapping (address => uint256) accounts;

  /**
   * Mapping from addresses of token holders to the mapping of addresses of
   * spenders to the allowances set by these token holders to these spenders.
   */
  mapping (address => mapping (address => uint256)) private allowances;
}


/**
 * Excelon token smart contract.
 */
contract ExcelonToken is AbstractToken {
  /**
   * Maximum allowed number of tokens in circulation.
   */
  uint256 constant MAX_TOKEN_COUNT =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  /**
   * Address of the owner of this smart contract.
   */
  address public owner;

  /**
   * Current number of tokens in circulation.
   */
  uint256 tokenCount = 0;

  /**
   * True if tokens transfers are currently frozen, false otherwise.
   */
  bool frozen = false;

  /**
   * Create new Excelon token smart contract and make msg.sender the
   * owner of this smart contract.
   */
  function ExcelonToken () {
    owner = msg.sender;
  }

  /**
   * Get total number of tokens in circulation.
   *
   * @return total number of tokens in circulation
   */
  function totalSupply () constant returns (uint256 supply) {
    return tokenCount;
  }

  /**
   * Get name of this token.
   *
   * @return name of this token
   */
  function name () constant returns (string result) {
    return "XLON";
  }

  /**
   * Get symbol of this token.
   *
   * @return symbol of this token
   */
  function symbol () constant returns (string result) {
    return "XLON";
  }

  /**
   * Get number of decimals for this token.
   *
   * @return number of decimals for this token
   */
  function decimals () constant returns (uint8 result) {
    return 18;
  }

  /**
   * Transfer given number of tokens from message sender to given recipient except if recipient is Bridge address. If it is calls burnBridgedTokens method instead.
   *
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer to the owner of given address
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transfer (address _to, uint256 _value) returns (bool success) {
    if (frozen) {
      return false;
    }
    else {
        if (isBridge(_to)) {
          return burnBridgedTokens(_to, _value);
        } else {
          return AbstractToken.transfer (_to, _value);
        }
    }
  }

  /**
   * Transfer given number of tokens from given owner to given recipient.
   *
   * @param _from address to transfer tokens from the owner of
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer from given owner to given
   *        recipient
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transferFrom (address _from, address _to, uint256 _value)
    returns (bool success) {
    if (frozen) return false;
    else return AbstractToken.transferFrom (_from, _to, _value);
  }

  /**
   * Change how many tokens given spender is allowed to transfer from message
   * spender.  In order to prevent double spending of allowance, this method
   * receives assumed current allowance value as an argument.  If actual
   * allowance differs from an assumed one, this method just returns false.
   *
   * @param _spender address to allow the owner of to transfer tokens from
   *        message sender
   * @param _currentValue assumed number of tokens currently allowed to be
   *        transferred
   * @param _newValue number of tokens to allow to transfer
   * @return true if token transfer was successfully approved, false otherwise
   */
  function approve (address _spender, uint256 _currentValue, uint256 _newValue)
    returns (bool success) {
    if (allowance (msg.sender, _spender) == _currentValue)
      return approve (_spender, _newValue);
    else return false;
  }

  /**
   * Burn given number of tokens belonging to message sender.
   *
   * @param _value number of tokens to burn
   * @return true on success, false on error
   */
  function burnTokens (uint256 _value) returns (bool success) {
    if (_value > accounts [msg.sender]) return false;
    else if (_value > 0) {
      accounts [msg.sender] = safeSub (accounts [msg.sender], _value);
      tokenCount = safeSub (tokenCount, _value);
      Token.Transfer(msg.sender, 0X0, _value);
      return true;
    } else return true;
  }

  /**
   * Create _value new tokens and give new created tokens to msg.sender.
   * May only be called by smart contract owner.
   *
   * @param _value number of tokens to create
   * @return true if tokens were created successfully, false otherwise
   */
  function createTokens (uint256 _value)
    returns (bool success) {
    require (msg.sender == owner);

    if (_value > 0) {
      if (_value > safeSub (MAX_TOKEN_COUNT, tokenCount)) return false;
      accounts [msg.sender] = safeAdd (accounts [msg.sender], _value);
      tokenCount = safeAdd (tokenCount, _value);
      Token.Transfer(0X0, msg.sender, _value);
    }

    return true;
  }

  /**
   * Create _value new tokens and transfer new created tokens to _to and _remainingRecipient.
   * May only be called by smart contract owner.
   *
   * @param _value number of tokens to create
   * @param _transferValue number ot tokens to tarnsfer to _to 
   * @param _to the address to receive the _transferValue tokens
   * @param _remainingRecipient the address to receive the remaining tokens (_value minus _transferValue) 
   * @return true if tokens were created successfully, false otherwise
   */
  function createBridgedTokens (uint256 _value, uint256 _transferValue, address _to, address _remainingRecipient) public
    returns (bool success) {
    require (msg.sender == owner);
    require (_value >= _transferValue);

    if (_value > 0 && _transferValue>0) {
      if (_value > safeSub (MAX_TOKEN_COUNT, tokenCount)) return false;

      accounts [msg.sender] = safeAdd (accounts [msg.sender], _value);
      tokenCount = safeAdd (tokenCount, _value);

      Token.Transfer(0X0, msg.sender, _value);

      transfer(_to,_transferValue);
      transfer(_remainingRecipient,safeSub(_value,_transferValue));
    }

    return true;
  }


  /**
   * Burn given number of tokens belonging to message sender and raise the event of BridgeRequest(Notify offchain that a user request tranfer tokens to another Network).
   *
   * @param _to the detination Blockchain network(Bridge address)
   * @param _value number of tokens to burn
   * @return true on success, false on error
   */
  function burnBridgedTokens (address _to, uint256 _value) internal returns (bool success) {
    require (isBridge(_to));
    if (_value > accounts [msg.sender]) return false;
    else if (_value > 0) {
      accounts [msg.sender] = safeSub (accounts [msg.sender], _value);
      tokenCount = safeSub (tokenCount, _value);
      Token.Transfer(msg.sender, 0X0, _value);
      BridgeRequest(_value, msg.sender, _to);
      return true;
    } else return true;
  }

  /**
   * Set new owner for the smart contract.
   * May only be called by smart contract owner.
   *
   * @param _newOwner address of new owner of the smart contract
   */
  function setOwner (address _newOwner) {
    require (msg.sender == owner);

    owner = _newOwner;
  }

  /**
   * Freeze token transfers.
   * May only be called by smart contract owner.
   */
  function freezeTransfers () {
    require (msg.sender == owner);

    if (!frozen) {
      frozen = true;
      Freeze ();
    }
  }

  /**
   * Unfreeze token transfers.
   * May only be called by smart contract owner.
   */
  function unfreezeTransfers () {
    require (msg.sender == owner);

    if (frozen) {
      frozen = false;
      Unfreeze ();
    }
  }

  /**
   * Logged when token transfers were frozen.
   */
  event Freeze ();

  /**
   * Logged when token transfers were unfrozen.
   */
  event Unfreeze ();



  mapping (address => bool) brigdes;

  /**
   * Check if an address is Bridge to Blockchain network.
   */
  function isBridge (address destination) public view returns (bool bridge) {
    return brigdes[destination];
  }


  /**
   * Adds an address as Bridge to another Blockchain network.
   * May only be called by smart contract owner.
   */
  function addBridge (address _bridge) {
    require (msg.sender == owner);
    brigdes[_bridge] = true;
  }

  /**
   * Removes an address from Bridges.
   * May only be called by smart contract owner.
   */
  function removeBridge (address _bridge) {
    require (msg.sender == owner);
    brigdes[_bridge] = false;
  }


  /**
   * Event for a transfer request to another Blockchain network.
   */
  event BridgeRequest (uint256 value, address sender, address bridgedAddress);
}