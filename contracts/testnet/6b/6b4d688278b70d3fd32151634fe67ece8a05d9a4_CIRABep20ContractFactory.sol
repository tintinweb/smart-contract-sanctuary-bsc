/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// File: Contract Factory/openzeppelin/IERC20.sol





pragma solidity ^0.8.0;



interface IERC20 {



    function totalSupply() external view returns (uint256);



    function balanceOf(address account) external view returns (uint256);



    function transfer(address recipient, uint256 amount) external returns (bool);



    function allowance(address owner, address spender) external view returns (uint256);



    function approve(address spender, uint256 amount) external returns (bool);



    function transferFrom(

        address sender,

        address recipient,

        uint256 amount

    ) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}


// File: Contract Factory/openzeppelin/IERC20Metadata.sol





pragma solidity ^0.8.0;




interface IERC20Metadata is IERC20 {



    function name() external view returns (string memory);



    function symbol() external view returns (string memory);



    function decimals() external view returns (uint8);



    function reflectionFee() external view returns (uint256);



    function lpFee() external view returns (uint256);



    function teamFee() external view returns (uint256);



    function marketingFee() external view returns (uint256);

}


// File: Contract Factory/openzeppelin/Context.sol





pragma solidity ^0.8.0;



abstract contract Context {

    function _msgSender() internal view virtual returns (address) {

        return msg.sender;

    }



    function _msgData() internal view virtual returns (bytes calldata) {

        return msg.data;

    }

}


// File: Contract Factory/openzeppelin/ERC20.sol





pragma solidity ^0.8.0;






contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;



    mapping(address => mapping(address => uint256)) private _allowances;



    uint256 private _totalSupply;

    uint8 private _decimals;

    uint256 private _reflectionFee;

    uint256 private _lpFee;

    uint256 private _teamFee;

    uint256 private _marketingFee;



    string private _name;

    string private _symbol;



    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 reflectionFee_, uint256 lpFee_, uint256 teamFee_, uint256 marketingFee_) {

        _name = name_;

        _symbol = symbol_;

        _decimals = decimals_;

        _reflectionFee = reflectionFee_;

        _lpFee = lpFee_;

        _teamFee = teamFee_;

        _marketingFee = marketingFee_;

    }



    function name() public view virtual override returns (string memory) {

        return _name;

    }



    function symbol() public view virtual override returns (string memory) {

        return _symbol;

    }



    function decimals() public view virtual override returns (uint8) {

        return _decimals;

    }





    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;

    }

    

    function reflectionFee() public view virtual override returns (uint256) {

        return _reflectionFee;

    }



    function lpFee() public view virtual override returns (uint256) {

        return _lpFee;

    }



    function teamFee() public view virtual override returns (uint256) {

        return _teamFee;

    }



    function marketingFee() public view virtual override returns (uint256) {

        return _marketingFee;

    }



    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];

    }



    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);

        return true;

    }



    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];

    }



    function approve(address spender, uint256 amount) public virtual override returns (bool) {

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

        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        unchecked {

            _approve(sender, _msgSender(), currentAllowance - amount);

        }



        return true;

    }



    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);

        return true;

    }



    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];

        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");

        unchecked {

            _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        }



        return true;

    }



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



    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");



        _beforeTokenTransfer(address(0), account, amount);



        _totalSupply += amount;

        _balances[account] += amount;

        emit Transfer(address(0), account, amount);



        _afterTokenTransfer(address(0), account, amount);

    }



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



    function _beforeTokenTransfer(

        address from,

        address to,

        uint256 amount

    ) internal virtual {}



    function _afterTokenTransfer(

        address from,

        address to,

        uint256 amount

    ) internal virtual {}

}


// File: Contract Factory/CIRABep20.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;




contract CIRABep20 is ERC20 {

    constructor(string memory name_, string memory symbol_, uint supply, uint8 decimals_, uint256 reflectionFee_, uint256 lpFee_, uint256 teamFee_, uint256 marketingFee_, address supplyAddress) ERC20(name_, symbol_, decimals_, reflectionFee_, lpFee_, teamFee_, marketingFee_) {

        _mint(supplyAddress, supply);

    }

}


// File: Contract Factory/openzeppelin/Ownable.sol





pragma solidity ^0.8.0;




abstract contract Ownable is Context {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    constructor() {

        _setOwner(_msgSender());

    }



    function owner() public view virtual returns (address) {

        return _owner;

    }



    modifier onlyOwner() {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

        _;

    }



    function renounceOwnership() public virtual onlyOwner {

        _setOwner(address(0));

    }



    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        _setOwner(newOwner);

    }



    function _setOwner(address newOwner) private {

        address oldOwner = _owner;

        _owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);

    }

}


// File: Contract Factory/CIRABep20ContractFactory.sol


pragma solidity ^0.8.0;





contract CIRABep20ContractFactory is Ownable {

    event TokenCreated(address indexed contractAddress, address indexed creatorAddress);



    uint private _fee;



    constructor(uint fee_) {

        _fee = fee_;

    }



    function fee() public view returns (uint) {

        return _fee;

    }



    function withdrawFees() public onlyOwner {

        payable(owner()).transfer(address(this).balance);

    }



    function createToken(string memory name_, string memory symbol_, uint supply, uint8 decimals, uint256 reflections, uint256 lpfee, uint256 teamfee, uint256 marketingfee) public payable returns (address) {

        require(msg.value == _fee, "Incorrect fee amount");



        address creatorAddress = msg.sender;

        address contractAddress = address(new CIRABep20(name_, symbol_, supply, decimals, reflections, lpfee, teamfee, marketingfee, creatorAddress));



        emit TokenCreated(contractAddress, creatorAddress);



        return contractAddress;

    }

}