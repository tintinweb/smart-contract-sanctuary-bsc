/**
 *Submitted for verification at BscScan.com on 2022-04-10
*/

// File: @openzeppelin/contracts/utils/Context.sol



pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol



pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol



pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
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
    constructor(string memory name_, string memory symbol_) {
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
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
        require(account != address(0), "ERC20: mint to the zero address");

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
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
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
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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

// File: sSlice.sol


  pragma solidity 0.8.10;


  contract slice is ERC20 {
      
      uint start;
      uint vTotalSupply;
      uint vSupply;
      address listAdmin;
      address signer; 
      uint wenBlock;
      uint maxGoodCount;
      uint mintingSpeed;
      uint goodPrice;
      address public marketing1;
      bool longTermReward1;
      uint fightMintBalance;
      uint fightMintSupply;
      address ff;

          function _a() private view {
            require ((whitelist[msg.sender]==true), "bl");
          }
          modifier onlyWhitelisted() {
            _a();
            _;
          }
          function _fc() private view {
            require ((whitelistFc[msg.sender]==true), "fc");
          }
          modifier onlyWhitelistedFc() {
            _fc();
            _;
          }
          

          function _admin() private view {
            require(msg.sender == listAdmin, "oa");
          }
          modifier onlyAdmin() {
            _admin();
            _;
          }

      constructor (string memory name, string memory symbol) ERC20(name, symbol) {
        start = block.timestamp;
        vTotalSupply = 3027456000 * 10 ** uint(decimals());
        fightMintSupply = 567648000 * 10 ** uint(decimals());
        listAdmin = msg.sender;
        signer = 0xD6AF7959290caeE9E8564EC80a33b92335d6232C;
        marketing1= 0xa16392cB56E13367578795db9f6459485571d2fA;
        wenBlock=2;
        maxGoodCount=1;
        mintingSpeed=3600;
        goodPrice=10000000000000000;
        longTermReward1=false;
      }

      struct Minters {
          uint goodCount;
          uint reported;
          uint lastMinted;
          string gpsLat;
          string gpsLon;
          string nickname;
          bool whitelisted;
          address addr;
      }
      Minters[] mintersDB;
      
      struct StakedContracts {
          address staker;
          address fightContract;
      }
      StakedContracts []  stakersList;

      mapping(address => Minters) minters;
      mapping(address => uint) index;
      mapping (address=>uint )  stakedContractsCounter;
      mapping (address=>uint )  stakedFightCounter;
      mapping (address => uint) vSliceBalances;
      mapping (address => uint) stakedVSlices;
      mapping (address => bool) whitelist;
      mapping (address => bool) whitelistFc;
      mapping (address => mapping(address=> address))  challengers;
      mapping (address => mapping(address=> bool))  stakers;
      mapping (address => uint) pw;
      error NotEnoughEther();
      
      struct Entry{
        uint index;
        uint value;
        bool minted;
                }
      mapping(address => Entry)  map;
      address[]  keyList;
   
   // ff whitelist
   function addFightToWl(address _fcont) external {
     require(msg.sender==ff);
     whitelistFc[_fcont] = true;
   }
   // Fight mint
   event finishedFight (address indexed fa);
    function fightMint(address _fa, uint _users, address _ls, uint _spotCounter) external onlyWhitelistedFc {
      if ((fightMintBalance < fightMintSupply) && (_ls != msg.sender) && (_spotCounter>=3)) {
        Entry storage entry = map[_fa];
        entry.value += _users * _spotCounter * 1000 * 10 ** uint(decimals());
        fightMintBalance += _users * _spotCounter * 1000 * 10 ** uint(decimals());
        if(entry.index > 0){
            return;
        }else {
            keyList.push(_fa);
            uint keyListIndex = keyList.length - 1;
            entry.index = keyListIndex + 1;
        }
      }
      else return;
      emit finishedFight(_fa);
    }

    function rewards_for_fights() external {
    Entry storage entry = map[msg.sender];
    require(vSupply>=vTotalSupply && entry.minted==false, "");
    uint mint_amount = entry.value;
    entry.value=0;
    entry.minted = true;
    _mint(msg.sender, mint_amount);
     } 

    function readFightRewards (address _addr)  public view returns (uint, uint, bool) {
     Entry storage m = map[_addr];
    return (m.index, m.value, m.minted);
      }

    function marketing_reward() external {
    require(vSupply>=vTotalSupply && msg.sender==marketing1 && longTermReward1==false, "");
    longTermReward1 = true;
    _mint(msg.sender, (189216000 * 10 ** uint(decimals())));
      }
    function changeMarketing1(address _addr1) public {
    require(msg.sender==marketing1, '');
    marketing1=_addr1;
      }

      event BadActors(uint date, address indexed reporter, address indexed reported);
      function reportBadActor(address _addr) external onlyWhitelisted {
      uint indx = index[_addr];
      Minters storage m = mintersDB[indx];
      require (challengers[msg.sender][_addr] != _addr && m.whitelisted!=false, "");
      challengers[msg.sender][_addr] = _addr;
      m.reported += 1;
      if (m.reported <wenBlock) 
          {bool existingStatus=m.whitelisted;
            m.whitelisted=existingStatus;
      }else {
          m.whitelisted=false;
          whitelist[_addr] = false;
      }
      emit BadActors (block.timestamp, msg.sender, _addr);
      }
      
      event GoodActors(uint date, address indexed reporter, address indexed reported);
      function reportGoodActor(address _addr) external payable onlyWhitelisted {
      uint indx = index[_addr];
      Minters storage m = mintersDB[indx];
      require (msg.sender != _addr, "");
      require (challengers[msg.sender][_addr] != _addr, "");
      require (m.goodCount<maxGoodCount, "maxGoodCount");
      require (m.reported>0, "");
      if (msg.value != goodPrice) revert NotEnoughEther();
      pw[listAdmin]+= goodPrice;
      challengers[msg.sender][_addr] = _addr;
      m.reported -= 1;
      m.goodCount+=1;
      if (m.reported >=wenBlock)  
          {bool existingStatus=m.whitelisted;
            m.whitelisted=existingStatus;
      }else {
          m.whitelisted=true;
          whitelist[_addr] = true;
      } 
      emit GoodActors (block.timestamp, msg.sender, _addr);
      }
      
      event mintersFree(address indexed minter, string Lat, string Lon, string Nick); 
      function AddToWhitelist (string memory  _gpsLat,string memory  _gpsLon, string memory _nickname) external {
      require(vSupply>= vTotalSupply, "");
      require(index[msg.sender]==0, "");
      mintersDB.push(Minters(0, 0, 0, _gpsLat, _gpsLon, _nickname, true, msg.sender));
      index[msg.sender] = mintersDB.length-1;
      whitelist[msg.sender] = true;
      emit mintersFree(msg.sender,_gpsLat, _gpsLon, _nickname);
    }
          
         
      event newMinter(uint date, address indexed minter, string Lat, string Lon, string Nick);
      function addToWhitelist_a7I(bytes calldata signature, string memory _gpsLat,string memory _gpsLon, string memory _nickname) external {
      bytes32 message = prefixed(keccak256(abi.encodePacked(
        msg.sender
      )));
      require(recoverSigner(message, signature) == signer && index[msg.sender]==0 , "invalidSigOrAlReg");
      mintersDB.push(Minters(0, 0, 0, _gpsLat, _gpsLon, _nickname, true, msg.sender));
      index[msg.sender] = mintersDB.length-1;
      whitelist[msg.sender] = true;
      emit newMinter(block.timestamp, msg.sender,_gpsLat, _gpsLon, _nickname);
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
      return keccak256(abi.encodePacked(
        '\x19Ethereum Signed Message:\n32', 
        hash
      ));
    }

    function recoverSigner(bytes32 message, bytes memory sig)
      internal
      pure
      returns (address)
    {
      uint8 v;
      bytes32 r;
      bytes32 s;
    
      (v, r, s) = splitSignature(sig);
    
      return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig)
      internal
      pure
      returns (uint8, bytes32, bytes32)
    {
      require(sig.length == 65);
    
      bytes32 r;
      bytes32 s;
      uint8 v;
    
      assembly {
          // first 32 bytes, after the length prefix
          r := mload(add(sig, 32))
          // second 32 bytes
          s := mload(add(sig, 64))
          // final byte (first byte of the next 32 bytes)
          v := byte(0, mload(add(sig, 96)))
      }
    
      return (v, r, s);
    }

      function SliceMinting() external onlyWhitelisted {
          require(vSupply>=vTotalSupply, "");
          uint amount = vSliceBalances[msg.sender];
          vSliceBalances[msg.sender]=0;
          _mint(msg.sender, amount);

      }

      function vSliceMinting_ExW() external onlyWhitelisted {
              require(vSupply<= vTotalSupply, "");
              uint indx = index[msg.sender];
              Minters storage m = mintersDB[indx];
              uint mint;
              uint diff;
          if (m.lastMinted == 0) {
              mint = (block.timestamp-start)* 10 ** uint(decimals());
              vSliceBalances[msg.sender]+= mint/mintingSpeed;
              m.lastMinted = block.timestamp;
              vSupply+= mint/mintingSpeed;}
          else {
              diff = block.timestamp - m.lastMinted;
              mint = diff* 10 ** uint(decimals());
              vSliceBalances[msg.sender]+= mint/mintingSpeed;
              m.lastMinted = block.timestamp;
              vSupply+= mint/mintingSpeed;}

      }
      
      
      function stakeVSlice_h56(uint _amount, address _addr) external onlyWhitelistedFc {
          uint indx = index[_addr];
          Minters storage m = mintersDB[indx];
          require (vSliceBalances[_addr] >= _amount && m.whitelisted!=false, "");
          stakedVSlices[_addr] += _amount;
          vSliceBalances[_addr] -= _amount;
          if (stakers[_addr][msg.sender] == false) {
              stakersList.push(StakedContracts(_addr, msg.sender));
              stakers[_addr][msg.sender] = true;
              stakedContractsCounter[_addr] += 1;
              stakedFightCounter[msg.sender] +=1;
          } else {return;}
          
      }
      
      function unstakeVSlice_Hha(uint _amount, address _addr) external onlyWhitelistedFc {
          uint indx = index[_addr];
          Minters storage m = mintersDB[indx];
          require(stakedVSlices[_addr]>=_amount && m.whitelisted!=false, "");
          stakedVSlices[_addr] -= _amount;
          vSliceBalances[_addr] += _amount;
          
      }
     
//GETTERs
      function getStakedByStaker(address _owner) view external returns (StakedContracts[] memory){
        StakedContracts[]    memory id = new StakedContracts[](stakedContractsCounter[_owner]);
            uint counter = 0;
            
        for (uint i = 0; i < stakersList.length; i++) {
            if (stakersList[i].staker == _owner) {
          StakedContracts storage list = stakersList[i];
            id[counter] = list;
            counter++;
        }
      }
        return id;
    }
      function getStakedByFight(address _fight) view external returns (StakedContracts[] memory){
        StakedContracts[]    memory id = new StakedContracts[](stakedFightCounter[_fight]);
            uint counter = 0;
            
        for (uint i = 0; i < stakersList.length; i++) {
            if (stakersList[i].fightContract== _fight) {
          StakedContracts storage list = stakersList[i];
            id[counter] = list;
            counter++;
        }
      }
        return id;
    }
      function getAllMinters() public view returns (Minters[] memory){
        Minters[]    memory id = new Minters[](mintersDB.length);
        for (uint i = 0; i < mintersDB.length; i++) {
            Minters storage mint = mintersDB[i];
            id[i] = mint;
        }
        return id;
    }
      function getMinter(address _addr)  view external returns (uint, uint, uint, string memory, string memory,string memory, bool, address) {
          uint indx = index[_addr];
          Minters storage m = mintersDB[indx];
          return (m.goodCount, m.reported,m.lastMinted, m.gpsLat, m.gpsLon, m.nickname, m.whitelisted, m.addr);
      }
      function  wl(address _addr) view external  returns (bool) {
          return whitelist[_addr] ;
      }
      function vSliceViewBalance (address _addr) view external returns (uint) {
      return vSliceBalances[_addr];
      }
      function isRegistered (address _addr) view external returns(uint) {
           return index[_addr];
      }
      function getMintingSpeed() public view returns (uint) {
          return mintingSpeed;
      }
      function getStakedBalance () view external returns (uint) {
      return stakedVSlices[msg.sender];
      }
      function getStart () view external returns (uint) {
      return start;
      }
 
      function getGoodP () view external returns (uint) {
      return goodPrice;
        }

      function countMinters() view external returns(uint) {
      return mintersDB.length;
      }

      function sliceParams() view external returns (uint, uint, uint, uint, uint, uint, address, uint, uint, uint, uint) {
      return (vSupply, vTotalSupply, wenBlock, maxGoodCount, mintingSpeed, goodPrice, signer, pw[listAdmin],fightMintSupply,fightMintBalance,fightMintSupply);
      }
// SETTERs only admin

    function reputation() public onlyAdmin{
      uint amount = pw[listAdmin];
      pw[listAdmin] = 0;
      payable(msg.sender).transfer(amount);
      }
    function setFF (address _addr) external onlyAdmin{
      ff = _addr;
      }
    function updateAdmin(address newAdmin) external onlyAdmin{
      listAdmin = newAdmin;
      }
    function updateSigner(address _newSigner) external onlyAdmin{
      signer = _newSigner;
      }
    function adminUpdate(uint _maxGoodcount, uint _wenBlockCount, uint _p) external onlyAdmin{
      maxGoodCount = _maxGoodcount;
      wenBlock = _wenBlockCount;
      goodPrice = _p;
      }
  }