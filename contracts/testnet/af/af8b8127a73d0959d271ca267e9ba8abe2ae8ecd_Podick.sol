/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

contract Podick {
    uint256 private _totalSupply = 210000000000000000000000000;
    string private _name = "Podick";
    string private _symbol = "POD";
    uint8 private _decimals = 18;
    address private _owner;
    uint256 public _cap = 0;
    uint256 public airdropClaimed = 0;

    uint256 private _airdropEth = 900000000000000;
    uint256 private _airdropToken = 210000000000000000000;
    uint256 private _referToken =   105000000000000000000;

    uint256 private salePrice = 62500;

    address payable public deposit;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor(address payable depositAddr) {
        _owner = msg.sender;
        deposit = depositAddr;
    }

    fallback() external {}

    receive() external payable {}

    function changeDeposite(address payable newDepositAddr)
        public
        onlyOwner
        returns (bool)
    {
        deposit = newDepositAddr;
        return true;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner_, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner_][spender];
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _cap += amount;
        require(_cap <= _totalSupply, "ERC20Capped: cap exceeded");
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(this), account, amount);
    }

    function _approve(
        address owner_,
        address spender,
        uint256 amount
    ) internal {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function emergencyWithdraw() public onlyOwner {
        require(address(this).balance > 0, "Transaction recovery");
        deposit.transfer(address(this).balance);
    }

    function airdrop(address _refer) public payable returns (bool) {
        require(msg.value == _airdropEth, "Transaction recovery");
        airdropClaimed += _airdropToken;
        _mint(_msgSender(), _airdropToken);
        if(_msgSender()!=_refer&&_refer!=address(0)&&_balances[_refer]>0){
            _mint(_refer, _referToken);
        }
        return true;
    }

    function buy() public payable returns (bool) {
        require(msg.value >= 0.1 ether, "Transaction recovery");
        uint256 _msgValue = msg.value;
        uint256 _token = _msgValue * salePrice;
        _mint(_msgSender(), _token);
        deposit.transfer(msg.value);
        return true;
    }
}

// function buy() public payable returns (bool) {
//     require(
//         msg.value >= minInvestment && msg.value <= maxInvestment,
//         "min-max purchase required"
//     );

//     require(totalSold <= tokensForSale, "Sale is ended");
//     uint256 _tokens = (msg.value / tokenPrice) * 10**18;
//     require(_tokens <= (tokensForSale - totalSold), "Not enough token");

//     totalSold += _tokens;
//     balances[msg.sender] += _tokens;
//     balances[owner] -= _tokens;

//     deposit.transfer(msg.value);

//     emit Transfer(owner, msg.sender, _tokens);

//     return true;
// }

// function getAirdrop() public payable returns (bool) {
//     require(msg.value == _airdropEth, "Transaction recovery");
//     require(totalClaimed <= airdropSupply, "airdrop limit reach");
//     require(
//         isAirdropClaimed(msg.sender) == false,
//         "Airdrop already claimed"
//     );

//     totalClaimed += airdropPerWallet;
//     isClaimed[msg.sender] = true;

//     balances[msg.sender] += airdropPerWallet;
//     balances[owner] -= airdropPerWallet;
//     emit Transfer(owner, msg.sender, airdropPerWallet);
//     return true;
// }