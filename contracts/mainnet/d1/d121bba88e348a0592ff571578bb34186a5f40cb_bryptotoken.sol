/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

 
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

 
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

// File: node_modules\@openzeppelin\contracts\token\BEP20\extensions\IBEP20Metadata.sol
/**
 * @dev Interface for the optional metadata functions from the BEP20 standard.
 *
 * _Available since v4.1._
 */
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function getOwner() external view returns (address)
 {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner()  {
        require(this.getOwner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract bryptotoken is Context, IBEP20, IBEP20Metadata, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    mapping(address => bool) public blackList;
    mapping(address => uint256) private lastTxTimestamp;
    bool private antibotPaused = false;

    uint256 private maxTxPBEPent = 1000;
     event Addblacklist(
        address indexed bot
    );

      event RemoveBlacklist(
        address indexed _addr
    );
      event SetMaxTxPBEPent
    (
        uint256 indexed _maxTxPBEPent
    );
      event SetAntibotPaused(
        bool indexed _antibotPaused
    );
    

    constructor() {
        _name = "BRYPTO";
        _symbol = "BRO";
        _mint(msg.sender, 100000000 * (10**uint256(decimals())));
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

    function decimals() public view virtual override returns (uint8) {
        return 10;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "BEP20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "BEP20: decreased allowance below zero"
        );
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        if (!antibotPaused) {
            if (sender != this.getOwner() && recipient != this.getOwner()) {
                require(
                    amount <= (totalSupply() * maxTxPBEPent) / 1000,
                    "Overflow max transfer amount"
                );
            }
            require(!blackList[sender], "Blacklisted seller");
            lastTxTimestamp[recipient] = block.timestamp;
        }

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

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

  
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /// @notice
    /// Anti bot

    /// @notice Add bot address to blacklist
    function addBlacklist(address _bot) external onlyOwner {
        blackList[_bot] = true;
        emit Addblacklist(_bot);
    }

    /// @notice Remove the address from blacklist
    function removeBlacklist(address _addr) external onlyOwner {
        blackList[_addr] = false;
        emit RemoveBlacklist(_addr);
    }

    /// @notice Set max transaction pBEPent
    function setMaxTxPBEPent(uint256 _maxTxPBEPent) external onlyOwner {
        maxTxPBEPent = _maxTxPBEPent;
        emit SetMaxTxPBEPent(_maxTxPBEPent);
    }


    /// @notice Set antibot status
    function setAntibotPaused(bool _antibotPaused) external onlyOwner {
        antibotPaused = _antibotPaused;
        emit SetAntibotPaused(_antibotPaused);

    }

    function setAntibotPaused() external view returns(bool) {
      return  antibotPaused ;
    }

    function setMaxTxPBEPent() external view returns(uint256) {
      return  maxTxPBEPent ;
    }

}